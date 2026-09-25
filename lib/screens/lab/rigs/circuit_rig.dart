import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../data/lab/lab_rules.dart';
import '../../../data/lab/lab_words.dart';
import '../../../data/models/regional_language.dart';
import '../lab_kit.dart';

// ─── Circuit: cells push electrons through resistors to light a bulb ─────────

class CircuitRig extends LabRig {
  const CircuitRig();

  @override
  String get id => 'circuit';

  @override
  IconData get icon => Icons.lightbulb_rounded;

  @override
  double get runSeconds => 1.6;

  @override
  List<LabControl> get controls => [
    LabControl(
      key: 'cells',
      icon: Icons.battery_charging_full_rounded,
      caption: (v, _) => '${(v as int) * 1.5} V',
      glyph: (canvas, size, v, p) {
        final n = v as int;
        final w = size.width * 0.22;
        final h = size.height * 0.5;
        final total = n * w + (n - 1) * 3;
        for (var i = 0; i < n; i++) {
          final left = (size.width - total) / 2 + i * (w + 3);
          _cell(
            canvas,
            Rect.fromLTWH(left, (size.height - h) / 2, w, h),
            p,
            vertical: true,
          );
        }
      },
    ),
    LabControl(
      key: 'resistance_ohms',
      icon: Icons.linear_scale_rounded,
      caption: (v, _) => '$v Ω',
      glyph: (canvas, size, v, p) {
        final n = (v as int) ~/ 3;
        final h = size.height * 0.2;
        for (var i = 0; i < n; i++) {
          final top = size.height / 2 - (n * h + (n - 1) * 4) / 2 + i * (h + 4);
          _resistor(
            canvas,
            Rect.fromLTWH(size.width * 0.2, top, size.width * 0.6, h),
            p,
          );
        }
      },
    ),
    LabControl(
      key: 'closed',
      icon: Icons.toggle_on_rounded,
      caption: (v, _) => v == true ? 'ON' : 'OFF',
      glyph: (canvas, size, v, p) => _switch(
        canvas,
        Offset(size.width * 0.2, size.height * 0.62),
        Offset(size.width * 0.8, size.height * 0.62),
        v == true ? 1 : 0,
        p,
        size.width / 40,
      ),
    ),
  ];

  // ─── Layout ────────────────────────────────────────────────────────────

  static Rect _loop(Size size) {
    final w = size.width;
    final h = size.height;
    final side = math.min(w * 0.72, h * 1.05);
    final height = math.min(h * 0.62, side * 0.72);
    return Rect.fromCenter(
      center: Offset(w / 2, h * 0.56),
      width: side,
      height: height,
    );
  }

  static (Offset, Offset) _switchPosts(Rect loop) {
    final y = loop.bottom;
    return (
      Offset(loop.center.dx - loop.width * 0.12, y),
      Offset(loop.center.dx + loop.width * 0.12, y),
    );
  }

  @override
  Map<String, Object>? onStageTap(
    Offset local,
    Size size,
    Map<String, Object> controls,
  ) {
    final (a, b) = _switchPosts(_loop(size));
    final zone = Rect.fromPoints(a, b).inflate(size.shortestSide * 0.1);
    if (!zone.contains(local)) return null;
    return {...controls, 'closed': !(controls['closed'] as bool)};
  }

  @override
  Map<String, Object> previewControls(int cycle) => {
    'cells': [2, 3, 1][cycle % 3],
    'resistance_ohms': [3, 6, 9][cycle % 3],
    'closed': true,
  };

  // ─── Paint ─────────────────────────────────────────────────────────────

