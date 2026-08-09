// ─── Daily warm-up questions ──────────────────────────────────────────────
// One multiple-choice question surfaced on Home each day. Static seed data, in
// the same spirit as the book catalogue: no backend, works offline, and stable
// for the whole day so the card never reshuffles between rebuilds.

class WarmupQuestion {
  final String id;

  /// Subject key from `kSubjects` — drives the card's accent hue and icon.
  final String subject;
  final String question;
  final List<String> options;

  /// Index into [options] of the correct answer.
  final int answerIndex;

  /// Inclusive class range this question suits.
  final int minClass;
  final int maxClass;

  /// One short line shown once the student has answered.
  final String explanation;

  const WarmupQuestion({
    required this.id,
    required this.subject,
    required this.question,
    required this.options,
    required this.answerIndex,
    required this.minClass,
    required this.maxClass,
    required this.explanation,
  });

  String get answer => options[answerIndex];
}

const List<WarmupQuestion> kWarmupQuestions = [
  // ── Science ─────────────────────────────────────────────────────────────
  WarmupQuestion(
    id: 'sci_leaf_food',
    subject: 'science',
    question: 'Which part of a plant makes its food?',
    options: ['Root', 'Leaf', 'Stem', 'Flower'],
    answerIndex: 1,
    minClass: 1,
    maxClass: 5,
    explanation: 'Leaves make food from sunlight — that is photosynthesis.',
  ),
  WarmupQuestion(
    id: 'sci_insect_legs',
    subject: 'science',
    question: 'How many legs does an insect have?',
    options: ['Four', 'Six', 'Eight', 'Ten'],
    answerIndex: 1,
    minClass: 1,
    maxClass: 5,
    explanation: 'All insects have six legs. Spiders have eight — they are not insects.',
  ),
  WarmupQuestion(
    id: 'sci_largest_planet',
    subject: 'science',
    question: 'Which is the largest planet in our solar system?',
    options: ['Earth', 'Jupiter', 'Saturn', 'Mars'],
    answerIndex: 1,
    minClass: 3,
    maxClass: 8,
    explanation: 'Jupiter is so large that every other planet would fit inside it.',
  ),
  WarmupQuestion(
    id: 'sci_photosynthesis_gas',
    subject: 'science',
    question: 'Which gas do plants take in during photosynthesis?',
    options: ['Oxygen', 'Carbon dioxide', 'Nitrogen', 'Hydrogen'],
    answerIndex: 1,
    minClass: 6,
    maxClass: 8,
    explanation: 'Plants take in carbon dioxide and give out oxygen.',
  ),
  WarmupQuestion(
    id: 'sci_boiling_point',
    subject: 'science',
    question: 'At sea level, water boils at:',
    options: ['50 °C', '90 °C', '100 °C', '120 °C'],
    answerIndex: 2,
    minClass: 6,
    maxClass: 8,
    explanation: 'Water boils at 100 °C at sea level — higher up, it boils cooler.',
  ),
  WarmupQuestion(
    id: 'sci_wbc',
    subject: 'science',
    question: 'Which blood cells help fight infection?',
    options: ['Red blood cells', 'White blood cells', 'Platelets', 'Plasma'],
    answerIndex: 1,
    minClass: 6,
    maxClass: 8,
    explanation: "White blood cells are the body's defence force.",
  ),
  WarmupQuestion(
    id: 'sci_force_unit',
    subject: 'science',
    question: 'The SI unit of force is the:',
    options: ['Joule', 'Newton', 'Watt', 'Pascal'],
    answerIndex: 1,
    minClass: 6,
    maxClass: 8,
    explanation: 'Force is measured in newtons (N), named after Isaac Newton.',
  ),
  WarmupQuestion(
    id: 'sci_closest_planet',
    subject: 'science',
    question: 'Which planet is closest to the Sun?',
    options: ['Venus', 'Mercury', 'Earth', 'Mars'],
    answerIndex: 1,
    minClass: 3,
    maxClass: 8,
    explanation: 'Mercury is first, then Venus, then Earth.',
  ),

  // ── Maths ───────────────────────────────────────────────────────────────
  WarmupQuestion(
    id: 'math_7x8',
    subject: 'maths',
    question: 'What is 7 × 8?',
    options: ['54', '56', '48', '64'],
    answerIndex: 1,
    minClass: 1,
    maxClass: 5,
    explanation: '7 × 8 = 56. Seven eights: 8, 16, 24, 32, 40, 48, 56.',
  ),
  WarmupQuestion(
    id: 'math_pentagon',
    subject: 'maths',
    question: 'How many sides does a pentagon have?',
    options: ['Four', 'Five', 'Six', 'Seven'],
    answerIndex: 1,
    minClass: 1,
    maxClass: 5,
    explanation: '"Penta" means five — a pentagon has five sides.',
  ),
  WarmupQuestion(
    id: 'math_pi',
    subject: 'maths',
    question: 'What is π correct to two decimal places?',
    options: ['3.41', '3.14', '3.12', '3.16'],
    answerIndex: 1,
    minClass: 6,
    maxClass: 8,
    explanation: 'π ≈ 3.14, or 22/7 as a fraction.',
  ),
  WarmupQuestion(
    id: 'math_triangle_angles',
    subject: 'maths',
    question: 'The three angles of a triangle add up to:',
    options: ['90°', '180°', '270°', '360°'],
    answerIndex: 1,
    minClass: 6,
    maxClass: 8,
    explanation: 'Always 180°, whatever the shape of the triangle.',
  ),
  WarmupQuestion(
    id: 'math_percent',
    subject: 'maths',
    question: 'What is 15% of 200?',
    options: ['15', '20', '30', '45'],
    answerIndex: 2,
    minClass: 6,
    maxClass: 8,
    explanation: '10% of 200 is 20, and 5% is 10 — so 15% is 30.',
  ),
  WarmupQuestion(
    id: 'math_hcf',
    subject: 'maths',
    question: 'The HCF of 12 and 18 is:',
    options: ['2', '3', '6', '12'],
    answerIndex: 2,
    minClass: 6,
    maxClass: 8,
    explanation: '6 is the largest number that divides both 12 and 18.',
  ),
  WarmupQuestion(
    id: 'math_circle_area',
    subject: 'maths',
    question: 'The area of a circle of radius r is:',
    options: ['2πr', 'πr²', 'πd', 'r²'],
    answerIndex: 1,
    minClass: 6,
    maxClass: 8,
    explanation: 'πr² is the area; 2πr is the circumference.',
  ),

  // ── English ─────────────────────────────────────────────────────────────
  WarmupQuestion(
    id: 'eng_noun',
    subject: 'english',
    question: 'Which of these words is a noun?',
    options: ['Quickly', 'Garden', 'Bright', 'Softly'],
    answerIndex: 1,
    minClass: 1,
    maxClass: 5,
    explanation: 'A noun names a person, place or thing — "garden" is a place.',
  ),
  WarmupQuestion(
    id: 'eng_spelling_receive',
    subject: 'english',
    question: 'Which spelling is correct?',
    options: ['Recieve', 'Receive', 'Receeve', 'Receve'],
    answerIndex: 1,
    minClass: 3,
    maxClass: 8,
    explanation: '"Receive" — i before e, except after c.',
  ),
  WarmupQuestion(
    id: 'eng_past_teach',
    subject: 'english',
    question: 'What is the past tense of "teach"?',
    options: ['Teached', 'Taught', 'Teacht', 'Teaching'],
    answerIndex: 1,
    minClass: 3,
    maxClass: 8,
    explanation: '"Teach" is irregular: teach → taught → taught.',
  ),
  WarmupQuestion(
    id: 'eng_synonym_brave',
    subject: 'english',
    question: 'Which word means the same as "brave"?',
    options: ['Timid', 'Bold', 'Weak', 'Silent'],
    answerIndex: 1,
    minClass: 3,
    maxClass: 8,
    explanation: '"Bold" is a synonym of "brave"; "timid" is the opposite.',
  ),

  // ── Social Science ──────────────────────────────────────────────────────
  WarmupQuestion(
    id: 'soc_independence',
    subject: 'social',
    question: 'In which year did India become independent?',
    options: ['1942', '1945', '1947', '1950'],
    answerIndex: 2,
    minClass: 3,
    maxClass: 8,
    explanation: '15 August 1947. The Constitution came into force in 1950.',
  ),
  WarmupQuestion(
    id: 'soc_longest_river',
    subject: 'social',
    question: 'Which is the longest river in India?',
    options: ['Yamuna', 'Ganga', 'Godavari', 'Narmada'],
    answerIndex: 1,
    minClass: 3,
    maxClass: 8,
    explanation: 'The Ganga runs about 2,525 km across northern India.',
  ),
  WarmupQuestion(
    id: 'soc_odisha_capital',
    subject: 'social',
    question: 'The capital of Odisha is:',
    options: ['Cuttack', 'Bhubaneswar', 'Puri', 'Rourkela'],
    answerIndex: 1,
    minClass: 1,
    maxClass: 8,
    explanation: 'Bhubaneswar became the capital in 1948, replacing Cuttack.',
  ),
  WarmupQuestion(
    id: 'soc_anthem',
    subject: 'social',
    question: "Who wrote India's national anthem?",
    options: [
      'Bankim Chandra Chatterjee',
      'Rabindranath Tagore',
      'Sarojini Naidu',
      'Mahatma Gandhi',
    ],
    answerIndex: 1,
    minClass: 3,
    maxClass: 8,
    explanation:
        'Rabindranath Tagore wrote "Jana Gana Mana"; Bankim Chandra wrote "Vande Mataram".',
  ),
  WarmupQuestion(
    id: 'soc_states',
    subject: 'social',
    question: 'How many states does India have today?',
    options: ['26', '28', '29', '31'],
    answerIndex: 1,
    minClass: 3,
    maxClass: 8,
    explanation: '28 states and 8 union territories.',
  ),
];

/// The questions available to a student in [classNo] — the whole pool when no
/// class is selected, or when no question matches that class.
List<WarmupQuestion> warmupPool({int? classNo}) {
  if (classNo == null) return kWarmupQuestions;
  final pool = kWarmupQuestions
      .where((q) => classNo >= q.minClass && classNo <= q.maxClass)
      .toList();
  return pool.isEmpty ? kWarmupQuestions : pool;
}

/// The warm-up for [date] — the same question all day, filtered to [classNo]
/// when the student has a class selected. Falls back to the full pool when no
/// question matches that class.
WarmupQuestion warmupForDate(DateTime date, {int? classNo}) {
  final questions = warmupPool(classNo: classNo);
  final days = DateTime.utc(date.year, date.month, date.day)
      .difference(DateTime.utc(2024, 1, 1))
      .inDays;
  return questions[days.abs() % questions.length];
}
