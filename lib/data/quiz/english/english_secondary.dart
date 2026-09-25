import '../quiz_models.dart';

// ─── English · Classes 9–10 ───

QuizQuestion _q(Tri p, List<String> o, int a, Tri e) => QuizQuestion.tri(
  QuizSubject.english,
  QuizBand.secondary,
  p,
  [for (final s in o) (s, s, s)],
  a,
  e,
);

final englishSecondary = <QuizQuestion>[
  _q(
    ('Choose the correct sentence.', 'ସଠିକ୍ ବାକ୍ୟ ବାଛ।', 'सही वाक्य चुनें।'),
    [
      'Neither of them are coming.',
      'Neither of them is coming.',
      'Neither of them were coming.',
      'Neither of them be coming.',
    ],
    1,
    (
      '“Neither” is singular and takes “is”.',
      '“Neither” ଏକବଚନ, ତେଣୁ “is” ଆସେ।',
      '“Neither” एकवचन है, इसलिए “is” आता है।',
    ),
  ),
  _q(
    (
      'Which sentence uses the subjunctive mood correctly?',
      'କେଉଁ ବାକ୍ୟ ସବଜଙ୍କ୍ଟିଭ୍ ମୁଡ୍ ଠିକ୍ ଭାବେ ବ୍ୟବହାର କରିଛି?',
      'किस वाक्य में subjunctive mood सही है?',
    ),
    [
      'If I was you, I would go.',
      'If I were you, I would go.',
      'If I am you, I will go.',
      'If I be you, I would go.',
    ],
    1,
    (
      'Use “were” for an imaginary condition.',
      'କାଳ୍ପନିକ ସର୍ତ୍ତ ପାଇଁ “were” ବ୍ୟବହାର କର।',
      'काल्पनिक शर्त के लिए “were” का प्रयोग करें।',
    ),
  ),
  _q(
    (
      'Choose the correct reported speech: She said, “I will call you tomorrow.”',
      'ପରୋକ୍ଷ କଥନ ବାଛ: She said, “I will call you tomorrow.”',
      'सही अप्रत्यक्ष कथन चुनें: She said, “I will call you tomorrow.”',
    ),
    [
      'She said that she will call me tomorrow.',
      'She said that she would call me the next day.',
      'She said that I would call her tomorrow.',
      'She said that she calls me tomorrow.',
    ],
    1,
    (
      'Will → would, and tomorrow → the next day.',
      'Will → would, tomorrow → the next day।',
      'Will → would और tomorrow → the next day हो जाता है।',
    ),
  ),
  _q(
    (
      'What is the meaning of “ubiquitous”?',
      '“ubiquitous” ର ଅର୍ଥ କଣ?',
      '“ubiquitous” का अर्थ क्या है?',
    ),
    ['Rare', 'Found everywhere', 'Ancient', 'Dangerous'],
    1,
    (
      'Ubiquitous means present everywhere.',
      'Ubiquitous ର ଅର୍ଥ ସର୍ବତ୍ର ଉପସ୍ଥିତ।',
      'Ubiquitous का अर्थ हर जगह मौजूद है।',
    ),
  ),
  _q(
    (
      'Identify the figure of speech: “Life is a journey.”',
      'ଅଳଙ୍କାର ଚିହ୍ନାଅ: “Life is a journey.”',
      'अलंकार पहचानें: “Life is a journey.”',
    ),
    ['Simile', 'Metaphor', 'Hyperbole', 'Irony'],
    1,
    (
      'A metaphor compares two things directly without “like” or “as”.',
      'Metaphor “like” ବା “as” ବିନା ଦୁଇ ବସ୍ତୁକୁ ସିଧାସଳଖ ତୁଳନା କରେ।',
      'रूपक (metaphor) “like” या “as” के बिना दो चीज़ों की सीधी तुलना करता है।',
    ),
  ),
  _q(
    (
      'Which is the correct passive form of “They are building a bridge”?',
      '“They are building a bridge” ର ସଠିକ୍ ପ୍ୟାସିଭ୍ ରୂପ କେଉଁଟି?',
      '“They are building a bridge” का सही passive रूप कौन-सा है?',
    ),
    [
      'A bridge is built by them.',
      'A bridge is being built by them.',
      'A bridge was being built by them.',
      'A bridge has been built by them.',
    ],
    1,
    (
      'Present continuous passive: is/are being + past participle.',
      'ବର୍ତ୍ତମାନ ଚାଲୁ passive: is/are being + past participle।',
      'Present continuous का passive: is/are being + past participle।',
    ),
  ),
  _q(
    (
      'Choose the word closest in meaning to “ephemeral”.',
      '“ephemeral” ର ସବୁଠାରୁ ପାଖ ଅର୍ଥର ଶବ୍ଦ ବାଛ।',
      '“ephemeral” के सबसे निकट अर्थ वाला शब्द चुनें।',
    ),
    ['Lasting', 'Short-lived', 'Solid', 'Famous'],
    1,
    (
      'Ephemeral means lasting only a short time.',
      'Ephemeral ର ଅର୍ଥ ଅଳ୍ପ ସମୟ ପାଇଁ ରହୁଥିବା।',
      'Ephemeral का अर्थ बहुत थोड़े समय तक रहने वाला है।',
    ),
  ),
  _q(
    (
      'Fill in the blank: Hardly ___ the station when the train left.',
      'ଶୂନ୍ୟସ୍ଥାନ ପୂରଣ କର: Hardly ___ the station when the train left.',
      'रिक्त स्थान भरें: Hardly ___ the station when the train left.',
    ),
    ['I reached', 'had I reached', 'I had reached', 'did I reach'],
    1,
    (
      '“Hardly” at the start needs inversion: had I reached.',
      'ବାକ୍ୟ ଆରମ୍ଭରେ “Hardly” ଥିଲେ ଉଲଟା କ୍ରମ ହୁଏ: had I reached।',
      'वाक्य के आरंभ में “Hardly” हो तो क्रम उलट जाता है: had I reached।',
    ),
  ),
  _q(
    (
      'Which sentence contains a dangling modifier?',
      'କେଉଁ ବାକ୍ୟରେ ଡେଙ୍ଗଲିଂ ମଡିଫାୟର୍ ଅଛି?',
      'किस वाक्य में dangling modifier है?',
    ),
    [
      'Walking home, I saw a rainbow.',
      'Walking home, a rainbow appeared.',
      'While I was walking home, I saw a rainbow.',
      'I saw a rainbow while walking home.',
    ],
    1,
    (
      '“Walking home” should modify a person, not a rainbow.',
      '“Walking home” ଜଣେ ବ୍ୟକ୍ତିକୁ ବୁଝାଇବା କଥା, ଇନ୍ଦ୍ରଧନୁକୁ ନୁହେଁ।',
      '“Walking home” किसी व्यक्ति के लिए होना चाहिए, इंद्रधनुष के लिए नहीं।',
    ),
  ),
  _q(
    (
      'What is the antonym of “verbose”?',
      '“verbose” ର ବିପରୀତ ଶବ୍ଦ କଣ?',
      '“verbose” का विलोम क्या है?',
    ),
    ['Wordy', 'Concise', 'Loud', 'Elaborate'],
    1,
    (
      'Verbose means using too many words; concise means using few.',
      'Verbose ମାନେ ଅତ୍ୟଧିକ ଶବ୍ଦ ବ୍ୟବହାର; concise ମାନେ ସଂକ୍ଷିପ୍ତ।',
      'Verbose का अर्थ बहुत शब्द प्रयोग करना है; concise का अर्थ संक्षिप्त है।',
    ),
  ),
  _q(
    ('Choose the correct sentence.', 'ସଠିକ୍ ବାକ୍ୟ ବାଛ।', 'सही वाक्य चुनें।'),
    [
      'The team have won its match.',
      'The team has won its match.',
      'The team have won their match yesterday.',
      'The team are won.',
    ],
    1,
    (
      'A collective noun acting as one unit takes a singular verb.',
      'ଏକକ ଭାବେ କାମ କରୁଥିବା collective noun ସହ ଏକବଚନ କ୍ରିୟା ଆସେ।',
      'एक इकाई के रूप में काम करने वाली समूहवाचक संज्ञा के साथ एकवचन क्रिया आती है।',
    ),
  ),
  _q(
    (
      'Which word is a homophone of “knight”?',
      '“knight” ର homophone କେଉଁଟି?',
      '“knight” का homophone कौन-सा है?',
    ),
    ['Kite', 'Night', 'Nut', 'Neat'],
    1,
    (
      'Knight and night sound the same but differ in meaning.',
      'Knight ଓ night ଉଚ୍ଚାରଣ ସମାନ କିନ୍ତୁ ଅର୍ଥ ଭିନ୍ନ।',
      'Knight और night का उच्चारण समान है पर अर्थ अलग हैं।',
    ),
  ),
  _q(
    (
      'Which is the correct use of the semicolon?',
      'ସେମିକୋଲନ୍‌ର ସଠିକ୍ ବ୍ୟବହାର କେଉଁଟି?',
      'सेमीकोलन का सही प्रयोग कौन-सा है?',
    ),
    [
      'I like tea; but not coffee.',
      'I like tea; she likes coffee.',
      'I like; tea and coffee.',
      'I; like tea.',
    ],
    1,
    (
      'A semicolon joins two closely related independent clauses.',
      'ସେମିକୋଲନ୍ ଦୁଇଟି ସମ୍ପର୍କିତ ସ୍ୱାଧୀନ ବାକ୍ୟାଂଶକୁ ଯୋଡ଼େ।',
      'सेमीकोलन दो संबंधित स्वतंत्र उपवाक्यों को जोड़ता है।',
    ),
  ),
  _q(
    (
      'Choose the correct word: The doctor’s advice had a great ___ on him.',
      'ସଠିକ୍ ଶବ୍ଦ ବାଛ: The doctor’s advice had a great ___ on him.',
      'सही शब्द चुनें: The doctor’s advice had a great ___ on him.',
    ),
    ['affect', 'effect', 'affection', 'effort'],
    1,
    (
      '“Effect” is the noun meaning result; “affect” is usually a verb.',
      '“Effect” ବିଶେଷ୍ୟ, ଅର୍ଥ ପ୍ରଭାବ; “affect” ସାଧାରଣତଃ କ୍ରିୟା।',
      '“Effect” संज्ञा है (प्रभाव); “affect” सामान्यतः क्रिया है।',
    ),
  ),
  _q(
    (
      'What does the idiom “break the ice” mean?',
      '“break the ice” ବାକ୍ୟାଂଶର ଅର୍ଥ କଣ?',
      'मुहावरे “break the ice” का अर्थ क्या है?',
    ),
    [
      'Start a conversation in an awkward situation',
      'Break something cold',
      'Cause a quarrel',
      'Cancel a plan',
    ],
    0,
    (
      'It means to ease tension and begin a friendly talk.',
      'ଏହାର ଅର୍ଥ ସଙ୍କୋଚ ଦୂର କରି କଥାବାର୍ତ୍ତା ଆରମ୍ଭ କରିବା।',
      'इसका अर्थ है झिझक तोड़कर बातचीत शुरू करना।',
    ),
  ),
  _q(
    (
      'Identify the tense: “By next June, she will have finished her course.”',
      'କାଳ ଚିହ୍ନାଅ: “By next June, she will have finished her course.”',
      'काल पहचानें: “By next June, she will have finished her course.”',
    ),
    ['Simple future', 'Future perfect', 'Future continuous', 'Present perfect'],
    1,
    (
      'will have + past participle is the future perfect tense.',
      'will have + past participle ହେଉଛି future perfect।',
      'will have + past participle future perfect है।',
    ),
  ),
  _q(
    (
      'Choose the correct pair: “Either … ___”',
      'ସଠିକ୍ ଯୋଡ଼ି ବାଛ: “Either … ___”',
      'सही जोड़ी चुनें: “Either … ___”',
    ),
    ['nor', 'or', 'and', 'but'],
    1,
    (
      '“Either” pairs with “or”; “neither” pairs with “nor”.',
      '“Either” ସହ “or”; “neither” ସହ “nor”।',
      '“Either” के साथ “or”; “neither” के साथ “nor” आता है।',
    ),
  ),
  _q(
    (
      'Which word is an example of onomatopoeia?',
      'କେଉଁ ଶବ୍ଦ ଅନୋମାଟୋପିଆର ଉଦାହରଣ?',
      'कौन-सा शब्द onomatopoeia का उदाहरण है?',
    ),
    ['Table', 'Buzz', 'Happy', 'Green'],
    1,
    (
      'Onomatopoeia is a word that imitates a sound, like buzz.',
      'Onomatopoeia ଏକ ଧ୍ୱନିର ଅନୁକରଣ କରୁଥିବା ଶବ୍ଦ, ଯେପରି buzz।',
      'Onomatopoeia ध्वनि की नकल करने वाला शब्द है, जैसे buzz।',
    ),
  ),
  _q(
    (
      'Choose the sentence with correct punctuation.',
      'ସଠିକ୍ ବିରାମ ଚିହ୍ନ ଥିବା ବାକ୍ୟ ବାଛ।',
      'सही विराम चिह्न वाला वाक्य चुनें।',
    ),
    [
      'Its a lovely day.',
      'It’s a lovely day.',
      'Its’ a lovely day.',
      'It’s’ a lovely day.',
    ],
    1,
    (
      'It’s is the short form of “it is”. “Its” shows possession.',
      'It’s ମାନେ “it is”। “Its” ଅଧିକାର ଦର୍ଶାଏ।',
      'It’s का अर्थ “it is” है। “Its” स्वामित्व दर्शाता है।',
    ),
  ),
];
