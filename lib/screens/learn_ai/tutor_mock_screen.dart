import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'widgets/chat_bubble.dart';

/// A **preview** of the upcoming AI Tutor agent. This screen is intentionally a
/// mock: it shows a scripted, step-by-step lesson so the intended experience is
/// clear, but it makes **no network calls** and the composer is disabled. The
/// real agent will reuse this same chat shell.
class TutorMockScreen extends StatefulWidget {
  const TutorMockScreen({super.key});

  @override
  State<TutorMockScreen> createState() => _TutorMockScreenState();
}

class _TutorMockScreenState extends State<TutorMockScreen> {
  static const _subjects = ['Mathematics', 'Science', 'English', 'History'];

  String _selectedSubject = 'Mathematics';

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
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  12,
                  AppSpacing.screenPadding,
                  16,
                ),
                itemCount: _scriptedLesson.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final turn = _scriptedLesson[index];
                  return turn.isUser
                      ? UserChatBubble(text: turn.text)
                      : AssistantChatBubble(text: turn.text);
                },
              ),
            ),
            const _DisabledComposer(),
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
              'Preview — guided lesson demo. Live tutoring isn\'t available yet.',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: cs.tertiary,
                fontWeight: AppFontWeight.semibold,
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

/// Greyed-out composer: shows where the student will type once the tutor is
/// live, without pretending to answer.
class _DisabledComposer extends StatelessWidget {
  const _DisabledComposer();

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
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              enabled: false,
              decoration: InputDecoration(
                hintText: 'Live tutoring is coming soon',
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
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: cs.outline),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton.filled(
            onPressed: null,
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
    '**2**, what fraction did you eat? 🤔\n\n'
    '_(In the full tutor you\'ll type your answer here and get step-by-step '
    'feedback.)_',
  ),
];
