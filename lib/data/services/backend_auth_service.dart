import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/learn_assist.dart';
import 'learn_assist_service.dart';

class BackendUser {
  final String userId;
  final String? firebaseUid;
  final String? dbId;
  final String? email;
  final String? name;
  final String? role;
  final String? status;
  final String? planKey;
  final int? planDailyLimit;
  final String? planProvider;
  final String? planModel;

  const BackendUser({
    required this.userId,
    this.firebaseUid,
    this.dbId,
    this.email,
    this.name,
    this.role,
    this.status,
    this.planKey,
    this.planDailyLimit,
    this.planProvider,
    this.planModel,
  });

  factory BackendUser.fromJson(Map<String, dynamic> json) {
    return BackendUser(
      userId: json['user_id'] as String? ?? '',
      firebaseUid: json['firebase_uid'] as String?,
      dbId: json['db_id'] as String?,
      email: json['email'] as String?,
      name: json['name'] as String?,
      role: json['role'] as String?,
      status: json['status'] as String?,
      planKey: json['plan_key'] as String?,
      planDailyLimit: json['plan_daily_limit'] as int?,
      planProvider: json['plan_provider'] as String?,
      planModel: json['plan_model'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'firebase_uid': firebaseUid,
    'db_id': dbId,
    'email': email,
    'name': name,
    'role': role,
    'status': status,
    'plan_key': planKey,
    'plan_daily_limit': planDailyLimit,
    'plan_provider': planProvider,
    'plan_model': planModel,
  };
}

class StudentProfile {
  final String board;
  final int classNo;
  final String preferredLanguage;
  final String? schoolName;

  /// Student display name (custom if edited, else the Google account name).
  final String? name;
  final bool onboardingCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StudentProfile({
    required this.board,
    required this.classNo,
    required this.preferredLanguage,
    this.schoolName,
    this.name,
    this.onboardingCompleted = false,
    this.createdAt,
    this.updatedAt,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      board: json['board'] as String? ?? 'scert_odisha',
      classNo: json['class_no'] as int? ?? 8,
      preferredLanguage: json['preferred_language'] as String? ?? 'en',
      schoolName: json['school_name'] as String?,
      name: json['name'] as String?,
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    final trimmedSchoolName = schoolName?.trim();
    final trimmedName = name?.trim();
    return {
      'board': board,
      'class_no': classNo,
      'preferred_language': preferredLanguage,
      'school_name': trimmedSchoolName == null || trimmedSchoolName.isEmpty
          ? null
          : trimmedSchoolName,
      // Omitted (null) means "leave the stored name unchanged" server-side.
      'name': trimmedName == null || trimmedName.isEmpty ? null : trimmedName,
    };
  }

  Map<String, dynamic> toCacheJson() => {
    'board': board,
    'class_no': classNo,
    'preferred_language': preferredLanguage,
    'school_name': schoolName,
    'name': name,
    'onboarding_completed': onboardingCompleted,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}

class ProfileNotFoundException implements Exception {
  const ProfileNotFoundException();
}

class ChatHistoryPage {
  final List<ChatHistoryMessage> messages;
  final int? nextBefore;

  const ChatHistoryPage({required this.messages, this.nextBefore});

  factory ChatHistoryPage.fromJson(Map<String, dynamic> json) {
    return ChatHistoryPage(
      messages: _asMapList(
        json['messages'],
      ).map(ChatHistoryMessage.fromJson).toList(),
      nextBefore: json['next_before'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'messages': messages.map((message) => message.toJson()).toList(),
    'next_before': nextBefore,
  };
}

class ChatHistoryMessage {
  final int id;
  final String role;
  final String content;
  final List<LearnAssistCitation> citations;
  final DateTime? createdAt;

  const ChatHistoryMessage({
    required this.id,
    required this.role,
    required this.content,
    this.citations = const [],
    this.createdAt,
  });

  factory ChatHistoryMessage.fromJson(Map<String, dynamic> json) {
    return ChatHistoryMessage(
      id: json['id'] as int? ?? 0,
      role: json['role'] as String? ?? '',
      content: json['content'] as String? ?? '',
      citations: _asMapList(
        json['citations'],
      ).map(LearnAssistCitation.fromJson).toList(),
      createdAt: _parseDateTime(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role,
    'content': content,
    'citations': citations.map((citation) => citation.toJson()).toList(),
    'created_at': createdAt?.toIso8601String(),
  };
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

  Future<StudentProfile?> profile() async {
    try {
      final response = await _sendWithAuth(
        forceRefresh: false,
        requestBuilder: (token) {
          return _client
              .get(
                _baseUrl.resolve('/me/profile'),
                headers: {'Authorization': 'Bearer $token'},
              )
              .timeout(const Duration(seconds: 20));
        },
      );

      return StudentProfile.fromJson(_decodeJsonObject(response.body));
    } on ProfileNotFoundException {
      return null;
    }
  }

  Future<StudentProfile> updateProfile(StudentProfile profile) async {
    final response = await _sendWithAuth(
      forceRefresh: false,
      requestBuilder: (token) {
        return _client
            .put(
              _baseUrl.resolve('/me/profile'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode(profile.toJson()),
            )
            .timeout(const Duration(seconds: 20));
      },
    );

    return StudentProfile.fromJson(_decodeJsonObject(response.body));
  }

  Future<LearnAssistUsage> usage() async {
    final response = await _sendWithAuth(
      forceRefresh: false,
      requestBuilder: (token) {
        return _client
            .get(
              _baseUrl.resolve('/me/usage'),
              headers: {'Authorization': 'Bearer $token'},
            )
            .timeout(const Duration(seconds: 20));
      },
    );

    return LearnAssistUsage.fromJson(_decodeJsonObject(response.body));
  }

  /// Loads one conversation's history. The backend scopes history to the same
  /// (channel, board, class, subject) thread the chat used, so [board] and
  /// [classNo] are required and must match what chat sends. [subject] null = the
  /// cross-subject "general" conversation.
  Future<ChatHistoryPage> history({
    required String board,
    required int classNo,
    String channel = LearnAssistChannel.learnAssist,
    String? subject,
    int limit = 30,
    int? before,
  }) async {
    final queryParameters = <String, String>{
      'board': board,
      'class_no': '$classNo',
      'channel': channel,
      'limit': '$limit',
    };
    if (subject != null) queryParameters['subject'] = subject;
    if (before != null) queryParameters['before'] = '$before';

    final response = await _sendWithAuth(
      forceRefresh: false,
      requestBuilder: (token) {
        return _client
            .get(
              _baseUrl
                  .resolve('/me/history')
                  .replace(queryParameters: queryParameters),
              headers: {'Authorization': 'Bearer $token'},
            )
            .timeout(const Duration(seconds: 20));
      },
    );

    return ChatHistoryPage.fromJson(_decodeJsonObject(response.body));
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
      if (response.statusCode == 404 &&
          error['message'] == 'Profile not found.') {
        throw const ProfileNotFoundException();
      }
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

DateTime? _parseDateTime(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

List<Map<String, dynamic>> _asMapList(Object? value) {
  if (value is! List) return const [];
  return value.whereType<Map<String, dynamic>>().toList();
}
