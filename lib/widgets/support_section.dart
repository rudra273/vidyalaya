import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/theme.dart';
import '../data/services/app_share.dart';
import '../utils/haptics.dart';
import 'calm_widgets.dart';

// ─── Support section ─────────────────────────────────────────────
// Shared "Share / Rate / Send feedback" card. Rendered identically on the
// Profile and Settings screens, so the card + its rows live here once.
class SupportSection extends ConsumerWidget {
  /// Padding around the "Support" heading. Profile insets the top; Settings
  /// keeps a plain horizontal inset (its own spacer sits above).
  final EdgeInsetsGeometry headingPadding;

  const SupportSection({
    super.key,
    this.headingPadding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.screenPadding,
    ),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: headingPadding,
          child: const SectionHead(label: 'Support'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border.all(color: cs.outline),
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            ),
            child: Column(
              children: [
                ListRow(
                  color: isDark ? AppColors.cMathsDark : AppColors.cMaths,
                  icon: Icons.share_outlined,
                  title: 'Share Vidyālaya',
                  sub: 'Tell your friends about the app',
                  onTap: () {
                    Haptics.light(ref);
                    AppShare.shareApp();
                  },
                ),
                ListRow(
                  color: isDark ? AppColors.cEnglishDark : AppColors.cEnglish,
                  icon: Icons.star_outline_rounded,
                  title: 'Rate Vidyālaya',
                  sub: 'Rate us on the Play Store',
                  onTap: () {
                    Haptics.light(ref);
                    AppShare.openPlayStore();
                  },
                ),
                ListRow(
                  color: isDark ? AppColors.cAiDark : AppColors.cAi,
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Send feedback',
                  sub: 'Report bugs or request features',
                  onTap: () {
                    Haptics.light(ref);
                    context.push('/feedback');
                  },
                  last: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
