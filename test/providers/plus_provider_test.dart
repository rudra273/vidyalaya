import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vidyalaya/data/cache/cache_store.dart';
import 'package:vidyalaya/data/models/learn_assist.dart';
import 'package:vidyalaya/data/models/plus.dart';
import 'package:vidyalaya/data/services/backend_auth_service.dart';
import 'package:vidyalaya/providers/auth_provider.dart';
import 'package:vidyalaya/providers/core_providers.dart';
import 'package:vidyalaya/providers/plus_provider.dart';

class _TestUser extends Fake implements User {
  _TestUser(this.uid);

  @override
  final String uid;
}

/// Stands in for the account cache: shows a plan, and records when the app was
/// told to refresh it.
class _RecordingCache extends BackendAccountCache {
  _RecordingCache({this.planKey, this.userLoaded = true});

  final String? planKey;
  final bool userLoaded;
  final calls = <String>[];

  @override
  BackendAccountState build() => BackendAccountState(
    uid: 'student-a',
    user: AsyncData(planKey == null ? null : BackendUser(userId: 'u', planKey: planKey)),
    userLoaded: userLoaded,
  );

  @override
  Future<BackendUser?> ensureUser({bool forceRefresh = false}) async {
    calls.add('user:$forceRefresh');
    return null;
  }

  @override
  Future<LearnAssistUsage?> ensureUsage({bool forceRefresh = false}) async {
    calls.add('usage:$forceRefresh');
    return null;
  }
}

http.Response _json(Map<String, Object?> body, [int status = 200]) =>
    http.Response(jsonEncode(body), status);

