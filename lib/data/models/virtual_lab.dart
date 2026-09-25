import 'dart:math';

import 'localized_text.dart';
import 'regional_language.dart';

class LabObservation {
  final Map<String, Object> values;
  final bool correct;

  /// Why it happened, in English, Odia and Hindi.
  final LocalizedText explanation;

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
          ? const LocalizedText(
              en: 'The open switch breaks the circuit, so no current flows.',
              or: 'ଖୋଲା ସ୍ୱିଚ୍ ପରିପଥକୁ ଭାଙ୍ଗିଦିଏ, ତେଣୁ କୌଣସି ବିଦ୍ୟୁତ୍ ସ୍ରୋତ ପ୍ରବାହିତ ହୁଏ ନାହିଁ।',
              hi: 'खुला स्विच परिपथ को तोड़ देता है, इसलिए कोई धारा नहीं बहती।',
            )
          : const LocalizedText(
              en: 'In this simplified model, current is voltage divided by the selected total resistance. More cells raise voltage; more resistance lowers current.',
              or: 'ଏହି ସରଳ ମଡେଲରେ, ବିଦ୍ୟୁତ୍ ସ୍ରୋତ = ବିଭବାନ୍ତର ÷ ମୋଟ ପ୍ରତିରୋଧ। ଅଧିକ ସେଲ୍ ବିଭବାନ୍ତର ବଢ଼ାଏ; ଅଧିକ ପ୍ରତିରୋଧ ସ୍ରୋତ କମାଏ।',
              hi: 'इस सरल मॉडल में, धारा = विभवांतर ÷ कुल प्रतिरोध। अधिक सेल विभवांतर बढ़ाते हैं; अधिक प्रतिरोध धारा घटाता है।',
            ),
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
      explanation: LocalizedText(
        en: 'The $sample sample is $nature; universal indicator is $color at this approximate pH.',
        or: '${labWord(sample, RegionalLanguage.odia)} ନମୁନାଟି ${labWord(nature, RegionalLanguage.odia)}; ଏହି ଆନୁମାନିକ pH ରେ ସାର୍ବଜନୀନ ସୂଚକ ${labWord(color, RegionalLanguage.odia)} ହୁଏ।',
        hi: '${labWord(sample, RegionalLanguage.hindi)} नमूना ${labWord(nature, RegionalLanguage.hindi)} है; इस अनुमानित pH पर सार्वत्रिक सूचक ${labWord(color, RegionalLanguage.hindi)} होता है।',
      ),
    );
  }
  throw ArgumentError.value(labId, 'labId');
}

// ─── Display words ────────────────────────────────────────────────────────────
//
// Observation values and samples are saved (and sent to the backend) as English
// keys; these are only their on-screen words.

/// The display word for a lab key such as `bright`, `red`, `acidic` or
/// `lemon`. Unknown keys are returned unchanged.
String labWord(String key, RegionalLanguage lang) =>
    _labWords[key]?.of(lang) ?? key;

const _labWords = {
  'off': LocalizedText(en: 'Off', or: 'ବନ୍ଦ', hi: 'बंद'),
  'dim': LocalizedText(en: 'Dim', or: 'କ୍ଷୀଣ', hi: 'मंद'),
  'bright': LocalizedText(en: 'Bright', or: 'ଉଜ୍ଜ୍ୱଳ', hi: 'तेज़'),
  'red': LocalizedText(en: 'Red', or: 'ଲାଲ', hi: 'लाल'),
  'green': LocalizedText(en: 'Green', or: 'ସବୁଜ', hi: 'हरा'),
  'blue': LocalizedText(en: 'Blue', or: 'ନୀଳ', hi: 'नीला'),
  'acidic': LocalizedText(en: 'Acidic', or: 'ଅମ୍ଳୀୟ', hi: 'अम्लीय'),
  'neutral': LocalizedText(en: 'Neutral', or: 'ନିରପେକ୍ଷ', hi: 'उदासीन'),
  'basic': LocalizedText(en: 'Basic', or: 'କ୍ଷାରୀୟ', hi: 'क्षारीय'),
  'lemon': LocalizedText(en: 'Lemon juice', or: 'ଲେମ୍ବୁ ରସ', hi: 'नींबू का रस'),
  'water': LocalizedText(en: 'Water', or: 'ପାଣି', hi: 'पानी'),
  'soap': LocalizedText(
    en: 'Soap solution',
    or: 'ସାବୁନ ଦ୍ରବଣ',
    hi: 'साबुन का घोल',
  ),
};

/// What the student is asked to do in each lab.
const labInstructions = {
  'circuit': LocalizedText(
    en: 'Predict how a switch, cells, and total resistance affect a bulb in this simplified model.',
    or: 'ଏହି ସରଳ ମଡେଲରେ ସ୍ୱିଚ୍, ସେଲ୍ ଓ ମୋଟ ପ୍ରତିରୋଧ ବଲ୍ବକୁ କିପରି ପ୍ରଭାବିତ କରେ ଅନୁମାନ କର।',
    hi: 'इस सरल मॉडल में अनुमान लगाएँ कि स्विच, सेल और कुल प्रतिरोध बल्ब को कैसे प्रभावित करते हैं।',
  ),
  'indicator': LocalizedText(
    en: 'Predict the colour of universal indicator in each sample.',
    or: 'ପ୍ରତ୍ୟେକ ନମୁନାରେ ସାର୍ବଜନୀନ ସୂଚକର ରଙ୍ଗ ଅନୁମାନ କର।',
    hi: 'हर नमूने में सार्वत्रिक सूचक का रंग अनुमान लगाएँ।',
  ),
};

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
