import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../data/lab/lab_rules.dart';
import '../../../data/lab/lab_words.dart';
import '../../../data/models/regional_language.dart';
import '../lab_kit.dart';

// ─── Universal indicator: drop it in, watch the colour, read the pH ──────────

class IndicatorRig extends LabRig {
  const IndicatorRig();

  @override
  String get id => 'indicator';

  @override
  IconData get icon => Icons.colorize_rounded;

  @override
  double get runSeconds => 2.7;

  static const _drops = [0.35, 0.75, 1.15];
  static const _fall = 0.3;

  @override
  List<LabControl> get controls => [
    LabControl(
      key: 'sample',
      icon: Icons.local_drink_rounded,
      caption: (v, lang) => labWord(v as String, lang),
      glyph: (canvas, size, v, p) => drawSample(
        canvas,
        size.center(Offset.zero),
        size.shortestSide * 0.36,
        v as String,
        p,
      ),
    ),
  ];

  static const _samples = [
    'lemon',
    'tomato',
    'water',
    'baking_soda',
    'soap',
    'limewater',
  ];

  @override
  Map<String, Object> previewControls(int cycle) => {
    'sample': _samples[cycle % _samples.length],
  };

  static Color sampleTint(String key, LabPalette p) => switch (key) {
    'lemon' => Color.lerp(p.gold, Colors.white, 0.55)!.withValues(alpha: 0.7),
    'tomato' => Color.lerp(p.coral, Colors.white, 0.5)!.withValues(alpha: 0.7),
    'water' => p.water,
    'soap' => Color.lerp(p.sky, Colors.white, 0.7)!.withValues(alpha: 0.75),
    _ => Color.lerp(p.surface3, Colors.white, 0.4)!.withValues(alpha: 0.85),
  };

  // ─── Paint ─────────────────────────────────────────────────────────────

