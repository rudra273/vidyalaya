import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vidyalaya/data/cache/cache_store.dart';
import 'package:vidyalaya/data/models/rollout_switches.dart';
import 'package:vidyalaya/data/services/backend_auth_service.dart';
import 'package:vidyalaya/providers/auth_provider.dart';
import 'package:vidyalaya/providers/core_providers.dart';
import 'package:vidyalaya/providers/rollout_switches_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class _TestUser extends Fake implements User {
  _TestUser(this.uid);

  @override
  final String uid;
}

http.Response _switches(Map<String, bool> values) =>
    http.Response(jsonEncode({'version': 1, 'switches': values}), 200);

void main() {
  late Directory cacheDirectory;
  late Box<String> box;

  setUp(() async {
    cacheDirectory = await Directory.systemTemp.createTemp('switches-test-');
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
      ],
    );
    addTearDown(container.dispose);
    container.listen(authStateProvider, (_, _) {});
    return container;
  }

  // The cache write is real disk I/O, so wait for it rather than pumping.
  Future<void> untilCached(String uid) async {
    final key = CacheStore.key(uid: uid, name: 'rollout_switches');
    for (var i = 0; i < 200 && !box.containsKey(key); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    expect(box.containsKey(key), isTrue);
  }

  group('RolloutSwitches', () {
    test('keeps the caller default for a switch the server omits', () {
      final switches = RolloutSwitches.fromJson({
        'switches': {'books': false},
      });

      expect(switches.isEnabled('books', defaultValue: true), isFalse);
      expect(switches.isEnabled('other', defaultValue: true), isTrue);
      expect(switches.isEnabled('other', defaultValue: false), isFalse);
    });

    test('ignores non-boolean values and round-trips through JSON', () {
      final switches = RolloutSwitches.fromJson({
        'switches': {'books': false, 'junk': 'yes', 'n': 1},
      });

      expect(switches, RolloutSwitches.fromJson(switches.toJson()));
      expect(switches.isEnabled('junk', defaultValue: true), isTrue);
    });

    test('rejects a response with no switches object', () {
      expect(
        () => RolloutSwitches.fromJson({'version': 1}),
        throwsFormatException,
      );
    });
  });

  group('rolloutSwitchesProvider', () {
    test('requests /config/v1 and turns books off when the server says so', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/config/v1');
        expect(request.headers['authorization'], 'Bearer test-token');
        return _switches({'books': false});
      });
      final container = containerFor(client);
      await container.read(authStateProvider.future);

      expect(container.read(booksEnabledProvider), isTrue);
      await pumpEventQueue();

      expect(container.read(booksEnabledProvider), isFalse);
    });

    test('a failed request keeps books on', () async {
      final container = containerFor(
        MockClient((request) async => http.Response('boom', 500)),
      );
      await container.read(authStateProvider.future);
      container.read(rolloutSwitchesProvider);
      await pumpEventQueue();

      expect(container.read(booksEnabledProvider), isTrue);
    });

    test('the last response applies at once on the next start', () async {
      final first = containerFor(MockClient((_) async => _switches({'books': false})));
      await first.read(authStateProvider.future);
      first.read(rolloutSwitchesProvider);
      await untilCached('student-a');

      final offline = containerFor(
        MockClient((_) async => throw const SocketException('offline')),
      );
      await offline.read(authStateProvider.future);

      expect(offline.read(booksEnabledProvider), isFalse);
    });

    test('switches are cached per student', () async {
      final first = containerFor(MockClient((_) async => _switches({'books': false})));
      await first.read(authStateProvider.future);
      first.read(rolloutSwitchesProvider);
      await untilCached('student-a');

      final other = containerFor(
        MockClient((_) async => http.Response('boom', 500)),
        authStream: Stream.value(_TestUser('student-b')),
      );
      await other.read(authStateProvider.future);

      expect(other.read(booksEnabledProvider), isTrue);
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
      await container.read(authStateProvider.future);
      container.read(rolloutSwitchesProvider);
      await pumpEventQueue();

      auth.add(null);
      await pumpEventQueue();
      slow.complete(_switches({'books': false}));
      await pumpEventQueue();

      expect(container.read(booksEnabledProvider), isTrue);
      expect(
        box.keys.whereType<String>().where((k) => k.startsWith('student-a:')),
        isEmpty,
      );
    });
  });
}
