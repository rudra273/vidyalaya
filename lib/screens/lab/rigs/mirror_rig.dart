import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../data/lab/lab_rules.dart';
import '../../../data/models/regional_language.dart';
import '../lab_kit.dart';

// ─── Plane mirror: angle in = angle out, shown with a laser and stars ────────

class MirrorRig extends LabRig {
  const MirrorRig();

  @override
  String get id => 'mirror';

  @override
  IconData get icon => Icons.flare_rounded;

  @override
  double get runSeconds => 1.7;

  static Color starColor(String target, LabPalette p) => switch (target) {
    'high' => p.violet,
    'middle' => p.gold,
    _ => p.coral,
  };

  @override
  List<LabControl> get controls => [
    LabControl(
      key: 'angle_deg',
      icon: Icons.architecture_rounded,
      caption: (v, _) => '$v°',
      glyph: (canvas, size, v, p) {
        final hit = Offset(size.width * 0.62, size.height * 0.82);
        final a = (v as int) * math.pi / 180;
        final from =
            hit + Offset(-math.sin(a), -math.cos(a)) * size.height * 0.62;
        canvas.drawLine(
          Offset(size.width * 0.1, hit.dy),
          Offset(size.width * 0.9, hit.dy),
          strokePaint(p.metal, 2.5),
        );
        drawDashed(
          canvas,
          hit,
          hit - Offset(0, size.height * 0.6),
          strokePaint(p.ink3, 1),
          dash: 3,
          gap: 3,
        );
        canvas.drawLine(from, hit, strokePaint(p.green, 2.4));
        canvas.drawArc(
          Rect.fromCircle(center: hit, radius: size.height * 0.26),
          -math.pi / 2 - a,
          a,
          false,
          strokePaint(p.sky, 1.6),
        );
      },
    ),
  ];

  @override
  Map<String, Object> previewControls(int cycle) => {
    'angle_deg': [45, 30, 60][cycle % 3],
  };

  // ─── Layout ────────────────────────────────────────────────────────────

  static ({Offset hit, double reach, double mirrorY}) _layout(Size size) {
    final mirrorY = size.height * 0.84;
    final reach = math.min(
      size.width * 0.44 / math.sin(math.pi / 3),
      size.height * 0.7,
    );
    return (
      hit: Offset(size.width / 2, mirrorY),
      reach: reach,
      mirrorY: mirrorY,
    );
  }

  static Offset _dir(double deg, {required bool incoming}) {
    final a = deg * math.pi / 180;
    return Offset(incoming ? -math.sin(a) : math.sin(a), -math.cos(a));
  }

