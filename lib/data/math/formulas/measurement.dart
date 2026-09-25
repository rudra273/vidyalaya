import 'formula_models.dart';

// ─── Measurement (Classes 3–6) ────────────────────────────────────────────────
//
// Unit converters: fill in any one field and the others are worked out.

const _c = 'Measurement';

const measurementFormulas = <FormulaData>[
  FormulaData(
    id: 'length-units',
    titleEn: 'Units of Length',
    titleOr: 'ଦୈର୍ଘ୍ୟର ଏକକ',
    titleHi: 'लंबाई की इकाइयाँ',
    formula: '1 km = 1000 m,  1 m = 100 cm,  1 cm = 10 mm',
    category: _c,
    descEn:
        'Converts between kilometres, metres, centimetres and millimetres. Fill in any one box.',
    descOr:
        'କିଲୋମିଟର, ମିଟର, ସେଣ୍ଟିମିଟର ଓ ମିଲିମିଟର ମଧ୍ୟରେ ପରିବର୍ତ୍ତନ କରେ। ଯେକୌଣସି ଗୋଟିଏ ଘର ପୂରଣ କର।',
    descHi:
        'किलोमीटर, मीटर, सेंटीमीटर और मिलीमीटर के बीच बदलता है। कोई एक खाना भरें।',
    inputs: [
      FormulaInput('km', 'Kilometres'),
      FormulaInput('m', 'Metres'),
      FormulaInput('cm', 'Centimetres'),
      FormulaInput('mm', 'Millimetres'),
    ],
    compute: _length,
  ),
  FormulaData(
    id: 'mass-units',
    titleEn: 'Units of Mass',
    titleOr: 'ବସ୍ତୁତ୍ୱର ଏକକ',
    titleHi: 'द्रव्यमान की इकाइयाँ',
    formula: '1 kg = 1000 g,  1 g = 1000 mg',
    category: _c,
    descEn:
        'Converts between kilograms, grams and milligrams. Fill in any one box.',
    descOr:
        'କିଲୋଗ୍ରାମ, ଗ୍ରାମ ଓ ମିଲିଗ୍ରାମ ମଧ୍ୟରେ ପରିବର୍ତ୍ତନ କରେ। ଯେକୌଣସି ଗୋଟିଏ ଘର ପୂରଣ କର।',
    descHi: 'किलोग्राम, ग्राम और मिलीग्राम के बीच बदलता है। कोई एक खाना भरें।',
    inputs: [
      FormulaInput('kg', 'Kilograms'),
      FormulaInput('g', 'Grams'),
      FormulaInput('mg', 'Milligrams'),
    ],
    compute: _mass,
  ),
  FormulaData(
    id: 'capacity-units',
    titleEn: 'Units of Capacity',
    titleOr: 'ଧାରଣ କ୍ଷମତାର ଏକକ',
    titleHi: 'धारिता की इकाइयाँ',
    formula: '1 L = 1000 mL',
    category: _c,
    descEn: 'Converts between litres and millilitres. Fill in either box.',
    descOr: 'ଲିଟର ଓ ମିଲିଲିଟର ମଧ୍ୟରେ ପରିବର୍ତ୍ତନ କରେ। ଯେକୌଣସି ଗୋଟିଏ ଘର ପୂରଣ କର।',
    descHi: 'लीटर और मिलीलीटर के बीच बदलता है। कोई एक खाना भरें।',
    inputs: [FormulaInput('L', 'Litres'), FormulaInput('mL', 'Millilitres')],
    compute: _capacity,
  ),
  FormulaData(
    id: 'time-units',
    titleEn: 'Units of Time',
    titleOr: 'ସମୟର ଏକକ',
    titleHi: 'समय की इकाइयाँ',
    formula: '1 h = 60 min,  1 min = 60 s',
    category: _c,
    descEn: 'Converts between hours, minutes and seconds. Fill in any one box.',
    descOr:
        'ଘଣ୍ଟା, ମିନିଟ ଓ ସେକେଣ୍ଡ ମଧ୍ୟରେ ପରିବର୍ତ୍ତନ କରେ। ଯେକୌଣସି ଗୋଟିଏ ଘର ପୂରଣ କର।',
    descHi: 'घंटे, मिनट और सेकंड के बीच बदलता है। कोई एक खाना भरें।',
    inputs: [
      FormulaInput('h', 'Hours'),
      FormulaInput('min', 'Minutes'),
      FormulaInput('s', 'Seconds'),
    ],
    compute: _time,
  ),
  FormulaData(
    id: 'money-units',
    titleEn: 'Rupees and Paise',
    titleOr: 'ଟଙ୍କା ଓ ପଇସା',
    titleHi: 'रुपये और पैसे',
    formula: '₹1 = 100 paise',
    category: _c,
    descEn: 'Converts between rupees and paise. Fill in either box.',
    descOr: 'ଟଙ୍କା ଓ ପଇସା ମଧ୍ୟରେ ପରିବର୍ତ୍ତନ କରେ। ଯେକୌଣସି ଗୋଟିଏ ଘର ପୂରଣ କର।',
    descHi: 'रुपये और पैसे के बीच बदलता है। कोई एक खाना भरें।',
    inputs: [FormulaInput('₹', 'Rupees'), FormulaInput('paise', 'Paise')],
    compute: _money,
  ),
];

// ─── Calculators ──────────────────────────────────────────────────────────────

/// [units] maps each input key to its size in the smallest unit. Exactly one
/// field must be filled; every unit is then shown.
String? _convert(FormulaValues v, Map<String, double> units) {
  final filled = [
    for (final u in units.keys)
      if (v.n(u) != null) u,
  ];
  if (filled.length != 1) return null;
  final base = v.n(filled.single)! * units[filled.single]!;
  return [
    for (final e in units.entries) '${nice(base / e.value, 6)} ${e.key}',
  ].join(' = ');
}

String? _length(FormulaValues v) =>
    _convert(v, const {'km': 1000000, 'm': 1000, 'cm': 10, 'mm': 1});

String? _mass(FormulaValues v) =>
    _convert(v, const {'kg': 1000000, 'g': 1000, 'mg': 1});

String? _capacity(FormulaValues v) => _convert(v, const {'L': 1000, 'mL': 1});

String? _time(FormulaValues v) =>
    _convert(v, const {'h': 3600, 'min': 60, 's': 1});

String? _money(FormulaValues v) => _convert(v, const {'₹': 100, 'paise': 1});
