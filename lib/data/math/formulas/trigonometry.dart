import 'dart:math';

import 'formula_models.dart';

// ─── Trigonometry ─────────────────────────────────────────────────────────────

const _c = 'Trigonometry';

const _theta = [FormulaInput('θ (deg)', 'Angle in degrees (e.g. 30)')];

const trigonometryFormulas = <FormulaData>[
  FormulaData(
    id: 'triangle-area-trig',
    titleEn: 'Area of Triangle (Trig)',
    titleOr: 'ତ୍ରିଭୁଜର କ୍ଷେତ୍ରଫଳ',
    titleHi: 'त्रिभुज का क्षेत्रफल (त्रिकोणमिति)',
    formula: 'A = ½ ab sin(C)',
    category: _c,
    descEn:
        'Calculates the area of a triangle using two sides and the included angle.',
    descOr:
        'ଦୁଇଟି ବାହୁ ଏବଂ ସେମାନଙ୍କ ମଧ୍ୟବର୍ତ୍ତୀ କୋଣ ବ୍ୟବହାର କରି ତ୍ରିଭୁଜର କ୍ଷେତ୍ରଫଳ ହିସାବ କରେ।',
    descHi:
        'दो भुजाओं और उनके बीच के कोण का उपयोग करके त्रिभुज के क्षेत्रफल की गणना करता है।',
    inputs: [
      FormulaInput('a', 'Side a (e.g. 10)'),
      FormulaInput('b', 'Side b (e.g. 12)'),
      FormulaInput('C (deg)', 'Included Angle (e.g. 30)'),
    ],
    compute: _triangleAreaTrig,
    diagram: FormulaDiagram.triangleTrig,
  ),
  FormulaData(
    id: 'sin-ratio',
    titleEn: 'Sine Ratio',
    titleOr: 'ସାଇନ୍ ଅନୁପାତ',
    titleHi: 'ज्या (sin) अनुपात',
    formula: 'sin(θ) = Opposite / Hypotenuse',
    category: _c,
    descEn:
        'Calculates the sine of an angle, the ratio of the opposite side to the hypotenuse.',
    descOr: 'ଏକ କୋଣର ସାଇନ୍, ଅର୍ଥାତ୍ ସମ୍ମୁଖ ବାହୁ ଓ କର୍ଣ୍ଣର ଅନୁପାତ ହିସାବ କରେ।',
    descHi:
        'किसी कोण की ज्या, अर्थात् सम्मुख भुजा और कर्ण का अनुपात ज्ञात करता है।',
    inputs: _theta,
    compute: _sinRatio,
  ),
  FormulaData(
    id: 'cos-ratio',
    titleEn: 'Cosine Ratio',
    titleOr: 'କୋସାଇନ୍ ଅନୁପାତ',
    titleHi: 'कोज्या (cos) अनुपात',
    formula: 'cos(θ) = Adjacent / Hypotenuse',
    category: _c,
    descEn:
        'Calculates the cosine of an angle, the ratio of the adjacent side to the hypotenuse.',
    descOr: 'ଏକ କୋଣର କୋସାଇନ୍, ଅର୍ଥାତ୍ ସଂଲଗ୍ନ ବାହୁ ଓ କର୍ଣ୍ଣର ଅନୁପାତ ହିସାବ କରେ।',
    descHi:
        'किसी कोण की कोज्या, अर्थात् आसन्न भुजा और कर्ण का अनुपात ज्ञात करता है।',
    inputs: _theta,
    compute: _cosRatio,
  ),
  FormulaData(
    id: 'tan-ratio',
    titleEn: 'Tangent Ratio',
    titleOr: 'ଟାଞ୍ଜେଣ୍ଟ ଅନୁପାତ',
    titleHi: 'स्पर्शज्या (tan) अनुपात',
    formula: 'tan(θ) = Opposite / Adjacent',
    category: _c,
    descEn:
        'Calculates the tangent of an angle, the ratio of the opposite side to the adjacent side.',
    descOr:
        'ଏକ କୋଣର ଟାଞ୍ଜେଣ୍ଟ, ଅର୍ଥାତ୍ ସମ୍ମୁଖ ବାହୁ ଓ ସଂଲଗ୍ନ ବାହୁର ଅନୁପାତ ହିସାବ କରେ।',
    descHi:
        'किसी कोण की स्पर्शज्या, अर्थात् सम्मुख भुजा और आसन्न भुजा का अनुपात ज्ञात करता है।',
    inputs: _theta,
    compute: _tanRatio,
  ),
  FormulaData(
    id: 'law-of-cosines',
    titleEn: 'Law of Cosines',
    titleOr: 'କୋସାଇନ୍ ନିୟମ',
    titleHi: 'कोसाइन नियम',
    formula: 'c = √(a² + b² - 2ab·cos C)',
    category: _c,
    descEn:
        'Finds the third side of a triangle from two sides and the included angle.',
    descOr:
        'ଦୁଇଟି ବାହୁ ଓ ସେମାନଙ୍କ ମଧ୍ୟବର୍ତ୍ତୀ କୋଣରୁ ତ୍ରିଭୁଜର ତୃତୀୟ ବାହୁ ନିର୍ଣ୍ଣୟ କରେ।',
    descHi:
        'दो भुजाओं और उनके बीच के कोण से त्रिभुज की तीसरी भुजा ज्ञात करता है।',
    inputs: [
      FormulaInput('a', 'Side a (e.g. 5)'),
      FormulaInput('b', 'Side b (e.g. 7)'),
      FormulaInput('C (deg)', 'Included Angle (e.g. 60)'),
    ],
    compute: _lawOfCosines,
  ),
  FormulaData(
    id: 'law-of-sines',
    titleEn: 'Law of Sines',
    titleOr: 'ସାଇନ୍ ନିୟମ',
    titleHi: 'साइन नियम',
    formula: 'a / sin A = b / sin B',
    category: _c,
    descEn:
        'Finds an unknown side b using a known side a and its opposite angles A and B.',
    descOr:
        'ଜଣା ବାହୁ a ଏବଂ ତାହାର ସମ୍ମୁଖ କୋଣ A ଓ B ବ୍ୟବହାର କରି ଅଜ୍ଞାତ ବାହୁ b ନିର୍ଣ୍ଣୟ କରେ।',
    descHi:
        'ज्ञात भुजा a और उसके सम्मुख कोणों A तथा B का उपयोग कर अज्ञात भुजा b ज्ञात करता है।',
    inputs: [
      FormulaInput('a', 'Known side a (e.g. 5)'),
      FormulaInput('A (deg)', 'Angle A (e.g. 40)'),
      FormulaInput('B (deg)', 'Angle B (e.g. 60)'),
    ],
    compute: _lawOfSines,
  ),
  FormulaData(
    id: 'arc-length',
    titleEn: 'Arc Length',
    titleOr: 'ଚାପର ଦୈର୍ଘ୍ୟ',
    titleHi: 'चाप की लंबाई',
    formula: 'L = (θ / 360) × 2πr',
    category: _c,
    descEn:
        'Calculates the length of an arc subtending an angle θ (in degrees) at the centre.',
    descOr: 'କେନ୍ଦ୍ରରେ θ (ଡିଗ୍ରୀ) କୋଣ ସୃଷ୍ଟି କରୁଥିବା ଚାପର ଦୈର୍ଘ୍ୟ ହିସାବ କରେ।',
    descHi: 'केंद्र पर θ (डिग्री) कोण बनाने वाले चाप की लंबाई की गणना करता है।',
    inputs: [
      FormulaInput('r', 'Radius (e.g. 5)'),
      FormulaInput('θ (deg)', 'Angle in degrees (e.g. 90)'),
    ],
    compute: _arcLength,
    diagram: FormulaDiagram.circle,
  ),
  FormulaData(
    id: 'reciprocal-ratios',
    titleEn: 'Reciprocal Ratios',
    titleOr: 'ବ୍ୟୁତ୍କ୍ରମ ଅନୁପାତ',
    titleHi: 'व्युत्क्रम अनुपात',
    formula: 'cosec θ = 1/sin θ,  sec θ = 1/cos θ,  cot θ = 1/tan θ',
    category: _c,
    descEn: 'cosec, sec and cot are the reciprocals of sin, cos and tan.',
    descOr: 'cosec, sec ଓ cot ହେଉଛନ୍ତି sin, cos ଓ tan ର ବ୍ୟୁତ୍କ୍ରମ।',
    descHi: 'cosec, sec और cot क्रमशः sin, cos और tan के व्युत्क्रम हैं।',
    inputs: _theta,
    compute: _reciprocals,
  ),
  FormulaData(
    id: 'trig-identities',
    titleEn: 'Trigonometric Identities',
    titleOr: 'ତ୍ରିକୋଣମିତିକ ଅଭେଦ',
    titleHi: 'त्रिकोणमितीय सर्वसमिकाएँ',
    formula: 'sin²θ + cos²θ = 1\n1 + tan²θ = sec²θ\n1 + cot²θ = cosec²θ',
    category: _c,
    descEn:
        'Three identities true for every angle θ (where defined). Enter an angle to check them.',
    descOr:
        'ପ୍ରତ୍ୟେକ କୋଣ θ ପାଇଁ ସତ୍ୟ ତିନୋଟି ଅଭେଦ (ଯେଉଁଠି ସଂଜ୍ଞାୟିତ)। ଯାଞ୍ଚ କରିବାକୁ ଏକ କୋଣ ଦିଅ।',
    descHi:
        'हर कोण θ के लिए सत्य तीन सर्वसमिकाएँ (जहाँ परिभाषित हों)। जाँचने के लिए कोई कोण डालें।',
    inputs: _theta,
    compute: _identities,
  ),
  FormulaData(
    id: 'standard-angles',
    titleEn: 'Standard Angle Values',
    titleOr: 'ମାନକ କୋଣର ମାନ',
    titleHi: 'मानक कोणों के मान',
    formula: '''θ      0°    30°    45°    60°    90°
sin    0     1/2    1/√2   √3/2   1
cos    1     √3/2   1/√2   1/2    0
tan    0     1/√3   1      √3     —''',
    category: _c,
    descEn:
        'The values of sin, cos and tan for the standard angles, worth learning by heart.',
    descOr: 'ମାନକ କୋଣଗୁଡ଼ିକ ପାଇଁ sin, cos ଓ tan ର ମାନ, ଯାହା ମନେ ରଖିବା ଉଚିତ।',
    descHi: 'मानक कोणों के लिए sin, cos और tan के मान, जिन्हें याद रखना चाहिए।',
  ),
];

