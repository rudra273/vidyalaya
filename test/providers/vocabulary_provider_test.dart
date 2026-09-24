import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyalaya/data/services/backend_auth_service.dart';
import 'package:vidyalaya/providers/auth_provider.dart';
import 'package:vidyalaya/providers/core_providers.dart';
import 'package:vidyalaya/providers/regional_language_provider.dart';
import 'package:vidyalaya/providers/vocabulary_provider.dart';

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
        () =>
            _StubAccountCache(BackendAccountState(profile: AsyncData(profile))),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('dictionary default language', () {
    test('uses Odia from the profile', () async {
      final container = await _container(profile: _profile('or'));

      expect(
        container.read(dictionaryDefaultLanguageProvider),
        RegionalLanguage.odia,
      );
    });

    test('uses Hindi from the profile', () async {
      final container = await _container(profile: _profile('hi'));

      expect(
        container.read(dictionaryDefaultLanguageProvider),
        RegionalLanguage.hindi,
      );
    });

    test('falls back to Hindi for an English profile', () async {
      final container = await _container(profile: _profile('en'));

      expect(
        container.read(dictionaryDefaultLanguageProvider),
        RegionalLanguage.hindi,
      );
    });

    test('does not follow the Explore language override', () async {
      final container = await _container(
        prefs: {'regional_language': 'hi'},
        profile: _profile('or'),
      );

      expect(
        container.read(dictionaryDefaultLanguageProvider),
        RegionalLanguage.odia,
      );
    });

    test('uses the local profile preference while signed out', () async {
      final container = await _container(
        prefs: {'preferred_language': 'or', 'regional_language': 'hi'},
      );

      expect(
        container.read(dictionaryDefaultLanguageProvider),
        RegionalLanguage.odia,
      );
    });
  });
}
