import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Availability of a feature/tool, controlling its badge and tap behaviour.
enum FeatureStatus { live, comingSoon }

/// Declarative description of a feature/tool, so screens can drive a grid or
/// list from a data list instead of hand-rolling each card (see Explore + Home).
class FeatureCardData {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  /// Foreground tint for the icon (and its soft background).
  final Color color;
  final FeatureStatus status;

  const FeatureCardData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.status = FeatureStatus.live,
  });
}

/// A reusable, warm rounded card for a feature/tool. Renders as a compact grid
/// tile by default; pass [layout] = [FeatureCardLayout.row] for a full-width
/// row with a trailing chevron.
///
/// "Coming soon" features show a muted badge and ignore [onTap].
class FeatureCard extends StatelessWidget {
  final FeatureCardData data;
  final VoidCallback? onTap;
  final FeatureCardLayout layout;

  const FeatureCard({
    super.key,
    required this.data,
    this.onTap,
    this.layout = FeatureCardLayout.tile,
  });

  bool get _isComingSoon => data.status == FeatureStatus.comingSoon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? cs.surface : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: _isComingSoon
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Opacity(
        opacity: _isComingSoon ? 0.7 : 1,
        child: layout == FeatureCardLayout.tile
            ? _buildTile(context)
            : _buildRow(context),
      ),
    );

    return GestureDetector(
      onTap: _isComingSoon ? null : onTap,
      child: card,
    );
  }

  Widget _iconBadge() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(data.icon, color: data.color),
    );
  }

  Widget _buildTile(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _iconBadge(),
            if (_isComingSoon) const _ComingSoonBadge(),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          data.title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          data.subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildRow(BuildContext context) {
    return Row(
      children: [
        _iconBadge(),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      data.title,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (_isComingSoon) ...[
                    const SizedBox(width: 8),
                    const _ComingSoonBadge(),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                data.subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        if (!_isComingSoon)
          Icon(Icons.chevron_right, color: AppColors.textMuted),
      ],
    );
  }
}

/// How a [FeatureCard] lays out: a compact grid [tile] or a full-width [row].
enum FeatureCardLayout { tile, row }

class _ComingSoonBadge extends StatelessWidget {
  const _ComingSoonBadge();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Soon',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: cs.onSecondaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
