import 'dart:math';

import '../models/localized_text.dart';

// ─── Practice rounds: Clock & Money, Word Problems ────────────────────────────
//
// Generated multiple-choice questions for the two practice tools that are not
// number drills. Questions are trilingual; numbers stay Western digits. The
// Hindi templates avoid gendered verbs (using "ने" constructions and
// masculine-plural item words) so one sentence fits every name.

/// One practice question. [clock] is set when the prompt shows an analog clock.
class MathPracticeQuestion {
  /// Short English chip label (app chrome), e.g. "Read the clock".
  final String label;
  final LocalizedText prompt;
  final List<String> options;
  final int correctIndex;

  /// Working shown after answering.
  final LocalizedText explanation;

  /// Hour (1–12) and minute (0–59) to draw, or `null` for no clock.
  final ({int hour, int minute})? clock;

  const MathPracticeQuestion({
    required this.label,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.clock,
  });
}

// ─── Option helpers ───────────────────────────────────────────────────────────

/// Four distinct options containing [correct], shuffled. Distractors sit within
/// [spread] of the answer and never go below [min].
({List<String> options, int correctIndex}) _numberOptions(
  int correct,
  Random rng, {
  int spread = 10,
  int min = 0,
  String prefix = '',
}) {
  final values = <int>{correct};
  var guard = 0;
  while (values.length < 4 && guard++ < 200) {
    final v = correct + rng.nextInt(spread * 2 + 1) - spread;
    if (v >= min) values.add(v);
  }
  // Tiny ranges can run out of room; widen deterministically.
  for (var v = correct + 1; values.length < 4; v++) {
    values.add(v);
  }
  final list = values.toList()..shuffle(rng);
  return (
    options: [for (final v in list) '$prefix$v'],
    correctIndex: list.indexOf(correct),
  );
}

String _clockText(int hour, int minute) =>
    '$hour:${minute.toString().padLeft(2, '0')}';

/// Minutes since 12:00 → "h:mm" on a 12-hour dial.
String _timeFromMinutes(int total) {
  final m = ((total % 720) + 720) % 720;
  final h = m ~/ 60 == 0 ? 12 : m ~/ 60;
  return _clockText(h, m % 60);
}

T _pick<T>(List<T> items, Random rng) => items[rng.nextInt(items.length)];

// ─── Clock & Money ────────────────────────────────────────────────────────────

enum _ClockMoneyKind { readClock, timeLater, change, coins, notes }

/// A round of clock-reading and rupee questions. Classes 1–2 only get
/// o'clock / half-past times and small sums; later classes get quarter hours,
/// five-minute steps and bigger amounts.
List<MathPracticeQuestion> buildClockMoneyRound({
  int count = 10,
  int classLevel = 2,
  Random? random,
}) {
  final rng = random ?? Random();
  final level = classLevel.clamp(1, 5);
  return List.generate(count, (i) {
    // Alternate clock and money so a round is always a mix.
    final kind = i.isEven
        ? (level >= 3 && rng.nextBool()
              ? _ClockMoneyKind.timeLater
              : _ClockMoneyKind.readClock)
        : _pick([
            _ClockMoneyKind.change,
            _ClockMoneyKind.coins,
            _ClockMoneyKind.notes,
          ], rng);
    return _buildClockMoney(kind, level, rng);
  });
}

