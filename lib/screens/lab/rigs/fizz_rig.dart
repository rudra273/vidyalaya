import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../data/lab/lab_rules.dart';
import '../../../data/lab/lab_words.dart';
import '../../../data/models/regional_language.dart';
import '../lab_kit.dart';

// ─── Fizz balloon: baking soda + vinegar make CO₂ that fills a balloon ───────

class FizzRig extends LabRig {
  const FizzRig();

  @override
  String get id => 'fizz';

  @override
  IconData get icon => Icons.bubble_chart_rounded;

  @override
  double get runSeconds => 3.3;

  @override
  List<LabControl> get controls => [
    LabControl(
      key: 'soda_spoons',
      icon: Icons.soup_kitchen_rounded,
      caption: (v, _) => '×$v',
      glyph: (canvas, size, v, p) {
        final n = v as int;
        for (var i = 0; i < n; i++) {
          final c = Offset(
            size.width / 2 + (i - (n - 1) / 2) * size.width * 0.26,
            size.height * 0.55,
          );
          _spoon(canvas, c, size.width * 0.14, p);
        }
      },
    ),
    LabControl(
      key: 'vinegar_cups',
      icon: Icons.local_cafe_rounded,
      caption: (v, _) => '×$v',
      glyph: (canvas, size, v, p) {
        final cup = Rect.fromCenter(
          center: size.center(Offset.zero),
          width: size.width * 0.5,
          height: size.height * 0.62,
        );
        final fill = cup.height * (v as int) / 3.4;
        canvas.drawRect(
          Rect.fromLTRB(cup.left, cup.bottom - fill, cup.right, cup.bottom),
          fillPaint(vinegarColor(p)),
        );
        canvas.drawPath(
          Path()
            ..moveTo(cup.left, cup.top)
            ..lineTo(cup.left, cup.bottom)
            ..lineTo(cup.right, cup.bottom)
            ..lineTo(cup.right, cup.top),
          strokePaint(p.glass, 1.6),
        );
        for (var i = 1; i < 3; i++) {
          final y = cup.bottom - cup.height * i / 3.4;
          canvas.drawLine(
            Offset(cup.left, y),
            Offset(cup.left + cup.width * 0.3, y),
            strokePaint(p.glass, 1),
          );
        }
      },
    ),
  ];

  @override
  Map<String, Object> previewControls(int cycle) => {
    'soda_spoons': [3, 1, 2][cycle % 3],
    'vinegar_cups': 3,
  };

  static Color vinegarColor(LabPalette p) =>
      Color.lerp(p.gold, Colors.white, 0.5)!.withValues(alpha: 0.6);

  static double balloonRadius(int gas, double u) => u * (5 + 4.5 * gas);

  // ─── Paint ─────────────────────────────────────────────────────────────

