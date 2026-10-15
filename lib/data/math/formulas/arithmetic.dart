import 'dart:math';

import 'formula_models.dart';

// ─── Arithmetic ───────────────────────────────────────────────────────────────

const _c = 'Arithmetic';

const arithmeticFormulas = <FormulaData>[
  FormulaData(
    id: 'simple-interest',
    titleEn: 'Simple Interest',
    titleOr: 'ସରଳ ସୁଧ',
    titleHi: 'साधारण ब्याज',
    formula: 'SI = (P × R × T) / 100',
    category: _c,
    descEn:
        'Calculates the simple interest earned on a principal sum over a period of time.',
    descOr: 'ଏକ ନିର୍ଦ୍ଦିଷ୍ଟ ସମୟ ପାଇଁ ମୂଳଧନ ଉପରେ ମିଳୁଥିବା ସରଳ ସୁଧ ହିସାବ କରେ।',
    descHi:
        'एक निश्चित अवधि के लिए मूलधन पर अर्जित साधारण ब्याज की गणना करता है।',
    inputs: [
      FormulaInput('P', 'Principal (e.g. 1000)'),
      FormulaInput('R', 'Rate % (e.g. 5)'),
      FormulaInput('T', 'Time in years (e.g. 2)'),
    ],
    compute: _simpleInterest,
  ),
  FormulaData(
    id: 'compound-interest',
    titleEn: 'Compound Interest',
    titleOr: 'ଚକ୍ରବୃଦ୍ଧି ସୁଧ',
    titleHi: 'चक्रवृद्धि ब्याज',
    formula: 'A = P(1 + R/100)^T',
    category: _c,
    descEn:
        'Calculates the final amount when interest is compounded annually on a principal.',
    descOr:
        'ମୂଳଧନ ଉପରେ ବାର୍ଷିକ ଚକ୍ରବୃଦ୍ଧି ସୁଧ ଲାଗିଲେ ମିଳୁଥିବା ସମୁଦାୟ ରାଶି ହିସାବ କରେ।',
    descHi:
        'मूलधन पर वार्षिक चक्रवृद्धि होने पर प्राप्त कुल राशि की गणना करता है।',
    inputs: [
      FormulaInput('P', 'Principal (e.g. 1000)'),
      FormulaInput('R', 'Rate % (e.g. 5)'),
      FormulaInput('T', 'Time in years (e.g. 2)'),
    ],
    compute: _compoundInterest,
  ),
  FormulaData(
    id: 'percentage',
    titleEn: 'Percentage',
    titleOr: 'ଶତକଡ଼ା',
    titleHi: 'प्रतिशत',
    formula: '% = (Value / Total) × 100',
    category: _c,
    descEn: 'Expresses a value as a fraction of a total, out of one hundred.',
    descOr: 'ଏକ ମୂଲ୍ୟକୁ ସମୁଦାୟର ଅଂଶ ଭାବେ ଶହକୁ ହିସାବ କରି ପ୍ରକାଶ କରେ।',
    descHi:
        'किसी मान को कुल का अंश मानते हुए सौ में से प्रतिशत के रूप में दर्शाता है।',
    inputs: [
      FormulaInput('Value', 'Part value (e.g. 25)'),
      FormulaInput('Total', 'Total value (e.g. 200)'),
    ],
    compute: _percentage,
  ),
  FormulaData(
    id: 'average',
    titleEn: 'Average (Mean)',
    titleOr: 'ହାରାହାରି',
    titleHi: 'औसत (माध्य)',
    formula: 'Mean = Sum / Count',
    category: _c,
    descEn:
        'Finds the average of a set of numbers by dividing their sum by how many numbers there are.',
    descOr:
        'ସଂଖ୍ୟାଗୁଡ଼ିକର ଯୋଗଫଳକୁ ସେଗୁଡ଼ିକର ସଂଖ୍ୟା ଦ୍ୱାରା ଭାଗ କରି ହାରାହାରି ନିର୍ଣ୍ଣୟ କରେ।',
    descHi: 'संख्याओं के योग को उनकी कुल संख्या से भाग देकर औसत ज्ञात करता है।',
    inputs: [
      FormulaInput(
        'x',
        'Numbers, comma-separated (e.g. 10, 20, 30)',
        isList: true,
      ),
    ],
    compute: _average,
  ),
  FormulaData(
    id: 'profit-percent',
    titleEn: 'Profit Percentage',
    titleOr: 'ଲାଭ ଶତକଡ଼ା',
    titleHi: 'लाभ प्रतिशत',
    formula: 'Profit % = ((SP - CP) / CP) × 100',
    category: _c,
    descEn:
        'Calculates the profit percentage from the cost price and selling price.',
    descOr: 'କ୍ରୟ ମୂଲ୍ୟ ଓ ବିକ୍ରୟ ମୂଲ୍ୟରୁ ଲାଭ ଶତକଡ଼ା ହିସାବ କରେ।',
    descHi: 'क्रय मूल्य और विक्रय मूल्य से लाभ प्रतिशत की गणना करता है।',
    inputs: [
      FormulaInput('CP', 'Cost Price (e.g. 100)'),
      FormulaInput('SP', 'Selling Price (e.g. 120)'),
    ],
    compute: _profitPercent,
  ),
  FormulaData(
    id: 'loss-percent',
    titleEn: 'Loss Percentage',
    titleOr: 'କ୍ଷତି ଶତକଡ଼ା',
    titleHi: 'हानि प्रतिशत',
    formula: 'Loss % = ((CP - SP) / CP) × 100',
    category: _c,
    descEn:
        'Calculates the loss percentage from the cost price and selling price.',
    descOr: 'କ୍ରୟ ମୂଲ୍ୟ ଓ ବିକ୍ରୟ ମୂଲ୍ୟରୁ କ୍ଷତି ଶତକଡ଼ା ହିସାବ କରେ।',
    descHi: 'क्रय मूल्य और विक्रय मूल्य से हानि प्रतिशत की गणना करता है।',
    inputs: [
      FormulaInput('CP', 'Cost Price (e.g. 100)'),
      FormulaInput('SP', 'Selling Price (e.g. 80)'),
    ],
    compute: _lossPercent,
  ),
  FormulaData(
    id: 'discount',
    titleEn: 'Discount & Selling Price',
    titleOr: 'ରିହାତି ଓ ବିକ୍ରୟ ମୂଲ୍ୟ',
    titleHi: 'छूट और विक्रय मूल्य',
    formula: 'SP = MP − (MP × D / 100)',
    category: _c,
    descEn:
        'Finds the discount and the price you pay when a marked price is reduced by a discount percent.',
    descOr:
        'ଚିହ୍ନିତ ମୂଲ୍ୟ ଉପରେ ଶତକଡ଼ା ରିହାତି ଦିଆଗଲେ ରିହାତି ପରିମାଣ ଓ ଦେବାକୁ ଥିବା ମୂଲ୍ୟ ନିର୍ଣ୍ଣୟ କରେ।',
    descHi:
        'अंकित मूल्य पर प्रतिशत छूट मिलने पर छूट की राशि और चुकाई जाने वाली कीमत ज्ञात करता है।',
    inputs: [
      FormulaInput('MP', 'Marked price (e.g. 500)'),
      FormulaInput('D', 'Discount % (e.g. 10)'),
    ],
    compute: _discount,
  ),
  FormulaData(
    id: 'percent-change',
    titleEn: 'Percentage Increase / Decrease',
    titleOr: 'ଶତକଡ଼ା ବୃଦ୍ଧି / ହ୍ରାସ',
    titleHi: 'प्रतिशत वृद्धि / कमी',
    formula: '% change = ((New − Old) / Old) × 100',
    category: _c,
    descEn:
        'Shows by what percent a value has gone up or down from its original value.',
    descOr: 'ଏକ ମୂଲ୍ୟ ତାହାର ମୂଳ ମୂଲ୍ୟଠାରୁ କେତେ ଶତକଡ଼ା ବଢ଼ିଲା ବା କମିଲା ଦର୍ଶାଏ।',
    descHi: 'कोई मान अपने मूल मान से कितने प्रतिशत बढ़ा या घटा, यह दर्शाता है।',
    inputs: [
      FormulaInput('Old', 'Original value (e.g. 40)'),
      FormulaInput('New', 'New value (e.g. 50)'),
    ],
    compute: _percentChange,
  ),
  FormulaData(
    id: 'ratio-share',
    titleEn: 'Dividing in a Ratio',
    titleOr: 'ଅନୁପାତରେ ଭାଗ',
    titleHi: 'अनुपात में बाँटना',
    formula: 'Share₁ = N × a / (a + b)',
    category: _c,
    descEn: 'Splits a total amount between two people in the ratio a : b.',
    descOr: 'ଏକ ମୋଟ ରାଶିକୁ ଦୁଇ ଜଣଙ୍କ ମଧ୍ୟରେ a : b ଅନୁପାତରେ ଭାଗ କରେ।',
    descHi: 'कुल राशि को दो लोगों में a : b के अनुपात में बाँटता है।',
    inputs: [
      FormulaInput('N', 'Total amount (e.g. 600)'),
      FormulaInput('a', 'First part of ratio (e.g. 2)'),
      FormulaInput('b', 'Second part of ratio (e.g. 3)'),
    ],
    compute: _ratioShare,
  ),
  FormulaData(
    id: 'unitary-method',
    titleEn: 'Unitary Method',
    titleOr: 'ଏକକ ପଦ୍ଧତି',
    titleHi: 'ऐकिक नियम',
    formula: 'Cost of m = (Cost of n / n) × m',
    category: _c,
    descEn:
        'Finds the value of one item first, then multiplies to get the value of many.',
    descOr:
        'ପ୍ରଥମେ ଗୋଟିଏ ଜିନିଷର ମୂଲ୍ୟ ବାହାର କରି, ତାପରେ ଗୁଣନ କରି ଅନେକ ଜିନିଷର ମୂଲ୍ୟ ନିର୍ଣ୍ଣୟ କରେ।',
    descHi:
        'पहले एक वस्तु का मान निकालता है, फिर गुणा करके कई वस्तुओं का मान ज्ञात करता है।',
    inputs: [
      FormulaInput('n', 'Known quantity (e.g. 5 pens)'),
      FormulaInput('Cost', 'Cost of that quantity (e.g. 50)'),
      FormulaInput('m', 'Quantity wanted (e.g. 8)'),
    ],
    compute: _unitary,
  ),
  FormulaData(
    id: 'hcf-lcm',
    titleEn: 'HCF × LCM',
    titleOr: 'ଗ.ସା.ଗୁ × ଲ.ସା.ଗୁ',
    titleHi: 'म.स. × ल.स.',
    formula: 'HCF(a, b) × LCM(a, b) = a × b',
    category: _c,
    descEn:
        'For two whole numbers, the HCF times the LCM equals the product of the numbers. Enter two numbers to get both.',
    descOr:
        'ଦୁଇଟି ପୂର୍ଣ୍ଣ ସଂଖ୍ୟା ପାଇଁ ଗ.ସା.ଗୁ ଓ ଲ.ସା.ଗୁର ଗୁଣଫଳ ସଂଖ୍ୟା ଦୁଇଟିର ଗୁଣଫଳ ସହ ସମାନ।',
    descHi:
        'दो पूर्ण संख्याओं के लिए म.स. और ल.स. का गुणनफल उन संख्याओं के गुणनफल के बराबर होता है।',
    inputs: [
      FormulaInput('a', 'First whole number (e.g. 12)'),
      FormulaInput('b', 'Second whole number (e.g. 18)'),
    ],
    compute: _hcfLcm,
  ),
  FormulaData(
    id: 'divisibility-rules',
    titleEn: 'Divisibility Rules',
    titleOr: 'ବିଭାଜ୍ୟତା ନିୟମ',
    titleHi: 'विभाज्यता के नियम',
    formula: '''2: last digit is even
3: sum of digits divisible by 3
4: last two digits divisible by 4
5: last digit is 0 or 5
6: divisible by both 2 and 3
8: last three digits divisible by 8
9: sum of digits divisible by 9
10: last digit is 0
11: (sum of odd-place digits) − (sum of even-place digits) is 0 or a multiple of 11''',
    category: _c,
    descEn:
        'Quick tests to see whether a number divides exactly without doing the division. Enter a number to check it against all of them.',
    descOr:
        'ଭାଗ ନକରି ଜାଣିବାର ସହଜ ଉପାୟ କି ସଂଖ୍ୟାଟି ସମ୍ପୂର୍ଣ୍ଣ ଭାବେ ବିଭାଜ୍ୟ। ସବୁ ନିୟମରେ ଯାଞ୍ଚ କରିବାକୁ ଏକ ସଂଖ୍ୟା ଦିଅ।',
    descHi:
        'भाग किए बिना जानने की आसान जाँच कि कोई संख्या पूर्णतः विभाजित होती है या नहीं। सभी नियमों से जाँचने के लिए संख्या डालें।',
    inputs: [FormulaInput('n', 'Whole number (e.g. 2376)')],
    compute: _divisibility,
  ),
  FormulaData(
    id: 'roman-numerals',
    titleEn: 'Roman Numerals',
    titleOr: 'ରୋମାନ ସଂଖ୍ୟା',
    titleHi: 'रोमन अंक',
    formula: 'I = 1, V = 5, X = 10, L = 50, C = 100, D = 500, M = 1000',
    category: _c,
    descEn:
        'Seven letters make every Roman numeral. A smaller letter before a larger one is subtracted (IV = 4, IX = 9, XL = 40). Enter a number from 1 to 3999.',
    descOr:
        'ସାତୋଟି ଅକ୍ଷରରେ ସବୁ ରୋମାନ ସଂଖ୍ୟା ହୁଏ। ବଡ଼ ଅକ୍ଷର ପୂର୍ବରେ ଛୋଟ ଅକ୍ଷର ଥିଲେ ବିୟୋଗ ହୁଏ (IV = 4, IX = 9, XL = 40)। 1 ରୁ 3999 ମଧ୍ୟରେ ଏକ ସଂଖ୍ୟା ଦିଅ।',
    descHi:
        'सात अक्षरों से सभी रोमन अंक बनते हैं। बड़े अक्षर से पहले छोटा अक्षर हो तो घटाया जाता है (IV = 4, IX = 9, XL = 40)। 1 से 3999 के बीच संख्या डालें।',
    inputs: [FormulaInput('n', 'Number, 1 to 3999 (e.g. 2024)')],
    compute: _roman,
  ),
  FormulaData(
    id: 'bodmas',
    titleEn: 'BODMAS (Order of Operations)',
    titleOr: 'BODMAS (କ୍ରିୟାର କ୍ରମ)',
    titleHi: 'BODMAS (संक्रियाओं का क्रम)',
    formula: '''B  Brackets  ( )
O  Orders  (powers and roots)
D  Division  ÷
M  Multiplication  ×
A  Addition  +
S  Subtraction  −''',
    category: _c,
    descEn:
        'Always work in this order. Division and multiplication have equal rank, as do addition and subtraction: do those from left to right. Example: 8 + 2 × 5 = 18, not 50.',
    descOr:
        'ସର୍ବଦା ଏହି କ୍ରମରେ କର। ଭାଗ ଓ ଗୁଣନର ସମାନ ମର୍ଯ୍ୟାଦା, ସେହିପରି ଯୋଗ ଓ ବିୟୋଗର ମଧ୍ୟ: ଏଗୁଡ଼ିକୁ ବାମରୁ ଡାହାଣକୁ କର। ଉଦାହରଣ: 8 + 2 × 5 = 18, 50 ନୁହେଁ।',
    descHi:
        'हमेशा इसी क्रम में हल करें। भाग और गुणा का दर्जा बराबर है, वैसे ही जोड़ और घटाव का: इन्हें बाएँ से दाएँ करें। उदाहरण: 8 + 2 × 5 = 18, 50 नहीं।',
  ),
  FormulaData(
    id: 'place-value',
    titleEn: 'Place Value',
    titleOr: 'ସ୍ଥାନୀୟ ମୂଲ୍ୟ',
    titleHi: 'स्थानीय मान',
    formula:
        'Ones · Tens · Hundreds · Thousands · Ten-Thousands · Lakhs · Ten-Lakhs · Crores',
    category: _c,
    descEn:
        'The value of a digit depends on its place. In 4,56,789 the digit 5 is in the ten-thousands place, so its value is 50,000. Enter a number to see each digit’s value.',
    descOr:
        'ଅଙ୍କର ମୂଲ୍ୟ ତାର ସ୍ଥାନ ଉପରେ ନିର୍ଭର କରେ। 4,56,789 ରେ ଅଙ୍କ 5 ଅଯୁତ ସ୍ଥାନରେ, ତେଣୁ ତାର ମୂଲ୍ୟ 50,000। ପ୍ରତ୍ୟେକ ଅଙ୍କର ମୂଲ୍ୟ ଦେଖିବାକୁ ଏକ ସଂଖ୍ୟା ଦିଅ।',
    descHi:
        'अंक का मान उसके स्थान पर निर्भर करता है। 4,56,789 में अंक 5 दस हज़ार के स्थान पर है, इसलिए उसका मान 50,000 है। हर अंक का मान देखने के लिए संख्या डालें।',
    inputs: [FormulaInput('n', 'Whole number (e.g. 456789)')],
    compute: _placeValue,
  ),
  FormulaData(
    id: 'squares-cubes',
    titleEn: 'Squares & Cubes',
    titleOr: 'ବର୍ଗ ଓ ଘନ',
    titleHi: 'वर्ग और घन',
    formula: 'n² = n × n,   n³ = n × n × n',
    category: _c,
    descEn:
        'The square of a number is the number multiplied by itself; the cube multiplies it three times. Also shows the square root and cube root when they come out whole.',
    descOr:
        'ସଂଖ୍ୟାର ବର୍ଗ ହେଉଛି ତାକୁ ନିଜ ସହ ଗୁଣିବା; ଘନ ହେଉଛି ତିନିଥର ଗୁଣିବା। ବର୍ଗମୂଳ ଓ ଘନମୂଳ ପୂର୍ଣ୍ଣ ସଂଖ୍ୟା ହେଲେ ତାହା ମଧ୍ୟ ଦେଖାଏ।',
    descHi:
        'किसी संख्या का वर्ग उसे स्वयं से गुणा करना है; घन उसे तीन बार गुणा करना है। वर्गमूल और घनमूल पूर्ण संख्या हों तो वे भी दिखाता है।',
    inputs: [FormulaInput('n', 'Number (e.g. 12)')],
    compute: _squaresCubes,
  ),
];

