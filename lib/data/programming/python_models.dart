// ─── Python course models ─────────────────────────────────────────────────────
//
// Plain immutable const classes (no codegen), mirroring the diagrams data
// pattern. Content is authored as `const` data in python_*_data.dart files and
// aggregated in python_course_data.dart.
//
// v1 is English-only; title/subtitle are single strings. Adding optional
// `titleOr`/`titleHi` named params later stays const-compatible.

enum PythonLevel { beginner, intermediate, advanced }

extension PythonLevelLabel on PythonLevel {
  String get label => switch (this) {
        PythonLevel.beginner => 'Beginner',
        PythonLevel.intermediate => 'Intermediate',
        PythonLevel.advanced => 'Advanced',
      };

  String get tagline => switch (this) {
        PythonLevel.beginner => 'Say hello to Python',
        PythonLevel.intermediate => 'Decisions & loops',
        PythonLevel.advanced => 'Collections & functions',
      };
}

/// A chapter groups a few lessons and ends with a quiz.
class PythonChapter {
  final String id;
  final PythonLevel level;
  final String title;
  final String subtitle;
  final String emoji; // playful card badge
  final List<PythonLesson> lessons;
  final List<PyQuizQuestion> quiz;

  const PythonChapter({
    required this.id,
    required this.level,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.lessons,
    required this.quiz,
  });
}

/// A lesson is a short sequence of blocks the student pages through.
class PythonLesson {
  final String id;
  final String title;
  final List<LessonBlock> blocks;

  const PythonLesson({
    required this.id,
    required this.title,
    required this.blocks,
  });
}

// ── Lesson blocks ─────────────────────────────────────────────────────────────

sealed class LessonBlock {
  const LessonBlock();
}

/// Explanatory prose. `**bold**` spans are rendered by the UI.
class TextBlock extends LessonBlock {
  final String text;
  const TextBlock(this.text);
}

/// A runnable, read-only code sample with the output we expect it to produce.
/// `expectedOutput` is both shown to the student and checked by the content test.
class CodeBlock extends LessonBlock {
  final String code;
  final String expectedOutput;
  final List<String> presetInputs;

  const CodeBlock({
    required this.code,
    required this.expectedOutput,
    this.presetInputs = const [],
  });
}

/// An editable challenge: starter code the student tweaks. When
/// `expectedOutput` is set, the UI shows a "✓ Matched!" celebration.
class ChallengeBlock extends LessonBlock {
  final String prompt;
  final String starterCode;
  final String? expectedOutput;
  final String hint;
  final List<String> presetInputs;

  const ChallengeBlock({
    required this.prompt,
    required this.starterCode,
    this.expectedOutput,
    required this.hint,
    this.presetInputs = const [],
  });
}

// ── Quiz ──────────────────────────────────────────────────────────────────────

enum PyQuizType { mcq, predictOutput }

class PyQuizQuestion {
  final PyQuizType type;
  final String prompt;
  final String? code; // shown for predict-the-output questions
  final List<String> options; // exactly 4
  final int correctIndex;
  final String explanation;

  const PyQuizQuestion({
    required this.type,
    required this.prompt,
    this.code,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}
