import 'dart:math' as math;

import '../models/localized_text.dart';
import '../models/regional_language.dart';
import 'lab_words.dart';

// ─── Lab rules ────────────────────────────────────────────────────────────────
//
// Every experiment is a pure function of its controls: the same controls always
// give the same observation, so an attempt can be re-checked later (and by the
// backend evaluator, which must mirror these rules for `labVersion` 2).
//
// Controls, observation values and predictions are English keys; only the
// explanation is shown in the student's language.

/// The rules version these functions implement. Bump it whenever an
/// observation for the same controls would change.
const kLabVersion = 2;

class LabObservation {
  final Map<String, Object> values;

  /// The key the prediction is checked against, e.g. `bright` or `float`.
  final String outcome;

  /// Why it happened, in English, Odia and Hindi.
  final LocalizedText explanation;

  const LabObservation({
    required this.values,
    required this.outcome,
    required this.explanation,
  });

  bool matches(String prediction) => prediction == outcome;
}

/// Runs [labId] with [controls]. Check a prediction with [LabObservation.matches].
LabObservation evaluateLab(String labId, Map<String, Object> controls) =>
    switch (labId) {
      'circuit' => _circuit(controls),
      'pendulum' => _pendulum(controls),
      'mirror' => _mirror(controls),
      'float' => _float(controls),
      'indicator' => _indicator(controls),
      'fizz' => _fizz(controls),
      _ => throw ArgumentError.value(labId, 'labId'),
    };

String _w(String key, RegionalLanguage lang) => labWord(key, lang);

// ─── Physics · Electric circuit ───────────────────────────────────────────────

/// Current at or above this lights the bulb brightly.
const kBrightCurrentA = 0.5;

LabObservation _circuit(Map<String, Object> c) {
  final cells = c['cells'] as int;
  final resistance = c['resistance_ohms'] as int;
  final closed = c['closed'] as bool;
  final voltage = cells * 1.5;
  final current = closed ? (voltage / resistance * 100).round() / 100 : 0.0;
  final brightness = !closed
      ? 'off'
      : current >= kBrightCurrentA
      ? 'bright'
      : 'dim';
  return LabObservation(
    values: {
      'voltage_v': voltage,
      'current_a': current,
      'brightness': brightness,
    },
    outcome: brightness,
    explanation: switch (brightness) {
      'off' => const LocalizedText(
        en: 'The switch is open, so the path is broken. No current flows and the bulb stays off.',
        or: 'ସ୍ୱିଚ୍ ଖୋଲା ଥିବାରୁ ପଥ ଭାଙ୍ଗିଯାଏ। କୌଣସି ବିଦ୍ୟୁତ୍ ସ୍ରୋତ ପ୍ରବାହିତ ହୁଏ ନାହିଁ ଓ ବଲ୍ବ ଜଳେ ନାହିଁ।',
        hi: 'स्विच खुला है, इसलिए रास्ता टूट जाता है। कोई धारा नहीं बहती और बल्ब नहीं जलता।',
      ),
      'bright' => LocalizedText(
        en: 'The cells push enough current through the circuit: $voltage V ÷ $resistance Ω = $current A, enough for a bright glow. More cells push more current; more resistance lets less through.',
        or: 'ସେଲ୍ ପରିପଥ ଦେଇ ଯଥେଷ୍ଟ ସ୍ରୋତ ଠେଲନ୍ତି: $voltage V ÷ $resistance Ω = $current A, ଉଜ୍ଜ୍ୱଳ ଆଲୋକ ପାଇଁ ଯଥେଷ୍ଟ। ଅଧିକ ସେଲ୍ ଅଧିକ ସ୍ରୋତ ଠେଲେ; ଅଧିକ ପ୍ରତିରୋଧ କମ୍ ସ୍ରୋତ ଛାଡ଼େ।',
        hi: 'सेल परिपथ में पर्याप्त धारा धकेलते हैं: $voltage V ÷ $resistance Ω = $current A, तेज़ रोशनी के लिए काफ़ी। अधिक सेल अधिक धारा धकेलते हैं; अधिक प्रतिरोध कम धारा जाने देता है।',
      ),
      _ => LocalizedText(
        en: 'The resistance slows the current down: $voltage V ÷ $resistance Ω = $current A, which is too little for a bright glow. Add a cell or remove resistance.',
        or: 'ପ୍ରତିରୋଧ ସ୍ରୋତକୁ କମାଇଦିଏ: $voltage V ÷ $resistance Ω = $current A, ଯାହା ଉଜ୍ଜ୍ୱଳ ଆଲୋକ ପାଇଁ କମ୍। ଗୋଟିଏ ସେଲ୍ ଯୋଡ଼ ବା ପ୍ରତିରୋଧ କମାଅ।',
        hi: 'प्रतिरोध धारा को धीमा कर देता है: $voltage V ÷ $resistance Ω = $current A, जो तेज़ रोशनी के लिए कम है। एक सेल जोड़ें या प्रतिरोध घटाएँ।',
      ),
    },
  );
}

