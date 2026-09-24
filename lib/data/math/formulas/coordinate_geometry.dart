import 'dart:math';

import 'formula_models.dart';

// ─── Coordinate geometry (Classes 9–10) ───────────────────────────────────────

const _c = 'Coordinate Geometry';

const _twoPoints = [
  FormulaInput('x₁', 'x of point 1 (e.g. 1)'),
  FormulaInput('y₁', 'y of point 1 (e.g. 2)'),
  FormulaInput('x₂', 'x of point 2 (e.g. 4)'),
  FormulaInput('y₂', 'y of point 2 (e.g. 6)'),
];

const coordinateGeometryFormulas = <FormulaData>[
  FormulaData(
    id: 'distance-formula',
    titleEn: 'Distance Formula',
    titleOr: 'ଦୂରତା ସୂତ୍ର',
    titleHi: 'दूरी सूत्र',
    formula: 'd = √((x₂ − x₁)² + (y₂ − y₁)²)',
    category: _c,
    descEn: 'The distance between two points on a graph.',
    descOr: 'ଗ୍ରାଫ୍ ଉପରେ ଦୁଇଟି ବିନ୍ଦୁ ମଧ୍ୟରେ ଦୂରତା।',
    descHi: 'ग्राफ़ पर दो बिंदुओं के बीच की दूरी।',
    inputs: _twoPoints,
    compute: _distance,
  ),
  FormulaData(
    id: 'midpoint-formula',
    titleEn: 'Midpoint Formula',
    titleOr: 'ମଧ୍ୟବିନ୍ଦୁ ସୂତ୍ର',
    titleHi: 'मध्यबिंदु सूत्र',
    formula: 'M = ((x₁ + x₂) / 2, (y₁ + y₂) / 2)',
    category: _c,
    descEn: 'The point exactly halfway between two points.',
    descOr: 'ଦୁଇଟି ବିନ୍ଦୁର ଠିକ୍ ମଝିରେ ଥିବା ବିନ୍ଦୁ।',
    descHi: 'दो बिंदुओं के ठीक बीच का बिंदु।',
    inputs: _twoPoints,
    compute: _midpoint,
  ),
  FormulaData(
    id: 'section-formula',
    titleEn: 'Section Formula',
    titleOr: 'ବିଭାଜନ ସୂତ୍ର',
    titleHi: 'विभाजन सूत्र',
    formula: 'P = ((m x₂ + n x₁) / (m + n), (m y₂ + n y₁) / (m + n))',
    category: _c,
    descEn:
        'The point that divides the line joining two points internally in the ratio m : n.',
    descOr:
        'ଦୁଇଟି ବିନ୍ଦୁକୁ ଯୋଡ଼ୁଥିବା ରେଖାକୁ m : n ଅନୁପାତରେ ଅନ୍ତଃବିଭାଜନ କରୁଥିବା ବିନ୍ଦୁ।',
    descHi:
        'दो बिंदुओं को मिलाने वाली रेखा को m : n के अनुपात में अंतः विभाजित करने वाला बिंदु।',
    inputs: [
      ..._twoPoints,
      FormulaInput('m', 'Ratio part m (e.g. 1)'),
      FormulaInput('n', 'Ratio part n (e.g. 2)'),
    ],
    compute: _section,
  ),
  FormulaData(
    id: 'slope',
    titleEn: 'Slope of a Line',
    titleOr: 'ରେଖାର ପ୍ରବଣତା',
    titleHi: 'रेखा की ढाल',
    formula: 'm = (y₂ − y₁) / (x₂ − x₁)',
    category: _c,
    descEn: 'How steep a line is: the rise in y divided by the run in x.',
    descOr: 'ରେଖା କେତେ ଢାଲୁ: y ର ବୃଦ୍ଧିକୁ x ର ପରିବର୍ତ୍ତନ ଦ୍ୱାରା ଭାଗ।',
    descHi: 'रेखा कितनी खड़ी है: y में वृद्धि को x में बदलाव से भाग।',
    inputs: _twoPoints,
    compute: _slope,
  ),
  FormulaData(
    id: 'triangle-area-coordinates',
    titleEn: 'Area of Triangle (Vertices)',
    titleOr: 'ତ୍ରିଭୁଜର କ୍ଷେତ୍ରଫଳ (ଶୀର୍ଷବିନ୍ଦୁ)',
    titleHi: 'त्रिभुज का क्षेत्रफल (शीर्ष)',
    formula: 'A = ½ |x₁(y₂ − y₃) + x₂(y₃ − y₁) + x₃(y₁ − y₂)|',
    category: _c,
    descEn:
        'The area of a triangle from the coordinates of its three corners. An area of 0 means the points lie on one line.',
    descOr:
        'ତିନୋଟି କୋଣର ସ୍ଥାନାଙ୍କରୁ ତ୍ରିଭୁଜର କ୍ଷେତ୍ରଫଳ। କ୍ଷେତ୍ରଫଳ 0 ହେଲେ ବିନ୍ଦୁଗୁଡ଼ିକ ଗୋଟିଏ ରେଖାରେ ଅଛନ୍ତି।',
    descHi:
        'तीनों शीर्षों के निर्देशांकों से त्रिभुज का क्षेत्रफल। क्षेत्रफल 0 का अर्थ है कि बिंदु एक ही रेखा पर हैं।',
    inputs: [
      ..._twoPoints,
      FormulaInput('x₃', 'x of point 3 (e.g. 5)'),
      FormulaInput('y₃', 'y of point 3 (e.g. 1)'),
    ],
    compute: _triangleArea,
  ),
];

// ─── Calculators ──────────────────────────────────────────────────────────────

({double x1, double y1, double x2, double y2})? _points(FormulaValues v) {
  final x1 = v.n('x₁'), y1 = v.n('y₁'), x2 = v.n('x₂'), y2 = v.n('y₂');
  if (x1 == null || y1 == null || x2 == null || y2 == null) return null;
  return (x1: x1, y1: y1, x2: x2, y2: y2);
}

String? _distance(FormulaValues v) {
  final p = _points(v);
  if (p == null) return null;
  return 'd = ${nice(sqrt(pow(p.x2 - p.x1, 2) + pow(p.y2 - p.y1, 2)))}';
}

String? _midpoint(FormulaValues v) {
  final p = _points(v);
  if (p == null) return null;
  return 'M = (${nice((p.x1 + p.x2) / 2)}, ${nice((p.y1 + p.y2) / 2)})';
}

String? _section(FormulaValues v) {
  final p = _points(v), m = v.n('m'), n = v.n('n');
  if (p == null || m == null || n == null || m + n == 0) return null;
  final x = (m * p.x2 + n * p.x1) / (m + n);
  final y = (m * p.y2 + n * p.y1) / (m + n);
  return 'P = (${nice(x)}, ${nice(y)})';
}

String? _slope(FormulaValues v) {
  final p = _points(v);
  if (p == null) return null;
  if (p.x2 == p.x1) return 'Vertical line: slope is undefined';
  return 'm = ${nice((p.y2 - p.y1) / (p.x2 - p.x1))}';
}

String? _triangleArea(FormulaValues v) {
  final p = _points(v), x3 = v.n('x₃'), y3 = v.n('y₃');
  if (p == null || x3 == null || y3 == null) return null;
  final a =
      0.5 *
      (p.x1 * (p.y2 - y3) + p.x2 * (y3 - p.y1) + x3 * (p.y1 - p.y2)).abs();
  return a == 0 ? 'A = 0 (the points are collinear)' : 'A = ${nice(a)}';
}
