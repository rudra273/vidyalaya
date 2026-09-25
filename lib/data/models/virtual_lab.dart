import 'dart:math';

import '../lab/lab_rules.dart';

// ─── Lab attempt ──────────────────────────────────────────────────────────────
//
// One prediction + observation, saved on the device. Attempts from older rules
// versions stay readable; `labVersion` says which rules produced them.

class LabAttempt {
  final String clientAttemptId;
  final String? clientSessionId;
  final String labId;
  final int labVersion;
  final String prediction;
  final Map<String, Object> controls;
  final Map<String, Object> observation;
  final bool correct;
  final DateTime createdAt;

  const LabAttempt({
    required this.clientAttemptId,
    this.clientSessionId,
    required this.labId,
    required this.labVersion,
    required this.prediction,
    required this.controls,
    required this.observation,
    required this.correct,
    required this.createdAt,
  });

  factory LabAttempt.create({
    required String labId,
    required String prediction,
    required Map<String, Object> controls,
    String? clientSessionId,
  }) {
    final result = evaluateLab(labId, controls);
    return LabAttempt(
      clientAttemptId: _uuidV4(),
      clientSessionId: clientSessionId,
      labId: labId,
      labVersion: kLabVersion,
      prediction: prediction,
      controls: controls,
      observation: result.values,
      correct: result.matches(prediction),
      createdAt: DateTime.now().toUtc(),
    );
  }

  Map<String, Object?> toJson() => {
    'client_attempt_id': clientAttemptId,
    if (clientSessionId != null) 'client_session_id': clientSessionId,
    'lab_id': labId,
    'lab_version': labVersion,
    'prediction': prediction,
    'controls': controls,
    'observation': observation,
    'correct': correct,
    'created_at': createdAt.toIso8601String(),
  };

  factory LabAttempt.fromJson(Map<String, dynamic> json) => LabAttempt(
    clientAttemptId: json['client_attempt_id'] as String,
    clientSessionId: json['client_session_id'] as String?,
    labId: json['lab_id'] as String,
    labVersion: json['lab_version'] as int,
    prediction: json['prediction'] as String,
    controls: Map<String, Object>.from(json['controls'] as Map),
    observation: Map<String, Object>.from(json['observation'] as Map),
    correct: json['correct'] as bool,
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}

String newLabSessionId() => _uuidV4();

String _uuidV4() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes
      .map((value) => value.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
