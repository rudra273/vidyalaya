import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/theme.dart';
import '../data/services/app_share.dart';
import '../screens/profile/widgets/settings_group.dart';
import '../utils/haptics.dart';
import 'calm_widgets.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: headingPadding,
          child: const SectionHead(label: 'Help & support'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: SettingsGroup(
            showBorder: false,
            children: [
              SettingsRow(
                color: Theme.of(context).colorScheme.primary,
                icon: Icons.help_outline_rounded,
                title: 'FAQ',
                onTap: () => context.push('/help'),
              ),
              SettingsRow(
                color: isDark ? AppColors.cAiDark : AppColors.cAi,
                icon: Icons.flag_outlined,
                title: 'Report a problem',
                onTap: () {
                  Haptics.light(ref);
                  context.push('/feedback');
                },
              ),
              SettingsRow(
                color: isDark ? AppColors.cMathsDark : AppColors.cMaths,
                icon: Icons.share_outlined,
                title: 'Share Vidyakalp',
                onTap: () {
                  Haptics.light(ref);
                  AppShare.shareApp();
                },
              ),
              SettingsRow(
                color: isDark ? AppColors.cEnglishDark : AppColors.cEnglish,
                icon: Icons.star_outline_rounded,
                title: 'Rate Vidyakalp',
                onTap: () {
                  Haptics.light(ref);
                  AppShare.openPlayStore();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
