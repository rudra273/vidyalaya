import 'dart:math';

import 'english/english_early.dart';
import 'english/english_middle.dart';
import 'english/english_middle_more.dart';
import 'english/english_primary.dart';
import 'english/english_primary_more.dart';
import 'english/english_secondary.dart';
import 'english/english_secondary_more.dart';
import 'maths/maths_early.dart';
import 'maths/maths_middle.dart';
import 'maths/maths_middle_more.dart';
import 'maths/maths_primary.dart';
import 'maths/maths_primary_more.dart';
import 'maths/maths_secondary.dart';
import 'maths/maths_secondary_more.dart';
import 'quiz_models.dart';
import 'science/science_early.dart';
import 'science/science_middle.dart';
import 'science/science_middle_more.dart';
import 'science/science_primary.dart';
import 'science/science_primary_more.dart';
import 'science/science_secondary.dart';
import 'science/science_secondary_more.dart';
import 'social/social_early.dart';
import 'social/social_middle.dart';
import 'social/social_middle_more.dart';
import 'social/social_primary.dart';
import 'social/social_primary_more.dart';
import 'social/social_secondary.dart';
import 'social/social_secondary_more.dart';

// ─── Quiz bank ────────────────────────────────────────────────────────────────

const quizQuestionsPerRound = 10;

final List<QuizQuestion> allQuizQuestions = [
  ...scienceEarly,
  ...sciencePrimary,
  ...sciencePrimaryMore,
  ...scienceMiddle,
  ...scienceMiddleMore,
  ...scienceSecondary,
  ...scienceSecondaryMore,
  ...socialEarly,
  ...socialPrimary,
  ...socialPrimaryMore,
  ...socialMiddle,
  ...socialMiddleMore,
  ...socialSecondary,
  ...socialSecondaryMore,
  ...englishEarly,
  ...englishPrimary,
  ...englishPrimaryMore,
  ...englishMiddle,
  ...englishMiddleMore,
  ...englishSecondary,
  ...englishSecondaryMore,
  ...mathsEarly,
  ...mathsPrimary,
  ...mathsPrimaryMore,
  ...mathsMiddle,
  ...mathsMiddleMore,
  ...mathsSecondary,
  ...mathsSecondaryMore,
];

/// Questions for [subject] + [band], narrowed to [topic] when given.
List<QuizQuestion> quizBank(
  QuizSubject subject,
  QuizBand band, {
  String? topic,
}) => allQuizQuestions
    .where(
      (q) =>
          q.subject == subject &&
          q.band == band &&
          (topic == null || q.topic == topic),
    )
    .toList();

/// Topics in [subject] + [band], in first-seen order.
List<String> quizTopics(QuizSubject subject, QuizBand band) => {
  for (final q in quizBank(subject, band)) q.topic,
}.toList();

/// A shuffled round of up to [count] questions, optionally from one [topic].
List<QuizQuestion> buildQuizRound(
  QuizSubject subject,
  QuizBand band, {
  String? topic,
  int count = quizQuestionsPerRound,
  Random? random,
}) {
  final bank = quizBank(subject, band, topic: topic)..shuffle(random);
  return bank.take(count).toList();
}

/// Key under which a subject/band best score is stored. Topic rounds are
/// practice and do not record a best score.
String quizToolId(QuizSubject subject, QuizBand band) =>
    'quiz-${subject.name}-${band.name}';
