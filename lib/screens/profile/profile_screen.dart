import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../utils/haptics.dart';
import '../../data/avatars.dart';
import '../../data/models/learn_assist.dart' show LearnAssistApiException;
import '../../data/seed/seed_data.dart'
    show availableBoardIds, availableClassNumbersForBoard, boardLabel, boards;
import '../../data/services/backend_auth_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/avatar_provider.dart';
import '../../providers/core_providers.dart';
import '../../providers/books_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/user_selection_provider.dart';
import '../../providers/clay_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/calm_widgets.dart';
import '../../widgets/clay_card.dart';
import '../../widgets/pressable.dart';
import '../../widgets/support_section.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isAuthBusy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ensureProfile(forceRefresh: true);
    });
  }

  void _ensureProfile({bool forceRefresh = false}) {
    ref
        .read(backendAccountCacheProvider.notifier)
        .ensureProfile(forceRefresh: forceRefresh);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (previous, next) {
      if (previous?.value?.uid != next.value?.uid && next.value != null) {
        _ensureProfile();
      }
    });

    final authState = ref.watch(authStateProvider);
    final accountState = ref.watch(backendAccountCacheProvider);
    final isSignedIn = authState.maybeWhen(
      data: (user) => user != null,
      orElse: () => false,
    );
    final user = authState.maybeWhen(data: (u) => u, orElse: () => null);
    final cachedProfile = accountState.uid == user?.uid
        ? accountState.profile.maybeWhen(
            data: (profile) => profile,
            orElse: () => null,
          )
        : null;
    // Only a first load that is genuinely in flight blocks the form — until it
    // settles we don't know the student's saved name/school, so letting them
    // save would overwrite server data with blanks. Both halves matter: a
    // background revalidation (loaded, refreshing) must never disable the form
    // — that was the "Edit profile does nothing" report — and a profile that
    // was never requested must not either, so the form fails open, not shut.
    final isInitialProfileLoad =
        isSignedIn &&
        !accountState.profileLoaded &&
        accountState.profile is AsyncLoading;
    // A failed backend sync doesn't blank the screen (the form runs off local
    // prefs), but it silently stops the profile from staying in sync — surface
    // it so the student can retry rather than wonder why edits don't stick.
    final profileSyncFailed =
        isSignedIn &&
        accountState.profile is AsyncError &&
        cachedProfile == null;
    final int selectedClass =
        cachedProfile?.classNo ?? ref.watch(primaryClassProvider);
    final String board = cachedProfile?.board ?? ref.watch(userBoardProvider);
    final preferredLanguage =
        cachedProfile?.preferredLanguage ??
        ref.read(userPrefsRepositoryProvider).getPreferredLanguage() ??
        'en';

    // Prefer the backend name (student-editable) over the Google account name.
    final backendName = cachedProfile?.name?.trim() ?? '';
    final firebaseName = user?.displayName?.trim() ?? '';
    final displayName = _titleCase(
      backendName.isNotEmpty
          ? backendName
          : (firebaseName.isNotEmpty ? firebaseName : 'Student'),
    );
    final email = user?.email ?? '—';
    final avatarLetter = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : 'S';

    final progress = ref.watch(progressProvider);
    final books = ref.watch(selectedBooksProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            PageTitle(
              title: 'Profile',
              sub: 'Your account & learning',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ThemeToggle(
                    isDark: Theme.of(context).brightness == Brightness.dark,
                    onTap: () => ref.read(themeModeProvider.notifier).toggle(),
                  ),
                  const SizedBox(width: 10),
                  IconBox(
                    icon: Icons.settings_rounded,
                    tooltip: 'Settings',
                    onTap: () => context.push('/settings'),
                  ),
                ],
              ),
            ),

            // ── Student profile ─────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                16,
                AppSpacing.screenPadding,
                0,
              ),
              child: SectionHead(
                label: 'Student profile',
                action: 'Edit',
                onAction: isInitialProfileLoad
                    ? null
                    : () => _showProfileEditor(cachedProfile),
              ),
            ),
            if (isInitialProfileLoad)
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    SizedBox.square(
                      dimension: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Expanded(child: Text('Syncing your profile…')),
                  ],
                ),
              ),
            if (profileSyncFailed)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  8,
                  AppSpacing.screenPadding,
                  0,
                ),
                child: _ProfileSyncErrorBanner(
                  onRetry: () => _ensureProfile(forceRefresh: true),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: _ProfileSummary(
                identity: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _BigAvatar(
                      letter: avatarLetter,
                      avatar: ref.watch(selectedAvatarProvider),
                      clay: ref.watch(clayEnabledProvider),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontSize: AppFontSize.heading),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isSignedIn
                                ? email
                                : 'Class $selectedClass · ${_languageLabel(preferredLanguage)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                classNo: selectedClass,
                board: board,
                language: _languageLabel(preferredLanguage),
                school: cachedProfile?.schoolName?.trim() ?? '',
              ),
            ),

            if (!isSignedIn)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  12,
                  AppSpacing.screenPadding,
                  0,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _buildAuthButton(authState),
                ),
              ),

            // ── My Learning (tappable summary → /progress) ───────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                24,
                AppSpacing.screenPadding,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionHead(
                    label: 'My learning',
                    action: 'View progress',
                    onAction: () => context.push('/progress'),
                  ),
                  _StatsStrip(
                    streak: progress.currentStreak,
                    aiSessions: progress.aiSessions,
                    books: books.length,
                    onTap: () => context.push('/progress'),
                  ),
                ],
              ),
            ),

            const SupportSection(
              headingPadding: EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                24,
                AppSpacing.screenPadding,
                0,
              ),
            ),

            if (isSignedIn)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  24,
                  AppSpacing.screenPadding,
                  0,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _buildAuthButton(authState),
                ),
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthButton(AsyncValue<User?> authState) {
    return authState.when(
      data: (user) => _AuthButton(
        isSignedIn: user != null,
        isBusy: _isAuthBusy,
        onTap: user != null ? _signOut : _signInWithGoogle,
        onLongPress: kDebugMode && user != null ? _copyFirebaseIdToken : null,
      ),
      loading: () => const _AuthButton.loading(),
      error: (_, _) => _AuthButton(
        isSignedIn: false,
        isBusy: _isAuthBusy,
        onTap: () => ref.invalidate(authStateProvider),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    await _runAuthAction(() {
      return ref.read(authRepositoryProvider).signInWithGoogle();
    });
  }

  Future<void> _signOut() async {
    // Clearing the form is handled by the auth listener in `build`, so it also
    // covers a session that ends without this button (expired/revoked token).
    await _runAuthAction(() {
      return ref.read(authRepositoryProvider).signOut();
    });
  }

  Future<void> _showProfileEditor(StudentProfile? profile) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      useSafeArea: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ProfileEditSheet(profile: profile),
    );
    if (mounted) setState(() {});
  }

  /// Capitalises the first letter of each word for display ("rudra mohanty"
  /// → "Rudra Mohanty"), leaving the rest alone so names like "McKay" keep
  /// their casing. Display only — the saved name is untouched.
  static String _titleCase(String name) => name
      .split(' ')
      .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
      .join(' ');

  static String _languageLabel(String code) =>
      const {'en': 'English', 'or': 'Odia', 'hi': 'Hindi'}[code] ?? 'English';

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
      // The user backing out of the Google sheet is not an error — stay quiet.
      if (_isUserCancellation(error)) return;
      Haptics.error(ref);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_friendlyAuthError(error))));
    } finally {
      if (mounted) {
        setState(() => _isAuthBusy = false);
      }
    }
  }

  /// True when [error] is the user dismissing the Google sign-in sheet, which
  /// google_sign_in surfaces as a thrown "canceled" exception.
  bool _isUserCancellation(Object error) {
    final s = error.toString().toLowerCase();
    return s.contains('cancel') || s.contains('aborted');
  }

  /// Turns a raw auth exception into a calm, student-friendly line instead of
  /// dumping `[firebase_auth/...]` plugin text into the snackbar.
  String _friendlyAuthError(Object error) {
    final s = error.toString().toLowerCase();
    if (s.contains('network') || s.contains('timeout')) {
      return 'No internet connection. Please check your network and try again.';
    }
    if (s.contains('not supported')) {
      return 'Google sign-in isn\'t available on this device.';
    }
    if (s.contains('sign in again') || s.contains('credential')) {
      return 'Your session expired. Please sign in again.';
    }
    return 'Couldn\'t complete that. Please try again.';
  }
}

