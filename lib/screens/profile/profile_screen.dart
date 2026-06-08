import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/services/backend_auth_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/books_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/user_selection_provider.dart';
import '../../providers/clay_provider.dart';
import '../../widgets/calm_widgets.dart';
import '../../widgets/clay_card.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _schoolController = TextEditingController();
  int _selectedClass = 8;
  String _preferredLanguage = 'en';
  bool _isAuthBusy = false;
  bool _isProfileSaving = false;
  String? _appliedProfileKey;

  @override
  void initState() {
    super.initState();
    final selectedClasses = ref.read(userSelectionProvider).toList()..sort();
    if (selectedClasses.isNotEmpty) {
      _selectedClass = selectedClasses.first;
    }
  }

  @override
  void dispose() {
    _schoolController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final accountState = ref.watch(backendAccountCacheProvider);
    final isSignedIn = authState.maybeWhen(
      data: (user) => user != null,
      orElse: () => false,
    );
    final user = authState.maybeWhen(data: (u) => u, orElse: () => null);
    _ensureCachedProfile(user);
    final cachedProfile = accountState.profile.maybeWhen(
      data: (profile) => profile,
      orElse: () => null,
    );
    final isProfileLoading = accountState.profile is AsyncLoading;
    _applyCachedProfile(cachedProfile);

    final displayName =
        (user?.displayName?.trim().isNotEmpty ?? false) ? user!.displayName! : 'Student';
    final email = user?.email ?? '—';
    final avatarLetter = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'S';

    final progress = ref.watch(progressProvider);
    final books = ref.watch(selectedBooksProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            PageTitle(
              title: 'Profile',
              trailing: IconBox(
                icon: Icons.settings_rounded,
                onTap: () => context.push('/settings'),
              ),
            ),

            // ── Identity ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 14, 0, 6),
              child: Center(
                child: Column(
                  children: [
                    _BigAvatar(
                      letter: avatarLetter,
                      clay: ref.watch(clayEnabledProvider),
                    ),
                    const SizedBox(height: 12),
                    Text(displayName,
                        style:
                            Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontSize: 23,
                                )),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          size: 15,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.ink3Dark
                              : AppColors.ink3,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'SCERT Odisha',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Learning summary stats ───────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding, 14, AppSpacing.screenPadding, 0),
              child: _StatsStrip(
                streak: progress.currentStreak,
                aiSessions: progress.aiSessions,
                books: books.length,
              ),
            ),

            // ── Account row ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding, 18, AppSpacing.screenPadding, 0),
              child: const SectionHead(label: 'Account'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              child: authState.when(
                data: (u) => _AccountRow(
                  letter: avatarLetter,
                  name: displayName,
                  email: u != null ? email : 'Sign in to sync your profile',
                  isSignedIn: u != null,
                  isBusy: _isAuthBusy,
                  onCopyToken:
                      kDebugMode && u != null ? _copyFirebaseIdToken : null,
                  onAction: u != null ? _signOut : _signInWithGoogle,
                ),
                loading: () => _AccountRow.loading(letter: avatarLetter),
                error: (e, _) => _AccountRow(
                  letter: 'G',
                  name: 'Account',
                  email: e.toString(),
                  isSignedIn: false,
                  isBusy: _isAuthBusy,
                  onAction: () => ref.invalidate(authStateProvider),
                  errored: true,
                ),
              ),
            ),

            // ── Student profile form ─────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding, 18, AppSpacing.screenPadding, 0),
              child: const SectionHead(label: 'Student profile'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              child: _StudentForm(
                isSignedIn: isSignedIn,
                isLoading: isProfileLoading,
                isSaving: _isProfileSaving,
                selectedClass: _selectedClass,
                preferredLanguage: _preferredLanguage,
                schoolController: _schoolController,
                onClassChanged: (v) => setState(() => _selectedClass = v),
                onLanguageChanged: (v) =>
                    setState(() => _preferredLanguage = v),
                onSave: _saveStudentProfile,
              ),
            ),

            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              child: _MyLearningRow(
                onTap: () => context.push('/progress'),
              ),
            ),
            const SizedBox(height: 16),
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
      _appliedProfileKey = null;
      return ref.read(authRepositoryProvider).signOut();
    });
  }

  void _ensureCachedProfile(User? user) {
    if (user == null || _isProfileSaving) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(backendAccountCacheProvider.notifier).ensureProfile();
    });
  }

  void _applyCachedProfile(StudentProfile? profile) {
    if (profile == null) return;
    final key = [
      profile.classNo,
      profile.preferredLanguage,
      profile.schoolName ?? '',
      profile.updatedAt?.toIso8601String() ?? '',
    ].join('|');
    if (_appliedProfileKey == key) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _appliedProfileKey == key || _isProfileSaving) return;
      setState(() {
        _appliedProfileKey = key;
        _selectedClass = profile.classNo;
        _preferredLanguage = profile.preferredLanguage;
        _schoolController.text = profile.schoolName ?? '';
      });
      _syncLocalProfile(profile.classNo);
    });
  }

  Future<void> _saveStudentProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to save your profile.')),
      );
      return;
    }

    setState(() => _isProfileSaving = true);
    try {
      final savedProfile = await ref
          .read(backendAccountCacheProvider.notifier)
          .saveProfile(
            StudentProfile(
              board: 'scert_odisha',
              classNo: _selectedClass,
              preferredLanguage: _preferredLanguage,
              schoolName: _schoolController.text,
            ),
          );

      _syncLocalProfile(savedProfile.classNo);
      if (!mounted) return;
      setState(() {
        _selectedClass = savedProfile.classNo;
        _preferredLanguage = savedProfile.preferredLanguage;
        _schoolController.text = savedProfile.schoolName ?? '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _isProfileSaving = false);
      }
    }
  }

  void _syncLocalProfile(int classNo) {
    ref.read(userBoardProvider.notifier).setBoard('scert_odisha');
    ref.read(userSelectionProvider.notifier).setClasses({classNo});
  }

  Future<void> _copyFirebaseIdToken() async {
    await _runAuthAction(() async {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
      if (token == null || token.isEmpty) {
        throw StateError('Please sign in again.');
      }

      await Clipboard.setData(ClipboardData(text: token));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Firebase ID token copied.')),
      );
    });
  }

  Future<void> _runAuthAction(Future<void> Function() action) async {
    setState(() => _isAuthBusy = true);
    try {
      await action();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _isAuthBusy = false);
      }
    }
  }
}

