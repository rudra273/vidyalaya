import 'dart:math';

import 'formula_models.dart';

// ─── Algebra ──────────────────────────────────────────────────────────────────

const _c = 'Algebra';

const _ab = [
  FormulaInput('a', 'Value of a (e.g. 3)'),
  FormulaInput('b', 'Value of b (e.g. 2)'),
];

const _ap = [
  FormulaInput('a', 'First term (e.g. 2)'),
  FormulaInput('d', 'Common difference (e.g. 3)'),
  FormulaInput('n', 'Term count n (e.g. 10)'),
];

const algebraFormulas = <FormulaData>[
  FormulaData(
    id: 'quadratic',
    titleEn: 'Quadratic Equation',
    titleOr: 'ଦ୍ୱିଘାତ ସମୀକରଣ',
    titleHi: 'द्विघात समीकरण',
    formula: 'x = (-b ± √(b² - 4ac)) / 2a',
    category: _c,
    descEn:
        'Finds the unknown variable x (roots) in a second-degree polynomial equation.',
    descOr: 'ଏକ ଦ୍ୱିଘାତ ସମୀକରଣରେ ଅଜ୍ଞାତ ରାଶି x ର ମୂଲ୍ୟ (ମୂଳ) ନିର୍ଣ୍ଣୟ କରେ।',
    descHi: 'एक द्विघात समीकरण में अज्ञात राशि x का मान (मूल) ज्ञात करता है।',
    inputs: [
      FormulaInput('a', 'Coefficient a'),
      FormulaInput('b', 'Coefficient b'),
      FormulaInput('c', 'Constant c'),
    ],
    compute: _quadratic,
  ),
  FormulaData(
    id: 'a-plus-b-squared',
    titleEn: 'Square of Sum',
    titleOr: 'ଯୋଗର ବର୍ଗ',
    titleHi: 'योग का वर्ग',
    formula: '(a + b)² = a² + 2ab + b²',
    category: _c,
    descEn: 'Expands the square of the sum of two terms a and b.',
    descOr: 'ଦୁଇଟି ପଦ a ଓ b ର ଯୋଗର ବର୍ଗକୁ ବିସ୍ତାର କରେ।',
    descHi: 'दो पदों a और b के योग के वर्ग का प्रसार करता है।',
    inputs: _ab,
    compute: _aPlusBSquared,
  ),
  FormulaData(
    id: 'a-minus-b-squared',
    titleEn: 'Square of Difference',
    titleOr: 'ବିୟୋଗର ବର୍ଗ',
    titleHi: 'अंतर का वर्ग',
    formula: '(a - b)² = a² - 2ab + b²',
    category: _c,
    descEn: 'Expands the square of the difference of two terms a and b.',
    descOr: 'ଦୁଇଟି ପଦ a ଓ b ର ବିୟୋଗର ବର୍ଗକୁ ବିସ୍ତାର କରେ।',
    descHi: 'दो पदों a और b के अंतर के वर्ग का प्रसार करता है।',
    inputs: _ab,
    compute: _aMinusBSquared,
  ),
  FormulaData(
    id: 'difference-of-squares',
    titleEn: 'Difference of Squares',
    titleOr: 'ବର୍ଗର ଅନ୍ତର',
    titleHi: 'वर्गों का अंतर',
    formula: 'a² - b² = (a + b)(a - b)',
    category: _c,
    descEn: 'Factorises the difference of the squares of two terms a and b.',
    descOr: 'ଦୁଇଟି ପଦ a ଓ b ର ବର୍ଗର ଅନ୍ତରକୁ ଗୁଣନୀୟକରେ ବିଭକ୍ତ କରେ।',
    descHi: 'दो पदों a और b के वर्गों के अंतर का गुणनखंडन करता है।',
    inputs: _ab,
    compute: _aSquaredMinusBSquared,
  ),
  FormulaData(
    id: 'a-plus-b-cubed',
    titleEn: 'Cube of Sum',
    titleOr: 'ଯୋଗର ଘନ',
    titleHi: 'योग का घन',
    formula: '(a + b)³ = a³ + 3a²b + 3ab² + b³',
    category: _c,
    descEn: 'Expands the cube of the sum of two terms a and b.',
    descOr: 'ଦୁଇଟି ପଦ a ଓ b ର ଯୋଗର ଘନକୁ ବିସ୍ତାର କରେ।',
    descHi: 'दो पदों a और b के योग के घन का प्रसार करता है।',
    inputs: _ab,
    compute: _aPlusBCubed,
  ),
  FormulaData(
    id: 'a-minus-b-cubed',
    titleEn: 'Cube of Difference',
    titleOr: 'ବିୟୋଗର ଘନ',
    titleHi: 'अंतर का घन',
    formula: '(a - b)³ = a³ - 3a²b + 3ab² - b³',
    category: _c,
    descEn: 'Expands the cube of the difference of two terms a and b.',
    descOr: 'ଦୁଇଟି ପଦ a ଓ b ର ବିୟୋଗର ଘନକୁ ବିସ୍ତାର କରେ।',
    descHi: 'दो पदों a और b के अंतर के घन का प्रसार करता है।',
    inputs: _ab,
    compute: _aMinusBCubed,
  ),
  FormulaData(
    id: 'ap-nth-term',
    titleEn: 'nth Term of an AP',
    titleOr: 'ସମାନ୍ତର ଶ୍ରେଣୀର nth ପଦ',
    titleHi: 'समांतर श्रेणी का nवाँ पद',
    formula: 'aₙ = a + (n - 1)d',
    category: _c,
    descEn:
        'Finds the nth term of an arithmetic progression with first term a and common difference d.',
    descOr:
        'ପ୍ରଥମ ପଦ a ଓ ସାଧାରଣ ଅନ୍ତର d ବିଶିଷ୍ଟ ସମାନ୍ତର ଶ୍ରେଣୀର nth ପଦ ନିର୍ଣ୍ଣୟ କରେ।',
    descHi:
        'प्रथम पद a और सार्व अंतर d वाली समांतर श्रेणी का nवाँ पद ज्ञात करता है।',
    inputs: _ap,
    compute: _apNthTerm,
  ),
  FormulaData(
    id: 'ap-sum',
    titleEn: 'Sum of an AP',
    titleOr: 'ସମାନ୍ତର ଶ୍ରେଣୀର ଯୋଗ',
    titleHi: 'समांतर श्रेणी का योग',
    formula: 'Sₙ = n/2 × [2a + (n - 1)d]',
    category: _c,
    descEn: 'Finds the sum of the first n terms of an arithmetic progression.',
    descOr: 'ସମାନ୍ତର ଶ୍ରେଣୀର ପ୍ରଥମ n ପଦର ଯୋଗଫଳ ନିର୍ଣ୍ଣୟ କରେ।',
    descHi: 'समांतर श्रेणी के प्रथम n पदों के योग की गणना करता है।',
    inputs: _ap,
    compute: _apSum,
  ),
  FormulaData(
    id: 'a-plus-b-plus-c-squared',
    titleEn: 'Square of Three Terms',
    titleOr: 'ତିନୋଟି ପଦର ବର୍ଗ',
    titleHi: 'तीन पदों का वर्ग',
    formula: '(a + b + c)² = a² + b² + c² + 2ab + 2bc + 2ca',
    category: _c,
    descEn: 'Expands the square of the sum of three terms.',
    descOr: 'ତିନୋଟି ପଦର ଯୋଗଫଳର ବର୍ଗକୁ ବିସ୍ତାର କରେ।',
    descHi: 'तीन पदों के योग के वर्ग का प्रसार करता है।',
    inputs: [
      FormulaInput('a', 'Value of a (e.g. 1)'),
      FormulaInput('b', 'Value of b (e.g. 2)'),
      FormulaInput('c', 'Value of c (e.g. 3)'),
    ],
    compute: _abcSquared,
  ),
  FormulaData(
    id: 'sum-of-cubes',
    titleEn: 'Sum of Cubes',
    titleOr: 'ଘନର ଯୋଗଫଳ',
    titleHi: 'घनों का योग',
    formula: 'a³ + b³ = (a + b)(a² − ab + b²)',
    category: _c,
    descEn: 'Factorises the sum of two cubes.',
    descOr: 'ଦୁଇଟି ଘନର ଯୋଗଫଳର ଉତ୍ପାଦକୀକରଣ କରେ।',
    descHi: 'दो घनों के योग का गुणनखंड करता है।',
    inputs: _ab,
    compute: _sumOfCubes,
  ),
  FormulaData(
    id: 'difference-of-cubes',
    titleEn: 'Difference of Cubes',
    titleOr: 'ଘନର ଅନ୍ତର',
    titleHi: 'घनों का अंतर',
    formula: 'a³ − b³ = (a − b)(a² + ab + b²)',
    category: _c,
    descEn: 'Factorises the difference of two cubes.',
    descOr: 'ଦୁଇଟି ଘନର ଅନ୍ତରର ଉତ୍ପାଦକୀକରଣ କରେ।',
    descHi: 'दो घनों के अंतर का गुणनखंड करता है।',
    inputs: _ab,
    compute: _differenceOfCubes,
  ),
  FormulaData(
    id: 'laws-of-exponents',
    titleEn: 'Laws of Exponents',
    titleOr: 'ଘାତାଙ୍କର ନିୟମ',
    titleHi: 'घातांक के नियम',
    formula: 'aᵐ × aⁿ = aᵐ⁺ⁿ   aᵐ ÷ aⁿ = aᵐ⁻ⁿ   (aᵐ)ⁿ = aᵐⁿ',
    category: _c,
    descEn:
        'Multiplying powers of the same base adds the exponents, dividing subtracts them, and a power of a power multiplies them.',
    descOr:
        'ସମାନ ଆଧାରର ଘାତକୁ ଗୁଣନ କଲେ ଘାତାଙ୍କ ଯୋଗ ହୁଏ, ଭାଗ କଲେ ବିୟୋଗ ହୁଏ, ଓ ଘାତର ଘାତରେ ଘାତାଙ୍କ ଗୁଣନ ହୁଏ।',
    descHi:
        'समान आधार की घातों का गुणा करने पर घातांक जुड़ते हैं, भाग देने पर घटते हैं, और घात की घात में गुणा होते हैं।',
    inputs: [
      FormulaInput('a', 'Base (e.g. 2)'),
      FormulaInput('m', 'Exponent m (e.g. 3)'),
      FormulaInput('n', 'Exponent n (e.g. 2)'),
    ],
    compute: _exponents,
  ),
  FormulaData(
    id: 'discriminant',
    titleEn: 'Discriminant (Nature of Roots)',
    titleOr: 'ବିଭେଦକ (ମୂଳର ପ୍ରକୃତି)',
    titleHi: 'विविक्तकर (मूलों की प्रकृति)',
    formula: 'D = b² − 4ac',
    category: _c,
    descEn:
        'For ax² + bx + c = 0: if D > 0 there are two real roots, if D = 0 two equal roots, and if D < 0 no real roots.',
    descOr:
        'ax² + bx + c = 0 ପାଇଁ: D > 0 ହେଲେ ଦୁଇଟି ବାସ୍ତବ ମୂଳ, D = 0 ହେଲେ ଦୁଇଟି ସମାନ ମୂଳ, ଓ D < 0 ହେଲେ କୌଣସି ବାସ୍ତବ ମୂଳ ନାହିଁ।',
    descHi:
        'ax² + bx + c = 0 के लिए: D > 0 हो तो दो वास्तविक मूल, D = 0 हो तो दो बराबर मूल, और D < 0 हो तो कोई वास्तविक मूल नहीं।',
    inputs: [
      FormulaInput('a', 'Coefficient a'),
      FormulaInput('b', 'Coefficient b'),
      FormulaInput('c', 'Constant c'),
    ],
    compute: _discriminant,
  ),
  FormulaData(
    id: 'sum-first-n',
    titleEn: 'Sum of First n Natural Numbers',
    titleOr: 'ପ୍ରଥମ n ଗୋଟି ସ୍ୱାଭାବିକ ସଂଖ୍ୟାର ଯୋଗଫଳ',
    titleHi: 'पहली n प्राकृत संख्याओं का योग',
    formula: '1 + 2 + … + n = n(n + 1) / 2',
    category: _c,
    descEn: 'Adds up all the counting numbers from 1 to n in one step.',
    descOr: '1 ରୁ n ପର୍ଯ୍ୟନ୍ତ ସମସ୍ତ ଗଣନ ସଂଖ୍ୟାକୁ ଗୋଟିଏ ପଦକ୍ଷେପରେ ଯୋଗ କରେ।',
    descHi: '1 से n तक की सभी गिनती संख्याओं को एक ही चरण में जोड़ता है।',
    inputs: [FormulaInput('n', 'Last number n (e.g. 100)')],
    compute: _sumFirstN,
  ),
  FormulaData(
    id: 'linear-equation',
    titleEn: 'Linear Equation',
    titleOr: 'ରୈଖିକ ସମୀକରଣ',
    titleHi: 'रैखिक समीकरण',
    formula: 'ax + b = 0  ⇒  x = −b / a',
    category: _c,
    descEn: 'Solves a linear equation in one variable.',
    descOr: 'ଗୋଟିଏ ଚଳରାଶି ବିଶିଷ୍ଟ ରୈଖିକ ସମୀକରଣର ସମାଧାନ କରେ।',
    descHi: 'एक चर वाले रैखिक समीकरण को हल करता है।',
    inputs: [
      FormulaInput('a', 'Coefficient of x (e.g. 2)'),
      FormulaInput('b', 'Constant b (e.g. -6)'),
    ],
    compute: _linear,
  ),
];

