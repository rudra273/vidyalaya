import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vidyalaya/data/models/learn_assist.dart';
import 'package:vidyalaya/data/models/plus.dart';
import 'package:vidyalaya/data/services/backend_auth_service.dart';

BackendAuthService _service(MockClient client) => BackendAuthService(
  client: client,
  idTokenProvider: ({required forceRefresh}) async => 'test-token',
  baseUrl: Uri.parse('https://example.test'),
);

http.Response _status(String state, {bool canRequest = false}) => http.Response(
  jsonEncode({
    'state': state,
    'plan_key': 'free',
    'available': true,
    'can_request': canRequest,
  }),
  200,
);

void main() {
  test('reads the Plus status with the student\'s token', () async {
    final service = _service(
      MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/me/plus');
        expect(request.headers['authorization'], 'Bearer test-token');
        return _status('pending');
      }),
    );

    final status = await service.plusStatus();

    expect(status.state, PlusState.pending);
  });

  test('a request sends the screen it came from and nothing else', () async {
    final service = _service(
      MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/me/plus/requests');
        expect(request.headers['authorization'], 'Bearer test-token');
        expect(jsonDecode(request.body), {'source': 'ai_questions'});
        return _status('pending');
      }),
    );

    final status = await service.requestPlus(PlusSource.aiQuestions);

    expect(status.state, PlusState.pending);
  });

  test('a refusal reaches the app with its code and a neutral message', () async {
    final service = _service(
      MockClient(
        (_) async => http.Response(
          jsonEncode({
            'error': {
              'code': 'plus_cooldown',
              'message': "Plus isn't available for your account right now.",
            },
          }),
          409,
        ),
      ),
    );

    await expectLater(
      service.requestPlus(PlusSource.profile),
      throwsA(
        isA<LearnAssistApiException>()
            .having((e) => e.code, 'code', 'plus_cooldown')
            .having((e) => e.message, 'message', contains("isn't available")),
      ),
    );
  });

  test('requests switched off on the server say so', () async {
    final service = _service(
      MockClient(
        (_) async => http.Response(
          jsonEncode({
            'error': {
              'code': 'plus_requests_closed',
              'message': 'Plus requests are not open right now.',
            },
          }),
          403,
        ),
      ),
    );

    await expectLater(
      service.requestPlus(PlusSource.profile),
      throwsA(
        isA<LearnAssistApiException>().having(
          (e) => e.code,
          'code',
          'plus_requests_closed',
        ),
      ),
    );
  });

  test('an old server without the endpoint is an error, not a crash', () async {
    final service = _service(
      MockClient((_) async => http.Response('{"error":{"code":"http_error","message":"Not Found"}}', 404)),
    );

    await expectLater(service.plusStatus(), throwsA(isA<LearnAssistApiException>()));
  });
}
