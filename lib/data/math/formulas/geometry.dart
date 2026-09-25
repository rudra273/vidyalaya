import 'dart:math';

import 'formula_models.dart';

// ─── Geometry & mensuration ───────────────────────────────────────────────────

const _c = 'Geometry';

const _side = [FormulaInput('a', 'Side length (e.g. 4)')];

const _lw = [
  FormulaInput('l', 'Length (e.g. 5)'),
  FormulaInput('w', 'Width (e.g. 3)'),
];

const _lwh = [
  FormulaInput('l', 'Length (e.g. 5)'),
  FormulaInput('w', 'Width (e.g. 3)'),
  FormulaInput('h', 'Height (e.g. 2)'),
];

const _rh = [
  FormulaInput('r', 'Radius (e.g. 3)'),
  FormulaInput('h', 'Height (e.g. 10)'),
];

const _r = [FormulaInput('r', 'Radius (e.g. 7)')];

const geometryFormulas = <FormulaData>[
  FormulaData(
    id: 'circle-area',
    titleEn: 'Area of a Circle',
    titleOr: 'ବୃତ୍ତର କ୍ଷେତ୍ରଫଳ',
    titleHi: 'वृत्त का क्षेत्रफल',
    formula: 'A = πr²',
    category: _c,
    descEn: 'Calculates the total 2D space enclosed within a circle.',
    descOr: 'ଏକ ବୃତ୍ତ ମଧ୍ୟରେ ଥିବା ସମୁଦାୟ ସ୍ଥାନ ବା କ୍ଷେତ୍ରଫଳ ହିସାବ କରେ।',
    descHi: 'एक वृत्त के भीतर घिरे कुल द्वि-आयामी क्षेत्रफल की गणना करता है।',
    inputs: [FormulaInput('r', 'Radius (e.g. 5)')],
    compute: _circleArea,
    diagram: FormulaDiagram.circle,
  ),
  FormulaData(
    id: 'circle-circumference',
    titleEn: 'Circumference of Circle',
    titleOr: 'ବୃତ୍ତର ପରିଧି',
    titleHi: 'वृत्त की परिधि',
    formula: 'C = 2πr',
    category: _c,
    descEn: 'Calculates the total length of the outer boundary of a circle.',
    descOr: 'ଏକ ବୃତ୍ତର ଚାରିପାଖର ସମୁଦାୟ ଦୈର୍ଘ୍ୟ ବା ପରିଧି ହିସାବ କରେ।',
    descHi: 'एक वृत्त की बाहरी सीमा की कुल लंबाई या परिधि की गणना करता है।',
    inputs: [FormulaInput('r', 'Radius (e.g. 5)')],
    compute: _circleCircumference,
    diagram: FormulaDiagram.circle,
  ),
  FormulaData(
    id: 'pythagoras',
    titleEn: 'Pythagorean Theorem',
    titleOr: 'ପିଥାଗୋରାସ୍ ଉପପାଦ୍ୟ',
    titleHi: 'पाइथागोरस प्रमेय',
    formula: 'c = √(a² + b²)',
    category: _c,
    descEn: 'Finds the longest side (hypotenuse) of a right-angled triangle.',
    descOr: 'ଏକ ସମକୋଣୀ ତ୍ରିଭୁଜର ସବୁଠାରୁ ବଡ଼ ବାହୁ (କର୍ଣ୍ଣ) ନିର୍ଣ୍ଣୟ କରେ।',
    descHi: 'एक समकोण त्रिभुज की सबसे लंबी भुजा (कर्ण) ज्ञात करता है।',
    inputs: [
      FormulaInput('a', 'Side a (e.g. 3)'),
      FormulaInput('b', 'Side b (e.g. 4)'),
    ],
    compute: _pythagoras,
    diagram: FormulaDiagram.rightTriangle,
  ),
  FormulaData(
    id: 'cylinder-volume',
    titleEn: 'Volume of a Cylinder',
    titleOr: 'ସିଲିଣ୍ଡରର ଆୟତନ',
    titleHi: 'बेलन का आयतन',
    formula: 'V = πr²h',
    category: _c,
    descEn: 'Calculates the total 3D space occupied by a cylinder.',
    descOr: 'ଏକ ସିଲିଣ୍ଡର ଦ୍ୱାରା ଅଧିକାର କରାଯାଇଥିବା ସମୁଦାୟ ଆୟତନ ହିସାବ କରେ।',
    descHi: 'एक बेलन द्वारा घेरे गए कुल त्रि-आयामी आयतन की गणना करता है।',
    inputs: _rh,
    compute: _cylinderVolume,
    diagram: FormulaDiagram.cylinder,
  ),
  FormulaData(
    id: 'rectangle-perimeter',
    titleEn: 'Perimeter of Rectangle',
    titleOr: 'ଆୟତକ୍ଷେତ୍ରର ପରିସୀମା',
    titleHi: 'आयत की परिमिति',
    formula: 'P = 2(l + w)',
    category: _c,
    descEn: 'Calculates the total length of the outer boundary of a rectangle.',
    descOr: 'ଏକ ଆୟତକ୍ଷେତ୍ରର ଚାରିପାଖର ସମୁଦାୟ ଦୈର୍ଘ୍ୟ ବା ପରିସୀମା ହିସାବ କରେ।',
    descHi: 'एक आयत की बाहरी सीमा की कुल लंबाई या परिमिति की गणना करता है।',
    inputs: _lw,
    compute: _rectanglePerimeter,
    diagram: FormulaDiagram.rectangle,
  ),
  FormulaData(
    id: 'rectangle-area',
    titleEn: 'Area of Rectangle',
    titleOr: 'ଆୟତକ୍ଷେତ୍ରର କ୍ଷେତ୍ରଫଳ',
    titleHi: 'आयत का क्षेत्रफल',
    formula: 'A = l × w',
    category: _c,
    descEn: 'Calculates the 2D surface area of a rectangle.',
    descOr: 'ଏକ ଆୟତକ୍ଷେତ୍ରର ପୃଷ୍ଠତଳର ସମୁଦାୟ କ୍ଷେତ୍ରଫଳ ହିସାବ କରେ।',
    descHi: 'एक आयत के द्वि-आयामी पृष्ठीय क्षेत्रफल की गणना करता है।',
    inputs: _lw,
    compute: _rectangleArea,
    diagram: FormulaDiagram.rectangle,
  ),
  FormulaData(
    id: 'square-perimeter',
    titleEn: 'Perimeter of Square',
    titleOr: 'ବର୍ଗକ୍ଷେତ୍ରର ପରିସୀମା',
    titleHi: 'वर्ग की परिमिति',
    formula: 'P = 4a',
    category: _c,
    descEn: 'Calculates the total boundary length of a square.',
    descOr: 'ଏକ ବର୍ଗକ୍ଷେତ୍ରର ଚାରିପାଖର ସମୁଦାୟ ଦୈର୍ଘ୍ୟ ହିସାବ କରେ।',
    descHi: 'एक वर्ग की कुल सीमा लंबाई की गणना करता है।',
    inputs: _side,
    compute: _squarePerimeter,
    diagram: FormulaDiagram.square,
  ),
  FormulaData(
    id: 'square-area',
    titleEn: 'Area of Square',
    titleOr: 'ବର୍ଗକ୍ଷେତ୍ରର କ୍ଷେତ୍ରଫଳ',
    titleHi: 'वर्ग का क्षेत्रफल',
    formula: 'A = a²',
    category: _c,
    descEn: 'Calculates the surface area enclosed by a square.',
    descOr: 'ଏକ ବର୍ଗକ୍ଷେତ୍ର ମଧ୍ୟରେ ଥିବା ସମୁଦାୟ କ୍ଷେତ୍ରଫଳ ହିସାବ କରେ।',
    descHi: 'एक वर्ग के भीतर घिरे क्षेत्रफल की गणना करता है।',
    inputs: _side,
    compute: _squareArea,
    diagram: FormulaDiagram.square,
  ),
  FormulaData(
    id: 'triangle-area',
    titleEn: 'Area of Triangle',
    titleOr: 'ତ୍ରିଭୁଜର କ୍ଷେତ୍ରଫଳ',
    titleHi: 'त्रिभुज का क्षेत्रफल',
    formula: 'A = ½ × b × h',
    category: _c,
    descEn:
        'Calculates the space enclosed by a triangle using its base and height.',
    descOr: 'ଭୂମି ଏବଂ ଉଚ୍ଚତା ବ୍ୟବହାର କରି ଏକ ତ୍ରିଭୁଜର କ୍ଷେତ୍ରଫଳ ହିସାବ କରେ।',
    descHi:
        'आधार और ऊँचाई का उपयोग करके एक त्रिभुज के क्षेत्रफल की गणना करता है।',
    inputs: [
      FormulaInput('b', 'Base (e.g. 10)'),
      FormulaInput('h', 'Height (e.g. 5)'),
    ],
    compute: _triangleArea,
    diagram: FormulaDiagram.triangle,
  ),
  FormulaData(
    id: 'cube-volume',
    titleEn: 'Volume of Cube',
    titleOr: 'ଘନର ଆୟତନ',
    titleHi: 'घन का आयतन',
    formula: 'V = a³',
    category: _c,
    descEn: 'Calculates the total 3D space occupied by a cube.',
    descOr: 'ଏକ ଘନ (Cube) ର ସମୁଦାୟ ଆୟତନ ହିସାବ କରେ।',
    descHi: 'एक घन (Cube) द्वारा घेरे गए कुल आयतन की गणना करता है।',
    inputs: _side,
    compute: _cubeVolume,
    diagram: FormulaDiagram.cube,
  ),
  FormulaData(
    id: 'cuboid-volume',
    titleEn: 'Volume of Cuboid',
    titleOr: 'ଆୟତଘନର ଆୟତନ',
    titleHi: 'घनाभ का आयतन',
    formula: 'V = l × w × h',
    category: _c,
    descEn: 'Calculates the 3D space enclosed by a rectangular cuboid.',
    descOr: 'ଏକ ଆୟତଘନ (Cuboid) ର ସମୁଦାୟ ଆୟତନ ହିସାବ କରେ।',
    descHi: 'एक घनाभ (Cuboid) द्वारा घेरे गए कुल आयतन की गणना करता है।',
    inputs: _lwh,
    compute: _cuboidVolume,
    diagram: FormulaDiagram.cuboid,
  ),
  // ── Perimeter & area of plane figures ──
  FormulaData(
    id: 'triangle-perimeter',
    titleEn: 'Perimeter of Triangle',
    titleOr: 'ତ୍ରିଭୁଜର ପରିସୀମା',
    titleHi: 'त्रिभुज का परिमाप',
    formula: 'P = a + b + c',
    category: _c,
    descEn: 'Adds the lengths of the three sides of a triangle.',
    descOr: 'ତ୍ରିଭୁଜର ତିନୋଟି ବାହୁର ଦୈର୍ଘ୍ୟକୁ ଯୋଗ କରେ।',
    descHi: 'त्रिभुज की तीनों भुजाओं की लंबाई जोड़ता है।',
    inputs: _abc,
    compute: _trianglePerimeter,
    diagram: FormulaDiagram.triangle,
  ),
  FormulaData(
    id: 'herons-formula',
    titleEn: "Heron's Formula",
    titleOr: 'ହେରନଙ୍କ ସୂତ୍ର',
    titleHi: 'हीरोन का सूत्र',
    formula: 'A = √(s(s − a)(s − b)(s − c)),  s = (a + b + c) / 2',
    category: _c,
    descEn:
        'Finds the area of a triangle when all three sides are known, using the semi-perimeter s.',
    descOr:
        'ତିନୋଟି ବାହୁ ଜଣାଥିଲେ ଅର୍ଦ୍ଧପରିସୀମା s ବ୍ୟବହାର କରି ତ୍ରିଭୁଜର କ୍ଷେତ୍ରଫଳ ନିର୍ଣ୍ଣୟ କରେ।',
    descHi:
        'तीनों भुजाएँ ज्ञात होने पर अर्धपरिमाप s की सहायता से त्रिभुज का क्षेत्रफल ज्ञात करता है।',
    inputs: _abc,
    compute: _heron,
    diagram: FormulaDiagram.triangle,
  ),
  FormulaData(
    id: 'parallelogram-area',
    titleEn: 'Area of Parallelogram',
    titleOr: 'ସାମାନ୍ତରିକର କ୍ଷେତ୍ରଫଳ',
    titleHi: 'समांतर चतुर्भुज का क्षेत्रफल',
    formula: 'A = b × h',
    category: _c,
    descEn: 'Base times the perpendicular height of the parallelogram.',
    descOr: 'ସାମାନ୍ତରିକର ଭୂମି ଓ ଲମ୍ବ ଉଚ୍ଚତାର ଗୁଣଫଳ।',
    descHi: 'समांतर चतुर्भुज के आधार और लंबवत ऊँचाई का गुणनफल।',
    inputs: [
      FormulaInput('b', 'Base (e.g. 8)'),
      FormulaInput('h', 'Height (e.g. 5)'),
    ],
    compute: _parallelogram,
  ),
  FormulaData(
    id: 'trapezium-area',
    titleEn: 'Area of Trapezium',
    titleOr: 'ଟ୍ରାପିଜିୟମର କ୍ଷେତ୍ରଫଳ',
    titleHi: 'समलंब चतुर्भुज का क्षेत्रफल',
    formula: 'A = ½ × (a + b) × h',
    category: _c,
    descEn:
        'Half the sum of the two parallel sides, times the distance between them.',
    descOr: 'ଦୁଇ ସମାନ୍ତର ବାହୁର ଯୋଗଫଳର ଅଧା ଓ ସେଗୁଡ଼ିକ ମଧ୍ୟରେ ଦୂରତାର ଗୁଣଫଳ।',
    descHi: 'दो समांतर भुजाओं के योग का आधा, उनके बीच की दूरी से गुणा।',
    inputs: [
      FormulaInput('a', 'Parallel side a (e.g. 6)'),
      FormulaInput('b', 'Parallel side b (e.g. 10)'),
      FormulaInput('h', 'Height (e.g. 4)'),
    ],
    compute: _trapezium,
  ),
  FormulaData(
    id: 'rhombus-area',
    titleEn: 'Area of Rhombus',
    titleOr: 'ରମ୍ବସର କ୍ଷେତ୍ରଫଳ',
    titleHi: 'समचतुर्भुज का क्षेत्रफल',
    formula: 'A = ½ × d₁ × d₂',
    category: _c,
    descEn: 'Half the product of the two diagonals of a rhombus.',
    descOr: 'ରମ୍ବସର ଦୁଇଟି କର୍ଣ୍ଣର ଗୁଣଫଳର ଅଧା।',
    descHi: 'समचतुर्भुज के दोनों विकर्णों के गुणनफल का आधा।',
    inputs: [
      FormulaInput('d₁', 'Diagonal 1 (e.g. 6)'),
      FormulaInput('d₂', 'Diagonal 2 (e.g. 8)'),
    ],
    compute: _rhombus,
  ),
  FormulaData(
    id: 'sector-area',
    titleEn: 'Area of Sector',
    titleOr: 'ବୃତ୍ତଖଣ୍ଡର କ୍ଷେତ୍ରଫଳ',
    titleHi: 'त्रिज्यखंड का क्षेत्रफल',
    formula: 'A = (θ / 360) × πr²',
    category: _c,
    descEn:
        'The area of a slice of a circle with radius r and central angle θ.',
    descOr: 'ବ୍ୟାସାର୍ଦ୍ଧ r ଓ କେନ୍ଦ୍ରୀୟ କୋଣ θ ଥିବା ବୃତ୍ତର ଏକ ଖଣ୍ଡର କ୍ଷେତ୍ରଫଳ।',
    descHi:
        'त्रिज्या r और केंद्रीय कोण θ वाले वृत्त के एक टुकड़े का क्षेत्रफल।',
    inputs: [
      FormulaInput('r', 'Radius (e.g. 7)'),
      FormulaInput('θ (deg)', 'Angle in degrees (e.g. 60)'),
    ],
    compute: _sector,
    diagram: FormulaDiagram.circle,
  ),
  FormulaData(
    id: 'polygon-angle-sum',
    titleEn: 'Angle Sum of a Polygon',
    titleOr: 'ବହୁଭୁଜର କୋଣମାନଙ୍କର ସମଷ୍ଟି',
    titleHi: 'बहुभुज के कोणों का योग',
    formula: 'Sum = (n − 2) × 180°',
    category: _c,
    descEn:
        'The interior angles of a polygon with n sides add up to (n − 2) × 180°. Each angle of a regular polygon is that sum divided by n.',
    descOr:
        'n ବାହୁ ବିଶିଷ୍ଟ ବହୁଭୁଜର ଅନ୍ତଃକୋଣମାନଙ୍କର ସମଷ୍ଟି (n − 2) × 180°। ସୁଷମ ବହୁଭୁଜର ପ୍ରତ୍ୟେକ କୋଣ ଏହି ସମଷ୍ଟିକୁ n ଦ୍ୱାରା ଭାଗ କଲେ ମିଳେ।',
    descHi:
        'n भुजाओं वाले बहुभुज के अंतःकोणों का योग (n − 2) × 180° होता है। सम बहुभुज का प्रत्येक कोण इस योग को n से भाग देकर मिलता है।',
    inputs: [FormulaInput('n', 'Number of sides (e.g. 6)')],
    compute: _polygonAngles,
  ),

  // ── Surface area & volume of solids ──
  FormulaData(
    id: 'cube-surface-area',
    titleEn: 'Surface Area of Cube',
    titleOr: 'ଘନକର ପୃଷ୍ଠତଳର କ୍ଷେତ୍ରଫଳ',
    titleHi: 'घन का पृष्ठीय क्षेत्रफल',
    formula: 'TSA = 6a²,  LSA = 4a²',
    category: _c,
    descEn:
        'Total surface area covers all 6 faces; lateral surface area covers the 4 side faces.',
    descOr:
        'ସମ୍ପୂର୍ଣ୍ଣ ପୃଷ୍ଠତଳ 6ଟି ପାର୍ଶ୍ୱକୁ ଓ ପାର୍ଶ୍ୱୀୟ ପୃଷ୍ଠତଳ 4ଟି ପାର୍ଶ୍ୱ ମୁହଁକୁ ଧରେ।',
    descHi:
        'संपूर्ण पृष्ठीय क्षेत्रफल सभी 6 फलकों का और पार्श्व पृष्ठीय क्षेत्रफल 4 पार्श्व फलकों का होता है।',
    inputs: _side,
    compute: _cubeSurface,
    diagram: FormulaDiagram.cube,
  ),
  FormulaData(
    id: 'cuboid-surface-area',
    titleEn: 'Surface Area of Cuboid',
    titleOr: 'ଆୟତଘନର ପୃଷ୍ଠତଳର କ୍ଷେତ୍ରଫଳ',
    titleHi: 'घनाभ का पृष्ठीय क्षेत्रफल',
    formula: 'TSA = 2(lw + wh + hl),  LSA = 2h(l + w)',
    category: _c,
    descEn:
        'Total surface area of a box shape, and the area of its four walls.',
    descOr: 'ବାକ୍ସ ଆକୃତିର ସମ୍ପୂର୍ଣ୍ଣ ପୃଷ୍ଠତଳ ଓ ଏହାର ଚାରି କାନ୍ଥର କ୍ଷେତ୍ରଫଳ।',
    descHi:
        'डिब्बे जैसी आकृति का संपूर्ण पृष्ठीय क्षेत्रफल और उसकी चार दीवारों का क्षेत्रफल।',
    inputs: _lwh,
    compute: _cuboidSurface,
    diagram: FormulaDiagram.cuboid,
  ),
  FormulaData(
    id: 'cylinder-surface-area',
    titleEn: 'Surface Area of Cylinder',
    titleOr: 'ବେଲନର ପୃଷ୍ଠତଳର କ୍ଷେତ୍ରଫଳ',
    titleHi: 'बेलन का पृष्ठीय क्षेत्रफल',
    formula: 'CSA = 2πrh,  TSA = 2πr(r + h)',
    category: _c,
    descEn:
        'Curved surface area is the side of the cylinder; total adds the two circular ends.',
    descOr:
        'ବକ୍ର ପୃଷ୍ଠତଳ ବେଲନର ପାର୍ଶ୍ୱ; ସମ୍ପୂର୍ଣ୍ଣ ପୃଷ୍ଠତଳରେ ଦୁଇଟି ବୃତ୍ତାକାର ମୁହଁ ମଧ୍ୟ ଯୋଗ ହୁଏ।',
    descHi:
        'वक्र पृष्ठीय क्षेत्रफल बेलन की बगल की सतह है; संपूर्ण में दोनों वृत्ताकार सिरे भी जुड़ते हैं।',
    inputs: _rh,
    compute: _cylinderSurface,
    diagram: FormulaDiagram.cylinder,
  ),
  FormulaData(
    id: 'cone',
    titleEn: 'Cone',
    titleOr: 'ଶଙ୍କୁ',
    titleHi: 'शंकु',
    formula: 'l = √(r² + h²),  CSA = πrl,  V = ⅓πr²h',
    category: _c,
    descEn:
        'Slant height, curved surface area and volume of a right circular cone.',
    descOr: 'ଲମ୍ବ ବୃତ୍ତାକାର ଶଙ୍କୁର ତିର୍ଯ୍ୟକ ଉଚ୍ଚତା, ବକ୍ର ପୃଷ୍ଠତଳ ଓ ଆୟତନ।',
    descHi: 'लंब वृत्तीय शंकु की तिर्यक ऊँचाई, वक्र पृष्ठीय क्षेत्रफल और आयतन।',
    inputs: _rh,
    compute: _cone,
  ),
  FormulaData(
    id: 'sphere',
    titleEn: 'Sphere',
    titleOr: 'ଗୋଲକ',
    titleHi: 'गोला',
    formula: 'SA = 4πr²,  V = ⁴⁄₃πr³',
    category: _c,
    descEn: 'Surface area and volume of a ball-shaped solid.',
    descOr: 'ବଲ୍ ଆକୃତିର ଘନ ବସ୍ତୁର ପୃଷ୍ଠତଳ ଓ ଆୟତନ।',
    descHi: 'गेंद जैसी ठोस आकृति का पृष्ठीय क्षेत्रफल और आयतन।',
    inputs: _r,
    compute: _sphere,
    diagram: FormulaDiagram.circle,
  ),
  FormulaData(
    id: 'hemisphere',
    titleEn: 'Hemisphere',
    titleOr: 'ଅର୍ଦ୍ଧଗୋଲକ',
    titleHi: 'अर्धगोला',
    formula: 'CSA = 2πr²,  TSA = 3πr²,  V = ⅔πr³',
    category: _c,
    descEn:
        'Half a sphere: its curved surface, total surface (with the flat circle) and volume.',
    descOr:
        'ଗୋଲକର ଅଧା: ଏହାର ବକ୍ର ପୃଷ୍ଠତଳ, ସମ୍ପୂର୍ଣ୍ଣ ପୃଷ୍ଠତଳ (ସମତଳ ବୃତ୍ତ ସହ) ଓ ଆୟତନ।',
    descHi:
        'गोले का आधा भाग: इसका वक्र पृष्ठ, संपूर्ण पृष्ठ (समतल वृत्त सहित) और आयतन।',
    inputs: _r,
    compute: _hemisphere,
  ),
];

