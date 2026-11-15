import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/calm_widgets.dart';
import 'widgets/settings_group.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  bool _busy = false;

  Future<void> _changeSession({required bool signOut}) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final auth = ref.read(authRepositoryProvider);
      if (signOut) {
        await auth.signOut();
      } else {
        await auth.signInWithGoogle();
      }
    } catch (error) {
      final message = error.toString().toLowerCase();
      if (mounted &&
          !message.contains('cancel') &&
          !message.contains('aborted')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              signOut
                  ? 'Could not sign out. Try again.'
                  : 'Could not sign in. Try again.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final user = auth.value;
    final account = ref.watch(backendAccountCacheProvider);
    final profile = account.uid == user?.uid ? account.profile.value : null;
    final name = profile?.name ?? user?.displayName;
    final email = user?.email;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            PageTitle(
              title: 'Account',
              onBack: () =>
                  context.canPop() ? context.pop() : context.go('/settings'),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: SettingsGroup(
                showBorder: false,
                children: [
                  if (user != null && name != null && name.isNotEmpty)
                    SettingsRow(
                      color: colors.primary,
                      icon: Icons.person_outline,
                      title: 'Name',
                      sub: name,
                      showChevron: false,
                    ),
                  SettingsRow(
                    color: colors.primary,
                    icon: user != null
                        ? Icons.email_outlined
                        : Icons.login_rounded,
                    title: user != null
                        ? 'Email address'
                        : 'Sign in with Google',
                    sub: user != null ? email : null,
                    showChevron: user == null && !auth.isLoading,
                    onTap: user == null && !auth.isLoading && !_busy
                        ? () => _changeSession(signOut: false)
                        : null,
                  ),
                  if (user != null) ...[
                    SettingsRow(
                      color: colors.error,
                      icon: Icons.logout_rounded,
                      title: 'Sign out',
                      showChevron: false,
                      onTap: _busy ? null : () => _changeSession(signOut: true),
                    ),
                    SettingsRow(
                      color: colors.error,
                      icon: Icons.delete_outline_rounded,
                      title: 'Delete account',
                      trailing: const Icon(
                        Icons.open_in_new_rounded,
                        semanticLabel: 'Opens in browser',
                      ),
                      onTap: _busy
                          ? null
                          : () async {
                              final opened = await launchUrl(
                                Uri.parse(
                                  'https://rosmox.com/products/vidyakalp/delete-account',
                                ),
                                mode: LaunchMode.externalApplication,
                              );
                              if (!opened && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Could not open the account deletion page.',
                                    ),
                                  ),
                                );
                              }
                            },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
