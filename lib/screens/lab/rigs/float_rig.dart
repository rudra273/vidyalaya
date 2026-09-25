import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../data/lab/lab_rules.dart';
import '../../../data/lab/lab_words.dart';
import '../../../data/models/regional_language.dart';
import '../lab_kit.dart';

// ─── Sink or float: drop an object in, compare densities ─────────────────────

class FloatRig extends LabRig {
  const FloatRig();

  @override
  String get id => 'float';

  @override
  IconData get icon => Icons.water_rounded;

  @override
  double get runSeconds => 2.5;

  static const _dropSeconds = 0.45;

  @override
  List<LabControl> get controls => [
    LabControl(
      key: 'object',
      icon: Icons.category_rounded,
      caption: (v, lang) => labWord(v as String, lang),
      glyph: (canvas, size, v, p) => drawObject(
        canvas,
        size.center(Offset.zero),
        size.shortestSide * 0.7,
        v as String,
        p,
      ),
    ),
    LabControl(
      key: 'liquid',
      icon: Icons.water_drop_rounded,
      caption: (v, lang) => labWord(v as String, lang),
      glyph: (canvas, size, v, p) => _dropGlyph(
        canvas,
        size.center(Offset.zero),
        size.shortestSide * 0.34,
        v == 'salt_water',
        p,
      ),
    ),
  ];

  @override
  Map<String, Object> previewControls(int cycle) => const [
    {'object': 'egg', 'liquid': 'salt_water'},
    {'object': 'stone', 'liquid': 'water'},
    {'object': 'wood', 'liquid': 'water'},
    {'object': 'egg', 'liquid': 'water'},
    {'object': 'ice', 'liquid': 'water'},
  ][cycle % 5];

  static Color liquidColor(bool salty, LabPalette p) =>
      (salty ? Color.lerp(p.blue, p.teal, 0.6)! : p.blue).withValues(
        alpha: p.dark ? 0.42 : 0.3,
      );

  /// Height of each object as a share of its box, for the waterline.
  static const _heights = {
    'wood': 0.6,
    'ice': 0.8,
    'egg': 0.86,
    'stone': 0.72,
    'iron': 0.76,
  };

  // ─── Paint ─────────────────────────────────────────────────────────────