// ─── Calculators ──────────────────────────────────────────────────────────────

String? _quadratic(FormulaValues v) {
  final a = v.n('a'), b = v.n('b'), c = v.n('c');
  if (a == null || b == null || c == null) return null;
  if (a == 0) return 'Not a quadratic (a cannot be 0)';
  final d = (b * b) - (4 * a * c);
  if (d > 0) {
    final r1 = (-b + sqrt(d)) / (2 * a);
    final r2 = (-b - sqrt(d)) / (2 * a);
    return 'x = ${fx(r1, 4)} or x = ${fx(r2, 4)}';
  }
  if (d == 0) return 'x = ${fx(-b / (2 * a), 4)}';
  final real = -b / (2 * a);
  final imag = sqrt(-d) / (2 * a);
  return 'x = ${fx(real, 4)} ± ${fx(imag, 4)}i';
}

String? _twoTerms(
  FormulaValues v,
  String label,
  num Function(double, double) f,
) {
  final a = v.n('a'), b = v.n('b');
  if (a == null || b == null) return null;
  return '$label = ${fx(f(a, b))}';
}

String? _aPlusBSquared(FormulaValues v) =>
    _twoTerms(v, '(a + b)²', (a, b) => (a + b) * (a + b));

String? _aMinusBSquared(FormulaValues v) =>
    _twoTerms(v, '(a - b)²', (a, b) => (a - b) * (a - b));