const _abc = [
  FormulaInput('a', 'Side a (e.g. 3)'),
  FormulaInput('b', 'Side b (e.g. 4)'),
  FormulaInput('c', 'Side c (e.g. 5)'),
];

// ─── Calculators ──────────────────────────────────────────────────────────────

String? _circleArea(FormulaValues v) {
  final r = v.n('r');
  return r == null ? null : 'A = ${fx(pi * r * r, 4)}';
}

String? _circleCircumference(FormulaValues v) {
  final r = v.n('r');
  return r == null ? null : 'C = ${fx(2 * pi * r, 4)}';
}

String? _pythagoras(FormulaValues v) {
  final a = v.n('a'), b = v.n('b');
  if (a == null || b == null) return null;
  return 'c = ${fx(sqrt((a * a) + (b * b)), 4)}';
}

String? _cylinderVolume(FormulaValues v) {
  final r = v.n('r'), h = v.n('h');
  if (r == null || h == null) return null;
  return 'V = ${fx(pi * r * r * h, 4)}';
}

String? _rectanglePerimeter(FormulaValues v) {
  final l = v.n('l'), w = v.n('w');
  if (l == null || w == null) return null;
  return 'P = ${fx(2 * (l + w))}';
}

String? _rectangleArea(FormulaValues v) {
  final l = v.n('l'), w = v.n('w');
  if (l == null || w == null) return null;
  return 'A = ${fx(l * w)}';
}

