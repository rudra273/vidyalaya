import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/pressable.dart';
import 'lab_kit.dart';

// ─── Lab widgets ──────────────────────────────────────────────────────────────
//
// Small building blocks shared by the lab hub and the bench: picture tokens,
// token strips, stars, the graph-paper bench and a confetti burst.

// ─── Token: a tappable picture with a short caption ──────────────────────────

class LabToken extends StatelessWidget {
  final void Function(Canvas canvas, Size size) glyph;
  final Object signature;
  final String caption;
  final bool selected;
  final bool dimmed;
  final Color accent;
  final VoidCallback? onTap;
  final double size;
  final String? semanticsLabel;

  const LabToken({
    super.key,
    required this.glyph,
    required this.signature,
    required this.caption,
    required this.selected,
    required this.accent,
    this.dimmed = false,
    this.onTap,
    this.size = 62,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final reduce = MediaQuery.disableAnimationsOf(context);
    final duration = reduce ? Duration.zero : const Duration(milliseconds: 260);
    return Semantics(
      button: true,
      selected: selected,
      label: semanticsLabel ?? caption,
      child: Pressable(
        onTap: onTap,
        scale: 0.9,
        child: AnimatedOpacity(
          duration: duration,
          opacity: dimmed ? 0.45 : 1,
          child: SizedBox(
            width: size + 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  duration: duration,
                  curve: Curves.easeOutBack,
                  scale: selected ? 1.06 : 1,
                  child: AnimatedContainer(
                    duration: duration,
                    width: size,
                    height: size,
                    padding: EdgeInsets.all(size * 0.1),
                    decoration: BoxDecoration(
                      color: selected
                          ? Color.alphaBlend(
                              accent.withValues(alpha: 0.16),
                              cs.surface,
                            )
                          : cs.surface,
                      borderRadius: BorderRadius.circular(size * 0.3),
                      border: Border.all(
                        color: selected ? accent : cs.outlineVariant,
                        width: selected ? 2.4 : 1,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: accent.withValues(alpha: 0.3),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ]
                          : null,
                    ),
                    child: CustomPaint(
                      painter: LabGlyphPainter(glyph, signature),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFontSize.small,
                    fontWeight: selected
                        ? AppFontWeight.bold
                        : AppFontWeight.medium,
                    color: selected ? accent : cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Strip: a leading badge and a scrolling row of tokens ────────────────────

class LabStrip extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final List<Widget> tokens;
  final String semanticsLabel;

  const LabStrip({
    super.key,
    required this.icon,
    required this.accent,
    required this.tokens,
    required this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: semanticsLabel,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: LabBadge(icon: icon, color: accent),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 6),
              clipBehavior: Clip.none,
              child: Row(children: tokens),
            ),
          ),
        ],
      ),
    );
  }
}

class LabBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const LabBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 34,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color.lerp(color, Colors.white, 0.25)!, color],
      ),
    ),
    child: Icon(icon, color: Colors.white, size: size * 0.55),
  );
}

// ─── Stars ────────────────────────────────────────────────────────────────────

class LabStars extends StatelessWidget {
  final int earned;
  final double size;
  final Color color;

  const LabStars({
    super.key,
    required this.earned,
    required this.color,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    final off = Theme.of(context).colorScheme.outlineVariant;
    return Semantics(
      label: '$earned of 3 stars',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++)
            Icon(
              i < earned ? Icons.star_rounded : Icons.star_outline_rounded,
              size: size,
              color: i < earned ? color : off,
            ),
        ],
      ),
    );
  }
}

// ─── Bench backdrop: graph paper with a table edge ───────────────────────────

class LabBenchPainter extends CustomPainter {
  final Color accent;
  final LabPalette p;

