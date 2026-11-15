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
    // Match the AI bot's green stops. Shade the light palette slightly
    // so the light title remains readable over the bright end.
    final foreground = isDark ? AppColors.onGreenDark : AppColors.heroInk;
    final colors = isDark
        ? const [AppColors.green500Dark, AppColors.green700Dark]
        : [
            Color.alphaBlend(
              Colors.black.withValues(alpha: 0.22),
              AppColors.green500,
            ),
            AppColors.green700,
          ];
    final iconBg = foreground.withValues(alpha: 0.15);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.stackGap,
        AppSpacing.screenPadding,
        0,
      ),
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
          ),
          child: InkWell(
            onTap: () => showPlusSheet(context, source: PlusSource.profile),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      Icons.star_rounded,
                      color: foreground,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      copy.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: AppFontSize.content,
                        fontWeight: AppFontWeight.semibold,
                        color: foreground,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 22,
                    color: foreground,
                  ),
                ],
              ),
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
