import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/cache/cache_store.dart';
import '../data/models/learn_assist.dart';
import '../data/models/plus.dart';
import 'auth_provider.dart';
import 'core_providers.dart';

// ─── Plus status ───

const _cacheName = 'plus_status';

const _connectionMessage =
    "Couldn't send your request. Please check your connection and try again.";

@immutable
class PlusViewState {
  final PlusStatus? status;
  final bool requesting;

  /// A student-readable reason the last request failed, or null.
  final String? error;

  const PlusViewState({this.status, this.requesting = false, this.error});

  PlusViewState copyWith({
    PlusStatus? status,
    bool? requesting,
    String? error,
    bool clearError = false,
  }) {
    return PlusViewState(
      status: status ?? this.status,
      requesting: requesting ?? this.requesting,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PlusViewState &&
      other.status == status &&
      other.requesting == requesting &&
      other.error == error;

  @override
  int get hashCode => Object.hash(status, requesting, error);
}

/// The signed-in student's Plus card: whether they can ask, and where a request
/// stands.
///
/// Stale-while-revalidate like the other account data: the last answer for this
/// uid shows at once and is refreshed in the background, when the app returns to
/// the foreground, and whenever the Plus screens open. When the server's plan
/// differs from the one the app is showing, the account is refreshed too, so an
/// approval changes the plan label and limits without waiting for a restart.
final plusProvider = NotifierProvider<PlusNotifier, PlusViewState>(
  PlusNotifier.new,
);

class PlusNotifier extends Notifier<PlusViewState> {
  @override
  PlusViewState build() {
    final uid = ref
        .watch(authStateProvider)
        .maybeWhen(data: (user) => user?.uid, orElse: () => null);
    if (uid == null) return const PlusViewState();

    final listener = AppLifecycleListener(onResume: () => unawaited(refresh()));
    ref.onDispose(listener.dispose);

    final cached = ref
        .read(cacheStoreProvider)
        .read(
          CacheStore.key(uid: uid, name: _cacheName),
          (json) => PlusStatus.fromJson(json as Map<String, dynamic>),
        );
    unawaited(refresh());
    return PlusViewState(status: cached);
  }

  String? get _currentUid => ref
      .read(authStateProvider)
      .maybeWhen(data: (user) => user?.uid, orElse: () => null);

  /// Fetches the latest status. Offline or on a server error the last known
  /// status stays on screen.
  Future<void> refresh() async {
    final uid = _currentUid;
    if (uid == null) return;
    try {
      final fetched = await ref.read(backendAuthServiceProvider).plusStatus();
      // The student may have signed out or switched while this was in flight.
      if (!ref.mounted || _currentUid != uid) return;
      await _apply(uid, fetched);
    } catch (_) {
      // Keep what is showing.
    }
  }

  /// Asks for Plus from [source] (a [PlusSource]); returns whether it was sent.
  Future<bool> request(String source) async {
    final uid = _currentUid;
    if (uid == null || state.requesting) return false;
    state = state.copyWith(requesting: true, clearError: true);
    try {
      final status = await ref
          .read(backendAuthServiceProvider)
          .requestPlus(source);
      if (!ref.mounted || _currentUid != uid) return false;
      await _apply(uid, status);
      state = state.copyWith(requesting: false);
      return true;
    } on LearnAssistApiException catch (error) {
      if (!ref.mounted || _currentUid != uid) return false;
      final stale = error.code.startsWith('plus_');
      state = state.copyWith(
        requesting: false,
        error: stale ? error.message : _connectionMessage,
      );
      // The server knows better than this screen: show where things stand.
      if (stale) unawaited(refresh());
      return false;
    } catch (_) {
      if (!ref.mounted || _currentUid != uid) return false;
      state = state.copyWith(requesting: false, error: _connectionMessage);
      return false;
    }
  }

  Future<void> _apply(String uid, PlusStatus status) async {
    if (status != state.status) state = state.copyWith(status: status);
    _syncAccountPlan(status);
    await ref
        .read(cacheStoreProvider)
        .write(
          CacheStore.key(uid: uid, name: _cacheName),
          status,
          (value) => value.toJson(),
        );
  }

  /// A plan the account screens are not showing yet: refresh them now.
  void _syncAccountPlan(PlusStatus status) {
    final account = ref.read(backendAccountCacheProvider);
    if (!account.userLoaded) return; // its own first fetch will be current
    final showing = account.user.maybeWhen(
      data: (user) => user?.planKey ?? 'free',
      orElse: () => null,
    );
    if (showing == null || showing == status.planKey) return;
    final cache = ref.read(backendAccountCacheProvider.notifier);
    unawaited(cache.ensureUser(forceRefresh: true));
    unawaited(cache.ensureUsage(forceRefresh: true));
  }
}
