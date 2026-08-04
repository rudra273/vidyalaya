import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../data/math/math_generators.dart';
import '../../../data/math/math_models.dart';
import '../../../providers/math_progress_provider.dart';
import '../../../utils/haptics.dart';
import 'math_home_screen.dart';
import 'widgets/math_option_tile.dart';

// ─── Fractions Lab ────────────────────────────────────────────────────────────
//
// Compare, simplify and add fractions — each question paired with a bar diagram
// so the arithmetic is grounded in something the student can see.

const _taskCount = 9;

class MathFractionsScreen extends ConsumerStatefulWidget {
  const MathFractionsScreen({super.key});

  @override
  ConsumerState<MathFractionsScreen> createState() =>
      _MathFractionsScreenState();
}

class _MathFractionsScreenState extends ConsumerState<MathFractionsScreen> {
  static const _toolId = 'math-fractions';

  late List<FractionTask> _tasks;
  int _index = 0;
  int? _selected;
  bool _answered = false;
  int _correct = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _tasks = buildFractionTasks(count: _taskCount);
  }

  void _generate() {
    setState(() {
      _tasks = buildFractionTasks(count: _taskCount);
      _index = 0;
      _selected = null;
      _answered = false;
      _correct = 0;
      _finished = false;
    });
  }

  void _answer(FractionTask t, int i) {
    final right = i == t.correctIndex;
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

  String _promptFor(FractionTask t) => switch (t.kind) {
        FractionTaskKind.compare => 'Which fraction is larger?',
        FractionTaskKind.simplify =>
          'Write ${t.left.numerator}/${t.left.denominator} in its simplest form.',
        FractionTaskKind.add =>
          'What is ${t.left.display} + ${t.right!.display}?',
      };

  @override
  Widget build(BuildContext context) {
    final accent = MathHomeScreen.accentOf(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Fractions Lab')),
      body: _finished
          ? MathScorePage(
              correct: _correct,
              total: _tasks.length,
              accent: accent,
              best: ref.watch(mathProgressProvider).bestFor(_toolId),
              onRetry: _generate,
              onExit: () => context.pop(),
            )
          : _taskView(accent),
    );
  }

  Widget _taskView(Color accent) {
    final t = _tasks[_index];
    final isLast = _index == _tasks.length - 1;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_index + 1} of ${_tasks.length}',
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
        const SizedBox(height: 12),
        Text(
          _promptFor(t),
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w700, height: 1.35),
        ),
        const SizedBox(height: 20),

        // Visual bars
        _FractionBar(
          fraction: t.left,
          accent: accent,
          label: t.left.display,
        ),
        if (t.right != null) ...[
          const SizedBox(height: 12),
          _FractionBar(
            fraction: t.right!,
            accent: accent,
            label: t.right!.display,
          ),
        ],

        const SizedBox(height: 24),
        ...List.generate(t.options.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MathOptionTile(
              label: t.options[i],
              state: mathOptionState(
                answered: _answered,
                index: i,
                correctIndex: t.correctIndex,
                selected: _selected,
              ),
              onTap: _answered ? null : () => _answer(t, i),
            ),
          );
        }),
        if (_answered) ...[
          const SizedBox(height: 4),
          MathExplanation(
            correct: _selected == t.correctIndex,
            text: t.explanation,
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

/// A horizontal bar split into [Fraction.denominator] parts with the first
/// [Fraction.numerator] filled — the classic fraction-strip picture.
class _FractionBar extends StatelessWidget {
  final Fraction fraction;
  final Color accent;
  final String label;

  const _FractionBar({
    required this.fraction,
    required this.accent,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        SizedBox(
          width: 46,
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
          ),
        ),
        Expanded(
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: isDark ? cs.surface : Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(AppSpacing.tileRadius - 1),
              child: CustomPaint(
                painter: _BarPainter(
                  numerator: fraction.numerator,
                  denominator: fraction.denominator,
                  fill: accent,
                  divider: cs.outlineVariant,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BarPainter extends CustomPainter {
  final int numerator;
  final int denominator;
  final Color fill;
  final Color divider;

  _BarPainter({
    required this.numerator,
    required this.denominator,
    required this.fill,
    required this.divider,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (denominator <= 0) return;
    final segW = size.width / denominator;

    final fillPaint = Paint()..color = fill.withValues(alpha: 0.55);
    // An improper fraction can't overflow the bar, so cap the shaded count.
    final shaded = numerator.clamp(0, denominator);
    if (shaded > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, segW * shaded, size.height),
        fillPaint,
      );
    }

    final linePaint = Paint()
      ..color = divider
      ..strokeWidth = 1;
    for (var i = 1; i < denominator; i++) {
      final x = segW * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.numerator != numerator ||
      old.denominator != denominator ||
      old.fill != fill;
}