  @override
  void paint(Canvas canvas, Size size, LabScene s) {
    final p = s.p;
    final w = size.width;
    final u = math.min(w, size.height) / 100;
    final (:hit, :reach, :mirrorY) = _layout(size);
    final angle = s.lerpControl('angle_deg', 0.45);
    final target = s.result?.values['target'] as String?;

    // Normal.
    drawDashed(
      canvas,
      hit,
      hit - Offset(0, reach * 0.85),
      strokePaint(p.ink3.withValues(alpha: 0.6), u * 0.6),
      dash: u * 2.5,
      gap: u * 2,
    );

    // Targets.
    final hitAt = s.seg(1.0, 1.7);
    for (final entry in kMirrorTargets.entries) {
      final pos =
          hit + _dir(entry.key.toDouble(), incoming: false) * reach * 0.92;
      final isHit = target == entry.value && hitAt > 0;
      final bob = s.ran ? 0.0 : math.sin(s.t * 2 + entry.key) * u * 1.2;
      final color = starColor(entry.value, p);
      final scale = isHit ? 1 + 0.5 * elastic(hitAt) : 1.0;
      final fade = s.ran && target != entry.value && s.runT > 1.0 ? 0.35 : 1.0;
      final center = pos + Offset(0, bob);
      if (isHit) {
        drawGlow(canvas, center, u * 22 * scale, color, hitAt);
        final ring = hitAt < 1 ? hitAt : (s.t * 0.7) % 1;
        canvas.drawCircle(
          center,
          u * (8 + 16 * ring),
          strokePaint(color.withValues(alpha: 1 - ring), u * 1.2),
        );
      }
      canvas.drawPath(
        starPath(center, u * 7 * scale, 0.45, isHit ? s.t * 0.8 : 0),
        fillPaint(color.withValues(alpha: fade)),
      );
      if (!s.ran && !s.preview) {
        drawTag(
          canvas,
          '?',
          center + Offset(0, u * 0.8),
          Colors.white,
          size: u * 5,
        );
      }
    }

    // Mirror, silvered front and hatched back.
    final mirror = Rect.fromLTRB(
      w * 0.1,
      mirrorY - u * 1.4,
      w * 0.9,
      mirrorY + u * 1.4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(mirror, Radius.circular(u)),
      Paint()
        ..shader = LinearGradient(
          colors: [p.metal, Colors.white.withValues(alpha: 0.9), p.metal],
        ).createShader(mirror),
    );
    final hatch = strokePaint(p.ink3.withValues(alpha: 0.6), u * 0.5);
    for (var x = mirror.left + u * 2; x < mirror.right; x += u * 4) {
      canvas.drawLine(
        Offset(x, mirror.bottom),
        Offset(x - u * 3, mirror.bottom + u * 3.5),
        hatch,
      );
    }

    // Laser torch, swivelling to the chosen angle.
    final inDir = _dir(angle, incoming: true);
    final torch = hit + inDir * reach;
    final beamStart = hit + inDir * (reach - u * 8);

    if (!s.ran) {
      drawDashed(
        canvas,
        beamStart,
        hit,
        strokePaint(p.green.withValues(alpha: 0.45), u * 0.8),
        dash: u * 2,
        gap: u * 2.5,
        phase: -s.t * u * 12,
      );
    } else {
      final inK = easeInOut(s.seg(0, 0.55));
      final outK = easeInOut(s.seg(0.5, 1.05));
      final outEnd = target == null
          ? hit
          : hit +
                _dir(s.c<int>('angle_deg').toDouble(), incoming: false) *
                    reach *
                    0.92;
      _beam(canvas, beamStart, Offset.lerp(beamStart, hit, inK)!, p, u);
      if (outK > 0) _beam(canvas, hit, Offset.lerp(hit, outEnd, outK)!, p, u);
      if (inK >= 1) {
        drawGlow(canvas, hit, u * 9, Colors.white, 0.9);
        drawGlow(canvas, hit, u * 14, p.green, 0.8);
      }
      // Light pulses running along the path once it is drawn.
      if (outK >= 1) {
        final l1 = (hit - beamStart).distance;
        final l2 = (outEnd - hit).distance;
        for (var i = 0; i < 4; i++) {
          final d = ((s.t * 0.6 + i / 4) % 1) * (l1 + l2);
          final pos = d < l1
              ? Offset.lerp(beamStart, hit, d / l1)!
              : Offset.lerp(hit, outEnd, (d - l1) / l2)!;
          drawGlow(canvas, pos, u * 4, Colors.white, 0.9);
        }
      }
      // Equal angles, drawn once the beam lands.
      final arcs = s.seg(1.1, 1.6);
      if (arcs > 0 && !s.preview) {
        final a = s.c<int>('angle_deg') * math.pi / 180;
        final r = reach * 0.22;
        final rect = Rect.fromCircle(center: hit, radius: r);
        canvas.drawArc(
          rect,
          -math.pi / 2,
          -a * arcs,
          false,
          strokePaint(p.sky, u * 1.2),
        );
        canvas.drawArc(
          rect,
          -math.pi / 2,
          a * arcs,
          false,
          strokePaint(p.sky, u * 1.2),
        );
        final label = '${s.c<int>('angle_deg')}°';
        for (final sign in [-1, 1]) {
          final mid = -math.pi / 2 + sign * a / 2;
          drawTag(
            canvas,
            label,
            hit + Offset(math.cos(mid), math.sin(mid)) * (r + u * 7),
            p.sky,
            size: u * 4.2,
            background: p.surface.withValues(alpha: arcs),
          );
        }
      }
    }

    canvas.save();
    canvas.translate(torch.dx, torch.dy);
    canvas.rotate(math.atan2(-inDir.dy, -inDir.dx));
    final body = RRect.fromRectAndRadius(
      Rect.fromLTRB(-u * 9, -u * 3.6, u * 9, u * 3.6),
      Radius.circular(u * 2),
    );
    canvas.drawRRect(body, fillPaint(p.ink2));
    canvas.drawRect(
      Rect.fromLTRB(u * 6, -u * 3.6, u * 9, u * 3.6),
      fillPaint(p.green),
    );
    canvas.drawCircle(Offset(-u * 3, 0), u * 1.4, fillPaint(p.coral));
    canvas.restore();
  }

  static void _beam(Canvas canvas, Offset a, Offset b, LabPalette p, double u) {
    canvas.drawLine(a, b, strokePaint(p.green.withValues(alpha: 0.25), u * 5));
    canvas.drawLine(a, b, strokePaint(p.green, u * 1.8));
    canvas.drawLine(
      a,
      b,
      strokePaint(Colors.white.withValues(alpha: 0.8), u * 0.6),
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
    final hit = Offset(size.width * 0.3, size.height * 0.85);
    canvas.drawLine(
      Offset(size.width * 0.08, hit.dy),
      Offset(size.width * 0.92, hit.dy),
      strokePaint(p.metal, 2.5),
    );
    for (final entry in kMirrorTargets.entries) {
      final pos =
          hit +
          _dir(entry.key.toDouble(), incoming: false) * size.height * 0.72;
      final mine = entry.value == outcome;
      canvas.drawPath(
        starPath(pos, size.width * (mine ? 0.15 : 0.07)),
        fillPaint(
          mine ? starColor(entry.value, p) : p.ink3.withValues(alpha: 0.35),
        ),
      );
    }
  }

  @override
  List<LabStat> stats(LabObservation obs, RegionalLanguage lang) => [
    LabStat(Icons.south_east_rounded, 'i = ${obs.values['incidence_deg']}°'),
    LabStat(Icons.north_east_rounded, 'r = ${obs.values['reflection_deg']}°'),
  ];

  @override
  String describe(LabScene s) {
    final target = s.result?.values['target'];
    return 'Laser aimed at a plane mirror at ${s.c<int>('angle_deg')} degrees. '
        '${target == null ? 'Beam not fired yet.' : 'The beam hits the $target star.'}';
  }
}
