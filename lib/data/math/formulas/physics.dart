import 'dart:math';

import 'formula_models.dart';

// ─── Physics ──────────────────────────────────────────────────────────────────
//
// Formerly "Science". Units are SI; g is taken as 9.8 m/s², as in the textbooks.

const _c = 'Physics';

const _g = 9.8;

const physicsFormulas = <FormulaData>[
  FormulaData(
    id: 'speed',
    titleEn: 'Speed, Distance, Time',
    titleOr: 'ବେଗ, ଦୂରତା, ସମୟ',
    titleHi: 'चाल, दूरी, समय',
    formula: 's = d / t',
    category: _c,
    descEn:
        'Calculates the speed of an object based on distance traveled over time.',
    descOr: 'ଦୂରତା ଏବଂ ସମୟ ଉପରେ ଭିତ୍ତି କରି ଏକ ବସ୍ତୁର ବେଗ ହିସାବ କରେ।',
    descHi: 'दूरी और समय के आधार पर किसी वस्तु की चाल की गणना करता है।',
    inputs: [
      FormulaInput('d', 'Distance (e.g. 100)'),
      FormulaInput('t', 'Time (e.g. 2)'),
    ],
    compute: _speed,
  ),
  FormulaData(
    id: 'fahrenheit-to-celsius',
    titleEn: 'Fahrenheit to Celsius',
    titleOr: 'ଫାରେନହାଇଟରୁ ସେଲସିୟସ',
    titleHi: 'फारेनहाइट से सेल्सियस',
    formula: 'C = (F - 32) × 5/9',
    category: _c,
    descEn:
        'Converts temperature from the Fahrenheit scale to the Celsius scale.',
    descOr: 'ତାପମାତ୍ରାକୁ ଫାରେନହାଇଟ୍ ରୁ ସେଲସିୟସ୍ ସ୍କେଲ୍ କୁ ପରିବର୍ତ୍ତନ କରେ।',
    descHi:
        'तापमान को फारेनहाइट पैमाने से सेल्सियस पैमाने में परिवर्तित करता है।',
    inputs: [FormulaInput('F', 'Fahrenheit (e.g. 98.6)')],
    compute: _fToC,
  ),
  FormulaData(
    id: 'celsius-to-fahrenheit',
    titleEn: 'Celsius to Fahrenheit',
    titleOr: 'ସେଲସିୟସରୁ ଫାରେନହାଇଟ',
    titleHi: 'सेल्सियस से फारेनहाइट',
    formula: 'F = (C × 9/5) + 32',
    category: _c,
    descEn:
        'Converts temperature from the Celsius scale to the Fahrenheit scale.',
    descOr: 'ତାପମାତ୍ରାକୁ ସେଲସିୟସ୍ ରୁ ଫାରେନହାଇଟ୍ ସ୍କେଲ୍ କୁ ପରିବର୍ତ୍ତନ କରେ।',
    descHi:
        'तापमान को सेल्सियस पैमाने से फारेनहाइट पैमाने में परिवर्तित करता है।',
    inputs: [FormulaInput('C', 'Celsius (e.g. 37)')],
    compute: _cToF,
  ),
  // ── Motion & force ──
  FormulaData(
    id: 'acceleration',
    titleEn: 'Acceleration',
    titleOr: 'ତ୍ୱରଣ',
    titleHi: 'त्वरण',
    formula: 'a = (v − u) / t',
    category: _c,
    descEn:
        'How fast velocity changes: final velocity minus initial velocity, divided by time (m/s²).',
    descOr:
        'ବେଗ କେତେ ଶୀଘ୍ର ବଦଳେ: ଅନ୍ତିମ ବେଗରୁ ପ୍ରାରମ୍ଭିକ ବେଗ ବିୟୋଗ କରି ସମୟ ଦ୍ୱାରା ଭାଗ (m/s²)।',
    descHi:
        'वेग कितनी तेज़ी से बदलता है: अंतिम वेग में से प्रारंभिक वेग घटाकर समय से भाग (m/s²)।',
    inputs: [
      FormulaInput('u', 'Initial velocity, m/s (e.g. 0)'),
      FormulaInput('v', 'Final velocity, m/s (e.g. 20)'),
      FormulaInput('t', 'Time, s (e.g. 5)'),
    ],
    compute: _acceleration,
  ),
  FormulaData(
    id: 'force',
    titleEn: "Newton's Second Law",
    titleOr: 'ନିଉଟନଙ୍କ ଦ୍ୱିତୀୟ ନିୟମ',
    titleHi: 'न्यूटन का दूसरा नियम',
    formula: 'F = m × a',
    category: _c,
    descEn: 'Force equals mass times acceleration, measured in newtons (N).',
    descOr: 'ବଳ = ବସ୍ତୁତ୍ୱ × ତ୍ୱରଣ, ଏହା ନିଉଟନ୍ (N) ରେ ମପାଯାଏ।',
    descHi: 'बल = द्रव्यमान × त्वरण, इसे न्यूटन (N) में मापा जाता है।',
    inputs: [
      FormulaInput('m', 'Mass, kg (e.g. 10)'),
      FormulaInput('a', 'Acceleration, m/s² (e.g. 2)'),
    ],
    compute: _force,
  ),
  FormulaData(
    id: 'momentum',
    titleEn: 'Momentum',
    titleOr: 'ସଂବେଗ',
    titleHi: 'संवेग',
    formula: 'p = m × v',
    category: _c,
    descEn: 'The quantity of motion of a body: mass times velocity (kg·m/s).',
    descOr: 'ଏକ ବସ୍ତୁର ଗତିର ପରିମାଣ: ବସ୍ତୁତ୍ୱ × ବେଗ (kg·m/s)।',
    descHi: 'किसी वस्तु की गति की मात्रा: द्रव्यमान × वेग (kg·m/s)।',
    inputs: [
      FormulaInput('m', 'Mass, kg (e.g. 50)'),
      FormulaInput('v', 'Velocity, m/s (e.g. 4)'),
    ],
    compute: _momentum,
  ),
  FormulaData(
    id: 'weight',
    titleEn: 'Weight',
    titleOr: 'ଓଜନ',
    titleHi: 'भार',
    formula: 'W = m × g   (g = 9.8 m/s²)',
    category: _c,
    descEn: 'The force with which the Earth pulls a mass, in newtons.',
    descOr: 'ପୃଥିବୀ ଏକ ବସ୍ତୁକୁ ଯେଉଁ ବଳରେ ଟାଣେ, ନିଉଟନ୍ ରେ।',
    descHi: 'वह बल जिससे पृथ्वी किसी वस्तु को खींचती है, न्यूटन में।',
    inputs: [FormulaInput('m', 'Mass, kg (e.g. 60)')],
    compute: _weight,
  ),

  // ── Matter ──
  FormulaData(
    id: 'density',
    titleEn: 'Density',
    titleOr: 'ଘନତ୍ୱ',
    titleHi: 'घनत्व',
    formula: 'ρ = m / V',
    category: _c,
    descEn:
        'Mass per unit volume. Objects denser than water (1000 kg/m³) sink in it.',
    descOr:
        'ଏକକ ଆୟତନ ପ୍ରତି ବସ୍ତୁତ୍ୱ। ପାଣି (1000 kg/m³) ଠାରୁ ଅଧିକ ଘନ ବସ୍ତୁ ପାଣିରେ ବୁଡ଼ିଯାଏ।',
    descHi:
        'प्रति इकाई आयतन द्रव्यमान। पानी (1000 kg/m³) से अधिक घनी वस्तुएँ उसमें डूब जाती हैं।',
    inputs: [
      FormulaInput('m', 'Mass, kg (e.g. 2)'),
      FormulaInput('V', 'Volume, m³ (e.g. 0.001)'),
    ],
    compute: _density,
  ),
  FormulaData(
    id: 'pressure',
    titleEn: 'Pressure',
    titleOr: 'ଚାପ',
    titleHi: 'दाब',
    formula: 'P = F / A',
    category: _c,
    descEn: 'Force acting per unit area, measured in pascals (Pa).',
    descOr: 'ଏକକ କ୍ଷେତ୍ରଫଳ ଉପରେ କାର୍ଯ୍ୟ କରୁଥିବା ବଳ, ପାସ୍କାଲ (Pa) ରେ।',
    descHi: 'प्रति इकाई क्षेत्रफल पर लगने वाला बल, पास्कल (Pa) में।',
    inputs: [
      FormulaInput('F', 'Force, N (e.g. 100)'),
      FormulaInput('A', 'Area, m² (e.g. 0.5)'),
    ],
    compute: _pressure,
  ),

  // ── Work & energy ──
  FormulaData(
    id: 'work',
    titleEn: 'Work Done',
    titleOr: 'କୃତ କାର୍ଯ୍ୟ',
    titleHi: 'किया गया कार्य',
    formula: 'W = F × s',
    category: _c,
    descEn:
        'Force times the distance moved in the direction of the force, in joules (J).',
    descOr: 'ବଳ × ବଳର ଦିଗରେ ଅତିକ୍ରାନ୍ତ ଦୂରତା, ଜୁଲ (J) ରେ।',
    descHi: 'बल × बल की दिशा में तय दूरी, जूल (J) में।',
    inputs: [
      FormulaInput('F', 'Force, N (e.g. 20)'),
      FormulaInput('s', 'Distance, m (e.g. 5)'),
    ],
    compute: _work,
  ),
  FormulaData(
    id: 'power',
    titleEn: 'Power',
    titleOr: 'ଶକ୍ତି (କ୍ଷମତା)',
    titleHi: 'शक्ति',
    formula: 'P = W / t',
    category: _c,
    descEn: 'The rate of doing work, in watts (W).',
    descOr: 'କାର୍ଯ୍ୟ କରିବାର ହାର, ୱାଟ (W) ରେ।',
    descHi: 'कार्य करने की दर, वाट (W) में।',
    inputs: [
      FormulaInput('W', 'Work, J (e.g. 1000)'),
      FormulaInput('t', 'Time, s (e.g. 10)'),
    ],
    compute: _power,
  ),
  FormulaData(
    id: 'kinetic-energy',
    titleEn: 'Kinetic Energy',
    titleOr: 'ଗତିଜ ଶକ୍ତି',
    titleHi: 'गतिज ऊर्जा',
    formula: 'KE = ½ × m × v²',
    category: _c,
    descEn: 'Energy a body has because it is moving, in joules.',
    descOr: 'ଗତି କରୁଥିବାରୁ ବସ୍ତୁର ଥିବା ଶକ୍ତି, ଜୁଲ ରେ।',
    descHi: 'गति के कारण वस्तु में होने वाली ऊर्जा, जूल में।',
    inputs: [
      FormulaInput('m', 'Mass, kg (e.g. 2)'),
      FormulaInput('v', 'Velocity, m/s (e.g. 3)'),
    ],
    compute: _kineticEnergy,
  ),
  FormulaData(
    id: 'potential-energy',
    titleEn: 'Potential Energy',
    titleOr: 'ସ୍ଥିତିଜ ଶକ୍ତି',
    titleHi: 'स्थितिज ऊर्जा',
    formula: 'PE = m × g × h',
    category: _c,
    descEn:
        'Energy a body has because of its height above the ground, in joules.',
    descOr: 'ଭୂମିଠାରୁ ଉଚ୍ଚତା ଯୋଗୁଁ ବସ୍ତୁର ଥିବା ଶକ୍ତି, ଜୁଲ ରେ।',
    descHi: 'ज़मीन से ऊँचाई के कारण वस्तु में होने वाली ऊर्जा, जूल में।',
    inputs: [
      FormulaInput('m', 'Mass, kg (e.g. 5)'),
      FormulaInput('h', 'Height, m (e.g. 10)'),
    ],
    compute: _potentialEnergy,
  ),

  // ── Electricity ──
  FormulaData(
    id: 'ohms-law',
    titleEn: "Ohm's Law",
    titleOr: 'ଓମଙ୍କ ନିୟମ',
    titleHi: 'ओम का नियम',
    formula: 'V = I × R',
    category: _c,
    descEn:
        'Voltage across a conductor equals current times resistance. Enter any two values to find the third.',
    descOr:
        'ପରିବାହୀ ଉପରେ ବିଭବାନ୍ତର = ବିଦ୍ୟୁତ୍ ସ୍ରୋତ × ପ୍ରତିରୋଧ। ତୃତୀୟଟି ପାଇବାକୁ ଯେକୌଣସି ଦୁଇଟି ମାନ ଦିଅ।',
    descHi:
        'चालक पर विभवांतर = धारा × प्रतिरोध। तीसरा मान पाने के लिए कोई भी दो मान डालें।',
    inputs: [
      FormulaInput('V', 'Voltage, volts (leave blank to find)'),
      FormulaInput('I', 'Current, amperes (e.g. 2)'),
      FormulaInput('R', 'Resistance, ohms (e.g. 5)'),
    ],
    compute: _ohm,
  ),
  FormulaData(
    id: 'resistors',
    titleEn: 'Resistors in Series & Parallel',
    titleOr: 'ଶ୍ରେଣୀ ଓ ସମାନ୍ତରରେ ପ୍ରତିରୋଧକ',
    titleHi: 'श्रेणी और समांतर में प्रतिरोधक',
    formula: 'Series: R = R₁ + R₂ + …\nParallel: 1/R = 1/R₁ + 1/R₂ + …',
    category: _c,
    descEn:
        'Total resistance when resistors are joined end to end (series) or side by side (parallel).',
    descOr: 'ପ୍ରତିରୋଧକଗୁଡ଼ିକୁ ଶ୍ରେଣୀରେ ବା ସମାନ୍ତରରେ ଯୋଡ଼ିଲେ ମୋଟ ପ୍ରତିରୋଧ।',
    descHi: 'प्रतिरोधकों को श्रेणी में या समांतर में जोड़ने पर कुल प्रतिरोध।',
    inputs: [
      FormulaInput(
        'R',
        'Resistances, comma-separated (e.g. 2, 3, 6)',
        isList: true,
      ),
    ],
    compute: _resistors,
  ),
  FormulaData(
    id: 'electric-power',
    titleEn: 'Electric Power',
    titleOr: 'ବୈଦ୍ୟୁତିକ ଶକ୍ତି',
    titleHi: 'विद्युत शक्ति',
    formula: 'P = V × I',
    category: _c,
    descEn: 'Power used by an appliance: voltage times current, in watts.',
    descOr: 'ଏକ ଉପକରଣ ବ୍ୟବହାର କରୁଥିବା ଶକ୍ତି: ବିଭବାନ୍ତର × ସ୍ରୋତ, ୱାଟ ରେ।',
    descHi: 'किसी उपकरण द्वारा उपयोग की गई शक्ति: विभवांतर × धारा, वाट में।',
    inputs: [
      FormulaInput('V', 'Voltage, volts (e.g. 220)'),
      FormulaInput('I', 'Current, amperes (e.g. 0.5)'),
    ],
    compute: _electricPower,
  ),
  // ── Heat ──
  FormulaData(
    id: 'heat-energy',
    titleEn: 'Heat Energy',
    titleOr: 'ତାପ ଶକ୍ତି',
    titleHi: 'ऊष्मा ऊर्जा',
    formula: 'Q = m × c × ΔT',
    category: _c,
    descEn:
        'Heat needed to change the temperature of a body: mass × specific heat capacity × temperature change. Water has c = 4200 J/kg·°C.',
    descOr:
        'ଶରୀରର ତାପମାତ୍ରା ବଦଳାଇବାକୁ ଆବଶ୍ୟକ ତାପ: ବସ୍ତୁତ୍ୱ × ନିର୍ଦ୍ଦିଷ୍ଟ ତାପଧାରଣ କ୍ଷମତା × ତାପମାତ୍ରା ପରିବର୍ତ୍ତନ। ପାଣିର c = 4200 J/kg·°C।',
    descHi:
        'किसी वस्तु का ताप बदलने के लिए आवश्यक ऊष्मा: द्रव्यमान × विशिष्ट ऊष्मा धारिता × ताप-परिवर्तन। पानी के लिए c = 4200 J/kg·°C।',
    inputs: [
      FormulaInput('m', 'Mass, kg (e.g. 2)'),
      FormulaInput('c', 'Specific heat, J/kg·°C (e.g. 4200)'),
      FormulaInput('ΔT', 'Temperature change, °C (e.g. 30)'),
    ],
    compute: _heat,
  ),

  // ── Light ──
  FormulaData(
    id: 'mirror-formula',
    titleEn: 'Mirror Formula',
    titleOr: 'ଦର୍ପଣ ସୂତ୍ର',
    titleHi: 'दर्पण सूत्र',
    formula: '1/v + 1/u = 1/f,   m = −v/u',
    category: _c,
    descEn:
        'Relates object distance u, image distance v and focal length f of a spherical mirror. Use the Cartesian sign convention: distances measured against the incident light are negative, so a concave mirror has f < 0.',
    descOr:
        'ଗୋଲାକାର ଦର୍ପଣର ବସ୍ତୁ ଦୂରତା u, ପ୍ରତିବିମ୍ବ ଦୂରତା v ଓ ଫୋକସ୍ ଦୂରତା f ର ସମ୍ପର୍କ। କାର୍ତ୍ତେସୀୟ ଚିହ୍ନ ନିୟମ ବ୍ୟବହାର କର: ଆପତିତ ଆଲୋକର ବିପରୀତ ଦିଗରେ ମାପିଲେ ଦୂରତା ଋଣାତ୍ମକ, ତେଣୁ ଅବତଳ ଦର୍ପଣରେ f < 0।',
    descHi:
        'गोलीय दर्पण की वस्तु-दूरी u, प्रतिबिंब-दूरी v और फोकस दूरी f का संबंध। कार्तीय चिह्न परिपाटी लें: आपतित प्रकाश के विपरीत दिशा में मापी दूरी ऋणात्मक होती है, इसलिए अवतल दर्पण में f < 0।',
    inputs: [
      FormulaInput('f', 'Focal length, cm (e.g. -15)'),
      FormulaInput('u', 'Object distance, cm (e.g. -30)'),
    ],
    compute: _mirror,
  ),
  FormulaData(
    id: 'lens-formula',
    titleEn: 'Lens Formula',
    titleOr: 'ଲେନ୍ସ ସୂତ୍ର',
    titleHi: 'लेंस सूत्र',
    formula: '1/v − 1/u = 1/f,   m = v/u,   P = 1/f',
    category: _c,
    descEn:
        'Relates object distance, image distance and focal length of a thin lens, with the Cartesian sign convention. A convex lens has f > 0; a concave lens has f < 0. Power P is in dioptres when f is in metres.',
    descOr:
        'ପତଳା ଲେନ୍ସର ବସ୍ତୁ ଦୂରତା, ପ୍ରତିବିମ୍ବ ଦୂରତା ଓ ଫୋକସ୍ ଦୂରତାର ସମ୍ପର୍କ (କାର୍ତ୍ତେସୀୟ ଚିହ୍ନ ନିୟମ)। ଉତ୍ତଳ ଲେନ୍ସରେ f > 0; ଅବତଳ ଲେନ୍ସରେ f < 0। f ମିଟରରେ ହେଲେ କ୍ଷମତା P ଡାୟପ୍ଟରରେ।',
    descHi:
        'पतले लेंस की वस्तु-दूरी, प्रतिबिंब-दूरी और फोकस दूरी का संबंध (कार्तीय चिह्न परिपाटी)। उत्तल लेंस में f > 0 और अवतल लेंस में f < 0। f मीटर में हो तो क्षमता P डायोप्टर में मिलती है।',
    inputs: [
      FormulaInput('f', 'Focal length, cm (e.g. 20)'),
      FormulaInput('u', 'Object distance, cm (e.g. -30)'),
    ],
    compute: _lens,
  ),
  FormulaData(
    id: 'magnification',
    titleEn: 'Magnification',
    titleOr: 'ବିବର୍ଦ୍ଧନ',
    titleHi: 'आवर्धन',
    formula: 'm = h′ / h',
    category: _c,
    descEn:
        'Height of the image divided by height of the object. m > 1 means enlarged, m < 1 diminished, and a negative m means the image is inverted.',
    descOr:
        'ପ୍ରତିବିମ୍ବର ଉଚ୍ଚତା ÷ ବସ୍ତୁର ଉଚ୍ଚତା। m > 1 ହେଲେ ବଡ଼, m < 1 ହେଲେ ଛୋଟ, ଓ ଋଣାତ୍ମକ m ହେଲେ ପ୍ରତିବିମ୍ବ ଓଲଟା।',
    descHi:
        'प्रतिबिंब की ऊँचाई ÷ वस्तु की ऊँचाई। m > 1 हो तो बड़ा, m < 1 हो तो छोटा, और ऋणात्मक m का अर्थ है प्रतिबिंब उलटा है।',
    inputs: [
      FormulaInput('h′', 'Image height (e.g. -6)'),
      FormulaInput('h', 'Object height (e.g. 3)'),
    ],
    compute: _magnification,
  ),
  FormulaData(
    id: 'refractive-index',
    titleEn: 'Refractive Index',
    titleOr: 'ପ୍ରତିସରଣାଙ୍କ',
    titleHi: 'अपवर्तनांक',
    formula: 'n = c / v = sin i / sin r',
    category: _c,
    descEn:
        'How much a medium slows light: speed of light in vacuum (3 × 10⁸ m/s) divided by its speed in the medium. Enter the speed v, or the angles of incidence i and refraction r.',
    descOr:
        'ମାଧ୍ୟମ ଆଲୋକକୁ କେତେ ଧୀର କରେ: ଶୂନ୍ୟରେ ଆଲୋକର ବେଗ (3 × 10⁸ m/s) ÷ ମାଧ୍ୟମରେ ତାର ବେଗ। ବେଗ v ଅଥବା ଆପତନ କୋଣ i ଓ ପ୍ରତିସରଣ କୋଣ r ଦିଅ।',
    descHi:
        'माध्यम प्रकाश को कितना धीमा करता है: निर्वात में प्रकाश की चाल (3 × 10⁸ m/s) ÷ माध्यम में उसकी चाल। चाल v या आपतन कोण i और अपवर्तन कोण r डालें।',
    inputs: [
      FormulaInput('v', 'Speed in medium, ×10⁸ m/s (e.g. 2)'),
      FormulaInput('i (deg)', 'Angle of incidence (optional, e.g. 45)'),
      FormulaInput('r (deg)', 'Angle of refraction (optional, e.g. 28)'),
    ],
    compute: _refractiveIndex,
  ),

  // ── Waves ──
  FormulaData(
    id: 'wave-speed',
    titleEn: 'Wave Speed',
    titleOr: 'ତରଙ୍ଗ ବେଗ',
    titleHi: 'तरंग चाल',
    formula: 'v = f × λ',
    category: _c,
    descEn:
        'Speed of a wave = frequency × wavelength. Leave one box blank to find it.',
    descOr:
        'ତରଙ୍ଗର ବେଗ = କମ୍ପାଙ୍କ × ତରଙ୍ଗଦୈର୍ଘ୍ୟ। ବାହାର କରିବାକୁ ଗୋଟିଏ ଘର ଖାଲି ରଖ।',
    descHi:
        'तरंग की चाल = आवृत्ति × तरंगदैर्ध्य। जिसे ज्ञात करना हो उस खाने को खाली छोड़ें।',
    inputs: [
      FormulaInput('v', 'Speed, m/s (blank to find)'),
      FormulaInput('f', 'Frequency, Hz (e.g. 340)'),
      FormulaInput('λ', 'Wavelength, m (e.g. 1)'),
    ],
    compute: _waveSpeed,
  ),
];

