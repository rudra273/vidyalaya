import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'widgets/chat_bubble.dart';

/// A **preview** of the upcoming AI Tutor agent. This screen is intentionally a
/// mock: it shows a scripted, step-by-step lesson so the intended experience is
/// clear, but it makes **no network calls** and the composer only returns a
/// canned "coming soon" reply. The real agent will reuse this same chat shell.
class TutorMockScreen extends StatefulWidget {
  const TutorMockScreen({super.key});

  @override
  State<TutorMockScreen> createState() => _TutorMockScreenState();
}

class _TutorMockScreenState extends State<TutorMockScreen> {
  static const _subjects = ['Mathematics', 'Science', 'English', 'History'];

  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_MockTurn> _turns = List.of(_scriptedLesson);

  String _selectedSubject = 'Mathematics';

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSend() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _turns.add(_MockTurn.user(text));
      _turns.add(
        _MockTurn.assistant(
          "I'd love to teach you that! Full AI tutoring is coming soon — "
          'for now this is just a preview. 🌱',
        ),
      );
      _messageController.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AI Tutor',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const _PreviewBanner(),
            _SubjectChips(
              subjects: _subjects,
              selected: _selectedSubject,
              onSelected: (s) => setState(() => _selectedSubject = s),
            ),
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  12,
                  AppSpacing.screenPadding,
                  16,
                ),
                itemCount: _turns.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final turn = _turns[index];
                  return turn.isUser
                      ? UserChatBubble(text: turn.text)
                      : AssistantChatBubble(text: turn.text);
                },
              ),
            ),
            _MockComposer(
              controller: _messageController,
              onSubmitted: _onSend,
            ),
          ],
        ),
      ),
    );
  }
}

/// Pinned banner making it unmistakable this is a non-functional preview.
class _PreviewBanner extends StatelessWidget {
  const _PreviewBanner();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: 10,
      ),
      color: cs.tertiary.withValues(alpha: 0.12),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: cs.tertiary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'AI Tutor preview — full step-by-step tutoring is coming soon.',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: cs.tertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectChips extends StatelessWidget {
  final List<String> subjects;
  final String selected;
  final ValueChanged<String> onSelected;

  const _SubjectChips({
    required this.subjects,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: 8,
        ),
        itemCount: subjects.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final subject = subjects[index];
          return ChoiceChip(
            label: Text(subject),
            selected: subject == selected,
            onSelected: (_) => onSelected(subject),
          );
        },
      ),
    );
  }
}

class _MockComposer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmitted;

  const _MockComposer({required this.controller, required this.onSubmitted});

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
              onSubmitted: (_) => onSubmitted(),
              decoration: InputDecoration(
                hintText: 'Try asking the tutor…',
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
            onPressed: onSubmitted,
            icon: const Icon(Icons.send_rounded),
            tooltip: 'Send',
          ),
        ],
      ),
    );
  }
}

class _MockTurn {
  final bool isUser;
  final String text;

  const _MockTurn._(this.isUser, this.text);

  factory _MockTurn.user(String text) => _MockTurn._(true, text);
  factory _MockTurn.assistant(String text) => _MockTurn._(false, text);
}

/// A short, pre-scripted lesson that demonstrates the intended step-by-step UX.
const _scriptedLesson = <_MockTurn>[
  _MockTurn._(
    false,
    "Hi! I'm your **AI Tutor**. Let's learn **fractions** together, one small "
    'step at a time. Ready? 😊',
  ),
  _MockTurn._(true, 'Yes!'),
  _MockTurn._(
    false,
    '**Step 1.** A fraction shows *part of a whole*.\n\n'
    'Imagine a pizza 🍕 cut into **4 equal slices**. If you eat **1 slice**, '
    'you ate **1 out of 4** — we write that as **1/4**.',
  ),
  _MockTurn._(true, 'What does the bottom number mean?'),
  _MockTurn._(
    false,
    'Great question! The **bottom number (denominator)** tells you how many '
    'equal parts the whole is split into. The **top number (numerator)** tells '
    'you how many parts you have.\n\nSo in **3/4**, the pizza has **4** slices '
    'and you have **3** of them.',
  ),
  _MockTurn._(
    false,
    "**Your turn.** If a chocolate bar has **5** equal pieces and you eat "
    '**2**, what fraction did you eat? Type your answer below 👇',
  ),
];
