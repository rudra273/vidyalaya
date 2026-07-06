import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app/theme.dart';
import '../data/services/app_share.dart';
import '../providers/share_banner_provider.dart';
import '../utils/haptics.dart';
import 'calm_widgets.dart';
import 'pressable.dart';

// ─── ShareFeedbackBanner: "Enjoying Vidyālaya?" card ─────────────────────

/// Dismissible Home banner inviting students to share the app on WhatsApp
/// or leave feedback on the Play Store. Dismissal persists via
/// [shareBannerDismissedProvider]; both actions stay reachable in Settings.
class ShareFeedbackBanner extends ConsumerWidget {
  const ShareFeedbackBanner({super.key});

  static const _waGreen = Color(0xFF25D366);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.ink2Dark : AppColors.ink2;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPad - 2),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heart tile + title/subtitle + dismiss
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Tile(
                color: cs.primary,
                icon: Icons.favorite_rounded,
                size: 38,
                radius: 11,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enjoying Vidyālaya?',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontSize: 18, height: 1.1),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Share it with friends or tell us what to improve.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12.5,
                        color: muted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                borderRadius: BorderRadius.circular(99),
                onTap: () {
                  Haptics.light(ref);
                  ref.read(shareBannerDismissedProvider.notifier).dismiss();
                },
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.close_rounded, size: 18, color: muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // WhatsApp share + Play Store feedback
          Row(
            children: [
              Expanded(
                child: Pressable(
                  onTap: () {
                    Haptics.light(ref);
                    AppShare.shareViaWhatsApp();
                  },
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: _waGreen,
                      borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/whatsapp.svg',
                          width: 17,
                          height: 17,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Share',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.stackGap),
              Expanded(
                child: Pressable(
                  onTap: () {
                    Haptics.light(ref);
                    AppShare.openPlayStore();
                  },
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      border: Border.all(color: cs.outline),
                      borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star_rounded, size: 18, color: cs.primary),
                        const SizedBox(width: 7),
                        Text(
                          'Feedback',
                          style: TextStyle(
                            color: cs.primary,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