// ─── Big avatar (identity) ────────────────────────────────────────────────

class _BigAvatar extends StatelessWidget {
  final String letter;
  final bool clay;

  const _BigAvatar({required this.letter, this.clay = true});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          cs.primary.withValues(alpha: isDark ? 0.18 : 0.12),
          cs.surface,
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? AppColors.green100Dark : AppColors.green100,
        ),
        boxShadow: clay
            ? [
                BoxShadow(
                  color:
                      (isDark ? AppColors.clayShadowDark : AppColors.clayShadow)
                          .withValues(alpha: isDark ? 0.55 : 0.7),
                  blurRadius: 16,
                  offset: const Offset(5, 5),
                ),
                BoxShadow(
                  color: (isDark
                          ? AppColors.clayHighlightDark
                          : AppColors.clayHighlight)
                      .withValues(alpha: isDark ? 0.30 : 0.9),
                  blurRadius: 16,
                  offset: const Offset(-5, -5),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontSize: 38,
              color: cs.primary,
            ),
      ),
    );
  }
}

// ─── Stats strip ──────────────────────────────────────────────────────────

class _StatsStrip extends StatelessWidget {
  final int streak;
  final int aiSessions;
  final int books;

  const _StatsStrip({
    required this.streak,
    required this.aiSessions,
    required this.books,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClayCard(
      child: Row(
        children: [
          Expanded(
            child: _Stat(
              color: isDark ? AppColors.cMathsDark : AppColors.cMaths,
              icon: Icons.local_fire_department_rounded,
              value: '$streak',
              label: 'Day streak',
            ),
          ),
          _Divider(),
          Expanded(
            child: _Stat(
              color: isDark ? AppColors.cAiDark : AppColors.cAi,
              icon: Icons.auto_awesome_rounded,
              value: '$aiSessions',
              label: 'AI sessions',
            ),
          ),
          _Divider(),
          Expanded(
            child: _Stat(
              color: isDark ? AppColors.cEnglishDark : AppColors.cEnglish,
              icon: Icons.menu_book_rounded,
              value: '$books',
              label: 'Books',
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String value;
  final String label;

  const _Stat({
    required this.color,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 22,
                height: 1,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 56,
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.hairline2Dark
          : AppColors.hairline2,
    );
  }
}

// ─── Account row ──────────────────────────────────────────────────────────

class _AccountRow extends StatelessWidget {
  final String letter;
  final String name;
  final String email;
  final bool isSignedIn;
  final bool isBusy;
  final bool errored;
  final VoidCallback? onCopyToken;
  final VoidCallback? onAction;

  const _AccountRow({
    required this.letter,
    required this.name,
    required this.email,
    required this.isSignedIn,
    required this.isBusy,
    this.onCopyToken,
    this.onAction,
    this.errored = false,
  });

  factory _AccountRow.loading({required String letter}) => _AccountRow(
        letter: letter,
        name: 'Account',
        email: 'Loading…',
        isSignedIn: false,
        isBusy: true,
      );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dangerColor = isDark ? AppColors.cMathsDark : AppColors.cMaths;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPad),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Row(
        children: [
          _SmallAvatar(letter: isSignedIn ? letter : 'G'),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 15,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: errored ? cs.error : null,
                        fontSize: 12.5,
                      ),
                ),
              ],
            ),
          ),
          if (isBusy)
            const SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            )
          else ...[
            if (onCopyToken != null) ...[
              _SquareIconButton(
                icon: Icons.vpn_key_rounded,
                tint: cs.onSurface.withValues(alpha: 0.6),
                bg: isDark ? AppColors.surface3Dark : AppColors.surface3,
                onTap: onCopyToken,
              ),
              const SizedBox(width: 8),
            ],
            _SquareIconButton(
              icon: isSignedIn
                  ? Icons.logout_rounded
                  : Icons.login_rounded,
              tint: isSignedIn ? dangerColor : cs.primary,
              bg: isSignedIn
                  ? Color.alphaBlend(
                      dangerColor.withValues(alpha: 0.12), cs.surface)
                  : Color.alphaBlend(
                      cs.primary.withValues(alpha: 0.14), cs.surface),
              onTap: onAction,
            ),
          ],
        ],
      ),
    );
  }
}