// ─── Calculators ──────────────────────────────────────────────────────────────

String? _speed(FormulaValues v) {
  final d = v.n('d'), t = v.n('t');
  if (d == null || t == null || t == 0) return null;
  return 's = ${fx(d / t)}';
}

String? _fToC(FormulaValues v) {
  final f = v.n('F');
  return f == null ? null : 'C = ${fx((f - 32) * 5 / 9)}°C';
}

String? _cToF(FormulaValues v) {
  final c = v.n('C');
  return c == null ? null : 'F = ${fx((c * 9 / 5) + 32)}°F';
}

String? _acceleration(FormulaValues v) {
  final u = v.n('u'), vel = v.n('v'), t = v.n('t');
  if (u == null || vel == null || t == null || t == 0) return null;
  return 'a = ${nice((vel - u) / t)} m/s²';
}

String? _force(FormulaValues v) {
  final m = v.n('m'), a = v.n('a');
  if (m == null || a == null) return null;
  return 'F = ${nice(m * a)} N';
}

String? _momentum(FormulaValues v) {
  final m = v.n('m'), vel = v.n('v');
  if (m == null || vel == null) return null;
  return 'p = ${nice(m * vel)} kg·m/s';
}

String? _weight(FormulaValues v) {
  final m = v.n('m');
  return m == null ? null : 'W = ${nice(m * _g)} N';
}

