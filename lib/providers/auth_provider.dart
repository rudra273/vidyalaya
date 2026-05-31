import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../data/models/learn_assist.dart';
import '../data/repositories/auth_repository.dart';
import '../data/services/backend_auth_service.dart';

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

  @override
  BackendAccountState build() {
    final uid = ref
        .watch(authStateProvider)
        .maybeWhen(data: (user) => user?.uid, orElse: () => null);

    if (uid == null) {
      _userRequest = null;
      _profileRequest = null;
      _usageRequest = null;
      _historyRequest = null;
      return const BackendAccountState();
    }

    if (stateOrNull?.uid != uid) {
      _userRequest = null;
      _profileRequest = null;
      _usageRequest = null;
      _historyRequest = null;
      return BackendAccountState(uid: uid);
    }

    return stateOrNull ?? BackendAccountState(uid: uid);
  }

  Future<BackendUser?> ensureUser({bool forceRefresh = false}) {
    final uid = _currentUid;
    if (uid == null) return Future.value(null);
    if (!forceRefresh &&
        state.uid == uid &&
        state.userLoaded &&
        state.user is AsyncData<BackendUser?> &&
        _asyncData(state.user) != null) {
      return Future.value(_asyncData(state.user));
    }
    if (!forceRefresh &&
        state.uid == uid &&
        state.userLoaded &&
        state.user is AsyncError<BackendUser?>) {
      return Future.value(_asyncData(state.user));
    }
    if (!forceRefresh && _userRequest != null) return _userRequest!;

    final previous = _asyncData(state.user);
    state = state.copyWith(uid: uid, user: const AsyncLoading());
    _userRequest = _loadUser(uid, previous);
    return _userRequest!;
  }

  Future<StudentProfile?> ensureProfile({bool forceRefresh = false}) {
    final uid = _currentUid;
    if (uid == null) return Future.value(null);
    if (!forceRefresh &&
        state.uid == uid &&
        state.profileLoaded &&
        state.profile is AsyncData<StudentProfile?>) {
      return Future.value(_asyncData(state.profile));
    }
    if (!forceRefresh &&
        state.uid == uid &&
        state.profileLoaded &&
        state.profile is AsyncError<StudentProfile?>) {
      return Future.value(_asyncData(state.profile));
    }
    if (!forceRefresh && _profileRequest != null) return _profileRequest!;

    final previous = _asyncData(state.profile);
    state = state.copyWith(uid: uid, profile: const AsyncLoading());
    _profileRequest = _loadProfile(uid, previous);
    return _profileRequest!;
  }

  Future<LearnAssistUsage?> ensureUsage({bool forceRefresh = false}) {
    final uid = _currentUid;
    if (uid == null) return Future.value(null);
    if (!forceRefresh &&
        state.uid == uid &&
        state.usageLoaded &&
        state.usage is AsyncData<LearnAssistUsage?> &&
        _asyncData(state.usage) != null) {
      return Future.value(_asyncData(state.usage));
    }
    if (!forceRefresh &&
        state.uid == uid &&
        state.usageLoaded &&
        state.usage is AsyncError<LearnAssistUsage?>) {
      return Future.value(_asyncData(state.usage));
    }
    if (!forceRefresh && _usageRequest != null) return _usageRequest!;

    final previous = _asyncData(state.usage);
    state = state.copyWith(uid: uid, usage: const AsyncLoading());
    _usageRequest = _loadUsage(uid, previous);
    return _usageRequest!;
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

    final sameSelector = state.historySelector == selector;
    if (!forceRefresh &&
        sameSelector &&
        state.uid == uid &&
        state.historyLoaded &&
        (state.history is AsyncData<ChatHistoryPage?> ||
            state.history is AsyncError<ChatHistoryPage?>)) {
      return Future.value(_asyncData(state.history));
    }
    if (!forceRefresh && sameSelector && _historyRequest != null) {
      return _historyRequest!;
    }

    // Different conversation (or forced): drop the old page so stale messages
    // never flash, and fetch fresh from the first page.
    final previous = sameSelector ? _asyncData(state.history) : null;
    state = state.copyWith(
      uid: uid,
      history: const AsyncLoading(),
      historySelector: selector,
    );
    _historyRequest = _loadHistory(uid, selector, previous);
    return _historyRequest!;
  }

  Future<ChatHistoryPage?> loadOlderHistory() {
    final selector = state.historySelector;
    if (selector == null) return Future.value(null);
    final current = _asyncData(state.history);
    final before = current?.nextBefore;
    if (before == null) return Future.value(current);
    final uid = _currentUid;
    if (uid == null) return Future.value(null);
    if (_historyRequest != null) return _historyRequest!;

    state = state.copyWith(uid: uid, history: const AsyncLoading());
    _historyRequest = _loadHistory(uid, selector, current, before: before);
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
    final current = _asyncData(state.history);
    if (current == null) return;
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
  }

  Future<BackendUser?> _loadUser(String uid, BackendUser? previous) async {
    try {
      final user = await ref.read(backendAuthServiceProvider).me();
      if (_currentUid == uid) {
        state = state.copyWith(user: AsyncData(user), userLoaded: true);
      }
      return user;
    } catch (error, stackTrace) {
      if (_currentUid == uid) {
        state = state.copyWith(
          user: AsyncError(error, stackTrace),
          userLoaded: true,
        );
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
        state = state.copyWith(
          profile: AsyncData(profile),
          profileLoaded: true,
        );
      }
      return profile;
    } catch (error, stackTrace) {
      if (_currentUid == uid) {
        state = state.copyWith(
          profile: AsyncError(error, stackTrace),
          profileLoaded: true,
        );
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
        state = state.copyWith(usage: AsyncData(usage), usageLoaded: true);
      }
      return usage;
    } catch (error, stackTrace) {
      if (_currentUid == uid) {
        state = state.copyWith(
          usage: AsyncError(error, stackTrace),
          usageLoaded: true,
        );
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
      if (_currentUid == uid) {
        state = state.copyWith(
          history: AsyncData(mergedPage),
          historyLoaded: true,
        );
      }
      return mergedPage;
    } catch (error, stackTrace) {
      if (_currentUid == uid) {
        state = state.copyWith(
          history: AsyncError(error, stackTrace),
          historyLoaded: true,
        );
      }
      return previous;
    } finally {
      _historyRequest = null;
    }
  }

  String? get _currentUid => ref.read(firebaseAuthProvider).currentUser?.uid;

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
