import 'package:flutter_test/flutter_test.dart';
import 'package:vidyalaya/data/quiz/quiz_bank.dart';
import 'package:vidyalaya/data/quiz/quiz_models.dart';

void main() {
  test('every subject and band has at least a round of questions', () {
    for (final s in QuizSubject.values) {
      for (final b in QuizBand.values) {
        expect(
          quizBank(s, b).length,
          greaterThanOrEqualTo(quizQuestionsPerRound),
          reason: '${s.name}/${b.name}',
        );
      }
    }
  });

  test('every question has a valid answer and all three languages', () {
    for (final q in allQuizQuestions) {
      final label = q.prompt.en;
      expect(q.options.length, 4, reason: label);
      expect(q.correctIndex, inInclusiveRange(0, q.options.length - 1));
      for (final t in [q.prompt, q.explanation, ...q.options]) {
        expect(t.en.trim(), isNotEmpty, reason: label);
        expect(t.or.trim(), isNotEmpty, reason: label);
        expect(t.hi.trim(), isNotEmpty, reason: label);
      }
      expect(
        q.options.map((o) => o.en).toSet().length,
        q.options.length,
        reason: 'duplicate options: $label',
      );
    }
  });

  test('rounds hold ten distinct questions', () {
    final round = buildQuizRound(QuizSubject.science, QuizBand.middle);
    expect(round, hasLength(quizQuestionsPerRound));
    expect(round.map((q) => q.prompt.en).toSet(), hasLength(round.length));
  });

  test('band follows the highest selected class', () {
    expect(QuizBand.forClasses({}), QuizBand.primary);
    expect(QuizBand.forClasses({2}), QuizBand.primary);
    expect(QuizBand.forClasses({4, 7}), QuizBand.middle);
    expect(QuizBand.forClasses({9}), QuizBand.secondary);
  });
}
