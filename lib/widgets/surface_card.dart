import 'package:flutter/material.dart';

import '../app/theme.dart';

// ─── Surface card ─────────────────────────────────────────────────────────
// The app's standard card, as on Explore: the surface colour on the page with
// no border. In light mode a 3px solid edge underneath lifts it off the page;
// in dark mode the lighter surface alone does that.

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.cardPad),
    this.radius = AppSpacing.cardRadius,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;

  /// Fill. Defaults to `colorScheme.surface`.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: surfaceCardDecoration(context, radius: radius, color: color),
      child: child,
    );
  }
}

/// The [SurfaceCard] look as a decoration, for widgets that need their own
/// container (an AnimatedContainer, a Material with ink).
BoxDecoration surfaceCardDecoration(
  BuildContext context, {
  double radius = AppSpacing.cardRadius,
  Color? color,
}) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return BoxDecoration(
    color: color ?? Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: dark
        ? null
        : const [BoxShadow(color: AppColors.cardEdge, offset: Offset(0, 3))],
  );
}