// ─── Calculators ──────────────────────────────────────────────────────────────

String? _simpleInterest(FormulaValues v) {
  final p = v.n('P'), r = v.n('R'), t = v.n('T');
  if (p == null || r == null || t == null) return null;
  return 'SI = ${fx((p * r * t) / 100)}';
}

String? _compoundInterest(FormulaValues v) {
  final p = v.n('P'), r = v.n('R'), t = v.n('T');
  if (p == null || r == null || t == null) return null;
  final amount = p * pow(1 + r / 100, t);
  return 'A = ${fx(amount)}, CI = ${fx(amount - p)}';
}

String? _percentage(FormulaValues v) {
  final value = v.n('Value'), total = v.n('Total');
  if (value == null || total == null || total == 0) return null;
  return '${fx(value / total * 100)}%';
}

String? _average(FormulaValues v) {
  final xs = v.list('x');
  if (xs == null) return null;
  return 'Mean = ${nice(xs.reduce((a, b) => a + b) / xs.length)}';
}

String? _profitPercent(FormulaValues v) {
  final cp = v.n('CP'), sp = v.n('SP');
  if (cp == null || sp == null || cp == 0) return null;
  return 'Profit % = ${fx((sp - cp) / cp * 100)}%';
}

String? _lossPercent(FormulaValues v) {
  final cp = v.n('CP'), sp = v.n('SP');
  if (cp == null || sp == null || cp == 0) return null;
  return 'Loss % = ${fx((cp - sp) / cp * 100)}%';
}

