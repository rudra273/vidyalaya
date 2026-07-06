import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../data/cache/cache_store.dart';
import '../data/models/learn_assist.dart';
import '../data/repositories/auth_repository.dart';
import '../data/services/backend_auth_service.dart';
import 'core_providers.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn.instance;
});

final backendAuthServiceProvider = Provider<BackendAuthService>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);

  return BackendAuthService(
    client: client,
    idTokenProvider: ({required forceRefresh}) async {
      final user = ref.read(firebaseAuthProvider).currentUser;
      return user?.getIdToken(forceRefresh);
    },
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    googleSignIn: ref.watch(googleSignInProvider),
    backendAuthService: ref.watch(backendAuthServiceProvider),
  );
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

/// Identifies one conversation's history thread (mirrors the backend thread id).
/// Used as the cache key so switching subject/agent re-fetches the right history.
class HistorySelector {
  final String channel;
  final String board;
  final int classNo;
  final String? subject;

  const HistorySelector({
    required this.channel,
    required this.board,
    required this.classNo,
    this.subject,
  });

  @override
  bool operator ==(Object other) =>
      other is HistorySelector &&
      other.channel == channel &&
      other.board == board &&
      other.classNo == classNo &&
      other.subject == subject;

  @override
  int get hashCode => Object.hash(channel, board, classNo, subject);
}

class BackendAccountState {
  final String? uid;
  final AsyncValue<BackendUser?> user;
  final AsyncValue<StudentProfile?> profile;
  final AsyncValue<LearnAssistUsage?> usage;
  final AsyncValue<ChatHistoryPage?> history;
  final HistorySelector? historySelector;
  final bool userLoaded;
  final bool profileLoaded;
  final bool usageLoaded;
  final bool historyLoaded;

  const BackendAccountState({
    this.uid,
    this.user = const AsyncData(null),
    this.profile = const AsyncData(null),
    this.usage = const AsyncData(null),
    this.history = const AsyncData(null),
    this.historySelector,
    this.userLoaded = false,
    this.profileLoaded = false,
    this.usageLoaded = false,
    this.historyLoaded = false,
  });

  BackendAccountState copyWith({
    String? uid,
    AsyncValue<BackendUser?>? user,
    AsyncValue<StudentProfile?>? profile,
    AsyncValue<LearnAssistUsage?>? usage,
    AsyncValue<ChatHistoryPage?>? history,
    HistorySelector? historySelector,
    bool? userLoaded,
    bool? profileLoaded,
    bool? usageLoaded,
    bool? historyLoaded,
  }) {
    return BackendAccountState(
      uid: uid ?? this.uid,
      user: user ?? this.user,
      profile: profile ?? this.profile,
      usage: usage ?? this.usage,
      history: history ?? this.history,
      historySelector: historySelector ?? this.historySelector,
      userLoaded: userLoaded ?? this.userLoaded,
      profileLoaded: profileLoaded ?? this.profileLoaded,
      usageLoaded: usageLoaded ?? this.usageLoaded,
      historyLoaded: historyLoaded ?? this.historyLoaded,
    );
  }
}

class BackendAccountCache extends Notifier<BackendAccountState> {
  Future<BackendUser?>? _userRequest;
  Future<StudentProfile?>? _profileRequest;
  Future<LearnAssistUsage?>? _usageRequest;
  Future<ChatHistoryPage?>? _historyRequest;
  // Which conversation [_historyRequest] is fetching. A single shared request
  // slot is fine, but it must be keyed: otherwise a still-in-flight fetch for
  // one subject gets reused for another (returning the wrong conversation), or
  // a slow response clobbers a conversation the user already switched away from.
  HistorySelector? _historyRequestSelector;

