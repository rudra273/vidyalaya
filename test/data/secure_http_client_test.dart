import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vidyalaya/data/services/secure_http_client.dart';

void main() {
  test('rejects plaintext requests before sending a token', () async {
    var sent = false;
    final client = SecureHttpClient(MockClient((request) async {
      sent = true;
      return http.Response('ok', 200);
    }));
    await expectLater(
      client.get(Uri.parse('http://example.test/profile'),
          headers: {'Authorization': 'Bearer secret'}),
      throwsStateError,
    );
    expect(sent, isFalse);
    client.close();
  });

  test('does not follow redirects from HTTPS', () async {
    bool? followsRedirects;
    final client = SecureHttpClient(MockClient((request) async {
      followsRedirects = request.followRedirects;
      return http.Response('', 302, headers: {'location': 'http://example.test'});
    }));
    final response = await client.get(Uri.parse('https://example.test/profile'));
    expect(response.statusCode, 302);
    expect(followsRedirects, isFalse);
    client.close();
  });
}
