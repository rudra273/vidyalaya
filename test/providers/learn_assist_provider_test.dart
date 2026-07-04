import 'package:flutter_test/flutter_test.dart';
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
  });

  test('learnAssistSubjectsForClass returns class-specific subjects', () {
    expect(learnAssistSubjectsForClass(8), containsAll(['english', 'science']));
    expect(learnAssistSubjectsForClass(8), isNot(contains('language')));
  });
}