  @override
  void paint(Canvas canvas, Size size, LabScene s) {
    final p = s.p;
    final w = size.width;
    final h = size.height;
    final u = math.min(w, h) / 100;
    final object = s.c<String>('object');
    final salty = s.c<String>('liquid') == 'salt_water';
    final tankW = math.min(w * (s.preview ? 0.7 : 0.56), h * 0.85);
    final tank = Rect.fromLTWH(
      (s.preview ? w / 2 : w * 0.44) - tankW / 2,
      h * 0.3,
      tankW,
      h * 0.63,
    );
    final surfaceY = tank.top + tank.height * 0.24;
    final box = math.min(u * 17, tankW * 0.3);
    final objH = box * (_heights[object] ?? 0.8);
    final floats = s.result?.values['result'] == 'float';
    final underwater =
        ((s.result?.values['underwater_pct'] as num?) ?? 100) / 100;

    // ─── Object motion ───────────────────────────────────────────────────
    final hoverY = tank.top - box * 0.9 + math.sin(s.t * 2.2) * u * 1.2;
    final impactY = surfaceY - objH * 0.2;
    double y;
    var tilt = 0.0;
    var splash = -1.0;
    if (!s.ran) {
      y = hoverY;
    } else if (s.runT < _dropSeconds) {
      final k = s.runT / _dropSeconds;
      y = hoverY + (impactY - hoverY) * k * k;
    } else {
      final tau = s.runT - _dropSeconds;
      splash = tau;
      if (floats) {
        final eq = surfaceY + objH * (underwater - 0.5);
        final decay = math.exp(-3 * tau);
        y =
            eq +
            (impactY - eq) * decay * math.cos(8 * tau) +
            objH * 0.5 * decay * math.sin(8 * tau) +
            math.sin(s.t * 2) * u * 0.6;
        tilt = 0.12 * decay * math.sin(6 * tau) + 0.03 * math.sin(s.t * 1.7);
      } else {
        final rest = tank.bottom - objH / 2 - u * 0.8;
        y = impactY + (rest - impactY) * easeOut(tau / 1.4);
        tilt = 0.25 * easeOut(tau / 1.4);
      }
    }
    final objCenter = Offset(tank.center.dx, y);

    // Drop guide while hovering.
    if (!s.ran && !s.preview) {
      drawDashed(
        canvas,
        objCenter + Offset(0, box * 0.55),
        Offset(tank.center.dx, surfaceY - u * 2),
        strokePaint(p.teal.withValues(alpha: 0.5), u * 0.7),
        dash: u * 2,
        gap: u * 2,
        phase: -s.t * u * 10,
      );
    }

    // Tank back wall.
    final tankRR = RRect.fromRectAndCorners(
      tank,
      bottomLeft: Radius.circular(u * 4),
      bottomRight: Radius.circular(u * 4),
    );
    canvas.drawRRect(tankRR, fillPaint(p.glassFill));

    // Object sits behind the liquid so its underwater part is tinted.
    canvas.save();
    canvas.translate(objCenter.dx, objCenter.dy);
    canvas.rotate(tilt);
    drawObject(canvas, Offset.zero, box, object, p);
    canvas.restore();

    // Liquid with a live wave; a splash stirs it.
    final stir = splash >= 0 ? math.exp(-2.5 * splash) * u * 3 : 0.0;
    final wave = Path()..moveTo(tank.left, tank.bottom);
    for (var x = tank.left; x <= tank.right + 0.1; x += tank.width / 24) {
      final dx = (x - tank.center.dx).abs() / tank.width;
      wave.lineTo(
        x,
        surfaceY +
            math.sin(x * 0.06 + s.t * 2.4) * u * 0.8 +
            math.sin(dx * 18 - (splash < 0 ? 0 : splash) * 14) *
                stir *
                (1 - dx),
      );
    }
    wave
      ..lineTo(tank.right, tank.bottom)
      ..close();
    canvas.save();
    canvas.clipRRect(tankRR);
    canvas.drawPath(wave, fillPaint(liquidColor(salty, p)));
    canvas.drawPath(
      wave,
      Paint()
        ..shader =
            LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.18),
                Colors.white.withValues(alpha: 0),
              ],
            ).createShader(
              Rect.fromLTRB(tank.left, surfaceY, tank.right, tank.bottom),
            ),
    );
    if (salty) {
      for (var i = 0; i < 14; i++) {
        final pos = Offset(
          tank.left + tank.width * labNoise(i, 7),
          surfaceY + (tank.bottom - surfaceY) * (0.15 + 0.8 * labNoise(i, 8)),
        );
        final twinkle = 0.4 + 0.6 * (0.5 + 0.5 * math.sin(s.t * 3 + i));
        canvas.drawRect(
          Rect.fromCenter(center: pos, width: u * 0.9, height: u * 0.9),
          fillPaint(Colors.white.withValues(alpha: 0.7 * twinkle)),
        );
      }
    }
    // Bubbles trail a sinking object.
    if (s.ran && !floats && splash >= 0) {
      final area = Rect.fromLTRB(
        tank.center.dx - box * 0.4,
        surfaceY,
        tank.center.dx + box * 0.4,
        y,
      );
      if (area.height > 0) {
        drawBubbles(
          canvas,
          area,
          s.t,
          Colors.white,
          count: 7,
          speed: 0.8,
          size: u / 2.2,
        );
      }
    }
    canvas.restore();

    // Glass walls.
    final glass = strokePaint(p.glass, u * 1.2);
    canvas.drawLine(tank.topLeft, tank.bottomLeft - Offset(0, u * 4), glass);
    canvas.drawLine(tank.topRight, tank.bottomRight - Offset(0, u * 4), glass);
    canvas.drawArc(
      Rect.fromLTWH(tank.left, tank.bottom - u * 8, u * 8, u * 8),
      math.pi / 2,
      math.pi / 2,
      false,
      glass,
    );
    canvas.drawArc(
      Rect.fromLTWH(tank.right - u * 8, tank.bottom - u * 8, u * 8, u * 8),
      0,
      math.pi / 2,
      false,
      glass,
    );
    canvas.drawLine(
      tank.bottomLeft + Offset(u * 4, 0),
      tank.bottomRight - Offset(u * 4, 0),
      glass,
    );
    canvas.drawLine(
      tank.topLeft + Offset(u * 3, u * 6),
      tank.topLeft + Offset(u * 3, tank.height * 0.6),
      strokePaint(Colors.white.withValues(alpha: 0.5), u * 1.2),
    );

    // Splash droplets + ripple.
    if (splash >= 0 && splash < 0.9) {
      for (var i = 0; i < 10; i++) {
        final side = i.isEven ? 1 : -1;
        final vx = side * (0.5 + labNoise(i, 3)) * u * 34;
        final vy = -(0.8 + labNoise(i, 4) * 0.8) * u * 70;
        final pos = Offset(
          tank.center.dx + side * box * 0.3 + vx * splash,
          surfaceY + vy * splash + 0.5 * u * 320 * splash * splash,
        );
        if (pos.dy > surfaceY) continue;
        canvas.drawCircle(
          pos,
          u * (0.8 + labNoise(i, 5)),
          fillPaint(p.blue.withValues(alpha: 0.8 * (1 - splash / 0.9))),
        );
      }
      final ring = splash / 0.9;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(tank.center.dx, surfaceY),
          width: box * (1 + 2.2 * ring),
          height: u * (2 + 3 * ring),
        ),
        strokePaint(Colors.white.withValues(alpha: 0.7 * (1 - ring)), u * 0.8),
      );
    }

    if (s.preview) return;

    // ─── Density bars: the object against the liquid ────────────────────
    final grow = easeOut(s.seg(1.5, 2.3));
    final barsLeft = tank.right + u * 7;
    final barW = u * 6;
    final maxH = tank.height * 0.8;
    const scaleTop = 1.5;
    final liquidD = kLiquidDensity[s.c<String>('liquid')]!;
    final objectD = kObjectDensity[object]!;
    final base = tank.bottom;
    final lineY = base - maxH * liquidD / scaleTop;
    if (grow > 0) {
      final bars = [
        (liquidD, liquidColor(salty, p).withValues(alpha: 0.9), 0),
        (objectD, objectColor(object, p), 1),
      ];
      for (final (d, color, i) in bars) {
        final hBar = maxH * math.min(d, scaleTop) / scaleTop * grow;
        final left = barsLeft + i * (barW + u * 2.5);
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(left, base - hBar, barW, hBar),
            topLeft: Radius.circular(u * 1.5),
            topRight: Radius.circular(u * 1.5),
          ),
          fillPaint(color),
        );
        if (d > scaleTop && grow >= 1) {
          // Break mark: the bar runs off the scale.
          final zy = base - hBar + u * 5;
          canvas.drawLine(
            Offset(left - u, zy + u),
            Offset(left + barW + u, zy - u),
            strokePaint(p.surface, u * 1.4),
          );
        }
        drawTag(
          canvas,
          '$d',
          Offset(left + barW / 2, base - hBar - u * 4),
          p.ink2,
          size: u * 3.4,
        );
      }
      drawDashed(
        canvas,
        Offset(barsLeft - u * 2, lineY),
        Offset(barsLeft + barW * 2 + u * 5, lineY),
        strokePaint(p.ink2.withValues(alpha: grow), u * 0.5),
        dash: u * 1.5,
        gap: u * 1.2,
      );
    }
  }

  // ─── Parts ─────────────────────────────────────────────────────────────

  static Color objectColor(String key, LabPalette p) => switch (key) {
    'wood' => p.amber,
    'ice' => Color.lerp(p.sky, Colors.white, 0.55)!,
    'egg' => Color.lerp(p.gold, Colors.white, 0.6)!,
    'stone' => p.ink3,
    _ => p.metal,
  };

  /// Draws an object centred on [c] inside a [box]-sized square.
  static void drawObject(
    Canvas canvas,
    Offset c,
    double box,
    String key,
    LabPalette p,
  ) {
    final color = objectColor(key, p);
    switch (key) {
      case 'wood':
        final r = Rect.fromCenter(center: c, width: box, height: box * 0.6);
        canvas.drawRRect(
          RRect.fromRectAndRadius(r, Radius.circular(box * 0.1)),
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color.lerp(color, Colors.white, 0.3)!, color],
            ).createShader(r),
        );
        final grain = strokePaint(
          Color.lerp(color, Colors.black, 0.3)!,
          box * 0.035,
        );
        for (var i = 0; i < 3; i++) {
          final gy = r.top + r.height * (0.28 + i * 0.22);
          canvas.drawPath(
            Path()
              ..moveTo(r.left + box * 0.1, gy)
              ..quadraticBezierTo(
                r.center.dx,
                gy + (i.isEven ? 1 : -1) * box * 0.07,
                r.right - box * 0.1,
                gy,
              ),
            grain,
          );
        }
      case 'ice':
        final r = Rect.fromCenter(
          center: c,
          width: box * 0.8,
          height: box * 0.8,
        );
        final rr = RRect.fromRectAndRadius(r, Radius.circular(box * 0.14));
        canvas.drawRRect(rr, fillPaint(color.withValues(alpha: 0.85)));
        canvas.drawRRect(
          rr,
          strokePaint(p.sky.withValues(alpha: 0.8), box * 0.04),
        );
        canvas.drawLine(
          r.topLeft + Offset(box * 0.16, box * 0.14),
          r.topLeft + Offset(box * 0.16, box * 0.4),
          strokePaint(Colors.white, box * 0.06),
        );
        canvas.drawLine(
          r.topLeft + Offset(box * 0.28, box * 0.14),
          r.topLeft + Offset(box * 0.48, box * 0.14),
          strokePaint(Colors.white, box * 0.06),
        );
      case 'egg':
        final r = Rect.fromCenter(
          center: c,
          width: box * 0.66,
          height: box * 0.86,
        );
        final egg = Path()
          ..moveTo(r.center.dx, r.top)
          ..cubicTo(
            r.right,
            r.top,
            r.right + box * 0.02,
            r.bottom,
            r.center.dx,
            r.bottom,
          )
          ..cubicTo(
            r.left - box * 0.02,
            r.bottom,
            r.left,
            r.top,
            r.center.dx,
            r.top,
          );
        canvas.drawPath(
          egg,
          Paint()
            ..shader = RadialGradient(
              center: const Alignment(-0.3, -0.35),
              colors: [
                Colors.white,
                color,
                Color.lerp(color, Colors.black, 0.15)!,
              ],
              stops: const [0, 0.6, 1],
            ).createShader(r),
        );
      case 'stone':
        final path = Path();
        for (var i = 0; i < 9; i++) {
          final a = i * 2 * math.pi / 9;
          final rad = box * 0.42 * (0.78 + 0.22 * labNoise(i, 11));
          final pt = c + Offset(math.cos(a) * rad, math.sin(a) * rad * 0.85);
          i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
        }
        path.close();
        canvas.drawPath(
          path,
          Paint()
            ..shader = RadialGradient(
              center: const Alignment(-0.3, -0.4),
              colors: [Color.lerp(color, Colors.white, 0.35)!, color],
            ).createShader(Rect.fromCircle(center: c, radius: box * 0.45)),
        );
        for (var i = 0; i < 5; i++) {
          canvas.drawCircle(
            c +
                Offset(
                  (labNoise(i, 12) - 0.5) * box * 0.5,
                  (labNoise(i, 13) - 0.5) * box * 0.4,
                ),
            box * 0.03,
            fillPaint(Color.lerp(color, Colors.black, 0.3)!),
          );
        }
      default:
        drawBall(canvas, c, box * 0.38, color);
    }
  }

  static void _dropGlyph(
    Canvas canvas,
    Offset c,
    double r,
    bool salty,
    LabPalette p,
  ) {
    final path = Path()
      ..moveTo(c.dx, c.dy - r * 1.3)
      ..quadraticBezierTo(
        c.dx + r * 1.05,
        c.dy - r * 0.1,
        c.dx + r * 0.8,
        c.dy + r * 0.45,
      )
      ..arcToPoint(
        Offset(c.dx - r * 0.8, c.dy + r * 0.45),
        radius: Radius.circular(r * 0.85),
      )
      ..quadraticBezierTo(c.dx - r * 1.05, c.dy - r * 0.1, c.dx, c.dy - r * 1.3)
      ..close();
    canvas.drawPath(
      path,
      fillPaint(liquidColor(salty, p).withValues(alpha: 0.85)),
    );
    canvas.drawPath(path, strokePaint(salty ? p.teal : p.blue, r * 0.1));
    if (salty) {
      for (var i = 0; i < 4; i++) {
        canvas.drawRect(
          Rect.fromCenter(
            center:
                c +
                Offset(
                  (labNoise(i, 21) - 0.5) * r,
                  r * 0.1 + (labNoise(i, 22) - 0.3) * r * 0.6,
                ),
            width: r * 0.22,
            height: r * 0.22,
          ),
          fillPaint(Colors.white),
        );
      }
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
    final salty = controls['liquid'] == 'salt_water';
    final surface = size.height * 0.36;
    final water = Rect.fromLTRB(
      size.width * 0.1,
      surface,
      size.width * 0.9,
      size.height * 0.92,
    );
    final box = size.width * 0.42;
    final object = controls['object'] as String;
    final y = outcome == 'float'
        ? surface + box * 0.05
        : water.bottom - box * 0.3;
    drawObject(canvas, Offset(size.width / 2, y), box, object, p);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        water,
        bottomLeft: const Radius.circular(6),
        bottomRight: const Radius.circular(6),
      ),
      fillPaint(liquidColor(salty, p)),
    );
    final arrow = strokePaint(outcome == 'float' ? p.teal : p.coral, 2);
    final x = size.width * 0.82;
    final (from, to) = outcome == 'float'
        ? (surface + 14, surface - 4)
        : (water.bottom - 22, water.bottom - 4);
    canvas.drawLine(Offset(x, from), Offset(x, to), arrow);
    final dir = to < from ? 1 : -1;
    canvas.drawLine(Offset(x, to), Offset(x - 4, to + 4.0 * dir), arrow);
    canvas.drawLine(Offset(x, to), Offset(x + 4, to + 4.0 * dir), arrow);
  }

  @override
  List<LabStat> stats(LabObservation obs, RegionalLanguage lang) => [
    LabStat(Icons.category_rounded, '${obs.values['object_density']} g/cm³'),
    LabStat(Icons.water_drop_rounded, '${obs.values['liquid_density']} g/cm³'),
    if (obs.values['result'] == 'float')
      LabStat(
        Icons.vertical_align_bottom_rounded,
        '${obs.values['underwater_pct']}%',
      ),
  ];

  @override
  String describe(LabScene s) {
    final result = s.result?.values['result'];
    return '${s.c<String>('object')} over a tank of ${s.c<String>('liquid').replaceAll('_', ' ')}. '
        '${result == null ? 'Not dropped yet.' : 'It ${result}s.'}';
  }
}
