// ─── Math tool models ─────────────────────────────────────────────────────────
//
// Plain immutable data for the Math hub and its practice tools. No codegen and
// no serialization — everything here is either static content or generated
// fresh each round (see math_generators.dart). Only *scores* persist, via
// UserPrefsRepository.
//
// Deliberately free of Flutter imports so the generators and their tests stay
// pure Dart. `MathTool` (which needs an IconData) lives in math_tools_data.dart.

// ─── Operations ───────────────────────────────────────────────────────────────

/// The four arithmetic operations, used by Flash Math and Speed Drills.
enum MathOp {
  add('+'),
  sub('−'),
  mul('×'),
  div('÷');

  const MathOp(this.symbol);

  /// Display glyph. Note these are the typographic minus/times/divide signs,
  /// not ASCII `-`, `*`, `/` — they read better at the large sizes Flash Math
  /// uses.
  final String symbol;

  /// Applies the operation. Division assumes [a] is divisible by [b]; the
  /// generators guarantee this, so callers never see a fractional result.
  int apply(int a, int b) => switch (this) {
        MathOp.add => a + b,
        MathOp.sub => a - b,
        MathOp.mul => a * b,
        MathOp.div => a ~/ b,
      };
}

// ─── Flash Math ───────────────────────────────────────────────────────────────

/// A difficulty preset for Flash Math.
class MathFlashPreset {
  final String id;
  final String label;
  final String blurb;

  /// Number of operation steps *after* the starting value.
  final int steps;
  final double secondsPerStep;
  final List<MathOp> allowedOps;

  /// Upper bound for a generated operand (not for the running total).
  final int maxOperand;

  /// Upper bound for the generated starting value.
  final int maxStart;

  const MathFlashPreset({
    required this.id,
    required this.label,
    required this.blurb,
    required this.steps,
    required this.secondsPerStep,
    required this.allowedOps,
    required this.maxOperand,
    required this.maxStart,
  });

  Duration get stepDuration =>
      Duration(milliseconds: (secondsPerStep * 1000).round());

  /// Used by the Custom setup sheet, which starts from a preset and overrides
  /// individual knobs. The label/blurb re-derive so the UI stays truthful.
  MathFlashPreset copyWith({
    String? id,
    String? label,
    int? steps,
    double? secondsPerStep,
    List<MathOp>? allowedOps,
    int? maxOperand,
    int? maxStart,
  }) {
    final nextSteps = steps ?? this.steps;
    final nextSeconds = secondsPerStep ?? this.secondsPerStep;
    final nextOps = allowedOps ?? this.allowedOps;
    return MathFlashPreset(
      id: id ?? this.id,
      label: label ?? this.label,
      blurb: describeFlashSettings(nextSteps, nextSeconds, nextOps),
      steps: nextSteps,
      secondsPerStep: nextSeconds,
      allowedOps: nextOps,
      maxOperand: maxOperand ?? this.maxOperand,
      maxStart: maxStart ?? this.maxStart,
    );
  }
}

/// The one place a settings summary line is composed, so presets and Custom
/// always read the same way.
String describeFlashSettings(int steps, double seconds, List<MathOp> ops) {
  final secondsText =
      seconds == seconds.roundToDouble() ? '${seconds.round()}' : '$seconds';
  final opText = ops.map((o) => o.symbol).join(' ');
  return '$steps steps · ${secondsText}s · $opText';
}

/// Bounds for the Custom sheet's sliders.
const flashMinSteps = 2;
const flashMaxSteps = 12;
const flashMinSeconds = 0.5;
const flashMaxSeconds = 5.0;

const mathFlashPresets = <MathFlashPreset>[
  MathFlashPreset(
    id: 'easy',
    label: 'Easy',
    blurb: '3 steps · 3s · + −',
    steps: 3,
    secondsPerStep: 3.0,
    allowedOps: [MathOp.add, MathOp.sub],
    maxOperand: 10,
    maxStart: 20,
  ),
  MathFlashPreset(
    id: 'medium',
    label: 'Medium',
    blurb: '5 steps · 2s · + − ×',
    steps: 5,
    secondsPerStep: 2.0,
    allowedOps: [MathOp.add, MathOp.sub, MathOp.mul],
    maxOperand: 12,
    maxStart: 20,
  ),
  MathFlashPreset(
    id: 'hard',
    label: 'Hard',
    blurb: '7 steps · 1s · + − × ÷',
    steps: 7,
    secondsPerStep: 1.0,
    allowedOps: [MathOp.add, MathOp.sub, MathOp.mul, MathOp.div],
    maxOperand: 12,
    maxStart: 50,
  ),
];

/// The id Custom rounds carry, kept distinct so their best score never mixes
/// with a fixed preset's.
const flashCustomId = 'custom';

