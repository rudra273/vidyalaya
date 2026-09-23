import 'package:http/http.dart' as http;

/// Enforces HTTPS for outbound student requests, including requests with ID tokens.
/// Redirects are surfaced to callers instead of following them to a new URL.
class SecureHttpClient extends http.BaseClient {
  SecureHttpClient(this._inner);

  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (request.url.scheme != 'https') {
      throw StateError('Student network requests require HTTPS.');
    }
    request.followRedirects = false;
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}
