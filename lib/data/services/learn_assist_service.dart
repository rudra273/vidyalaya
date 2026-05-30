import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/learn_assist.dart';

typedef FirebaseIdTokenProvider =
    Future<String?> Function({required bool forceRefresh});

class LearnAssistService {
  static final defaultBaseUrl = Uri.parse(
    'https://vidyalaya-ai-production.up.railway.app',
  );

  final http.Client _client;
  final Uri _baseUrl;
  final FirebaseIdTokenProvider _idTokenProvider;

  LearnAssistService({
    required http.Client client,
    required FirebaseIdTokenProvider idTokenProvider,
    Uri? baseUrl,
  }) : _client = client,
       _idTokenProvider = idTokenProvider,
       _baseUrl = baseUrl ?? defaultBaseUrl;

  Future<LearnAssistResponse> chat(LearnAssistRequest request) async {
    final uri = _baseUrl.resolve('/learnassist/chat');

    final response = await _postChat(uri, request, forceRefresh: false);
    final decoded = _decodeJsonObject(response.body);
    return LearnAssistResponse.fromJson(decoded);
  }

  Future<http.Response> _postChat(
    Uri uri,
    LearnAssistRequest request, {
    required bool forceRefresh,
  }) async {
    final token = await _idTokenProvider(forceRefresh: forceRefresh);
    if (token == null || token.isEmpty) {
      throw const LearnAssistApiException(
        'unauthorized',
        'Please sign in to use Learn Assist.',
      );
    }

    http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 100));
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
      return _postChat(uri, request, forceRefresh: true);
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