String? _aSquaredMinusBSquared(FormulaValues v) =>
    _twoTerms(v, 'a² - b²', (a, b) => a * a - b * b);

String? _aPlusBCubed(FormulaValues v) =>
    _twoTerms(v, '(a + b)³', (a, b) => pow(a + b, 3));

String? _aMinusBCubed(FormulaValues v) =>
    _twoTerms(v, '(a - b)³', (a, b) => pow(a - b, 3));

String? _sumOfCubes(FormulaValues v) =>
    _twoTerms(v, 'a³ + b³', (a, b) => pow(a, 3) + pow(b, 3));

String? _differenceOfCubes(FormulaValues v) =>
    _twoTerms(v, 'a³ − b³', (a, b) => pow(a, 3) - pow(b, 3));

String? _abcSquared(FormulaValues v) {
  final a = v.n('a'), b = v.n('b'), c = v.n('c');
  if (a == null || b == null || c == null) return null;
  return '(a + b + c)² = ${nice(pow(a + b + c, 2))}';
}

String? _apNthTerm(FormulaValues v) {
  final a = v.n('a'), d = v.n('d'), n = v.n('n');
  if (a == null || d == null || n == null) return null;
  return 'aₙ = ${fx(a + (n - 1) * d)}';
}

String? _apSum(FormulaValues v) {
  final a = v.n('a'), d = v.n('d'), n = v.n('n');
  if (a == null || d == null || n == null) return null;
  return 'Sₙ = ${fx(n / 2 * (2 * a + (n - 1) * d))}';
}

