import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vidyalaya/data/services/backend_auth_service.dart';
import 'package:vidyalaya/data/models/learn_assist.dart';

void main() {
  test('learning event keeps its ID across an auth refresh', () async {
    var requests = 0;
    final service = BackendAuthService(
      client: MockClient((request) async {
        requests++;
        expect(request.url.path, '/me/events');
        expect(
          jsonDecode(request.body)['event_id'],
          '00000000-0000-4000-8000-000000000001',
        );
        if (requests == 1) return http.Response('{}', 401);
        return http.Response(
          jsonEncode({
            'event_id': '00000000-0000-4000-8000-000000000001',
            'recorded': true,
          }),
          200,
        );
      }),
      idTokenProvider: ({required forceRefresh}) async =>
          forceRefresh ? 'fresh-token' : 'old-token',
      baseUrl: Uri.parse('https://example.test'),
    );

    await service.recordLearningEvent(
      eventId: '00000000-0000-4000-8000-000000000001',
      eventType: 'content_opened',
      feature: 'book',
      board: 'scert_odisha',
      classNo: 8,
    );
    expect(requests, 2);
  });

  test('loads account-owned Explore preferences', () async {
    final service = BackendAuthService(
      client: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/me/explore-preferences');
        expect(request.headers['authorization'], 'Bearer test-token');
        return http.Response(
          jsonEncode({
            'selection_mode': 'selected',
            'selected_classes': [7, 8, 9],
          }),
          200,
        );
      }),
      idTokenProvider: ({required forceRefresh}) async => 'test-token',
      baseUrl: Uri.parse('https://example.test'),
    );

    final result = await service.explorePreferences();

    expect(result.selectionMode, 'selected');
    expect(result.selectedClasses, [7, 8, 9]);
  });

  test('saves Explore preferences without changing the profile', () async {
    final service = BackendAuthService(
      client: MockClient((request) async {
        expect(request.method, 'PUT');
        expect(request.url.path, '/me/explore-preferences');
        expect(jsonDecode(request.body), {
          'selection_mode': 'selected',
          'selected_classes': [6, 8],
        });
        return http.Response(request.body, 200);
      }),
      idTokenProvider: ({required forceRefresh}) async => 'test-token',
      baseUrl: Uri.parse('https://example.test'),
    );

    final result = await service.updateExplorePreferences(
      const ExplorePreferences(
        selectionMode: 'selected',
        selectedClasses: [6, 8],
      ),
    );

    expect(result.selectionMode, 'selected');
    expect(result.selectedClasses, [6, 8]);
  });

  test('sends profile revision and reads the next revision', () async {
    final service = BackendAuthService(
      client: MockClient((request) async {
        expect(request.url.path, '/me/profile');
        expect(jsonDecode(request.body)['revision'], 4);
        return http.Response(
          jsonEncode({
            'board': 'scert_odisha',
            'class_no': 8,
            'preferred_language': 'en',
            'revision': 5,
            'onboarding_completed': true,
          }),
          200,
        );
      }),
      idTokenProvider: ({required forceRefresh}) async => 'test-token',
      baseUrl: Uri.parse('https://example.test'),
    );

    final saved = await service.updateProfile(
      const StudentProfile(
        board: 'scert_odisha',
        classNo: 8,
        preferredLanguage: 'en',
        revision: 4,
      ),
    );
    expect(saved.revision, 5);
  });

  test(
    'exposes a distinct profile conflict without changing local edits',
    () async {
      final service = BackendAuthService(
        client: MockClient(
          (request) async => http.Response(
            jsonEncode({
              'error': {
                'code': 'profile_conflict',
                'message': 'Profile changed on another device.',
              },
            }),
            409,
          ),
        ),
        idTokenProvider: ({required forceRefresh}) async => 'test-token',
        baseUrl: Uri.parse('https://example.test'),
      );

      expect(
        () => service.updateProfile(
          const StudentProfile(
            board: 'scert_odisha',
            classNo: 8,
            preferredLanguage: 'en',
            revision: 4,
          ),
        ),
        throwsA(
          isA<LearnAssistApiException>().having(
            (error) => error.code,
            'code',
            'profile_conflict',
          ),
        ),
      );
    },
  );
}
