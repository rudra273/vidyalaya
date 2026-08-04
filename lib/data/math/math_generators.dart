import 'dart:math';

import 'math_models.dart';

// ─── Math question generators ─────────────────────────────────────────────────
//
// Pure Dart — no Flutter imports — so every generator is unit-testable and the
// screens stay dumb. Each function takes an optional [Random] so tests can seed
// it and reproduce a failure exactly.
//
// The load-bearing invariant, enforced by buildFlashChain: a chain never
// produces a fractional or negative intermediate value. We get that by building
// the chain *forward* and choosing each operand from the current running value,
// rather than picking operands blindly and hoping they divide.

/// Lower bound for a running total. Kept at 0 so young students never meet
/// negatives in a mental-math chain.
const _minRunning = 0;

/// Upper bound for a running total, so `×` can't explode into 6-digit numbers.
const _maxRunning = 999;

/// Builds a Flash Math round for [preset].
///
/// Guarantees, for every step: the operand is ≥ 1, and the running total stays a
/// whole number within `0..999`. When [withCheckpoints] is true the student is
/// also asked for the running total after every 3rd step (never the last one —
/// that's the round's final answer).
MathFlashChain buildFlashChain(
  MathFlashPreset preset, {
  bool withCheckpoints = false,
  Random? random,
}) {
  final rng = random ?? Random();
  final start = 2 + rng.nextInt(max(1, preset.maxStart - 1));

  var running = start;
  final steps = <MathFlashStep>[];

  for (var i = 0; i < preset.steps; i++) {
    final step = _nextStep(running, preset, rng);
    running = step.runningValue;
    steps.add(step);
  }

  final checkpoints = <int>[];
  if (withCheckpoints) {
    // Every 3rd step, excluding the final one.
    for (var i = 2; i < steps.length - 1; i += 3) {
      checkpoints.add(i);
    }
  }

  return MathFlashChain(
    start: start,
    steps: steps,
    checkpointIndices: checkpoints,
  );
}

/// Picks one legal step from [running]. Falls back to `+1` in the (rare) case
/// where no allowed operation has a legal operand, so the chain always reaches
/// its full length.
MathFlashStep _nextStep(int running, MathFlashPreset preset, Random rng) {
  // Try the allowed ops in random order and take the first that admits a legal
  // operand.
  final ops = [...preset.allowedOps]..shuffle(rng);

  for (final op in ops) {
    final operand = _operandFor(op, running, preset.maxOperand, rng);
    if (operand == null) continue;

    final result = op.apply(running, operand);
    if (result < _minRunning || result > _maxRunning) continue;

    return MathFlashStep(op: op, operand: operand, runningValue: result);
  }

  return MathFlashStep(
    op: MathOp.add,
    operand: 1,
    runningValue: running + 1,
  );
}

/// Chooses an operand for [op] applied to [running], or null when none is legal.
int? _operandFor(MathOp op, int running, int maxOperand, Random rng) {
  switch (op) {
    case MathOp.add:
      return 1 + rng.nextInt(maxOperand);

    case MathOp.sub:
      // Never go below zero: cap the operand at the running value.
      final cap = min(maxOperand, running);
      if (cap < 1) return null;
      return 1 + rng.nextInt(cap);

    case MathOp.mul:
      // Avoid ×1 (a no-op) where possible, and keep the product in range.
      if (running == 0) return 1 + rng.nextInt(maxOperand);
      final cap = min(maxOperand, _maxRunning ~/ max(1, running));
      if (cap < 2) return null;
      return 2 + rng.nextInt(cap - 1);

    case MathOp.div:
      // Only exact divisors, and never ÷1.
      final divisors = <int>[];
      for (var d = 2; d <= min(maxOperand, running); d++) {
        if (running % d == 0) divisors.add(d);
      }
      if (divisors.isEmpty) return null;
      return divisors[rng.nextInt(divisors.length)];
  }
}

// ─── Math Quiz ────────────────────────────────────────────────────────────────

/// Builds [count] multiple-choice questions scaled to [classLevel] (1–8).
///
/// Lower classes get addition/subtraction and small multiplication; higher
/// classes pick up division, fractions, percentages and simple algebra.
List<MathQuizQuestion> buildQuizQuestions({
  required int classLevel,
  int count = 10,
  Random? random,
}) {
  final rng = random ?? Random();
  final level = classLevel.clamp(1, 8);
  final builders = _quizBuildersFor(level);

  return List.generate(count, (i) {
    final builder = builders[rng.nextInt(builders.length)];
    return builder(level, rng);
  });
}

