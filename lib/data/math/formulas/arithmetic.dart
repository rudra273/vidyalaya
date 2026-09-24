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
