import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../data/math/math_generators.dart';
import '../../../data/math/math_models.dart';
import '../../../providers/math_progress_provider.dart';
import '../../../providers/user_selection_provider.dart';
import '../../../utils/haptics.dart';
import 'math_home_screen.dart';
import 'widgets/math_option_tile.dart';

// ─── Math Quiz ────────────────────────────────────────────────────────────────
//
// Ten generated multiple-choice questions, scaled to the student's class. One
// question per page: tapping an option locks it in and shows the explanation.
// Mirrors PythonQuizScreen's flow.

const _questionCount = 10;

class MathQuizScreen extends ConsumerStatefulWidget {
  const MathQuizScreen({super.key});

  @override
  ConsumerState<MathQuizScreen> createState() => _MathQuizScreenState();
}

class _MathQuizScreenState extends ConsumerState<MathQuizScreen> {
  static const _toolId = 'math-quiz';

  late List<MathQuizQuestion> _questions;
  int _index = 0;
  int? _selected;
  bool _answered = false;
  int _correct = 0;
  bool _finished = false;

  /// The class used to scale difficulty — highest selected class, defaulting to
  /// 4 when the student hasn't picked any.
  int get _classLevel {
    final selected = ref.read(userSelectionProvider);
    if (selected.isEmpty) return 4;
    return selected.reduce((a, b) => a > b ? a : b);
  }

  @override
  void initState() {
    super.initState();
    _questions = buildQuizQuestions(
      classLevel: _classLevel,
      count: _questionCount,
    );
  }

  void _generate() {
    setState(() {
      _questions = buildQuizQuestions(
        classLevel: _classLevel,
        count: _questionCount,
      );
      _index = 0;
      _selected = null;
      _answered = false;
      _correct = 0;
      _finished = false;
    });
  }

  void _answer(MathQuizQuestion q, int i) {
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
    final accent = MathHomeScreen.accentOf(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Math Quiz')),
      body: _finished
          ? MathScorePage(
              correct: _correct,
              total: _questions.length,
              accent: accent,
              best: ref.watch(mathProgressProvider).bestFor(_toolId),
              onRetry: _generate,
              onExit: () => context.pop(),
            )
          : _questionView(_questions, accent),
    );
  }

  Widget _questionView(List<MathQuizQuestion> questions, Color accent) {
    final q = questions[_index];
    final isLast = _index == questions.length - 1;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question ${_index + 1} of ${questions.length}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textMuted,
                    letterSpacing: 0.5,
                  ),
            ),
            Text(
              'Score $_correct',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          q.prompt,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w700, height: 1.35),
        ),
        const SizedBox(height: 20),
        ...List.generate(q.options.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MathOptionTile(
              label: q.options[i],
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
            text: q.explanation,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: accent),
            onPressed: () => _next(isLast),
            icon: Icon(isLast
                ? Icons.emoji_events_rounded
                : Icons.arrow_forward_rounded),
            label: Text(isLast ? 'See results' : 'Next question'),
          ),
        ],
      ],
    );
  }
}