// ─── Physics · Pendulum ───────────────────────────────────────────────────────

const kGravity = 9.8;

/// Seconds the pendulum is timed for.
const kPendulumWindowS = 10;

/// Time for one full swing (there and back) of a simple pendulum.
double pendulumPeriod(int lengthCm) =>
    2 * math.pi * math.sqrt(lengthCm / 100 / kGravity);

LabObservation _pendulum(Map<String, Object> c) {
  final length = c['length_cm'] as int;
  final mass = c['mass_g'] as int;
  final period = pendulumPeriod(length);
  final swings = (kPendulumWindowS / period).floor();
  final speed = swings >= 9
      ? 'fast'
      : swings >= 6
      ? 'medium'
      : 'slow';
  final periodText = (period * 100).round() / 100;
  return LabObservation(
    values: {'period_s': periodText, 'swings_10s': swings, 'speed': speed},
    outcome: speed,
    explanation: LocalizedText(
      en: 'One swing takes $periodText s, so it swings $swings times in 10 s. Only the string length changes this: a longer string swings slower. The $mass g bob swings just as fast as any other.',
      or: 'ଗୋଟିଏ ଦୋଳନରେ $periodText s ଲାଗେ, ତେଣୁ 10 s ରେ $swings ଥର ଦୋହଲେ। କେବଳ ସୂତାର ଲମ୍ବ ଏହାକୁ ବଦଳାଏ: ଲମ୍ବା ସୂତା ଧୀରେ ଦୋହଲେ। $mass g ବବ୍ ଅନ୍ୟ ଯେକୌଣସି ବବ୍ ପରି ସମାନ ବେଗରେ ଦୋହଲେ।',
      hi: 'एक दोलन में $periodText s लगते हैं, इसलिए 10 s में यह $swings बार झूलता है। केवल धागे की लंबाई इसे बदलती है: लंबा धागा धीरे झूलता है। $mass g का गोलक किसी भी दूसरे गोलक जितना ही तेज़ झूलता है।',
    ),
  );
}

// ─── Physics · Plane mirror ───────────────────────────────────────────────────

/// Angle of reflection (from the normal) → the target that sits there.
const kMirrorTargets = {30: 'high', 45: 'middle', 60: 'low'};

LabObservation _mirror(Map<String, Object> c) {
  final incidence = c['angle_deg'] as int;
  final target = kMirrorTargets[incidence];
  if (target == null) throw ArgumentError.value(incidence, 'angle_deg');
  return LabObservation(
    values: {
      'incidence_deg': incidence,
      'reflection_deg': incidence,
      'target': target,
    },
    outcome: target,
    explanation: LocalizedText(
      en: 'The beam hits the mirror at $incidence° from the normal and bounces off at exactly $incidence° on the other side. Angle of incidence = angle of reflection.',
      or: 'ରଶ୍ମି ଲମ୍ବ ରେଖାଠାରୁ $incidence° ରେ ଦର୍ପଣରେ ପଡ଼େ ଓ ଅନ୍ୟ ପାର୍ଶ୍ୱରେ ଠିକ୍ $incidence° ରେ ପ୍ରତିଫଳିତ ହୁଏ। ଆପତନ କୋଣ = ପ୍ରତିଫଳନ କୋଣ।',
      hi: 'किरण अभिलंब से $incidence° पर दर्पण से टकराती है और दूसरी ओर ठीक $incidence° पर लौटती है। आपतन कोण = परावर्तन कोण।',
    ),
  );
}