String? _density(FormulaValues v) {
  final m = v.n('m'), vol = v.n('V');
  if (m == null || vol == null || vol == 0) return null;
  return 'ρ = ${nice(m / vol)} kg/m³';
}

String? _pressure(FormulaValues v) {
  final f = v.n('F'), a = v.n('A');
  if (f == null || a == null || a == 0) return null;
  return 'P = ${nice(f / a)} Pa';
}

String? _work(FormulaValues v) {
  final f = v.n('F'), s = v.n('s');
  if (f == null || s == null) return null;
  return 'W = ${nice(f * s)} J';
}

String? _power(FormulaValues v) {
  final w = v.n('W'), t = v.n('t');
  if (w == null || t == null || t == 0) return null;
  return 'P = ${nice(w / t)} W';
}

String? _kineticEnergy(FormulaValues v) {
  final m = v.n('m'), vel = v.n('v');
  if (m == null || vel == null) return null;
  return 'KE = ${nice(0.5 * m * vel * vel)} J';
}

String? _potentialEnergy(FormulaValues v) {
  final m = v.n('m'), h = v.n('h');
  if (m == null || h == null) return null;
  return 'PE = ${nice(m * _g * h)} J';
}

/// Solves V = IR for whichever one of the three is left blank.
String? _ohm(FormulaValues v) {
  final volts = v.n('V'), i = v.n('I'), r = v.n('R');
  if (volts == null && i != null && r != null) {
    return 'V = ${nice(i * r)} V';
  }
  if (i == null && volts != null && r != null && r != 0) {
    return 'I = ${nice(volts / r)} A';
  }
  if (r == null && volts != null && i != null && i != 0) {
    return 'R = ${nice(volts / i)} Ω';
  }
  return null;
}

