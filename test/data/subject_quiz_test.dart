import 'package:flutter_test/flutter_test.dart';
import 'package:vidyalaya/data/models/localized_text.dart';
import 'package:vidyalaya/data/quiz/quiz_bank.dart';
import 'package:vidyalaya/data/quiz/quiz_models.dart';

void _expectAllLanguages(LocalizedText t, String label) {
  expect(t.en.trim(), isNotEmpty, reason: label);
  expect(t.or.trim(), isNotEmpty, reason: label);
  expect(t.hi.trim(), isNotEmpty, reason: label);
}

void main() {
  test('every subject and band has a healthy bank', () {
    for (final s in QuizSubject.values) {
      for (final b in QuizBand.values) {
        final min = b == QuizBand.early ? 20 : 50;
        expect(
          quizBank(s, b).length,
          greaterThanOrEqualTo(min),
          reason: '${s.name}/${b.name}',
        );
      }
    }
  });

  test('every question is well-formed in all three languages', () {
    for (final q in allQuizQuestions) {
      final label = q.prompt.en;
      expect(q.topic.trim(), isNotEmpty, reason: label);
      _expectAllLanguages(q.prompt, label);
      _expectAllLanguages(q.explanation, label);

      switch (q.kind) {
        case QuizKind.choice:
        case QuizKind.fillBlank:
          expect(q.options.length, 4, reason: label);
        case QuizKind.trueFalse:
          expect(q.options.length, 2, reason: label);
        case QuizKind.match:
          expect(q.options, isEmpty, reason: label);
          expect(q.pairs.length, inInclusiveRange(3, 5), reason: label);
          for (final (l, r) in q.pairs) {
            _expectAllLanguages(l, label);
            _expectAllLanguages(r, label);
          }
          expect(
            q.pairs.map((p) => p.$2.en).toSet().length,
            q.pairs.length,
            reason: 'duplicate right items: $label',
          );
          continue;
      }

      expect(q.correctIndex, inInclusiveRange(0, q.options.length - 1));
      for (final o in q.options) {
        _expectAllLanguages(o, label);
      }
      expect(
        q.options.map((o) => o.en).toSet().length,
        q.options.length,
        reason: 'duplicate options: $label',
      );
      if (q.kind == QuizKind.fillBlank) {
        for (final t in [q.prompt.en, q.prompt.or, q.prompt.hi]) {
          expect(t, contains(quizBlank), reason: 'no blank: $label');
        }
      }
    }
  });

  test('no question repeats within a subject and band', () {
    // Generic prompts ("Choose the correct sentence.") repeat, so the prompt
    // and its options together identify a question.
    String key(QuizQuestion q) => [
      q.prompt.en,
      ...q.options.map((o) => o.en),
      ...q.pairs.map((p) => p.$1.en),
    ].join('|');
    for (final s in QuizSubject.values) {
      for (final b in QuizBand.values) {
        final prompts = quizBank(s, b).map(key).toList();
        final dupes = [
          for (final p in prompts.toSet())
            if (prompts.where((x) => x == p).length > 1) p,
        ];
        expect(dupes, isEmpty, reason: '${s.name}/${b.name}');
      }
    }
  });

  test('every band mixes several topics and question kinds', () {
    for (final s in QuizSubject.values) {
      for (final b in QuizBand.values) {
        final bank = quizBank(s, b);
        expect(
          quizTopics(s, b).length,
          greaterThanOrEqualTo(3),
          reason: '${s.name}/${b.name}',
        );
        expect(
          bank.map((q) => q.kind).toSet(),
          containsAll(QuizKind.values),
          reason: '${s.name}/${b.name}',
        );
      }
    }
  });

  test('rounds hold ten distinct questions', () {
    final round = buildQuizRound(QuizSubject.science, QuizBand.middle);
    expect(round, hasLength(quizQuestionsPerRound));
    expect(round.map((q) => q.prompt.en).toSet(), hasLength(round.length));
  });

  test('topic rounds only draw from that topic', () {
    final topic = quizTopics(QuizSubject.science, QuizBand.primary).first;
    final round = buildQuizRound(
      QuizSubject.science,
      QuizBand.primary,
      topic: topic,
    );
    expect(round, isNotEmpty);
    expect(round.every((q) => q.topic == topic), isTrue);
  });

  test('band follows the highest selected class', () {
    expect(QuizBand.forClasses({}), QuizBand.primary);
    expect(QuizBand.forClasses({1, 2}), QuizBand.early);
    expect(QuizBand.forClasses({2, 4}), QuizBand.primary);
    expect(QuizBand.forClasses({4, 7}), QuizBand.middle);
    expect(QuizBand.forClasses({9}), QuizBand.secondary);
  });
}