typedef _QuizBuilder = MathQuizQuestion Function(int level, Random rng);

/// Assembles a question, shuffling [options] and tracking where the correct
/// answer landed. Builders pass the correct answer as `options.first`; this is
/// the only place `correctIndex` is computed, so it can't drift out of sync.
MathQuizQuestion _mcq({
  required String prompt,
  required List<String> options,
  required String explanation,
  required Random rng,
}) {
  final correct = options.first;
  final shuffled = [...options]..shuffle(rng);
  return MathQuizQuestion(
    prompt: prompt,
    options: shuffled,
    correctIndex: shuffled.indexOf(correct),
    explanation: explanation,
  );
}

List<_QuizBuilder> _quizBuildersFor(int level) {
  final builders = <_QuizBuilder>[_addQuestion, _subQuestion];
  if (level >= 2) builders.add(_mulQuestion);
  if (level >= 3) builders.add(_divQuestion);
  if (level >= 4) builders.add(_missingNumberQuestion);
  if (level >= 5) builders.add(_fractionAddQuestion);
  if (level >= 6) builders.add(_percentQuestion);
  if (level >= 7) builders.add(_linearEquationQuestion);
  return builders;
}

int _scaleFor(int level) => switch (level) {
      1 => 10,
      2 => 20,
      3 => 50,
      4 => 100,
      5 => 200,
      6 => 500,
      _ => 1000,
    };

MathQuizQuestion _addQuestion(int level, Random rng) {
  final scale = _scaleFor(level);
  final a = 1 + rng.nextInt(scale);
  final b = 1 + rng.nextInt(scale);
  final answer = a + b;
  return _mcq(
    prompt: 'What is $a + $b?',
    options: _numericOptions(answer, rng, spread: max(4, scale ~/ 5)),
    explanation: '$a + $b = $answer.',
    rng: rng,
  );
}

MathQuizQuestion _subQuestion(int level, Random rng) {
  final scale = _scaleFor(level);
  final a = 2 + rng.nextInt(scale);
  final b = 1 + rng.nextInt(a); // keep it non-negative
  final answer = a - b;
  return _mcq(
    prompt: 'What is $a − $b?',
    options: _numericOptions(answer, rng, spread: max(4, scale ~/ 5)),
    explanation: '$a − $b = $answer.',
    rng: rng,
  );
}

MathQuizQuestion _mulQuestion(int level, Random rng) {
  final cap = level <= 3 ? 10 : (level <= 5 ? 12 : 20);
  final a = 2 + rng.nextInt(cap - 1);
  final b = 2 + rng.nextInt(cap - 1);
  final answer = a * b;
  return _mcq(
    prompt: 'What is $a × $b?',
    options: _numericOptions(answer, rng, spread: max(4, answer ~/ 4)),
    explanation: '$a × $b = $answer.',
    rng: rng,
  );
}

MathQuizQuestion _divQuestion(int level, Random rng) {
  final cap = level <= 4 ? 10 : 12;
  final b = 2 + rng.nextInt(cap - 1);
  final answer = 2 + rng.nextInt(cap - 1);
  final a = b * answer; // build backwards so it divides exactly
  return _mcq(
    prompt: 'What is $a ÷ $b?',
    options: _numericOptions(answer, rng, spread: max(3, answer)),
    explanation: '$a ÷ $b = $answer, because $b × $answer = $a.',
    rng: rng,
  );
}

MathQuizQuestion _missingNumberQuestion(int level, Random rng) {
  final scale = _scaleFor(level);
  final a = 2 + rng.nextInt(scale);
  final answer = 1 + rng.nextInt(scale);
  final total = a + answer;
  return _mcq(
    prompt: 'What number goes in the box?   $a + ▢ = $total',
    options: _numericOptions(answer, rng, spread: max(4, scale ~/ 5)),
    explanation: '$total − $a = $answer.',
    rng: rng,
  );
}