  @override
  BackendAccountState build() {
    final uid = ref
        .watch(authStateProvider)
        .maybeWhen(data: (user) => user?.uid, orElse: () => null);

    final previousUid = stateOrNull?.uid;

    if (uid == null) {
      if (previousUid != null) {
        unawaited(_cache.deleteNamespace(previousUid));
      }
      _userRequest = null;
      _profileRequest = null;
      _usageRequest = null;
      _historyRequest = null;
      _historyRequestSelector = null;
      return const BackendAccountState();
    }

    if (previousUid != uid) {
      if (previousUid != null) {
        unawaited(_cache.deleteNamespace(previousUid));
      }
      _userRequest = null;
      _profileRequest = null;
      _usageRequest = null;
      _historyRequest = null;
      _historyRequestSelector = null;
      return BackendAccountState(uid: uid);
    }

    return stateOrNull ?? BackendAccountState(uid: uid);
  }

  Future<BackendUser?> ensureUser({bool forceRefresh = false}) {
    final uid = _currentUid;
    if (uid == null) return Future.value(null);
    _hydrateUserFromCache(uid);

    final cached = _asyncData(state.user);
    final hasCache = state.userLoaded && cached != null;
    if (_userRequest == null && (forceRefresh || _shouldRevalidate())) {
      if (!hasCache) {
        state = state.copyWith(uid: uid, user: const AsyncLoading());
      }
      _userRequest = _loadUser(uid, cached);
    }

    return hasCache
        ? Future.value(cached)
        : (_userRequest ?? Future.value(null));
  }

  Future<StudentProfile?> ensureProfile({bool forceRefresh = false}) {
    final uid = _currentUid;
    if (uid == null) return Future.value(null);
    _hydrateProfileFromCache(uid);

    final cached = _asyncData(state.profile);
    final hasCache = state.profileLoaded && cached != null;
    if (_profileRequest == null && (forceRefresh || _shouldRevalidate())) {
      if (!hasCache) {
        state = state.copyWith(uid: uid, profile: const AsyncLoading());
      }
      _profileRequest = _loadProfile(uid, cached);
    }

    return hasCache
        ? Future.value(cached)
        : (_profileRequest ?? Future.value(null));
  }

  Future<LearnAssistUsage?> ensureUsage({bool forceRefresh = false}) {
    final uid = _currentUid;
    if (uid == null) return Future.value(null);
    _hydrateUsageFromCache(uid);

    final cached = _asyncData(state.usage);
    final hasCache = state.usageLoaded && cached != null;
    if (_usageRequest == null && (forceRefresh || _shouldRevalidate())) {
      if (!hasCache) {
        state = state.copyWith(uid: uid, usage: const AsyncLoading());
      }
      _usageRequest = _loadUsage(uid, cached);
    }

    return hasCache
        ? Future.value(cached)
        : (_usageRequest ?? Future.value(null));
  }

  /// Loads history for one conversation, identified by [selector]
  /// (channel + board + class + subject). When the selector differs from what is
  /// cached, the cache is reset and re-fetched so each subject/agent shows only
  /// its own messages.
  Future<ChatHistoryPage?> ensureHistory(
    HistorySelector selector, {
    bool forceRefresh = false,
  }) {
    final uid = _currentUid;
    if (uid == null) return Future.value(null);
    _hydrateHistoryFromCache(uid, selector);

    final sameSelector = state.historySelector == selector;
    final cached = sameSelector ? _asyncData(state.history) : null;
    final hasCache = state.historyLoaded && cached != null;

    // Only an in-flight request for *this* selector may be reused. A request
    // for a different conversation must never be handed back here, or the
    // caller would await another subject's history (the intermittent
    // wrong-conversation bug when switching subjects quickly).
    final inFlight = _historyRequestSelector == selector
        ? _historyRequest
        : null;

    if (inFlight == null && (forceRefresh || _shouldRevalidate())) {
      if (!hasCache) {
        state = state.copyWith(
          uid: uid,
          history: const AsyncLoading(),
          historySelector: selector,
        );
      }
      _historyRequest = _loadHistory(uid, selector, cached);
      _historyRequestSelector = selector;
    }

    final pending = _historyRequestSelector == selector
        ? _historyRequest
        : null;
    if (hasCache && forceRefresh && pending != null) {
      return pending;
    }
    return hasCache
        ? Future.value(cached)
        : (pending ?? Future.value(null));
  }