// ─── Calculators ──────────────────────────────────────────────────────────────

String? _triangleAreaTrig(FormulaValues v) {
  final a = v.n('a'), b = v.n('b'), deg = v.n('C (deg)');
  if (a == null || b == null || deg == null) return null;
  return 'A = ${fx(0.5 * a * b * sin(rad(deg)), 4)}';
}

String? _sinRatio(FormulaValues v) {
  final deg = v.n('θ (deg)');
  return deg == null ? null : 'sin(θ) = ${fx(sin(rad(deg)), 4)}';
}

String? _cosRatio(FormulaValues v) {
  final deg = v.n('θ (deg)');
  return deg == null ? null : 'cos(θ) = ${fx(cos(rad(deg)), 4)}';
}

String? _tanRatio(FormulaValues v) {
  final deg = v.n('θ (deg)');
  return deg == null ? null : 'tan(θ) = ${fx(tan(rad(deg)), 4)}';
}

String? _lawOfCosines(FormulaValues v) {
  final a = v.n('a'), b = v.n('b'), deg = v.n('C (deg)');
  if (a == null || b == null || deg == null) return null;
  return 'c = ${fx(sqrt(a * a + b * b - 2 * a * b * cos(rad(deg))), 4)}';
}

String? _lawOfSines(FormulaValues v) {
  final a = v.n('a'), angleA = v.n('A (deg)'), angleB = v.n('B (deg)');
  if (a == null || angleA == null || angleB == null) return null;
  final sinA = sin(rad(angleA));
  if (sinA == 0) return null;
  return 'b = ${fx(a * sin(rad(angleB)) / sinA, 4)}';
}

String? _arcLength(FormulaValues v) {
  final r = v.n('r'), deg = v.n('θ (deg)');
  if (r == null || deg == null) return null;
  return 'L = ${fx(deg / 360 * 2 * pi * r, 4)}';
}

/// "undefined" when a ratio's denominator is (numerically) zero, e.g. sec 90°.
String _inv(double x) => x.abs() < 1e-9 ? 'undefined' : nice(1 / x);

String? _reciprocals(FormulaValues v) {
  final deg = v.n('θ (deg)');
  if (deg == null) return null;
  final t = rad(deg);
  return 'cosec = ${_inv(sin(t))}, sec = ${_inv(cos(t))}, '
      'cot = ${_inv(tan(t))}';
}

String? _identities(FormulaValues v) {
  final deg = v.n('θ (deg)');
  if (deg == null) return null;
  final t = rad(deg);
  final s = sin(t), c = cos(t);
  return 'sin²θ + cos²θ = ${nice(s * s + c * c)}';
}
