import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../data/quiz/quiz_bank.dart';
import '../../../data/quiz/quiz_models.dart';
import '../../../providers/math_progress_provider.dart';
import '../../../providers/regional_language_provider.dart';
import '../../../utils/haptics.dart';
import '../../../widgets/regional_language_switch.dart';
import '../math/widgets/math_option_tile.dart';
import 'subject_quiz_home_screen.dart';

// ─── Subject quiz round ───────────────────────────────────────────────────────
//
// Ten questions drawn at random from one subject + band bank. Same flow as
// Math Quiz: tapping an option locks it in and reveals the explanation. Best
// scores share the math progress store, keyed by [quizToolId].

class SubjectQuizScreen extends ConsumerStatefulWidget {
  final QuizSubject subject;
  final QuizBand band;

  const SubjectQuizScreen({
    super.key,
    required this.subject,
    required this.band,
  });

  @override
  ConsumerState<SubjectQuizScreen> createState() => _SubjectQuizScreenState();
}

class _SubjectQuizScreenState extends ConsumerState<SubjectQuizScreen> {
  late List<QuizQuestion> _questions;
  int _index = 0;
  int? _selected;
  bool _answered = false;
  int _correct = 0;
  bool _finished = false;

  String get _toolId => quizToolId(widget.subject, widget.band);

  @override
  void initState() {
    super.initState();
    _questions = buildQuizRound(widget.subject, widget.band);
  }

  void _restart() {
    setState(() {
      _questions = buildQuizRound(widget.subject, widget.band);
      _index = 0;
      _selected = null;
      _answered = false;
      _correct = 0;
      _finished = false;
    });
  }

  void _answer(QuizQuestion q, int i) {
    final right = i == q.correctIndex;
    right ? Haptics.medium(ref) : Haptics.error(ref);
    setState(() {
      _selected = i;
      _answered = true;
      if (right) _correct++;
    });
  }

  void _next(bool isLast) {
    if (isLast) {
      ref.read(mathProgressProvider.notifier).recordScore(_toolId, _correct);
      setState(() => _finished = true);
    } else {
      setState(() {
        _index++;
        _selected = null;
        _answered = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = quizSubjectAccent(context, widget.subject);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.subject.label),
        actions: const [RegionalLanguageSwitch()],
      ),
      body: _questions.isEmpty
          ? const Center(child: Text('No questions yet.'))
          : _finished
          ? MathScorePage(
              correct: _correct,
              total: _questions.length,
              accent: accent,
              best: ref.watch(mathProgressProvider).bestFor(_toolId),
              onRetry: _restart,
              onExit: () => context.pop(),
            )
          : _questionView(accent),
    );
  }

  Widget _questionView(Color accent) {
    final lang = ref.watch(regionalLanguageProvider);
    final q = _questions[_index];
    final isLast = _index == _questions.length - 1;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question ${_index + 1} of ${_questions.length}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'Score $_correct',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: accent,
                fontWeight: AppFontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          q.prompt.of(lang),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: AppFontWeight.bold,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 20),
        ...List.generate(q.options.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MathOptionTile(
              label: q.options[i].of(lang),
              state: mathOptionState(
                answered: _answered,
                index: i,
                correctIndex: q.correctIndex,
                selected: _selected,
              ),
              onTap: _answered ? null : () => _answer(q, i),
            ),
          );
        }),
        if (_answered) ...[
          const SizedBox(height: 4),
          MathExplanation(
            correct: _selected == q.correctIndex,
            text: q.explanation.of(lang),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: accent),
            onPressed: () => _next(isLast),
            icon: Icon(
              isLast ? Icons.emoji_events_rounded : Icons.arrow_forward_rounded,
            ),
            label: Text(isLast ? 'See results' : 'Next question'),
          ),
        ],
      ],
    );
  }
}