class _SmallAvatar extends StatelessWidget {
  final String letter;

  const _SmallAvatar({required this.letter});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          cs.primary.withValues(alpha: isDark ? 0.18 : 0.12),
          cs.surface,
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? AppColors.green100Dark : AppColors.green100,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 18,
              color: cs.primary,
            ),
      ),
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  final IconData icon;
  final Color tint;
  final Color bg;
  final VoidCallback? onTap;

  const _SquareIconButton({
    required this.icon,
    required this.tint,
    required this.bg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: tint),
      ),
    );
  }
}

// ─── Student form ─────────────────────────────────────────────────────────

class _StudentForm extends StatelessWidget {
  final bool isSignedIn;
  final bool isLoading;
  final bool isSaving;
  final int selectedClass;
  final String preferredLanguage;
  final TextEditingController schoolController;
  final ValueChanged<int> onClassChanged;
  final ValueChanged<String> onLanguageChanged;
  final VoidCallback onSave;

  const _StudentForm({
    required this.isSignedIn,
    required this.isLoading,
    required this.isSaving,
    required this.selectedClass,
    required this.preferredLanguage,
    required this.schoolController,
    required this.onClassChanged,
    required this.onLanguageChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isBusy = isLoading || isSaving;
    final langLabel = const {
      'en': 'English',
      'or': 'Odia',
      'hi': 'Hindi',
    }[preferredLanguage] ??
        'English';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPad),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Field<int>(
            label: 'Class',
            value: 'Class $selectedClass',
            onTap: isBusy
                ? null
                : () => _showClassPicker(context, onClassChanged, selectedClass),
          ),
          const SizedBox(height: 12),
          _Field<String>(
            label: 'Preferred language',
            value: langLabel,
            onTap: isBusy
                ? null
                : () => _showLanguagePicker(
                    context, onLanguageChanged, preferredLanguage),
          ),
          const SizedBox(height: 12),
          _SchoolField(controller: schoolController, enabled: !isBusy),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isSignedIn && !isBusy ? onSave : null,
              icon: isSaving
                  ? const SizedBox.square(
                      dimension: 18,
                      child:
                          CircularProgressIndicator(strokeWidth: 2.2),
                    )
                  : const Icon(Icons.check_rounded, size: 18),
              label:
                  Text(isSignedIn ? 'Save profile' : 'Sign in to save'),
            ),
          ),
        ],
      ),
    );
  }

  void _showClassPicker(BuildContext context,
      ValueChanged<int> onChanged, int current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 12,
            itemBuilder: (_, i) {
              final c = i + 1;
              return ListTile(
                title: Text('Class $c'),
                trailing: c == current
                    ? Icon(Icons.check_rounded,
                        color: Theme.of(ctx).colorScheme.primary)
                    : null,
                onTap: () {
                  Navigator.of(ctx).pop();
                  onChanged(c);
                },
              );
            },
          ),
        );
      },
    );
  }

  void _showLanguagePicker(BuildContext context,
      ValueChanged<String> onChanged, String current) {
    const langs = {'en': 'English', 'or': 'Odia', 'hi': 'Hindi'};
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: langs.entries.map((e) {
              return ListTile(
                title: Text(e.value),
                trailing: e.key == current
                    ? Icon(Icons.check_rounded,
                        color: Theme.of(ctx).colorScheme.primary)
                    : null,
                onTap: () {
                  Navigator.of(ctx).pop();
                  onChanged(e.key);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _Field<T> extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _Field({required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.ink3Dark : AppColors.ink3,
              ),
        ),
        const SizedBox(height: 7),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surface3Dark : AppColors.surface3,
              border: Border.all(
                color: isDark
                    ? AppColors.hairline2Dark
                    : AppColors.hairline2,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: cs.onSurface,
                        ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 19,
                    color:
                        isDark ? AppColors.ink3Dark : AppColors.ink3),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SchoolField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  const _SchoolField({required this.controller, required this.enabled});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'School name',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.ink3Dark : AppColors.ink3,
              ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          enabled: enabled,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            hintText: 'e.g. SSVM',
          ),
        ),
      ],
    );
  }
}

class _MyLearningRow extends StatelessWidget {
  final VoidCallback onTap;

  const _MyLearningRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: ListRow(
        color: isDark ? AppColors.cMathsDark : AppColors.cMaths,
        icon: Icons.bar_chart_rounded,
        title: 'My Learning',
        sub: 'Streak, AI sessions, tools & reading progress',
        onTap: onTap,
        last: true,
      ),
    );
  }
}