String? _resistors(FormulaValues v) {
  final rs = v.list('R');
  if (rs == null || rs.any((r) => r <= 0)) return null;
  final series = rs.reduce((a, b) => a + b);
  final parallel = 1 / rs.map((r) => 1 / r).reduce((a, b) => a + b);
  return 'Series = ${nice(series)} Ω, Parallel = ${nice(parallel)} Ω';
}

String? _electricPower(FormulaValues v) {
  final volts = v.n('V'), i = v.n('I');
  if (volts == null || i == null) return null;
  return 'P = ${nice(volts * i)} W';
}

String? _heat(FormulaValues v) {
  final m = v.n('m'), c = v.n('c'), dt = v.n('ΔT');
  if (m == null || c == null || dt == null) return null;
  return 'Q = ${nice(m * c * dt)} J';
}

/// Shared by the mirror (1/v + 1/u = 1/f) and lens (1/v − 1/u = 1/f) formulas,
/// both in the Cartesian sign convention.
String? _imageDistance(FormulaValues v, {required bool mirror}) {
  final f = v.n('f'), u = v.n('u');
  if (f == null || u == null) return null;
  if (f == 0 || u == 0) return 'f and u cannot be 0';
  final inv = mirror ? 1 / f - 1 / u : 1 / f + 1 / u;
  if (inv.abs() < 1e-12) return 'Image forms at infinity';
  final img = 1 / inv;
  final m = mirror ? -img / u : img / u;
  final kind = img * (mirror ? -1 : 1) > 0 ? 'real' : 'virtual';
  final size = m.abs() > 1
      ? 'enlarged'
      : m.abs() < 1
      ? 'diminished'
      : 'same size';
  final tail = mirror ? '' : ', P = ${nice(100 / f)} D';
  return 'v = ${nice(img)} cm, m = ${nice(m)} ($kind, $size)$tail';
}

