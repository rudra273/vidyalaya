import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyalaya/data/services/backend_auth_service.dart';
import 'package:vidyalaya/providers/auth_provider.dart';
import 'package:vidyalaya/providers/avatar_provider.dart';
import 'package:vidyalaya/providers/core_providers.dart';
import 'package:vidyalaya/screens/profile/profile_screen.dart';

class _User extends Fake implements User {
  @override
  String get uid => 'student-a';
  @override
  String get displayName => 'Asha';
  @override
  String get email => 'asha@example.test';
}

class _Auth extends Fake implements FirebaseAuth {
  @override
  User? currentUser = _User();
}

const _initial = StudentProfile(
  board: 'scert_odisha',
  classNo: 8,
  preferredLanguage: 'en',
  name: 'Asha',
  schoolName: 'School',
  avatarId: 'girl_1',
  revision: 3,
);

class _Cache extends BackendAccountCache {
  StudentProfile? submitted;
  bool fail = false;
  Completer<void>? saving;

  void refreshProfile(StudentProfile profile) {
    state = state.copyWith(profile: AsyncData(profile));
  }

  @override
  BackendAccountState build() => BackendAccountState(
    uid: 'student-a',
    profile: const AsyncData(_initial),
    profileLoaded: true,
  );

  @override
  Future<StudentProfile?> ensureProfile({bool forceRefresh = false}) async =>
      state.profile.value;

  @override
  Future<StudentProfile> saveProfile(StudentProfile profile) async {
    submitted = profile;
    if (saving != null) await saving!.future;
    if (fail) throw Exception('offline');
    state = state.copyWith(profile: AsyncData(profile));
    return profile;
  }
}

