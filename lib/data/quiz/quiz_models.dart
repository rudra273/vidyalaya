import '../models/class_range.dart';
import '../models/localized_text.dart';

// ─── Subject quiz models ──────────────────────────────────────────────────────
//
// Hand-written banks for Science, Social Science, English and Maths, split into
// four class bands. Study content is trilingual (English, Odia, Hindi);
// subject, band and topic names are app chrome and stay English.

enum QuizSubject {
  science('Science', 'Living things, matter, energy'),
  social('Social Science', 'History, geography, civics'),
  english('English', 'Grammar and vocabulary'),
  maths('Maths Concepts', 'Numbers, shapes, algebra');

  final String label;
  final String blurb;
  const QuizSubject(this.label, this.blurb);
}

enum QuizBand {
  early('Classes 1–2', ClassRange(1, 2)),
  primary('Classes 3–5', ClassRange(3, 5)),
  middle('Classes 6–8', ClassRange(6, 8)),
  secondary('Classes 9–10', ClassRange(9, 10));

  final String label;
  final ClassRange range;
  const QuizBand(this.label, this.range);

  /// The band a student's classes point to — the highest selected class wins.
  /// No selection falls back to Classes 3–5.
  static QuizBand forClasses(Iterable<int> classes) {
    if (classes.isEmpty) return primary;
    final top = classes.reduce((a, b) => a > b ? a : b);
    if (top >= 9) return secondary;
    if (top >= 6) return middle;
    if (top >= 3) return primary;
    return early;
  }
}

/// How a question is answered.
enum QuizKind {
  /// Pick one of four options.
  choice,

  /// Pick True or False.
  trueFalse,

  /// The prompt holds a `___` blank; pick the option that fills it.
  fillBlank,

  /// Pair each left item with its right item.
  match,
}

/// The blank marker in [QuizKind.fillBlank] prompts.
const quizBlank = '___';

/// `(english, odia, hindi)` — the compact form the banks are written in.
typedef Tri = (String, String, String);

LocalizedText _text(Tri t) => LocalizedText(en: t.$1, or: t.$2, hi: t.$3);

const _trueText = LocalizedText(en: 'True', or: 'ସତ୍ୟ', hi: 'सत्य');
const _falseText = LocalizedText(en: 'False', or: 'ମିଥ୍ୟା', hi: 'असत्य');

class QuizQuestion {
  final QuizSubject subject;
  final QuizBand band;

  /// Short English topic name, used by the topic filter.
  final String topic;
  final QuizKind kind;
  final LocalizedText prompt;

  /// Choices for [QuizKind.choice], [QuizKind.trueFalse] and
  /// [QuizKind.fillBlank]; empty for [QuizKind.match].
  final List<LocalizedText> options;
  final int correctIndex;

  /// Correct left → right pairs for [QuizKind.match]; empty otherwise.
  final List<(LocalizedText, LocalizedText)> pairs;
  final LocalizedText explanation;

  const QuizQuestion({
    required this.subject,
    required this.band,
    required this.topic,
    required this.kind,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.pairs = const [],
  });
}

// ─── Bank builder ─────────────────────────────────────────────────────────────

/// Builds questions for one subject + band, so bank files stay compact:
///
/// ```dart
/// const _k = QuizKit(QuizSubject.science, QuizBand.primary);
/// final _q = _k.choice, _tf = _k.trueFalse;
/// ```
class QuizKit {
  final QuizSubject subject;
  final QuizBand band;

  const QuizKit(this.subject, this.band);

  QuizQuestion choice(
    String topic,
    Tri prompt,
    List<Tri> options,
    int correctIndex,
    Tri explanation,
  ) => QuizQuestion(
    subject: subject,
    band: band,
    topic: topic,
    kind: QuizKind.choice,
    prompt: _text(prompt),
    options: options.map(_text).toList(),
    correctIndex: correctIndex,
    explanation: _text(explanation),
  );

  QuizQuestion trueFalse(
    String topic,
    Tri statement,
    bool isTrue,
    Tri explanation,
  ) => QuizQuestion(
    subject: subject,
    band: band,
    topic: topic,
    kind: QuizKind.trueFalse,
    prompt: _text(statement),
    options: const [_trueText, _falseText],
    correctIndex: isTrue ? 0 : 1,
    explanation: _text(explanation),
  );

  /// [sentence] must contain [quizBlank] in every language.
  QuizQuestion fillBlank(
    String topic,
    Tri sentence,
    List<Tri> options,
    int correctIndex,
    Tri explanation,
  ) => QuizQuestion(
    subject: subject,
    band: band,
    topic: topic,
    kind: QuizKind.fillBlank,
    prompt: _text(sentence),
    options: options.map(_text).toList(),
    correctIndex: correctIndex,
    explanation: _text(explanation),
  );

  QuizQuestion match(
    String topic,
    Tri instruction,
    List<(Tri, Tri)> pairs,
    Tri explanation,
  ) => QuizQuestion(
    subject: subject,
    band: band,
    topic: topic,
    kind: QuizKind.match,
    prompt: _text(instruction),
    options: const [],
    correctIndex: 0,
    pairs: [for (final (l, r) in pairs) (_text(l), _text(r))],
    explanation: _text(explanation),
  );
}
