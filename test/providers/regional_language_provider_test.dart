import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyalaya/data/services/backend_auth_service.dart';
import 'package:vidyalaya/providers/auth_provider.dart';
import 'package:vidyalaya/providers/core_providers.dart';
import 'package:vidyalaya/providers/regional_language_provider.dart';
import 'package:vidyalaya/providers/user_selection_provider.dart';

/// Replaces [BackendAccountCache] with a fixed state so tests never touch
/// Firebase or the network.
class _StubAccountCache extends BackendAccountCache {
  _StubAccountCache(this._fixedState);

  final BackendAccountState _fixedState;

  @override
  BackendAccountState build() => _fixedState;
}

StudentProfile _profile(String preferredLanguage) => StudentProfile(
      board: 'scert_odisha',
      classNo: 8,
      preferredLanguage: preferredLanguage,
    );

Future<ProviderContainer> _container({
  Map<String, Object> prefs = const {},
  StudentProfile? profile,
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sharedPrefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      backendAccountCacheProvider.overrideWith(
        () => _StubAccountCache(
          BackendAccountState(profile: AsyncData(profile)),
        ),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('regional language resolution', () {
    test('defaults to Odia for the SCERT Odisha board', () async {
      final container = await _container(
        prefs: {'selected_board': 'scert_odisha'},
      );
      expect(
        container.read(regionalLanguageProvider),
        RegionalLanguage.odia,
      );
    });

    test('defaults to Hindi for the NCERT board', () async {
      final container = await _container(
        prefs: {'selected_board': 'ncert'},
      );
      expect(
        container.read(regionalLanguageProvider),
        RegionalLanguage.hindi,
      );
    });

    test('falls back to Odia for an unknown board id', () async {
      final container = await _container(
        prefs: {'selected_board': 'future_board'},
      );
      expect(
        container.read(regionalLanguageProvider),
        RegionalLanguage.odia,
      );
    });

    test('manual override beats the board default', () async {
      final container = await _container(
        prefs: {
          'selected_board': 'scert_odisha',
          'regional_language': 'hi',
        },
      );
      expect(
        container.read(regionalLanguageProvider),
        RegionalLanguage.hindi,
      );
    });

    test("profile 'or' beats the NCERT board default", () async {
      final container = await _container(
        prefs: {'selected_board': 'ncert'},
        profile: _profile('or'),
      );
      expect(
        container.read(regionalLanguageProvider),
        RegionalLanguage.odia,
      );
    });

    test("profile 'en' falls through to the board default", () async {
      final container = await _container(
        prefs: {'selected_board': 'ncert'},
        profile: _profile('en'),
      );
      expect(
        container.read(regionalLanguageProvider),
        RegionalLanguage.hindi,
      );
    });

    test('locally-picked preferred language beats the board default', () async {
      // Signed-out student who picked Hindi in Profile (saved to
      // preferred_language) on an Odia-default board.
      final container = await _container(
        prefs: {
          'selected_board': 'scert_odisha',
          'preferred_language': 'hi',
        },
      );
      expect(
        container.read(regionalLanguageProvider),
        RegionalLanguage.hindi,
      );
    });

    test("locally-picked 'en' falls through to the board default", () async {
      final container = await _container(
        prefs: {
          'selected_board': 'scert_odisha',
          'preferred_language': 'en',
        },
      );
      expect(
        container.read(regionalLanguageProvider),
        RegionalLanguage.odia,
      );
    });

    test('profile preferred language beats the local pref', () async {
      final container = await _container(
        prefs: {
          'selected_board': 'ncert',
          'preferred_language': 'hi',
        },
        profile: _profile('or'),
      );
      expect(
        container.read(regionalLanguageProvider),
        RegionalLanguage.odia,
      );
    });

    test('manual override beats the local pref', () async {
      final container = await _container(
        prefs: {
          'selected_board': 'scert_odisha',
          'preferred_language': 'hi',
          'regional_language': 'or',
        },
      );
      expect(
        container.read(regionalLanguageProvider),
        RegionalLanguage.odia,
      );
    });
  });

  group('board changes', () {
    test('setBoard clears the manual override and re-resolves', () async {
      final container = await _container(
        prefs: {
          'selected_board': 'scert_odisha',
          'regional_language': 'or',
        },
      );
      expect(
        container.read(regionalLanguageProvider),
        RegionalLanguage.odia,
      );

      container.read(userBoardProvider.notifier).setBoard('ncert');

      expect(
        container.read(userPrefsRepositoryProvider).getRegionalLanguage(),
        isNull,
      );
      expect(
        container.read(regionalLanguageProvider),
        RegionalLanguage.hindi,
      );
    });

    test('setBoard with the same board keeps the override', () async {
      final container = await _container(
        prefs: {
          'selected_board': 'scert_odisha',
          'regional_language': 'hi',
        },
      );

      container.read(userBoardProvider.notifier).setBoard('scert_odisha');

      expect(
        container.read(userPrefsRepositoryProvider).getRegionalLanguage(),
        'hi',
      );
      expect(
        container.read(regionalLanguageProvider),
        RegionalLanguage.hindi,
      );
    });
  });
}