  Future<ChatHistoryPage?> loadOlderHistory() {
    final selector = state.historySelector;
    if (selector == null) return Future.value(null);
    final current = _asyncData(state.history);
    final before = current?.nextBefore;
    if (before == null) return Future.value(current);
    final uid = _currentUid;
    if (uid == null) return Future.value(null);
    if (_historyRequest != null && _historyRequestSelector == selector) {
      return _historyRequest!;
    }

    _historyRequest = _loadHistory(uid, selector, current, before: before);
    _historyRequestSelector = selector;
    return _historyRequest!;
  }

  Future<StudentProfile> saveProfile(StudentProfile profile) async {
    final uid = _requireUid();
    final previous = _asyncData(state.profile);
    state = state.copyWith(uid: uid, profile: const AsyncLoading());
    try {
      final saved = await ref
          .read(backendAuthServiceProvider)
          .updateProfile(profile);
      if (_currentUid == uid) {
        await _cache.write<StudentProfile>(
          _profileKey(uid),
          saved,
          (profile) => profile.toCacheJson(),
        );
        state = state.copyWith(profile: AsyncData(saved), profileLoaded: true);
      }
      return saved;
    } catch (error, stackTrace) {
      if (_currentUid == uid) {
        state = state.copyWith(profile: AsyncError(error, stackTrace));
      }
      if (previous != null && _currentUid == uid) {
        state = state.copyWith(profile: AsyncData(previous));
      }
      rethrow;
    }
  }

  void updateUsage(LearnAssistUsage usage) {
    final uid = _currentUid;
    if (uid == null) return;
    unawaited(
      _cache.write<LearnAssistUsage>(
        _usageKey(uid),
        usage,
        (usage) => usage.toJson(),
      ),
    );
    state = state.copyWith(
      uid: uid,
      usage: AsyncData(usage),
      usageLoaded: true,
    );
  }

  void markHistoryStale() {
    final uid = _currentUid;
    if (uid == null) return;
    state = state.copyWith(uid: uid, historyLoaded: false);
  }

  void prependLatestHistoryMessages(List<ChatHistoryMessage> messages) {
    final uid = _currentUid;
    if (uid == null || messages.isEmpty) return;
    final selector = state.historySelector;
    if (selector == null) return;
    final current =
        _asyncData(state.history) ??
        const ChatHistoryPage(messages: [], nextBefore: null);
    final existingIds = current.messages.map((message) => message.id).toSet();
    final uniqueMessages = [
      ...messages.where((message) => !existingIds.contains(message.id)),
      ...current.messages,
    ]..sort((a, b) => b.id.compareTo(a.id));
    state = state.copyWith(
      uid: uid,
      history: AsyncData(
        ChatHistoryPage(
          messages: uniqueMessages,
          nextBefore: current.nextBefore,
        ),
      ),
      historyLoaded: true,
    );
    unawaited(
      _cache.write<ChatHistoryPage>(
        _historyKey(uid, selector),
        ChatHistoryPage(
          messages: uniqueMessages,
          nextBefore: current.nextBefore,
        ),
        (page) => page.toJson(),
      ),
    );
  }

  Future<BackendUser?> _loadUser(String uid, BackendUser? previous) async {
    try {
      final user = await ref.read(backendAuthServiceProvider).me();
      if (_currentUid == uid) {
        await _cache.write<BackendUser>(
          _userKey(uid),
          user,
          (user) => user.toJson(),
        );
        final changed = state.user is! AsyncData ||
            !_jsonEquals(previous?.toJson(), user.toJson());
        state = changed
            ? state.copyWith(user: AsyncData(user), userLoaded: true)
            : state.copyWith(userLoaded: true);
      }
      return user;
    } catch (error, stackTrace) {
      if (_currentUid == uid) {
        state = previous == null
            ? state.copyWith(
                user: AsyncError(error, stackTrace),
                userLoaded: true,
              )
            : state.copyWith(userLoaded: true);
      }
      return previous;
    } finally {
      _userRequest = null;
    }
  }

