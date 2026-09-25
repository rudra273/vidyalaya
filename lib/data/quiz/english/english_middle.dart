import '../quiz_models.dart';

// ─── English · Classes 6–8 ───

QuizQuestion _q(Tri p, List<String> o, int a, Tri e) => QuizQuestion.tri(
  QuizSubject.english,
  QuizBand.middle,
  p,
  [for (final s in o) (s, s, s)],
  a,
  e,
);

final englishMiddle = <QuizQuestion>[
  _q(
    (
      'Which sentence is in the passive voice?',
      'କେଉଁ ବାକ୍ୟ ଭାବବାଚ୍ୟ (passive voice)ରେ ଅଛି?',
      'कौन-सा वाक्य कर्मवाच्य (passive voice) में है?',
    ),
    [
      'The cat chased the mouse.',
      'The mouse was chased by the cat.',
      'The cat is chasing the mouse.',
      'The cat will chase the mouse.',
    ],
    1,
    (
      'In passive voice the object becomes the subject: was chased by.',
      'Passive voiceରେ କର୍ମ କର୍ତ୍ତା ହୋଇଯାଏ: was chased by।',
      'कर्मवाच्य में कर्म ही कर्ता बन जाता है: was chased by।',
    ),
  ),
  _q(
    (
      'Choose the correct form: If it rains, we ___ at home.',
      'ସଠିକ୍ ରୂପ ବାଛ: If it rains, we ___ at home.',
      'सही रूप चुनें: If it rains, we ___ at home.',
    ),
    ['stay', 'will stay', 'stayed', 'staying'],
    1,
    (
      'A real future condition uses will + verb in the main clause.',
      'ବାସ୍ତବ ଭବିଷ୍ୟତ ସର୍ତ୍ତରେ ମୁଖ୍ୟ ବାକ୍ୟରେ will + verb ଆସେ।',
      'भविष्य की वास्तविक शर्त में मुख्य वाक्य में will + verb आता है।',
    ),
  ),
  _q(
    (
      'What is the synonym of “rapid”?',
      '“rapid” ର ସମାର୍ଥକ ଶବ୍ଦ କଣ?',
      '“rapid” का समानार्थी क्या है?',
    ),
    ['Slow', 'Fast', 'Weak', 'Heavy'],
    1,
    ('Rapid means fast.', 'Rapid ର ଅର୍ଥ ଦ୍ରୁତ।', 'Rapid का अर्थ तेज़ है।'),
  ),
  _q(
    (
      'What is the antonym of “ancient”?',
      '“ancient” ର ବିପରୀତ ଶବ୍ଦ କଣ?',
      '“ancient” का विलोम क्या है?',
    ),
    ['Old', 'Modern', 'Historic', 'Past'],
    1,
    (
      'Ancient means very old; modern is its opposite.',
      'Ancient ମାନେ ବହୁତ ପୁରାତନ; modern ତା’ର ବିପରୀତ।',
      'Ancient का अर्थ बहुत पुराना है; modern उसका विलोम है।',
    ),
  ),
  _q(
    (
      'Choose the correct preposition: He is good ___ mathematics.',
      'ସଠିକ୍ ପ୍ରିପୋଜିସନ୍ ବାଛ: He is good ___ mathematics.',
      'सही Preposition चुनें: He is good ___ mathematics.',
    ),
    ['in', 'at', 'on', 'with'],
    1,
    (
      'We say “good at” a subject.',
      'ଆମେ “good at” କହୁ।',
      'हम “good at” कहते हैं।',
    ),
  ),
  _q(
    (
      'Which is a compound sentence?',
      'କେଉଁଟି ଯୌଗିକ ବାକ୍ୟ (compound sentence)?',
      'कौन-सा संयुक्त वाक्य (compound sentence) है?',
    ),
    [
      'I like tea.',
      'I like tea, but she likes coffee.',
      'Although I like tea, I drank milk.',
      'Drinking tea daily.',
    ],
    1,
    (
      'A compound sentence joins two main clauses with and, but or or.',
      'ଯୌଗିକ ବାକ୍ୟ ଦୁଇଟି ମୁଖ୍ୟ ବାକ୍ୟକୁ and, but ବା or ଦ୍ୱାରା ଯୋଡ଼େ।',
      'संयुक्त वाक्य दो मुख्य उपवाक्यों को and, but या or से जोड़ता है।',
    ),
  ),
  _q(
    (
      'Identify the adverb: She sang beautifully.',
      'Adverb ଚିହ୍ନାଅ: She sang beautifully.',
      'Adverb पहचानें: She sang beautifully.',
    ),
    ['She', 'sang', 'beautifully', 'None'],
    2,
    (
      'An adverb describes how an action is done.',
      'Adverb କାର୍ଯ୍ୟ କିପରି ହେଲା ଦର୍ଶାଏ।',
      'Adverb बताता है कि काम कैसे किया गया।',
    ),
  ),
  _q(
    (
      'Choose the correct past tense: He ___ his homework yesterday.',
      'ସଠିକ୍ ଅତୀତ କାଳ ବାଛ: He ___ his homework yesterday.',
      'सही भूतकाल चुनें: He ___ his homework yesterday.',
    ),
    ['do', 'did', 'done', 'does'],
    1,
    (
      'Yesterday points to the simple past: did.',
      'Yesterday ସରଳ ଅତୀତ କାଳ ଦର୍ଶାଏ: did।',
      'Yesterday सामान्य भूतकाल दर्शाता है: did।',
    ),
  ),
  _q(
    (
      'Which word is spelt correctly?',
      'କେଉଁ ଶବ୍ଦର ବନାନ ଠିକ୍?',
      'किस शब्द की वर्तनी सही है?',
    ),
    ['Neccessary', 'Necessary', 'Necesary', 'Necessery'],
    1,
    (
      'Necessary has one c and two s’s.',
      'Necessary ରେ ଗୋଟିଏ c ଓ ଦୁଇଟି s ଅଛି।',
      'Necessary में एक c और दो s होते हैं।',
    ),
  ),
  _q(
    (
      'What does the idiom “a piece of cake” mean?',
      '“a piece of cake” ବାକ୍ୟାଂଶର ଅର୍ଥ କଣ?',
      'मुहावरे “a piece of cake” का अर्थ क्या है?',
    ),
    ['A sweet dish', 'Very easy', 'Very costly', 'A gift'],
    1,
    (
      'It means something is very easy to do.',
      'ଏହାର ଅର୍ଥ କିଛି କାମ ବହୁତ ସହଜ।',
      'इसका अर्थ है कि कोई काम बहुत आसान है।',
    ),
  ),
  _q(
    ('Choose the correct sentence.', 'ସଠିକ୍ ବାକ୍ୟ ବାଛ।', 'सही वाक्य चुनें।'),
    [
      'Each of the boys have a pen.',
      'Each of the boys has a pen.',
      'Each of the boys are having pen.',
      'Each boys has a pen.',
    ],
    1,
    (
      '“Each” takes a singular verb: has.',
      '“Each” ସହ ଏକବଚନ କ୍ରିୟା ଆସେ: has।',
      '“Each” के साथ एकवचन क्रिया आती है: has।',
    ),
  ),
  _q(
    (
      'Which word is a conjunction?',
      'କେଉଁ ଶବ୍ଦ ସଂଯୋଜକ (conjunction)?',
      'कौन-सा शब्द संयोजक (conjunction) है?',
    ),
    ['Because', 'Table', 'Quickly', 'Beautiful'],
    0,
    (
      'A conjunction joins words or clauses. Because joins clauses.',
      'Conjunction ଶବ୍ଦ ବା ବାକ୍ୟାଂଶ ଯୋଡ଼େ। Because ବାକ୍ୟାଂଶ ଯୋଡ଼େ।',
      'संयोजक शब्दों या उपवाक्यों को जोड़ता है। Because उपवाक्य जोड़ता है।',
    ),
  ),
  _q(
    (
      'Change to indirect speech: He said, “I am tired.”',
      'ପରୋକ୍ଷ କଥନକୁ ବଦଳାଅ: He said, “I am tired.”',
      'अप्रत्यक्ष कथन में बदलें: He said, “I am tired.”',
    ),
    [
      'He said that he is tired.',
      'He said that he was tired.',
      'He said that I was tired.',
      'He says that he was tired.',
    ],
    1,
    (
      'In indirect speech, present tense shifts back: am → was.',
      'ପରୋକ୍ଷ କଥନରେ ବର୍ତ୍ତମାନ କାଳ ଅତୀତକୁ ଯାଏ: am → was।',
      'अप्रत्यक्ष कथन में वर्तमान काल भूतकाल हो जाता है: am → was।',
    ),
  ),
  _q(
    (
      'Which is the plural of “analysis”?',
      '“analysis” ର ବହୁବଚନ କଣ?',
      '“analysis” का बहुवचन क्या है?',
    ),
    ['Analysises', 'Analyses', 'Analysi', 'Analysis’s'],
    1,
    (
      'Words ending in -is change to -es: analyses.',
      '-is ରେ ଶେଷ ଶବ୍ଦ -es ହୁଏ: analyses।',
      '-is पर समाप्त शब्द -es हो जाते हैं: analyses।',
    ),
  ),
  _q(
    (
      'Identify the figure of speech: “The wind whispered.”',
      'ଅଳଙ୍କାର ଚିହ୍ନାଅ: “The wind whispered.”',
      'अलंकार पहचानें: “The wind whispered.”',
    ),
    ['Simile', 'Personification', 'Metaphor', 'Alliteration'],
    1,
    (
      'Giving human actions to non-living things is personification.',
      'ନିର୍ଜୀବ ବସ୍ତୁକୁ ମନୁଷ୍ୟ ଗୁଣ ଦେବା ହେଉଛି ପର୍ସନିଫିକେସନ୍।',
      'निर्जीव को मानवीय क्रिया देना मानवीकरण (personification) है।',
    ),
  ),
  _q(
    (
      'Choose the correct article: He is ___ honest man.',
      'ସଠିକ୍ ଆର୍ଟିକିଲ୍ ବାଛ: He is ___ honest man.',
      'सही आर्टिकल चुनें: He is ___ honest man.',
    ),
    ['a', 'an', 'the', 'no article'],
    1,
    (
      'Honest starts with a vowel sound (the h is silent), so we use “an”.',
      'Honest ସ୍ୱର ଧ୍ୱନିରେ ଆରମ୍ଭ (h ଅନୁଚ୍ଚାରିତ), ତେଣୁ “an”।',
      'Honest स्वर ध्वनि से शुरू होता है (h मौन है), इसलिए “an”।',
    ),
  ),
  _q(
    (
      'What is a synonym of “brave”?',
      '“brave” ର ସମାର୍ଥକ ଶବ୍ଦ କଣ?',
      '“brave” का समानार्थी क्या है?',
    ),
    ['Afraid', 'Courageous', 'Lazy', 'Shy'],
    1,
    (
      'Brave and courageous mean the same.',
      'Brave ଓ courageous ର ଅର୍ଥ ସମାନ।',
      'Brave और courageous का अर्थ एक ही है।',
    ),
  ),
  _q(
    (
      'Which is a proper noun?',
      'କେଉଁଟି ନାମବାଚକ ସଂଜ୍ଞା (proper noun)?',
      'कौन-सा व्यक्तिवाचक संज्ञा (proper noun) है?',
    ),
    ['city', 'Cuttack', 'river', 'school'],
    1,
    (
      'A proper noun names a particular person or place and starts with a capital.',
      'Proper noun ଏକ ନିର୍ଦ୍ଦିଷ୍ଟ ବ୍ୟକ୍ତି ବା ସ୍ଥାନର ନାମ ଓ ବଡ଼ ଅକ୍ଷରରେ ଆରମ୍ଭ।',
      'व्यक्तिवाचक संज्ञा किसी विशेष व्यक्ति या स्थान का नाम है और बड़े अक्षर से शुरू होती है।',
    ),
  ),
  _q(
    (
      'Fill in the blank: I have lived here ___ 2015.',
      'ଶୂନ୍ୟସ୍ଥାନ ପୂରଣ କର: I have lived here ___ 2015.',
      'रिक्त स्थान भरें: I have lived here ___ 2015.',
    ),
    ['for', 'since', 'from', 'during'],
    1,
    (
      'Use “since” with a point in time.',
      'ନିର୍ଦ୍ଦିଷ୍ଟ ସମୟ ବିନ୍ଦୁ ସହ “since” ବ୍ୟବହାର କର।',
      'समय के किसी बिंदु के साथ “since” का प्रयोग करें।',
    ),
  ),
  _q(
    (
      'What is the meaning of “benevolent”?',
      '“benevolent” ର ଅର୍ଥ କଣ?',
      '“benevolent” का अर्थ क्या है?',
    ),
    ['Kind and generous', 'Angry', 'Careless', 'Proud'],
    0,
    (
      'Benevolent means kind and well-meaning.',
      'Benevolent ର ଅର୍ଥ ଦୟାଳୁ ଓ ଉଦାର।',
      'Benevolent का अर्थ दयालु और उदार है।',
    ),
  ),
];
