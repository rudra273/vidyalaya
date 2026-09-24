import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyalaya/data/repositories/user_prefs_repository.dart';
import 'package:vidyalaya/providers/auth_provider.dart';
import 'package:vidyalaya/providers/core_providers.dart';
import 'package:vidyalaya/screens/onboarding/welcome_screen.dart';

void main() {
  testWidgets('welcome saves the preferred language with the class and board', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = GoRouter(
      initialLocation: '/welcome',
      routes: [
        GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
        GoRoute(path: '/', builder: (_, _) => const Scaffold()),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authStateProvider.overrideWith((ref) => Stream<User?>.value(null)),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Preferred language'), findsOneWidget);
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hindi').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(prefs.getString('preferred_language'), 'hi');
    final saved = UserPrefsRepository(prefs);
    expect(saved.getSelectedBoard(), 'scert_odisha');
    expect(saved.getPrimaryClass(), 8);
    expect(prefs.getBool('has_completed_onboarding'), isTrue);
  });
}