String? _discount(FormulaValues v) {
  final mp = v.n('MP'), d = v.n('D');
  if (mp == null || d == null) return null;
  final off = mp * d / 100;
  return 'Discount = ${fx(off)}, SP = ${fx(mp - off)}';
}

String? _percentChange(FormulaValues v) {
  final oldV = v.n('Old'), newV = v.n('New');
  if (oldV == null || newV == null || oldV == 0) return null;
  final change = (newV - oldV) / oldV * 100;
  final word = change >= 0 ? 'Increase' : 'Decrease';
  return '$word = ${fx(change.abs())}%';
}

String? _ratioShare(FormulaValues v) {
  final n = v.n('N'), a = v.n('a'), b = v.n('b');
  if (n == null || a == null || b == null || a + b == 0) return null;
  return 'Share₁ = ${nice(n * a / (a + b))}, Share₂ = ${nice(n * b / (a + b))}';
}

String? _unitary(FormulaValues v) {
  final n = v.n('n'), cost = v.n('Cost'), m = v.n('m');
  if (n == null || cost == null || m == null || n == 0) return null;
  return 'One = ${nice(cost / n)}, Cost of m = ${nice(cost / n * m)}';
}

String? _hcfLcm(FormulaValues v) {
  final a = v.n('a'), b = v.n('b');
  if (a == null || b == null) return null;
  if (a <= 0 || b <= 0 || a != a.roundToDouble() || b != b.roundToDouble()) {
    return 'Enter two positive whole numbers';
  }
  final x = a.toInt(), y = b.toInt();
  final h = _gcd(x, y);
  return 'HCF = $h, LCM = ${x ~/ h * y}';
}