String? _squarePerimeter(FormulaValues v) {
  final a = v.n('a');
  return a == null ? null : 'P = ${fx(4 * a)}';
}

String? _squareArea(FormulaValues v) {
  final a = v.n('a');
  return a == null ? null : 'A = ${fx(a * a)}';
}

String? _triangleArea(FormulaValues v) {
  final b = v.n('b'), h = v.n('h');
  if (b == null || h == null) return null;
  return 'A = ${fx(0.5 * b * h)}';
}

String? _cubeVolume(FormulaValues v) {
  final a = v.n('a');
  return a == null ? null : 'V = ${fx(a * a * a)}';
}

String? _cuboidVolume(FormulaValues v) {
  final l = v.n('l'), w = v.n('w'), h = v.n('h');
  if (l == null || w == null || h == null) return null;
  return 'V = ${fx(l * w * h)}';
}

String? _trianglePerimeter(FormulaValues v) {
  final a = v.n('a'), b = v.n('b'), c = v.n('c');
  if (a == null || b == null || c == null) return null;
  return 'P = ${nice(a + b + c)}';
}

String? _heron(FormulaValues v) {
  final a = v.n('a'), b = v.n('b'), c = v.n('c');
  if (a == null || b == null || c == null) return null;
  if (a <= 0 || b <= 0 || c <= 0 || a + b <= c || b + c <= a || a + c <= b) {
    return 'These sides cannot form a triangle';
  }
  final s = (a + b + c) / 2;
  return 's = ${nice(s)}, A = ${nice(sqrt(s * (s - a) * (s - b) * (s - c)))}';
}

