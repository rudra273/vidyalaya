import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../data/models/answer_style.dart';
import 'pressable.dart';

// ─── AI entry heroes ──────────────────────────────────────────────────────
// Two deliberately different skins of the same call to action, so Home's
// banner and the AI tab's header never read as the same card:
//
//   HomeAskHero — tall dark-green card with a faint study-glyph backdrop. The
//                 brand moment on Home.
//   AiAskHero   — short light card with an answer-style switch. A working
//                 header, kept compact so the sections under it stay visible.
//
// In both, the action is a filled button, never a text-field lookalike —
// students were not recognising the faux input bar these replaced.

// ═══════════════════════════════════════════════════════════════════════════
// Home — dark hero with study glyphs
// ═══════════════════════════════════════════════════════════════════════════

class HomeAskHero extends StatelessWidget {
  final String headline;
  final String sub;
  final VoidCallback onAsk;
  final VoidCallback onCamera;

  /// Last question the student asked, for the "continue" pill. Null hides the
  /// pill entirely — a first-time student sees the plain hero.
  final String? resumeLabel;

  /// Tapped when the resume pill is shown. Required whenever [resumeLabel] is
  /// non-null.
  final VoidCallback? onResume;

  const HomeAskHero({
    super.key,
    required this.headline,
    required this.sub,
    required this.onAsk,
    required this.onCamera,
    this.resumeLabel,
    this.onResume,
  }) : assert(
         resumeLabel == null || onResume != null,
         'onResume is required when resumeLabel is set',
       );

  /// Floor height. The card grows past this if the student runs a large text
  /// scale — the Stack is bottom-aligned, so nothing clips.
  static const double _minHeight = 208;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final heroColor = isDark ? AppColors.heroDark : AppColors.hero;
    final hero2 = isDark ? AppColors.hero2Dark : AppColors.hero2;
    final accent = isDark ? AppColors.green500Dark : AppColors.green500;
    const inkLight = AppColors.heroInk;
    final inkMuted = AppColors.heroInk.withValues(alpha: 0.62);

    return Container(
      clipBehavior: Clip.antiAlias,
      constraints: const BoxConstraints(minHeight: _minHeight),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0.95, -0.8),
          radius: 1.3,
          colors: [hero2, heroColor],
        ),
        border: Border.all(
          color: isDark ? AppColors.heroLineDark : AppColors.heroLine,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Positioned.fill(
            child: IgnorePointer(child: _StudyGlyphBackdrop(accent: accent)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 15, color: accent),
                    const SizedBox(width: 7),
                    Text(
                      'ASK · Q&A',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: inkMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  headline,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: inkLight,
                    fontSize: 25,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  sub,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: inkMuted),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _AskButton(label: 'Ask a question', onTap: onAsk),
                    ),
                    const SizedBox(width: 10),
                    _HeroIconButton(
                      icon: Icons.photo_camera_rounded,
                      tooltip: 'Snap a photo of a question',
                      onTap: onCamera,
                    ),
                  ],
                ),
                if (resumeLabel != null) ...[
                  const SizedBox(height: 12),
                  _ResumePill(
                    label: resumeLabel!,
                    accent: accent,
                    onTap: onResume!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The dark hero's backdrop: oversized subject glyphs at a whisper of opacity,
/// a diagonal sheen and one small atom motif. All painted, no image assets.
class _StudyGlyphBackdrop extends StatelessWidget {
  final Color accent;

  const _StudyGlyphBackdrop({required this.accent});

  @override
  Widget build(BuildContext context) {
    final serif = Theme.of(context).textTheme.displayLarge?.fontFamily;
    final glyphColor = Colors.white.withValues(alpha: 0.07);

    Widget glyph(String char, double size, double angle) {
      return Transform.rotate(
        angle: angle * math.pi / 180,
        child: Text(
          char,
          style: TextStyle(
            fontFamily: serif,
            fontSize: size,
            height: 1,
            fontWeight: FontWeight.w600,
            color: glyphColor,
          ),
        ),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Diagonal wash of brand green from the top-right.
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [accent.withValues(alpha: 0.16), Colors.transparent],
                stops: const [0.0, 0.55],
              ),
            ),
          ),
        ),
        Positioned(top: -8, right: 12, child: glyph('π', 76, 8)),
        Positioned(top: 18, right: 92, child: glyph('∑', 44, -12)),
        Positioned(bottom: 4, right: 52, child: glyph('√', 40, 6)),
        Positioned(bottom: -10, right: 144, child: glyph('अ', 52, -6)),
        Positioned(top: -14, right: 128, child: glyph('ଓ', 34, 14)),
        Positioned(
          right: 78,
          bottom: 38,
          child: SizedBox(
            width: 64,
            height: 64,
            child: CustomPaint(painter: _AtomPainter(color: glyphColor)),
          ),
        ),
      ],
    );
  }
}

