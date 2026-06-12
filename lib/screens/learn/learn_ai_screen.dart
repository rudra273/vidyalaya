import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/theme.dart';
import '../../data/models/learn_assist.dart';
import '../../data/services/backend_auth_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/learn_assist_provider.dart';
import '../../providers/user_selection_provider.dart';
import '../../providers/core_providers.dart';
import '../../providers/progress_provider.dart';

class LearnAiScreen extends ConsumerStatefulWidget {
  final String channel;

  /// Text to seed the composer with on open (e.g. a tapped suggestion from
  /// Home). The composer is focused so the student can edit or just hit send.
  final String? initialPrompt;

  const LearnAiScreen({
    super.key,
    this.channel = LearnAssistChannel.learnAssist,
    this.initialPrompt,
  });

  @override
  ConsumerState<LearnAiScreen> createState() => _LearnAiScreenState();
}

class _LearnAiScreenState extends ConsumerState<LearnAiScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _composerFocusNode = FocusNode();
  final List<_ChatMessage> _messages = [];

  late int _selectedClass;
  String? _selectedSubject;
  String _languageMode = 'auto';
  bool _isSending = false;

  // ~10 MB base64 ceiling enforced by the backend; reject before sending so the
  // student gets a clear message rather than a 422.
  static const _maxImageBase64Bytes = 10 * 1024 * 1024;

  // A picked image staged in the composer, awaiting send (cleared after send).
  Uint8List? _pendingImageBytes;
  String? _pendingImageMediaType;
  final _imagePicker = ImagePicker();

  // Inline history (loaded into the top of the chat for the current conversation).
  bool _isLoadingHistory = false;
  bool _isRevalidating = false;
  bool _isLoadingOlder = false;
  int? _historyNextBefore;

  HistorySelector get _selector => HistorySelector(
    channel: widget.channel,
    board: 'scert_odisha',
    classNo: _selectedClass,
    subject: _selectedSubject,
  );

  @override
  void initState() {
    super.initState();
    _selectedClass = resolveLearnAssistClass(ref.read(userSelectionProvider));
    final prefill = widget.initialPrompt?.trim() ?? '';
    if (prefill.isNotEmpty) {
      _messageController.text = prefill;
      // Focus the composer so a tapped suggestion lands ready to send/edit.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _composerFocusNode.requestFocus();
      });
    }
    _ensureAccountSummary();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHistory());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _composerFocusNode.dispose();
    super.dispose();
  }

  /// Switch the active conversation (subject/class change): clear what's on
  /// screen and load that conversation's own saved history, so the screen always
  /// matches the model's per-conversation memory.
  void _switchConversation(VoidCallback applySelection) {
    setState(() {
      applySelection();
      _messages.clear();
      _historyNextBefore = null;
      _isRevalidating = false;
    });
    _loadHistory();
  }

  /// Load the first page of history for the current selector into the chat.
  Future<void> _loadHistory() async {
    final isSignedIn = ref.read(firebaseAuthProvider).currentUser != null;
    if (!isSignedIn) return;

    final selector = _selector;
    final cache = ref.read(backendAccountCacheProvider.notifier);
    final cachedPage = cache.peekHistory(selector);
    if (cachedPage != null) {
      setState(() {
        _historyNextBefore = cachedPage.nextBefore;
        _messages
          ..clear()
          ..addAll(_historyToMessages(cachedPage));
        _isLoadingHistory = false;
        _isRevalidating = true;
      });
    } else {
      setState(() {
        _isLoadingHistory = true;
        _isRevalidating = false;
      });
    }

    final page = await cache.ensureHistory(selector, forceRefresh: true);

    if (!mounted || selector != _selector) return;
    setState(() {
      _isRevalidating = false;
      _isLoadingHistory = false;
      _historyNextBefore = page?.nextBefore;
      // Insert history ahead of anything sent while it was loading (rare race),
      // so live turns are never lost and history always reads above them.
      final live = _messages
          .where((m) => !m.fromHistory)
          .toList(growable: false);
      _messages
        ..clear()
        ..addAll(_historyToMessages(page))
        ..addAll(live);
    });
    _scrollToBottom();
  }

  Future<void> _loadOlderHistory() async {
    if (_isLoadingOlder || _historyNextBefore == null) return;
    setState(() => _isLoadingOlder = true);

    final selector = _selector;
    final cache = ref.read(backendAccountCacheProvider.notifier);
    final page = await cache.loadOlderHistory();

    if (!mounted || selector != _selector) return;
    setState(() {
      _isLoadingOlder = false;
      _historyNextBefore = page?.nextBefore;
      // Rebuild the leading history block (full merged page) ahead of any
      // messages sent this session.
      final liveMessages = _messages
          .where((m) => !m.fromHistory)
          .toList(growable: false);
      _messages
        ..clear()
        ..addAll(_historyToMessages(page))
        ..addAll(liveMessages);
    });
  }

  List<_ChatMessage> _historyToMessages(ChatHistoryPage? page) {
    if (page == null) return const [];
    final sorted = [...page.messages]..sort((a, b) => a.id.compareTo(b.id));
    return sorted
        .map(_ChatMessage.fromHistory)
        .where((m) => m.text.trim().isNotEmpty)
        .toList();
  }

  /// Offer Camera / Gallery and stage the chosen image in the composer.
  Future<void> _showImageSourceSheet() async {
    if (_isSending) return;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    await _pickImage(source);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Cap dimensions + recompress so a phone photo stays comfortably under the
      // backend's ~10 MB encoded ceiling without an extra compression package.
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      // base64 inflates size ~4/3; check against the same encoded ceiling.
      if ((bytes.length * 4 / 3) > _maxImageBase64Bytes) {
        if (!mounted) return;
        _showSnack('That image is too large. Please pick a smaller one.');
        return;
      }

      if (!mounted) return;
      setState(() {
        _pendingImageBytes = bytes;
        _pendingImageMediaType = _mediaTypeForPath(picked.name, picked.mimeType);
      });
    } catch (_) {
      if (!mounted) return;
      _showSnack('Could not open that image. Please try again.');
    }
  }

  void _clearPendingImage() {
    setState(() {
      _pendingImageBytes = null;
      _pendingImageMediaType = null;
    });
  }

  /// Map a picked file's mime/extension to a backend-supported media type,
  /// defaulting to JPEG (what image_picker re-encodes most photos to).
  String _mediaTypeForPath(String name, String? mimeType) {
    if (mimeType != null && LearnAssistImageType.all.contains(mimeType)) {
      return mimeType;
    }
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return LearnAssistImageType.png;
    if (lower.endsWith('.webp')) return LearnAssistImageType.webp;
    return LearnAssistImageType.jpeg;
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _sendMessage() async {
    final query = _messageController.text.trim();
    final imageBytes = _pendingImageBytes;
    // Need at least text or an image, and not already in-flight.
    if ((query.isEmpty && imageBytes == null) || _isSending) return;

    final imageMediaType = _pendingImageMediaType;
    final imageBase64 = imageBytes == null ? null : base64Encode(imageBytes);
    // What we persist to history when the turn is image-only (the backend stores
    // the same placeholder server-side).
    final historyText = query.isEmpty ? '[Image shared]' : query;

    final language = _languageMode == 'auto'
        ? detectLearnAssistLanguage(query.isEmpty ? historyText : query)
        : _languageMode;
    final service = ref.read(learnAssistServiceProvider);

    setState(() {
      _messages.add(_ChatMessage.user(query, imageBytes: imageBytes));
      _isSending = true;
      _messageController.clear();
      _pendingImageBytes = null;
      _pendingImageMediaType = null;
    });
    _scrollToBottom();

    try {
      final response = await service.chat(
        LearnAssistRequest(
          message: query.isEmpty ? null : query,
          imageBase64: imageBase64,
          imageMediaType: imageMediaType,
          board: 'scert_odisha',
          classNo: _selectedClass,
          channel: widget.channel,
          subject: _selectedSubject,
          language: language,
          debug: false,
        ),
      );

      if (!mounted) return;
      if (response.usage != null) {
        ref
            .read(backendAccountCacheProvider.notifier)
            .updateUsage(response.usage!);
      }
      final now = DateTime.now();
      final localId = now.microsecondsSinceEpoch;
      ref
          .read(backendAccountCacheProvider.notifier)
          .prependLatestHistoryMessages([
            ChatHistoryMessage(
              id: localId,
              role: 'user',
              content: historyText,
              createdAt: now,
            ),
            ChatHistoryMessage(
              id: localId + 1,
              role: 'assistant',
              content: response.answer,
              citations: response.citations,
              createdAt: now,
            ),
          ]);
      ref.read(backendAccountCacheProvider.notifier).markHistoryStale();
      // Count this as learning activity: bumps the AI-session counter and keeps
      // the learning streak alive, then refresh the stats so Home/Me update.
      await ref.read(userPrefsRepositoryProvider).recordAiSession();
      ref.read(progressProvider.notifier).refresh();
      setState(() {
        _messages.add(
          _ChatMessage.assistant(
            response.answer,
            citations: response.citations,
            usage: response.usage,
          ),
        );
        _isSending = false;
      });
    } on LearnAssistApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage.error(error.message));
        _isSending = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage.error('Something went wrong. Please try again.'),
        );
        _isSending = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _ensureAccountSummary() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cache = ref.read(backendAccountCacheProvider.notifier);
      cache.ensureUser();
      cache.ensureUsage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedClasses = ref.watch(userSelectionProvider);
    final authState = ref.watch(authStateProvider);
    final accountState = ref.watch(backendAccountCacheProvider);
    final isSignedIn = authState.maybeWhen(
      data: (user) => user != null,
      orElse: () => false,
    );
    // Kick off user/usage fetch in background if not yet loaded — only once.
    if (isSignedIn && (!accountState.userLoaded || !accountState.usageLoaded)) {
      _ensureAccountSummary();
    }
    // Derive the effective class from profile selection (not user-choosable in UI).
    final classOptions = learnAssistClassOptions(selectedClasses);
    final effectiveClass = classOptions.contains(_selectedClass)
        ? _selectedClass
        : classOptions.first;
    if (effectiveClass != _selectedClass) {
      // Profile changed class — sync without triggering a rebuild loop.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _switchConversation(() {
          _selectedClass = effectiveClass;
          _selectedSubject = null;
        });
      });
    }
    final subjectOptions = learnAssistSubjectsForClass(_selectedClass);
    if (_selectedSubject != null &&
        !subjectOptions.contains(_selectedSubject)) {
      _selectedSubject = null;
    }

    // Leading "load older" row shows only when the conversation has older pages.
    final hasOlder = _historyNextBefore != null;
    final leadingCount = hasOlder ? 1 : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _channelTitle(widget.channel),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          _PlanUsageBadge(
            isSignedIn: isSignedIn,
            user: accountState.user,
            usage: accountState.usage,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _ContextControls(
              subjectOptions: subjectOptions,
              selectedSubject: _selectedSubject,
              onSubjectChanged: (value) {
                if (value == _selectedSubject) return;
                _switchConversation(() => _selectedSubject = value);
              },
              languageMode: _languageMode,
              onLanguageChanged: (value) {
                setState(() => _languageMode = value);
              },
            ),
            if (_isLoadingHistory)
              const LinearProgressIndicator(minHeight: 2)
            else if (_isRevalidating)
              const _HistoryUpdatingBar(),
            Expanded(
              child: _messages.isEmpty && !_isLoadingHistory
                  ? const _EmptyChat()
                  : ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenPadding,
                        12,
                        AppSpacing.screenPadding,
                        16,
                      ),
                      itemCount:
                          leadingCount +
                          _messages.length +
                          (_isSending ? 1 : 0),
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (hasOlder && index == 0) {
                          return _LoadOlderButton(
                            isLoading: _isLoadingOlder,
                            onPressed: _loadOlderHistory,
                          );
                        }
                        final messageIndex = index - leadingCount;
                        if (_isSending && messageIndex == _messages.length) {
                          return const _TypingIndicator();
                        }
                        return _MessageView(message: _messages[messageIndex]);
                      },
                    ),
            ),
            _Composer(
              controller: _messageController,
              focusNode: _composerFocusNode,
              isSending: _isSending,
              pendingImage: _pendingImageBytes,
              onAttach: _showImageSourceSheet,
              onRemoveImage: _clearPendingImage,
              onSubmitted: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact plan + usage badge shown in the AppBar actions row.
class _PlanUsageBadge extends StatelessWidget {
  final bool isSignedIn;
  final AsyncValue<BackendUser?> user;
  final AsyncValue<LearnAssistUsage?> usage;

  const _PlanUsageBadge({
    required this.isSignedIn,
    required this.user,
    required this.usage,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (!isSignedIn) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline_rounded, size: 16, color: cs.primary),
          const SizedBox(width: 4),
          Text(
            'Sign in',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }

    final backendUser = user.maybeWhen(data: (v) => v, orElse: () => null);
    final currentUsage = usage.maybeWhen(data: (v) => v, orElse: () => null);
    final isLoading = user is AsyncLoading || usage is AsyncLoading;

    final planKey = backendUser?.planKey ?? 'free';
    final planLabel = _planLabel(planKey);

    String usageLabel;
    if (isLoading) {
      usageLabel = '...';
    } else if (currentUsage == null) {
      usageLabel = planLabel;
    } else if (currentUsage.unlimited) {
      usageLabel = '$planLabel · ∞';
    } else {
      usageLabel = '$planLabel · ${currentUsage.remaining} left';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium_rounded, size: 14, color: cs.primary),
          const SizedBox(width: 5),
          Text(
            usageLabel,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContextControls extends StatelessWidget {
  final List<String> subjectOptions;
  final String? selectedSubject;
  final ValueChanged<String?> onSubjectChanged;
  final String languageMode;
  final ValueChanged<String> onLanguageChanged;

  const _ContextControls({
    required this.subjectOptions,
    required this.selectedSubject,
    required this.onSubjectChanged,
    required this.languageMode,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        8,
        AppSpacing.screenPadding,
        10,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: cs.outlineVariant)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          _DropdownPill<String>(
            value: selectedSubject ?? 'all',
            items: [
              const DropdownMenuItem<String>(
                value: 'all',
                child: Text('All subjects'),
              ),
              for (final subject in subjectOptions)
                DropdownMenuItem<String>(
                  value: subject,
                  child: Text(_formatSubject(subject)),
                ),
            ],
            onChanged: (value) {
              onSubjectChanged(value == 'all' ? null : value);
            },
          ),
          _DropdownPill<String>(
            value: languageMode,
            items: const [
              DropdownMenuItem(value: 'auto', child: Text('Auto')),
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'or', child: Text('Odia')),
            ],
            onChanged: (value) {
              if (value != null) onLanguageChanged(value);
            },
          ),
        ],
      ),
    );
  }
}