MathQuizQuestion _fractionAddQuestion(int level, Random rng) {
  // Same denominator keeps this fair for class 5–6.
  final d = 2 + rng.nextInt(8);
  final n1 = 1 + rng.nextInt(d - 1 == 0 ? 1 : d - 1);
  final n2 = 1 + rng.nextInt(d - 1 == 0 ? 1 : d - 1);
  final sum = Fraction(n1 + n2, d);
  final options = <String>{sum.display};
  var guard = 0;
  while (options.length < 4 && guard++ < 50) {
    final wrongN = 1 + rng.nextInt(d * 2);
    final wrongD = rng.nextBool() ? d : d + 1 + rng.nextInt(3);
    options.add(Fraction(wrongN, wrongD).display);
  }
  return _mcq(
    prompt: 'What is $n1/$d + $n2/$d?',
    options: options.toList(),
    explanation:
        'Add the numerators over the same denominator: ${n1 + n2}/$d = ${sum.display}.',
    rng: rng,
  );
}

MathQuizQuestion _percentQuestion(int level, Random rng) {
  const percents = [10, 20, 25, 50, 75];
  final pct = percents[rng.nextInt(percents.length)];
  // Pick a base the percentage divides cleanly.
  final base = (1 + rng.nextInt(20)) * 20;
  final answer = base * pct ~/ 100;
  return _mcq(
    prompt: 'What is $pct% of $base?',
    options: _numericOptions(answer, rng, spread: max(3, answer ~/ 2)),
    explanation: '$pct% of $base = $base × $pct ÷ 100 = $answer.',
    rng: rng,
  );
}

MathQuizQuestion _linearEquationQuestion(int level, Random rng) {
  final a = 2 + rng.nextInt(9);
  final answer = 1 + rng.nextInt(12);
  final b = 1 + rng.nextInt(20);
  final rhs = a * answer + b;
  return _mcq(
    prompt: 'Solve for x:   ${a}x + $b = $rhs',
    options: _numericOptions(answer, rng, spread: max(3, answer)),
    explanation:
        '${a}x = $rhs − $b = ${a * answer}, so x = ${a * answer} ÷ $a = $answer.',
    rng: rng,
  );
}

/// Builds 4 distinct numeric options with [answer] first. Distractors sit within
/// ±[spread] of the answer and are never negative.
List<String> _numericOptions(int answer, Random rng, {int spread = 5}) {
  final set = <int>{answer};
  var guard = 0;
  while (set.length < 4 && guard++ < 100) {
    final delta = 1 + rng.nextInt(max(1, spread));
    final candidate = rng.nextBool() ? answer + delta : answer - delta;
    if (candidate < 0) continue;
    set.add(candidate);
  }
  // Pad upward if the spread was too tight to find 4 distinct values.
  var pad = answer + 1;
  while (set.length < 4) {
    set.add(pad++);
  }
  return set.map((e) => e.toString()).toList();
}

// ─── Speed Drills ─────────────────────────────────────────────────────────────

/// Builds [count] single-operation facts for the 60-second sprint.
List<MathFact> buildDrillFacts({
  required List<MathOp> ops,
  int count = 60,
  int maxOperand = 12,
  Random? random,
}) {
  final rng = random ?? Random();
  final pool = ops.isEmpty ? MathOp.values : ops;

  return List.generate(count, (_) {
    final op = pool[rng.nextInt(pool.length)];
    return _buildFact(op, maxOperand, rng);
  });
}

MathFact _buildFact(MathOp op, int maxOperand, Random rng) {
  switch (op) {
    case MathOp.add:
      final a = 1 + rng.nextInt(maxOperand * 2);
      final b = 1 + rng.nextInt(maxOperand * 2);
      return MathFact(left: a, op: op, right: b, answer: a + b);

    case MathOp.sub:
      final a = 2 + rng.nextInt(maxOperand * 2);
      final b = 1 + rng.nextInt(a);
      return MathFact(left: a, op: op, right: b, answer: a - b);

    case MathOp.mul:
      final a = 2 + rng.nextInt(maxOperand - 1);
      final b = 2 + rng.nextInt(maxOperand - 1);
      return MathFact(left: a, op: op, right: b, answer: a * b);

    case MathOp.div:
      final b = 2 + rng.nextInt(maxOperand - 1);
      final answer = 1 + rng.nextInt(maxOperand);
      return MathFact(left: b * answer, op: op, right: b, answer: answer);
  }
}

