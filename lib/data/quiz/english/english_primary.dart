import '../quiz_models.dart';

// ─── English · Classes 3–5 ───

QuizQuestion _q(Tri p, List<String> o, int a, Tri e) => QuizQuestion.tri(
  QuizSubject.english,
  QuizBand.primary,
  p,
  [for (final s in o) (s, s, s)],
  a,
  e,
);

final englishPrimary = <QuizQuestion>[
  _q(
    (
      'Choose the correct article: ___ apple a day keeps the doctor away.',
      'ସଠିକ୍ ଆର୍ଟିକିଲ୍ ବାଛ: ___ apple a day keeps the doctor away.',
      'सही आर्टिकल चुनें: ___ apple a day keeps the doctor away.',
    ),
    ['A', 'An', 'The', 'No article'],
    1,
    (
      'Use “an” before a vowel sound.',
      'ସ୍ୱରଧ୍ୱନି ପୂର୍ବରୁ “an” ବ୍ୟବହାର କର।',
      'स्वर ध्वनि से पहले “an” का प्रयोग करें।',
    ),
  ),
  _q(
    (
      'Which word is a noun?',
      'କେଉଁ ଶବ୍ଦଟି ବିଶେଷ୍ୟ (noun)?',
      'कौन-सा शब्द संज्ञा (noun) है?',
    ),
    ['Run', 'Beautiful', 'Table', 'Quickly'],
    2,
    (
      'A noun names a person, place or thing. Table is a thing.',
      'Noun କୌଣସି ବ୍ୟକ୍ତି, ସ୍ଥାନ ବା ବସ୍ତୁର ନାମ। Table ଏକ ବସ୍ତୁ।',
      'संज्ञा किसी व्यक्ति, स्थान या वस्तु का नाम होती है। Table एक वस्तु है।',
    ),
  ),
  _q(
    (
      'Which word is a verb?',
      'କେଉଁ ଶବ୍ଦଟି କ୍ରିୟା (verb)?',
      'कौन-सा शब्द क्रिया (verb) है?',
    ),
    ['Happy', 'Jump', 'Blue', 'Book'],
    1,
    (
      'A verb shows an action. Jump is an action.',
      'Verb କାର୍ଯ୍ୟ ଦର୍ଶାଏ। Jump ଏକ କାର୍ଯ୍ୟ।',
      'क्रिया काम को दर्शाती है। Jump एक काम है।',
    ),
  ),
  _q(
    (
      'Choose the plural of “child”.',
      '“child” ର ବହୁବଚନ ବାଛ।',
      '“child” का बहुवचन चुनें।',
    ),
    ['Childs', 'Childes', 'Children', 'Childrens'],
    2,
    (
      'Child has an irregular plural: children.',
      'Child ର ବହୁବଚନ ଅନିୟମିତ: children।',
      'Child का बहुवचन अनियमित है: children।',
    ),
  ),
  _q(
    (
      'Choose the opposite of “hot”.',
      '“hot” ର ବିପରୀତ ଶବ୍ଦ ବାଛ।',
      '“hot” का विलोम चुनें।',
    ),
    ['Warm', 'Cold', 'Boiling', 'Sunny'],
    1,
    (
      'Hot and cold are opposites.',
      'Hot ଓ cold ବିପରୀତ ଶବ୍ଦ।',
      'Hot और cold विलोम शब्द हैं।',
    ),
  ),
  _q(
    (
      'Fill in the blank: She ___ to school every day.',
      'ଶୂନ୍ୟସ୍ଥାନ ପୂରଣ କର: She ___ to school every day.',
      'रिक्त स्थान भरें: She ___ to school every day.',
    ),
    ['go', 'goes', 'going', 'gone'],
    1,
    (
      'With “she”, add -es to the verb: goes.',
      '“she” ସହ କ୍ରିୟାରେ -es ଯୋଗ ହୁଏ: goes।',
      '“she” के साथ क्रिया में -es लगता है: goes।',
    ),
  ),
  _q(
    (
      'Which sentence is correct?',
      'କେଉଁ ବାକ୍ୟଟି ଠିକ୍?',
      'कौन-सा वाक्य सही है?',
    ),
    ['He are a boy.', 'He is a boy.', 'He am a boy.', 'He be a boy.'],
    1,
    (
      'Use “is” with he, she and it.',
      'he, she, it ସହ “is” ବ୍ୟବହାର କର।',
      'he, she, it के साथ “is” का प्रयोग करें।',
    ),
  ),
  _q(
    (
      'Choose the past tense of “play”.',
      '“play” ର ଅତୀତ କାଳ ରୂପ ବାଛ।',
      '“play” का भूतकाल रूप चुनें।',
    ),
    ['Plays', 'Played', 'Playing', 'Plaied'],
    1,
    (
      'Add -ed to make the past tense of regular verbs.',
      'ନିୟମିତ କ୍ରିୟାର ଅତୀତ କାଳ ପାଇଁ -ed ଯୋଗ କର।',
      'नियमित क्रियाओं का भूतकाल बनाने के लिए -ed जोड़ें।',
    ),
  ),
  _q(
    (
      'What is the synonym of “big”?',
      '“big” ର ସମାର୍ଥକ ଶବ୍ଦ କଣ?',
      '“big” का समानार्थी शब्द क्या है?',
    ),
    ['Small', 'Large', 'Tiny', 'Thin'],
    1,
    (
      'Big and large mean the same.',
      'Big ଓ large ର ଅର୍ଥ ସମାନ।',
      'Big और large का अर्थ एक ही है।',
    ),
  ),
  _q(
    (
      'Which word is an adjective?',
      'କେଉଁ ଶବ୍ଦଟି ବିଶେଷଣ (adjective)?',
      'कौन-सा शब्द विशेषण (adjective) है?',
    ),
    ['Slowly', 'Tall', 'Sing', 'Girl'],
    1,
    (
      'An adjective describes a noun. Tall describes a person or thing.',
      'Adjective ବିଶେଷ୍ୟକୁ ବର୍ଣ୍ଣନା କରେ। Tall ତାହା କରେ।',
      'विशेषण संज्ञा का वर्णन करता है। Tall यही करता है।',
    ),
  ),
  _q(
    ('Choose the correct spelling.', 'ସଠିକ୍ ବନାନ ବାଛ।', 'सही वर्तनी चुनें।'),
    ['Freind', 'Friend', 'Frend', 'Firend'],
    1,
    (
      'Remember: “i before e” — fr-i-e-nd.',
      'ମନେରଖ: “i before e” — fr-i-e-nd।',
      'याद रखें: “i before e” — fr-i-e-nd।',
    ),
  ),
  _q(
    (
      'Which punctuation mark ends a question?',
      'କେଉଁ ଚିହ୍ନ ପ୍ରଶ୍ନ ଶେଷରେ ବସେ?',
      'प्रश्न के अंत में कौन-सा चिह्न लगता है?',
    ),
    ['. (full stop)', '? (question mark)', '! (exclamation mark)', ', (comma)'],
    1,
    (
      'A question ends with a question mark.',
      'ପ୍ରଶ୍ନ ଶେଷରେ ପ୍ରଶ୍ନବାଚକ ଚିହ୍ନ (?) ବସେ।',
      'प्रश्न के अंत में प्रश्नवाचक चिह्न (?) लगता है।',
    ),
  ),
  _q(
    (
      'Fill in the blank: The cat is sitting ___ the table.',
      'ଶୂନ୍ୟସ୍ଥାନ ପୂରଣ କର: The cat is sitting ___ the table.',
      'रिक्त स्थान भरें: The cat is sitting ___ the table.',
    ),
    ['on', 'in', 'at', 'of'],
    0,
    (
      '“On” shows something resting on a surface.',
      'କୌଣସି ପୃଷ୍ଠ ଉପରେ ଥିବା ବୁଝାଇବାକୁ “on” ବ୍ୟବହୃତ ହୁଏ।',
      'किसी सतह के ऊपर होना बताने के लिए “on” आता है।',
    ),
  ),
  _q(
    (
      'Which is a pronoun?',
      'କେଉଁଟି ସର୍ବନାମ (pronoun)?',
      'कौन-सा सर्वनाम (pronoun) है?',
    ),
    ['Ram', 'They', 'Run', 'Green'],
    1,
    (
      'A pronoun takes the place of a noun.',
      'Pronoun noun ବଦଳରେ ବ୍ୟବହୃତ ହୁଏ।',
      'सर्वनाम संज्ञा के स्थान पर आता है।',
    ),
  ),
  _q(
    (
      'Choose the plural of “box”.',
      '“box” ର ବହୁବଚନ ବାଛ।',
      '“box” का बहुवचन चुनें।',
    ),
    ['Boxs', 'Boxes', 'Boxies', 'Box'],
    1,
    (
      'Add -es after words ending in x.',
      'x ରେ ଶେଷ ହେଉଥିବା ଶବ୍ଦରେ -es ଯୋଗ କର।',
      'x पर समाप्त होने वाले शब्दों में -es जोड़ें।',
    ),
  ),
  _q(
    (
      'What is the opposite of “up”?',
      '“up” ର ବିପରୀତ ଶବ୍ଦ କଣ?',
      '“up” का विलोम क्या है?',
    ),
    ['Over', 'Down', 'Above', 'High'],
    1,
    (
      'Up and down are opposites.',
      'Up ଓ down ବିପରୀତ ଶବ୍ଦ।',
      'Up और down विलोम शब्द हैं।',
    ),
  ),
  _q(
    (
      'Which word starts with a vowel?',
      'କେଉଁ ଶବ୍ଦ ସ୍ୱରବର୍ଣ୍ଣରେ ଆରମ୍ଭ ହୁଏ?',
      'किस शब्द की शुरुआत स्वर से होती है?',
    ),
    ['Book', 'Umbrella', 'Pen', 'Dog'],
    1,
    (
      'The vowels are a, e, i, o, u. Umbrella starts with u.',
      'ସ୍ୱରବର୍ଣ୍ଣ a, e, i, o, u। Umbrella u ରେ ଆରମ୍ଭ।',
      'स्वर a, e, i, o, u हैं। Umbrella u से शुरू होता है।',
    ),
  ),
  _q(
    (
      'Fill in the blank: I ___ a book now.',
      'ଶୂନ୍ୟସ୍ଥାନ ପୂରଣ କର: I ___ a book now.',
      'रिक्त स्थान भरें: I ___ a book now.',
    ),
    ['read', 'am reading', 'reads', 'readed'],
    1,
    (
      'An action happening now uses “am/is/are + verb-ing”.',
      'ବର୍ତ୍ତମାନ ଚାଲିଥିବା କାର୍ଯ୍ୟ ପାଇଁ “am/is/are + verb-ing” ବ୍ୟବହୃତ ହୁଏ।',
      'अभी हो रहे काम के लिए “am/is/are + verb-ing” आता है।',
    ),
  ),
  _q(
    (
      'Which sentence starts with a capital letter correctly?',
      'କେଉଁ ବାକ୍ୟ ବଡ଼ ଅକ୍ଷରରେ ଠିକ୍ ଭାବେ ଆରମ୍ଭ?',
      'कौन-सा वाक्य बड़े अक्षर से सही शुरू होता है?',
    ),
    [
      'my name is Riya.',
      'My name is Riya.',
      'my Name is Riya.',
      'my name Is riya.',
    ],
    1,
    (
      'A sentence and names begin with capital letters.',
      'ବାକ୍ୟ ଓ ନାମ ବଡ଼ ଅକ୍ଷରରେ ଆରମ୍ଭ ହୁଏ।',
      'वाक्य और नाम बड़े अक्षर से शुरू होते हैं।',
    ),
  ),
  _q(
    (
      'How many days are in a week?',
      'ଏକ ସପ୍ତାହରେ କେତେ ଦିନ?',
      'एक सप्ताह में कितने दिन होते हैं?',
    ),
    ['5', '6', '7', '8'],
    2,
    (
      'There are seven days in a week.',
      'ଏକ ସପ୍ତାହରେ ସାତ ଦିନ ଥାଏ।',
      'एक सप्ताह में सात दिन होते हैं।',
    ),
  ),
];
