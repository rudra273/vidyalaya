import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/virtual_lab.dart';
import 'learn_assist_service.dart';

typedef LabTokenProvider =
    Future<String?> Function({required bool forceRefresh});

class LabService {
  final http.Client _client;
  final Uri _baseUrl;

  LabService({required http.Client client, Uri? baseUrl})
    : _client = client,
      _baseUrl = baseUrl ?? LearnAssistService.defaultBaseUrl;

  Future<void> submitAttempt(
    LabAttempt attempt, {
    required LabTokenProvider tokenProvider,
  }) async {
    Future<http.Response> send({required bool forceRefresh}) async {
      final token = await tokenProvider(forceRefresh: forceRefresh);
      if (token == null || token.isEmpty) {
        throw StateError('Please sign in again.');
      }
      return _client
          .post(
            _baseUrl.resolve('/labs/v1/attempts'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(attempt.toRequestJson()),
          )
          .timeout(const Duration(seconds: 20));
    }

    var response = await send(forceRefresh: false);
    if (response.statusCode == 401) response = await send(forceRefresh: true);
    if (response.statusCode != 200) {
      throw StateError(
        'Lab progress could not be saved (${response.statusCode}).',
      );
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['client_attempt_id'] != attempt.clientAttemptId) {
      throw const FormatException('Lab attempt ID mismatch.');
    }
  }
}
