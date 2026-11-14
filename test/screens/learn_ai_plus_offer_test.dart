import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vidyalaya/data/models/ai_image_draft.dart';
import 'package:vidyalaya/data/services/ai_image_recovery.dart';
import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyalaya/data/cache/cache_store.dart';
import 'package:vidyalaya/data/models/ingested_books.dart';
import 'package:vidyalaya/data/models/learn_assist.dart';
import 'package:vidyalaya/data/models/plus.dart';
import 'package:vidyalaya/data/repositories/user_prefs_repository.dart';
import 'package:vidyalaya/data/services/backend_auth_service.dart';
import 'package:vidyalaya/data/services/learn_assist_service.dart';
import 'package:vidyalaya/providers/auth_provider.dart';
import 'package:vidyalaya/providers/core_providers.dart';
import 'package:vidyalaya/providers/ingested_books_provider.dart';
import 'package:vidyalaya/providers/learn_assist_provider.dart';
import 'package:vidyalaya/providers/plus_provider.dart';
import 'package:vidyalaya/screens/learn/learn_ai_screen.dart';

class _RecoveryPicker extends Fake implements ImagePicker {
  final bool withImage;
  _RecoveryPicker(this.withImage);

  @override
  Future<LostDataResponse> retrieveLostData() async => withImage
      ? LostDataResponse(files: [XFile.fromData(base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII='),
          name: 'question.png', mimeType: 'image/png')])
      : LostDataResponse.empty();
}

/// The cache's box in memory. Widget tests run on simulated time, where a real
/// Hive file would never finish its I/O.
class _MemoryBox extends Fake implements Box<String> {
  final _data = <dynamic, String>{};

  @override
  String? get(dynamic key, {String? defaultValue}) => _data[key] ?? defaultValue;

  @override
  Future<void> put(dynamic key, String value) async => _data[key] = value;

  @override
  Future<void> delete(dynamic key) async => _data.remove(key);

  @override
  Iterable<dynamic> get keys => _data.keys;

  @override
  Future<int> deleteAll(Iterable<dynamic> keys) async {
    keys.toList().forEach(_data.remove);
    return keys.length;
  }
}

class _User extends Fake implements User {
  @override
  String get uid => 'student-a';

  @override
  String? get displayName => 'Asha Patra';
}

class _Auth extends Fake implements FirebaseAuth {
  @override
  User? currentUser = _User();
}

/// The account, already loaded: no network, no history.
class _Cache extends BackendAccountCache {
  @override
  BackendAccountState build() => BackendAccountState(
    uid: 'student-a',
    user: const AsyncData(BackendUser(userId: 'u', planKey: 'free')),
    profile: const AsyncData(
      StudentProfile(
        board: 'scert_odisha',
        classNo: 8,
        preferredLanguage: 'en',
        onboardingCompleted: true,
        revision: 1,
      ),
    ),
    usage: const AsyncData(
      LearnAssistUsage(
        dateIst: '2026-11-02',
        used: 3,
        limit: 3,
        remaining: 0,
        unlimited: false,
      ),
    ),
    userLoaded: true,
    profileLoaded: true,
    usageLoaded: true,
  );

  @override
  ChatHistoryPage? peekHistory(HistorySelector selector) => null;

  @override
  Future<ChatHistoryPage?> ensureHistory(
    HistorySelector selector, {
    bool forceRefresh = false,
  }) async => null;
}

/// The learning counters are covered elsewhere; this keeps them out of the way.
class _Repo extends UserPrefsRepository {
  _Repo(super.prefs);

  @override
  Future<void> recordAiSession() async {}
}

class _StubPlus extends PlusNotifier {
  @override
  PlusViewState build() => const PlusViewState(
    status: PlusStatus(
      state: PlusState.none,
      planKey: 'free',
      available: true,
      canRequest: true,
    ),
  );

  @override
  Future<void> refresh() async {}
}

http.Response _quotaExceeded() => http.Response(
  jsonEncode({
    'error': {
      'code': 'quota_exceeded',
      'message': 'Daily LearnAssist quota exceeded.',
      'retry_at_ist': DateTime(2026, 11, 3).toUtc().toIso8601String(),
    },
  }),
  429,
);

http.StreamedResponse _answer() => http.StreamedResponse(
  Stream.value(
    utf8.encode(
      'event: token\ndata: {"text":"Plants make food."}\n\n'
      'event: done\ndata: {"answer":"Plants make food.","citations":[],'
      '"usage":{"date_ist":"2026-11-03","used":1,"limit":3,"remaining":2,'
      '"unlimited":false}}\n\n',
    ),
  ),
  200,
  headers: {'content-type': 'text/event-stream'},
);