MathFlashPreset mathFlashPresetById(String id) => mathFlashPresets.firstWhere(
      (p) => p.id == id,
      orElse: () => mathFlashPresets[1],
    );

/// One operation step in a Flash Math chain, plus the running total *after* it
/// is applied. Storing the running value makes checkpoint prompts and the
/// post-round recap trivial.
class MathFlashStep {
  final MathOp op;
  final int operand;
  final int runningValue;

  const MathFlashStep({
    required this.op,
    required this.operand,
    required this.runningValue,
  });

  String get display => '${op.symbol} $operand';
}

/// A generated Flash Math round.
class MathFlashChain {
  final int start;
  final List<MathFlashStep> steps;

  /// Indices into [steps] where the student is asked for the running total
  /// mid-chain. Empty when checkpoints are off. The final step is never a
  /// checkpoint — that prompt is the round's main answer.
  final List<int> checkpointIndices;

  const MathFlashChain({
    required this.start,
    required this.steps,
    this.checkpointIndices = const [],
  });

  /// The final answer.
  int get answer => steps.isEmpty ? start : steps.last.runningValue;

  /// Running total after [index] steps have been applied (0 → [start]).
  int valueAfter(int index) =>
      index <= 0 ? start : steps[index - 1].runningValue;

  bool isCheckpoint(int stepIndex) => checkpointIndices.contains(stepIndex);

  /// How many answers the student gives this round: each checkpoint plus the
  /// final one.
  int get promptCount => checkpointIndices.length + 1;
}

// ─── Quiz / drills ────────────────────────────────────────────────────────────

/// A multiple-choice question for the Math Quiz.
class MathQuizQuestion {
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const MathQuizQuestion({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  String get correctOption => options[correctIndex];
}

/// A single-operation fact for Speed Drills and table practice — typed answer,
/// no options.
class MathFact {
  final int left;
  final MathOp op;
  final int right;
  final int answer;

  const MathFact({
    required this.left,
    required this.op,
    required this.right,
    required this.answer,
  });

  String get prompt => '$left ${op.symbol} $right';
}

// ─── Number sense ─────────────────────────────────────────────────────────────

/// The kinds of quick-judgement rounds Number Sense asks.
enum NumberSenseKind {
  larger('Which is larger?'),
  smaller('Which is smaller?'),
  oddEven('Odd or even?'),
  placeValue('Place value'),
  rounding('Rounding'),
  prime('Prime or not?');

  const NumberSenseKind(this.label);
  final String label;
}

/// One Number Sense question. Reuses the MCQ shape but carries its kind so the
/// UI can label the round.
class NumberSenseQuestion {
  final NumberSenseKind kind;
  final String prompt;
  final List<String> options;
  final int correctIndex;

  const NumberSenseQuestion({
    required this.kind,
    required this.prompt,
    required this.options,
    required this.correctIndex,
  });
}

// ─── Fractions ────────────────────────────────────────────────────────────────

/// An immutable fraction with exact integer arithmetic, used by Fractions Lab.
/// Always stored in lowest terms with a positive denominator.
class Fraction {
  final int numerator;
  final int denominator;

  const Fraction._(this.numerator, this.denominator);

  factory Fraction(int numerator, int denominator) {
    if (denominator == 0) {
      throw ArgumentError('Fraction denominator cannot be zero');
    }
    // Keep the sign on the numerator so comparisons behave.
    final sign = denominator < 0 ? -1 : 1;
    final n = numerator * sign;
    final d = denominator * sign;
    final g = _gcd(n.abs(), d);
    if (g == 0) return const Fraction._(0, 1);
    return Fraction._(n ~/ g, d ~/ g);
  }

  /// Raw (unsimplified) fraction — used when the *point* of the exercise is to
  /// simplify it, so the UI must show 6/8 rather than 3/4.
  const Fraction.raw(this.numerator, this.denominator);

  static int _gcd(int a, int b) {
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  Fraction get simplified => Fraction(numerator, denominator);

  bool get isSimplified =>
      _gcd(numerator.abs(), denominator.abs()) == 1 && denominator > 0;

  double get value => numerator / denominator;

  Fraction operator +(Fraction other) => Fraction(
        numerator * other.denominator + other.numerator * denominator,
        denominator * other.denominator,
      );

  Fraction operator -(Fraction other) => Fraction(
        numerator * other.denominator - other.numerator * denominator,
        denominator * other.denominator,
      );

  String get display => '$numerator/$denominator';

  @override
  String toString() => display;

  @override
  bool operator ==(Object other) =>
      other is Fraction &&
      other.numerator == numerator &&
      other.denominator == denominator;

  @override
  int get hashCode => Object.hash(numerator, denominator);
}