// ─── Profile editor ─────────────────────────────────────────────────────

class _ProfileEditSheet extends ConsumerStatefulWidget {
  final StudentProfile? profile;

  const _ProfileEditSheet({this.profile});

  @override
  ConsumerState<_ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends ConsumerState<_ProfileEditSheet> {
  late final TextEditingController _schoolController;
  late final TextEditingController _nameController;
  late final String? _uid;
  late int _selectedClass;
  late String _board;
  late String _preferredLanguage;
  late String? _avatarId;
  late int _revision;
  bool _isProfileSaving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    final user = ref.read(authStateProvider).value;
    _uid = user?.uid;
    _schoolController = TextEditingController(text: profile?.schoolName ?? '');
    _nameController = TextEditingController(
      text: profile?.name ?? user?.displayName ?? '',
    );
    _selectedClass = profile?.classNo ?? ref.read(primaryClassProvider);
    _board = profile?.board ?? ref.read(userBoardProvider);
    _preferredLanguage =
        profile?.preferredLanguage ??
        ref.read(userPrefsRepositoryProvider).getPreferredLanguage() ??
        'en';
    _avatarId = ref.read(effectiveAvatarIdProvider);
    _revision = profile?.revision ?? 0;
  }

  @override
  void dispose() {
    _schoolController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (previous, next) {
      if (!next.isLoading && next.value?.uid != _uid && mounted) {
        final editorRoute = ModalRoute.of(context);
        final navigator = Navigator.of(context);
        navigator.popUntil((route) => route == editorRoute);
        navigator.pop();
      }
    });
    final letter = _nameController.text.trim().isEmpty
        ? 'S'
        : _nameController.text.trim()[0].toUpperCase();
    return BackButtonListener(
      onBackButtonPressed: () async => _isProfileSaving,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Edit profile',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Cancel editing',
                      onPressed: _isProfileSaving
                          ? null
                          : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Center(
                  child: Stack(
                    children: [
                      _BigAvatar(
                        letter: letter,
                        avatar: avatarById(_avatarId),
                        clay: ref.watch(clayEnabledProvider),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: IconButton.filled(
                          tooltip: 'Change avatar',
                          onPressed: _isProfileSaving
                              ? null
                              : _showAvatarPicker,
                          iconSize: 16,
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.edit_rounded),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_saveError != null) ...[
                  Text(
                    _saveError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                _StudentForm(
                  isSignedIn: _uid != null,
                  isSaving: _isProfileSaving,
                  selectedClass: _selectedClass,
                  preferredLanguage: _preferredLanguage,
                  board: _board,
                  nameController: _nameController,
                  schoolController: _schoolController,
                  onClassChanged: (value) =>
                      setState(() => _selectedClass = value),
                  onLanguageChanged: (value) =>
                      setState(() => _preferredLanguage = value),
                  onBoardChanged: _selectBoardForEditing,
                  onSave: _saveStudentProfile,
                  onCancel: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showAvatarPicker() async {
    FocusScope.of(context).unfocus();
    final letter = _nameController.text.trim().isEmpty
        ? 'S'
        : _nameController.text.trim()[0].toUpperCase();
    // A record distinguishes choosing the default (null ID) from dismissal.
    final choice = await showModalBottomSheet<(String?,)>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (pickerContext) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Choose your avatar',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close avatar picker',
                    onPressed: () => Navigator.of(pickerContext).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _AvatarChoice(
                    letter: letter,
                    selected: _avatarId == null,
                    onTap: () => Navigator.of(pickerContext).pop((null,)),
                  ),
                  for (final avatar in kStudentAvatars)
                    _AvatarChoice(
                      avatar: avatar,
                      selected: _avatarId == avatar.id,
                      onTap: () =>
                          Navigator.of(pickerContext).pop((avatar.id,)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (mounted && choice != null) setState(() => _avatarId = choice.$1);
  }

  Future<void> _saveStudentProfile() async {
    final user = ref.read(firebaseAuthProvider).currentUser;
    if (user?.uid != _uid) return;
    if (user == null) {
      // Class, board and language are local prefs, so a signed-out student
      // can still change them — only name/school need the backend.
      _syncLocalProfile(
        _selectedClass,
        _board,
        _preferredLanguage,
        syncExploreClass: true,
      );
      ref.read(avatarIdProvider.notifier).setAvatarId(_avatarId);
      Navigator.of(context).pop();
      Haptics.medium(ref);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated.')));
      return;
    }

    setState(() {
      _isProfileSaving = true;
      _saveError = null;
    });
    var submittedRevision = 0;
    try {
      submittedRevision = _revision;
      final savedProfile = await ref
          .read(backendAccountCacheProvider.notifier)
          .saveProfile(
            StudentProfile(
              avatarId: _avatarId,
              board: _board,
              classNo: _selectedClass,
              preferredLanguage: _preferredLanguage,
              schoolName: _schoolController.text,
              name: _nameController.text,
              revision: submittedRevision,
            ),
          );

      if (!mounted ||
          ref.read(firebaseAuthProvider).currentUser?.uid != user.uid) {
        return;
      }
      if (submittedRevision == 0 && savedProfile.revision == 1) {
        unawaited(
          ref
              .read(learningEventServiceProvider)
              .recordBestEffort(
                eventType: 'onboarding_completed',
                feature: 'session',
              ),
        );
      }
      _syncLocalProfile(
        savedProfile.classNo,
        savedProfile.board,
        savedProfile.preferredLanguage,
      );
      setState(() {
        _selectedClass = savedProfile.classNo;
        _preferredLanguage = savedProfile.preferredLanguage;
        _board = savedProfile.board;
        _schoolController.text = savedProfile.schoolName ?? '';
        _nameController.text = savedProfile.name ?? '';
        _avatarId = savedProfile.avatarId;
        _revision = savedProfile.revision;
      });
      Haptics.medium(ref);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted ||
          ref.read(firebaseAuthProvider).currentUser?.uid != user.uid) {
        return;
      }
      Haptics.error(ref);
      if (error is LearnAssistApiException &&
          error.code == 'profile_conflict') {
        StudentProfile? latest;
        try {
          latest = await ref
              .read(backendAccountCacheProvider.notifier)
              .ensureProfile(forceRefresh: true);
        } catch (_) {
          // Keep the student's edits. A later retry will re-fetch the profile.
        }
        // AccountCache may return its stale cached profile when a refresh
        // fails. A conflict guarantees the server has a newer revision.
        if (latest != null && latest.revision <= submittedRevision) {
          latest = null;
        }
        if (!mounted ||
            ref.read(firebaseAuthProvider).currentUser?.uid != user.uid) {
          return;
        }
        if (latest != null) {
          final useLatest = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Profile changed elsewhere'),
              content: Text(
                'The latest saved profile is ${latest!.name ?? 'Student'}, '
                'class ${latest.classNo} (${boardLabel(latest.board)}), '
                'language ${latest.preferredLanguage}, '
                'school ${latest.schoolName ?? 'none'}. '
                'Your edits are still here. Use the latest profile or keep '
                'editing and save your version?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Keep my edits'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Use latest'),
                ),
              ],
            ),
          );
          if (!mounted ||
              ref.read(firebaseAuthProvider).currentUser?.uid != _uid) {
            return;
          }
          if (useLatest == true) {
            setState(() {
              _selectedClass = latest!.classNo;
              _preferredLanguage = latest.preferredLanguage;
              _board = latest.board;
              _schoolController.text = latest.schoolName ?? '';
              _nameController.text = latest.name ?? '';
              _avatarId = latest.avatarId;
              _revision = latest.revision;
            });
            _syncLocalProfile(
              latest.classNo,
              latest.board,
              latest.preferredLanguage,
            );
            if (mounted) Navigator.of(context).pop();
          } else if (mounted) {
            // A deliberate retry applies this draft against the version the
            // student just reviewed, not an unrelated background refresh.
            _revision = latest.revision;
          }
        } else {
          setState(
            () => _saveError =
                'Profile changed elsewhere. Your edits are kept; please try saving again.',
          );
        }
        return;
      }
      setState(
        () => _saveError = "Couldn't save your profile. Please try again.",
      );
    } finally {
      if (mounted) {
        setState(() => _isProfileSaving = false);
      }
    }
  }

  void _syncLocalProfile(
    int classNo,
    String board,
    String language, {
    bool syncExploreClass = false,
  }) {
    ref.read(userBoardProvider.notifier).setBoard(board);
    ref.read(primaryClassProvider.notifier).setClass(classNo);
    if (syncExploreClass) {
      final prefs = ref.read(userPrefsRepositoryProvider);
      if (prefs.getExploreSelectionMode() == 'primary') {
        ref.read(exploreClassSelectionProvider.notifier).setClasses({classNo});
      }
      if (prefs.getLibrarySelectionMode() == 'primary') {
        ref.read(libraryClassSelectionProvider.notifier).setClasses({classNo});
      }
    }
    ref.read(subjectFilterProvider.notifier).setFilter(null);
    ref.read(userPrefsRepositoryProvider).setPreferredLanguage(language);
  }

  void _selectBoardForEditing(String board) {
    final availableClasses = availableClassNumbersForBoard(board).toList()
      ..sort();
    if (availableClasses.isEmpty) return;

    setState(() {
      _board = board;
      if (!availableClasses.contains(_selectedClass)) {
        _selectedClass = availableClasses.first;
      }
    });
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

    return Tooltip(
      message: isDark ? 'Switch to light mode' : 'Switch to dark mode',
      child: Pressable(
        onTap: onTap,
        scale: 0.92,
        child: Container(
          width: kPageTitleRowHeight,
          height: kPageTitleRowHeight,
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
              isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
              key: ValueKey(isDark),
              size: 20,
              color: accent,
            ),
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

  const _BigAvatar({required this.letter, this.avatar, this.clay = true});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
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
                      color:
                          (isDark
                                  ? AppColors.clayShadowDark
                                  : AppColors.clayShadow)
                              .withValues(alpha: isDark ? 0.55 : 0.7),
                      blurRadius: 16,
                      offset: const Offset(5, 5),
                    ),
                    BoxShadow(
                      color:
                          (isDark
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
                    fontSize: AppFontSize.displayLarge,
                    color: cs.primary,
                  ),
                ),
        ),
      ],
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
    return Semantics(
      label: avatar?.label ?? 'Default avatar',
      excludeSemantics: true,
      selected: selected,
      button: true,
      child: GestureDetector(
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
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(
                            fontSize: AppFontSize.headingLarge,
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
      ),
    );
  }
}

// ─── Stats strip ──────────────────────────────────────────────────────────

/// Tappable learning statistics; the section heading sits above the card.
/// Tap-down dims the card before opening the full progress page.
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
          child: Row(
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
                  label: 'My books',
                ),
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
                fontSize: AppFontSize.heading,
                height: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontSize: AppFontSize.small,
            fontWeight: AppFontWeight.medium,
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
            Flexible(
              child: Text(
                isSignedIn ? 'Sign out' : 'Sign in with Google',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: accent,
                  fontWeight: AppFontWeight.semibold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Profile sync error ──────────────────────────────────────────────────

class _ProfileSyncErrorBanner extends StatelessWidget {
  final VoidCallback onRetry;

  const _ProfileSyncErrorBanner({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_rounded, size: 18, color: cs.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Couldn't sync your profile.",
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: cs.onErrorContainer),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              minimumSize: const Size(0, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ─── Profile summary (view mode) ─────────────────────────────────────────

class _ProfileSummary extends StatelessWidget {
  final Widget identity;
  final int classNo;
  final String board;
  final String language;
  final String school;

  const _ProfileSummary({
    required this.identity,
    required this.classNo,
    required this.board,
    required this.language,
    required this.school,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
          identity,
          const SizedBox(height: 20),
          Divider(height: 1, color: cs.outline),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final singleColumn =
                  constraints.maxWidth < 240 ||
                  MediaQuery.textScalerOf(context).scale(AppFontSize.body) > 20;
              final width = singleColumn
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 16) / 2;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: width,
                    child: _ProfileDetail(
                      label: 'Class',
                      value: 'Class $classNo',
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _ProfileDetail(
                      label: 'Board',
                      value: boardLabel(board),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _ProfileDetail(label: 'Language', value: language),
                  ),
                  SizedBox(
                    width: width,
                    child: _ProfileDetail(
                      label: 'School',
                      value: school.isEmpty ? 'Not added' : school,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileDetail extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: AppFontWeight.semibold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

// ─── Student form (edit mode) ────────────────────────────────────────────

class _StudentForm extends StatelessWidget {
  final bool isSignedIn;

  final bool isSaving;
  final int selectedClass;
  final String preferredLanguage;
  final String board;
  final TextEditingController nameController;
  final TextEditingController schoolController;
  final ValueChanged<int> onClassChanged;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<String> onBoardChanged;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const _StudentForm({
    required this.isSignedIn,
    required this.isSaving,
    required this.selectedClass,
    required this.preferredLanguage,
    required this.board,
    required this.nameController,
    required this.schoolController,
    required this.onClassChanged,
    required this.onLanguageChanged,
    required this.onBoardChanged,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isBusy = isSaving;
    final langLabel =
        const {
          'en': 'English',
          'or': 'Odia',
          'hi': 'Hindi',
        }[preferredLanguage] ??
        'English';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TextInput(
          label: 'Name',
          hint: 'Your name',
          controller: nameController,
          enabled: isSignedIn && !isBusy,
          onDisabledTap: isSignedIn ? null : () => _showSignInNudge(context),
        ),
        const SizedBox(height: 8),
        _Field<int>(
          label: 'Class',
          value: 'Class $selectedClass',
          onTap: isBusy
              ? null
              : () => _showClassPicker(
                  context,
                  onClassChanged,
                  selectedClass,
                  board,
                ),
        ),
        const SizedBox(height: 8),
        _Field<String>(
          label: 'Board',
          value: boardLabel(board),
          onTap: isBusy
              ? null
              : () => _showBoardPicker(context, onBoardChanged, board),
        ),
        const SizedBox(height: 8),
        _Field<String>(
          label: 'Preferred language',
          value: langLabel,
          onTap: isBusy
              ? null
              : () => _showLanguagePicker(
                  context,
                  onLanguageChanged,
                  preferredLanguage,
                ),
        ),
        const SizedBox(height: 8),
        _TextInput(
          label: 'School name',
          hint: 'e.g. SSVM',
          controller: schoolController,
          enabled: isSignedIn && !isBusy,
          onDisabledTap: isSignedIn ? null : () => _showSignInNudge(context),
        ),
        if (!isSignedIn) ...[
          const SizedBox(height: 10),
          Text(
            'Sign in to change your name and school.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                // Cancel stays live even mid-load: it only drops back to the
                // summary, and a student must always be able to back out.
                onPressed: isSaving ? null : onCancel,
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
                onPressed: isBusy ? null : onSave,
                icon: isSaving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2.2),
                      )
                    : const Icon(Icons.check_rounded, size: 18),
                label: Text(isSignedIn ? 'Save profile' : 'Save'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showSignInNudge(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Sign in to edit your name and school.')),
      );
  }

  void _showClassPicker(
    BuildContext context,
    ValueChanged<int> onChanged,
    int current,
    String board,
  ) {
    final availableClasses = availableClassNumbersForBoard(board);
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 12,
            itemBuilder: (_, i) {
              final c = i + 1;
              final isAvailable = availableClasses.contains(c);
              return ListTile(
                title: Text('Class $c'),
                subtitle: isAvailable ? null : const Text('Coming soon'),
                trailing: c == current
                    ? Icon(
                        Icons.check_rounded,
                        color: Theme.of(ctx).colorScheme.primary,
                      )
                    : null,
                enabled: isAvailable,
                onTap: isAvailable
                    ? () {
                        Navigator.of(ctx).pop();
                        onChanged(c);
                      }
                    : null,
              );
            },
          ),
        );
      },
    );
  }

  void _showBoardPicker(
    BuildContext context,
    ValueChanged<String> onChanged,
    String current,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: boards.map((b) {
              final isAvailable = availableBoardIds.contains(b.id);
              return ListTile(
                title: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: b.name),
                      TextSpan(
                        text: b.id == 'scert_odisha'
                            ? ' (Odia Medium)'
                            : ' (CBSE)',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                subtitle: Text(
                  isAvailable ? b.state : '${b.state} · Coming soon',
                ),
                trailing: b.id == current
                    ? Icon(
                        Icons.check_rounded,
                        color: Theme.of(ctx).colorScheme.primary,
                      )
                    : null,
                enabled: isAvailable,
                onTap: isAvailable
                    ? () {
                        Navigator.of(ctx).pop();
                        onChanged(b.id);
                      }
                    : null,
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showLanguagePicker(
    BuildContext context,
    ValueChanged<String> onChanged,
    String current,
  ) {
    const langs = {'en': 'English', 'or': 'Odia', 'hi': 'Hindi'};
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: langs.entries.map((e) {
              return ListTile(
                title: Text(e.value),
                trailing: e.key == current
                    ? Icon(
                        Icons.check_rounded,
                        color: Theme.of(ctx).colorScheme.primary,
                      )
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
            fontSize: AppFontSize.small,
            fontWeight: AppFontWeight.semibold,
            color: isDark ? AppColors.ink3Dark : AppColors.ink3,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surface3Dark : AppColors.surface3,
              border: Border.all(
                color: isDark ? AppColors.hairline2Dark : AppColors.hairline2,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: AppFontSize.body,
                      fontWeight: AppFontWeight.medium,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 19,
                  color: isDark ? AppColors.ink3Dark : AppColors.ink3,
                ),
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

  /// Called when the field is tapped while disabled (a disabled TextField
  /// ignores pointers, so the tap falls through to a wrapping detector).
  final VoidCallback? onDisabledTap;

  const _TextInput({
    required this.label,
    required this.hint,
    required this.controller,
    required this.enabled,
    this.onDisabledTap,
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
            fontSize: AppFontSize.small,
            fontWeight: AppFontWeight.semibold,
            color: isDark ? AppColors.ink3Dark : AppColors.ink3,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? null : onDisabledTap,
          child: TextField(
            controller: controller,
            enabled: enabled,
            textInputAction: TextInputAction.done,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontSize: AppFontSize.body),
            decoration: InputDecoration(
              hintText: hint,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              constraints: const BoxConstraints(minHeight: 44),
            ),
          ),
        ),
      ],
    );
  }
}
