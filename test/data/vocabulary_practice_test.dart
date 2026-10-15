import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:vidyalaya/data/seed/vocabulary/vocabulary_practice.dart';
import 'package:vidyalaya/data/seed/vocabulary/vocabulary_sets.dart';
import 'package:vidyalaya/data/seed/vocabulary_data.dart';

void main() {
  group('dictionary', () {
    test('has the new adverbs, each with translated example sentences', () {
      final adverbs = vocabularyWords
          .where((w) => w.partOfSpeech == 'adverb')
          .toList();
      expect(adverbs.length, greaterThanOrEqualTo(100));
      final withTranslation = adverbs.where((w) => w.sentenceOr != null);
      expect(withTranslation.length, greaterThanOrEqualTo(100));
      for (final w in withTranslation) {
        expect(w.sentenceOr!.trim(), isNotEmpty, reason: w.word);
        expect(w.sentenceHi?.trim(), isNotEmpty, reason: w.word);
      }
    });

    test('words are unique (ignoring case)', () {
      final names = vocabularyWords.map((w) => w.word.toLowerCase()).toList();
      expect(names.toSet().length, names.length);
    });

    test('every word has a level, and the levels spread across the bands', () {
      final counts = {
        for (final l in VocabularyLevel.values)
          l: vocabularyWords.where((w) => w.level == l).length,
      };
      for (final entry in counts.entries) {
        expect(entry.value, greaterThan(50), reason: entry.key.label);
      }
    });

    test('related words never include the word itself', () {
      for (final w in vocabularyWords) {
        final related = [
          ...w.synonyms,
          ...w.antonyms,
        ].map((r) => r.toLowerCase());
        expect(related, isNot(contains(w.word.toLowerCase())), reason: w.word);
      }
    });
  });

  group('word sets', () {
    test('five sets with unique ids and enough entries', () {
      expect(vocabularySets.length, 5);
      expect(vocabularySets.map((s) => s.id).toSet().length, 5);
      for (final s in vocabularySets) {
        expect(s.entries.length, greaterThanOrEqualTo(25), reason: s.id);
      }
    });

    test('every entry is complete in all three languages', () {
      for (final s in vocabularySets) {
        for (final e in s.entries) {
          for (final t in [
            e.term,
            e.meaningEn,
            e.meaningOr,
            e.meaningHi,
            e.example,
          ]) {
            expect(t.trim(), isNotEmpty, reason: '${s.id}: ${e.term}');
          }
        }
      }
    });

    test('terms are unique within a set', () {
      for (final s in vocabularySets) {
        final terms = s.entries.map((e) => e.term.toLowerCase()).toList();
        expect(terms.toSet().length, terms.length, reason: s.id);
      }
    });
  });

  group('practice', () {
    test('sources resolve; unknown source is empty', () {
      expect(vocabItemsFor(kVocabWordsSource).length, vocabularyWords.length);
      expect(vocabItemsFor('idioms'), isNotEmpty);
      expect(vocabItemsFor('nope'), isEmpty);
    });

    test('level filter narrows the dictionary', () {
      final easy = vocabItemsFor(
        kVocabWordsSource,
        level: VocabularyLevel.easy,
      );
      expect(easy.length, lessThan(vocabularyWords.length));
      expect(easy, isNotEmpty);
    });

    test('flashcard deck is capped and has no repeats', () {
      final deck = buildFlashcardDeck(
        vocabItemsFor(kVocabWordsSource),
        random: Random(1),
      );
      expect(deck.length, 20);
      expect(deck.map((c) => c.term).toSet().length, 20);
    });

    test('quiz questions have four distinct choices including the answer', () {
      for (final source in [
        kVocabWordsSource,
        ...vocabularySets.map((s) => s.id),
      ]) {
        final quiz = buildVocabQuiz(vocabItemsFor(source), random: Random(3));
        expect(quiz.length, 10, reason: source);
        for (final q in quiz) {
          expect(q.choices.length, 4);
          expect(q.choices.map((c) => c.meaningEn).toSet().length, 4);
          expect(q.choices[q.correctIndex].term, q.item.term);
        }
      }
    });

    test('too few items builds no quiz', () {
      final few = vocabItemsFor('idioms').take(3).toList();
      expect(buildVocabQuiz(few), isEmpty);
    });
  });
}
