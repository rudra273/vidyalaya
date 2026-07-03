import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vidyalaya/data/models/learn_assist.dart';
import 'package:vidyalaya/data/services/backend_auth_service.dart';
import 'package:vidyalaya/data/services/learn_assist_service.dart';

void main() {
  group('LearnAssistRequest', () {
    test('serializes with a selected subject', () {
      const request = LearnAssistRequest(
        message: 'Who was Major Somnath Sharma?',
        board: 'scert_odisha',
        classNo: 8,
        subject: 'english',
        language: 'en',
        debug: false,
      );

      expect(request.toJson(), {
        'message': 'Who was Major Somnath Sharma?',
        'board': 'scert_odisha',
        'class_no': 8,
        'channel': LearnAssistChannel.learnAssist,
        'subject': 'english',
        'language': 'en',
        'debug': false,
      });
    });

    test('serializes subject as null for all subjects', () {
      const request = LearnAssistRequest(
        message: 'Question',
        board: 'scert_odisha',
        classNo: 8,
        subject: null,
        language: 'en',
      );

      expect(request.toJson()['subject'], isNull);
      expect(request.toJson()['debug'], isFalse);
    });
  });

  group('LearnAssistResponse', () {
    test('parses citations with int, array, and null page_no values', () {
      final response = LearnAssistResponse.fromJson({
        'answer': 'Answer [1]',
        'citations': [
          {
            'label': '[1]',
            'book_name': 'Jasmine',
            'source_pdf': 'English_Jasmine.pdf',
            'page_no': 69,
            'score': 0.75,
            'chunk_ids': ['chunk_1'],
          },
          {
            'label': '[2]',
            'book_name': 'Science',
            'source_pdf': null,
            'page_no': [10, 11],
            'score': null,
            'chunk_ids': ['chunk_2'],
          },
          {
            'label': '[3]',
            'book_name': null,
            'source_pdf': null,
            'page_no': null,
            'score': null,
            'chunk_ids': [],
          },
        ],
        'context_blocks': null,
      });

      expect(response.answer, 'Answer [1]');
      expect(response.citations[0].pageNumbers, [69]);
      expect(response.citations[1].pageNumbers, [10, 11]);
      expect(response.citations[2].pageNumbers, isEmpty);
    });

    test('parses empty citations', () {
      final response = LearnAssistResponse.fromJson({
        'answer': 'Answer',
        'citations': [],
      });

      expect(response.citations, isEmpty);
    });
  });

  group('cache model serialization', () {
    test('round-trips LearnAssistUsage', () {
      const usage = LearnAssistUsage(
        dateIst: '2026-05-31',
        used: 2,
        limit: 10,
        remaining: 8,
        unlimited: false,
      );

      final roundTripped = LearnAssistUsage.fromJson(usage.toJson());

      expect(roundTripped.dateIst, usage.dateIst);
      expect(roundTripped.used, usage.used);
      expect(roundTripped.limit, usage.limit);
      expect(roundTripped.remaining, usage.remaining);
      expect(roundTripped.unlimited, usage.unlimited);
    });

    test('round-trips LearnAssistCitation', () {
      const citation = LearnAssistCitation(
        label: '[1]',
        bookName: 'Science',
        sourcePdf: 'science.pdf',
        pageNumbers: [10, 11],
        score: 0.85,
        chunkIds: ['chunk-1'],
      );

      final roundTripped = LearnAssistCitation.fromJson(citation.toJson());

      expect(roundTripped.label, citation.label);
      expect(roundTripped.bookName, citation.bookName);
      expect(roundTripped.sourcePdf, citation.sourcePdf);
      expect(roundTripped.pageNumbers, citation.pageNumbers);
      expect(roundTripped.score, citation.score);
      expect(roundTripped.chunkIds, citation.chunkIds);
    });

    test('round-trips backend user', () {
      const user = BackendUser(
        userId: 'user-1',
        firebaseUid: 'firebase-1',
        dbId: 'db-1',
        email: 'student@example.com',
        name: 'Student',
        role: 'student',
        status: 'active',
        planKey: 'free',
        planDailyLimit: 10,
        planProvider: 'openai',
        planModel: 'gpt-5-mini',
      );

      final roundTripped = BackendUser.fromJson(user.toJson());

      expect(roundTripped.userId, user.userId);
      expect(roundTripped.firebaseUid, user.firebaseUid);
      expect(roundTripped.dbId, user.dbId);
      expect(roundTripped.email, user.email);
      expect(roundTripped.name, user.name);
      expect(roundTripped.role, user.role);
      expect(roundTripped.status, user.status);
      expect(roundTripped.planKey, user.planKey);
      expect(roundTripped.planDailyLimit, user.planDailyLimit);
      expect(roundTripped.planProvider, user.planProvider);
      expect(roundTripped.planModel, user.planModel);
    });

    test('round-trips full student profile cache JSON', () {
      final profile = StudentProfile(
        board: 'scert_odisha',
        classNo: 8,
        preferredLanguage: 'or',
        schoolName: 'Demo School',
        onboardingCompleted: true,
        createdAt: DateTime.utc(2026, 5, 30, 10),
        updatedAt: DateTime.utc(2026, 5, 31, 11),
      );

      final roundTripped = StudentProfile.fromJson(profile.toCacheJson());

      expect(roundTripped.board, profile.board);
      expect(roundTripped.classNo, profile.classNo);
      expect(roundTripped.preferredLanguage, profile.preferredLanguage);
      expect(roundTripped.schoolName, profile.schoolName);
      expect(roundTripped.onboardingCompleted, profile.onboardingCompleted);
      expect(roundTripped.createdAt, profile.createdAt);
      expect(roundTripped.updatedAt, profile.updatedAt);
    });

    test('round-trips chat history page', () {
      final page = ChatHistoryPage(
        nextBefore: 42,
        messages: [
          ChatHistoryMessage(
            id: 7,
            role: 'assistant',
            content: 'Answer',
            citations: const [LearnAssistCitation(label: '[1]')],
            createdAt: DateTime.utc(2026, 5, 31, 12),
          ),
        ],
      );

      final roundTripped = ChatHistoryPage.fromJson(page.toJson());

      expect(roundTripped.nextBefore, page.nextBefore);
      expect(roundTripped.messages.single.id, page.messages.single.id);
      expect(roundTripped.messages.single.role, page.messages.single.role);
      expect(
        roundTripped.messages.single.content,
        page.messages.single.content,
      );
      expect(
        roundTripped.messages.single.createdAt,
        page.messages.single.createdAt,
      );
      expect(roundTripped.messages.single.citations.single.label, '[1]');
    });
  });

  group('LearnAssistService', () {
    test('throws API exception for error responses', () async {
      final service = LearnAssistService(
        idTokenProvider: ({required forceRefresh}) async => 'firebase-token',
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'error': {
                'code': 'bad_request',
                'message': 'message is required',
              },
            }),
            400,
          ),
        ),
      );

      expect(
        service.chat(
          const LearnAssistRequest(
            message: '',
            board: 'scert_odisha',
            classNo: 8,
          ),
        ),
        throwsA(
          isA<LearnAssistApiException>()
              .having((error) => error.code, 'code', 'bad_request')
              .having(
                (error) => error.message,
                'message',
                'message is required',
              ),
        ),
      );
    });

    test('throws API exception for invalid JSON', () async {
      final service = LearnAssistService(
        idTokenProvider: ({required forceRefresh}) async => 'firebase-token',
        client: MockClient((_) async => http.Response('not json', 200)),
      );

      expect(
        service.chat(
          const LearnAssistRequest(
            message: 'Question',
            board: 'scert_odisha',
            classNo: 8,
          ),
        ),
        throwsA(
          isA<LearnAssistApiException>().having(
            (error) => error.code,
            'code',
            'invalid_response',
          ),
        ),
      );
    });

    test('sends bearer token without user identity fields', () async {
      late http.Request capturedRequest;
      final service = LearnAssistService(
        idTokenProvider: ({required forceRefresh}) async => 'firebase-token',
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({
              'answer': 'Answer',
              'citations': [],
              'retrieval': {'class_no': 8},
            }),
            200,
          );
        }),
      );

      await service.chat(
        const LearnAssistRequest(
          message: 'Question',
          board: 'scert_odisha',
          classNo: 8,
          subject: null,
          language: 'en',
        ),
      );

      final body = jsonDecode(capturedRequest.body) as Map<String, dynamic>;
      expect(capturedRequest.headers['Authorization'], 'Bearer firebase-token');
      expect(capturedRequest.headers['Content-Type'], 'application/json');
      expect(body, isNot(contains('user_id')));
      expect(body, isNot(contains('email')));
      expect(body, isNot(contains('name')));
      expect(body, isNot(contains('picture')));
      expect(body, isNot(contains('query')));
      expect(body['message'], 'Question');
      expect(body['subject'], isNull);
    });

    test('refreshes token once when the backend returns 401', () async {
      final forceRefreshValues = <bool>[];
      final authorizationHeaders = <String?>[];
      var callCount = 0;

      final service = LearnAssistService(
        idTokenProvider: ({required forceRefresh}) async {
          forceRefreshValues.add(forceRefresh);
          return forceRefresh ? 'fresh-token' : 'stale-token';
        },
        client: MockClient((request) async {
          callCount += 1;
          authorizationHeaders.add(request.headers['Authorization']);
          if (callCount == 1) {
            return http.Response(
              jsonEncode({
                'error': {
                  'code': 'unauthorized',
                  'message': 'Invalid or expired bearer token.',
                },
              }),
              401,
            );
          }
          return http.Response(
            jsonEncode({
              'answer': 'Answer',
              'citations': [],
              'retrieval': {'class_no': 8},
            }),
            200,
          );
        }),
      );

      final response = await service.chat(
        const LearnAssistRequest(
          message: 'Question',
          board: 'scert_odisha',
          classNo: 8,
        ),
      );

      expect(response.answer, 'Answer');
      expect(forceRefreshValues, [false, true]);
      expect(authorizationHeaders, [
        'Bearer stale-token',
        'Bearer fresh-token',
      ]);
    });

    test('chatStream parses token and done frames in order', () async {
      final service = LearnAssistService(
        idTokenProvider: ({required forceRefresh}) async => 'firebase-token',
        client: MockClient(
          (_) async => http.Response(
            'event: token\n'
            'data: {"text":"Hel"}\n'
            '\n'
            'event: token\n'
            'data: {"text":"lo"}\n'
            '\n'
            'event: done\n'
            'data: {"answer":"Hello","citations":[],"usage":{"date_ist":'
            '"2026-05-31","used":1,"limit":10,"remaining":9,"unlimited":false}}\n'
            '\n',
            200,
          ),
        ),
      );

      final events = await service
          .chatStream(
            const LearnAssistRequest(
              message: 'Question',
              board: 'scert_odisha',
              classNo: 8,
            ),
          )
          .toList();

      expect(events, [
        isA<LearnAssistTokenEvent>().having((e) => e.text, 'text', 'Hel'),
        isA<LearnAssistTokenEvent>().having((e) => e.text, 'text', 'lo'),
        isA<LearnAssistDoneEvent>()
            .having((e) => e.answer, 'answer', 'Hello')
            .having((e) => e.citations, 'citations', isEmpty)
            .having((e) => e.usage?.remaining, 'usage.remaining', 9),
      ]);
    });

    test('chatStream carries the full answer in done when no tokens stream',
        () async {
      // Reproduces the OpenRouter (paid-plan) path: the server emits zero token
      // frames and delivers the whole answer in the terminal done frame.
      final service = LearnAssistService(
        idTokenProvider: ({required forceRefresh}) async => 'firebase-token',
        client: MockClient(
          (_) async => http.Response(
            'event: done\n'
            'data: {"answer":"Full answer with no token frames.",'
            '"citations":[]}\n'
            '\n',
            200,
          ),
        ),
      );

      final events = await service
          .chatStream(
            const LearnAssistRequest(
              message: 'Question',
              board: 'scert_odisha',
              classNo: 8,
            ),
          )
          .toList();

      expect(events, [
        isA<LearnAssistDoneEvent>().having(
          (e) => e.answer,
          'answer',
          'Full answer with no token frames.',
        ),
      ]);
    });

    test('chatStream yields an error event for a mid-stream failure', () async {
      final service = LearnAssistService(
        idTokenProvider: ({required forceRefresh}) async => 'firebase-token',
        client: MockClient(
          (_) async => http.Response(
            'event: token\n'
            'data: {"text":"Hi"}\n'
            '\n'
            'event: error\n'
            'data: {"code":"assistant_timeout","message":"Timed out."}\n'
            '\n',
            200,
          ),
        ),
      );

      final events = await service
          .chatStream(
            const LearnAssistRequest(
              message: 'Question',
              board: 'scert_odisha',
              classNo: 8,
            ),
          )
          .toList();

      expect(events.last, isA<LearnAssistErrorEvent>());
      expect((events.last as LearnAssistErrorEvent).code, 'assistant_timeout');
    });

    test('chatStream refreshes token once on a pre-flight 401', () async {
      final forceRefreshValues = <bool>[];
      var callCount = 0;

      final service = LearnAssistService(
        idTokenProvider: ({required forceRefresh}) async {
          forceRefreshValues.add(forceRefresh);
          return forceRefresh ? 'fresh-token' : 'stale-token';
        },
        client: MockClient((request) async {
          callCount += 1;
          if (callCount == 1) {
            return http.Response(
              jsonEncode({
                'error': {
                  'code': 'unauthorized',
                  'message': 'Invalid or expired bearer token.',
                },
              }),
              401,
            );
          }
          return http.Response(
            'event: done\ndata: {"citations":[]}\n\n',
            200,
          );
        }),
      );

      final events = await service
          .chatStream(
            const LearnAssistRequest(
              message: 'Question',
              board: 'scert_odisha',
              classNo: 8,
            ),
          )
          .toList();

      expect(events, [isA<LearnAssistDoneEvent>()]);
      expect(forceRefreshValues, [false, true]);
    });

    test(
      'chatStream throws for a pre-flight error that survives the retry',
      () async {
        final service = LearnAssistService(
          idTokenProvider: ({required forceRefresh}) async => 'stale-token',
          client: MockClient(
            (_) async => http.Response(
              jsonEncode({
                'error': {'code': 'quota_exceeded', 'message': 'Out of quota.'},
              }),
              429,
            ),
          ),
        );

        expect(
          service
              .chatStream(
                const LearnAssistRequest(
                  message: 'Question',
                  board: 'scert_odisha',
                  classNo: 8,
                ),
              )
              .toList(),
          throwsA(
            isA<LearnAssistApiException>().having(
              (error) => error.code,
              'code',
              'quota_exceeded',
            ),
          ),
        );
      },
    );
  });
}
