import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/theme.dart';
import '../providers/clay_provider.dart';

// ─── Global clay tuning ───────────────────────────────────────────────────
// Applied on top of whatever `blur` / `distance` a call site passes, so the
// whole app's clay can be re-tuned from here without touching call sites.
//
// Light mode gets NO top-left highlight. The classic claymorphism recipe puts
// a white glow there, but that assumes a mid-tone page: here `paper` (#ECF1EC)
// and `surface` (#FBFCFA) are both near-white, so a white blur on the card's
// top-left just dissolves those edges into the background. Light mode instead
// gets one soft directional shadow — cleaner, and the edges stay put.
//
// Dark mode keeps both shadows: on `paperDark` (#0D1411) the lifted top-left
// edge is the only thing separating card from page, and it genuinely reads.

/// Blur multiplier. Below 1.0 the falloff tightens, so the card's edge stays
/// defined instead of dissolving into a halo.
const double _blurScale = 0.5;

/// Shadow-alpha multiplier. Kept nearer full strength than [_blurScale]: a
/// tight shadow needs its weight to stay visible at all.
const double _alphaScale = 0.7;

/// ClayCard — soft "claymorphism" depth for accent surfaces only.
///
/// A gently raised, tactile look: one soft bottom-right shadow in light mode,
/// plus a lifted top-left highlight in dark mode where the page is dark enough
/// for it to read. Use sparingly on hero surfaces (avatar, stat cards, primary
/// tiles) — list rows and forms stay flat.
///
/// Respects the [clayEnabledProvider] toggle: when claymorphism is turned off
/// (Settings → Appearance), it falls back to a flat hairline-bordered card so
/// the layout is unchanged — just plain. Set [pressed] for the inset variant.
class ClayCard extends ConsumerWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;

  /// Base surface color. Defaults to `colorScheme.surface`.
  final Color? color;

  /// Inset (pressed-in) variant instead of raised.
  final bool pressed;

  /// Softness of the shadows. ~16 reads soft without going muddy.
  final double blur;

  /// Shadow offset distance. ~5 is a gentle lift.
  final double distance;

  const ClayCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.cardPad),
    this.radius = AppSpacing.cardRadius,
    this.color,
    this.pressed = false,
    this.blur = 16,
    this.distance = 5,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = color ?? cs.surface;
    final clayOn = ref.watch(clayEnabledProvider);

    // Toggle OFF → flat hairline-bordered card (same footprint, no depth).
    if (!clayOn) {
      return Container(
        padding: padding,
        decoration: BoxDecoration(
          color: base,
          border: Border.all(color: cs.outline),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: child,
      );
    }

    final shadowColor = isDark ? AppColors.clayShadowDark : AppColors.clayShadow;
    final highlightColor =
        isDark ? AppColors.clayHighlightDark : AppColors.clayHighlight;

    // Inset look is faked with tighter shadows, since Flutter BoxShadow has no
    // true inset. Good enough for press states.
    final shadows = pressed
        ? <BoxShadow>[
            BoxShadow(
              color: shadowColor.withValues(
                alpha: (isDark ? 0.6 : 0.7) * _alphaScale,
              ),
              blurRadius: blur * 0.5 * _blurScale,
              offset: Offset(distance * 0.4, distance * 0.4),
            ),
          ]
        : <BoxShadow>[
            // dark — bottom-right. In light mode this is the whole effect.
            BoxShadow(
              color: shadowColor.withValues(
                alpha: (isDark ? 0.55 : 0.75) * _alphaScale,
              ),
              blurRadius: blur * _blurScale,
              offset: Offset(distance, distance),
            ),
            // light — top-left, dark mode only. See the note at the top of the
            // file: on a near-white page this washes the card's edges out.
            if (isDark)
              BoxShadow(
                color: highlightColor.withValues(alpha: 0.30),
                blurRadius: blur * _blurScale,
                offset: Offset(-distance, -distance),
              ),
          ];

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(radius),
        // No border: clay defines its edge with light, not a line. A hairline
        // here reads as a dark outline in light mode and kills the effect.
        boxShadow: shadows,
      ),
      child: child,
    );
  }
}