  @override
  void paint(Canvas canvas, Size size, LabScene s) {
    final p = s.p;
    final w = size.width;
    final h = size.height;
    final u = math.min(w, h) / 100;
    final sample = s.c<String>('sample');
    final colorKey = s.result?.values['color'] as String?;
    final ph = (s.result?.values['approx_ph'] as num?)?.toInt();
    final result = colorKey == null ? null : p.indicator(colorKey);

    final bw = math.min(w * (s.preview ? 0.5 : 0.36), h * 0.55);
    final beaker = Rect.fromLTWH(
      w / 2 - bw / 2,
      h * (s.preview ? 0.38 : 0.35),
      bw,
      h * (s.preview ? 0.55 : 0.4),
    );
    final surfaceY = beaker.top + beaker.height * 0.3;
    final liquid = Path()
      ..moveTo(beaker.left + u * 1.2, surfaceY)
      ..lineTo(beaker.right - u * 1.2, surfaceY)
      ..lineTo(beaker.right - u * 1.2, beaker.bottom - u * 5)
      ..quadraticBezierTo(
        beaker.right - u * 1.2,
        beaker.bottom - u,
        beaker.right - u * 5,
        beaker.bottom - u,
      )
      ..lineTo(beaker.left + u * 5, beaker.bottom - u)
      ..quadraticBezierTo(
        beaker.left + u * 1.2,
        beaker.bottom - u,
        beaker.left + u * 1.2,
        beaker.bottom - u * 5,
      )
      ..close();

    // Soft glow in the result colour.
    final mix = result == null ? 0.0 : easeInOut(s.seg(0.7, 2.3));
    if (result != null) {
      drawGlow(canvas, beaker.center, beaker.width * 1.1, result, mix * 0.6);
    }

    // Liquid: the sample, then the indicator colour spreading in.
    canvas.save();
    canvas.clipPath(liquid);
    canvas.drawPath(liquid, fillPaint(sampleTint(sample, p)));
    if (result != null) {
      for (var i = 0; i < _drops.length; i++) {
        final landed = s.runT - _drops[i] - _fall;
        if (landed <= 0) continue;
        final k = easeOut(landed / 1.1);
        final x = beaker.center.dx + (i - 1) * beaker.width * 0.18;
        canvas.drawCircle(
          Offset(x, surfaceY + beaker.height * 0.08 * k),
          beaker.width * (0.1 + 0.9 * k),
          fillPaint(result.withValues(alpha: 0.55 * (1 - mix * 0.4))),
        );
      }
      canvas.drawPath(liquid, fillPaint(result.withValues(alpha: 0.8 * mix)));
      // Swirls fade as the colour evens out.
      final swirl = (1 - mix) * s.seg(0.65, 0.9);
      if (swirl > 0) {
        for (var i = 0; i < 3; i++) {
          final r = beaker.width * (0.14 + i * 0.1);
          canvas.drawArc(
            Rect.fromCircle(
              center: Offset(beaker.center.dx, surfaceY + beaker.height * 0.35),
              radius: r,
            ),
            s.t * (2.4 - i * 0.5) + i * 2,
            1.6,
            false,
            strokePaint(result.withValues(alpha: 0.7 * swirl), u * 1.4),
          );
        }
      }
      if (mix >= 1) {
        drawBubbles(
          canvas,
          Rect.fromLTRB(
            beaker.left + u * 4,
            surfaceY,
            beaker.right - u * 4,
            beaker.bottom - u * 2,
          ),
          s.t,
          Colors.white.withValues(alpha: 0.8),
          count: 6,
          speed: 0.35,
          size: u / 2.5,
          salt: 4,
        );
      }
    }
    if (sample == 'soap') {
      for (var i = 0; i < 7; i++) {
        canvas.drawCircle(
          Offset(
            beaker.left + beaker.width * (0.12 + i * 0.13),
            surfaceY + u * 0.5,
          ),
          u * (1.6 + labNoise(i, 31) * 1.4),
          strokePaint(Colors.white.withValues(alpha: 0.9), u * 0.5),
        );
      }
    }
    canvas.restore();

    // Surface line.
    canvas.drawLine(
      Offset(beaker.left + u * 1.2, surfaceY),
      Offset(beaker.right - u * 1.2, surfaceY),
      strokePaint(Colors.white.withValues(alpha: 0.6), u * 0.7),
    );

    // Beaker glass with tick marks and a lip.
    final glass = strokePaint(p.glass, u * 1.2);
    final outline = Path()
      ..moveTo(beaker.left - u * 2.5, beaker.top)
      ..lineTo(beaker.left, beaker.top + u * 2)
      ..lineTo(beaker.left, beaker.bottom - u * 5)
      ..quadraticBezierTo(
        beaker.left,
        beaker.bottom,
        beaker.left + u * 5,
        beaker.bottom,
      )
      ..lineTo(beaker.right - u * 5, beaker.bottom)
      ..quadraticBezierTo(
        beaker.right,
        beaker.bottom,
        beaker.right,
        beaker.bottom - u * 5,
      )
      ..lineTo(beaker.right, beaker.top);
    canvas.drawPath(outline, glass);
    for (var i = 1; i <= 4; i++) {
      final y = beaker.bottom - beaker.height * i / 5.5;
      canvas.drawLine(
        Offset(beaker.left, y),
        Offset(beaker.left + (i.isEven ? u * 5 : u * 3), y),
        strokePaint(p.glass, u * 0.6),
      );
    }
    canvas.drawLine(
      Offset(beaker.right - u * 3.5, beaker.top + u * 5),
      Offset(beaker.right - u * 3.5, beaker.top + beaker.height * 0.55),
      strokePaint(Colors.white.withValues(alpha: 0.45), u * 1.2),
    );

    // Sample badge on the glass.
    if (!s.preview) {
      final badge = Offset(beaker.right, beaker.bottom - u * 2);
      canvas.drawCircle(badge, u * 7, fillPaint(p.surface));
      canvas.drawCircle(badge, u * 7, strokePaint(p.hairline, u * 0.6));
      drawSample(canvas, badge, u * 4.6, sample, p);
    }

    // Dropper with a rainbow of indicator.
    final dip = s.ran
        ? easeInOut(s.seg(0, 0.35)) * u * 5
        : math.sin(s.t * 1.6) * u;
    final tip = Offset(beaker.center.dx, beaker.top - u * 4 + dip);
    _dropper(canvas, tip, u, p, squeeze: s.ran ? _squeeze(s.runT) : 0);

    // Falling drops.
    if (s.ran) {
      for (var i = 0; i < _drops.length; i++) {
        final k = (s.runT - _drops[i]) / _fall;
        if (k <= 0 || k >= 1) continue;
        final x = beaker.center.dx + (i - 1) * beaker.width * 0.18 * k;
        final y = tip.dy + (surfaceY - tip.dy) * k * k;
        _drip(canvas, Offset(x, y), u * 1.8, result ?? p.green);
      }
    }

    if (s.preview) return;

    // ─── pH scale ────────────────────────────────────────────────────────
    final strip = Rect.fromLTWH(w * 0.08, h * 0.86, w * 0.84, u * 5);
    final seg = strip.width / 14;
    for (var i = 1; i <= 14; i++) {
      final r = Rect.fromLTWH(
        strip.left + (i - 1) * seg,
        strip.top,
        seg + 0.5,
        strip.height,
      );
      canvas.drawRect(r, fillPaint(p.indicator(indicatorColor(i))));
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(strip, Radius.circular(u * 1.5)),
      strokePaint(p.surface, u * 0.8),
    );
    for (final n in [1, 7, 14]) {
      drawTag(
        canvas,
        '$n',
        Offset(strip.left + (n - 0.5) * seg, strip.bottom + u * 4),
        p.ink3,
        size: u * 3.4,
      );
    }

    // Marker: a "?" before the run, then it slides to the measured pH.
    final slide = ph == null ? 0.0 : easeInOut(s.seg(1.9, 2.5));
    final at = 7 + ((ph ?? 7) - 7) * slide;
    final mx = strip.left + (at - 0.5) * seg;
    final bob = ph == null ? math.sin(s.t * 2.5) * u : 0.0;
    final pin = Offset(mx, strip.top - u * 7 + bob);
    final pinColor = ph == null || slide < 1
        ? p.ink2
        : p.indicator(indicatorColor(ph));
    final pop = slide >= 1 ? 1 + 0.25 * (1 - s.seg(2.5, 2.8)) : 1.0;
    canvas.drawPath(
      Path()
        ..moveTo(mx, strip.top - u * 0.5)
        ..lineTo(mx - u * 2.2, strip.top - u * 3.5)
        ..lineTo(mx + u * 2.2, strip.top - u * 3.5)
        ..close(),
      fillPaint(pinColor),
    );
    canvas.drawCircle(pin, u * 5 * pop, fillPaint(pinColor));
    drawTag(
      canvas,
      ph == null ? '?' : (slide >= 1 ? '$ph' : at.toStringAsFixed(0)),
      pin,
      Colors.white,
      size: u * 4.8 * pop,
    );
  }

