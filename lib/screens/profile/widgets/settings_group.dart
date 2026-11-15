import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../widgets/calm_widgets.dart';

// ─── Grouped list card ────────────────────────────────────────────────────
// The rounded card that holds a run of [SettingsRow]s on Profile, Settings and
// the Support section. Rows are separated by hairlines inset past the icon, so
// a group reads as one surface. Light cards carry a hairline edge; dark cards
// read by their lighter surface alone, matching the app's card theme.

class SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  final bool showBorder;

  const SettingsGroup({
    super.key,
    required this.children,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hair = isDark ? AppColors.hairline2Dark : AppColors.hairline2;
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i < children.length - 1) {
        rows.add(
          Padding(
            padding: const EdgeInsets.only(left: SettingsRow.dividerInset),
            child: Divider(height: 1, thickness: 1, color: hair),
          ),
        );
      }
    }
    return Material(
      color: cs.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        side: showBorder && !isDark
            ? BorderSide(color: cs.outline)
            : BorderSide.none,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: rows),
    );
  }
}

// ─── Grouped list row ─────────────────────────────────────────────────────

/// One row in a [SettingsGroup]: tinted icon box, label, optional supporting
/// line and trailing value, then a chevron (or a custom [trailing]).
class SettingsRow extends StatelessWidget {
  static const double _hPad = 16;
  static const double _iconBox = 36;
  static const double _gap = 12;

  /// Where the hairline between rows starts: under the label, past the icon.
  static const double dividerInset = _hPad + _iconBox + _gap;

  final Color color;
  final IconData icon;
  final String title;

  /// Supporting line under the title. Wraps rather than truncates.
  final String? sub;

  /// Short current value shown before the chevron ("System", "On").
  final String? value;

  /// Replaces the chevron (a switch, an open-in-new icon, a spinner).
  final Widget? trailing;

  /// Hide the chevron when there's no [trailing] (e.g. quiet action rows).
  final bool showChevron;

  /// Colour for the title; defaults to the theme's on-surface ink.
  final Color? titleColor;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const SettingsRow({
    super.key,
    required this.color,
    required this.icon,
    required this.title,
    this.sub,
    this.value,
    this.trailing,
    this.showChevron = true,
    this.titleColor,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.ink2Dark : AppColors.ink2;
    final chevron = isDark ? AppColors.ink3Dark : AppColors.ink3;

    final Widget? end =
        trailing ??
        (showChevron
            ? Icon(Icons.chevron_right_rounded, size: 22, color: chevron)
            : null);

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: _hPad, vertical: 12),
          child: Row(
            children: [
              Tile(
                color: color,
                icon: icon,
                size: _iconBox,
                iconSize: 20,
                radius: 11,
              ),
              const SizedBox(width: _gap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: AppFontSize.content,
                        fontWeight: AppFontWeight.semibold,
                        color: titleColor ?? cs.onSurface,
                      ),
                    ),
                    if (sub != null) ...[
                      const SizedBox(height: 2),
                      Text(sub!, style: theme.textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
              if (value != null) ...[
                const SizedBox(width: 8),
                Text(
                  value!,
                  style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                ),
              ],
              if (end != null) ...[const SizedBox(width: 6), end],
            ],
          ),
        ),
      ),
    );
  }
}
