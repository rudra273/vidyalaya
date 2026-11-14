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
import '../../providers/books_provider.dart' show subjectFilterProvider;
import '../../providers/core_providers.dart';
import '../../providers/plus_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/rollout_switches_provider.dart';
import '../../providers/user_selection_provider.dart';
import '../../widgets/calm_widgets.dart';
import '../../data/services/app_share.dart';
import 'widgets/profile_activity.dart';
import 'widgets/streak_week.dart';
import 'widgets/plus_card.dart';
import 'widgets/settings_group.dart';

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
      if (!mounted) return;
      _ensureProfile(forceRefresh: true);
      // An approval since the last look shows up here.
      ref.read(plusProvider.notifier).refresh();
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
    final avatarLetter = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : 'S';

    final progress = ref.watch(progressProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final edit = isInitialProfileLoad
        ? null
        : () => _showProfileEditor(cachedProfile);
    const inset = EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding);

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.green100Dark : AppColors.green100,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(36),
                  ),
                ),
                padding: EdgeInsets.only(
                  top: MediaQuery.paddingOf(context).top,
                  bottom: isSignedIn ? 24 : 12,
                ),
                child: Column(
                  children: [
                    PageTitle(
                      title: 'Profile',
                      trailing: IconButton(
                        icon: const Icon(Icons.settings_rounded),
                        tooltip: 'Settings',
                        onPressed: () => context.push('/settings'),
                      ),
                    ),
                    // ── Student card ────────────────────────────────
                    if (isInitialProfileLoad)
                      const Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.screenPadding,
                          0,
                          AppSpacing.screenPadding,
                          12,
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
                          0,
                          AppSpacing.screenPadding,
                          12,
                        ),
                        child: _ProfileSyncErrorBanner(
                          onRetry: () => _ensureProfile(forceRefresh: true),
                        ),
                      ),
                    Padding(
                      padding: inset,
                      child: _StudentCard(
                        avatar: _BigAvatar(
                          letter: avatarLetter,
                          avatar: ref.watch(selectedAvatarProvider),
                          size: 74,
                        ),
                        name: displayName,
                        subtitle: 'Class $selectedClass · ${boardLabel(board)}',
                        onEdit: edit,
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
                        child: _buildAuthButton(authState),
                      ),
                  ],
                ),
              ),
              if (isSignedIn) const PlusCard(),
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
                    StreakWeek(
                      streak: progress.currentStreak,
                      onTap: () => context.push('/progress'),
                    ),
                    const SizedBox(height: 24),
                    const SectionHead(label: 'Your learning activity'),
                    ProfileActivityCard(
                      locked: !isSignedIn,
                      onProgress: () => context.push('/progress'),
                    ),
                    const SizedBox(height: 24),
                    const SectionHead(label: 'Your learning setup'),
                    SettingsGroup(
                      showBorder: false,
                      children: [
                        SettingsRow(
                          color: isDark
                              ? AppColors.green500Dark
                              : AppColors.green700,
                          icon: Icons.school_outlined,
                          title: 'Class & board',
                          sub: 'Class $selectedClass · ${boardLabel(board)}',
                          onTap: edit == null || profileSyncFailed
                              ? null
                              : () => _showProfileEditor(
                                  cachedProfile,
                                  section: _ProfileSection.curriculum,
                                ),
                        ),
                        SettingsRow(
                          color: isDark
                              ? AppColors.cTutorDark
                              : AppColors.cTutor,
                          icon: Icons.translate_rounded,
                          title: 'Answer language',
                          sub: _languageLabel(preferredLanguage),
                          onTap: edit == null || profileSyncFailed
                              ? null
                              : () => _showProfileEditor(
                                  cachedProfile,
                                  section: _ProfileSection.language,
                                ),
                        ),
                        if (ref.watch(booksEnabledProvider))
                          SettingsRow(
                            color: isDark
                                ? AppColors.cEnglishDark
                                : AppColors.cEnglish,
                            icon: Icons.file_download_outlined,
                            title: 'Manage downloads',
                            sub: 'Download or delete offline books',
                            onTap: () => context.push('/manage-downloads'),
                          ),
                      ],
                    ),
                    if (isSignedIn) ...[
                      const SizedBox(height: 12),
                      _buildAuthButton(authState),
                    ],
                    const SizedBox(height: 24),
                    SettingsGroup(
                      showBorder: false,
                      children: [
                        SettingsRow(
                          color: theme.colorScheme.primary,
                          icon: Icons.share_outlined,
                          title: 'Share Vidyakalp',
                          sub: 'Invite a friend to learn with you',
                          onTap: () {
                            Haptics.light(ref);
                            AppShare.shareApp();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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

  Future<void> _showProfileEditor(
    StudentProfile? profile, {
    _ProfileSection section = _ProfileSection.full,
  }) async {
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
      builder: (_) => _ProfileEditSheet(profile: profile, section: section),
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

enum _ProfileSection {
  full('Update profile', 'Save profile'),
  curriculum('Class & board', 'Save learning setup'),
  language('Answer language', 'Save language');

  const _ProfileSection(this.title, this.saveLabel);
  final String title;
  final String saveLabel;
}

class _ProfileEditSheet extends ConsumerStatefulWidget {
  final StudentProfile? profile;

  final _ProfileSection section;

  const _ProfileEditSheet({this.profile, required this.section});

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
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
                              widget.section.title,
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
                      if (widget.section == _ProfileSection.full)
                        Center(
                          child: Stack(
                            children: [
                              _BigAvatar(
                                letter: letter,
                                avatar: avatarById(_avatarId),
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
                        section: widget.section,
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
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  8,
                  AppSpacing.screenPadding,
                  12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        // Cancel stays live even mid-load: it only drops back to the
                        // summary, and a student must always be able to back out.
                        onPressed: _isProfileSaving
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
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
                        onPressed: _isProfileSaving
                            ? null
                            : _saveStudentProfile,
                        icon: _isProfileSaving
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                ),
                              )
                            : const Icon(Icons.check_rounded, size: 18),
                        label: Text(widget.section.saveLabel),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
            if (widget.section != _ProfileSection.full) {
              _nameController.text = latest.name ?? '';
              _schoolController.text = latest.schoolName ?? '';
              _avatarId = latest.avatarId;
              if (widget.section == _ProfileSection.language) {
                _board = latest.board;
                _selectedClass = latest.classNo;
              } else {
                _preferredLanguage = latest.preferredLanguage;
              }
            }
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

// ─── Big avatar (identity) ────────────────────────────────────────────────

class _BigAvatar extends StatelessWidget {
  final String letter;
  final StudentAvatar? avatar;
  final double size;

  const _BigAvatar({required this.letter, this.avatar, this.size = 88});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: size,
      height: size,
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
      child: avatar != null
          ? ClipOval(
              child: SvgPicture.asset(
                avatar!.assetPath,
                width: size - 2,
                height: size - 2,
              ),
            )
          : Text(
              letter,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: size >= 80
                    ? AppFontSize.displayLarge
                    : AppFontSize.displaySmall,
                color: cs.primary,
              ),
            ),
    );
  }
}

// ─── Student card ─────────────────────────────────────────────────────────
//
class _StudentCard extends StatelessWidget {
  const _StudentCard({
    required this.avatar,
    required this.name,
    required this.subtitle,
    required this.onEdit,
  });

  final Widget avatar;
  final String name;
  final String subtitle;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        avatar,
        const SizedBox(height: 8),
        Text(
          name,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall,
        ),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        SettingsGroup(
          showBorder: false,
          children: [
            SettingsRow(
              color: theme.colorScheme.primary,
              icon: Icons.edit_outlined,
              title: 'Update profile',
              onTap: onEdit,
            ),
          ],
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

// ─── Auth button (sign in / sign out) ─────────────────────────────────────
//
// Signed out: a single understated pill under the identity card. Signed in: a
// quiet full-width row at the foot of the page, so leaving the account is easy
// to find but never shouts. Long-press on Sign out copies the Firebase ID
// token in debug builds (dev-only).

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

    if (isSignedIn) {
      final muted = isDark ? AppColors.ink2Dark : AppColors.ink2;
      return SettingsGroup(
        showBorder: false,
        children: [
          SettingsRow(
            color: cs.error,
            icon: Icons.logout_rounded,
            title: 'Sign out',
            titleColor: muted,
            showChevron: false,
            trailing: isBusy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  )
                : null,
            onTap: isBusy ? null : onTap,
            onLongPress: isBusy ? null : onLongPress,
          ),
        ],
      );
    }

    if (isBusy) {
      return const SizedBox.square(
        dimension: 22,
        child: CircularProgressIndicator(strokeWidth: 2.4),
      );
    }

    final accent = cs.primary;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: Color.alphaBlend(accent.withValues(alpha: 0.10), cs.surface),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.login_rounded, size: 16, color: accent),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                'Sign in with Google',
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

// ─── Student form (edit mode) ────────────────────────────────────────────

class _StudentForm extends StatelessWidget {
  final _ProfileSection section;
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

  const _StudentForm({
    required this.section,
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
  });

  @override
  Widget build(BuildContext context) {
    final isBusy = isSaving;
    final classes = availableClassNumbersForBoard(board).toList()..sort();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section == _ProfileSection.full) ...[
          Text('Personal details', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          _TextInput(
            label: 'Name',
            hint: 'Your name',
            controller: nameController,
            enabled: isSignedIn && !isBusy,
            onDisabledTap: isSignedIn ? null : () => _showSignInNudge(context),
          ),
          const SizedBox(height: 8),
          _TextInput(
            label: 'School name',
            hint: 'Your school',
            controller: schoolController,
            enabled: isSignedIn && !isBusy,
            onDisabledTap: isSignedIn ? null : () => _showSignInNudge(context),
          ),
          if (!isSignedIn)
            Text(
              'Sign in to change your name and school.',
              style: theme.textTheme.bodySmall,
            ),
          const SizedBox(height: 20),
          Text('Learning preferences', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
        ],
        if (section != _ProfileSection.language) ...[
          _ProfileOptionPicker(
            label: 'Your board',
            value: board,
            onChanged: isBusy ? null : onBoardChanged,
            options: [
              for (final option in boards)
                DropdownMenuItem(
                  value: option.id,
                  enabled: availableBoardIds.contains(option.id),
                  child: Text(
                    availableBoardIds.contains(option.id)
                        ? option.name
                        : '${option.name} · Coming soon',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Your class', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final classNo in classes)
                ChoiceChip(
                  label: Text('Class $classNo'),
                  selected: selectedClass == classNo,
                  onSelected: isBusy ? null : (_) => onClassChanged(classNo),
                ),
            ],
          ),
        ],
        if (section != _ProfileSection.curriculum) ...[
          if (section == _ProfileSection.full) const SizedBox(height: 16),
          _ProfileOptionPicker(
            label: 'Answer language',
            value: preferredLanguage,
            onChanged: isBusy ? null : onLanguageChanged,
            options: const [
              DropdownMenuItem(value: 'or', child: Text('ଓଡ଼ିଆ · Odia')),
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'hi', child: Text('हिन्दी · Hindi')),
            ],
          ),
        ],
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
}

class _ProfileOptionPicker extends StatelessWidget {
  const _ProfileOptionPicker({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<DropdownMenuItem<String>> options;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final change = onChanged;
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        enabled: change != null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: options.any((option) => option.value == value) ? value : null,
          hint: Text('Select $label'),
          items: options,
          isExpanded: true,
          menuMaxHeight: 320,
          onChanged: change == null
              ? null
              : (selection) {
                  if (selection != null) change(selection);
                },
        ),
      ),
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