  Future<StudentProfile?> _loadProfile(
    String uid,
    StudentProfile? previous,
  ) async {
    try {
      final profile = await ref.read(backendAuthServiceProvider).profile();
      if (_currentUid == uid) {
        if (profile == null) {
          await _cache.delete(_profileKey(uid));
        } else {
          await _cache.write<StudentProfile>(
            _profileKey(uid),
            profile,
            (profile) => profile.toCacheJson(),
          );
        }
        // "Unchanged" may only skip the state write when the state already
        // holds data — a first fetch that returns null matches a null
        // `previous`, and skipping would leave AsyncLoading in place forever.
        final changed = state.profile is! AsyncData ||
            !_jsonEquals(
              previous?.toCacheJson(),
              profile?.toCacheJson(),
            );
        state = changed
            ? state.copyWith(profile: AsyncData(profile), profileLoaded: true)
            : state.copyWith(profileLoaded: true);
      }
      return profile;
    } catch (error, stackTrace) {
      if (_currentUid == uid) {
        state = previous == null
            ? state.copyWith(
                profile: AsyncError(error, stackTrace),
                profileLoaded: true,
              )
            : state.copyWith(profileLoaded: true);
      }
      return previous;
    } finally {
      _profileRequest = null;
    }
  }

  Future<LearnAssistUsage?> _loadUsage(
    String uid,
    LearnAssistUsage? previous,
  ) async {
    try {
      final usage = await ref.read(backendAuthServiceProvider).usage();
      if (_currentUid == uid) {
        await _cache.write<LearnAssistUsage>(
          _usageKey(uid),
          usage,
          (usage) => usage.toJson(),
        );
        final changed = state.usage is! AsyncData ||
            !_jsonEquals(previous?.toJson(), usage.toJson());
        state = changed
            ? state.copyWith(usage: AsyncData(usage), usageLoaded: true)
            : state.copyWith(usageLoaded: true);
      }
      return usage;
    } catch (error, stackTrace) {
      if (_currentUid == uid) {
        state = previous == null
            ? state.copyWith(
                usage: AsyncError(error, stackTrace),
                usageLoaded: true,
              )
            : state.copyWith(usageLoaded: true);
      }
      return previous;
    } finally {
      _usageRequest = null;
    }
  }

  Future<ChatHistoryPage?> _loadHistory(
    String uid,
    HistorySelector selector,
    ChatHistoryPage? previous, {
    int? before,
  }) async {
    try {
      final page = await ref
          .read(backendAuthServiceProvider)
          .history(
            board: selector.board,
            classNo: selector.classNo,
            channel: selector.channel,
            subject: selector.subject,
            before: before,
          );
      final mergedPage = before == null || previous == null
          ? page
          : ChatHistoryPage(
              messages: [...previous.messages, ...page.messages],
              nextBefore: page.nextBefore,
            );
      // Always cache the fetched page under its own key, but only push it into
      // the visible state when this selector is still the active conversation.
      // Otherwise a slow response for a subject the user has switched away from
      // would clobber the conversation now on screen.
      if (_currentUid == uid) {
        await _cache.write<ChatHistoryPage>(
          _historyKey(uid, selector),
          mergedPage,
          (page) => page.toJson(),
        );
        if (state.historySelector == selector) {
          final changed = !_jsonEquals(previous?.toJson(), mergedPage.toJson());
          state = changed
              ? state.copyWith(
                  history: AsyncData(mergedPage),
                  historyLoaded: true,
                  historySelector: selector,
                )
              : state.copyWith(historyLoaded: true, historySelector: selector);
        }
      }
      return mergedPage;
    } catch (error, stackTrace) {
      if (_currentUid == uid && state.historySelector == selector) {
        state = previous == null
            ? state.copyWith(
                history: AsyncError(error, stackTrace),
                historyLoaded: true,
                historySelector: selector,
              )
            : state.copyWith(historyLoaded: true, historySelector: selector);
      }
      return previous;
    } finally {
      // Only release the shared slot if it is still ours; a newer fetch for a
      // different selector may have replaced it while we awaited the network.
      if (_historyRequestSelector == selector) {
        _historyRequest = null;
        _historyRequestSelector = null;
      }
    }
  }

