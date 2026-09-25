import '../models/localized_text.dart';

// ─── Lab catalog ──────────────────────────────────────────────────────────────
//
// What each experiment offers: the controls a student can set (and their
// allowed values), the outcomes they can predict, and the one question the
// bench asks. Visuals live with the screens; this file stays plain Dart.

enum LabSubject { physics, chemistry }

class LabExperiment {
  final String id;
  final LabSubject subject;

  /// App chrome, English only.
  final String title;

  /// The question the bench asks, e.g. "Will the bulb glow?".
  final LocalizedText question;

  /// Control key → allowed values, in display order.
  final Map<String, List<Object>> controls;

  /// The controls a fresh bench starts with.
  final Map<String, Object> defaultControls;

  /// Outcome keys the student can predict, in display order.
  final List<String> outcomes;

  const LabExperiment({
    required this.id,
    required this.subject,
    required this.title,
    required this.question,
    required this.controls,
    required this.defaultControls,
    required this.outcomes,
  });

  /// Every combination of control values, for exhaustive checks.
  Iterable<Map<String, Object>> get allControlSets sync* {
    Iterable<Map<String, Object>> expand(int i) sync* {
      if (i == controls.length) {
        yield {};
        return;
      }
      final entry = controls.entries.elementAt(i);
      for (final rest in expand(i + 1)) {
        for (final value in entry.value) {
          yield {entry.key: value, ...rest};
        }
      }
    }

    yield* expand(0);
  }
}

const labExperiments = <LabExperiment>[
  LabExperiment(
    id: 'circuit',
    subject: LabSubject.physics,
    title: 'Light the bulb',
    question: LocalizedText(
      en: 'How brightly will the bulb glow?',
      or: 'ବଲ୍ବ କେତେ ଉଜ୍ଜ୍ୱଳ ଜଳିବ?',
      hi: 'बल्ब कितना तेज़ जलेगा?',
    ),
    controls: {
      'cells': [1, 2, 3],
      'resistance_ohms': [3, 6, 9],
      'closed': [false, true],
    },
    defaultControls: {'cells': 1, 'resistance_ohms': 6, 'closed': true},
    outcomes: ['off', 'dim', 'bright'],
  ),
  LabExperiment(
    id: 'pendulum',
    subject: LabSubject.physics,
    title: 'Pendulum swing',
    question: LocalizedText(
      en: 'How many swings in 10 seconds?',
      or: '10 ସେକେଣ୍ଡରେ କେତେ ଥର ଦୋହଲିବ?',
      hi: '10 सेकंड में कितनी बार झूलेगा?',
    ),
    controls: {
      'length_cm': [25, 50, 100],
      'mass_g': [50, 200],
    },
    defaultControls: {'length_cm': 50, 'mass_g': 50},
    outcomes: ['slow', 'medium', 'fast'],
  ),
  LabExperiment(
    id: 'mirror',
    subject: LabSubject.physics,
    title: 'Mirror bounce',
    question: LocalizedText(
      en: 'Which star will the reflected beam hit?',
      or: 'ପ୍ରତିଫଳିତ ରଶ୍ମି କେଉଁ ତାରାକୁ ଛୁଇଁବ?',
      hi: 'परावर्तित किरण किस तारे से टकराएगी?',
    ),
    controls: {
      'angle_deg': [30, 45, 60],
    },
    defaultControls: {'angle_deg': 45},
    outcomes: ['high', 'middle', 'low'],
  ),
  LabExperiment(
    id: 'float',
    subject: LabSubject.physics,
    title: 'Sink or float',
    question: LocalizedText(
      en: 'Will it float or sink?',
      or: 'ଏହା ଭାସିବ ନା ବୁଡ଼ିବ?',
      hi: 'यह तैरेगा या डूबेगा?',
    ),
    controls: {
      'object': ['wood', 'ice', 'egg', 'stone', 'iron'],
      'liquid': ['water', 'salt_water'],
    },
    defaultControls: {'object': 'egg', 'liquid': 'water'},
    outcomes: ['float', 'sink'],
  ),
  LabExperiment(
    id: 'indicator',
    subject: LabSubject.chemistry,
    title: 'Colour detective',
    question: LocalizedText(
      en: 'What colour will the indicator turn?',
      or: 'ସୂଚକ କେଉଁ ରଙ୍ଗ ହେବ?',
      hi: 'सूचक किस रंग का हो जाएगा?',
    ),
    controls: {
      'sample': [
        'lemon',
        'tomato',
        'water',
        'baking_soda',
        'soap',
        'limewater',
      ],
    },
    defaultControls: {'sample': 'lemon'},
    outcomes: ['red', 'orange', 'green', 'blue', 'violet'],
  ),
  LabExperiment(
    id: 'fizz',
    subject: LabSubject.chemistry,
    title: 'Fizz balloon',
    question: LocalizedText(
      en: 'How big will the balloon grow?',
      or: 'ବେଲୁନ୍ କେତେ ବଡ଼ ହେବ?',
      hi: 'गुब्बारा कितना बड़ा होगा?',
    ),
    controls: {
      'soda_spoons': [1, 2, 3],
      'vinegar_cups': [1, 2, 3],
    },
    defaultControls: {'soda_spoons': 1, 'vinegar_cups': 2},
    outcomes: ['small', 'medium', 'big'],
  ),
];

LabExperiment? labById(String id) {
  for (final lab in labExperiments) {
    if (lab.id == id) return lab;
  }
  return null;
}
