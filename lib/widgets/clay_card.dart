import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/theme.dart';
import '../providers/clay_provider.dart';

/// ClayCard — soft "claymorphism" depth for accent surfaces only.
///
/// Two opposing shadows (dark bottom-right, light top-left) give a gently
/// raised, tactile look. Use sparingly on hero surfaces (avatar, stat cards,
/// primary tiles) — list rows and forms stay flat.
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
              color: shadowColor.withValues(alpha: isDark ? 0.6 : 0.7),
              blurRadius: blur * 0.5,
              offset: Offset(distance * 0.4, distance * 0.4),
            ),
          ]
        : <BoxShadow>[
            // dark — bottom-right
            BoxShadow(
              color: shadowColor.withValues(alpha: isDark ? 0.55 : 0.75),
              blurRadius: blur,
              offset: Offset(distance, distance),
            ),
            // light — top-left
            BoxShadow(
              color: highlightColor.withValues(alpha: isDark ? 0.30 : 0.9),
              blurRadius: blur,
              offset: Offset(-distance, -distance),
            ),
          ];

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadows,
      ),
      child: child,
    );
  }
}
