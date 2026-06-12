import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/avatars.dart';
import '../../data/services/backend_auth_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/avatar_provider.dart';
import '../../providers/books_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/user_selection_provider.dart';
import '../../providers/clay_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/calm_widgets.dart';
import '../../widgets/clay_card.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _schoolController = TextEditingController();
  final _nameController = TextEditingController();
  int _selectedClass = 8;
  String _preferredLanguage = 'en';
  String _board = 'scert_odisha';
  bool _isAuthBusy = false;
  bool _isProfileSaving = false;
  bool _isEditing = false;
  String? _appliedProfileKey;

  @override
  void initState() {
    super.initState();
    final selectedClasses = ref.read(userSelectionProvider).toList()..sort();
    if (selectedClasses.isNotEmpty) {
      _selectedClass = selectedClasses.first;
    }
    _board = ref.read(userBoardProvider);
  }

  @override
  void dispose() {
    _schoolController.dispose();
    _nameController.dispose();
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

    // Prefer the backend name (student-editable) over the Google account name.
    final backendName = cachedProfile?.name?.trim() ?? '';
    final firebaseName = user?.displayName?.trim() ?? '';
    final displayName = backendName.isNotEmpty
        ? backendName
        : (firebaseName.isNotEmpty ? firebaseName : 'Student');
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
              // Center the two action icons against the serif title's height so
              // they read as sitting on the same line as "Profile".
              trailing: SizedBox(
                height: Theme.of(context).textTheme.displayMedium!.fontSize! *
                    Theme.of(context).textTheme.displayMedium!.height!,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _ThemeToggle(
                      isDark:
                          Theme.of(context).brightness == Brightness.dark,
                      onTap: () =>
                          ref.read(themeModeProvider.notifier).toggle(),
                    ),
                    const SizedBox(width: 10),
                    IconBox(
                      icon: Icons.settings_rounded,
                      topMargin: 0,
                      onTap: () => context.push('/settings'),
                    ),
                  ],
                ),
              ),
            ),

            // ── Identity (avatar, name, email, sign-out) ─────────
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
              child: Center(
                child: Column(
                  children: [
                    _BigAvatar(
                      letter: avatarLetter,
                      avatar: ref.watch(selectedAvatarProvider),
                      clay: ref.watch(clayEnabledProvider),
                      onTap: _showAvatarPicker,
                    ),
                    const SizedBox(height: 10),
                    Text(displayName,
                        style:
                            Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontSize: 21,
                                )),
                    const SizedBox(height: 3),
                    Text(
                      isSignedIn
                          ? email
                          : 'Class $_selectedClass · ${_languageLabel(_preferredLanguage)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    authState.when(
                      data: (u) => _AuthButton(
                        isSignedIn: u != null,
                        isBusy: _isAuthBusy,
                        onTap: u != null ? _signOut : _signInWithGoogle,
                        onLongPress: kDebugMode && u != null
                            ? _copyFirebaseIdToken
                            : null,
                      ),
                      loading: () => const _AuthButton.loading(),
                      error: (_, _) => _AuthButton(
                        isSignedIn: false,
                        isBusy: _isAuthBusy,
                        onTap: () => ref.invalidate(authStateProvider),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── My Learning (tappable summary → /progress) ───────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding, 14, AppSpacing.screenPadding, 0),
              child: _StatsStrip(
                streak: progress.currentStreak,
                aiSessions: progress.aiSessions,
                books: books.length,
                onTap: () => context.push('/progress'),
              ),
            ),

            // ── Student profile form ─────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding, 16, AppSpacing.screenPadding, 0),
              child: const SectionHead(label: 'Student profile'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              child: _isEditing
                  ? _StudentForm(
                      isSignedIn: isSignedIn,
                      isLoading: isProfileLoading,
                      isSaving: _isProfileSaving,
                      selectedClass: _selectedClass,
                      preferredLanguage: _preferredLanguage,
                      board: _board,
                      nameController: _nameController,
                      schoolController: _schoolController,
                      onClassChanged: (v) => setState(() => _selectedClass = v),
                      onLanguageChanged: (v) =>
                          setState(() => _preferredLanguage = v),
                      onSave: _saveStudentProfile,
                      onCancel: _cancelEditing,
                    )
                  : _ProfileSummary(
                      isSignedIn: isSignedIn,
                      isLoading: isProfileLoading,
                      classNo: _selectedClass,
                      board: _board,
                      language: _languageLabel(_preferredLanguage),
                      school: _schoolController.text.trim(),
                      onEdit: isSignedIn
                          ? () => setState(() => _isEditing = true)
                          : null,
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
      profile.name ?? '',
      profile.board,
      profile.updatedAt?.toIso8601String() ?? '',
    ].join('|');
    if (_appliedProfileKey == key) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Never clobber in-progress edits with a background refresh.
      if (!mounted ||
          _appliedProfileKey == key ||
          _isProfileSaving ||
          _isEditing) {
        return;
      }
      setState(() {
        _appliedProfileKey = key;
        _selectedClass = profile.classNo;
        _preferredLanguage = profile.preferredLanguage;
        _board = profile.board;
        _schoolController.text = profile.schoolName ?? '';
        _nameController.text = profile.name ?? '';
      });
      _syncLocalProfile(profile.classNo, profile.board);
    });
  }

  /// Leave edit mode, restoring the last saved values.
  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _appliedProfileKey = null; // re-apply the cached profile on next build
    });
  }

  static String _languageLabel(String code) =>
      const {'en': 'English', 'or': 'Odia', 'hi': 'Hindi'}[code] ?? 'English';

  /// Avatar selection — preset illustrations only, no photo upload
  /// (under-13 privacy). Tapping a choice saves it immediately.
  void _showAvatarPicker() {
    final letter = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()[0].toUpperCase()
        : 'S';
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Consumer(
            builder: (ctx, ref, _) {
              final currentId = ref.watch(avatarIdProvider);
              return Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding, 18, AppSpacing.screenPadding, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Choose your avatar',
                      style: Theme.of(ctx).textTheme.headlineMedium?.copyWith(
                            fontSize: 18,
                          ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 18,
                      runSpacing: 16,
                      children: [
                        _AvatarChoice(
                          letter: letter,
                          selected: currentId == null,
                          onTap: () {
                            ref
                                .read(avatarIdProvider.notifier)
                                .setAvatarId(null);
                            Navigator.of(ctx).pop();
                          },
                        ),
                        for (final avatar in kStudentAvatars)
                          _AvatarChoice(
                            avatar: avatar,
                            selected: currentId == avatar.id,
                            onTap: () {
                              ref
                                  .read(avatarIdProvider.notifier)
                                  .setAvatarId(avatar.id);
                              Navigator.of(ctx).pop();
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
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
              board: _board,
              classNo: _selectedClass,
              preferredLanguage: _preferredLanguage,
              schoolName: _schoolController.text,
              name: _nameController.text,
            ),
          );

      _syncLocalProfile(savedProfile.classNo, savedProfile.board);
      if (!mounted) return;
      setState(() {
        _selectedClass = savedProfile.classNo;
        _preferredLanguage = savedProfile.preferredLanguage;
        _board = savedProfile.board;
        _schoolController.text = savedProfile.schoolName ?? '';
        _nameController.text = savedProfile.name ?? '';
        _isEditing = false;
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

  void _syncLocalProfile(int classNo, String board) {
    ref.read(userBoardProvider.notifier).setBoard(board);
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

// ─── Theme toggle (sun ↔ moon) ────────────────────────────────────────────
//
// A quick light/dark switch in the profile header. The icon cross-fades and
// rotates between a warm sun and a cool crescent moon so the change feels
// tactile, and the chip tints to match the active mode.

class _ThemeToggle extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _ThemeToggle({required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Warm amber for the sun, cool indigo for the moon.
    final accent = isDark ? const Color(0xFF9DB2E8) : const Color(0xFFE0A23B);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Color.alphaBlend(accent.withValues(alpha: 0.12), cs.surface),
          border: Border.all(color: accent.withValues(alpha: 0.32)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) => RotationTransition(
            turns: Tween<double>(begin: 0.6, end: 1).animate(animation),
            child: ScaleTransition(scale: animation, child: child),
          ),
          child: Icon(
            isDark
                ? Icons.nightlight_round
                : Icons.wb_sunny_rounded,
            key: ValueKey(isDark),
            size: 20,
            color: accent,
          ),
        ),
      ),
    );
  }
}

// ─── Big avatar (identity) ────────────────────────────────────────────────

class _BigAvatar extends StatelessWidget {
  final String letter;
  final StudentAvatar? avatar;
  final bool clay;
  final VoidCallback? onTap;

  const _BigAvatar({
    required this.letter,
    this.avatar,
    this.clay = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
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
                        color: (isDark
                                ? AppColors.clayShadowDark
                                : AppColors.clayShadow)
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
            child: avatar != null
                ? ClipOval(
                    child: SvgPicture.asset(
                      avatar!.assetPath,
                      width: 86,
                      height: 86,
                    ),
                  )
                : Text(
                    letter,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 38,
                          color: cs.primary,
                        ),
                  ),
          ),
          if (onTap != null)
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.surface, width: 2.5),
                ),
                child: Icon(
                  Icons.edit_rounded,
                  size: 13,
                  color: cs.onPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Avatar choice (picker sheet item) ────────────────────────────────────

class _AvatarChoice extends StatelessWidget {
  final StudentAvatar? avatar;
  final String letter;
  final bool selected;
  final VoidCallback onTap;

  const _AvatarChoice({
    this.avatar,
    this.letter = 'S',
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                cs.primary.withValues(alpha: isDark ? 0.18 : 0.12),
                cs.surface,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? cs.primary : cs.outline,
                width: selected ? 2.5 : 1,
              ),
            ),
            alignment: Alignment.center,
            child: avatar != null
                ? ClipOval(
                    child: SvgPicture.asset(
                      avatar!.assetPath,
                      width: 51,
                      height: 51,
                    ),
                  )
                : Text(
                    letter,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 24,
                          color: cs.primary,
                        ),
                  ),
          ),
          if (selected)
            Positioned(
              right: -3,
              top: -3,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.surface, width: 2),
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 12,
                  color: cs.onPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Stats strip ──────────────────────────────────────────────────────────

/// Tappable "My Learning" summary: a labeled card showing three headline stats
/// that opens the full progress page. The eyebrow + "View details ›" make the
/// card read as a doorway, not just decoration; tap-down dims it slightly so it
/// physically responds.
class _StatsStrip extends StatefulWidget {
  final int streak;
  final int aiSessions;
  final int books;
  final VoidCallback onTap;

  const _StatsStrip({
    required this.streak,
    required this.aiSessions,
    required this.books,
    required this.onTap,
  });

  @override
  State<_StatsStrip> createState() => _StatsStripState();
}

class _StatsStripState extends State<_StatsStrip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 90),
        opacity: _pressed ? 0.72 : 1,
        child: ClayCard(
          pressed: _pressed,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('MY LEARNING', style: kEyebrow(context)),
                  Row(
                    children: [
                      Text(
                        'View details',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: cs.primary,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _Stat(
                      color: isDark ? AppColors.cMathsDark : AppColors.cMaths,
                      icon: Icons.local_fire_department_rounded,
                      value: '${widget.streak}',
                      label: 'Day streak',
                    ),
                  ),
                  _Divider(),
                  Expanded(
                    child: _Stat(
                      color: isDark ? AppColors.cAiDark : AppColors.cAi,
                      icon: Icons.auto_awesome_rounded,
                      value: '${widget.aiSessions}',
                      label: 'AI sessions',
                    ),
                  ),
                  _Divider(),
                  Expanded(
                    child: _Stat(
                      color: isDark ? AppColors.cEnglishDark : AppColors.cEnglish,
                      icon: Icons.menu_book_rounded,
                      value: '${widget.books}',
                      label: 'Books',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 21,
                    height: 1,
                  ),
            ),
          ],
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
      height: 30,
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.hairline2Dark
          : AppColors.hairline2,
    );
  }
}

// ─── Auth button (sign in / sign out) ─────────────────────────────────────
//
// A single understated pill under the identity block. Long-press signs out in
// debug to copy the Firebase ID token (dev-only).

class _AuthButton extends StatelessWidget {
  final bool isSignedIn;
  final bool isBusy;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _AuthButton({
    required this.isSignedIn,
    required this.isBusy,
    this.onTap,
    this.onLongPress,
  });

  const _AuthButton.loading()
      : isSignedIn = false,
        isBusy = true,
        onTap = null,
        onLongPress = null;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dangerColor = isDark ? AppColors.cMathsDark : AppColors.cMaths;
    final accent = isSignedIn ? dangerColor : cs.primary;

    if (isBusy) {
      return const SizedBox.square(
        dimension: 22,
        child: CircularProgressIndicator(strokeWidth: 2.4),
      );
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: Color.alphaBlend(accent.withValues(alpha: 0.10), cs.surface),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: accent.withValues(alpha: 0.28)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSignedIn ? Icons.logout_rounded : Icons.login_rounded,
              size: 16,
              color: accent,
            ),
            const SizedBox(width: 7),
            Text(
              isSignedIn ? 'Sign out' : 'Sign in with Google',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Profile summary (view mode) ─────────────────────────────────────────

class _ProfileSummary extends StatelessWidget {
  final bool isSignedIn;
  final bool isLoading;
  final int classNo;
  final String board;
  final String language;
  final String school;
  final VoidCallback? onEdit;

  const _ProfileSummary({
    required this.isSignedIn,
    required this.isLoading,
    required this.classNo,
    required this.board,
    required this.language,
    required this.school,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.cardPad,
        4,
        AppSpacing.cardPad,
        AppSpacing.cardPad - 6,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryRow(label: 'Class', value: 'Class $classNo'),
          _SummaryRow(label: 'Board', value: _boardLabel(board)),
          _SummaryRow(label: 'Language', value: language),
          _SummaryRow(
            label: 'School',
            value: school.isEmpty ? 'Not set' : school,
            muted: school.isEmpty,
            last: true,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isLoading ? null : onEdit,
              style: OutlinedButton.styleFrom(
                foregroundColor: cs.primary,
                side: BorderSide(color: cs.outline),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              icon: const Icon(Icons.edit_rounded, size: 16),
              label: Text(
                isSignedIn ? 'Edit profile' : 'Sign in to edit',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: isSignedIn
                          ? cs.primary
                          : cs.onSurface.withValues(alpha: 0.4),
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool muted;
  final bool last;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.muted = false,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: last
          ? null
          : BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color:
                      isDark ? AppColors.hairline2Dark : AppColors.hairline2,
                ),
              ),
            ),
      child: Row(
        children: [
          SizedBox(
            width: 86,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: muted
                        ? (isDark ? AppColors.ink3Dark : AppColors.ink3)
                        : cs.onSurface,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

String _boardLabel(String board) =>
    board == 'scert_odisha' ? 'SCERT Odisha' : board;

// ─── Student form (edit mode) ────────────────────────────────────────────

class _StudentForm extends StatelessWidget {
  final bool isSignedIn;
  final bool isLoading;
  final bool isSaving;
  final int selectedClass;
  final String preferredLanguage;
  final String board;
  final TextEditingController nameController;
  final TextEditingController schoolController;
  final ValueChanged<int> onClassChanged;
  final ValueChanged<String> onLanguageChanged;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const _StudentForm({
    required this.isSignedIn,
    required this.isLoading,
    required this.isSaving,
    required this.selectedClass,
    required this.preferredLanguage,
    required this.board,
    required this.nameController,
    required this.schoolController,
    required this.onClassChanged,
    required this.onLanguageChanged,
    required this.onSave,
    required this.onCancel,
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
          _TextInput(
            label: 'Name',
            hint: 'Your name',
            controller: nameController,
            enabled: !isBusy,
          ),
          const SizedBox(height: 12),
          _Field<int>(
            label: 'Class',
            value: 'Class $selectedClass',
            onTap: isBusy
                ? null
                : () => _showClassPicker(context, onClassChanged, selectedClass),
          ),
          const SizedBox(height: 12),
          // Single supported board today; shown for transparency, picker
          // activates once the backend accepts more boards.
          _Field<String>(
            label: 'Board',
            value: _boardLabel(board),
            onTap: null,
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
          _TextInput(
            label: 'School name',
            hint: 'e.g. SSVM',
            controller: schoolController,
            enabled: !isBusy,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isBusy ? null : onCancel,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: cs.outline),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: isSignedIn && !isBusy ? onSave : null,
                  icon: isSaving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.2),
                        )
                      : const Icon(Icons.check_rounded, size: 18),
                  label:
                      Text(isSignedIn ? 'Save profile' : 'Sign in to save'),
                ),
              ),
            ],
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

class _TextInput extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool enabled;

  const _TextInput({
    required this.label,
    required this.hint,
    required this.controller,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
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
        TextField(
          controller: controller,
          enabled: enabled,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
