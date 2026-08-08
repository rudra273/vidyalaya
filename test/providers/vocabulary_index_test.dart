import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidyalaya/data/seed/vocabulary_data.dart';
import 'package:vidyalaya/providers/vocabulary_provider.dart';

/// Ranks the way the screen does, so the search contract is covered even
/// though the ordering itself is applied in the widget.
List<IndexedWord> search(VocabularyIndex index, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return index.words;

  final tiers = [<IndexedWord>[], <IndexedWord>[], <IndexedWord>[]];
  for (final w in index.words) {
    final rank = w.rank(q);
    if (rank != null) tiers[rank].add(w);
  }
  return [...tiers[0], ...tiers[1], ...tiers[2]];
}

void main() {
  late ProviderContainer container;
  late VocabularyIndex index;

  setUp(() {
    container = ProviderContainer();
    index = container.read(vocabularyIndexProvider);
  });

  tearDown(() => container.dispose());

  group('VocabularyIndex', () {
    test('keeps every seed word', () {
      expect(index.words.length, vocabularyWords.length);
      final bucketed =
          index.byLetter.values.fold<int>(0, (sum, l) => sum + l.length);
      expect(bucketed, vocabularyWords.length);
    });

    test('is sorted alphabetically', () {
      for (var i = 1; i < index.words.length; i++) {
        expect(
          index.words[i - 1].sortKey.compareTo(index.words[i].sortKey),
          lessThanOrEqualTo(0),
          reason: 'out of order at $i: '
              '${index.words[i - 1].word.word} then ${index.words[i].word.word}',
        );
      }
    });

    test('every word is bucketed under its own first letter', () {
      for (final entry in index.byLetter.entries) {
        for (final w in entry.value) {
          expect(w.word.word[0].toUpperCase(), entry.key);
        }
      }
    });

    test('letters are sorted and only include letters that have words', () {
      expect(index.letters, equals([...index.letters]..sort()));
      expect(index.letters.toSet(), index.byLetter.keys.toSet());
      for (final l in index.letters) {
        expect(index.byLetter[l], isNotEmpty);
      }
    });

    test('section offset estimates increase monotonically from zero', () {
      expect(index.sectionOffsetEstimate[index.letters.first], 0.0);
      for (var i = 1; i < index.letters.length; i++) {
        expect(
          index.sectionOffsetEstimate[index.letters[i]]!,
          greaterThan(index.sectionOffsetEstimate[index.letters[i - 1]]!),
        );
      }
    });

    test('is cached across reads rather than re-sorted', () {
      expect(identical(container.read(vocabularyIndexProvider), index), isTrue);
    });
  });

  group('search blob', () {
    test('is lowercase so queries never need case folding', () {
      for (final w in index.words) {
        expect(w.searchBlob, w.searchBlob.toLowerCase());
      }
    });

    test('matches the word itself, case-insensitively', () {
      final sample = index.words.first.word.word;
      expect(
        search(index, sample.toUpperCase()).map((w) => w.word.word),
        contains(sample),
      );
    });

    test('matches fields the old two-field search missed', () {
      // Regression guard: search used to cover only word + meaningEn.
      final target = index.words.firstWhere(
        (w) => w.word.sentence.trim().isNotEmpty,
      );
      final sentenceWord = target.word.sentence
          .split(RegExp(r'\s+'))
          .firstWhere((t) => t.length > 5, orElse: () => '');

      if (sentenceWord.isEmpty) return;
      final cleaned = sentenceWord.replaceAll(RegExp(r'[^A-Za-z]'), '');
      expect(
        search(index, cleaned).map((w) => w.word.word),
        contains(target.word.word),
        reason: 'example-sentence text should be searchable',
      );
    });

    test('matches the regional meaning', () {
      final target = index.words.firstWhere(
        (w) => w.word.meaningOr.trim().length > 3,
      );
      expect(
        search(index, target.word.meaningOr.trim()).map((w) => w.word.word),
        contains(target.word.word),
      );
    });

    test('an unmatched query returns nothing', () {
      expect(search(index, 'zzzqqqxxnotaword'), isEmpty);
    });
  });

  group('ranking', () {
    // The reported bug: typing a letter surfaced words with that letter buried
    // in a meaning, instead of words beginning with it.
    test('a single letter leads with words starting with it', () {
      for (final letter in ['t', 'a', 's']) {
        final results = search(index, letter);
        expect(results, isNotEmpty);
        expect(
          results.first.word.word.toLowerCase().startsWith(letter),
          isTrue,
          reason: '"$letter" led with ${results.first.word.word}',
        );

        // The whole leading run should start with that letter, not just one.
        final leading = results
            .takeWhile((w) => w.sortKey.startsWith(letter))
            .length;
        expect(
          leading,
          index.byLetter[letter.toUpperCase()]!.length,
          reason: 'every word starting with "$letter" should rank first',
        );
      }
    });

    test('prefix matches outrank matches inside the word', () {
      final results = search(index, 'ab');
      final firstInner = results.indexWhere((w) => !w.sortKey.startsWith('ab'));
      final lastPrefix = results.lastIndexWhere((w) => w.sortKey.startsWith('ab'));
      if (firstInner != -1) {
        expect(lastPrefix, lessThan(firstInner));
      }
    });

    test('word matches outrank meaning-only matches', () {
      final results = search(index, 'light');
      final wordMatches = results.where((w) => w.sortKey.contains('light'));
      final meaningOnly = results.where((w) => !w.sortKey.contains('light'));

      if (wordMatches.isNotEmpty && meaningOnly.isNotEmpty) {
        expect(
          results.indexOf(wordMatches.last),
          lessThan(results.indexOf(meaningOnly.first)),
        );
      }
    });

    test('alphabetical order is kept within a tier', () {
      final results = search(index, 't');
      final prefixTier =
          results.takeWhile((w) => w.sortKey.startsWith('t')).toList();
      for (var i = 1; i < prefixTier.length; i++) {
        expect(
          prefixTier[i - 1].sortKey.compareTo(prefixTier[i].sortKey),
          lessThanOrEqualTo(0),
        );
      }
    });

    test('meaning and sentence matches are still reachable', () {
      // Ranked lower, but not dropped.
      final target = index.words.firstWhere(
        (w) => w.word.meaningOr.trim().length > 3,
      );
      expect(
        search(index, target.word.meaningOr.trim()).map((w) => w.word.word),
        contains(target.word.word),
      );
    });
  });

  group('incremental narrowing', () {
    // The screen re-filters the previous results when a query is extended.
    // That is only sound if matches shrink monotonically as the query grows.
    test('extending a query yields a subset of the previous results', () {
      const queries = ['a', 'ab', 'aba', 'aban'];
      var previous = search(index, queries.first).toSet();

      for (final q in queries.skip(1)) {
        final current = search(index, q).toSet();
        expect(
          current.difference(previous),
          isEmpty,
          reason: '"$q" matched words that "${queries[queries.indexOf(q) - 1]}" '
              'did not — narrowing would drop them',
        );
        previous = current;
      }
    });

    test('narrowing from prior results equals a full rescan', () {
      final full = search(index, 'aban').map((w) => w.word.word).toList();
      final narrowed = [
        for (final w in search(index, 'ab'))
          if (w.searchBlob.contains('aban')) w.word.word,
      ];
      expect(narrowed, full);
    });
  });
}
