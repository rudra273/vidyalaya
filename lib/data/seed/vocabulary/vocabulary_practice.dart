import 'dart:math';

import '../../../providers/regional_language_provider.dart';
import '../vocabulary_data.dart';
import 'vocabulary_sets.dart';

// ─── Vocabulary practice ──────────────────────────────────────────────────────
//
// Flashcards and a meaning quiz over either the A–Z dictionary (optionally one
// difficulty level) or one of the phrase sets. Both dictionary words and set
// entries are first turned into a [VocabItem] so the practice screens deal
// with one shape.

/// [VocabularyWord] or [VocabSetEntry], reduced to what practice needs.
class VocabItem {
  final String term;
  final String meaningEn;
  final String meaningOr;
  final String meaningHi;
  final String example;

  const VocabItem({
    required this.term,
    required this.meaningEn,
    required this.meaningOr,
    required this.meaningHi,
    required this.example,
  });

  factory VocabItem.fromWord(VocabularyWord w) => VocabItem(
    term: w.word,
    meaningEn: w.meaningEn,
    meaningOr: w.meaningOr,
    meaningHi: w.meaningHi,
    example: w.sentence,
  );

  factory VocabItem.fromEntry(VocabSetEntry e) => VocabItem(
    term: e.term,
    meaningEn: e.meaningEn,
    meaningOr: e.meaningOr,
    meaningHi: e.meaningHi,
    example: e.example,
  );

  String regionalMeaning(RegionalLanguage lang) => switch (lang) {
    RegionalLanguage.english => meaningEn,
    RegionalLanguage.odia => meaningOr,
    RegionalLanguage.hindi => meaningHi,
  };
}

/// Source name for the A–Z dictionary; any other source is a [VocabSet] id.
const kVocabWordsSource = 'words';

/// Items to practise. Returns an empty list for an unknown source.
List<VocabItem> vocabItemsFor(String source, {VocabularyLevel? level}) {
  if (source == kVocabWordsSource) {
    return [
      for (final w in vocabularyWords)
        if (level == null || w.level == level) VocabItem.fromWord(w),
    ];
  }
  final set = vocabSetById(source);
  if (set == null) return const [];
  return [for (final e in set.entries) VocabItem.fromEntry(e)];
}

/// A shuffled deck of up to [count] cards.
List<VocabItem> buildFlashcardDeck(
  List<VocabItem> items, {
  int count = 20,
  Random? random,
}) {
  final deck = [...items]..shuffle(random ?? Random());
  return deck.take(count).toList();
}

/// "What does [item] mean?" with four meanings, one correct.
class VocabQuizQuestion {
  final VocabItem item;
  final List<VocabItem> choices;
  final int correctIndex;

  const VocabQuizQuestion({
    required this.item,
    required this.choices,
    required this.correctIndex,
  });
}

/// Up to [count] questions. Distractors come from [items] itself, so a set quiz
/// compares idiom with idiom. Needs at least four items to build a question.
List<VocabQuizQuestion> buildVocabQuiz(
  List<VocabItem> items, {
  int count = 10,
  Random? random,
}) {
  if (items.length < 4) return const [];
  final rng = random ?? Random();
  final pool = [...items]..shuffle(rng);
  final questions = <VocabQuizQuestion>[];

  for (final item in pool.take(count)) {
    // Two terms can share a meaning text (rare); keep options distinguishable.
    final others = items
        .where((o) => o.term != item.term && o.meaningEn != item.meaningEn)
        .toList()
      ..shuffle(rng);
    if (others.length < 3) continue;
    final choices = [item, ...others.take(3)]..shuffle(rng);
    questions.add(
      VocabQuizQuestion(
        item: item,
        choices: choices,
        correctIndex: choices.indexOf(item),
      ),
    );
  }
  return questions;
}
