import 'dart:math';

import '../seed/vocabulary_data.dart';

// ─── Word Builder ─────────────────────────────────────────────────────────────
//
// Unscramble a vocabulary word from its meaning. Words come from the curated
// vocabulary list, so the clue can be shown in the student's regional language.
// Difficulty is word length.

enum WordLevel {
  easy(label: 'Easy', minLen: 4, maxLen: 5),
  medium(label: 'Medium', minLen: 6, maxLen: 7),
  hard(label: 'Hard', minLen: 8, maxLen: 10);

  final String label;
  final int minLen;
  final int maxLen;

  const WordLevel({
    required this.label,
    required this.minLen,
    required this.maxLen,
  });

  /// Pitch the default at the student's (lowest selected) class.
  static WordLevel forClass(int? classNo) {
    if (classNo == null) return WordLevel.medium;
    if (classNo <= 4) return WordLevel.easy;
    if (classNo <= 7) return WordLevel.medium;
    return WordLevel.hard;
  }
}

class WordPuzzle {
  final VocabularyWord entry;

  /// The answer in upper case, letters only.
  final String answer;

  /// The same letters in a shuffled order that never equals [answer].
  final List<String> letters;

  const WordPuzzle({
    required this.entry,
    required this.answer,
    required this.letters,
  });
}

final _lettersOnly = RegExp(r'^[A-Za-z]+$');

List<VocabularyWord> wordPool(WordLevel level) => [
  for (final w in vocabularyWords)
    if (_lettersOnly.hasMatch(w.word) &&
        w.word.length >= level.minLen &&
        w.word.length <= level.maxLen)
      w,
];

/// [count] distinct puzzles at [level].
List<WordPuzzle> buildWordPuzzles(
  WordLevel level, {
  int count = 10,
  Random? random,
}) {
  final rng = random ?? Random();
  final pool = wordPool(level)..shuffle(rng);
  return [for (final w in pool.take(count)) _scramble(w, rng)];
}

WordPuzzle _scramble(VocabularyWord w, Random rng) {
  final answer = w.word.toUpperCase();
  final letters = answer.split('');
  // Words like "EEEE" can't be scrambled; everything in the pool can, but cap
  // the attempts so a pathological word can never spin forever.
  for (var i = 0; i < 20; i++) {
    letters.shuffle(rng);
    if (letters.join() != answer) break;
  }
  return WordPuzzle(entry: w, answer: answer, letters: letters);
}
