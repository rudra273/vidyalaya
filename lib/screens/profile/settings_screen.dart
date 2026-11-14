import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/app_info.dart';
import '../../app/theme.dart';
import '../../providers/haptic_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/haptics.dart';
import '../../widgets/calm_widgets.dart';
import '../../widgets/support_section.dart';
import 'widgets/settings_group.dart';

const _deleteAccountUrl =
    'https://rosmox.com/products/vidyakalp/delete-account';

/// **App Settings** — appearance, data, about.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
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

            // ── Appearance ────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                16,
                AppSpacing.screenPadding,
                0,
              ),
              child: SectionHead(label: 'Appearance'),
            ),
            Padding(
              padding: inset,
              child: _ThemeSegmented(
                current: themeMode,
                onChanged: (m) =>
                    ref.read(themeModeProvider.notifier).setThemeMode(m),
              ),
            ),
            const Padding(
              padding: sectionTop,
              child: SectionHead(label: 'App preferences'),
            ),
            Padding(
              padding: inset,
              child: SettingsGroup(
                showBorder: false,
                children: [
                  SettingsRow(
                    color: isDark ? AppColors.cOdiaDark : AppColors.cOdia,
                    icon: Icons.vibration_rounded,
                    title: 'Haptic feedback',
                    onTap: () => setHaptics(!hapticsOn),
                    trailing: Switch(
                      value: hapticsOn,
                      onChanged: setHaptics,
                      activeThumbColor: cs.primary,
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: sectionTop,
              child: SectionHead(label: 'Notifications'),
            ),
            const Padding(
              padding: inset,
              child: SettingsGroup(
                showBorder: false,
                children: [
                  _ReminderToggle(
                    type: ReminderType.timetable,
                    icon: Icons.calendar_today_outlined,
                    title: 'Timetable reminders',
                  ),
                  _ReminderToggle(
                    type: ReminderType.dailyChallenge,
                    icon: Icons.psychology_outlined,
                    title: 'Daily challenge reminders',
                  ),
                ],
              ),
            ),

            const SupportSection(headingPadding: sectionTop),
            const SizedBox(height: AppSpacing.stackGap),
            Padding(
              padding: inset,
              child: SettingsGroup(
                showBorder: false,
                children: [
                  SettingsRow(
                    color: cs.primary,
                    icon: Icons.help_outline_rounded,
                    title: 'Help and feedback',
                    onTap: () => context.push('/help'),
                  ),
                ],
              ),
            ),

            // ── About ─────────────────────────────────────────────
            const Padding(
              padding: sectionTop,
              child: SectionHead(label: 'Privacy & information'),
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
                  // The external-link icon indicates the web form opens in a browser.
                  SettingsRow(
                    color: isDark ? AppColors.cMathsDark : AppColors.cMaths,
                    icon: Icons.delete_outline_rounded,
                    title: 'Delete account',
                    trailing: Icon(
                      Icons.open_in_new_rounded,
                      size: 18,
                      semanticLabel: 'Opens in browser',
                      color: isDark ? AppColors.ink3Dark : AppColors.ink3,
                    ),
                    onTap: () => launchUrl(
                      Uri.parse(_deleteAccountUrl),
                      mode: LaunchMode.externalApplication,
                    ),
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

// ─── Theme segmented picker (System / Light / Dark) ──────────────────────

class _ThemeSegmented extends StatelessWidget {
  final ThemeMode current;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeSegmented({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.surface3Dark : AppColors.surface3;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _Segment(
            label: 'System',
            icon: Icons.brightness_auto_rounded,
            active: current == ThemeMode.system,
            onTap: () => onChanged(ThemeMode.system),
          ),
          _Segment(
            label: 'Light',
            icon: Icons.light_mode_rounded,
            active: current == ThemeMode.light,
            onTap: () => onChanged(ThemeMode.light),
          ),
          _Segment(
            label: 'Dark',
            icon: Icons.dark_mode_rounded,
            active: current == ThemeMode.dark,
            onTap: () => onChanged(ThemeMode.dark),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? cs.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 19,
                color: active
                    ? cs.onPrimary
                    : (isDark ? AppColors.ink2Dark : AppColors.ink2),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: active
                      ? cs.onPrimary
                      : (isDark ? AppColors.ink2Dark : AppColors.ink2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderToggle extends ConsumerWidget {
  const _ReminderToggle({
    required this.type,
    required this.icon,
    required this.title,
  });

  final ReminderType type;
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = reminderEnabledProvider(type);
    final enabled = ref.watch(provider);
    return SettingsRow(
      color: Theme.of(context).colorScheme.primary,
      icon: icon,
      title: title,
      trailing: Semantics(
        label: title,
        child: Switch(
          value: enabled,
          onChanged: ref.read(provider.notifier).set,
        ),
      ),
    );
  }
}
