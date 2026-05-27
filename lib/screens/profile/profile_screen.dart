import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_selection_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController(text: 'Student');
  bool _isAuthBusy = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedClasses = ref.watch(userSelectionProvider);
    final selectedBoard = ref.watch(userBoardProvider);
    final authState = ref.watch(authStateProvider);
    final cs = Theme.of(context).colorScheme;
    final themeMode = ref.watch(themeModeProvider);
    final mutedColor =
        Theme.of(context).textTheme.bodySmall?.color ??
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
                        hintStyle: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(color: mutedColor),
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
                    selectedBoard,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            authState.when(
              data: (user) => _AccountPanel(
                displayName: user?.displayName,
                email: user?.email,
                photoUrl: user?.photoURL,
                isSignedIn: user != null,
                isBusy: _isAuthBusy,
                onSignIn: _signInWithGoogle,
                onSignOut: _signOut,
              ),
              loading: () => const _AccountPanel.loading(),
              error: (error, stackTrace) => _AccountPanel.error(
                message: error.toString(),
                isBusy: _isAuthBusy,
                onRetry: () => ref.invalidate(authStateProvider),
              ),
            ),

            const SizedBox(height: 28),

            // ── Settings ──────────────────────────────────────────
            Text('Settings', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),

            // Theme selector (System, Light, Dark)
            _ThemeSelector(
              currentMode: themeMode,
              onChanged: (mode) {
                ref.read(themeModeProvider.notifier).setThemeMode(mode);
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

            const SizedBox(height: 10),

            // Downloads — nav row
            _SettingsNavRow(
              icon: Icons.download_done_rounded,
              title: 'Manage Downloads',
              subtitle: 'Download or delete offline books',
              onTap: () => context.push('/manage-downloads'),
            ),

            const SizedBox(height: 10),

            // Privacy Policy — nav row
            _SettingsNavRow(
              icon: Icons.privacy_tip_rounded,
              title: 'Privacy Policy',
              subtitle: 'Read our data and privacy commitments',
              onTap: () => context.push('/privacy-policy'),
            ),

            const SizedBox(height: 10),

            // About App — nav row
            _SettingsNavRow(
              icon: Icons.info_outline_rounded,
              title: 'About Vidyālaya',
              subtitle: 'Learn more about the app and its features',
              onTap: () => context.push('/about'),
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
                    'Version 1.0.0',
                    style: Theme.of(context).textTheme.bodySmall,
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

  Future<void> _signInWithGoogle() async {
    await _runAuthAction(() {
      return ref.read(authRepositoryProvider).signInWithGoogle();
    });
  }

  Future<void> _signOut() async {
    await _runAuthAction(() {
      return ref.read(authRepositoryProvider).signOut();
    });
  }

  Future<void> _runAuthAction(Future<void> Function() action) async {
    setState(() => _isAuthBusy = true);
    try {
      await action();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _isAuthBusy = false);
      }
    }
  }
}

// ─── Account Panel ─────────────────────────────────────────────────────────

class _AccountPanel extends StatelessWidget {
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final bool isSignedIn;
  final bool isBusy;
  final VoidCallback? onSignIn;
  final VoidCallback? onSignOut;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const _AccountPanel({
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.isSignedIn,
    required this.isBusy,
    required this.onSignIn,
    required this.onSignOut,
  }) : errorMessage = null,
       onRetry = null;

  const _AccountPanel.loading()
    : displayName = null,
      email = null,
      photoUrl = null,
      isSignedIn = false,
      isBusy = true,
      onSignIn = null,
      onSignOut = null,
      errorMessage = null,
      onRetry = null;

  const _AccountPanel.error({
    required String message,
    required this.isBusy,
    required this.onRetry,
  }) : displayName = null,
       email = null,
       photoUrl = null,
       isSignedIn = false,
       onSignIn = null,
       onSignOut = null,
       errorMessage = message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bodySmall = Theme.of(context).textTheme.bodySmall;
    final title = isSignedIn ? (displayName ?? 'Google account') : 'Account';
    final subtitle = errorMessage ?? email ?? 'Sign in to sync your profile';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        children: [
          _AccountAvatar(
            photoUrl: photoUrl,
            displayName: displayName,
            isSignedIn: isSignedIn,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: bodySmall?.copyWith(
                    color: errorMessage == null ? bodySmall.color : cs.error,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isBusy)
            const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          else if (errorMessage != null)
            IconButton(
              tooltip: 'Retry',
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
            )
          else
            IconButton.filledTonal(
              tooltip: isSignedIn ? 'Sign out' : 'Sign in with Google',
              onPressed: isSignedIn ? onSignOut : onSignIn,
              icon: Icon(
                isSignedIn ? Icons.logout_rounded : Icons.login_rounded,
              ),
            ),
        ],
      ),
    );
  }
}

class _AccountAvatar extends StatelessWidget {
  final String? photoUrl;
  final String? displayName;
  final bool isSignedIn;

  const _AccountAvatar({
    required this.photoUrl,
    required this.displayName,
    required this.isSignedIn,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final firstLetter = (displayName?.trim().isNotEmpty ?? false)
        ? displayName!.trim()[0].toUpperCase()
        : 'G';

    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(photoUrl!),
        backgroundColor: cs.secondary,
      );
    }

    return CircleAvatar(
      radius: 24,
      backgroundColor: cs.secondary,
      child: Text(
        isSignedIn ? firstLetter : 'G',
        style: TextStyle(
          color: cs.primary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
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
              child: Center(child: Icon(icon, size: 20, color: cs.primary)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
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

// ─── Theme Selector ─────────────────────────────────────────────────────────

class _ThemeSelector extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeSelector({required this.currentMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        children: [
          _ThemeOption(
            label: 'System',
            icon: Icons.settings_suggest_rounded,
            isSelected: currentMode == ThemeMode.system,
            onTap: () => onChanged(ThemeMode.system),
          ),
          _ThemeOption(
            label: 'Light',
            icon: Icons.light_mode_rounded,
            isSelected: currentMode == ThemeMode.light,
            onTap: () => onChanged(ThemeMode.light),
          ),
          _ThemeOption(
            label: 'Dark',
            icon: Icons.dark_mode_rounded,
            isSelected: currentMode == ThemeMode.dark,
            onTap: () => onChanged(ThemeMode.dark),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? cs.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? cs.onPrimary
                    : cs.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? cs.onPrimary
                      : cs.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