MathPracticeQuestion _buildClockMoney(
  _ClockMoneyKind kind,
  int level,
  Random rng,
) {
  switch (kind) {
    case _ClockMoneyKind.readClock:
      final hour = 1 + rng.nextInt(12);
      final minute = switch (level) {
        <= 1 => _pick([0, 30], rng),
        2 => _pick([0, 15, 30, 45], rng),
        _ => 5 * rng.nextInt(12),
      };
      final answer = _clockText(hour, minute);
      final options = <String>{answer};
      while (options.length < 4) {
        final h = 1 + rng.nextInt(12);
        final m = level <= 1
            ? _pick([0, 30], rng)
            : level == 2
            ? _pick([0, 15, 30, 45], rng)
            : 5 * rng.nextInt(12);
        options.add(_clockText(h, m));
      }
      final list = options.toList()..shuffle(rng);
      return MathPracticeQuestion(
        label: 'Read the clock',
        prompt: const LocalizedText(
          en: 'What time does the clock show?',
          or: 'ଘଣ୍ଟାରେ କେତେ ବାଜିଛି?',
          hi: 'घड़ी में कितने बजे हैं?',
        ),
        options: list,
        correctIndex: list.indexOf(answer),
        clock: (hour: hour, minute: minute),
        explanation: LocalizedText(
          en: 'The short hand points to $hour and the long hand to ${minute ~/ 5 == 0 ? 12 : minute ~/ 5}, so it is $answer.',
          or: 'ଛୋଟ କଣ୍ଟା $hour ଆଡ଼କୁ ଓ ବଡ଼ କଣ୍ଟା ${minute ~/ 5 == 0 ? 12 : minute ~/ 5} ଆଡ଼କୁ, ତେଣୁ $answer ବାଜିଛି।',
          hi: 'छोटी सुई $hour पर और बड़ी सुई ${minute ~/ 5 == 0 ? 12 : minute ~/ 5} पर है, इसलिए $answer बजे हैं।',
        ),
      );

    case _ClockMoneyKind.timeLater:
      final start = (1 + rng.nextInt(12)) * 60 + 5 * rng.nextInt(12);
      final add = _pick([15, 20, 30, 40, 45, 50, 75, 90], rng);
      final answer = _timeFromMinutes(start + add);
      final options = <String>{answer};
      for (final d in [-30, -15, 15, 30, 60, -60, 10, -10]) {
        if (options.length == 4) break;
        options.add(_timeFromMinutes(start + add + d));
      }
      final list = options.toList()..shuffle(rng);
      final from = _timeFromMinutes(start);
      return MathPracticeQuestion(
        label: 'Time later',
        prompt: LocalizedText(
          en: 'It is $from now. What time will it be after $add minutes?',
          or: 'ଏବେ $from ବାଜିଛି। $add ମିନିଟ୍ ପରେ କେତେ ବାଜିବ?',
          hi: 'अभी $from बजे हैं। $add मिनट बाद कितने बजेंगे?',
        ),
        options: list,
        correctIndex: list.indexOf(answer),
        explanation: LocalizedText.same('$from + $add min = $answer'),
      );

    case _ClockMoneyKind.change:
      final scale = level <= 2 ? 1 : (level == 3 ? 2 : 5);
      final price = (5 + rng.nextInt(18)) * scale;
      final pay = [10, 20, 50, 100, 200, 500].firstWhere((n) => n > price);
      final change = pay - price;
      final o = _numberOptions(change, rng, spread: 10, min: 1, prefix: '₹');
      return MathPracticeQuestion(
        label: 'Change',
        prompt: LocalizedText(
          en: 'A toy costs ₹$price. You pay ₹$pay. How much change do you get back?',
          or: 'ଗୋଟିଏ ଖେଳନାର ଦାମ ₹$price। ତୁମେ ₹$pay ଦେଲ। କେତେ ଟଙ୍କା ଫେରିବ?',
          hi: 'एक खिलौने का दाम ₹$price है। तुमने ₹$pay दिए। कितने रुपये वापस मिलेंगे?',
        ),
        options: o.options,
        correctIndex: o.correctIndex,
        explanation: LocalizedText.same('₹$pay − ₹$price = ₹$change'),
      );

    case _ClockMoneyKind.coins:
      final coin = _pick(level <= 1 ? [1, 2, 5] : [2, 5, 10], rng);
      final n = 2 + rng.nextInt(level <= 2 ? 7 : 12);
      final total = coin * n;
      final o = _numberOptions(n, rng, spread: 4, min: 1);
      return MathPracticeQuestion(
        label: 'Coins',
        prompt: LocalizedText(
          en: 'How many ₹$coin coins make ₹$total?',
          or: '₹$total ହେବା ପାଇଁ ₹$coin ର କେତୋଟି ମୁଦ୍ରା ଦରକାର?',
          hi: '₹$total बनाने के लिए ₹$coin के कितने सिक्के चाहिए?',
        ),
        options: o.options,
        correctIndex: o.correctIndex,
        explanation: LocalizedText.same('₹$total ÷ ₹$coin = $n'),
      );

    case _ClockMoneyKind.notes:
      final note = _pick(level <= 2 ? [10, 20, 50] : [20, 50, 100, 500], rng);
      final n = 2 + rng.nextInt(level <= 2 ? 5 : 8);
      final total = note * n;
      final o = _numberOptions(
        total,
        rng,
        spread: note * 2,
        min: note,
        prefix: '₹',
      );
      return MathPracticeQuestion(
        label: 'Notes',
        prompt: LocalizedText(
          en: 'You have $n notes of ₹$note. How much money is that in all?',
          or: 'ତୁମ ପାଖରେ ₹$note ର $nଟି ନୋଟ ଅଛି। ମୋଟ କେତେ ଟଙ୍କା?',
          hi: 'तुम्हारे पास ₹$note के $n नोट हैं। कुल कितने रुपये हैं?',
        ),
        options: o.options,
        correctIndex: o.correctIndex,
        explanation: LocalizedText.same('$n × ₹$note = ₹$total'),
      );
  }
}

