import '../../../providers/regional_language_provider.dart';

/// A single English vocabulary entry for the "Word of the day" section.
///
/// The meaning is given in English plus both regional languages so the card
/// can show the one matching the student's chosen language ([regionalMeaning]).
class VocabularyWord {
  final String word;
  final String pronunciation;
  final String partOfSpeech;
  final String meaningEn;
  final String meaningOr;
  final String meaningHi;
  final String sentence;

  const VocabularyWord({
    required this.word,
    required this.pronunciation,
    required this.partOfSpeech,
    required this.meaningEn,
    required this.meaningOr,
    required this.meaningHi,
    required this.sentence,
  });

  /// Meaning in the chosen regional language.
  String regionalMeaning(RegionalLanguage lang) =>
      lang == RegionalLanguage.hindi ? meaningHi : meaningOr;
}