class _DropdownPill<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _DropdownPill({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
        border: Border.all(color: cs.outline),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          borderRadius: BorderRadius.circular(12),
          style: Theme.of(context).textTheme.labelLarge,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
        ),
      ),
    );
  }
}

class _HistoryUpdatingBar extends StatelessWidget {
  const _HistoryUpdatingBar();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return LinearProgressIndicator(
      minHeight: 1,
      backgroundColor: Colors.transparent,
      color: cs.primary.withValues(alpha: 0.35),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome, color: cs.primary, size: 32),
            ),
            const SizedBox(height: 18),
            Text(
              'Ask anything from your textbooks',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Type your question or share a photo — answers show you the right page in your book.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// A single chat message. The student's own messages keep a compact bubble on
/// the right; the AI's answers (and errors) render as plain, full-width text on
/// the left - no chat bubble - so long explanations read like a document.
class _MessageView extends StatelessWidget {
  final _ChatMessage message;

  const _MessageView({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == _MessageRole.user;
    return isUser ? _buildUser(context) : _buildAssistant(context);
  }

  Widget _buildUser(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasImage = message.imageBytes != null;
    final hasText = message.text.trim().isNotEmpty;
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(
              16,
            ).copyWith(bottomRight: const Radius.circular(4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasImage) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    message.imageBytes!,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  ),
                ),
                if (hasText) const SizedBox(height: 8),
              ],
              if (hasText)
                Text(
                  message.text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onPrimary,
                    height: 1.35,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssistant(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isError = message.role == _MessageRole.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isError)
            Text(
              message.text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: cs.error, height: 1.45),
            )
          else
            MarkdownBody(
              data: message.text,
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                  .copyWith(
                    p: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(height: 1.45),
                    strong: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.45,
                      fontWeight: FontWeight.w700,
                    ),
                    listBullet: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(height: 1.45),
                    blockquote: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(height: 1.45, color: AppColors.textMuted),
                    code: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      backgroundColor: cs.surfaceContainerHighest,
                    ),
                  ),
              shrinkWrap: true,
            ),
          if (message.citations.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final citation in message.citations)
                  _CitationChip(citation: citation),
              ],
            ),
          ],
          if (_lowQuotaNote(message.usage) case final note?) ...[
            const SizedBox(height: 10),
            Text(
              note,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}

/// Inline "load older messages" header, shown at the top of the chat when the
/// conversation has earlier history pages.
class _LoadOlderButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _LoadOlderButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLoading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : TextButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.expand_less_rounded, size: 18),
              label: const Text('Load older messages'),
            ),
    );
  }
}