// ─── Word problems ────────────────────────────────────────────────────────────

const _names = [
  LocalizedText(en: 'Ravi', or: 'ରବି', hi: 'रवि'),
  LocalizedText(en: 'Sita', or: 'ସୀତା', hi: 'सीता'),
  LocalizedText(en: 'Mohan', or: 'ମୋହନ', hi: 'मोहन'),
  LocalizedText(en: 'Priya', or: 'ପ୍ରିୟା', hi: 'प्रिया'),
  LocalizedText(en: 'Biswa', or: 'ବିଶ୍ୱ', hi: 'विश्व'),
  LocalizedText(en: 'Lipsa', or: 'ଲିପ୍ସା', hi: 'लिप्सा'),
];

// Hindi words are masculine plural so past-tense verbs agree for any name.
const _items = [
  LocalizedText(en: 'mangoes', or: 'ଆମ୍ବ', hi: 'आम'),
  LocalizedText(en: 'laddus', or: 'ଲଡ୍ଡୁ', hi: 'लड्डू'),
  LocalizedText(en: 'marbles', or: 'ଗୋଲି', hi: 'कंचे'),
  LocalizedText(en: 'bananas', or: 'କଦଳୀ', hi: 'केले'),
  LocalizedText(en: 'pens', or: 'କଲମ', hi: 'पेन'),
];

enum _WordKind { add, subtract, multiply, divide, twoStep }

/// A round of word problems. Classes 1–2 get add/subtract with small numbers;
/// multiplication and division unlock at class 3, two-step shop problems at 4.
List<MathPracticeQuestion> buildWordProblemRound({
  int count = 10,
  int classLevel = 3,
  Random? random,
}) {
  final rng = random ?? Random();
  final level = classLevel.clamp(1, 8);
  final kinds = [
    _WordKind.add,
    _WordKind.subtract,
    if (level >= 3) _WordKind.multiply,
    if (level >= 3) _WordKind.divide,
    if (level >= 4) _WordKind.twoStep,
  ];
  return List.generate(count, (_) {
    return _buildWord(_pick(kinds, rng), level, rng);
  });
}

