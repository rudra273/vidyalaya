import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vidyalaya/data/services/backend_auth_service.dart';

void main() {
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
}
