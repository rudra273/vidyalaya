import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/cache/cache_store.dart';
import '../data/models/rollout_switches.dart';
import 'auth_provider.dart';
import 'core_providers.dart';

// ─── Rollout switches ───

const _cacheName = 'rollout_switches';

/// The signed-in student's server-controlled switches.
///
/// Stale-while-revalidate like the account cache: the last response for this
/// uid is used immediately and refreshed in the background, so a switch change
/// reaches the app on its next start without delaying it. Signed out, or when
/// the server has never been reached, every switch keeps its in-app default.
final rolloutSwitchesProvider =
    NotifierProvider<RolloutSwitchesNotifier, RolloutSwitches>(
      RolloutSwitchesNotifier.new,
    );

class RolloutSwitchesNotifier extends Notifier<RolloutSwitches> {
  @override
  RolloutSwitches build() {
    final uid = ref
        .watch(authStateProvider)
        .maybeWhen(data: (user) => user?.uid, orElse: () => null);
    if (uid == null) return RolloutSwitches.defaults;

    final cached = ref
        .read(cacheStoreProvider)
        .read(
          CacheStore.key(uid: uid, name: _cacheName),
          (json) => RolloutSwitches.fromJson(json as Map<String, dynamic>),
        );
    unawaited(_refresh(uid));
    return cached ?? RolloutSwitches.defaults;
  }

  String? get _currentUid => ref
      .read(authStateProvider)
      .maybeWhen(data: (user) => user?.uid, orElse: () => null);

  Future<void> _refresh(String uid) async {
    try {
      final fetched = await ref
          .read(backendAuthServiceProvider)
          .rolloutSwitches();
      // The student may have signed out or switched while this was in flight.
      if (!ref.mounted || _currentUid != uid) return;
      if (fetched != state) state = fetched;
      await ref
          .read(cacheStoreProvider)
          .write(
            CacheStore.key(uid: uid, name: _cacheName),
            fetched,
            (value) => value.toJson(),
          );
    } catch (_) {
      // Offline or server error: keep the cached or default switches.
    }
  }
}

/// Whether the reading/books feature ("Library") is enabled.
///
/// Books are the app's tertiary feature and carry copyright risk, so every book
/// surface hides cleanly when this is false, leaving AI and the tools fully
/// functional with no dead links. When disabled it hides Home's whole "Your
/// books" section (library row, continue-reading, recently-added) and
/// redirects the /library, /my-books, /reader and /bookmarks routes to Home
/// (router.dart). The bottom nav is unaffected — Library is reached from Home,
/// not a tab, since AI took that slot. On unless the server's `books` switch
/// turns it off.
final booksEnabledProvider = Provider<bool>((ref) {
  return ref
      .watch(rolloutSwitchesProvider)
      .isEnabled('books', defaultValue: true);
});
