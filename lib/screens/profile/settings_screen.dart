import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../providers/clay_provider.dart';
import '../../providers/haptic_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/haptics.dart';
import '../../widgets/calm_widgets.dart';
import '../../widgets/support_section.dart';

/// **App Settings** — appearance, data, about.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);
    final clayOn = ref.watch(clayEnabledProvider);
    final hapticsOn = ref.watch(hapticsEnabledProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            PageTitle(
              title: 'Settings',
              onBack: () => context.canPop() ? context.pop() : context.go('/profile'),
            ),

            const SizedBox(height: 12),

            // ── Appearance ────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              child: SectionHead(label: 'Appearance'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              child: _ThemeSegmented(
                current: themeMode,
                onChanged: (m) =>
                    ref.read(themeModeProvider.notifier).setThemeMode(m),
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surface,
                  border: Border.all(color: cs.outline),
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                ),
                child: SwitchListTile(
                  value: clayOn,
                  onChanged: (v) =>
                      ref.read(clayEnabledProvider.notifier).set(v),
                  activeThumbColor: cs.primary,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.cardPad, vertical: 2),
                  title: Text(
                    'Soft 3D look',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    'Adds gentle depth to cards. Turn off for a flat, plain look.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surface,
                  border: Border.all(color: cs.outline),
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                ),
                child: SwitchListTile(
                  value: hapticsOn,
                  onChanged: (v) {
                    ref.read(hapticsEnabledProvider.notifier).set(v);
                    // Fire one buzz on enable so the change is felt immediately.
                    if (v) Haptics.medium(ref);
                  },
                  activeThumbColor: cs.primary,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.cardPad, vertical: 2),
                  title: Text(
                    'Haptic feedback',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    'Subtle vibrations on taps and actions.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Data ──────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              child: SectionHead(label: 'Data'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surface,
                  border: Border.all(color: cs.outline),
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                ),
                child: ListRow(
                  color: isDark ? AppColors.cAiDark : AppColors.cAi,
                  icon: Icons.file_download_outlined,
                  title: 'Manage downloads',
                  sub: 'Download or delete offline books',
                  onTap: () => context.push('/manage-downloads'),
                  last: true,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const SupportSection(),

            const SizedBox(height: 20),

            // ── About ─────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              child: SectionHead(label: 'About'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surface,
                  border: Border.all(color: cs.outline),
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                ),
                child: Column(
                  children: [
                    ListRow(
                      color:
                          isDark ? AppColors.cScienceDark : AppColors.cScience,
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      sub: 'Our data & privacy commitments',
                      onTap: () => context.push('/privacy-policy'),
                    ),
                    ListRow(
                      color: isDark ? AppColors.cTutorDark : AppColors.cTutor,
                      icon: Icons.info_outline_rounded,
                      title: 'About Vidyālaya',
                      sub: 'Learn more about the app',
                      onTap: () => context.push('/about'),
                      last: true,
                    ),
                  ],
                ),
              ),
            ),

            // ── App info ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding, 24, AppSpacing.screenPadding, 0),
              child: Column(
                children: [
                  Text('Vidyālaya',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontSize: 17,
                                color: isDark
                                    ? AppColors.ink2Dark
                                    : AppColors.ink2,
                              )),
                  const SizedBox(height: 3),
                  Text(
                    'Version 1.0.3',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12.5,
                        ),
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
    final border = isDark ? AppColors.hairline2Dark : AppColors.hairline2;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
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
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
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
