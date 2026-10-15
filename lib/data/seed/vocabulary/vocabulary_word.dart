import '../../../providers/regional_language_provider.dart';

/// A single English vocabulary entry for the "Word of the day" section.
///
/// The meaning is given in English plus both regional languages so the card
/// can show the one matching the student's chosen language ([regionalMeaning]).
/// How hard a word is, shown as a chip on the card and used to pick words for
/// flashcards and quizzes.
enum VocabularyLevel {
  easy('Easy', 'Classes 1–5'),
  medium('Medium', 'Classes 6–8'),
  hard('Hard', 'Classes 9–10');

  const VocabularyLevel(this.label, this.classes);
  final String label;
  final String classes;
}

class VocabularyWord {
  final String word;
  final String pronunciation;
  final String partOfSpeech;
  final String meaningEn;
  final String meaningOr;
  final String meaningHi;
  final String sentence;

  /// Optional Odia / Hindi translations of [sentence].
  final String? sentenceOr;
  final String? sentenceHi;

  /// Optional related words, shown on the card when present.
  final List<String> synonyms;
  final List<String> antonyms;

  /// Set when a word's difficulty is not well predicted by its length.
  final VocabularyLevel? levelOverride;

  const VocabularyWord({
    required this.word,
    required this.pronunciation,
    required this.partOfSpeech,
    required this.meaningEn,
    required this.meaningOr,
    required this.meaningHi,
    required this.sentence,
    this.sentenceOr,
    this.sentenceHi,
    this.synonyms = const [],
    this.antonyms = const [],
    this.levelOverride,
  });

  /// Difficulty band. Taken from [levelOverride] when set; otherwise estimated
  /// from the word's length, the same way Word Builder picks its levels.
  VocabularyLevel get level =>
      levelOverride ??
      (word.length <= 5
          ? VocabularyLevel.easy
          : word.length <= 7
          ? VocabularyLevel.medium
          : VocabularyLevel.hard);

  /// The example sentence in the chosen language, or `null` when there is no
  /// translation (or the language is English).
  String? regionalSentence(RegionalLanguage lang) => switch (lang) {
    RegionalLanguage.english => null,
    RegionalLanguage.odia => sentenceOr,
    RegionalLanguage.hindi => sentenceHi,
  };

  /// Meaning in the chosen app language.
  String regionalMeaning(RegionalLanguage lang) => switch (lang) {
    RegionalLanguage.english => meaningEn,
    RegionalLanguage.odia => meaningOr,
    RegionalLanguage.hindi => meaningHi,
  };
}
