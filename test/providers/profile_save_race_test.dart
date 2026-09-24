import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyalaya/data/cache/cache_store.dart';
import 'package:vidyalaya/data/models/ingested_books.dart';
import 'package:vidyalaya/data/services/backend_auth_service.dart';
import 'package:vidyalaya/providers/auth_provider.dart';
import 'package:vidyalaya/providers/core_providers.dart';
import 'package:vidyalaya/providers/ingested_books_provider.dart';

class _TestUser extends Fake implements User {
  @override
  String get uid => 'student-a';
}

class _TestAuth extends Fake implements FirebaseAuth {
  _TestAuth(this.user);

  final User user;

  @override
  User? get currentUser => user;
}

http.Response _profileResponse(int revision, int classNo, {String? avatarId}) =>
    http.Response(
      jsonEncode({
        'board': 'scert_odisha',
        'class_no': classNo,
        'preferred_language': 'en',
        'name': 'Asha',
        'avatar_id': avatarId,
        'revision': revision,
        'onboarding_completed': true,
      }),
      200,
    );

http.Response _eventResponse(http.Request request) => http.Response(
  jsonEncode({
    'event_id': jsonDecode(request.body)['event_id'],
    'recorded': true,
  }),
  200,
);

StudentProfile _profile(int revision, int classNo, {String? avatarId}) =>
    StudentProfile(
      board: 'scert_odisha',
      classNo: classNo,
      preferredLanguage: 'en',
      name: 'Asha',
      avatarId: avatarId,
      revision: revision,
    );

void main() {
  late Directory cacheDirectory;
  late Box<String> box;
  late SharedPreferences preferences;
  final user = _TestUser();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    cacheDirectory = await Directory.systemTemp.createTemp(
      'profile-cache-test-',
    );
    Hive.init(cacheDirectory.path);
    box = await Hive.openBox<String>(CacheStore.boxName);
  });

  tearDown(() async {
    await box.close();
    await cacheDirectory.delete(recursive: true);
  });

  ProviderContainer containerFor(MockClient client) {
    final service = BackendAuthService(
      client: client,
      idTokenProvider: ({required forceRefresh}) async => 'test-token',
      baseUrl: Uri.parse('https://example.test'),
    );
    final container = ProviderContainer(
      overrides: [
        firebaseAuthProvider.overrideWithValue(_TestAuth(user)),
        authStateProvider.overrideWith((ref) => Stream.value(user)),
        backendAuthServiceProvider.overrideWithValue(service),
        cacheStoreProvider.overrideWithValue(CacheStore(box)),
        sharedPreferencesProvider.overrideWithValue(preferences),
        activeIngestedBooksProvider.overrideWithValue(
          const IngestedBooks.empty(),
        ),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(authStateProvider, (_, _) {});
    addTearDown(subscription.close);
    return container;
  }

  test('a slow profile GET cannot replace a newer save', () async {
    final slowGet = Completer<http.Response>();
    final getStarted = Completer<void>();
    final client = MockClient((request) async {
      if (request.url.path == '/me/events') return _eventResponse(request);
      if (request.method == 'GET') {
        getStarted.complete();
        return slowGet.future;
      }
      expect(request.method, 'PUT');
      return _profileResponse(2, 9, avatarId: 'girl_2');
    });
    final container = containerFor(client);
    await container.read(authStateProvider.future);
    final cache = container.read(backendAccountCacheProvider.notifier);

    final pendingRead = cache.ensureProfile();
    await getStarted.future;
    await cache.saveProfile(_profile(1, 9, avatarId: 'girl_2'));
    slowGet.complete(_profileResponse(1, 8, avatarId: 'boy_1'));
    await pendingRead;

    final stored = container.read(backendAccountCacheProvider).profile.value;
    expect(stored?.revision, 2);
    expect(stored?.classNo, 9);
    expect(stored?.avatarId, 'girl_2');
  });

  test('a lost PUT response reconciles the committed profile', () async {
    var reads = 0;
    final client = MockClient((request) async {
      if (request.url.path == '/me/events') return _eventResponse(request);
      if (request.method == 'PUT') {
        throw http.ClientException('response lost');
      }
      reads++;
      return _profileResponse(2, 9);
    });
    final container = containerFor(client);
    await container.read(authStateProvider.future);
    final cache = container.read(backendAccountCacheProvider.notifier);

    final saved = await cache.saveProfile(_profile(1, 9));

    expect(reads, 1);
    expect(saved.revision, 2);
    expect(
      container.read(backendAccountCacheProvider).profile.value?.revision,
      2,
    );
  });

  test('an offline save keeps the last confirmed profile for retry', () async {
    var reads = 0;
    final client = MockClient((request) async {
      if (request.url.path == '/me/events') return _eventResponse(request);
      if (request.method == 'GET' && reads++ == 0) {
        return _profileResponse(1, 8);
      }
      throw http.ClientException('offline');
    });
    final container = containerFor(client);
    await container.read(authStateProvider.future);
    final cache = container.read(backendAccountCacheProvider.notifier);
    await cache.ensureProfile();

    await expectLater(cache.saveProfile(_profile(1, 9)), throwsException);

    final confirmed = container.read(backendAccountCacheProvider).profile.value;
    expect(confirmed?.revision, 1);
    expect(confirmed?.classNo, 8);
  });
  test(
    'lost response cannot accept a different server avatar as success',
    () async {
      final client = MockClient((request) async {
        if (request.url.path == '/me/events') return _eventResponse(request);
        if (request.method == 'PUT') {
          throw http.ClientException('response lost');
        }
        return _profileResponse(2, 9, avatarId: 'boy_1');
      });
      final container = containerFor(client);
      await container.read(authStateProvider.future);
      final cache = container.read(backendAccountCacheProvider.notifier);
      await expectLater(
        cache.saveProfile(_profile(1, 9, avatarId: 'girl_2')),
        throwsException,
      );
    },
  );
}