// ─── Physics · Sink or float ──────────────────────────────────────────────────

/// Density in g/cm³.
const kObjectDensity = {
  'wood': 0.6,
  'ice': 0.92,
  'egg': 1.03,
  'stone': 2.6,
  'iron': 7.9,
};

const kLiquidDensity = {'water': 1.0, 'salt_water': 1.2};

LabObservation _float(Map<String, Object> c) {
  final object = c['object'] as String;
  final liquid = c['liquid'] as String;
  final objectDensity = kObjectDensity[object];
  final liquidDensity = kLiquidDensity[liquid];
  if (objectDensity == null) throw ArgumentError.value(object, 'object');
  if (liquidDensity == null) throw ArgumentError.value(liquid, 'liquid');
  final floats = objectDensity < liquidDensity;
  final result = floats ? 'float' : 'sink';
  final underwater = floats
      ? (objectDensity / liquidDensity * 100).round()
      : 100;
  String line(RegionalLanguage l) =>
      '${_w(object, l)} $objectDensity g/cm³ · ${_w(liquid, l)} $liquidDensity g/cm³';
  return LabObservation(
    values: {
      'object_density': objectDensity,
      'liquid_density': liquidDensity,
      'result': result,
      'underwater_pct': underwater,
    },
    outcome: result,
    explanation: floats
        ? LocalizedText(
            en: '${line(RegionalLanguage.english)}. It is lighter than the same volume of liquid, so it floats with about $underwater% under the surface.',
            or: '${line(RegionalLanguage.odia)}। ଏହା ସମାନ ଆୟତନର ତରଳଠାରୁ ହାଲୁକା, ତେଣୁ ପ୍ରାୟ $underwater% ଭାଗ ବୁଡ଼ି ଭାସେ।',
            hi: '${line(RegionalLanguage.hindi)}। यह उतने ही आयतन के द्रव से हल्का है, इसलिए लगभग $underwater% डूबकर तैरता है।',
          )
        : LocalizedText(
            en: '${line(RegionalLanguage.english)}. It is heavier than the same volume of liquid, so it sinks.',
            or: '${line(RegionalLanguage.odia)}। ଏହା ସମାନ ଆୟତନର ତରଳଠାରୁ ଭାରୀ, ତେଣୁ ବୁଡ଼ିଯାଏ।',
            hi: '${line(RegionalLanguage.hindi)}। यह उतने ही आयतन के द्रव से भारी है, इसलिए डूब जाता है।',
          ),
  );
}

// ─── Chemistry · Universal indicator ──────────────────────────────────────────

/// Sample → approximate pH.
const kSamplePh = {
  'lemon': 2,
  'tomato': 4,
  'water': 7,
  'baking_soda': 9,
  'soap': 10,
  'limewater': 12,
};

/// The colour universal indicator turns at [ph].
String indicatorColor(int ph) => ph <= 3
    ? 'red'
    : ph <= 6
    ? 'orange'
    : ph == 7
    ? 'green'
    : ph <= 10
    ? 'blue'
    : 'violet';

String phNature(int ph) => ph < 7
    ? 'acidic'
    : ph == 7
    ? 'neutral'
    : 'basic';