/// Builds practice facts for a single multiplication [table] (e.g. all of 7×1…
/// 7×12), shuffled.
List<MathFact> buildTableQuestions(
  int table, {
  int upTo = 12,
  Random? random,
}) {
  final rng = random ?? Random();
  final facts = List.generate(
    upTo,
    (i) => MathFact(
      left: table,
      op: MathOp.mul,
      right: i + 1,
      answer: table * (i + 1),
    ),
  );
  facts.shuffle(rng);
  return facts;
}

// ─── Number Sense ─────────────────────────────────────────────────────────────

/// Builds [count] quick-judgement questions.
List<NumberSenseQuestion> buildNumberSenseRound({
  int count = 10,
  int classLevel = 4,
  Random? random,
}) {
  final rng = random ?? Random();
  final level = classLevel.clamp(1, 8);
  final kinds = <NumberSenseKind>[
    NumberSenseKind.larger,
    NumberSenseKind.smaller,
    NumberSenseKind.oddEven,
    if (level >= 3) NumberSenseKind.placeValue,
    if (level >= 4) NumberSenseKind.rounding,
    if (level >= 5) NumberSenseKind.prime,
  ];

  return List.generate(count, (_) {
    final kind = kinds[rng.nextInt(kinds.length)];
    return _buildNumberSense(kind, level, rng);
  });
}

NumberSenseQuestion _buildNumberSense(
    NumberSenseKind kind, int level, Random rng) {
  final scale = _scaleFor(level);

  switch (kind) {
    case NumberSenseKind.larger:
    case NumberSenseKind.smaller:
      final wantLarger = kind == NumberSenseKind.larger;
      final values = <int>{};
      while (values.length < 4) {
        values.add(1 + rng.nextInt(scale * 2));
      }
      final list = values.toList();
      final target = wantLarger
          ? list.reduce((a, b) => a > b ? a : b)
          : list.reduce((a, b) => a < b ? a : b);
      return NumberSenseQuestion(
        kind: kind,
        prompt: kind.label,
        options: list.map((e) => e.toString()).toList(),
        correctIndex: list.indexOf(target),
      );

    case NumberSenseKind.oddEven:
      final n = 1 + rng.nextInt(scale * 2);
      return NumberSenseQuestion(
        kind: kind,
        prompt: 'Is $n odd or even?',
        options: const ['Odd', 'Even'],
        correctIndex: n.isEven ? 1 : 0,
      );

    case NumberSenseKind.placeValue:
      // Always a 3-digit number so the place names are unambiguous.
      final n = 100 + rng.nextInt(900);
      const places = ['ones', 'tens', 'hundreds'];
      final placeIndex = rng.nextInt(3);
      final digit = (n ~/ pow(10, placeIndex).toInt()) % 10;
      final options = <String>{digit.toString()};
      var guard = 0;
      while (options.length < 4 && guard++ < 50) {
        options.add(rng.nextInt(10).toString());
      }
      return NumberSenseQuestion(
        kind: kind,
        prompt: 'In $n, what digit is in the ${places[placeIndex]} place?',
        options: options.toList(),
        correctIndex: options.toList().indexOf(digit.toString()),
      );

    case NumberSenseKind.rounding:
      final n = 11 + rng.nextInt(989);
      final to = rng.nextBool() ? 10 : 100;
      final answer = ((n / to).round()) * to;
      final options = <int>{answer};
      var guard = 0;
      while (options.length < 4 && guard++ < 50) {
        final candidate = answer + (rng.nextBool() ? to : -to) * (1 + rng.nextInt(2));
        if (candidate < 0) continue;
        options.add(candidate);
      }
      final list = options.toList();
      return NumberSenseQuestion(
        kind: kind,
        prompt: 'Round $n to the nearest $to.',
        options: list.map((e) => e.toString()).toList(),
        correctIndex: list.indexOf(answer),
      );

    case NumberSenseKind.prime:
      final n = 2 + rng.nextInt(58);
      return NumberSenseQuestion(
        kind: kind,
        prompt: 'Is $n a prime number?',
        options: const ['Prime', 'Not prime'],
        correctIndex: isPrime(n) ? 0 : 1,
      );
  }
}