  @override
  void paint(Canvas canvas, Size size, LabScene s) {
    final p = s.p;
    final loop = _loop(size);
    final u = loop.width / 100;
    final cells = s.c<int>('cells');
    final resistors = s.c<int>('resistance_ohms') ~/ 3;
    final closed = s.c<bool>('closed');
    final current = (s.result?.values['current_a'] as num?)?.toDouble() ?? 0;
    final flow = s.seg(0.1, 0.9);
    final power = s.ran && closed ? easeOut(flow) : 0.0;

    // Glow behind the bulb.
    final bulb = Offset(loop.center.dx, loop.top);
    // Even a dim bulb glows visibly; brightness climbs with current.
    final lit = current <= 0
        ? 0.0
        : (0.3 + 0.7 * (current / 1.2).clamp(0.0, 1.0)) * power;
    final flicker = current < kBrightCurrentA
        ? 0.9 + 0.1 * math.sin(s.t * 23)
        : 1.0;
    drawGlow(canvas, bulb, u * (26 + 46 * lit), p.glow, lit * flicker);

    // Wire loop with gaps for the components.
    final wire = strokePaint(p.ink2, u * 1.6);
    final rrect = RRect.fromRectAndRadius(loop, Radius.circular(u * 8));
    final path = Path()..addRRect(rrect);
    canvas.drawPath(path, wire);

    // Electrons around the loop.
    if (power > 0) {
      final metric = path.computeMetrics().first;
      final count = s.preview ? 14 : 22;
      final speed = 18 + 90 * current;
      final spacing = metric.length / count;
      for (var i = 0; i < count; i++) {
        final d = (i * spacing + s.t * speed * u / 2) % metric.length;
        final pos = metric.getTangentForOffset(d)?.position;
        if (pos == null) continue;
        drawGlow(canvas, pos, u * 3.4, p.sky, 0.55 * power);
        canvas.drawCircle(pos, u * 1.2, fillPaint(p.sky));
      }
    }

    // Battery pack on the left.
    final cellH = u * 13;
    final cellW = u * 9;
    final packH = cells * cellH + (cells - 1) * u * 1.5;
    final packTop = loop.center.dy - packH / 2;
    for (var i = 0; i < cells; i++) {
      final top = packTop + i * (cellH + u * 1.5);
      _cell(
        canvas,
        Rect.fromLTWH(loop.left - cellW / 2, top, cellW, cellH),
        p,
        vertical: true,
      );
    }
    if (!s.preview) {
      drawTag(
        canvas,
        '${cells * 1.5} V',
        Offset(loop.left, packTop - u * 6),
        p.gold,
        size: u * 4.2,
        background: p.surface,
      );
    }

    // Resistors on the right.
    final resH = u * 7;
    final resW = u * 16;
    final stackH = resistors * resH + (resistors - 1) * u * 3;
    final resTop = loop.center.dy - stackH / 2;
    for (var i = 0; i < resistors; i++) {
      final top = resTop + i * (resH + u * 3);
      canvas.save();
      canvas.translate(loop.right, top + resH / 2);
      canvas.rotate(math.pi / 2);
      _resistor(
        canvas,
        Rect.fromCenter(center: Offset.zero, width: resW, height: resH),
        p,
      );
      canvas.restore();
      if (i < resistors - 1) {
        canvas.drawLine(
          Offset(loop.right, top + resH),
          Offset(loop.right, top + resH + u * 3),
          wire,
        );
      }
    }
    if (!s.preview) {
      drawTag(
        canvas,
        '${resistors * 3} Ω',
        Offset(loop.right + u * 12, loop.center.dy),
        p.amber,
        size: u * 4.2,
        background: p.surface,
      );
    }

    // Switch at the bottom — its lever swings when toggled.
    final (a, b) = _switchPosts(loop);
    canvas.drawLine(a, b, strokePaint(p.surface, u * 2.4));
    final wasClosed = s.previous['closed'] as bool? ?? closed;
    final k = s.changed(0.35);
    final from = wasClosed ? 1.0 : 0.0;
    final to = closed ? 1.0 : 0.0;
    _switch(canvas, a, b, from + (to - from) * k, p, u);
    if (!s.ran && !s.preview) {
      // A gentle pulse invites a tap on the switch.
      final pulse = (s.t * 0.8) % 1;
      canvas.drawCircle(
        Offset.lerp(a, b, 0.5)!,
        u * (6 + 10 * pulse),
        strokePaint(p.green.withValues(alpha: 0.5 * (1 - pulse)), u * 0.8),
      );
    }

    // Bulb on top.
    _bulb(canvas, bulb, u * 11, lit, p, question: !s.ran && !s.preview);

    // Rays when bright.
    if (lit > 0.3) {
      final rays = strokePaint(p.glow.withValues(alpha: lit), u * 1.3);
      for (var i = 0; i < 10; i++) {
        final a = s.t * 0.4 + i * math.pi / 5;
        if (math.sin(a) > 0.35) continue; // keep rays above the wire
        final dir = Offset(math.cos(a), math.sin(a));
        canvas.drawLine(
          bulb + dir * u * (16 + 2 * math.sin(s.t * 4 + i)),
          bulb + dir * u * (16 + 10 * lit),
          rays,
        );
      }
    }
  }

  // ─── Parts ─────────────────────────────────────────────────────────────

