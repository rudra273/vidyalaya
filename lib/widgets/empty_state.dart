import 'package:flutter/material.dart';

import '../app/theme.dart';
import 'chunky_button.dart';

// ─── Empty state ──────────────────────────────────────────────────────────
// Shown when a list has nothing in it yet: a tinted icon, a short title, one
// line on how to fill it, and (when there is one) the action that does.

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? ctaLabel;
  final VoidCallback? onCtaTap;

  /// Icon hue. Defaults to the brand green.
  final Color? color;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.ctaLabel,
    this.onCtaTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final hue = color ?? cs.primary;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Color.alphaBlend(
                    hue.withValues(alpha: dark ? 0.2 : 0.14),
                    cs.surface,
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(icon, size: 30, color: hue),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: dark ? AppColors.ink2Dark : AppColors.ink2,
                ),
                textAlign: TextAlign.center,
              ),
              if (ctaLabel != null && onCtaTap != null) ...[
                const SizedBox(height: 24),
                ChunkyButton(
                  label: ctaLabel!,
                  onPressed: onCtaTap,
                  height: 48,
                  expand: false,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
