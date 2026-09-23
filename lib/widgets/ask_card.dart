import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../data/models/answer_style.dart';
import 'pressable.dart';

// AI tab entry card with answer-style switch.

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

    for (final radius in [
      size.width * 0.24,
      size.width * 0.37,
      size.width * 0.5,
    ]) {
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