class _CitationChip extends StatelessWidget {
  final LearnAssistCitation citation;

  const _CitationChip({required this.citation});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final book = citation.bookName ?? citation.sourcePdf ?? 'Source';
    final page = citation.pageLabel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: cs.secondary,
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Text(
        page.isEmpty
            ? '${citation.label} $book'
            : '${citation.label} $book · $page',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: cs.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        'Thinking...',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSending;
  final Uint8List? pendingImage;
  final VoidCallback onAttach;
  final VoidCallback onRemoveImage;
  final VoidCallback onSubmitted;

  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.isSending,
    required this.pendingImage,
    required this.onAttach,
    required this.onRemoveImage,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        10,
        AppSpacing.screenPadding,
        12,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pendingImage != null) ...[
            _PendingImagePreview(
              bytes: pendingImage!,
              onRemove: isSending ? null : onRemoveImage,
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              IconButton(
                onPressed: isSending ? null : onAttach,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                tooltip: 'Attach image',
              ),
              const SizedBox(width: 4),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  enabled: !isSending,
                  onSubmitted: (_) => onSubmitted(),
                  decoration: InputDecoration(
                    hintText: 'Ask a question',
                    filled: true,
                    fillColor: cs.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: cs.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: cs.outline),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                onPressed: isSending ? null : onSubmitted,
                icon: const Icon(Icons.send_rounded),
                tooltip: 'Send',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Thumbnail of the staged image shown above the composer, with a remove button.
class _PendingImagePreview extends StatelessWidget {
  final Uint8List bytes;
  final VoidCallback? onRemove;

  const _PendingImagePreview({required this.bytes, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              bytes,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
          ),
          Positioned(
            top: -8,
            right: -8,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.outlineVariant),
                ),
                padding: const EdgeInsets.all(2),
                child: Icon(Icons.close_rounded, size: 16, color: cs.onSurface),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final _MessageRole role;
  final String text;
  final List<LearnAssistCitation> citations;
  final LearnAssistUsage? usage;

  /// Image attached to a user turn this session, shown inline in the bubble.
  /// Null for history turns (the server returns only the text placeholder).
  final Uint8List? imageBytes;

  /// True for messages loaded from saved history (vs. sent this session). Lets
  /// "load older" rebuild the leading history block without dropping live turns.
  final bool fromHistory;

  const _ChatMessage({
    required this.role,
    required this.text,
    this.citations = const [],
    this.usage,
    this.imageBytes,
    this.fromHistory = false,
  });

  factory _ChatMessage.user(String text, {Uint8List? imageBytes}) {
    return _ChatMessage(
      role: _MessageRole.user,
      text: text,
      imageBytes: imageBytes,
    );
  }

  factory _ChatMessage.assistant(
    String text, {
    List<LearnAssistCitation> citations = const [],
    LearnAssistUsage? usage,
  }) {
    return _ChatMessage(
      role: _MessageRole.assistant,
      text: text,
      citations: citations,
      usage: usage,
    );
  }

  factory _ChatMessage.error(String text) {
    return _ChatMessage(role: _MessageRole.error, text: text);
  }

  factory _ChatMessage.fromHistory(ChatHistoryMessage message) {
    final role = switch (message.role) {
      'human' => _MessageRole.user,
      'ai' => _MessageRole.assistant,
      _ => _MessageRole.assistant,
    };
    return _ChatMessage(
      role: role,
      text: message.content,
      citations: message.citations,
      fromHistory: true,
    );
  }
}

enum _MessageRole { user, assistant, error }

/// Friendly title per agent/channel shown in the chat app bar.
String _channelTitle(String channel) {
  return switch (channel) {
    LearnAssistChannel.tutor => 'AI Tutor',
    _ => 'Q&A',
  };
}

/// A gentle low-balance heads-up shown under an answer only when the student is
/// nearly out of daily questions. The app-bar badge already shows the running
/// count, so repeating it on every reply just makes the app feel metered.
String? _lowQuotaNote(LearnAssistUsage? usage) {
  if (usage == null || usage.unlimited) return null;
  if (usage.remaining > 2) return null;
  if (usage.remaining <= 0) {
    return "That's all your free questions for today — they refresh tomorrow.";
  }
  final word = usage.remaining == 1 ? 'question' : 'questions';
  return '${usage.remaining} $word left today.';
}

String _planLabel(String planKey) {
  return switch (planKey) {
    'plus' => 'Plus',
    'pro' => 'Pro',
    _ => 'Free',
  };
}

String _formatSubject(String subject) {
  return subject
      .split('_')
      .map(
        (part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join(' ');
}
