import 'dart:math';

import 'english/english_middle.dart';
import 'english/english_primary.dart';
import 'english/english_secondary.dart';
import 'quiz_models.dart';
import 'science/science_middle.dart';
import 'science/science_primary.dart';
import 'science/science_secondary.dart';
import 'social/social_middle.dart';
import 'social/social_primary.dart';
import 'social/social_secondary.dart';

// ─── Quiz bank ────────────────────────────────────────────────────────────────

const quizQuestionsPerRound = 10;

final List<QuizQuestion> allQuizQuestions = [
  ...sciencePrimary,
  ...scienceMiddle,
  ...scienceSecondary,
  ...socialPrimary,
  ...socialMiddle,
  ...socialSecondary,
  ...englishPrimary,
  ...englishMiddle,
  ...englishSecondary,
];

List<QuizQuestion> quizBank(QuizSubject subject, QuizBand band) =>
    allQuizQuestions
        .where((q) => q.subject == subject && q.band == band)
        .toList();

/// A shuffled round of up to [count] questions.
List<QuizQuestion> buildQuizRound(
  QuizSubject subject,
  QuizBand band, {
  int count = quizQuestionsPerRound,
  Random? random,
}) {
  final bank = quizBank(subject, band)..shuffle(random);
  return bank.take(count).toList();
}

/// Key under which a subject/band best score is stored.
String quizToolId(QuizSubject subject, QuizBand band) =>
    'quiz-${subject.name}-${band.name}';
