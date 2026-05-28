import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/learn_assist.dart';
import 'learn_assist_service.dart';

class BackendUser {
  final String userId;
  final String? email;
  final String? name;

  const BackendUser({required this.userId, this.email, this.name});

  factory BackendUser.fromJson(Map<String, dynamic> json) {
    return BackendUser(
      userId: json['user_id'] as String? ?? '',
      email: json['email'] as String?,
      name: json['name'] as String?,
    );
  }
}

class BackendAuthService {
  final http.Client _client;
  final Uri _baseUrl;
  final FirebaseIdTokenProvider _idTokenProvider;

  BackendAuthService({
    required http.Client client,
    required FirebaseIdTokenProvider idTokenProvider,
    Uri? baseUrl,
  }) : _client = client,
       _idTokenProvider = idTokenProvider,
       _baseUrl = baseUrl ?? LearnAssistService.defaultBaseUrl;

  Future<BackendUser> me() async {
    final response = await _sendWithAuth(
      forceRefresh: false,
      requestBuilder: (token) {
        return _client
            .get(
              _baseUrl.resolve('/auth/me'),
              headers: {'Authorization': 'Bearer $token'},
            )
            .timeout(const Duration(seconds: 20));
      },
    );

    return BackendUser.fromJson(_decodeJsonObject(response.body));
  }

  Future<http.Response> _sendWithAuth({
    required bool forceRefresh,
    required Future<http.Response> Function(String token) requestBuilder,
  }) async {
    final token = await _idTokenProvider(forceRefresh: forceRefresh);
    if (token == null || token.isEmpty) {
      throw const LearnAssistApiException(
        'unauthorized',
        'Please sign in again.',
      );
    }

    http.Response response;
    try {
      response = await requestBuilder(token);
    } on TimeoutException {
      throw const LearnAssistApiException(
        'network_error',
        'The AI service took too long to respond. Please try again.',
      );
    } on http.ClientException {
      throw const LearnAssistApiException(
        'network_error',
        'Could not reach the AI service. Please check your connection.',
      );
    }

    if (response.statusCode == 401 && !forceRefresh) {
      return _sendWithAuth(forceRefresh: true, requestBuilder: requestBuilder);
    }

    final decoded = _decodeJsonObject(response.body);
    final error = decoded['error'];
    if (error is Map<String, dynamic>) {
      throw LearnAssistApiException(
        error['code'] as String? ?? 'service_error',
        response.statusCode == 401
            ? 'Please sign in again.'
            : error['message'] as String? ?? 'Something went wrong.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LearnAssistApiException(
        'service_error',
        'The AI service returned status ${response.statusCode}.',
      );
    }

    return response;
  }

  Map<String, dynamic> _decodeJsonObject(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
    } on FormatException {
      throw const LearnAssistApiException(
        'invalid_response',
        'The AI service returned an invalid response.',
      );
    }

    throw const LearnAssistApiException(
      'invalid_response',
      'The AI service returned an invalid response.',
    );
  }
}
