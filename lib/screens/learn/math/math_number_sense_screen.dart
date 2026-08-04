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

// ─── Number Sense ─────────────────────────────────────────────────────────────
//
// Quick-fire judgement rounds — larger/smaller, odd/even, place value, rounding,
// primes. Same one-question-per-page flow as the quiz, but the options are short
// so they sit in a 2-column grid.

const _roundLength = 10;

class MathNumberSenseScreen extends ConsumerStatefulWidget {
  const MathNumberSenseScreen({super.key});

  @override
  ConsumerState<MathNumberSenseScreen> createState() =>
      _MathNumberSenseScreenState();
}

class _MathNumberSenseScreenState
    extends ConsumerState<MathNumberSenseScreen> {
  static const _toolId = 'math-number-sense';

  late List<NumberSenseQuestion> _questions;
  int _index = 0;
  int? _selected;
  bool _answered = false;
  int _correct = 0;
  bool _finished = false;

  int get _classLevel {
    final selected = ref.read(userSelectionProvider);
    if (selected.isEmpty) return 4;
    return selected.reduce((a, b) => a > b ? a : b);
  }

  @override
  void initState() {
    super.initState();
    _questions = buildNumberSenseRound(
      count: _roundLength,
      classLevel: _classLevel,
    );
  }

  void _generate() {
    setState(() {
      _questions = buildNumberSenseRound(
        count: _roundLength,
        classLevel: _classLevel,
      );
      _index = 0;
      _selected = null;
      _answered = false;
      _correct = 0;
      _finished = false;
    });
  }

  void _answer(NumberSenseQuestion q, int i) {
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
      appBar: AppBar(title: const Text('Number Sense')),
      body: _finished
          ? MathScorePage(
              correct: _correct,
              total: _questions.length,
              accent: accent,
              best: ref.watch(mathProgressProvider).bestFor(_toolId),
              onRetry: _generate,
              onExit: () => context.pop(),
            )
          : _questionView(accent),
    );
  }

  Widget _questionView(Color accent) {
    final q = _questions[_index];
    final isLast = _index == _questions.length - 1;
    // Two-per-row for short numeric options; full width for word answers.
    final useGrid = q.options.length == 4 &&
        q.options.every((o) => o.length <= 5);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_index + 1} of ${_questions.length}  ·  ${q.kind.label}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textMuted,
                    letterSpacing: 0.3,
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
        const SizedBox(height: 12),
        Text(
          q.prompt,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w700, height: 1.35),
        ),
        const SizedBox(height: 22),
        if (useGrid)
          LayoutBuilder(builder: (context, c) {
            const gap = 12.0;
            final cellW = (c.maxWidth - gap) / 2;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: List.generate(q.options.length, (i) {
                return SizedBox(
                  width: cellW,
                  child: MathOptionTile(
                    label: q.options[i],
                    centered: true,
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
            );
          })
        else
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
          const SizedBox(height: 18),
          MathExplanation(
            correct: _selected == q.correctIndex,
            text: 'The answer is ${q.options[q.correctIndex]}.',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: accent),
            onPressed: () => _next(isLast),
            icon: Icon(isLast
                ? Icons.emoji_events_rounded
                : Icons.arrow_forward_rounded),
            label: Text(isLast ? 'See results' : 'Next'),
          ),
        ],
      ],
    );
  }
}
