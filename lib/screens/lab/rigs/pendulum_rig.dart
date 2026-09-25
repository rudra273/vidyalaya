import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../data/lab/lab_rules.dart';
import '../../../data/models/regional_language.dart';
import '../lab_kit.dart';

// ─── Pendulum: time the swings, see that only the length matters ─────────────

class PendulumRig extends LabRig {
  const PendulumRig();

  @override
  String get id => 'pendulum';

  @override
  IconData get icon => Icons.av_timer_rounded;

  /// Ten timed seconds, played at double speed.
  @override
  double get runSeconds => kPendulumWindowS / _speedUp;

  static const _speedUp = 2.0;
  static const _amplitude = 0.42;

  @override
  List<LabControl> get controls => [
    LabControl(
      key: 'length_cm',
      icon: Icons.straighten_rounded,
      caption: (v, _) => '$v cm',
      glyph: (canvas, size, v, p) {
        final top = size.height * 0.16;
        final len = size.height * 0.62 * (v as int) / 100;
        final pivot = Offset(size.width / 2, top);
        canvas.drawLine(
          Offset(size.width * 0.25, top),
          Offset(size.width * 0.75, top),
          strokePaint(p.amber, size.height * 0.06),
        );
        final bob = pivot + Offset(0, len + size.height * 0.04);
        canvas.drawLine(pivot, bob, strokePaint(p.ink2, 1.4));
        drawBall(canvas, bob, size.width * 0.1, p.violet);
      },
    ),
    LabControl(
      key: 'mass_g',
      icon: Icons.fitness_center_rounded,
      caption: (v, _) => '$v g',
      glyph: (canvas, size, v, p) => drawBall(
        canvas,
        size.center(Offset.zero),
        size.width * (v == 200 ? 0.27 : 0.15),
        v == 200 ? p.violet : p.sky,
      ),
    ),
  ];

  @override
  Map<String, Object> previewControls(int cycle) => {
    'length_cm': [50, 25, 100][cycle % 3],
    'mass_g': cycle.isEven ? 200 : 50,
  };

  /// Simulated seconds: double speed while timing, then real time.
  static double _simT(LabScene s, double runSeconds) {
    if (!s.ran) return 0;
    final r = s.runT;
    return r <= runSeconds ? r * _speedUp : kPendulumWindowS + (r - runSeconds);
  }

