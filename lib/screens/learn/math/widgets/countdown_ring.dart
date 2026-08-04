import 'dart:math' as math;

import 'package:flutter/material.dart';

// ─── Countdown ring ───────────────────────────────────────────────────────────
//
// A circle around the flashing number that empties as the step's time runs out,
// so a student can see how long is left without reading a clock.
//
// Driven by an implicit TweenAnimationBuilder rather than an AnimationController:
// the parent gives each step a fresh [ValueKey], which remounts this widget and
// restarts the sweep from full. That keeps the animation honest — it can't drift
// out of sync with the timer that actually advances the chain.

class CountdownRing extends StatelessWidget {
  /// How long this step is displayed. The ring empties over exactly this span.
  final Duration duration;
  final Color accent;
  final Color track;
  final double size;
  final double strokeWidth;
  final Widget child;

  const CountdownRing({
    super.key,
    required this.duration,
    required this.accent,
    required this.track,
    required this.child,
    this.size = 250,
    this.strokeWidth = 7,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1, end: 0),
        duration: duration,
        // Linear: a decelerating countdown would misrepresent the time left.
        curve: Curves.linear,
        builder: (context, remaining, _) {
          return CustomPaint(
            painter: _CountdownPainter(
              remaining: remaining,
              accent: accent,
              track: track,
              strokeWidth: strokeWidth,
            ),
            child: Center(child: child),
          );
        },
      ),
    );
  }
}

class _CountdownPainter extends CustomPainter {
  final double remaining;
  final Color accent;
  final Color track;
  final double strokeWidth;

  _CountdownPainter({
    required this.remaining,
    required this.accent,
    required this.track,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - strokeWidth / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = track
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    final fraction = remaining.clamp(0.0, 1.0);
    if (fraction <= 0) return;

    // Warm to red as time runs out — a peripheral cue that the step is about to
    // vanish.
    final color = fraction < 0.25
        ? Color.lerp(const Color(0xFFC0483C), accent, fraction / 0.25)!
        : accent;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * fraction,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_CountdownPainter old) =>
      old.remaining != remaining ||
      old.accent != accent ||
      old.track != track ||
      old.strokeWidth != strokeWidth;
}
