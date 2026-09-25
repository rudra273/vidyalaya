import 'formula_models.dart';

// ─── Statistics & probability (Classes 6–10) ──────────────────────────────────
//
// The plain mean lives in Arithmetic ("Average (Mean)"), which already accepts
// a list of numbers.

const _c = 'Statistics & Probability';

const _data = [
  FormulaInput(
    'x',
    'Numbers, comma-separated (e.g. 3, 7, 7, 2, 9)',
    isList: true,
  ),
];

const statisticsFormulas = <FormulaData>[
  FormulaData(
    id: 'median',
    titleEn: 'Median',
    titleOr: 'ମଧ୍ୟମା',
    titleHi: 'माध्यिका',
    formula: 'Middle value of the data arranged in order',
    category: _c,
    descEn:
        'Arrange the data in order. With an odd count, the median is the middle value; with an even count, it is the mean of the two middle values.',
    descOr:
        'ତଥ୍ୟକୁ କ୍ରମରେ ସଜାଅ। ସଂଖ୍ୟା ଅଯୁଗ୍ମ ହେଲେ ମଝି ମାନଟି ମଧ୍ୟମା; ଯୁଗ୍ମ ହେଲେ ମଝିର ଦୁଇଟି ମାନର ହାରାହାରି।',
    descHi:
        'आँकड़ों को क्रम में रखें। संख्या विषम हो तो बीच का मान माध्यिका है; सम हो तो बीच के दो मानों का माध्य।',
    inputs: _data,
    compute: _median,
  ),
  FormulaData(
    id: 'mode',
    titleEn: 'Mode',
    titleOr: 'ବହୁଳକ',
    titleHi: 'बहुलक',
    formula: 'The value that occurs most often',
    category: _c,
    descEn: 'The value that appears the greatest number of times in the data.',
    descOr: 'ତଥ୍ୟରେ ସବୁଠାରୁ ଅଧିକ ଥର ଆସୁଥିବା ମାନ।',
    descHi: 'आँकड़ों में सबसे अधिक बार आने वाला मान।',
    inputs: _data,
    compute: _mode,
  ),
  FormulaData(
    id: 'range',
    titleEn: 'Range',
    titleOr: 'ପରିସର',
    titleHi: 'परिसर',
    formula: 'Range = Highest − Lowest',
    category: _c,
    descEn: 'How spread out the data is: the largest value minus the smallest.',
    descOr: 'ତଥ୍ୟ କେତେ ବିସ୍ତୃତ: ସର୍ବୋଚ୍ଚ ମାନରୁ ସର୍ବନିମ୍ନ ମାନ ବିୟୋଗ।',
    descHi: 'आँकड़े कितने फैले हैं: सबसे बड़े मान में से सबसे छोटा मान घटाएँ।',
    inputs: _data,
    compute: _range,
  ),
  FormulaData(
    id: 'grouped-mean',
    titleEn: 'Mean of Grouped Data',
    titleOr: 'ବର୍ଗୀକୃତ ତଥ୍ୟର ହାରାହାରି',
    titleHi: 'वर्गीकृत आँकड़ों का माध्य',
    formula: 'x̄ = Σ fᵢxᵢ / Σ fᵢ',
    category: _c,
    descEn:
        'Direct method: multiply each value (or class mark) by its frequency, add them, and divide by the total frequency.',
    descOr:
        'ପ୍ରତ୍ୟକ୍ଷ ପଦ୍ଧତି: ପ୍ରତ୍ୟେକ ମାନ (ବା ବର୍ଗ ଚିହ୍ନ) କୁ ତାର ବାରମ୍ବାରତା ସହ ଗୁଣି ଯୋଗ କର, ତାପରେ ମୋଟ ବାରମ୍ବାରତା ଦ୍ୱାରା ଭାଗ କର।',
    descHi:
        'प्रत्यक्ष विधि: हर मान (या वर्ग चिह्न) को उसकी बारंबारता से गुणा करके जोड़ें, फिर कुल बारंबारता से भाग दें।',
    inputs: [
      FormulaInput('x', 'Values / class marks (e.g. 5, 15, 25)', isList: true),
      FormulaInput('f', 'Frequencies (e.g. 2, 3, 5)', isList: true),
    ],
    compute: _groupedMean,
  ),
  FormulaData(
    id: 'probability',
    titleEn: 'Probability of an Event',
    titleOr: 'ଏକ ଘଟଣାର ସମ୍ଭାବ୍ୟତା',
    titleHi: 'किसी घटना की प्रायिकता',
    formula: 'P(E) = favourable outcomes / total outcomes',
    category: _c,
    descEn:
        'How likely an event is, from 0 (impossible) to 1 (certain). P(not E) = 1 − P(E).',
    descOr:
        'ଏକ ଘଟଣା କେତେ ସମ୍ଭବ, 0 (ଅସମ୍ଭବ) ରୁ 1 (ନିଶ୍ଚିତ) ପର୍ଯ୍ୟନ୍ତ। P(E ନୁହେଁ) = 1 − P(E)।',
    descHi:
        'कोई घटना कितनी संभावित है, 0 (असंभव) से 1 (निश्चित) तक। P(E नहीं) = 1 − P(E)।',
    inputs: [
      FormulaInput('Fav', 'Favourable outcomes (e.g. 1)'),
      FormulaInput('Total', 'Total outcomes (e.g. 6)'),
    ],
    compute: _probability,
  ),
];

// ─── Calculators ──────────────────────────────────────────────────────────────

String? _median(FormulaValues v) {
  final xs = v.list('x');
  if (xs == null) return null;
  final s = [...xs]..sort();
  final mid = s.length ~/ 2;
  final median = s.length.isOdd ? s[mid] : (s[mid - 1] + s[mid]) / 2;
  return 'Median = ${nice(median)}';
}

String? _mode(FormulaValues v) {
  final xs = v.list('x');
  if (xs == null) return null;
  final counts = <double, int>{};
  for (final x in xs) {
    counts[x] = (counts[x] ?? 0) + 1;
  }
  final top = counts.values.reduce((a, b) => a > b ? a : b);
  if (top == 1) return 'No mode (every value appears once)';
  final modes = [
    for (final e in counts.entries)
      if (e.value == top) e.key,
  ]..sort();
  return 'Mode = ${modes.map(nice).join(', ')} (appears $top times)';
}

String? _range(FormulaValues v) {
  final xs = v.list('x');
  if (xs == null) return null;
  final hi = xs.reduce((a, b) => a > b ? a : b);
  final lo = xs.reduce((a, b) => a < b ? a : b);
  return 'Range = ${nice(hi)} − ${nice(lo)} = ${nice(hi - lo)}';
}

String? _groupedMean(FormulaValues v) {
  final xs = v.list('x'), fs = v.list('f');
  if (xs == null || fs == null) return null;
  if (xs.length != fs.length) return 'Enter one frequency for each value';
  final sumF = fs.reduce((a, b) => a + b);
  if (sumF == 0) return null;
  var sumFx = 0.0;
  for (var i = 0; i < xs.length; i++) {
    sumFx += xs[i] * fs[i];
  }
  return 'Σfx = ${nice(sumFx)}, Σf = ${nice(sumF)}, x̄ = ${nice(sumFx / sumF)}';
}

String? _probability(FormulaValues v) {
  final fav = v.n('Fav'), total = v.n('Total');
  if (fav == null || total == null || total <= 0) return null;
  if (fav < 0 || fav > total) {
    return 'Favourable outcomes must be between 0 and the total';
  }
  final p = fav / total;
  return 'P(E) = ${nice(p)}, P(not E) = ${nice(1 - p)}';
}