String? _parallelogram(FormulaValues v) {
  final b = v.n('b'), h = v.n('h');
  if (b == null || h == null) return null;
  return 'A = ${nice(b * h)}';
}

String? _trapezium(FormulaValues v) {
  final a = v.n('a'), b = v.n('b'), h = v.n('h');
  if (a == null || b == null || h == null) return null;
  return 'A = ${nice(0.5 * (a + b) * h)}';
}

String? _rhombus(FormulaValues v) {
  final d1 = v.n('d₁'), d2 = v.n('d₂');
  if (d1 == null || d2 == null) return null;
  return 'A = ${nice(0.5 * d1 * d2)}';
}

String? _sector(FormulaValues v) {
  final r = v.n('r'), deg = v.n('θ (deg)');
  if (r == null || deg == null) return null;
  return 'A = ${nice(deg / 360 * pi * r * r)}';
}

String? _polygonAngles(FormulaValues v) {
  final n = v.n('n');
  if (n == null) return null;
  if (n < 3 || n != n.roundToDouble()) return 'A polygon needs 3 or more sides';
  final sum = (n - 2) * 180;
  return 'Sum = ${nice(sum)}°, each (regular) = ${nice(sum / n)}°';
}

String? _cubeSurface(FormulaValues v) {
  final a = v.n('a');
  if (a == null) return null;
  return 'TSA = ${nice(6 * a * a)}, LSA = ${nice(4 * a * a)}';
}