  @override
  void paint(Canvas canvas, Size size, LabScene s) {
    final p = s.p;
    final w = size.width;
    final h = size.height;
    final u = math.min(w, h) / 100;
    final soda = s.c<int>('soda_spoons');
    final gas = (s.result?.values['gas_units'] as num?)?.toInt() ?? 0;
    final leftover = s.result?.values['leftover'] as String?;

    // ─── Flask geometry ──────────────────────────────────────────────────
    final baseY = h * 0.93;
    final baseW = math.min(w * 0.44, h * 0.62);
    final cx = w / 2;
    final neckW = baseW * 0.24;
    final neckTop = h * 0.56;
    final shoulderY = h * 0.65;
    final flask = Path()
      ..moveTo(cx - neckW / 2, neckTop)
      ..lineTo(cx - neckW / 2, shoulderY)
      ..lineTo(cx - baseW / 2, baseY - u * 3)
      ..quadraticBezierTo(cx - baseW / 2, baseY, cx - baseW / 2 + u * 3, baseY)
      ..lineTo(cx + baseW / 2 - u * 3, baseY)
      ..quadraticBezierTo(cx + baseW / 2, baseY, cx + baseW / 2, baseY - u * 3)
      ..lineTo(cx + neckW / 2, shoulderY)
      ..lineTo(cx + neckW / 2, neckTop);
    final inside = Path.from(flask)..close();
    final bodyH = baseY - shoulderY;
    final vinegarLevel = s.lerpControl('vinegar_cups', 0.4);
    final liquidTop = baseY - bodyH * (0.12 + 0.13 * vinegarLevel);

    // Soda spoons beside the flask (they tip into the balloon on run).
    final spoonsFade = s.ran ? 1 - s.seg(0, 0.4) : 1.0;
    if (spoonsFade > 0 && !s.preview) {
      canvas.save();
      canvas.translate(0, (1 - spoonsFade) * -u * 6);
      for (var i = 0; i < soda; i++) {
        _spoon(
          canvas,
          Offset(cx - baseW / 2 - u * 12, baseY - u * 6 - i * u * 9),
          u * 5,
          p,
          alpha: spoonsFade,
        );
      }
      canvas.restore();
    }

    // Glow of the reaction.
    final fizz = s.ran ? s.seg(0.9, 1.5) * (1 - s.seg(2.4, 3.3)) : 0.0;
    drawGlow(canvas, Offset(cx, liquidTop), baseW * 0.8, p.coral, fizz * 0.5);

    // Liquid + reaction inside the glass.
    canvas.save();
    canvas.clipPath(inside);
    final liquidRect = Rect.fromLTRB(cx - baseW, liquidTop, cx + baseW, baseY);
    canvas.drawRect(liquidRect, fillPaint(vinegarColor(p)));
    // Powder falling from the balloon.
    if (s.ran) {
      final pour = s.seg(0.4, 1.15);
      if (pour > 0 && pour < 1) {
        for (var i = 0; i < 26; i++) {
          final life = (pour * 2.2 + labNoise(i, 41)) % 1;
          final y = neckTop - u * 4 + (liquidTop - neckTop + u * 4) * life;
          final x = cx + (labNoise(i, 42) - 0.5) * neckW * (0.4 + life * 1.4);
          canvas.drawCircle(Offset(x, y), u * 0.7, fillPaint(Colors.white));
        }
      }
      // Sediment of unreacted soda.
      final settle = s.seg(2.2, 3.2);
      if (leftover == 'baking_soda' && settle > 0) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx, baseY - u),
            width: baseW * 0.55 * settle,
            height: u * 3.5 * settle,
          ),
          fillPaint(Colors.white.withValues(alpha: 0.9)),
        );
      }
      // Fizzing bubbles and foam.
      if (fizz > 0) {
        drawBubbles(
          canvas,
          Rect.fromLTRB(cx - baseW * 0.4, liquidTop, cx + baseW * 0.4, baseY),
          s.t,
          Colors.white,
          count: (10 + 14 * gas * fizz).round(),
          speed: 1.6,
          size: u / 2,
          salt: 9,
        );
      }
      final foam = s.seg(0.95, 1.6) * (1 - 0.7 * s.seg(2.3, 3.3));
      if (foam > 0) {
        final foamH = (liquidTop - neckTop) * 0.55 * foam * gas / 3;
        for (var i = 0; i < 26; i++) {
          final x = cx + (labNoise(i, 51) - 0.5) * baseW;
          final y =
              liquidTop -
              foamH * labNoise(i, 52) +
              math.sin(s.t * 6 + i) * u * 0.5;
          canvas.drawCircle(
            Offset(x, y),
            u * (1.8 + labNoise(i, 53) * 2.2),
            fillPaint(Colors.white.withValues(alpha: 0.85)),
          );
        }
      }
    } else {
      drawBubbles(
        canvas,
        Rect.fromLTRB(cx - baseW * 0.3, liquidTop, cx + baseW * 0.3, baseY),
        s.t,
        Colors.white.withValues(alpha: 0.6),
        count: 3,
        speed: 0.2,
        size: u / 3,
      );
    }
    canvas.restore();

    // Glass.
    canvas.drawPath(flask, strokePaint(p.glass, u * 1.3));
    canvas.drawLine(
      Offset(cx - baseW * 0.3, baseY - u * 5),
      Offset(cx - neckW * 0.3, shoulderY + u * 4),
      strokePaint(Colors.white.withValues(alpha: 0.45), u * 1.2),
    );
    for (var i = 1; i <= 3; i++) {
      final y = baseY - bodyH * (0.12 + 0.13 * i);
      final half = baseW / 2 - (baseY - y) * (baseW - neckW) / 2 / bodyH;
      canvas.drawLine(
        Offset(cx + half - u * 5, y),
        Offset(cx + half - u, y),
        strokePaint(p.glass, u * 0.6),
      );
    }

    // ─── Balloon ─────────────────────────────────────────────────────────
    final lift = s.ran ? easeInOut(s.seg(0, 0.6)) : 0.0;
    final droop = (1 - lift) * 1.9 + (s.ran ? 0 : math.sin(s.t * 1.5) * 0.05);
    final grow = s.ran ? elastic(s.seg(1.1, 3.2)) : 0.0;
    final limp = u * 5.5;
    final full = gas == 0
        ? limp
        : balloonRadius(gas, u) * (s.preview ? 0.85 : 1);
    final breathe = s.ran && s.runT > runSeconds
        ? 1 + 0.025 * math.sin(s.t * 2)
        : 1.0;
    final r = (limp + (full - limp) * grow) * breathe;
    final neck = Offset(cx, neckTop);

    canvas.save();
    canvas.translate(neck.dx, neck.dy);
    canvas.rotate(droop);
    // Balloon body grows upward from the neck.
    final stretch = 1.25 - 0.1 * grow;
    final body = Rect.fromCenter(
      center: Offset(0, -r * stretch - u * 4),
      width: r * 2,
      height: r * 2 * stretch,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(-neckW * 0.58, -u * 1.2, neckW * 0.58, u * 2.2),
        Radius.circular(u * 1.6),
      ),
      fillPaint(Color.lerp(p.pink, Colors.black, 0.15)!),
    );
    canvas.drawPath(
      Path()
        ..moveTo(-neckW * 0.42, -u)
        ..quadraticBezierTo(
          -neckW * 0.3,
          body.bottom,
          -r * 0.3,
          body.bottom - r * 0.2,
        )
        ..lineTo(r * 0.3, body.bottom - r * 0.2)
        ..quadraticBezierTo(neckW * 0.3, body.bottom, neckW * 0.42, -u)
        ..close(),
      fillPaint(p.pink),
    );
    canvas.drawOval(
      body,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          colors: [
            Color.lerp(p.pink, Colors.white, 0.45)!,
            p.pink,
            Color.lerp(p.pink, Colors.black, 0.2)!,
          ],
          stops: const [0, 0.6, 1],
        ).createShader(body),
    );
    if (!s.ran || s.runT < 0.5) {
      // Soda waiting inside the limp balloon.
      canvas.drawCircle(
        body.center + Offset(0, -r * 0.2),
        r * 0.5,
        fillPaint(Colors.white.withValues(alpha: 0.85)),
      );
    }
    canvas.drawArc(
      body.deflate(r * 0.3),
      math.pi * 1.1,
      math.pi * 0.3,
      false,
      strokePaint(Colors.white.withValues(alpha: 0.6), r * 0.12),
    );
    // CO₂ molecules drifting inside.
    if (gas > 0 && grow > 0.6 && !s.preview) {
      final count = gas * 3;
      for (var i = 0; i < count; i++) {
        final a = s.t * (0.5 + labNoise(i, 61) * 0.6) + i * 2.1;
        final pos =
            body.center +
            Offset(
              math.cos(a) * body.width * 0.28 * labNoise(i, 62),
              math.sin(a * 1.3) * body.height * 0.28 * labNoise(i, 63),
            );
        _co2(canvas, pos, r * 0.07, s.t + i, p);
      }
    }
    canvas.restore();

    if (!s.preview && s.ran && grow > 0.6) {
      drawTag(
        canvas,
        'CO₂',
        Offset(cx + full + u * 10, neckTop - full * 1.2),
        Colors.white,
        size: u * 4.2,
        background: p.pink.withValues(alpha: (grow - 0.6) / 0.4),
      );
    }
  }

  static void _co2(Canvas canvas, Offset c, double r, double t, LabPalette p) {
    final a = t * 0.8;
    final d = Offset(math.cos(a), math.sin(a)) * r * 1.7;
    canvas.drawLine(
      c - d,
      c + d,
      strokePaint(Colors.white.withValues(alpha: 0.8), r * 0.5),
    );
    canvas.drawCircle(c - d, r * 0.9, fillPaint(p.coral));
    canvas.drawCircle(c + d, r * 0.9, fillPaint(p.coral));
    canvas.drawCircle(c, r, fillPaint(p.ink));
  }

  static void _spoon(
    Canvas canvas,
    Offset c,
    double r,
    LabPalette p, {
    double alpha = 1,
  }) {
    canvas.drawLine(
      c + Offset(r * 0.9, r * 0.1),
      c + Offset(r * 2.4, r * 0.7),
      strokePaint(p.metal.withValues(alpha: alpha), r * 0.3),
    );
    canvas.drawOval(
      Rect.fromCenter(center: c, width: r * 2, height: r * 1.1),
      fillPaint(p.metal.withValues(alpha: alpha)),
    );
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - r * 0.85, c.dy)
        ..quadraticBezierTo(c.dx, c.dy - r * 1.2, c.dx + r * 0.85, c.dy)
        ..close(),
      fillPaint(Colors.white.withValues(alpha: alpha)),
    );
  }

  @override
  void paintOutcome(
    Canvas canvas,
    Size size,
    String outcome,
    Map<String, Object> controls,
    LabPalette p,
  ) {
    final gas = kBalloonSizes.indexOf(outcome) + 1;
    final r = size.shortestSide * (0.12 + 0.075 * gas);
    final neck = Offset(size.width / 2, size.height * 0.92);
    final body = Rect.fromCenter(
      center: neck - Offset(0, r * 1.15 + 3),
      width: r * 2,
      height: r * 2.2,
    );
    canvas.drawPath(
      Path()
        ..moveTo(neck.dx - 3, neck.dy)
        ..lineTo(neck.dx - r * 0.15, body.bottom - 2)
        ..lineTo(neck.dx + r * 0.15, body.bottom - 2)
        ..lineTo(neck.dx + 3, neck.dy)
        ..close(),
      fillPaint(p.pink),
    );
    canvas.drawOval(
      body,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          colors: [Color.lerp(p.pink, Colors.white, 0.45)!, p.pink],
        ).createShader(body),
    );
  }

  @override
  List<LabStat> stats(LabObservation obs, RegionalLanguage lang) => [
    LabStat(Icons.bubble_chart_rounded, 'CO₂ × ${obs.values['gas_units']}'),
    LabStat(
      Icons.inventory_2_rounded,
      labWord(obs.values['leftover'] as String, lang),
    ),
  ];

  @override
  String describe(LabScene s) {
    final balloon = s.result?.values['balloon'];
    return 'Flask with ${s.c<int>('vinegar_cups')} cups of vinegar and a balloon '
        'holding ${s.c<int>('soda_spoons')} spoons of baking soda. '
        '${balloon == null ? 'Not mixed yet.' : 'The balloon grew $balloon.'}';
  }
}