void main() {
  late _Cache cache;
  late _Auth auth;
  late SharedPreferences prefs;
  late StreamController<User?> authChanges;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    cache = _Cache();
    auth = _Auth();
    authChanges = StreamController<User?>();
  });

  tearDown(() => authChanges.close());

  Future<void> pumpProfile(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
    bool clay = true,
  }) async {
    await prefs.setBool('clay_enabled', clay);
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final theme = ThemeData(brightness: brightness);
    final router = GoRouter(
      routes: [GoRoute(path: '/', builder: (_, _) => const ProfileScreen())],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          firebaseAuthProvider.overrideWithValue(auth),
          authStateProvider.overrideWith((ref) => authChanges.stream),
          backendAccountCacheProvider.overrideWith(() => cache),
        ],
        child: MaterialApp.router(
          theme: theme.copyWith(
            textTheme: theme.textTheme.copyWith(
              displayMedium: theme.textTheme.displayMedium!.copyWith(
                height: 1.05,
              ),
            ),
          ),
          routerConfig: router,
        ),
      ),
    );
    authChanges.add(auth.currentUser);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
  }

  Future<void> tapAction(WidgetTester tester, String label) async {
    await tester.ensureVisible(find.text(label));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Avatar choices open only from the pencil and dismissal preserves selection',
    (tester) async {
      await pumpProfile(tester);
      expect(find.bySemanticsLabel('Boy 2'), findsNothing);
      await tester.tap(find.byTooltip('Change avatar'));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Boy 2'), findsOneWidget);
      await tester.tap(find.byTooltip('Close avatar picker'));
      await tester.pumpAndSettle();
      await tapAction(tester, 'Save profile');
      expect(cache.submitted?.avatarId, 'girl_1');
    },
  );

  testWidgets('Account change closes both the avatar picker and editor', (
    tester,
  ) async {
    await pumpProfile(tester);
    await tester.tap(find.byTooltip('Change avatar'));
    await tester.pumpAndSettle();
    auth.currentUser = null;
    authChanges.add(null);
    await tester.pumpAndSettle();
    expect(find.text('Choose your avatar'), findsNothing);
    expect(find.text('Edit profile'), findsNothing);
    expect(cache.submitted, isNull);
  });

  testWidgets('Background refresh does not change the draft revision', (
    tester,
  ) async {
    await pumpProfile(tester);
    cache.refreshProfile(
      const StudentProfile(
        board: 'scert_odisha',
        classNo: 7,
        preferredLanguage: 'hi',
        avatarId: 'boy_4',
        revision: 4,
      ),
    );
    await tester.pumpAndSettle();
    await tapAction(tester, 'Save profile');
    expect(cache.submitted?.revision, 3);
    expect(cache.submitted?.avatarId, 'girl_1');
    expect(cache.submitted?.classNo, 8);
  });

  testWidgets('Back and Cancel cannot dismiss an in-flight save', (
    tester,
  ) async {
    cache.saving = Completer<void>();
    await pumpProfile(tester);
    await tester.ensureVisible(find.text('Save profile'));
    await tester.tap(find.text('Save profile'));
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.text('Edit profile'), findsOneWidget);
    final cancel = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Cancel'),
    );
    expect(cancel.onPressed, isNull);
    cache.saving!.complete();
    await tester.pumpAndSettle();
    expect(find.text('Edit profile'), findsNothing);
  });

  testWidgets('Cancel discards avatar and text changes', (tester) async {
    await pumpProfile(tester);
    expect(find.text('Edit'), findsOneWidget);
    await tester.tap(find.byTooltip('Change avatar'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Boy 2'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Draft name');
    await tapAction(tester, 'Cancel');
    expect(cache.submitted, isNull);
    expect(find.text('Asha'), findsOneWidget);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Change avatar'));
    await tester.pumpAndSettle();
    final choice = tester.widget<Semantics>(find.bySemanticsLabel('Girl 1'));
    expect(choice.properties.selected, isTrue);
    await tester.tap(find.byTooltip('Close avatar picker'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      'Asha',
    );
  });

  testWidgets('Save commits avatar and details together', (tester) async {
    await pumpProfile(tester);
    await tester.tap(find.byTooltip('Change avatar'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Boy 2'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'New name');
    await tapAction(tester, 'Save profile');
    expect(cache.submitted?.avatarId, 'boy_2');
    expect(cache.submitted?.name, 'New name');
    expect(cache.submitted?.revision, 3);
    expect(find.text('Edit profile'), findsNothing);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ProfileScreen)),
    );
    expect(container.read(effectiveAvatarIdProvider), 'boy_2');
  });

  testWidgets('Failed save keeps draft and Cancel remains available', (
    tester,
  ) async {
    cache.fail = true;
    await pumpProfile(tester);
    await tester.tap(find.byTooltip('Change avatar'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Default avatar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Draft name');
    await tapAction(tester, 'Save profile');
    expect(find.text('Edit profile'), findsOneWidget);
    expect(
      find.text("Couldn't save your profile. Please try again."),
      findsOneWidget,
    );
    expect(cache.submitted?.avatarId, isNull);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      'Draft name',
    );
    await tapAction(tester, 'Cancel');
    expect(find.text('Asha'), findsOneWidget);
  });

  testWidgets('Account change closes the draft and hides the account avatar', (
    tester,
  ) async {
    await pumpProfile(tester);
    auth.currentUser = null;
    authChanges.add(null);
    await tester.pumpAndSettle();
    expect(find.text('Edit profile'), findsNothing);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ProfileScreen)),
    );
    expect(container.read(effectiveAvatarIdProvider), isNull);
    expect(cache.submitted, isNull);
  });

  for (final brightness in Brightness.values) {
    for (final clay in [true, false]) {
      testWidgets('Sheet lays out in $brightness with 3D=$clay', (
        tester,
      ) async {
        await pumpProfile(tester, brightness: brightness, clay: clay);
        expect(tester.takeException(), isNull);
        await tapAction(tester, 'Cancel');
        expect(tester.takeException(), isNull);
      });
    }
  }
}