String? _exponents(FormulaValues v) {
  final a = v.n('a'), m = v.n('m'), n = v.n('n');
  if (a == null || m == null || n == null) return null;
  if (a == 0) return 'Base cannot be 0';
  return 'aᵐ⁺ⁿ = ${nice(pow(a, m + n))}, '
      'aᵐ⁻ⁿ = ${nice(pow(a, m - n))}, '
      'aᵐⁿ = ${nice(pow(a, m * n))}';
}

String? _discriminant(FormulaValues v) {
  final a = v.n('a'), b = v.n('b'), c = v.n('c');
  if (a == null || b == null || c == null) return null;
  final d = b * b - 4 * a * c;
  final nature = d > 0
      ? 'two real roots'
      : d == 0
      ? 'two equal roots'
      : 'no real roots';
  return 'D = ${nice(d)} → $nature';
}

String? _sumFirstN(FormulaValues v) {
  final n = v.n('n');
  if (n == null || n < 1 || n != n.roundToDouble()) return null;
  return 'Sum = ${nice(n * (n + 1) / 2)}';
}

String? _linear(FormulaValues v) {
  final a = v.n('a'), b = v.n('b');
  if (a == null || b == null) return null;
  if (a == 0) return 'a cannot be 0';
  return 'x = ${nice(-b / a)}';
}