String? _cuboidSurface(FormulaValues v) {
  final l = v.n('l'), w = v.n('w'), h = v.n('h');
  if (l == null || w == null || h == null) return null;
  return 'TSA = ${nice(2 * (l * w + w * h + h * l))}, '
      'LSA = ${nice(2 * h * (l + w))}';
}

String? _cylinderSurface(FormulaValues v) {
  final r = v.n('r'), h = v.n('h');
  if (r == null || h == null) return null;
  return 'CSA = ${nice(2 * pi * r * h)}, TSA = ${nice(2 * pi * r * (r + h))}';
}

String? _cone(FormulaValues v) {
  final r = v.n('r'), h = v.n('h');
  if (r == null || h == null) return null;
  final l = sqrt(r * r + h * h);
  return 'l = ${nice(l)}, CSA = ${nice(pi * r * l)}, '
      'V = ${nice(pi * r * r * h / 3)}';
}

String? _sphere(FormulaValues v) {
  final r = v.n('r');
  if (r == null) return null;
  return 'SA = ${nice(4 * pi * r * r)}, V = ${nice(4 / 3 * pi * pow(r, 3))}';
}

String? _hemisphere(FormulaValues v) {
  final r = v.n('r');
  if (r == null) return null;
  return 'CSA = ${nice(2 * pi * r * r)}, TSA = ${nice(3 * pi * r * r)}, '
      'V = ${nice(2 / 3 * pi * pow(r, 3))}';
}
