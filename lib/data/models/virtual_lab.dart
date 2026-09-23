import 'dart:math';

class LabObservation {
  final Map<String, Object> values;
  final bool correct;
  final String explanation;

  const LabObservation({
    required this.values,
    required this.correct,
    required this.explanation,
  });
}

/// The same deterministic rules as the backend's version 1 lab evaluator.
LabObservation evaluateLab(
  String labId,
  Map<String, Object> controls,
  String prediction,
) {
  if (labId == 'circuit') {
    final cells = controls['cells'] as int;
    final resistance = controls['resistance_ohms'] as int;
    final closed = controls['closed'] as bool;
    final voltage = cells * 1.5;
    final current = closed ? (voltage / resistance * 100).round() / 100 : 0.0;
    final brightness = !closed
        ? 'off'
        : current >= 0.5
        ? 'bright'
        : 'dim';
    return LabObservation(
      values: {
        'voltage_v': voltage,
        'current_a': current,
        'brightness': brightness,
      },
      correct: prediction == brightness,
      explanation: !closed
          ? 'The open switch breaks the circuit, so no current flows.'
          : 'In this simplified model, current is voltage divided by the selected total resistance. More cells raise voltage; more resistance lowers current.',
    );
  }
  if (labId == 'indicator') {
    final sample = controls['sample'] as String;
    final (color, ph, nature) = switch (sample) {
      'lemon' => ('red', 2, 'acidic'),
      'water' => ('green', 7, 'neutral'),
      'soap' => ('blue', 10, 'basic'),
      _ => throw ArgumentError.value(sample, 'sample'),
    };
    return LabObservation(
      values: {'color': color, 'approx_ph': ph, 'nature': nature},
      correct: prediction == color,
      explanation:
          'The $sample sample is $nature; universal indicator is $color at this approximate pH.',
    );
  }
  throw ArgumentError.value(labId, 'labId');
}

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
    final result = evaluateLab(labId, controls, prediction);
    return LabAttempt(
      clientAttemptId: _uuidV4(),
      clientSessionId: clientSessionId,
      labId: labId,
      labVersion: 1,
      prediction: prediction,
      controls: controls,
      observation: result.values,
      correct: result.correct,
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