/// Whether [n] is prime. Exposed because Fractions Lab and Number Sense both
/// want it, and it's worth testing directly.
bool isPrime(int n) {
  if (n < 2) return false;
  if (n < 4) return true;
  if (n.isEven) return false;
  for (var i = 3; i * i <= n; i += 2) {
    if (n % i == 0) return false;
  }
  return true;
}

// ─── Fractions Lab ────────────────────────────────────────────────────────────

/// The three exercise modes in Fractions Lab.
enum FractionTaskKind { compare, simplify, add }

/// One Fractions Lab task. [left]/[right] are the operands shown as bars; for
/// [FractionTaskKind.simplify] only [left] is used (deliberately unsimplified).
class FractionTask {
  final FractionTaskKind kind;
  final Fraction left;
  final Fraction? right;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const FractionTask({
    required this.kind,
    required this.left,
    this.right,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

/// Builds [count] fraction tasks, cycling through the three kinds.
List<FractionTask> buildFractionTasks({
  int count = 9,
  Random? random,
}) {
  final rng = random ?? Random();
  return List.generate(count, (i) {
    final kind = FractionTaskKind.values[i % FractionTaskKind.values.length];
    return switch (kind) {
      FractionTaskKind.compare => _compareTask(rng),
      FractionTaskKind.simplify => _simplifyTask(rng),
      FractionTaskKind.add => _addFractionTask(rng),
    };
  });
}

FractionTask _compareTask(Random rng) {
  Fraction a, b;
  var guard = 0;
  do {
    final d1 = 2 + rng.nextInt(9);
    final d2 = 2 + rng.nextInt(9);
    a = Fraction(1 + rng.nextInt(d1), d1);
    b = Fraction(1 + rng.nextInt(d2), d2);
  } while (a.value == b.value && guard++ < 50);

  final options = [a.display, b.display];
  final correct = a.value >= b.value ? 0 : 1;
  return FractionTask(
    kind: FractionTaskKind.compare,
    left: a,
    right: b,
    options: options,
    correctIndex: correct,
    explanation: a.value == b.value
        ? 'They are equal.'
        : '${options[correct]} is larger — compare ${a.value.toStringAsFixed(2)} and ${b.value.toStringAsFixed(2)}.',
  );
}

FractionTask _simplifyTask(Random rng) {
  // Build an unsimplified fraction by scaling a simple one up.
  final d = 2 + rng.nextInt(6);
  final n = 1 + rng.nextInt(d - 1 == 0 ? 1 : d - 1);
  final factor = 2 + rng.nextInt(4);
  final raw = Fraction.raw(n * factor, d * factor);
  final simple = Fraction(n, d);

  final options = <String>{simple.display};
  var guard = 0;
  while (options.length < 4 && guard++ < 50) {
    final wn = 1 + rng.nextInt(d * factor);
    final wd = 2 + rng.nextInt(d * factor);
    final candidate = Fraction(wn, wd);
    if (candidate == simple) continue;
    options.add(candidate.display);
  }
  final list = options.toList();
  return FractionTask(
    kind: FractionTaskKind.simplify,
    left: raw,
    options: list,
    correctIndex: list.indexOf(simple.display),
    explanation:
        'Divide top and bottom by $factor: ${raw.display} = ${simple.display}.',
  );
}

FractionTask _addFractionTask(Random rng) {
  final d = 2 + rng.nextInt(7);
  final n1 = 1 + rng.nextInt(d);
  final n2 = 1 + rng.nextInt(d);
  final a = Fraction.raw(n1, d);
  final b = Fraction.raw(n2, d);
  final sum = Fraction(n1 + n2, d);

  final options = <String>{sum.display};
  var guard = 0;
  while (options.length < 4 && guard++ < 50) {
    final wn = 1 + rng.nextInt((n1 + n2) * 2);
    final wd = rng.nextBool() ? d : 2 + rng.nextInt(d * 2);
    final candidate = Fraction(wn, wd);
    if (candidate == sum) continue;
    options.add(candidate.display);
  }
  final list = options.toList();
  return FractionTask(
    kind: FractionTaskKind.add,
    left: a,
    right: b,
    options: list,
    correctIndex: list.indexOf(sum.display),
    explanation:
        'Same denominator, so add the numerators: ${n1 + n2}/$d = ${sum.display}.',
  );
}