  @override
  void paint(Canvas canvas, Size size, LabScene s) {
    final p = s.p;
    final w = size.width;
    final h = size.height;
    final u = math.min(w, h) / 100;
    final pivot = Offset(w / 2, h * 0.13);
    final length = s.lerpControl('length_cm', 0.45);
    final stringPx = h * 0.66 * length / 100;
    final mass = s.lerpControl('mass_g', 0.3);
    final bobR = u * (5.5 + 4 * (mass - 50) / 150);
    final period = pendulumPeriod(s.c<int>('length_cm'));
    final simT = _simT(s, runSeconds);

    double angleAt(double time) => s.ran
        ? -_amplitude * math.cos(2 * math.pi * time / period)
        : -_amplitude;
    Offset bobAt(double a) =>
        pivot + Offset(math.sin(a), math.cos(a)) * (stringPx + bobR);

    // Floor + soft shadow.
    final floorY = h * 0.94;
    canvas.drawLine(
      Offset(w * 0.08, floorY),
      Offset(w * 0.92, floorY),
      strokePaint(p.hairline, u * 0.8),
    );

    // Stand.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(w * 0.2, pivot.dy - u * 4.5, w * 0.8, pivot.dy - u * 0.5),
        Radius.circular(u * 2),
      ),
      fillPaint(p.amber),
    );
    canvas.drawRect(
      Rect.fromLTRB(w * 0.2, pivot.dy - u * 0.5, w * 0.23, floorY),
      fillPaint(p.amber.withValues(alpha: 0.55)),
    );
    canvas.drawCircle(pivot, u * 1.6, fillPaint(p.ink2));

    // Swing range guide.
    final arcRect = Rect.fromCircle(center: pivot, radius: stringPx + bobR);
    final guide = strokePaint(p.violet.withValues(alpha: 0.25), u * 0.7);
    canvas.drawArc(
      arcRect,
      math.pi / 2 - _amplitude,
      _amplitude * 2,
      false,
      guide,
    );
    if (!s.ran) {
      drawBall(canvas, bobAt(_amplitude), bobR, p.ink3.withValues(alpha: 0.18));
    }

    // Motion trail.
    final bobColor = Color.lerp(p.sky, p.violet, (mass - 50) / 150)!;
    if (s.ran && s.runT > 0.05) {
      for (var k = 5; k >= 1; k--) {
        final ghost = bobAt(angleAt(simT - k * period * 0.035));
        canvas.drawCircle(
          ghost,
          bobR * (1 - k * 0.08),
          fillPaint(bobColor.withValues(alpha: 0.07 * (6 - k))),
        );
      }
    }

    final angle = angleAt(simT);
    final bob = bobAt(angle);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(bob.dx, floorY),
        width: bobR * 2.4,
        height: bobR * 0.5,
      ),
      fillPaint(p.ink.withValues(alpha: 0.08)),
    );
    canvas.drawLine(pivot, bob, strokePaint(p.ink2, u * 0.6));
    drawBall(canvas, bob, bobR, bobColor);
    if (!s.preview) {
      drawTag(
        canvas,
        '${s.c<int>('mass_g')} g',
        bob,
        Colors.white,
        size: bobR * 0.55,
      );
    }

    if (s.preview) return;

    // Swing counter.
    final timed = math.min(simT, kPendulumWindowS.toDouble());
    final swings = s.ran ? (timed / period).floor() : 0;
    final frac = s.ran ? (timed / period) % 1 : 1.0;
    final pop = swings > 0 && frac < 0.25 && timed < kPendulumWindowS
        ? 1 + 0.35 * (1 - frac / 0.25)
        : 1.0;
    final counter = Offset(w * 0.12, h * 0.3);
    canvas.drawCircle(
      counter,
      u * 9 * pop,
      fillPaint(p.violet.withValues(alpha: s.ran ? 1 : 0.18)),
    );
    drawTag(
      canvas,
      s.ran ? '$swings' : '?',
      counter,
      s.ran ? Colors.white : p.violet,
      size: u * 8 * pop,
    );
    drawTag(canvas, '↻', counter + Offset(0, u * 13), p.violet, size: u * 5);

    // Stopwatch.
    final watch = Offset(w * 0.88, h * 0.3);
    final r = u * 9;
    canvas.drawCircle(watch, r, fillPaint(p.surface));
    canvas.drawCircle(watch, r, strokePaint(p.ink2, u * 1.2));
    canvas.drawRect(
      Rect.fromCenter(
        center: watch - Offset(0, r + u * 1.5),
        width: u * 3,
        height: u * 2.4,
      ),
      fillPaint(p.ink2),
    );
    final progress = timed / kPendulumWindowS;
    canvas.drawArc(
      Rect.fromCircle(center: watch, radius: r * 0.78),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      strokePaint(p.green, r * 0.22),
    );
    final hand = -math.pi / 2 + 2 * math.pi * progress;
    canvas.drawLine(
      watch,
      watch + Offset(math.cos(hand), math.sin(hand)) * r * 0.7,
      strokePaint(p.ink, u * 0.9),
    );
    canvas.drawCircle(watch, u * 1.1, fillPaint(p.ink));
    drawTag(
      canvas,
      '${timed.toStringAsFixed(1)} s',
      watch + Offset(0, r + u * 5),
      p.ink2,
      size: u * 4.2,
    );
    if (s.ran && s.runT < runSeconds) {
      drawTag(
        canvas,
        '×2',
        watch + Offset(-r - u * 2, -r),
        Colors.white,
        size: u * 3.6,
        background: p.coral,
      );
    }
  }

  @override
  void paintOutcome(
    Canvas canvas,
    Size size,
    String outcome,
    Map<String, Object> controls,
    LabPalette p,
  ) {
    final lines = switch (outcome) {
      'fast' => 3,
      'medium' => 2,
      _ => 1,
    };
    final pivot = Offset(size.width * 0.42, size.height * 0.12);
    final a = 0.45;
    final bob = pivot + Offset(math.sin(a), math.cos(a)) * size.height * 0.62;
    canvas.drawLine(pivot, bob, strokePaint(p.ink2, 1.4));
    drawBall(canvas, bob, size.width * 0.12, p.violet);
    for (var i = 0; i < lines; i++) {
      final r = size.height * (0.5 + i * 0.12);
      canvas.drawArc(
        Rect.fromCircle(center: pivot, radius: r),
        math.pi / 2 - 0.2 - i * 0.02,
        -0.45 - i * 0.12,
        false,
        strokePaint(p.violet.withValues(alpha: 0.75 - i * 0.18), 2),
      );
    }
  }

  @override
  List<LabStat> stats(LabObservation obs, RegionalLanguage lang) => [
    LabStat(Icons.av_timer_rounded, 'T = ${obs.values['period_s']} s'),
    LabStat(Icons.replay_rounded, '${obs.values['swings_10s']} × / 10 s'),
  ];

  @override
  String describe(LabScene s) {
    final swings = s.result?.values['swings_10s'];
    return 'Pendulum with a ${s.c<int>('length_cm')} centimetre string and a '
        '${s.c<int>('mass_g')} gram bob. '
        '${swings == null ? 'Not timed yet.' : '$swings swings in 10 seconds.'}';
  }
}