  static void _cell(
    Canvas canvas,
    Rect r,
    LabPalette p, {
    bool vertical = false,
  }) {
    final body = RRect.fromRectAndRadius(
      r,
      Radius.circular(r.shortestSide * 0.25),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Color.lerp(p.gold, Colors.white, 0.35)!,
            p.gold,
            Color.lerp(p.gold, Colors.black, 0.25)!,
          ],
        ).createShader(r),
    );
    // Dark band at the negative end, nub at the positive end.
    final band = Rect.fromLTWH(
      r.left,
      r.bottom - r.height * 0.3,
      r.width,
      r.height * 0.3,
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        band,
        bottomLeft: Radius.circular(r.shortestSide * 0.25),
        bottomRight: Radius.circular(r.shortestSide * 0.25),
      ),
      fillPaint(p.ink.withValues(alpha: 0.85)),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(r.center.dx, r.top - r.height * 0.05),
          width: r.width * 0.4,
          height: r.height * 0.12,
        ),
        Radius.circular(r.width * 0.1),
      ),
      fillPaint(p.metal),
    );
  }

  static void _resistor(Canvas canvas, Rect r, LabPalette p) {
    final body = RRect.fromRectAndRadius(r, Radius.circular(r.height / 2));
    canvas.drawRRect(
      body,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(p.amber, Colors.white, 0.45)!,
            Color.lerp(p.amber, Colors.white, 0.1)!,
          ],
        ).createShader(r),
    );
    final bands = [p.coral, p.violet, p.ink];
    for (var i = 0; i < 3; i++) {
      final x = r.left + r.width * (0.28 + i * 0.18);
      canvas.drawRect(
        Rect.fromLTWH(x, r.top, r.width * 0.08, r.height),
        fillPaint(bands[i]),
      );
    }
  }

  /// [k] is 0 for open, 1 for closed.
  static void _switch(
    Canvas canvas,
    Offset a,
    Offset b,
    double k,
    LabPalette p,
    double u,
  ) {
    final lever = (b - a).distance;
    final angle = -0.6 * (1 - k);
    final tip = a + Offset(math.cos(angle), math.sin(angle)) * lever;
    canvas.drawLine(a, tip, strokePaint(k > 0.95 ? p.green : p.coral, u * 2));
    for (final post in [a, b]) {
      canvas.drawCircle(post, u * 2.2, fillPaint(p.ink2));
      canvas.drawCircle(post, u * 1.1, fillPaint(p.surface));
    }
  }

  static void _bulb(
    Canvas canvas,
    Offset c,
    double r,
    double lit,
    LabPalette p, {
    bool question = false,
  }) {
    // Screw base.
    final base = Rect.fromCenter(
      center: c + Offset(0, r * 1.05),
      width: r * 0.95,
      height: r * 0.7,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(base, Radius.circular(r * 0.15)),
      fillPaint(p.metal),
    );
    for (var i = 1; i < 3; i++) {
      final y = base.top + base.height * i / 3;
      canvas.drawLine(
        Offset(base.left, y),
        Offset(base.right, y),
        strokePaint(p.ink2.withValues(alpha: 0.6), r * 0.06),
      );
    }
    // Glass.
    final glass = Color.lerp(p.surface3, p.glow, lit)!;
    canvas.drawCircle(c, r, fillPaint(glass));
    canvas.drawCircle(c, r, strokePaint(p.glass, r * 0.1));
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r * 0.7),
      math.pi * 1.1,
      math.pi * 0.35,
      false,
      strokePaint(Colors.white.withValues(alpha: 0.7), r * 0.12),
    );
    // Filament.
    final filament = Path()..moveTo(c.dx - r * 0.35, c.dy + r * 0.55);
    filament.lineTo(c.dx - r * 0.35, c.dy);
    for (var i = 0; i < 4; i++) {
      filament.lineTo(
        c.dx - r * 0.35 + r * 0.7 * (i + 0.5) / 4,
        c.dy + (i.isEven ? -r * 0.18 : r * 0.05),
      );
    }
    filament.lineTo(c.dx + r * 0.35, c.dy);
    filament.lineTo(c.dx + r * 0.35, c.dy + r * 0.55);
    canvas.drawPath(
      filament,
      strokePaint(
        Color.lerp(p.ink3, Colors.white, lit)!,
        r * (0.08 + 0.06 * lit),
      ),
    );
    if (question) {
      drawTag(canvas, '?', c - Offset(0, r * 0.35), p.ink2, size: r * 0.8);
    }
  }

  // ─── Prediction glyphs ─────────────────────────────────────────────────

  @override
  void paintOutcome(
    Canvas canvas,
    Size size,
    String outcome,
    Map<String, Object> controls,
    LabPalette p,
  ) {
    final c = Offset(size.width / 2, size.height * 0.44);
    final r = size.shortestSide * 0.24;
    final lit = switch (outcome) {
      'bright' => 1.0,
      'dim' => 0.35,
      _ => 0.0,
    };
    drawGlow(canvas, c, r * (1.4 + 1.6 * lit), p.glow, lit);
    _bulb(canvas, c, r, lit, p);
    if (lit == 1) {
      final rays = strokePaint(p.glow, r * 0.12);
      for (var i = 0; i < 7; i++) {
        final a = math.pi + i * math.pi / 6;
        final dir = Offset(math.cos(a), math.sin(a));
        canvas.drawLine(c + dir * r * 1.3, c + dir * r * 1.75, rays);
      }
    }
  }

  @override
  List<LabStat> stats(LabObservation obs, RegionalLanguage lang) => [
    LabStat(Icons.bolt_rounded, '${obs.values['voltage_v']} V'),
    LabStat(Icons.waves_rounded, '${obs.values['current_a']} A'),
    LabStat(
      Icons.lightbulb_rounded,
      labWord(obs.values['brightness'] as String, lang),
    ),
  ];

  @override
  String describe(LabScene s) {
    final cells = s.c<int>('cells');
    final brightness = s.result?.values['brightness'];
    return 'Circuit with $cells cell${cells == 1 ? '' : 's'}, '
        '${s.c<int>('resistance_ohms')} ohm resistance and '
        '${s.c<bool>('closed') ? 'a closed' : 'an open'} switch. '
        '${brightness == null ? 'Bulb not tested yet.' : 'Bulb is $brightness.'}';
  }
}
