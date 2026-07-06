import 'package:flutter_test/flutter_test.dart';
import 'package:vidyalaya/data/models/ingested_books.dart';
import 'package:vidyalaya/providers/learn_assist_provider.dart';

void main() {
  group('detectLearnAssistLanguage', () {
    test('returns or for Odia text', () {
      expect(detectLearnAssistLanguage('କୋଷ କିଏ ଆବିଷ୍କାର କରିଥିଲେ?'), 'or');
    });

    test('returns en for English text', () {
      expect(detectLearnAssistLanguage('Who was Major Somnath Sharma?'), 'en');
    });

    test('returns hi for Hindi (Devanagari) text', () {
      expect(detectLearnAssistLanguage('कोशिका की खोज किसने की?'), 'hi');
    });

    test('prefers or when Odia and Devanagari are mixed', () {
      expect(detectLearnAssistLanguage('କୋଷ cell कोशिका'), 'or');
    });
  });

  group('resolveLearnAssistClass', () {
    test('uses class 8 when no classes are selected', () {
      expect(resolveLearnAssistClass({}), 8);
      expect(learnAssistClassOptions({}), [8]);
    });

    test('uses the selected class when one class is selected', () {
      expect(resolveLearnAssistClass({7}), 7);
      expect(learnAssistClassOptions({7}), [7]);
    });

    test('uses the lowest class as the default when multiple are selected', () {
      expect(resolveLearnAssistClass({8, 6, 7}), 6);
      expect(learnAssistClassOptions({8, 6, 7}), [6, 7, 8]);
    });

    test('ignores classes below the LearnAssist minimum', () {
      expect(resolveLearnAssistClass({3, 9}), 9);
      expect(learnAssistClassOptions({3, 9}), [9]);
      expect(resolveLearnAssistClass({2, 4}), 8);
      expect(learnAssistClassOptions({2, 4}), [8]);
    });
  });

  group('learnAssistSubjects', () {
    final ingestedBooks = IngestedBooks.fromJson({
      'boards': [
        {
          'board': 'scert_odisha',
          'classes': [
            {
              'class': 9,
              'subjects': [
                {'subject': 'math_algebra', 'book_name': 'Math_Algebra', 'language': 'or'},
                {'subject': 'english', 'book_name': 'English', 'language': 'en'},
              ],
            },
          ],
        },
      ],
    });

    test('returns sorted subjects for an ingested board and class', () {
      expect(
        learnAssistSubjects(ingestedBooks, 'scert_odisha', 9),
        ['english', 'math_algebra'],
      );
    });

    test('returns empty for classes or boards with nothing ingested', () {
      expect(learnAssistSubjects(ingestedBooks, 'scert_odisha', 6), isEmpty);
      expect(learnAssistSubjects(ingestedBooks, 'ncert', 9), isEmpty);
    });
  });
}