  const LabBenchPainter({required this.accent, required this.p});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.alphaBlend(
              accent.withValues(alpha: p.dark ? 0.16 : 0.10),
              p.surface,
            ),
            p.surface,
          ],
        ).createShader(rect),
    );
    final grid = Paint()
      ..color = accent.withValues(alpha: p.dark ? 0.08 : 0.07)
      ..strokeWidth = 1;
    const step = 22.0;
    for (var x = step; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = step; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    // Soft spotlight behind the apparatus.
    drawGlow(
      canvas,
      Offset(size.width / 2, size.height * 0.5),
      size.shortestSide * 0.7,
      Colors.white,
      p.dark ? 0.05 : 0.5,
    );
  }

  @override
  bool shouldRepaint(LabBenchPainter old) =>
      old.accent != accent || old.p.dark != p.dark;
}

// ─── Confetti ─────────────────────────────────────────────────────────────────

class LabConfettiPainter extends CustomPainter {
  final ValueListenable<double> clock;
  final double startedAt;
  final List<Color> colors;

  static const seconds = 1.8;

  LabConfettiPainter({
    required this.clock,
    required this.startedAt,
    required this.colors,
  }) : super(repaint: clock);

  @override
  void paint(Canvas canvas, Size size) {
    final t = clock.value - startedAt;
    if (t < 0 || t > seconds) return;
    final origin = Offset(size.width / 2, size.height * 0.35);
    final fade = 1 - (t / seconds);
    for (var i = 0; i < 48; i++) {
      final a = labNoise(i, 71) * 2 * math.pi;
      final speed = size.shortestSide * (0.5 + labNoise(i, 72) * 0.9);
      final pos =
          origin +
          Offset(math.cos(a), math.sin(a) - 0.6) * speed * t +
          Offset(0, 0.5 * size.height * 1.4 * t * t);
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(t * (4 + labNoise(i, 73) * 8));
      final color = colors[i % colors.length].withValues(alpha: fade);
      if (i % 3 == 0) {
        canvas.drawCircle(Offset.zero, 3.5, fillPaint(color));
      } else {
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: 9, height: 5),
          fillPaint(color),
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(LabConfettiPainter old) => old.startedAt != startedAt;
}

// ─── Floating bubbles for the hub hero ───────────────────────────────────────

class LabBubblesPainter extends CustomPainter {
  final ValueListenable<double> clock;
  final List<Color> colors;

  LabBubblesPainter({required this.clock, required this.colors})
    : super(repaint: clock);

  @override
  void paint(Canvas canvas, Size size) {
    final t = clock.value;
    for (var i = 0; i < 18; i++) {
      final life = (t * (0.04 + labNoise(i, 81) * 0.05) + labNoise(i, 82)) % 1;
      final x = size.width * labNoise(i, 83) + math.sin(t * 0.8 + i) * 10;
      final y = size.height * (1.1 - life * 1.3);
      final r = 4 + labNoise(i, 84) * 12;
      final color = colors[i % colors.length];
      canvas.drawCircle(
        Offset(x, y),
        r,
        fillPaint(color.withValues(alpha: 0.16)),
      );
      canvas.drawCircle(
        Offset(x, y),
        r,
        strokePaint(color.withValues(alpha: 0.45), 1.2),
      );
    }
    // An atom orbiting in the corner.
    final atom = Offset(size.width * 0.84, size.height * 0.42);
    final orbit = strokePaint(Colors.white.withValues(alpha: 0.35), 1.4);
    for (var k = 0; k < 3; k++) {
      canvas.save();
      canvas.translate(atom.dx, atom.dy);
      canvas.rotate(k * math.pi / 3);
      final rect = Rect.fromCenter(center: Offset.zero, width: 92, height: 32);
      canvas.drawOval(rect, orbit);
      final a = t * (1.4 + k * 0.3) + k * 2;
      canvas.drawCircle(
        Offset(math.cos(a) * 46, math.sin(a) * 16),
        4,
        fillPaint(colors[k % colors.length]),
      );
      canvas.restore();
    }
    drawBall(canvas, atom, 9, colors.first);
  }

  @override
  bool shouldRepaint(LabBubblesPainter old) => false;
}