String? _mirror(FormulaValues v) => _imageDistance(v, mirror: true);

String? _lens(FormulaValues v) => _imageDistance(v, mirror: false);

String? _magnification(FormulaValues v) {
  final hi = v.n('h′'), ho = v.n('h');
  if (hi == null || ho == null || ho == 0) return null;
  final m = hi / ho;
  final note = m < 0 ? 'inverted' : 'erect';
  final size = m.abs() > 1
      ? 'enlarged'
      : m.abs() < 1
      ? 'diminished'
      : 'same size';
  return 'm = ${nice(m)} ($note, $size)';
}

String? _refractiveIndex(FormulaValues v) {
  final speed = v.n('v');
  if (speed != null) {
    if (speed <= 0 || speed > 3) return 'Speed must be between 0 and 3';
    return 'n = ${nice(3 / speed)}';
  }
  final i = v.n('i (deg)'), r = v.n('r (deg)');
  if (i == null || r == null) return null;
  final sinR = sin(rad(r));
  if (sinR == 0) return null;
  return 'n = ${nice(sin(rad(i)) / sinR)}';
}

String? _waveSpeed(FormulaValues v) {
  final speed = v.n('v'), f = v.n('f'), wl = v.n('λ');
  if (speed == null && f != null && wl != null) {
    return 'v = ${nice(f * wl)} m/s';
  }
  if (f == null && speed != null && wl != null && wl != 0) {
    return 'f = ${nice(speed / wl)} Hz';
  }
  if (wl == null && speed != null && f != null && f != 0) {
    return 'λ = ${nice(speed / f)} m';
  }
  return null;
}
