import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_info.dart';
import '../../app/theme.dart';
import '../../providers/haptic_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/haptics.dart';
import '../../widgets/calm_widgets.dart';
import '../../widgets/support_section.dart';
import 'widgets/settings_group.dart';

/// **App Settings** — appearance, data, about.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);
    final hapticsOn = ref.watch(hapticsEnabledProvider);

    void setHaptics(bool v) {
      ref.read(hapticsEnabledProvider.notifier).set(v);
      // Fire one buzz on enable so the change is felt immediately.
      if (v) Haptics.medium(ref);
    }

    const sectionTop = EdgeInsets.fromLTRB(
      AppSpacing.screenPadding,
      AppSpacing.sectionGap,
      AppSpacing.screenPadding,
      0,
    );
    const inset = EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            PageTitle(
              title: 'Settings',
              onBack: () =>
                  context.canPop() ? context.pop() : context.go('/profile'),
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.stackGap,
                AppSpacing.screenPadding,
                0,
              ),
              child: SectionHead(label: 'Account & preferences'),
            ),
            Padding(
              padding: inset,
              child: SettingsGroup(
                showBorder: false,
                children: [
                  SettingsRow(
                    color: isDark ? AppColors.cTutorDark : AppColors.cTutor,
                    icon: Icons.person_outline_rounded,
                    title: 'Account',
                    onTap: () => context.push('/settings/account'),
                  ),
                  SettingsRow(
                    color: isDark ? AppColors.cHindiDark : AppColors.cHindi,
                    icon: Icons.palette_outlined,
                    title: 'Appearance',
                    trailing: _AppearanceSwitch(
                      selected: themeMode,
                      onChanged: ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode,
                    ),
                  ),
                  SettingsRow(
                    color: isDark ? AppColors.cOdiaDark : AppColors.cOdia,
                    icon: Icons.vibration_rounded,
                    title: 'Haptic feedback',
                    onTap: () => setHaptics(!hapticsOn),
                    trailing: Switch(value: hapticsOn, onChanged: setHaptics),
                  ),
                  SettingsRow(
                    color: isDark ? AppColors.cEnglishDark : AppColors.cEnglish,
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    onTap: () => context.push('/settings/notifications'),
                  ),
                ],
              ),
            ),
            const SupportSection(headingPadding: sectionTop),
            Padding(
              padding: sectionTop,
              child: const SectionHead(label: 'About & privacy'),
            ),
            Padding(
              padding: inset,
              child: SettingsGroup(
                showBorder: false,
                children: [
                  SettingsRow(
                    color: isDark ? AppColors.cScienceDark : AppColors.cScience,
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () => context.push('/privacy-policy'),
                  ),
                  SettingsRow(
                    color: isDark ? AppColors.cTutorDark : AppColors.cTutor,
                    icon: Icons.info_outline_rounded,
                    title: 'About Vidyakalp',
                    onTap: () => context.push('/about'),
                  ),
                ],
              ),
            ),

            // ── App info ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                28,
                AppSpacing.screenPadding,
                0,
              ),
              child: Column(
                children: [
                  Text(
                    'Vidyakalp',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: AppFontSize.title,
                      color: isDark ? AppColors.ink2Dark : AppColors.ink2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Version $kAppVersionName',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppearanceSwitch extends StatelessWidget {
  const _AppearanceSwitch({required this.selected, required this.onChanged});

  final ThemeMode selected;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const options = [
      (ThemeMode.system, Icons.brightness_auto_rounded, 'System'),
      (ThemeMode.light, Icons.light_mode_outlined, 'Light'),
      (ThemeMode.dark, Icons.dark_mode_outlined, 'Dark'),
    ];
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          left: 3,
          right: 3,
          height: 34,
          child: Ink(
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(17),
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (mode, icon, label) in options)
              Semantics(
                selected: mode == selected,
                child: Tooltip(
                  message: label,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () => onChanged(mode),
                    child: SizedBox.square(
                      dimension: 44,
                      child: Center(
                        child: Ink(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: mode == selected
                                ? colors.primary
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            size: 16,
                            color: mode == selected
                                ? colors.onPrimary
                                : colors.onSurfaceVariant,
                          ),
                        ),
                      ),
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
