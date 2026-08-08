import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/seed/vocabulary_data.dart';

/// A [VocabularyWord] with its sort and search keys precomputed.
///
/// The screen sorts by word and filters by substring on every keystroke. Doing
/// the `toLowerCase()` inline meant re-folding the same strings thousands of
/// times per session, so both keys are derived once here instead.
class IndexedWord {
  final VocabularyWord word;

  /// Lowercased word, used as the sort key (decorate-sort-undecorate).
  final String sortKey;

  /// Every field lowercased and joined, so a query is one allocation-free
  /// `contains` per word rather than one per field.
  final String searchBlob;

  const IndexedWord({
    required this.word,
    required this.sortKey,
    required this.searchBlob,
  });

  /// How well this word matches [query], lower being better. Returns null when
  /// it doesn't match at all.
  ///
  /// Typing "t" should surface words that *start* with T, not every word with a
  /// T buried in its meaning — so a prefix beats a match inside the word, which
  /// in turn beats a match in a meaning or example sentence.
  int? rank(String query) {
    if (sortKey.startsWith(query)) return 0;
    if (sortKey.contains(query)) return 1;
    if (searchBlob.contains(query)) return 2;
    return null;
  }
}

/// The full word list, alphabetised and bucketed by first letter.
///
/// Built once per app run (see [vocabularyIndexProvider]) — the screen used to
/// redo the 929-word sort on every mount, which showed as a hitch on the first
/// frame each time Vocabulary was opened.
class VocabularyIndex {
  /// All words, sorted alphabetically.
  final List<IndexedWord> words;

  /// Words grouped under their uppercase first letter.
  final Map<String, List<IndexedWord>> byLetter;

  /// Letters that actually have words, in alphabetical order. The seed data
  /// has no X, so this is not simply A-Z.
  final List<String> letters;

  /// Approximate scroll offset of each letter's section, used for the coarse
  /// first hop of a jump before the exact offset can be measured.
  final Map<String, double> sectionOffsetEstimate;

  const VocabularyIndex({
    required this.words,
    required this.byLetter,
    required this.letters,
    required this.sectionOffsetEstimate,
  });

  bool hasLetter(String letter) => byLetter.containsKey(letter);
}

// ─── Offset estimation ───

/// Mean height of a word card plus the gap below it. Cards vary with how the
/// meanings wrap, so this only has to be close enough to land the target
/// section inside the viewport's cache extent — the jump then measures the
/// real offset and corrects.
const _kMeanCardExtent = 190.0 + 12.0;

/// Height of a sticky letter header, kept in sync with the screen's
/// `_LetterHeaderDelegate`.
const _kLetterHeaderExtent = 40.0;

/// Sorted, bucketed vocabulary. Intentionally not `autoDispose`: surviving
/// navigation is the whole point, so reopening the screen is free.
final vocabularyIndexProvider = Provider<VocabularyIndex>((ref) {
  final indexed = [
    for (final w in vocabularyWords)
      IndexedWord(
        word: w,
        sortKey: w.word.toLowerCase(),
        searchBlob: [
          w.word,
          w.pronunciation,
          w.partOfSpeech,
          w.meaningEn,
          w.meaningOr,
          w.meaningHi,
          w.sentence,
        ].join(' ').toLowerCase(),
      ),
  ]..sort((a, b) => a.sortKey.compareTo(b.sortKey));

  final byLetter = <String, List<IndexedWord>>{};
  for (final w in indexed) {
    byLetter.putIfAbsent(w.sortKey[0].toUpperCase(), () => []).add(w);
  }

  final letters = byLetter.keys.toList()..sort();

  // Prefix sum over the sections above each letter.
  final estimates = <String, double>{};
  var running = 0.0;
  for (final letter in letters) {
    estimates[letter] = running;
    running += _kLetterHeaderExtent + byLetter[letter]!.length * _kMeanCardExtent;
  }

  return VocabularyIndex(
    words: indexed,
    byLetter: byLetter,
    letters: letters,
    sectionOffsetEstimate: estimates,
  );
});
