import '../models/class_range.dart';
import '../models/localized_text.dart';

// ─── Subject quiz models ──────────────────────────────────────────────────────
//
// Hand-written multiple-choice banks for Science, Social Science and English,
// split into three class bands. Study content is trilingual (English, Odia,
// Hindi); subject and band names are app chrome and stay English.

enum QuizSubject {
  science('Science', 'Living things, matter, energy'),
  social('Social Science', 'History, geography, civics'),
  english('English', 'Grammar and vocabulary');

  final String label;
  final String blurb;
  const QuizSubject(this.label, this.blurb);
}

enum QuizBand {
  primary('Classes 3–5', ClassRange(3, 5)),
  middle('Classes 6–8', ClassRange(6, 8)),
  secondary('Classes 9–10', ClassRange(9, 10));

  final String label;
  final ClassRange range;
  const QuizBand(this.label, this.range);

  /// The band a student's classes point to — the highest selected class wins,
  /// and no selection (or Classes 1–2) falls back to the first band.
  static QuizBand forClasses(Iterable<int> classes) {
    if (classes.isEmpty) return primary;
    final top = classes.reduce((a, b) => a > b ? a : b);
    if (top >= 9) return secondary;
    if (top >= 6) return middle;
    return primary;
  }
}

/// `(english, odia, hindi)` — the compact form the banks are written in.
typedef Tri = (String, String, String);

LocalizedText _text(Tri t) => LocalizedText(en: t.$1, or: t.$2, hi: t.$3);

class QuizQuestion {
  final QuizSubject subject;
  final QuizBand band;
  final LocalizedText prompt;
  final List<LocalizedText> options;
  final int correctIndex;
  final LocalizedText explanation;

  const QuizQuestion({
    required this.subject,
    required this.band,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  /// Builds a question from `(en, or, hi)` records.
  factory QuizQuestion.tri(
    QuizSubject subject,
    QuizBand band,
    Tri prompt,
    List<Tri> options,
    int correctIndex,
    Tri explanation,
  ) => QuizQuestion(
    subject: subject,
    band: band,
    prompt: _text(prompt),
    options: options.map(_text).toList(),
    correctIndex: correctIndex,
    explanation: _text(explanation),
  );
}
