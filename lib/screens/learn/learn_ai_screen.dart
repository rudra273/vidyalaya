import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../data/models/learn_assist.dart';
import '../../data/services/backend_auth_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/learn_assist_provider.dart';
import '../../providers/user_selection_provider.dart';

class LearnAiScreen extends ConsumerStatefulWidget {
  const LearnAiScreen({super.key});

  @override
  ConsumerState<LearnAiScreen> createState() => _LearnAiScreenState();
}

class _LearnAiScreenState extends ConsumerState<LearnAiScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];

  late int _selectedClass;
  String? _selectedSubject;
  String _languageMode = 'auto';
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _selectedClass = resolveLearnAssistClass(ref.read(userSelectionProvider));
    _ensureAccountSummary();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final query = _messageController.text.trim();
    if (query.isEmpty || _isSending) return;

    final language = _languageMode == 'auto'
        ? detectLearnAssistLanguage(query)
        : _languageMode;
    final service = ref.read(learnAssistServiceProvider);

    setState(() {
      _messages.add(_ChatMessage.user(query));
      _isSending = true;
      _messageController.clear();
    });
    _scrollToBottom();

    try {
      final response = await service.chat(
        LearnAssistRequest(
          message: query,
          board: 'scert_odisha',
          classNo: _selectedClass,
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
      ref.read(backendAccountCacheProvider.notifier).markHistoryStale();
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
    if (isSignedIn && (!accountState.userLoaded || !accountState.usageLoaded)) {
      _ensureAccountSummary();
    }
    final classOptions = learnAssistClassOptions(selectedClasses);
    final subjectOptions = learnAssistSubjectsForClass(_selectedClass);
    if (!classOptions.contains(_selectedClass)) {
      _selectedClass = classOptions.first;
    }
    if (_selectedSubject != null &&
        !subjectOptions.contains(_selectedSubject)) {
      _selectedSubject = null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Learn with AI',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          IconButton(
            tooltip: 'Chat history',
            onPressed: isSignedIn ? _showHistory : null,
            icon: const Icon(Icons.history_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _PlanUsageBar(
              isSignedIn: isSignedIn,
              user: accountState.user,
              usage: accountState.usage,
            ),
            _ContextControls(
              classOptions: classOptions,
              selectedClass: _selectedClass,
              onClassChanged: (value) {
                setState(() {
                  _selectedClass = value;
                  _selectedSubject = null;
                });
              },
              subjectOptions: subjectOptions,
              selectedSubject: _selectedSubject,
              onSubjectChanged: (value) {
                setState(() => _selectedSubject = value);
              },
              languageMode: _languageMode,
              onLanguageChanged: (value) {
                setState(() => _languageMode = value);
              },
            ),
            Expanded(
              child: _messages.isEmpty
                  ? const _EmptyChat()
                  : ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenPadding,
                        12,
                        AppSpacing.screenPadding,
                        16,
                      ),
                      itemCount: _messages.length + (_isSending ? 1 : 0),
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (_isSending && index == _messages.length) {
                          return const _TypingBubble();
                        }
                        return _MessageBubble(message: _messages[index]);
                      },
                    ),
            ),
            _Composer(
              controller: _messageController,
              isSending: _isSending,
              onSubmitted: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showHistory() async {
    ref.read(backendAccountCacheProvider.notifier).ensureHistory();
    final selectedMessages = await showModalBottomSheet<List<_ChatMessage>>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => const _HistorySheet(),
    );

    if (!mounted || selectedMessages == null || selectedMessages.isEmpty) {
      return;
    }

    setState(() {
      _messages
        ..clear()
        ..addAll(selectedMessages);
    });
    _scrollToBottom();
  }
}

class _HistorySheet extends ConsumerWidget {
  const _HistorySheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountState = ref.watch(backendAccountCacheProvider);
    final history = accountState.history.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    final isLoading = accountState.history is AsyncLoading;
    final error = accountState.history.maybeWhen(
      error: (error, _) => error,
      orElse: () => null,
    );
    final messages =
        history == null ? const <ChatHistoryMessage>[] : [...history.messages]
          ..sort((a, b) => a.id.compareTo(b.id));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.78,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                12,
                AppSpacing.screenPadding,
                8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Chat History',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: isLoading
                        ? null
                        : () => ref
                              .read(backendAccountCacheProvider.notifier)
                              .ensureHistory(forceRefresh: true),
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            if (isLoading) const LinearProgressIndicator(minHeight: 2),
            if (error != null)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Text(
                  error.toString(),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            Expanded(
              child: messages.isEmpty && !isLoading
                  ? const Center(child: Text('No saved chats yet.'))
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenPadding,
                        8,
                        AppSpacing.screenPadding,
                        16,
                      ),
                      itemCount: messages.length + 1,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        if (index == messages.length) {
                          return _HistoryActions(
                            canLoadOlder: history?.nextBefore != null,
                            canUseHistory: messages.isNotEmpty,
                            isLoading: isLoading,
                            onLoadOlder: () => ref
                                .read(backendAccountCacheProvider.notifier)
                                .loadOlderHistory(),
                            onUseHistory: () {
                              final chatMessages = messages
                                  .map(_ChatMessage.fromHistory)
                                  .where(
                                    (message) => message.text.trim().isNotEmpty,
                                  )
                                  .toList();
                              Navigator.of(context).pop(chatMessages);
                            },
                          );
                        }

                        return _HistoryMessageTile(message: messages[index]);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _HistoryMessageTile extends StatelessWidget {
  final ChatHistoryMessage message;

  const _HistoryMessageTile({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isHuman = message.role == 'human';

    return Align(
      alignment: isHuman ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isHuman ? cs.primaryContainer : cs.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.content,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (message.citations.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final citation in message.citations)
                      _CitationChip(citation: citation),
                  ],
                ),
              ],
              if (message.createdAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  _formatHistoryTime(message.createdAt!),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryActions extends StatelessWidget {
  final bool canLoadOlder;
  final bool canUseHistory;
  final bool isLoading;
  final VoidCallback onLoadOlder;
  final VoidCallback onUseHistory;

  const _HistoryActions({
    required this.canLoadOlder,
    required this.canUseHistory,
    required this.isLoading,
    required this.onLoadOlder,
    required this.onUseHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (canLoadOlder)
          OutlinedButton.icon(
            onPressed: isLoading ? null : onLoadOlder,
            icon: const Icon(Icons.expand_more_rounded),
            label: const Text('Load Older'),
          ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: canUseHistory ? onUseHistory : null,
            icon: const Icon(Icons.restore_rounded),
            label: const Text('Show In Chat'),
          ),
        ),
      ],
    );
  }
}

class _PlanUsageBar extends StatelessWidget {
  final bool isSignedIn;
  final AsyncValue<BackendUser?> user;
  final AsyncValue<LearnAssistUsage?> usage;

  const _PlanUsageBar({
    required this.isSignedIn,
    required this.user,
    required this.usage,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (!isSignedIn) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          8,
          AppSpacing.screenPadding,
          8,
        ),
        color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
        child: Row(
          children: [
            Icon(Icons.lock_outline_rounded, size: 18, color: cs.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Sign in to use Learn AI',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    }

    final backendUser = user.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    final currentUsage = usage.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    final isLoading = user is AsyncLoading || usage is AsyncLoading;
    final planKey = backendUser?.planKey ?? 'free';
    final planLabel = _planLabel(planKey);
    final limit = currentUsage?.limit ?? backendUser?.planDailyLimit;
    final usageLabel = currentUsage == null
        ? limit == null
              ? 'Usage loading'
              : '$limit/day'
        : currentUsage.unlimited
        ? 'Unlimited'
        : '${currentUsage.remaining} left today';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        8,
        AppSpacing.screenPadding,
        8,
      ),
      color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
      child: Row(
        children: [
          Icon(Icons.workspace_premium_rounded, size: 18, color: cs.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$planLabel plan',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          if (isLoading)
            const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Text(
              usageLabel,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
        ],
      ),
    );
  }
}

class _ContextControls extends StatelessWidget {
  final List<int> classOptions;
  final int selectedClass;
  final ValueChanged<int> onClassChanged;
  final List<String> subjectOptions;
  final String? selectedSubject;
  final ValueChanged<String?> onSubjectChanged;
  final String languageMode;
  final ValueChanged<String> onLanguageChanged;

  const _ContextControls({
    required this.classOptions,
    required this.selectedClass,
    required this.onClassChanged,
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
        12,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: cs.outlineVariant)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (classOptions.length > 1)
            _DropdownPill<int>(
              value: selectedClass,
              items: [
                for (final classNo in classOptions)
                  DropdownMenuItem(
                    value: classNo,
                    child: Text('Class $classNo'),
                  ),
              ],
              onChanged: (value) {
                if (value != null) onClassChanged(value);
              },
            )
          else
            _StaticPill(label: 'Class $selectedClass'),
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
              DropdownMenuItem(value: 'auto', child: Text('Auto language')),
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

class _StaticPill extends StatelessWidget {
  final String label;

  const _StaticPill({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
        border: Border.all(color: cs.outline),
      ),
      alignment: Alignment.center,
      child: Text(label, style: Theme.of(context).textTheme.labelLarge),
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
              'Answers can include textbook citations when the AI finds matching pages.',
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

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isUser = message.role == _MessageRole.user;
    final isError = message.role == _MessageRole.error;
    final bubbleColor = isUser
        ? cs.primary
        : isError
        ? cs.errorContainer
        : cs.surface;
    final textColor = isUser
        ? cs.onPrimary
        : isError
        ? cs.onErrorContainer
        : cs.onSurface;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(16).copyWith(
              bottomRight: isUser ? const Radius.circular(4) : null,
              bottomLeft: !isUser ? const Radius.circular(4) : null,
            ),
            border: isUser ? null : Border.all(color: cs.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  height: 1.35,
                ),
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
              if (message.usage != null) ...[
                const SizedBox(height: 10),
                Text(
                  _formatUsage(message.usage!),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: textColor.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ],
          ),
        ),
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

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(
            16,
          ).copyWith(bottomLeft: const Radius.circular(4)),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Text(
          'Thinking...',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSubmitted;

  const _Composer({
    required this.controller,
    required this.isSending,
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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
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
    );
  }
}

class _ChatMessage {
  final _MessageRole role;
  final String text;
  final List<LearnAssistCitation> citations;
  final LearnAssistUsage? usage;

  const _ChatMessage({
    required this.role,
    required this.text,
    this.citations = const [],
    this.usage,
  });

  factory _ChatMessage.user(String text) {
    return _ChatMessage(role: _MessageRole.user, text: text);
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
    );
  }
}

enum _MessageRole { user, assistant, error }

String _formatUsage(LearnAssistUsage usage) {
  if (usage.unlimited) return 'Unlimited plan';
  return 'Daily usage: ${usage.used}/${usage.limit} used, ${usage.remaining} left';
}

String _formatHistoryTime(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.day}/${local.month}/${local.year} $hour:$minute';
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