MathPracticeQuestion _buildWord(_WordKind kind, int level, Random rng) {
  final name = _pick(_names, rng);
  final item = _pick(_items, rng);
  final big = level <= 2 ? 20 : (level <= 4 ? 90 : 900);

  switch (kind) {
    case _WordKind.add:
      final a = 2 + rng.nextInt(big), b = 2 + rng.nextInt(big);
      final o = _numberOptions(a + b, rng, spread: 10, min: 1);
      return MathPracticeQuestion(
        label: 'Addition story',
        prompt: LocalizedText(
          en: '${name.en} has $a ${item.en}. A friend gives $b more. How many ${item.en} does ${name.en} have now?',
          or: '${name.or}ଙ୍କ ପାଖରେ $aଟି ${item.or} ଅଛି। ଜଣେ ସାଙ୍ଗ ଆହୁରି $bଟି ଦେଲା। ଏବେ ମୋଟ କେତୋଟି ${item.or}?',
          hi: '${name.hi} के पास $a ${item.hi} हैं। एक दोस्त ने $b और दिए। अब कुल कितने ${item.hi} हैं?',
        ),
        options: o.options,
        correctIndex: o.correctIndex,
        explanation: LocalizedText.same('$a + $b = ${a + b}'),
      );

    case _WordKind.subtract:
      final a = 10 + rng.nextInt(big), b = 1 + rng.nextInt(a - 1);
      final o = _numberOptions(a - b, rng, spread: 10, min: 0);
      return MathPracticeQuestion(
        label: 'Subtraction story',
        prompt: LocalizedText(
          en: '${name.en} had $a ${item.en} and gave $b to a friend. How many are left?',
          or: '${name.or}ଙ୍କ ପାଖରେ $aଟି ${item.or} ଥିଲା, ସେ $bଟି ସାଙ୍ଗକୁ ଦେଲେ। କେତୋଟି ବଳିଲା?',
          hi: '${name.hi} के पास $a ${item.hi} थे। उसने $b दोस्त को दे दिए। कितने बचे?',
        ),
        options: o.options,
        correctIndex: o.correctIndex,
        explanation: LocalizedText.same('$a − $b = ${a - b}'),
      );

    case _WordKind.multiply:
      final a = 2 + rng.nextInt(level <= 4 ? 9 : 20);
      final b = 2 + rng.nextInt(level <= 4 ? 8 : 15);
      final o = _numberOptions(a * b, rng, spread: max(6, a), min: 1);
      return MathPracticeQuestion(
        label: 'Multiplication story',
        prompt: LocalizedText(
          en: 'One box holds $a ${item.en}. How many ${item.en} are in $b boxes?',
          or: 'ଗୋଟିଏ ବାକ୍ସରେ $aଟି ${item.or} ଅଛି। $bଟି ବାକ୍ସରେ ମୋଟ କେତୋଟି ${item.or}?',
          hi: 'एक डिब्बे में $a ${item.hi} हैं। $b डिब्बों में कुल कितने ${item.hi} होंगे?',
        ),
        options: o.options,
        correctIndex: o.correctIndex,
        explanation: LocalizedText.same('$a × $b = ${a * b}'),
      );

    case _WordKind.divide:
      final share = 2 + rng.nextInt(level <= 4 ? 8 : 14);
      final each = 2 + rng.nextInt(level <= 4 ? 9 : 18);
      final total = share * each;
      final o = _numberOptions(each, rng, spread: 4, min: 1);
      return MathPracticeQuestion(
        label: 'Division story',
        prompt: LocalizedText(
          en: '$total ${item.en} are shared equally among $share children. How many does each child get?',
          or: '$totalଟି ${item.or}କୁ $share ଜଣ ପିଲାଙ୍କ ମଧ୍ୟରେ ସମାନ ଭାବେ ବାଣ୍ଟି ଦିଆଗଲା। ପ୍ରତ୍ୟେକ ପିଲା କେତୋଟି ପାଇବ?',
          hi: '$total ${item.hi} को $share बच्चों में बराबर बाँटा गया। हर बच्चे को कितने मिले?',
        ),
        options: o.options,
        correctIndex: o.correctIndex,
        explanation: LocalizedText.same('$total ÷ $share = $each'),
      );

    case _WordKind.twoStep:
      final price = 3 + rng.nextInt(level <= 5 ? 12 : 40);
      final qty = 2 + rng.nextInt(7);
      final cost = price * qty;
      final pay = ((cost ~/ 50) + 1) * 50;
      final change = pay - cost;
      final o = _numberOptions(change, rng, spread: 12, min: 1, prefix: '₹');
      return MathPracticeQuestion(
        label: 'Shop problem',
        prompt: LocalizedText(
          en: 'A pen costs ₹$price. ${name.en} buys $qty pens and pays ₹$pay. How much change does ${name.en} get?',
          or: 'ଗୋଟିଏ କଲମର ଦାମ ₹$price। ${name.or} $qtyଟି କଲମ କିଣି ₹$pay ଦେଲେ। କେତେ ଟଙ୍କା ଫେରସ୍ତ ମିଳିବ?',
          hi: 'एक पेन का दाम ₹$price है। ${name.hi} ने $qty पेन ख़रीदे और ₹$pay दिए। कितने रुपये वापस मिलेंगे?',
        ),
        options: o.options,
        correctIndex: o.correctIndex,
        explanation: LocalizedText.same(
          '$qty × ₹$price = ₹$cost,  ₹$pay − ₹$cost = ₹$change',
        ),
      );
  }
}
