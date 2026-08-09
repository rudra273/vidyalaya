import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyalaya/data/services/backend_auth_service.dart';
import 'package:vidyalaya/providers/auth_provider.dart';
import 'package:vidyalaya/providers/core_providers.dart';
import 'package:vidyalaya/providers/user_selection_provider.dart';

/// A cache whose state is set directly, so the notify behaviour can be tested
/// without Firebase or the network.
class _PokeableAccountCache extends BackendAccountCache {
  _PokeableAccountCache(this._initialState);

  final BackendAccountState _initialState;

  @override
  BackendAccountState build() => _initialState;

  void poke(BackendAccountState next) => state = next;
}

StudentProfile _profile({String? name, String? school}) => StudentProfile(
  board: 'scert_odisha',
  classNo: 8,
  preferredLanguage: 'en',
  name: name,
  schoolName: school,
);

void main() {
  group('BackendAccountState', () {
    test('a revalidation that changed nothing produces an equal state', () {
      final profile = _profile(name: 'Asha');
      final loaded = BackendAccountState(
        uid: 'uid-1',
        profile: AsyncData(profile),
        profileLoaded: true,
      );

      // What _loadProfile does when the response matches what is already held:
      // it keeps the same AsyncData and only re-affirms the loaded flag.
      expect(loaded.copyWith(profileLoaded: true), loaded);
    });

    test('a changed profile produces a different state', () {
      const base = BackendAccountState(uid: 'uid-1');

      expect(
        base.copyWith(profile: AsyncData(_profile(name: 'Asha'))),
        isNot(base.copyWith(profile: AsyncData(_profile(name: 'Ravi')))),
      );
    });

    test('an empty profile is distinct from one that has not loaded', () {
      const base = BackendAccountState(uid: 'uid-1');

      expect(
        base.copyWith(profile: const AsyncData(null), profileLoaded: true),
        isNot(base.copyWith(profile: const AsyncLoading())),
      );
    });

    // The loop this guards: ProfileScreen rebuilds -> ensureProfile() ->
    // response identical -> new state object -> notify -> rebuild -> refetch.
    test('re-emitting an unchanged state does not notify listeners', () {
      final loaded = BackendAccountState(
        uid: 'uid-1',
        profile: AsyncData(_profile(name: 'Asha')),
        profileLoaded: true,
      );
      final container = ProviderContainer(
        overrides: [
          backendAccountCacheProvider.overrideWith(
            () => _PokeableAccountCache(loaded),
          ),
        ],
      );
      addTearDown(container.dispose);

      var notifications = 0;
      container.listen(backendAccountCacheProvider, (_, _) => notifications++);
      final cache =
          container.read(backendAccountCacheProvider.notifier)
              as _PokeableAccountCache;

      cache.poke(loaded.copyWith(profileLoaded: true));
      expect(notifications, 0);

      cache.poke(loaded.copyWith(profile: AsyncData(_profile(name: 'Ravi'))));
      expect(notifications, 1);
    });
  });

  group('UserSelectionNotifier.setClasses', () {
    Future<ProviderContainer> containerWith(Set<int> classes) async {
      SharedPreferences.setMockInitialValues({
        'selected_classes': jsonEncode(classes.toList()),
      });
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      return container;
    }

    // Profile loads mirror the backend class into prefs on every fetch. Sets
    // compare by identity, so an equal-but-new set would notify and rebuild
    // every book surface — and re-trigger the load that called it.
    test('setting the same classes does not notify listeners', () async {
      final container = await containerWith({8});
      var notifications = 0;
      container.listen(userSelectionProvider, (_, _) => notifications++);

      container.read(userSelectionProvider.notifier).setClasses({8});

      expect(notifications, 0);
      expect(container.read(userSelectionProvider), {8});
    });

    test('setting different classes still notifies', () async {
      final container = await containerWith({8});
      var notifications = 0;
      container.listen(userSelectionProvider, (_, _) => notifications++);

      container.read(userSelectionProvider.notifier).setClasses({7});

      expect(notifications, 1);
      expect(container.read(userSelectionProvider), {7});
    });
  });
}