  static double _squeeze(double runT) {
    for (final d in _drops) {
      final k = (runT - d + 0.12) / 0.2;
      if (k > 0 && k < 1) return math.sin(k * math.pi);
    }
    return 0;
  }

  static void _dropper(
    Canvas canvas,
    Offset tip,
    double u,
    LabPalette p, {
    double squeeze = 0,
  }) {
    final tube = Rect.fromLTRB(
      tip.dx - u * 2.2,
      tip.dy - u * 15,
      tip.dx + u * 2.2,
      tip.dy - u * 2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tube, Radius.circular(u)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [p.coral, p.gold, p.green, p.blue, p.violet],
        ).createShader(tube),
    );
    canvas.drawPath(
      Path()
        ..moveTo(tube.left, tube.bottom)
        ..lineTo(tip.dx - u * 0.6, tip.dy)
        ..lineTo(tip.dx + u * 0.6, tip.dy)
        ..lineTo(tube.right, tube.bottom)
        ..close(),
      fillPaint(p.green.withValues(alpha: 0.8)),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tube.inflate(u * 0.5), Radius.circular(u * 1.4)),
      strokePaint(p.glass, u * 0.6),
    );
    final bulb = Rect.fromCenter(
      center: Offset(tip.dx, tube.top - u * 4),
      width: u * (8 - 2 * squeeze),
      height: u * (9 + squeeze),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bulb, Radius.circular(u * 4)),
      Paint()
        ..shader = LinearGradient(
          colors: [Color.lerp(p.pink, Colors.white, 0.3)!, p.pink],
        ).createShader(bulb),
    );
  }

  static void _drip(Canvas canvas, Offset c, double r, Color color) {
    canvas.drawPath(
      Path()
        ..moveTo(c.dx, c.dy - r * 1.8)
        ..quadraticBezierTo(c.dx + r, c.dy - r * 0.2, c.dx, c.dy + r)
        ..quadraticBezierTo(c.dx - r, c.dy - r * 0.2, c.dx, c.dy - r * 1.8),
      fillPaint(color),
    );
  }

  /// A picture of a sample, centred on [c] with radius [r].
  static void drawSample(
    Canvas canvas,
    Offset c,
    double r,
    String key,
    LabPalette p,
  ) {
    switch (key) {
      case 'lemon':
        final rind = Color.lerp(p.gold, Colors.white, 0.1)!;
        canvas.drawCircle(c, r, fillPaint(rind));
        canvas.drawCircle(
          c,
          r * 0.82,
          fillPaint(Color.lerp(p.gold, Colors.white, 0.6)!),
        );
        final seg = strokePaint(rind, r * 0.08);
        for (var i = 0; i < 8; i++) {
          final a = i * math.pi / 4;
          canvas.drawLine(
            c,
            c + Offset(math.cos(a), math.sin(a)) * r * 0.8,
            seg,
          );
        }
        canvas.drawCircle(c, r * 0.12, fillPaint(rind));
      case 'tomato':
        drawBall(canvas, c + Offset(0, r * 0.08), r * 0.9, p.coral);
        canvas.drawPath(
          starPath(c - Offset(0, r * 0.62), r * 0.42, 0.35),
          fillPaint(p.green),
        );
      case 'water':
        canvas.drawPath(
          Path()
            ..moveTo(c.dx, c.dy - r)
            ..quadraticBezierTo(
              c.dx + r * 0.85,
              c.dy,
              c.dx + r * 0.6,
              c.dy + r * 0.5,
            )
            ..arcToPoint(
              Offset(c.dx - r * 0.6, c.dy + r * 0.5),
              radius: Radius.circular(r * 0.62),
            )
            ..quadraticBezierTo(c.dx - r * 0.85, c.dy, c.dx, c.dy - r)
            ..close(),
          fillPaint(p.blue),
        );
      case 'baking_soda':
        final jar = Rect.fromCenter(
          center: c + Offset(0, r * 0.1),
          width: r * 1.5,
          height: r * 1.6,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(jar, Radius.circular(r * 0.3)),
          fillPaint(p.sky),
        );
        canvas.drawRect(
          Rect.fromLTWH(
            jar.left,
            jar.top + jar.height * 0.35,
            jar.width,
            jar.height * 0.35,
          ),
          fillPaint(Colors.white),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              jar.left - r * 0.08,
              jar.top - r * 0.2,
              jar.width + r * 0.16,
              r * 0.35,
            ),
            Radius.circular(r * 0.1),
          ),
          fillPaint(p.ink2),
        );
      case 'soap':
        final bar = Rect.fromCenter(
          center: c + Offset(0, r * 0.25),
          width: r * 1.7,
          height: r * 0.95,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(bar, Radius.circular(r * 0.35)),
          fillPaint(Color.lerp(p.pink, Colors.white, 0.35)!),
        );
        for (final (dx, dy, rr) in [
          (-0.35, -0.6, 0.28),
          (0.25, -0.75, 0.2),
          (0.6, -0.45, 0.14),
        ]) {
          canvas.drawCircle(
            c + Offset(dx * r, dy * r),
            rr * r,
            strokePaint(p.sky, r * 0.1),
          );
        }
      default:
        final glass = Rect.fromCenter(
          center: c,
          width: r * 1.3,
          height: r * 1.8,
        );
        canvas.drawRect(
          Rect.fromLTRB(
            glass.left,
            glass.top + glass.height * 0.3,
            glass.right,
            glass.bottom,
          ),
          fillPaint(Color.lerp(p.surface3, Colors.white, 0.3)!),
        );
        canvas.drawPath(
          Path()
            ..moveTo(glass.left, glass.top)
            ..lineTo(glass.left, glass.bottom)
            ..lineTo(glass.right, glass.bottom)
            ..lineTo(glass.right, glass.top),
          strokePaint(p.ink2, r * 0.12),
        );
        canvas.drawCircle(
          c + Offset(-r * 0.15, r * 0.35),
          r * 0.12,
          fillPaint(p.ink3),
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
    final c = Offset(size.width / 2, size.height * 0.52);
    final r = size.shortestSide * 0.3;
    final color = p.indicator(outcome);
    drawGlow(canvas, c, r * 1.8, color, 0.5);
    final drop = Path()
      ..moveTo(c.dx, c.dy - r * 1.4)
      ..quadraticBezierTo(
        c.dx + r * 1.1,
        c.dy - r * 0.1,
        c.dx + r * 0.8,
        c.dy + r * 0.5,
      )
      ..arcToPoint(
        Offset(c.dx - r * 0.8, c.dy + r * 0.5),
        radius: Radius.circular(r * 0.83),
      )
      ..quadraticBezierTo(c.dx - r * 1.1, c.dy - r * 0.1, c.dx, c.dy - r * 1.4)
      ..close();
    canvas.drawPath(drop, fillPaint(color));
    canvas.drawCircle(
      c + Offset(-r * 0.35, r * 0.05),
      r * 0.18,
      fillPaint(Colors.white.withValues(alpha: 0.55)),
    );
  }

  @override
  List<LabStat> stats(LabObservation obs, RegionalLanguage lang) => [
    LabStat(Icons.straighten_rounded, 'pH ${obs.values['approx_ph']}'),
    LabStat(
      Icons.science_rounded,
      labWord(obs.values['nature'] as String, lang),
    ),
  ];

  @override
  String describe(LabScene s) {
    final color = s.result?.values['color'];
    return 'Beaker of ${s.c<String>('sample').replaceAll('_', ' ')}. '
        '${color == null ? 'No indicator added yet.' : 'Indicator turned $color, pH ${s.result!.values['approx_ph']}.'}';
  }
}