void main() {
  late SharedPreferences prefs;
  var server = 'refuse'; // refuse | answer | busy
  var asked = 0;

  setUp(() {
    server = 'refuse';
    asked = 0;
  });

  Future<void> pumpChat(WidgetTester tester, {bool? recoveredImage}) async {
    // Created here, inside the test's own time, so its saves can finish.
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    final recovery = AiImageRecovery(_Repo(prefs),
        picker: _RecoveryPicker(recoveredImage ?? false));
    if (recoveredImage != null) {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await recovery.prefs.setPrimaryClass(6, uid: 'student-a');
      await recovery.prefs.saveAiImageDraft(const AiImageDraft(
          uid: 'student-a', board: 'scert_odisha', classNo: 6,
          channel: 'learn_assist', subject: null, text: 'My restored question',
          language: 'en', style: 'ask'));
      try {
        await recovery.recover('student-a');
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    }
    final service = LearnAssistService(
      idTokenProvider: ({required forceRefresh}) async => 'token',
      baseUrl: Uri.parse('https://example.test'),
      client: MockClient.streaming((request, _) async {
        asked++;
        switch (server) {
          case 'answer':
            return _answer();
          case 'busy':
            return http.StreamedResponse(
              Stream.value(
                utf8.encode('{"error":{"code":"service_error","message":"Busy now."}}'),
              ),
              503,
            );
          default:
            final response = _quotaExceeded();
            return http.StreamedResponse(
              Stream.value(response.bodyBytes),
              response.statusCode,
            );
        }
      }),
    );
    final router = GoRouter(
      initialLocation: recovery.initialLocation ?? '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const LearnAiScreen()),
        GoRoute(path: '/learn/ai', builder: (_, _) => const LearnAiScreen(resume: true)),
      ],
    );
    addTearDown(router.dispose);
    await tester.binding.setSurfaceSize(const Size(900, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          aiImageRecoveryProvider.overrideWithValue(recovery),
          userPrefsRepositoryProvider.overrideWithValue(_Repo(prefs)),
          cacheStoreProvider.overrideWithValue(CacheStore(_MemoryBox())),
          firebaseAuthProvider.overrideWithValue(_Auth()),
          authStateProvider.overrideWith((ref) => Stream.value(_User())),
          backendAccountCacheProvider.overrideWith(_Cache.new),
          learnAssistServiceProvider.overrideWithValue(service),
          activeIngestedBooksProvider.overrideWithValue(
            const IngestedBooks.empty(),
          ),
          plusProvider.overrideWith(_StubPlus.new),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> ask(WidgetTester tester, String question) async {
    await tester.enterText(find.byType(TextField).last, question);
    await tester.testTextInput.receiveAction(TextInputAction.send);
    // The streamed answer needs the real event loop to finish, which simulated
    // time alone never gives it: yield to it, then let the screen catch up.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();
  }

  for (final withImage in [true, false]) {
    testWidgets('restart restores composer after picker (image=$withImage)', (tester) async {
      await pumpChat(tester, recoveredImage: withImage);
      expect(find.text('My restored question'), findsOneWidget);
      expect(find.byType(Image), withImage ? findsOneWidget : findsNothing);
      expect(UserPrefsRepository(prefs).getAiImageDraft(), isNull);
      expect(asked, 0, reason: 'Recovery must never automatically send');
    });
  }

  testWidgets('a refused question says when it refreshes and offers Plus', (tester) async {
    await pumpChat(tester);

    await ask(tester, 'What is photosynthesis?');

    expect(asked, 1);
    expect(find.text("That's all your questions for today"), findsOneWidget);
    expect(find.text('They refresh at midnight.'), findsOneWidget);
    expect(find.text('Request Plus'), findsOneWidget);
    // The chat itself still shows the refusal in plain words.
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(find.textContaining('They refresh at midnight.'), findsOneWidget);
  });

  testWidgets('the sheet opens once per limit, not on every refused send', (tester) async {
    await pumpChat(tester);
    await ask(tester, 'First question');
    expect(find.text('Not now'), findsOneWidget);
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    await ask(tester, 'Second question');

    expect(asked, 2, reason: 'the student can still try again');
    expect(find.text('Not now'), findsNothing, reason: 'but is not nagged');
  });

  testWidgets('a good answer re-arms the offer for the next limit', (tester) async {
    await pumpChat(tester);
    await ask(tester, 'First question');
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    server = 'answer'; // the allowance refilled
    await ask(tester, 'Now it works');
    expect(find.textContaining('Plants make food.'), findsWidgets);
    expect(find.text('Not now'), findsNothing);

    server = 'refuse'; // and ran out again
    await ask(tester, 'Out again');
    expect(find.text("That's all your questions for today"), findsOneWidget);
  });

  testWidgets('other failures never open the Plus sheet', (tester) async {
    await pumpChat(tester);
    server = 'busy';

    await ask(tester, 'Anything at all');

    expect(asked, 1);
    expect(find.textContaining('Busy now.'), findsOneWidget);
    expect(find.text("That's all your questions for today"), findsNothing);
    expect(find.text('Not now'), findsNothing);
  });
}
