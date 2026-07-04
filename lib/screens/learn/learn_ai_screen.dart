import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/theme.dart';
import '../../utils/haptics.dart';
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

  /// Open with the composer already focused (keyboard up), even with no seeded
  /// text — e.g. when the student taps the Ask bar on Home. A non-empty
  /// [initialPrompt] always focuses regardless of this flag.
  final bool autofocus;

  const LearnAiScreen({
    super.key,
    this.channel = LearnAssistChannel.learnAssist,
    this.initialPrompt,
    this.autofocus = false,
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

  /// Index into [_messages] of the in-progress streamed answer, or null before
  /// the first token has arrived. Used to grow that one message in place
  /// instead of appending a new one per token, and to suppress the typing-dots
  /// slot once real text is on screen.
  int? _streamingMessageIndex;

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
  // Set when a history fetch failed and there was nothing cached to fall back
  // on, so the chat shows a retry affordance instead of a silent blank.
  bool _historyLoadFailed = false;
  int? _historyNextBefore;

  // After 30+ minutes away, the previous conversation stays tucked behind a
  // "load previous chat" link so the student lands on a fresh start with
  // suggestions, instead of scrolling old messages.
  static const _staleChatThreshold = Duration(minutes: 30);
  bool _historyHidden = false;

  /// Board from the saved profile (single-board today, multi-board ready).
  String get _board => ref.read(userBoardProvider);

  HistorySelector get _selector => HistorySelector(
    channel: widget.channel,
    board: _board,
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
    }
    // Focus the composer (keyboard up) when arriving from a tapped suggestion
    // or the Home Ask bar, so the screen lands ready to type/send.
    if (prefill.isNotEmpty || widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _composerFocusNode.requestFocus();
      });
    }
    // Fresh-start rule: if the student last chatted more than 30 minutes ago,
    // keep the previous conversation hidden behind a tap so the screen opens
    // on suggestions. A brand-new user (no activity yet) has nothing to hide.
    final lastActivity = ref
        .read(userPrefsRepositoryProvider)
        .getChatLastActivity(widget.channel);
    _historyHidden =
        lastActivity != null &&
        DateTime.now().difference(lastActivity) > _staleChatThreshold;
    _ensureAccountSummary();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHistory());
  }

  /// Student tapped "Load previous chat": reveal and fetch the conversation.
  void _revealHistory() {
    setState(() => _historyHidden = false);
    ref.read(userPrefsRepositoryProvider).recordChatActivity(widget.channel);
    _loadHistory();
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
    if (_historyHidden) return;
    final isSignedIn = ref.read(firebaseAuthProvider).currentUser != null;
    if (!isSignedIn) return;

    final selector = _selector;
    final cache = ref.read(backendAccountCacheProvider.notifier);
    final cachedPage = cache.peekHistory(selector);
    if (cachedPage != null) {
      setState(() {
        _historyLoadFailed = false;
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
    // A null page with nothing cached means the fetch failed with no fallback.
    // Distinguish that from a genuinely empty conversation by checking whether
    // the account state parked an error for this selector.
    final historyErrored = page == null &&
        ref.read(backendAccountCacheProvider).history is AsyncError;
    setState(() {
      _isRevalidating = false;
      _isLoadingHistory = false;
      _historyLoadFailed = historyErrored;
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
        _pendingImageMediaType = _mediaTypeForPath(
          picked.name,
          picked.mimeType,
        );
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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

    Haptics.light(ref);
    setState(() {
      _messages.add(_ChatMessage.user(query, imageBytes: imageBytes));
      _isSending = true;
      _streamingMessageIndex = null;
      _messageController.clear();
      _pendingImageBytes = null;
      _pendingImageMediaType = null;
    });
    ref.read(userPrefsRepositoryProvider).recordChatActivity(widget.channel);
    _scrollToBottom();

    final answerBuffer = StringBuffer();
    var citations = const <LearnAssistCitation>[];
    LearnAssistUsage? usage;
    // The complete answer from the terminal 'done' frame. Used as a fallback
    // when a provider streamed no token frames (paid plans route through
    // OpenRouter, which doesn't emit incremental chunks) so the bubble is never
    // left empty.
    var doneAnswer = '';

    void appendToken(String text) {
      if (text.isEmpty) return;
      answerBuffer.write(text);
      setState(() {
        final message = _ChatMessage.assistant(
          answerBuffer.toString(),
          isStreaming: true,
        );
        if (_streamingMessageIndex == null) {
          _streamingMessageIndex = _messages.length;
          _messages.add(message);
        } else {
          _messages[_streamingMessageIndex!] = message;
        }
      });
      _scrollToBottom();
    }

    try {
      await for (final event in service.chatStream(
        LearnAssistRequest(
          message: query.isEmpty ? null : query,
          imageBase64: imageBase64,
          imageMediaType: imageMediaType,
          board: _board,
          classNo: _selectedClass,
          channel: widget.channel,
          subject: _selectedSubject,
          language: language,
          debug: false,
        ),
      )) {
        if (!mounted) return;
        switch (event) {
          case LearnAssistTokenEvent(:final text):
            appendToken(text);
            break;
          case LearnAssistDoneEvent(
            answer: final eventAnswer,
            citations: final eventCitations,
            usage: final eventUsage,
          ):
            doneAnswer = eventAnswer;
            citations = eventCitations;
            usage = eventUsage;
            break;
          case LearnAssistErrorEvent(:final code, :final message):
            throw LearnAssistApiException(code, message);
          case LearnAssistToolEvent():
            break; // Progress-only signal; the growing answer already conveys activity.
        }
      }

      if (!mounted) return;
      // Prefer the text streamed token-by-token; fall back to the complete
      // answer from the 'done' frame when a provider emitted no token frames.
      final streamed = answerBuffer.toString();
      final answer = streamed.isNotEmpty ? streamed : doneAnswer;
      final finalUsage = usage;
      if (finalUsage != null) {
        ref.read(backendAccountCacheProvider.notifier).updateUsage(finalUsage);
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
              content: answer,
              citations: citations,
              createdAt: now,
            ),
          ]);
      ref.read(backendAccountCacheProvider.notifier).markHistoryStale();
      // Count this as learning activity: bumps the AI-session counter and keeps
      // the learning streak alive, then refresh the stats so Home/Me update.
      await ref.read(userPrefsRepositoryProvider).recordAiSession();
      ref.read(progressProvider.notifier).refresh();
      setState(() {
        final finalMessage = _ChatMessage.assistant(
          answer.isEmpty ? '(no answer)' : answer,
          citations: citations,
          usage: usage,
        );
        if (_streamingMessageIndex != null) {
          _messages[_streamingMessageIndex!] = finalMessage;
        } else {
          _messages.add(finalMessage);
        }
        _streamingMessageIndex = null;
        _isSending = false;
      });
    } on LearnAssistApiException catch (error) {
      if (!mounted) return;
      Haptics.error(ref);
      setState(() {
        final errorMessage = _ChatMessage.error(error.message);
        if (_streamingMessageIndex != null) {
          _messages[_streamingMessageIndex!] = errorMessage;
        } else {
          _messages.add(errorMessage);
        }
        _streamingMessageIndex = null;
        _isSending = false;
      });
    } catch (_) {
      if (!mounted) return;
      Haptics.error(ref);
      setState(() {
        final errorMessage = _ChatMessage.error(
          'Something went wrong. Please try again.',
        );
        if (_streamingMessageIndex != null) {
          _messages[_streamingMessageIndex!] = errorMessage;
        } else {
          _messages.add(errorMessage);
        }
        _streamingMessageIndex = null;
        _isSending = false;
      });
    }
    _scrollToBottom();
  }

  /// Tapped suggestion: prefill the composer (don't auto-send) so the student
  /// can tweak the question before sending.
  void _applySuggestion(String text) {
    _messageController.text = text;
    _messageController.selection = TextSelection.collapsed(
      offset: text.length,
    );
    _composerFocusNode.requestFocus();
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
          style: Theme.of(context).textTheme.headlineSmall,
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
              const _HistoryUpdatingBar()
            else if (_historyLoadFailed)
              _HistoryErrorBar(onRetry: _loadHistory),
            Expanded(
              child: _messages.isEmpty && !_isLoadingHistory && !_isSending
                  ? _EmptyChat(
                      suggestions: _suggestionsFor(_selectedSubject),
                      onSuggestionTap: _applySuggestion,
                      showLoadPrevious: _historyHidden && isSignedIn,
                      onLoadPrevious: _revealHistory,
                    )
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
                          // The dots-only placeholder only makes sense before the
                          // first token lands — once streaming has a message of
                          // its own in _messages, this extra slot would trail it.
                          (_isSending && _streamingMessageIndex == null
                              ? 1
                              : 0),
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (hasOlder && index == 0) {
                          return _LoadOlderButton(
                            isLoading: _isLoadingOlder,
                            onPressed: _loadOlderHistory,
                          );
                        }
                        final messageIndex = index - leadingCount;
                        if (_isSending &&
                            _streamingMessageIndex == null &&
                            messageIndex == _messages.length) {
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
    // Only treat usage as errored when there's no cached value to show; a
    // stale-but-present count is more useful than a warning glyph.
    final usageErrored = usage is AsyncError && currentUsage == null;

    final planKey = backendUser?.planKey ?? 'free';
    final planLabel = _planLabel(planKey);

    String usageLabel;
    if (isLoading) {
      usageLabel = '...';
    } else if (usageErrored) {
      usageLabel = '$planLabel · —';
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
          Icon(
            usageErrored
                ? Icons.sync_problem_rounded
                : Icons.workspace_premium_rounded,
            size: 14,
            color: usageErrored ? cs.error : cs.primary,
          ),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        6,
        AppSpacing.screenPadding,
        8,
      ),
      child: Row(
        children: [
          _MenuChip<String>(
            icon: Icons.menu_book_rounded,
            label: selectedSubject == null
                ? 'All subjects'
                : _formatSubject(selectedSubject!),
            value: selectedSubject ?? 'all',
            options: [
              const ('all', 'All subjects'),
              for (final subject in subjectOptions)
                (subject, _formatSubject(subject)),
            ],
            onSelected: (value) {
              onSubjectChanged(value == 'all' ? null : value);
            },
          ),
          const SizedBox(width: 8),
          _MenuChip<String>(
            icon: Icons.translate_rounded,
            label: switch (languageMode) {
              'en' => 'English',
              'or' => 'Odia',
              _ => 'Auto',
            },
            value: languageMode,
            options: const [
              ('auto', 'Auto'),
              ('en', 'English'),
              ('or', 'Odia'),
            ],
            onSelected: onLanguageChanged,
          ),
        ],
      ),
    );
  }
}

/// A small pill that opens a popup menu — much lighter than a full dropdown.
class _MenuChip<T> extends StatelessWidget {
  final IconData icon;
  final String label;
  final T value;
  final List<(T, String)> options;
  final ValueChanged<T> onSelected;

  const _MenuChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.ink2Dark : AppColors.ink2;

    return PopupMenuButton<T>(
      initialValue: value,
      onSelected: onSelected,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: cs.outline),
      ),
      color: cs.surface,
      itemBuilder: (context) => [
        for (final (optionValue, optionLabel) in options)
          PopupMenuItem<T>(
            value: optionValue,
            height: 40,
            child: Text(
              optionLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: optionValue == value
                    ? FontWeight.w700
                    : FontWeight.w400,
                color: optionValue == value ? cs.primary : cs.onSurface,
              ),
            ),
          ),
      ],
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: muted),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(width: 3),
            Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: muted),
          ],
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

