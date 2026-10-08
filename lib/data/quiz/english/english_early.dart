import '../quiz_models.dart';

// ─── English · Classes 1–2 ────────────────────────────────────────────────────
//
// The English itself is the content, so options stay English; prompts and
// explanations are translated so younger students can follow them.

const _k = QuizKit(QuizSubject.english, QuizBand.early);
final _tf = _k.trueFalse, _m = _k.match;

/// English options read the same in every language.
QuizQuestion _q(String topic, Tri p, List<String> o, int a, Tri e) =>
    _k.choice(topic, p, [for (final s in o) (s, s, s)], a, e);

QuizQuestion _fill(String topic, Tri p, List<String> o, int a, Tri e) =>
    _k.fillBlank(topic, p, [for (final s in o) (s, s, s)], a, e);

/// An English word shown unchanged in every language.
Tri _w(String s) => (s, s, s);

const _abc = 'Letters & sounds';
const _words = 'Words';
const _sentences = 'Sentences';

final englishEarly = <QuizQuestion>[
  _q(
    _abc,
    ('Which letter comes after B?', 'B ପରେ କେଉଁ ଅକ୍ଷର ଆସେ?', 'B के बाद कौन-सा अक्षर आता है?'),
    ['A', 'C', 'D', 'E'],
    1,
    ('A, B, C — C comes after B.', 'A, B, C — B ପରେ C।', 'A, B, C — B के बाद C आता है।'),
  ),
  _q(
    _abc,
    ('Which is a vowel?', 'କେଉଁଟି ସ୍ୱରବର୍ଣ୍ଣ?', 'कौन-सा स्वर है?'),
    ['B', 'K', 'E', 'T'],
    2,
    ('The vowels are A, E, I, O and U.', 'ସ୍ୱରବର୍ଣ୍ଣ A, E, I, O ଓ U।', 'स्वर A, E, I, O और U हैं।'),
  ),
  _q(
    _abc,
    ('“Cat” starts with which letter?', '“Cat” କେଉଁ ଅକ୍ଷରରେ ଆରମ୍ଭ ହୁଏ?', '“Cat” किस अक्षर से शुरू होता है?'),
    ['K', 'C', 'T', 'A'],
    1,
    ('C-A-T: cat starts with C.', 'C-A-T: cat ର ପ୍ରଥମ ଅକ୍ଷର C।', 'C-A-T: cat का पहला अक्षर C है।'),
  ),
  _q(
    _abc,
    ('Which word rhymes with “hat”?', 'କେଉଁ ଶବ୍ଦ “hat” ସହ ମେଳ ଖାଏ?', 'कौन-सा शब्द “hat” से तुक मिलाता है?'),
    ['Hot', 'Bat', 'Hit', 'Hut'],
    1,
    ('Hat and bat both end in “-at”.', 'Hat ଓ bat ଦୁହେଁ “-at” ରେ ଶେଷ।', 'Hat और bat दोनों “-at” पर खत्म होते हैं।'),
  ),
  _q(
    _abc,
    ('What is the small letter of “G”?', '“G” ର ଛୋଟ ଅକ୍ଷର କ’ଣ?', '“G” का छोटा अक्षर क्या है?'),
    ['q', 'j', 'g', 'y'],
    2,
    ('Capital G, small g.', 'ବଡ଼ G, ଛୋଟ g।', 'बड़ा G, छोटा g।'),
  ),
  _q(
    _words,
    ('Which one is a fruit?', 'କେଉଁଟି ଫଳ?', 'इनमें से फल कौन-सा है?'),
    ['Mango', 'Chair', 'Pencil', 'Shoe'],
    0,
    ('A mango is a fruit.', 'Mango (ଆମ୍ବ) ଏକ ଫଳ।', 'Mango (आम) एक फल है।'),
  ),
  _q(
    _words,
    ('Which colour is the sky on a sunny day?', 'ଖରା ଦିନରେ ଆକାଶ କେଉଁ ରଙ୍ଗର?', 'धूप वाले दिन आसमान किस रंग का होता है?'),
    ['Blue', 'Pink', 'Black', 'Brown'],
    0,
    ('On a sunny day the sky is blue.', 'ଖରା ଦିନରେ ଆକାଶ blue (ନୀଳ)।', 'धूप वाले दिन आसमान blue (नीला) होता है।'),
  ),
  _q(
    _words,
    ('What is the opposite of “big”?', '“big” ର ବିପରୀତ କ’ଣ?', '“big” का उल्टा क्या है?'),
    ['Tall', 'Small', 'Long', 'Fat'],
    1,
    ('Big and small are opposites.', 'Big ଓ small ବିପରୀତ।', 'Big और small उल्टे हैं।'),
  ),
  _q(
    _words,
    ('How do we say “one more than one” in English?', 'ଇଂରାଜୀରେ “ଏକ ଅଧିକ ଏକ” କୁ କ’ଣ କୁହାଯାଏ?', 'अंग्रेज़ी में “एक और एक” को क्या कहते हैं?'),
    ['One', 'Two', 'Three', 'Four'],
    1,
    ('One and one make two.', 'One ଓ one ମିଶି two।', 'One और one मिलकर two होते हैं।'),
  ),
  _q(
    _words,
    ('Which word means more than one dog?', 'ଏକାଧିକ କୁକୁରକୁ କେଉଁ ଶବ୍ଦ ବୁଝାଏ?', 'एक से ज़्यादा कुत्तों के लिए कौन-सा शब्द है?'),
    ['Dog', 'Doges', 'Dogs', 'Doggy'],
    2,
    ('Add “s” for more than one: dog → dogs.', 'ଏକାଧିକ ପାଇଁ “s” ଯୋଡ଼: dog → dogs।', 'एक से ज़्यादा के लिए “s” जोड़ें: dog → dogs।'),
  ),
  _q(
    _sentences,
    ('Which sentence is correct?', 'କେଉଁ ବାକ୍ୟ ଠିକ୍?', 'कौन-सा वाक्य सही है?'),
    ['i am a boy.', 'I am a boy.', 'I a boy am.', 'am I a boy.'],
    1,
    ('“I” is always a capital letter, and a sentence starts with one.', '“I” ସର୍ବଦା ବଡ଼ ଅକ୍ଷର, ଏବଂ ବାକ୍ୟ ବଡ଼ ଅକ୍ଷରରେ ଆରମ୍ଭ ହୁଏ।', '“I” हमेशा बड़ा अक्षर होता है, और वाक्य बड़े अक्षर से शुरू होता है।'),
  ),
  _tf(
    _abc,
    ('There are 26 letters in the English alphabet.', 'ଇଂରାଜୀ ବର୍ଣ୍ଣମାଳାରେ 26ଟି ଅକ୍ଷର ଅଛି।', 'अंग्रेज़ी वर्णमाला में 26 अक्षर हैं।'),
    true,
    ('A to Z makes 26 letters.', 'A ରୁ Z ପର୍ଯ୍ୟନ୍ତ 26ଟି ଅକ୍ଷର।', 'A से Z तक 26 अक्षर हैं।'),
  ),
  _tf(
    _abc,
    ('“Z” is the first letter of the alphabet.', '“Z” ବର୍ଣ୍ଣମାଳାର ପ୍ରଥମ ଅକ୍ଷର।', '“Z” वर्णमाला का पहला अक्षर है।'),
    false,
    ('“A” is first; “Z” is the last letter.', '“A” ପ୍ରଥମ; “Z” ଶେଷ ଅକ୍ଷର।', '“A” पहला है; “Z” आखिरी अक्षर है।'),
  ),
  _tf(
    _words,
    ('“Red” is the name of a colour.', '“Red” ଏକ ରଙ୍ଗର ନାମ।', '“Red” एक रंग का नाम है।'),
    true,
    ('Red is a colour, like an apple.', 'Red (ନାଲି) ଏକ ରଙ୍ଗ, ସେଓ ପରି।', 'Red (लाल) एक रंग है, सेब जैसा।'),
  ),
  _tf(
    _sentences,
    ('A sentence ends with a full stop (.).', 'ବାକ୍ୟ ପୂର୍ଣ୍ଣଚ୍ଛେଦ (.) ରେ ଶେଷ ହୁଏ।', 'वाक्य पूर्ण विराम (.) पर खत्म होता है।'),
    true,
    ('Telling sentences end with a full stop; questions end with “?”.', 'ସାଧାରଣ ବାକ୍ୟ (.) ରେ, ପ୍ରଶ୍ନ “?” ରେ ଶେଷ ହୁଏ।', 'साधारण वाक्य (.) पर और प्रश्न “?” पर खत्म होते हैं।'),
  ),
  _fill(
    _sentences,
    ('This is ___ apple.', 'This is ___ apple.', 'This is ___ apple.'),
    ['a', 'an', 'the a', 'on'],
    1,
    ('Use “an” before a vowel sound: an apple.', 'ସ୍ୱର ଧ୍ୱନି ପୂର୍ବରୁ “an”: an apple।', 'स्वर ध्वनि से पहले “an”: an apple।'),
  ),
  _fill(
    _sentences,
    ('I ___ a girl.', 'I ___ a girl.', 'I ___ a girl.'),
    ['is', 'am', 'are', 'be'],
    1,
    ('With “I” we use “am”: I am.', '“I” ସହ “am”: I am।', '“I” के साथ “am”: I am।'),
  ),
  _fill(
    _words,
    ('A cow has four ___.', 'A cow has four ___.', 'A cow has four ___.'),
    ['legs', 'leg', 'wings', 'tails'],
    0,
    ('Four is more than one, so we say “legs”.', 'ଚାରି ଏକାଧିକ, ତେଣୁ “legs”।', 'चार एक से ज़्यादा है, इसलिए “legs”।'),
  ),
  _m(
    _words,
    ('Match each English word to its meaning.', 'ପ୍ରତ୍ୟେକ ଇଂରାଜୀ ଶବ୍ଦକୁ ତା’ର ଅର୍ଥ ସହ ମିଳାଅ।', 'हर अंग्रेज़ी शब्द को उसके अर्थ से मिलाओ।'),
    [
      (_w('Sun'), ('Sun', 'ସୂର୍ଯ୍ୟ', 'सूरज')),
      (_w('Water'), ('Water', 'ପାଣି', 'पानी')),
      (_w('Tree'), ('Tree', 'ଗଛ', 'पेड़')),
      (_w('Book'), ('Book', 'ବହି', 'किताब')),
    ],
    ('Learning word meanings helps us read.', 'ଶବ୍ଦର ଅର୍ଥ ଜାଣିଲେ ପଢ଼ିବା ସହଜ।', 'शब्दों के अर्थ जानने से पढ़ना आसान होता है।'),
  ),
  _m(
    _abc,
    ('Match each capital letter to its small letter.', 'ପ୍ରତ୍ୟେକ ବଡ଼ ଅକ୍ଷରକୁ ଛୋଟ ଅକ୍ଷର ସହ ମିଳାଅ।', 'हर बड़े अक्षर को उसके छोटे अक्षर से मिलाओ।'),
    [
      (_w('A'), _w('a')),
      (_w('D'), _w('d')),
      (_w('R'), _w('r')),
      (_w('Q'), _w('q')),
    ],
    ('Every letter has a capital and a small form.', 'ପ୍ରତ୍ୟେକ ଅକ୍ଷରର ବଡ଼ ଓ ଛୋଟ ରୂପ ଅଛି।', 'हर अक्षर का बड़ा और छोटा रूप होता है।'),
  ),
  _m(
    _words,
    ('Match each word to its opposite.', 'ପ୍ରତ୍ୟେକ ଶବ୍ଦକୁ ତା’ର ବିପରୀତ ସହ ମିଳାଅ।', 'हर शब्द को उसके उल्टे से मिलाओ।'),
    [
      (_w('Hot'), _w('Cold')),
      (_w('Day'), _w('Night')),
      (_w('Happy'), _w('Sad')),
      (_w('Open'), _w('Close')),
    ],
    ('Opposites mean completely different things.', 'ବିପରୀତ ଶବ୍ଦର ଅର୍ଥ ସମ୍ପୂର୍ଣ୍ଣ ଭିନ୍ନ।', 'उल्टे शब्दों का अर्थ बिल्कुल अलग होता है।'),
  ),
];
