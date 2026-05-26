import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/learn_assist.dart';

class LearnAssistService {
  static final defaultBaseUrl = Uri.parse(
    'https://vidyalaya-ai-production.up.railway.app',
  );

  final http.Client _client;
  final Uri _baseUrl;

  LearnAssistService({required http.Client client, Uri? baseUrl})
    : _client = client,
      _baseUrl = baseUrl ?? defaultBaseUrl;

  Future<LearnAssistResponse> chat(LearnAssistRequest request) async {
    final uri = _baseUrl.resolve('/learnassist/chat');

    http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));
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

    final decoded = _decodeJsonObject(response.body);
    final error = decoded['error'];
    if (error is Map<String, dynamic>) {
      throw LearnAssistApiException(
        error['code'] as String? ?? 'service_error',
        error['message'] as String? ?? 'Something went wrong.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LearnAssistApiException(
        'service_error',
        'The AI service returned status ${response.statusCode}.',
      );
    }

    return LearnAssistResponse.fromJson(decoded);
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