/// Shown when the past-conversation fetch failed with nothing cached to fall
/// back on, so the empty chat doesn't read as "no history."
class _HistoryErrorBar extends StatelessWidget {
  final VoidCallback onRetry;

  const _HistoryErrorBar({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: 8,
      ),
      color: cs.errorContainer.withValues(alpha: 0.4),
      child: Row(
        children: [
          Icon(Icons.cloud_off_rounded, size: 16, color: cs.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Couldn't load your past chat.",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onErrorContainer,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ─── Suggested questions ─────────────────────────────────────────────────
// Subject-specific starters shown on the fresh chat screen. Subjects without
// their own list fall back to the mixed set (one per covered subject).

const Map<String, List<String>> _subjectSuggestions = {
  'maths': [
    'How do I find the area of a triangle?',
    'Explain fractions with a simple example',
    'What is the difference between LCM and HCF?',
  ],
  'science': [
    'Why does the moon change shape?',
    'How does the water cycle work?',
    'What is photosynthesis in simple words?',
  ],
  'english': [
    'What is the difference between a noun and a verb?',
    'Help me write a paragraph about my school',
    'When do I use "a", "an" and "the"?',
  ],
};

const List<String> _mixedSuggestions = [
  'How do I find the area of a triangle?',
  'Why does the moon change shape?',
  'Help me write a paragraph about my school',
];

List<String> _suggestionsFor(String? subject) {
  if (subject == null) return _mixedSuggestions;
  return _subjectSuggestions[subject.toLowerCase()] ?? _mixedSuggestions;
}

/// Fresh-start screen: a quiet heading, tappable starter questions, and (when
/// an older conversation is tucked away) a link to bring it back.
class _EmptyChat extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onSuggestionTap;
  final bool showLoadPrevious;
  final VoidCallback onLoadPrevious;

  const _EmptyChat({
    required this.suggestions,
    required this.onSuggestionTap,
    required this.showLoadPrevious,
    required this.onLoadPrevious,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (showLoadPrevious)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 12),
                      child: TextButton.icon(
                        onPressed: onLoadPrevious,
                        style: TextButton.styleFrom(
                          foregroundColor: isDark ? AppColors.ink2Dark : AppColors.ink2,
                          textStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        icon: const Icon(Icons.history_rounded, size: 16),
                        label: const Text('Load previous chat'),
                      ),
                    ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 26, color: cs.primary),
                      const SizedBox(height: 14),
                      Text(
                        'What would you like to learn?',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Type a question or snap a photo of one.',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 22),
                      for (final suggestion in suggestions) ...[
                        _SuggestionRow(
                          text: suggestion,
                          onTap: () => onSuggestionTap(suggestion),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SuggestionRow({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        side: BorderSide(color: cs.outline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.3),
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.north_east_rounded,
                size: 14,
                color: isDark ? AppColors.ink3Dark : AppColors.ink3,
              ),
            ],
          ),
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(
              16,
            ).copyWith(bottomRight: const Radius.circular(5)),
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
          // Quiet marker so answers read as distinct blocks between user bubbles.
          Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 14,
              color: cs.primary.withValues(alpha: 0.75),
            ),
          ),
          if (isError)
            Text(
              message.text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: cs.error, height: 1.45),
            )
          else
            MarkdownBody(
              data: message.isStreaming ? '${message.text} ▌' : message.text,
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          cs.primary.withValues(alpha: 0.07),
          cs.surface,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.primary.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.menu_book_rounded,
            size: 11,
            color: cs.primary.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 5),
          Text(
            page.isEmpty
                ? '${citation.label} $book'
                : '${citation.label} $book · $page',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// Three softly pulsing dots while the answer is being prepared.
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 5),
                Opacity(
                  // Stagger each dot a third of a cycle apart.
                  opacity:
                      0.25 +
                      0.75 *
                          (0.5 -
                              0.5 *
                                  math.cos(
                                    (_controller.value - i / 3) * 2 * math.pi,
                                  )),
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
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
          // One rounded surface: attach + field + send, like a modern chat bar.
          Container(
            padding: const EdgeInsets.fromLTRB(4, 4, 5, 4),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: cs.outline),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: isSending ? null : onAttach,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  iconSize: 21,
                  visualDensity: VisualDensity.compact,
                  color: cs.onSurface.withValues(alpha: 0.55),
                  tooltip: 'Attach image',
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    enabled: !isSending,
                    onSubmitted: (_) => onSubmitted(),
                    style: Theme.of(context).textTheme.bodyLarge,
                    decoration: const InputDecoration(
                      hintText: 'Ask a question…',
                      filled: false,
                      isDense: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 11,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 38,
                  height: 38,
                  child: IconButton.filled(
                    onPressed: isSending ? null : onSubmitted,
                    icon: const Icon(Icons.arrow_upward_rounded),
                    iconSize: 19,
                    padding: EdgeInsets.zero,
                    tooltip: 'Send',
                  ),
                ),
              ],
            ),
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

  /// True while this assistant message is still receiving SSE token frames —
  /// shows a trailing cursor so the student can see it's still generating.
  final bool isStreaming;

  const _ChatMessage({
    required this.role,
    required this.text,
    this.citations = const [],
    this.usage,
    this.imageBytes,
    this.fromHistory = false,
    this.isStreaming = false,
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
    bool isStreaming = false,
  }) {
    return _ChatMessage(
      role: _MessageRole.assistant,
      text: text,
      citations: citations,
      usage: usage,
      isStreaming: isStreaming,
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
