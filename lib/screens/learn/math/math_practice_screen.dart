import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../data/math/math_practice.dart';
import '../../../providers/math_progress_provider.dart';
import '../../../providers/regional_language_provider.dart';
import '../../../providers/user_selection_provider.dart';
import '../../../utils/haptics.dart';
import '../../../widgets/regional_language_switch.dart';
import 'math_home_screen.dart';
import 'widgets/math_option_tile.dart';

// ─── Practice rounds ──────────────────────────────────────────────────────────
//
// One-question-per-page rounds for Clock & Money and Word Problems. Same flow
// as Number Sense; the only extra is an analog clock above the prompt when the
// question carries one.

const _roundLength = 10;

typedef PracticeBuilder =
    List<MathPracticeQuestion> Function(int count, int classLevel);

class MathPracticeScreen extends ConsumerStatefulWidget {
  final String toolId;
  final String title;
  final PracticeBuilder builder;

  const MathPracticeScreen({
    super.key,
    required this.toolId,
    required this.title,
    required this.builder,
  });

  /// Clock & Money.
  factory MathPracticeScreen.clockMoney() => MathPracticeScreen(
    toolId: 'math-clock-money',
    title: 'Clock & Money',
    builder: (count, level) =>
        buildClockMoneyRound(count: count, classLevel: level),
  );

  /// Word Problems.
  factory MathPracticeScreen.wordProblems() => MathPracticeScreen(
    toolId: 'math-word-problems',
    title: 'Word Problems',
    builder: (count, level) =>
        buildWordProblemRound(count: count, classLevel: level),
  );

  @override
  ConsumerState<MathPracticeScreen> createState() => _MathPracticeScreenState();
}

class _MathPracticeScreenState extends ConsumerState<MathPracticeScreen> {
  late List<MathPracticeQuestion> _questions;
  int _index = 0;
  int? _selected;
  bool _answered = false;
  int _correct = 0;
  bool _finished = false;

  int get _classLevel {
    final selected = ref.read(exploreClassSelectionProvider);
    if (selected.isEmpty) return 3;
    return selected.reduce(max);
  }

  @override
  void initState() {
    super.initState();
    _questions = widget.builder(_roundLength, _classLevel);
  }

  void _generate() {
    setState(() {
      _questions = widget.builder(_roundLength, _classLevel);
      _index = 0;
      _selected = null;
      _answered = false;
      _correct = 0;
      _finished = false;
    });
  }

  void _answer(MathPracticeQuestion q, int i) {
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
      ref
          .read(mathProgressProvider.notifier)
          .recordScore(widget.toolId, _correct);
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
      appBar: AppBar(
        title: Text(widget.title),
        actions: const [RegionalLanguageSwitch()],
      ),
      body: _finished
          ? MathScorePage(
              correct: _correct,
              total: _questions.length,
              accent: accent,
              best: ref.watch(mathProgressProvider).bestFor(widget.toolId),
              onRetry: _generate,
              onExit: () => context.pop(),
            )
          : _questionView(accent),
    );
  }

  Widget _questionView(Color accent) {
    final lang = ref.watch(regionalLanguageProvider);
    final q = _questions[_index];
    final isLast = _index == _questions.length - 1;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '${_index + 1} of ${_questions.length}  ·  ${q.label}',
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Score $_correct',
              style: textTheme.labelMedium?.copyWith(
                color: accent,
                fontWeight: AppFontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (q.clock != null) ...[
          Center(
            child: SizedBox(
              width: 190,
              height: 190,
              child: CustomPaint(
                painter: ClockFacePainter(
                  hour: q.clock!.hour,
                  minute: q.clock!.minute,
                  accent: accent,
                  ink: Theme.of(context).colorScheme.onSurface,
                  face: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text(
          q.prompt.of(lang),
          style: textTheme.titleLarge?.copyWith(
            fontWeight: AppFontWeight.bold,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, c) {
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
          },
        ),
        if (_answered) ...[
          const SizedBox(height: 18),
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
            label: Text(isLast ? 'See results' : 'Next'),
          ),
        ],
      ],
    );
  }
}

// ─── Analog clock ─────────────────────────────────────────────────────────────

class ClockFacePainter extends CustomPainter {
  final int hour;
  final int minute;
  final Color accent;
  final Color ink;
  final Color face;

  const ClockFacePainter({
    required this.hour,
    required this.minute,
    required this.accent,
    required this.ink,
    required this.face,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 4;

    canvas.drawCircle(center, radius, Paint()..color = face);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = ink.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // 60 ticks, longer at the hours; numbers 1–12 inside.
    for (var i = 0; i < 60; i++) {
      final a = i * pi / 30;
      final long = i % 5 == 0;
      final r1 = radius - (long ? 12 : 6);
      canvas.drawLine(
        center + Offset(sin(a), -cos(a)) * r1,
        center + Offset(sin(a), -cos(a)) * (radius - 2),
        Paint()
          ..color = ink.withValues(alpha: long ? 0.8 : 0.35)
          ..strokeWidth = long ? 2 : 1,
      );
    }
    for (var n = 1; n <= 12; n++) {
      final a = n * pi / 6;
      final tp = TextPainter(
        text: TextSpan(
          text: '$n',
          style: TextStyle(
            color: ink,
            fontSize: radius * 0.17,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final p = center + Offset(sin(a), -cos(a)) * (radius * 0.72);
      tp.paint(canvas, p - Offset(tp.width / 2, tp.height / 2));
    }

    // The hour hand drifts with the minutes, as on a real clock.
    final hourAngle = ((hour % 12) + minute / 60) * pi / 6;
    final minuteAngle = minute * pi / 30;
    void hand(double angle, double length, double width, Color color) {
      canvas.drawLine(
        center,
        center + Offset(sin(angle), -cos(angle)) * length,
        Paint()
          ..color = color
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round,
      );
    }

    hand(hourAngle, radius * 0.45, 6, ink);
    hand(minuteAngle, radius * 0.68, 4, accent);
    canvas.drawCircle(center, 5, Paint()..color = ink);
  }

  @override
  bool shouldRepaint(ClockFacePainter old) =>
      old.hour != hour ||
      old.minute != minute ||
      old.accent != accent ||
      old.ink != ink ||
      old.face != face;
}
