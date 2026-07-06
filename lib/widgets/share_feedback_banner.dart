import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app/theme.dart';
import '../data/services/app_share.dart';
import '../providers/share_banner_provider.dart';
import '../utils/haptics.dart';
import 'calm_widgets.dart';
import 'pressable.dart';

// ─── ShareFeedbackBanner: sticky share card at Home bottom ───────────────

/// Permanent banner at the bottom of Home for sharing the app on WhatsApp.
/// Until dismissed, it also shows an "Enjoying Vidyālaya?" header with a
/// Rate-us button; the close icon hides only that part, collapsing the
/// banner into a compact share-only card. Rating stays reachable in
/// Settings → Support.
class ShareFeedbackBanner extends ConsumerWidget {
  const ShareFeedbackBanner({super.key});

  static const _waGreen = Color(0xFF25D366);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.ink2Dark : AppColors.ink2;
    final rateDismissed = ref.watch(shareBannerDismissedProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPad - 2),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: rateDismissed
          ? _CompactShareRow(muted: muted)
          : _FullBanner(cs: cs, muted: muted),
    );
  }
}

// ─── Full banner: header + Share / Rate actions ──────────────────────────

class _FullBanner extends ConsumerWidget {
  const _FullBanner({required this.cs, required this.muted});

  final ColorScheme cs;
  final Color muted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heart tile + title/subtitle + dismiss (hides the rate part only)
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
                    'Share it with friends or rate it on the Play Store.',
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

        // WhatsApp share + Play Store rating
        Row(
          children: [
            const Expanded(child: _WhatsAppButton()),
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
                    borderRadius:
                        BorderRadius.circular(AppSpacing.tileRadius),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star_rounded, size: 18, color: cs.primary),
                      const SizedBox(width: 7),
                      Text(
                        'Rate us',
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
    );
  }
}

// ─── Compact row: share-only, shown after the rate part is dismissed ─────

class _CompactShareRow extends ConsumerWidget {
  const _CompactShareRow({required this.muted});

  final Color muted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        const Tile(
          color: ShareFeedbackBanner._waGreen,
          icon: Icons.share_rounded,
          size: 38,
          radius: 11,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share Vidyālaya',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontSize: 16, height: 1.1),
              ),
              const SizedBox(height: 2),
              Text(
                'Invite your friends to study together.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: muted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(width: 110, child: _WhatsAppButton()),
      ],
    );
  }
}

// ─── WhatsApp share pill ──────────────────────────────────────────────────

class _WhatsAppButton extends ConsumerWidget {
  const _WhatsAppButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Pressable(
      onTap: () {
        Haptics.light(ref);
        AppShare.shareViaWhatsApp();
      },
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: ShareFeedbackBanner._waGreen,
          borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/whatsapp.svg',
              width: 17,
              height: 17,
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
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
    );
  }
}
