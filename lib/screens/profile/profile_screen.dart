import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_selection_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController(text: 'Student');

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedClasses = ref.watch(userSelectionProvider);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);
    final mutedColor = Theme.of(context).textTheme.bodySmall?.color ??
        cs.onSurface.withValues(alpha: 0.5);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar & Name ──────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: cs.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _nameController.text.isNotEmpty
                            ? _nameController.text[0].toUpperCase()
                            : 'A',
                        style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 32,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _nameController,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                      decoration: InputDecoration(
                        hintText: 'Your name',
                        hintStyle:
                            Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: mutedColor,
                                ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  Text(
                    'BSE Odisha · Odia Medium',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Settings ──────────────────────────────────────────
            Text(
              'Settings',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // Dark mode toggle
            _DarkModeToggle(
              isDark: themeMode == ThemeMode.dark ||
                  (themeMode == ThemeMode.system && isDark),
              onToggle: (value) {
                ref.read(themeModeProvider.notifier).setThemeMode(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
              },
            ),

            const SizedBox(height: 10),

            // Manage classes — nav row
            _SettingsNavRow(
              icon: Icons.school_rounded,
              title: 'Your Classes',
              subtitle: selectedClasses.isEmpty
                  ? 'No class selected'
                  : selectedClasses.map((c) => 'Class $c').join(', '),
              onTap: () => context.push('/class-selector'),
            ),

            const SizedBox(height: 28),

            // ── App Info ───────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                border: Border.all(color: cs.outline),
              ),
              child: Column(
                children: [
                  Text(
                    'Vidyālaya',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 0.1.0',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ଶିକ୍ଷାର ଦ୍ୱାର',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: mutedColor,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─── Settings Nav Row ────────────────────────────────────────────────────────

class _SettingsNavRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsNavRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outline),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cs.secondary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, size: 20, color: cs.primary),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dark Mode Toggle ────────────────────────────────────────────────────────

class _DarkModeToggle extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onToggle;

  const _DarkModeToggle({
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => onToggle(!isDark),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? cs.secondary : cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? cs.primary.withValues(alpha: 0.3) : cs.outline,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? cs.primary.withValues(alpha: 0.15)
                    : cs.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? cs.primary.withValues(alpha: 0.3)
                      : cs.outline,
                ),
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return RotationTransition(
                      turns: Tween(begin: 0.75, end: 1.0).animate(animation),
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    key: ValueKey(isDark),
                    size: 20,
                    color: isDark ? cs.primary : cs.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dark Mode',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isDark ? 'Currently dark' : 'Currently light',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Switch(
                key: ValueKey(isDark),
                value: isDark,
                onChanged: onToggle,
                activeThumbColor: cs.primary,
                activeTrackColor: cs.primary.withValues(alpha: 0.3),
                inactiveThumbColor: cs.onSurface.withValues(alpha: 0.4),
                inactiveTrackColor: cs.onSurface.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
