import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/learn_assist.dart';

typedef FirebaseIdTokenProvider =
    Future<String?> Function({required bool forceRefresh});

class LearnAssistService {
  static final defaultBaseUrl = Uri.parse(
    'https://vidyalaya-ai-llf1.onrender.com',
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

  /// Same request as [chat], but the answer arrives as it's generated via
  /// Server-Sent Events. Yields [LearnAssistTokenEvent] frames as the answer is
  /// typed out, then exactly one [LearnAssistDoneEvent] with the citations/usage
  /// (only known once generation finishes). A generation failure surfaces as a
  /// [LearnAssistErrorEvent] frame rather than throwing, since the HTTP status is
  /// already 200 by the time streaming starts; a pre-flight failure (401/429/…)
  /// still throws [LearnAssistApiException], matching [chat].
  Stream<LearnAssistStreamEvent> chatStream(LearnAssistRequest request) {
    final uri = _baseUrl.resolve('/learnassist/chat/stream');
    return _streamChat(uri, request, forceRefresh: false);
  }

  Stream<LearnAssistStreamEvent> _streamChat(
    Uri uri,
    LearnAssistRequest request, {
    required bool forceRefresh,
  }) async* {
    final token = await _idTokenProvider(forceRefresh: forceRefresh);
    if (token == null || token.isEmpty) {
      throw const LearnAssistApiException(
        'unauthorized',
        'Please sign in to use Learn Assist.',
      );
    }

    final httpRequest = http.Request('POST', uri)
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
        'Authorization': 'Bearer $token',
      })
      ..body = jsonEncode(request.toJson());

    http.StreamedResponse response;
    try {
      response = await _client
          .send(httpRequest)
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
      await response.stream.drain<void>();
      yield* _streamChat(uri, request, forceRefresh: true);
      return;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = await response.stream.bytesToString();
      final decoded = _decodeJsonObject(body);
      final error = decoded['error'];
      if (error is Map<String, dynamic>) {
        throw LearnAssistApiException(
          error['code'] as String? ?? 'service_error',
          response.statusCode == 401
              ? 'Please sign in again.'
              : error['message'] as String? ?? 'Something went wrong.',
        );
      }
      throw LearnAssistApiException(
        'service_error',
        'The AI service returned status ${response.statusCode}.',
      );
    }

    // Idle-timeout the line stream (not just the initial response) so a
    // connection that stalls mid-turn doesn't hang the UI forever - the backend
    // has its own turn timeout that should always beat this, but a dropped
    // connection wouldn't otherwise surface at all.
    final lines = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .timeout(const Duration(seconds: 100));

    var eventName = 'message';
    final dataLines = <String>[];
    try {
      await for (final line in lines) {
        if (line.isEmpty) {
          if (dataLines.isNotEmpty) {
            final event = _parseSseEvent(eventName, dataLines.join('\n'));
            if (event != null) yield event;
          }
          eventName = 'message';
          dataLines.clear();
        } else if (line.startsWith(':')) {
          continue; // SSE comment / keep-alive ping
        } else if (line.startsWith('event:')) {
          eventName = line.substring('event:'.length).trim();
        } else if (line.startsWith('data:')) {
          dataLines.add(line.substring('data:'.length).trimLeft());
        }
      }
    } on TimeoutException {
      throw const LearnAssistApiException(
        'network_error',
        'The connection stalled. Please try again.',
      );
    } on http.ClientException {
      throw const LearnAssistApiException(
        'network_error',
        'Lost connection to the AI service. Please try again.',
      );
    }
    if (dataLines.isNotEmpty) {
      // Flush a trailing event with no terminating blank line.
      final event = _parseSseEvent(eventName, dataLines.join('\n'));
      if (event != null) yield event;
    }
  }

  /// Decodes one buffered SSE frame's `data:` payload into a typed event.
  /// Returns null for an unrecognized `event:` name or a malformed JSON body
  /// (the backend never emits either, but a dropped/garbled connection could).
  LearnAssistStreamEvent? _parseSseEvent(String name, String data) {
    final Object? decoded;
    try {
      decoded = jsonDecode(data);
    } on FormatException {
      return null;
    }
    if (decoded is! Map<String, dynamic>) return null;

    return switch (name) {
      'tool' => LearnAssistToolEvent(decoded['tool'] as String? ?? ''),
      'token' => LearnAssistTokenEvent(decoded['text'] as String? ?? ''),
      'done' => LearnAssistDoneEvent.fromJson(decoded),
      'error' => LearnAssistErrorEvent(
        decoded['code'] as String? ?? 'service_error',
        decoded['message'] as String? ?? 'Something went wrong.',
      ),
      _ => null,
    };
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
