import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../data/models/plus.dart';
import '../../../providers/plus_provider.dart';
import '../../../utils/ai_labels.dart';
import '../../plus/plus_sheet.dart';

// ─── Plus card ───

/// The Profile card for Vidyakalp Plus: ask for it, or see where the request
/// stands. Hidden until the server confirms Plus requests are open for this
/// student, and for accounts that already include more than Plus.
class PlusCard extends ConsumerWidget {
  const PlusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(plusProvider).status;
    if (status == null || !_visible(status)) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final copy = plusCardCopy(status);
    // The hero green in both themes: Plus is the one dark-green card on the
    // page, so it reads as special without competing colours.
    final bg = isDark ? AppColors.heroDark : AppColors.hero;
    final iconBg = Color.alphaBlend(
      AppColors.green500Dark.withValues(alpha: isDark ? 0.16 : 0.14),
      bg,
    );
    const star = Color(0xFF7FE0B6);
    const sub = Color(0xFFC9DDD2);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.stackGap,
        AppSpacing.screenPadding,
        0,
      ),
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          side: isDark
              ? const BorderSide(color: AppColors.heroLineDark)
              : BorderSide.none,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => showPlusSheet(context, source: PlusSource.profile),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.star_rounded, color: star, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        copy.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.heroInk,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        copy.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: sub,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, color: sub),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Active Plus always shows; a request in any other state shows only while the
  /// server has Plus requests open. Pro is an internal plan and gets no card.
  static bool _visible(PlusStatus status) {
    if (status.planKey == 'pro') return false;
    return status.state == PlusState.active || status.available;
  }
}

/// The card's headline and supporting line for each state.
({String title, String subtitle}) plusCardCopy(PlusStatus status) {
  switch (status.state) {
    case PlusState.active:
      final until = status.plusExpiresAt;
      return (
        title: 'Plus is on',
        subtitle: until == null
            ? 'Higher limits are on for your account.'
            : 'Until ${shortDate(until)}.',
      );
    case PlusState.pending:
      return (
        title: 'Plus requested',
        subtitle: "We'll review it. You don't need to do anything.",
      );
    case PlusState.declined:
      final again = status.canRequestAgainAt;
      return (
        title: "Plus isn't available right now",
        subtitle: again == null
            ? 'You can ask again later.'
            : 'You can ask again after ${shortDate(again)}.',
      );
    case PlusState.expired:
      return (
        title: 'Your Plus access has ended',
        subtitle: 'You can ask for it again.',
      );
    case PlusState.none:
      return (
        title: 'Vidyakalp Plus',
        subtitle: 'More AI questions every day. Asking costs nothing.',
      );
  }
}