int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);

String? _wholeNumber(FormulaValues v) {
  final n = v.n('n');
  if (n == null || n < 0 || n != n.roundToDouble() || n > 999999999999) {
    return null;
  }
  return n.toString();
}

String? _divisibility(FormulaValues v) {
  final text = _wholeNumber(v);
  if (text == null) return null;
  final n = int.parse(text.replaceAll(RegExp(r'\.0$'), ''));
  final by = [
    for (final d in [2, 3, 4, 5, 6, 8, 9, 10, 11])
      if (n % d == 0) d,
  ];
  return by.isEmpty
      ? '$n is not divisible by 2, 3, 4, 5, 6, 8, 9, 10 or 11'
      : '$n is divisible by ${by.join(', ')}';
}

String? _roman(FormulaValues v) {
  final n = v.n('n');
  if (n == null || n != n.roundToDouble()) return null;
  if (n < 1 || n > 3999) return 'Enter a number from 1 to 3999';
  const table = [
    (1000, 'M'),
    (900, 'CM'),
    (500, 'D'),
    (400, 'CD'),
    (100, 'C'),
    (90, 'XC'),
    (50, 'L'),
    (40, 'XL'),
    (10, 'X'),
    (9, 'IX'),
    (5, 'V'),
    (4, 'IV'),
    (1, 'I'),
  ];
  var left = n.toInt();
  final out = StringBuffer();
  for (final (value, symbol) in table) {
    while (left >= value) {
      out.write(symbol);
      left -= value;
    }
  }
  return '${nice(n)} = $out';
}

String? _placeValue(FormulaValues v) {
  final text = _wholeNumber(v);
  if (text == null) return null;
  final digits = text.replaceAll(RegExp(r'\.0$'), '');
  final parts = <String>[];
  for (var i = 0; i < digits.length; i++) {
    final d = int.parse(digits[i]);
    if (d == 0) continue;
    final value = d * pow(10, digits.length - 1 - i).toInt();
    parts.add('$d → $value');
  }
  return parts.isEmpty ? '0' : parts.join(',  ');
}

String? _squaresCubes(FormulaValues v) {
  final n = v.n('n');
  if (n == null) return null;
  final out = StringBuffer('n² = ${nice(n * n)}, n³ = ${nice(n * n * n)}');
  if (n >= 0) {
    final sq = sqrt(n), cb = pow(n, 1 / 3).toDouble();
    if ((sq - sq.roundToDouble()).abs() < 1e-9) {
      out.write(', √n = ${nice(sq)}');
    }
    if ((cb - cb.roundToDouble()).abs() < 1e-9) {
      out.write(', ∛n = ${nice(cb)}');
    }
  }
  return out.toString();
}