  String? get _currentUid => ref.read(firebaseAuthProvider).currentUser?.uid;

  CacheStore get _cache => ref.read(cacheStoreProvider);

  String _userKey(String uid) => CacheStore.key(uid: uid, name: 'backend_user');
  String _profileKey(String uid) {
    return CacheStore.key(uid: uid, name: 'student_profile');
  }

  String _usageKey(String uid) => CacheStore.key(uid: uid, name: 'usage');

  String _historyKey(String uid, HistorySelector selector) {
    return CacheStore.key(
      uid: uid,
      name:
          'history:${selector.channel}:${selector.board}:${selector.classNo}:${selector.subject ?? "_all"}',
    );
  }

  bool _shouldRevalidate() => true;

  void _hydrateUserFromCache(String uid) {
    if (state.uid == uid && state.userLoaded) return;
    final entry = _cache.readWithMeta<BackendUser>(
      _userKey(uid),
      (json) => BackendUser.fromJson(_jsonMap(json)),
    );
    if (entry != null) {
      state = state.copyWith(
        uid: uid,
        user: AsyncData(entry.value),
        userLoaded: true,
      );
    }
  }

  void _hydrateProfileFromCache(String uid) {
    if (state.uid == uid && state.profileLoaded) return;
    final entry = _cache.readWithMeta<StudentProfile>(
      _profileKey(uid),
      (json) => StudentProfile.fromJson(_jsonMap(json)),
    );
    if (entry != null) {
      state = state.copyWith(
        uid: uid,
        profile: AsyncData(entry.value),
        profileLoaded: true,
      );
    }
  }

  void _hydrateUsageFromCache(String uid) {
    if (state.uid == uid && state.usageLoaded) return;
    final entry = _cache.readWithMeta<LearnAssistUsage>(
      _usageKey(uid),
      (json) => LearnAssistUsage.fromJson(_jsonMap(json)),
    );
    if (entry != null) {
      state = state.copyWith(
        uid: uid,
        usage: AsyncData(entry.value),
        usageLoaded: true,
      );
    }
  }

  void _hydrateHistoryFromCache(String uid, HistorySelector selector) {
    if (state.historySelector == selector && state.historyLoaded) return;
    final entry = _cache.readWithMeta<ChatHistoryPage>(
      _historyKey(uid, selector),
      (json) => ChatHistoryPage.fromJson(_jsonMap(json)),
    );
    if (entry != null) {
      state = state.copyWith(
        uid: uid,
        history: AsyncData(entry.value),
        historySelector: selector,
        historyLoaded: true,
      );
    }
  }

  ChatHistoryPage? peekHistory(HistorySelector selector) {
    final uid = _currentUid;
    if (uid == null) return null;
    _hydrateHistoryFromCache(uid, selector);
    return state.historySelector == selector ? _asyncData(state.history) : null;
  }

  String _requireUid() {
    final uid = _currentUid;
    if (uid == null) throw StateError('Please sign in again.');
    return uid;
  }
}

final backendAccountCacheProvider =
    NotifierProvider<BackendAccountCache, BackendAccountState>(
      BackendAccountCache.new,
    );

T? _asyncData<T>(AsyncValue<T?> value) {
  return value.maybeWhen(data: (data) => data, orElse: () => null);
}

Map<String, dynamic> _jsonMap(Object json) {
  return Map<String, dynamic>.from(json as Map);
}

bool _jsonEquals(Object? left, Object? right) {
  return jsonEncode(left) == jsonEncode(right);
}