http.Response _status(
  String state, {
  String plan = 'free',
  bool canRequest = false,
  bool available = true,
}) => _json({
  'state': state,
  'plan_key': plan,
  'available': available,
  'can_request': canRequest,
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory cacheDirectory;
  late Box<String> box;

  setUp(() async {
    cacheDirectory = await Directory.systemTemp.createTemp('plus-test-');
    Hive.init(cacheDirectory.path);
    box = await Hive.openBox<String>(CacheStore.boxName);
  });

  tearDown(() async {
    await box.close();
    await cacheDirectory.delete(recursive: true);
  });

  ProviderContainer containerFor(
    MockClient client, {
    Stream<User?>? authStream,
    _RecordingCache? account,
  }) {
    final service = BackendAuthService(
      client: client,
      idTokenProvider: ({required forceRefresh}) async => 'test-token',
      baseUrl: Uri.parse('https://example.test'),
    );
    final container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith(
          (ref) => authStream ?? Stream.value(_TestUser('student-a')),
        ),
        backendAuthServiceProvider.overrideWithValue(service),
        cacheStoreProvider.overrideWithValue(CacheStore(box)),
        backendAccountCacheProvider.overrideWith(
          () => account ?? _RecordingCache(planKey: 'free'),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(authStateProvider, (_, _) {});
    return container;
  }

  Future<void> signedIn(ProviderContainer container) =>
      container.read(authStateProvider.future);

  Future<void> cached(String uid) async {
    final key = CacheStore.key(uid: uid, name: 'plus_status');
    for (var i = 0; i < 200 && !box.containsKey(key); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    expect(box.containsKey(key), isTrue);
  }

  group('refreshing', () {
    test('loads the status in the background and remembers it', () async {
      final container = containerFor(
        MockClient((request) async {
          expect(request.url.path, '/me/plus');
          return _status('none', canRequest: true);
        }),
      );
      await signedIn(container);

      expect(container.read(plusProvider).status, isNull);
      await pumpEventQueue();

      final status = container.read(plusProvider).status!;
      expect((status.state, status.canRequest), (PlusState.none, true));
      await cached('student-a');
    });

    test('shows the last answer at once, then the fresh one', () async {
      final first = containerFor(MockClient((_) async => _status('pending')));
      await signedIn(first);
      first.read(plusProvider);
      await cached('student-a');

      final later = Completer<http.Response>();
      final second = containerFor(MockClient((_) => later.future));
      await signedIn(second);

      expect(second.read(plusProvider).status!.state, PlusState.pending);
      later.complete(_status('active', plan: 'plus'));
      await pumpEventQueue();
      expect(second.read(plusProvider).status!.state, PlusState.active);
    });

    test('offline or a server error keeps what is showing', () async {
      final first = containerFor(MockClient((_) async => _status('pending')));
      await signedIn(first);
      first.read(plusProvider);
      await cached('student-a');

      for (final failing in [
        MockClient((_) async => throw const SocketException('offline')),
        MockClient((_) async => http.Response('boom', 500)),
      ]) {
        final container = containerFor(failing);
        await signedIn(container);
        container.read(plusProvider);
        await pumpEventQueue();
        expect(container.read(plusProvider).status!.state, PlusState.pending);
      }
    });

    test('one student never sees another\'s status', () async {
      final first = containerFor(MockClient((_) async => _status('pending')));
      await signedIn(first);
      first.read(plusProvider);
      await cached('student-a');

      final other = containerFor(
        MockClient((_) async => http.Response('boom', 500)),
        authStream: Stream.value(_TestUser('student-b')),
      );
      await signedIn(other);

      expect(other.read(plusProvider).status, isNull);
    });

    test('a response that lands after sign-out is discarded', () async {
      final slow = Completer<http.Response>();
      final auth = StreamController<User?>();
      addTearDown(auth.close);
      final container = containerFor(
        MockClient((_) => slow.future),
        authStream: auth.stream,
      );
      auth.add(_TestUser('student-a'));
      await signedIn(container);
      container.read(plusProvider);
      await pumpEventQueue();

      auth.add(null);
      await pumpEventQueue();
      slow.complete(_status('active', plan: 'plus'));
      await pumpEventQueue();

      expect(container.read(plusProvider).status, isNull);
      expect(box.keys.whereType<String>().where((k) => k.startsWith('student-a:')), isEmpty);
    });

    test('coming back to the app checks again', () async {
      var requests = 0;
      final container = containerFor(
        MockClient((_) async {
          requests++;
          return _status(requests == 1 ? 'pending' : 'active', plan: requests == 1 ? 'free' : 'plus');
        }),
      );
      await signedIn(container);
      container.listen(plusProvider, (_, _) {});
      await pumpEventQueue();
      expect(container.read(plusProvider).status!.state, PlusState.pending);

      // The sequence a phone really goes through when the app is put away and
      // brought back.
      final binding = TestWidgetsFlutterBinding.instance;
      for (final step in [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        binding.handleAppLifecycleStateChanged(step);
      }
      await pumpEventQueue();

      expect(requests, 2);
      expect(container.read(plusProvider).status!.state, PlusState.active);
    });
  });

  group('the account follows the plan', () {
    test('an approval refreshes the plan label and limits at once', () async {
      final account = _RecordingCache(planKey: 'free');
      final container = containerFor(
        MockClient((_) async => _status('active', plan: 'plus')),
        account: account,
      );
      await signedIn(container);
      container.read(plusProvider);
      await pumpEventQueue();

      expect(account.calls, containsAll(['user:true', 'usage:true']));
    });

    test('Plus ending refreshes the account the other way', () async {
      final account = _RecordingCache(planKey: 'plus');
      final container = containerFor(
        MockClient((_) async => _status('expired', canRequest: true)),
        account: account,
      );
      await signedIn(container);
      container.read(plusProvider);
      await pumpEventQueue();

      expect(account.calls, containsAll(['user:true', 'usage:true']));
    });

    test('nothing is refreshed when the plan already matches', () async {
      final account = _RecordingCache(planKey: 'plus');
      final container = containerFor(
        MockClient((_) async => _status('active', plan: 'plus')),
        account: account,
      );
      await signedIn(container);
      container.read(plusProvider);
      await pumpEventQueue();

      expect(account.calls, isEmpty);
    });

    test('nothing is refreshed while the account is still loading', () async {
      final account = _RecordingCache(planKey: null, userLoaded: false);
      final container = containerFor(
        MockClient((_) async => _status('active', plan: 'plus')),
        account: account,
      );
      await signedIn(container);
      container.read(plusProvider);
      await pumpEventQueue();

      expect(account.calls, isEmpty, reason: 'its own first fetch will be current');
    });
  });

  group('asking for Plus', () {
    test('sends the screen and shows the request as pending', () async {
      final bodies = <Object?>[];
      final container = containerFor(
        MockClient((request) async {
          if (request.method == 'POST') {
            bodies.add(jsonDecode(request.body));
            return _status('pending');
          }
          return _status('none', canRequest: true);
        }),
      );
      await signedIn(container);
      container.read(plusProvider);
      await pumpEventQueue();

      final sent = await container.read(plusProvider.notifier).request(PlusSource.profile);

      expect(sent, isTrue);
      expect(bodies, [{'source': 'profile'}]);
      final state = container.read(plusProvider);
      expect(state.status!.state, PlusState.pending);
      expect((state.requesting, state.error), (false, null));
      await cached('student-a');
    });

    test('two quick taps send one request', () async {
      var posts = 0;
      final gate = Completer<http.Response>();
      final container = containerFor(
        MockClient((request) async {
          if (request.method == 'POST') {
            posts++;
            return gate.future;
          }
          return _status('none', canRequest: true);
        }),
      );
      await signedIn(container);
      container.read(plusProvider);
      await pumpEventQueue();

      final notifier = container.read(plusProvider.notifier);
      final first = notifier.request(PlusSource.profile);
      expect(container.read(plusProvider).requesting, isTrue);
      final second = await notifier.request(PlusSource.profile);
      gate.complete(_status('pending'));
      await first;

      expect(second, isFalse);
      expect(posts, 1);
    });

    test('a refusal shows the server\'s neutral words and re-checks the status', () async {
      var gets = 0;
      final container = containerFor(
        MockClient((request) async {
          if (request.method == 'POST') {
            return _json({
              'error': {'code': 'plus_cooldown', 'message': "Plus isn't available for your account right now."},
            }, 409);
          }
          gets++;
          return gets == 1 ? _status('none', canRequest: true) : _status('declined');
        }),
      );
      await signedIn(container);
      container.read(plusProvider);
      await pumpEventQueue();

      final sent = await container.read(plusProvider.notifier).request(PlusSource.profile);
      await pumpEventQueue();

      expect(sent, isFalse);
      final state = container.read(plusProvider);
      expect(state.error, "Plus isn't available for your account right now.");
      expect(state.status!.state, PlusState.declined, reason: 'the server is the truth');
      expect(state.requesting, isFalse);
    });

    test('a network failure says so kindly and changes nothing else', () async {
      final container = containerFor(
        MockClient((request) async {
          if (request.method == 'POST') throw const SocketException('offline');
          return _status('none', canRequest: true);
        }),
      );
      await signedIn(container);
      container.read(plusProvider);
      await pumpEventQueue();

      final sent = await container.read(plusProvider.notifier).request(PlusSource.profile);

      expect(sent, isFalse);
      final state = container.read(plusProvider);
      expect(state.error, contains('check your connection'));
      expect(state.status!.state, PlusState.none);
      expect(state.requesting, isFalse);
    });

    test('a request that lands after sign-out is not applied', () async {
      final gate = Completer<http.Response>();
      final auth = StreamController<User?>();
      addTearDown(auth.close);
      final container = containerFor(
        MockClient((request) async {
          if (request.method == 'POST') return gate.future;
          return _status('none', canRequest: true);
        }),
        authStream: auth.stream,
      );
      auth.add(_TestUser('student-a'));
      await signedIn(container);
      container.read(plusProvider);
      await pumpEventQueue();

      final pending = container.read(plusProvider.notifier).request(PlusSource.profile);
      auth.add(null);
      await pumpEventQueue();
      gate.complete(_status('pending'));
      final sent = await pending;

      expect(sent, isFalse);
      expect(container.read(plusProvider).status, isNull);
    });

    test('signed out, there is nothing to ask', () async {
      final container = containerFor(
        MockClient((_) async => fail('no request should be made')),
        authStream: Stream.value(null),
      );
      await signedIn(container);

      expect(await container.read(plusProvider.notifier).request(PlusSource.profile), isFalse);
      expect(container.read(plusProvider), const PlusViewState());
    });
  });

  test('the view state compares by value', () {
    const status = PlusStatus(
      state: PlusState.none,
      planKey: 'free',
      available: true,
      canRequest: true,
    );

    expect(const PlusViewState(status: status), const PlusViewState(status: status));
    expect(const PlusViewState(status: status).copyWith(error: 'x').error, 'x');
    expect(const PlusViewState(error: 'x').copyWith(clearError: true).error, isNull);
  });
}
