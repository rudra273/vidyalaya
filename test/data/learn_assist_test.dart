import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vidyalaya/data/models/learn_assist.dart';
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
        'retrieval': {
          'query': 'Question',
          'board': 'scert_odisha',
          'class_no': 8,
          'subject_filter': 'english',
          'subjects_found': ['english'],
          'pages_found': [62, 69],
          'top_score': 0.75,
          'context_block_count': 4,
          'tool_used': true,
        },
        'context_blocks': null,
      });

      expect(response.answer, 'Answer [1]');
      expect(response.citations[0].pageNumbers, [69]);
      expect(response.citations[1].pageNumbers, [10, 11]);
      expect(response.citations[2].pageNumbers, isEmpty);
      expect(response.retrieval.subjectFilter, 'english');
      expect(response.retrieval.toolUsed, isTrue);
    });

    test('parses empty citations', () {
      final response = LearnAssistResponse.fromJson({
        'answer': 'Answer',
        'citations': [],
        'retrieval': {'class_no': 8},
      });

      expect(response.citations, isEmpty);
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
  });
}