/// Nucleus + two crossed orbits — the "study" motif on the dark hero.
class _AtomPainter extends CustomPainter {
  final Color color;

  const _AtomPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = color;

    canvas.drawCircle(center, size.width * 0.22, paint);

    final orbit = Rect.fromCenter(
      center: Offset.zero,
      width: size.width,
      height: size.height * 0.36,
    );
    for (final degrees in [-30.0, 30.0]) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(degrees * math.pi / 180);
      canvas.drawOval(orbit, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_AtomPainter oldDelegate) => oldDelegate.color != color;
}

/// `Continue: <last question>` — a quiet outlined row under the hero's buttons.
/// Deliberately not a second filled button: asking something new stays the
/// primary action, and this is the shortcut for students already mid-topic.
class _ResumePill extends StatelessWidget {
  final String label;
  final Color accent;
  final VoidCallback onTap;

  const _ResumePill({
    required this.label,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ink = AppColors.heroInk.withValues(alpha: 0.86);

    return Pressable(
      onTap: onTap,
      scale: 0.98,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(
          children: [
            Icon(Icons.history_rounded, size: 15, color: accent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ink,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.arrow_forward_rounded,
              size: 15,
              color: AppColors.heroInk.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// AI tab — compact light hero with an answer-style switch
// ═══════════════════════════════════════════════════════════════════════════

class AiAskHero extends StatefulWidget {
  final String headline;
  final String sub;

  /// Called with the answer style selected on the switch, so the chat can pitch
  /// its first reply accordingly.
  final ValueChanged<AnswerStyle> onAsk;
  final VoidCallback onCamera;

  const AiAskHero({
    super.key,
    required this.headline,
    required this.sub,
    required this.onAsk,
    required this.onCamera,
  });

  @override
  State<AiAskHero> createState() => _AiAskHeroState();
}

class _AiAskHeroState extends State<AiAskHero> {
  AnswerStyle _style = AnswerStyle.ask;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = isDark ? AppColors.green50Dark : AppColors.green50;
    final muted = isDark ? AppColors.ink2Dark : AppColors.ink2;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.7, -1),
          radius: 1.25,
          colors: [tint, cs.surface],
        ),
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -58,
            bottom: -86,
            child: IgnorePointer(
              child: SizedBox(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: _DottedArcPainter(
                    color: cs.primary.withValues(alpha: isDark ? 0.22 : 0.16),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _StyleSwitch(
                  selected: _style,
                  onChanged: (style) => setState(() => _style = style),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const _AiMark(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.headline,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontSize: 16.5, height: 1.2),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.sub,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontSize: 11.5, color: muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _AskButton(
                        label: _askLabel(_style),
                        height: 44,
                        onTap: () => widget.onAsk(_style),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _LightIconButton(
                      icon: Icons.photo_camera_rounded,
                      tooltip: 'Snap a photo of a question',
                      onTap: widget.onCamera,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The button label restates the chosen style, so the switch has a visible
/// consequence before the student even taps through.
String _askLabel(AnswerStyle style) {
  return switch (style) {
    AnswerStyle.ask => 'Ask a question',
    AnswerStyle.simple => 'Ask, explain simply',
    AnswerStyle.steps => 'Ask, step by step',
  };
}

/// Ask / Explain simply / Step by step — sets how the next answer is pitched.
class _StyleSwitch extends StatelessWidget {
  final AnswerStyle selected;
  final ValueChanged<AnswerStyle> onChanged;

  const _StyleSwitch({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark ? AppColors.surface3Dark : AppColors.surface3;
    final idleInk = isDark ? AppColors.ink3Dark : AppColors.ink3;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          for (final style in AnswerStyle.values)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(style),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: style == selected ? cs.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      style.label,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: style == selected ? cs.onSurface : idleInk,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The little gradient sparkle mark that stands in for the assistant.
class _AiMark extends StatelessWidget {
  const _AiMark();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [AppColors.green500Dark, AppColors.green700Dark]
              : const [AppColors.green500, AppColors.green700],
        ),
        borderRadius: BorderRadius.circular(13),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.auto_awesome_rounded,
        size: 19,
        color: isDark ? AppColors.onGreenDark : Colors.white,
      ),
    );
  }
}

/// Concentric dotted arcs behind the light hero.
class _DottedArcPainter extends CustomPainter {
  final Color color;

  const _DottedArcPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = color;

    for (final radius in [size.width * 0.24, size.width * 0.37, size.width * 0.5]) {
      // Hand-rolled dashes: 22 short strokes around each ring.
      const segments = 22;
      const gap = 0.55; // fraction of each slice left blank
      const slice = 2 * math.pi / segments;
      for (var i = 0; i < segments; i++) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          i * slice,
          slice * (1 - gap),
          false,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_DottedArcPainter oldDelegate) =>
      oldDelegate.color != color;
}

// ═══════════════════════════════════════════════════════════════════════════
// Shared buttons
// ═══════════════════════════════════════════════════════════════════════════

/// The primary call to action — a solid, obviously-tappable button.
///
/// A mint glow pulses out from under the button once when the card appears and
/// again every 15s after, so the CTA periodically catches the eye. Nothing
/// moves: the fill, label and icon stay put and only the shadow animates. The
/// glow uses the bright accent (not the button's own dark green) because the
/// button sits on the dark hero, where a dark-green halo is invisible.
class _AskButton extends StatefulWidget {
  final String label;
  final double height;
  final VoidCallback onTap;

  const _AskButton({
    required this.label,
    required this.onTap,
    this.height = 46,
  });

  @override
  State<_AskButton> createState() => _AskButtonState();
}

class _AskButtonState extends State<_AskButton>
    with SingleTickerProviderStateMixin {
  /// How long one pulse takes to swell and fade.
  static const Duration _pulse = Duration(milliseconds: 1100);

  /// Quiet time between pulses.
  static const Duration _gap = Duration(seconds: 15);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _pulse,
  );

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Pulse once shortly after the card appears, then on a 15s cadence.
    _timer = Timer(const Duration(milliseconds: 450), () {
      _fire();
      _timer = Timer.periodic(_gap, (_) => _fire());
    });
  }

  void _fire() {
    if (!mounted) return;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onGreen = isDark ? AppColors.onGreenDark : Colors.white;
    final green = isDark ? AppColors.green500Dark : AppColors.green600;

    // The bright accent, not the button's own fill — the button sits on the
    // dark hero, where a dark-green halo would not read at all.
    const glow = AppColors.green500Dark;

    return Pressable(
      onTap: widget.onTap,
      scale: 0.97,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Swell in fast, fade out slow: sin(pi * t) peaks at the midpoint.
          final v = _controller.value;
          final t = v == 0 ? 0.0 : math.sin(math.pi * v);
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                if (t > 0.01)
                  BoxShadow(
                    color: glow.withValues(alpha: 0.55 * t),
                    blurRadius: 16 + 14 * t,
                    spreadRadius: 1 + 4 * t,
                  ),
              ],
            ),
            child: child,
          );
        },
        child: Container(
          height: widget.height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: green,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: onGreen,
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Icon(Icons.arrow_forward_rounded, size: 17, color: onGreen),
            ],
          ),
        ),
      ),
    );
  }
}

/// Secondary square action on the dark hero (camera).
class _HeroIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _HeroIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Pressable(
        onTap: onTap,
        scale: 0.94,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, size: 20, color: AppColors.heroInk),
        ),
      ),
    );
  }
}

/// Secondary square action on the light hero (camera).
class _LightIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _LightIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Pressable(
        onTap: onTap,
        scale: 0.94,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: cs.surface,
            border: Border.all(color: cs.outline),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            size: 19,
            color: cs.onSurface.withValues(alpha: 0.72),
          ),
        ),
      ),
    );
  }
}