LabObservation _indicator(Map<String, Object> c) {
  final sample = c['sample'] as String;
  final ph = kSamplePh[sample];
  if (ph == null) throw ArgumentError.value(sample, 'sample');
  final color = indicatorColor(ph);
  final nature = phNature(ph);
  return LabObservation(
    values: {'color': color, 'approx_ph': ph, 'nature': nature},
    outcome: color,
    explanation: LocalizedText(
      en: '${_w(sample, RegionalLanguage.english)} has a pH of about $ph, so it is ${_w(nature, RegionalLanguage.english).toLowerCase()}. Universal indicator turns ${_w(color, RegionalLanguage.english).toLowerCase()}: red for strong acids, green for neutral, violet for strong bases.',
      or: '${_w(sample, RegionalLanguage.odia)}ର pH ପ୍ରାୟ $ph, ତେଣୁ ଏହା ${_w(nature, RegionalLanguage.odia)}। ସାର୍ବଜନୀନ ସୂଚକ ${_w(color, RegionalLanguage.odia)} ହୁଏ: ତୀବ୍ର ଅମ୍ଳରେ ଲାଲ, ନିରପେକ୍ଷରେ ସବୁଜ, ତୀବ୍ର କ୍ଷାରରେ ବାଇଗଣୀ।',
      hi: '${_w(sample, RegionalLanguage.hindi)} का pH लगभग $ph है, इसलिए यह ${_w(nature, RegionalLanguage.hindi)} है। सार्वत्रिक सूचक ${_w(color, RegionalLanguage.hindi)} हो जाता है: प्रबल अम्ल में लाल, उदासीन में हरा, प्रबल क्षार में बैंगनी।',
    ),
  );
}

// ─── Chemistry · Baking soda + vinegar ────────────────────────────────────────

const kBalloonSizes = ['small', 'medium', 'big'];

LabObservation _fizz(Map<String, Object> c) {
  final soda = c['soda_spoons'] as int;
  final vinegar = c['vinegar_cups'] as int;
  if (soda < 1 || soda > 3) throw ArgumentError.value(soda, 'soda_spoons');
  if (vinegar < 1 || vinegar > 3) {
    throw ArgumentError.value(vinegar, 'vinegar_cups');
  }
  final gas = math.min(soda, vinegar);
  final balloon = kBalloonSizes[gas - 1];
  final leftover = soda > vinegar
      ? 'baking_soda'
      : vinegar > soda
      ? 'vinegar'
      : 'none';
  final LocalizedText why = switch (leftover) {
    'none' => const LocalizedText(
      en: 'Both were used up together, so every bit made gas.',
      or: 'ଦୁହେଁ ଏକାସାଙ୍ଗରେ ସରିଗଲେ, ତେଣୁ ସବୁ ଅଂଶ ଗ୍ୟାସ ତିଆରି କଲା।',
      hi: 'दोनों एक साथ खत्म हो गए, इसलिए हर हिस्से से गैस बनी।',
    ),
    _ => LocalizedText(
      en: 'Some ${_w(leftover, RegionalLanguage.english).toLowerCase()} was left over: the reaction stops when the other one runs out.',
      or: 'କିଛି ${_w(leftover, RegionalLanguage.odia)} ବଳିଗଲା: ଅନ୍ୟଟି ସରିଗଲେ ପ୍ରତିକ୍ରିୟା ବନ୍ଦ ହୁଏ।',
      hi: 'कुछ ${_w(leftover, RegionalLanguage.hindi)} बच गया: दूसरा खत्म होते ही अभिक्रिया रुक जाती है।',
    ),
  };
  return LabObservation(
    values: {'gas_units': gas, 'balloon': balloon, 'leftover': leftover},
    outcome: balloon,
    explanation: LocalizedText(
      en: 'Baking soda (a base) reacts with vinegar (an acid) and gives off carbon dioxide gas, which fills the balloon. ${why.en}',
      or: 'ଖାଇବା ସୋଡା (କ୍ଷାର) ଭିନେଗାର (ଅମ୍ଳ) ସହ ପ୍ରତିକ୍ରିୟା କରି କାର୍ବନ ଡାଇଅକ୍ସାଇଡ୍ ଗ୍ୟାସ ଦିଏ, ଯାହା ବେଲୁନ୍ ଭରେ। ${why.or}',
      hi: 'बेकिंग सोडा (क्षार) सिरके (अम्ल) से अभिक्रिया करके कार्बन डाइऑक्साइड गैस देता है, जो गुब्बारे को भरती है। ${why.hi}',
    ),
  );
}
