import '../quiz_models.dart';

// ─── Social Science · Classes 1–2 ─────────────────────────────────────────────

const _k = QuizKit(QuizSubject.social, QuizBand.early);
final _q = _k.choice, _tf = _k.trueFalse, _fill = _k.fillBlank, _m = _k.match;

const _family = 'Family & school';
const _helpers = 'Helpers & places';
const _india = 'Our country';

final socialEarly = <QuizQuestion>[
  _q(
    _family,
    ('Who is your father’s mother?', 'ତୁମ ବାପାଙ୍କ ମା କିଏ?', 'तुम्हारे पिता की माँ कौन हैं?'),
    [
      ('Aunt', 'ପିଉସୀ', 'बुआ'),
      ('Grandmother', 'ଜେଜେମା', 'दादी'),
      ('Sister', 'ଭଉଣୀ', 'बहन'),
      ('Cousin', 'ମାମୁଁ ଭାଇ', 'चचेरा भाई'),
    ],
    1,
    ('Your father’s mother is your grandmother.', 'ବାପାଙ୍କ ମା ତୁମର ଜେଜେମା।', 'पिता की माँ तुम्हारी दादी हैं।'),
  ),
  _q(
    _family,
    ('Who teaches us in school?', 'ବିଦ୍ୟାଳୟରେ ଆମକୁ କିଏ ପଢ଼ାନ୍ତି?', 'स्कूल में हमें कौन पढ़ाता है?'),
    [
      ('Teacher', 'ଶିକ୍ଷକ', 'शिक्षक'),
      ('Driver', 'ଡ୍ରାଇଭର', 'ड्राइवर'),
      ('Cook', 'ରୋଷେୟା', 'रसोइया'),
      ('Tailor', 'ଦରଜି', 'दर्ज़ी'),
    ],
    0,
    ('Teachers help us learn to read, write and count.', 'ଶିକ୍ଷକ ଆମକୁ ପଢ଼ିବା, ଲେଖିବା ଓ ଗଣିବା ଶିଖାନ୍ତି।', 'शिक्षक हमें पढ़ना, लिखना और गिनना सिखाते हैं।'),
  ),
  _q(
    _family,
    ('What should we do with litter?', 'ଅଳିଆକୁ ଆମେ କ’ଣ କରିବା ଉଚିତ?', 'कचरे का हमें क्या करना चाहिए?'),
    [
      ('Throw it on the road', 'ରାସ୍ତାରେ ପକାଇବା', 'सड़क पर फेंकना'),
      ('Put it in a dustbin', 'ଡଷ୍ଟବିନରେ ପକାଇବା', 'कूड़ेदान में डालना'),
      ('Hide it under the desk', 'ଡେସ୍କ ତଳେ ଲୁଚାଇବା', 'डेस्क के नीचे छिपाना'),
      ('Throw it in the pond', 'ପୋଖରୀରେ ପକାଇବା', 'तालाब में फेंकना'),
    ],
    1,
    ('Using a dustbin keeps our school and town clean.', 'ଡଷ୍ଟବିନ ବ୍ୟବହାର କଲେ ବିଦ୍ୟାଳୟ ଓ ସହର ସଫା ରହେ।', 'कूड़ेदान इस्तेमाल करने से स्कूल और शहर साफ़ रहते हैं।'),
  ),
  _q(
    _helpers,
    ('Who brings letters to our home?', 'ଆମ ଘରକୁ ଚିଠି କିଏ ଆଣନ୍ତି?', 'हमारे घर चिट्ठियाँ कौन लाता है?'),
    [
      ('Farmer', 'ଚାଷୀ', 'किसान'),
      ('Postman', 'ଡାକପିଅନ', 'डाकिया'),
      ('Barber', 'ଭଣ୍ଡାରି', 'नाई'),
      ('Potter', 'କୁମ୍ଭାର', 'कुम्हार'),
    ],
    1,
    ('The postman delivers letters and parcels.', 'ଡାକପିଅନ ଚିଠି ଓ ପାର୍ସଲ ପହଞ୍ଚାନ୍ତି।', 'डाकिया चिट्ठियाँ और पार्सल पहुँचाता है।'),
  ),
  _q(
    _helpers,
    ('Who puts out fires?', 'ନିଆଁ କିଏ ଲିଭାନ୍ତି?', 'आग कौन बुझाता है?'),
    [
      ('Firefighter', 'ଦମକଳ କର୍ମୀ', 'अग्निशामक'),
      ('Carpenter', 'ବଢ଼େଇ', 'बढ़ई'),
      ('Shopkeeper', 'ଦୋକାନୀ', 'दुकानदार'),
      ('Painter', 'ରଙ୍ଗ କାରିଗର', 'पेंटर'),
    ],
    0,
    ('Firefighters use water and fire engines to put out fires.', 'ଦମକଳ କର୍ମୀ ପାଣି ଓ ଦମକଳ ଗାଡ଼ିରେ ନିଆଁ ଲିଭାନ୍ତି।', 'अग्निशामक पानी और दमकल गाड़ी से आग बुझाते हैं।'),
  ),
  _q(
    _helpers,
    ('Where do we go to borrow books?', 'ବହି ଧାର ନେବାକୁ ଆମେ କେଉଁଠିକୁ ଯାଉ?', 'किताबें उधार लेने हम कहाँ जाते हैं?'),
    [
      ('Library', 'ପାଠାଗାର', 'पुस्तकालय'),
      ('Bank', 'ବ୍ୟାଙ୍କ', 'बैंक'),
      ('Hospital', 'ଡାକ୍ତରଖାନା', 'अस्पताल'),
      ('Market', 'ବଜାର', 'बाज़ार'),
    ],
    0,
    ('A library lends books for us to read.', 'ପାଠାଗାର ଆମକୁ ପଢ଼ିବାକୁ ବହି ଦିଏ।', 'पुस्तकालय हमें पढ़ने के लिए किताबें देता है।'),
  ),
  _q(
    _helpers,
    ('At a traffic light, red means…', 'ଟ୍ରାଫିକ ଆଲୋକରେ ନାଲି ଅର୍ଥ…', 'ट्रैफ़िक लाइट पर लाल का मतलब है…'),
    [
      ('Go', 'ଯାଅ', 'चलो'),
      ('Stop', 'ଅଟକ', 'रुको'),
      ('Run', 'ଦୌଡ଼', 'दौड़ो'),
      ('Turn back', 'ଫେରିଯାଅ', 'पीछे मुड़ो'),
    ],
    1,
    ('Red means stop, yellow means wait, green means go.', 'ନାଲି ଅଟକ, ହଳଦିଆ ଅପେକ୍ଷା, ସବୁଜ ଯାଅ।', 'लाल रुको, पीला रुको-देखो, हरा चलो।'),
  ),
  _q(
    _india,
    ('What colour is the wheel on the Indian flag?', 'ଭାରତୀୟ ପତାକାର ଚକ କେଉଁ ରଙ୍ଗର?', 'भारतीय झंडे के चक्र का रंग क्या है?'),
    [
      ('Green', 'ସବୁଜ', 'हरा'),
      ('Navy blue', 'ଗାଢ଼ ନୀଳ', 'गहरा नीला'),
      ('Saffron', 'ଗେରୁଆ', 'केसरिया'),
      ('Red', 'ନାଲି', 'लाल'),
    ],
    1,
    ('The Ashoka Chakra in the middle is navy blue.', 'ମଝିରେ ଥିବା ଅଶୋକ ଚକ୍ର ଗାଢ଼ ନୀଳ।', 'बीच का अशोक चक्र गहरे नीले रंग का है।'),
  ),
  _q(
    _india,
    ('Which is the national flower of India?', 'ଭାରତର ଜାତୀୟ ଫୁଲ କେଉଁଟି?', 'भारत का राष्ट्रीय फूल कौन-सा है?'),
    [
      ('Rose', 'ଗୋଲାପ', 'गुलाब'),
      ('Lotus', 'ପଦ୍ମ', 'कमल'),
      ('Sunflower', 'ସୂର୍ଯ୍ୟମୁଖୀ', 'सूरजमुखी'),
      ('Marigold', 'ଗେଣ୍ଡୁ', 'गेंदा'),
    ],
    1,
    ('The lotus is India’s national flower.', 'ପଦ୍ମ ଭାରତର ଜାତୀୟ ଫୁଲ।', 'कमल भारत का राष्ट्रीय फूल है।'),
  ),
  _q(
    _india,
    ('We celebrate Republic Day on…', 'ଆମେ ସାଧାରଣତନ୍ତ୍ର ଦିବସ କେବେ ପାଳୁ?', 'हम गणतंत्र दिवस कब मनाते हैं?'),
    [
      ('15 August', '15 ଅଗଷ୍ଟ', '15 अगस्त'),
      ('26 January', '26 ଜାନୁଆରୀ', '26 जनवरी'),
      ('2 October', '2 ଅକ୍ଟୋବର', '2 अक्टूबर'),
      ('14 November', '14 ନଭେମ୍ବର', '14 नवंबर'),
    ],
    1,
    ('Republic Day is on 26 January, when our Constitution began.', 'ସାଧାରଣତନ୍ତ୍ର ଦିବସ 26 ଜାନୁଆରୀ, ଯେତେବେଳେ ଆମ ସମ୍ବିଧାନ ଲାଗୁ ହେଲା।', 'गणतंत्र दिवस 26 जनवरी को है, जब हमारा संविधान लागू हुआ।'),
  ),
  _q(
    _india,
    ('Children’s Day is celebrated on the birthday of…', 'ଶିଶୁ ଦିବସ କାହାର ଜନ୍ମଦିନରେ ପାଳନ ହୁଏ?', 'बाल दिवस किसके जन्मदिन पर मनाया जाता है?'),
    [
      ('Mahatma Gandhi', 'ମହାତ୍ମା ଗାନ୍ଧୀ', 'महात्मा गांधी'),
      ('Jawaharlal Nehru', 'ଜବାହରଲାଲ ନେହେରୁ', 'जवाहरलाल नेहरू'),
      ('Subhas Chandra Bose', 'ସୁଭାଷ ଚନ୍ଦ୍ର ବୋଷ', 'सुभाष चंद्र बोस'),
      ('Rabindranath Tagore', 'ରବୀନ୍ଦ୍ରନାଥ ଠାକୁର', 'रवींद्रनाथ टैगोर'),
    ],
    1,
    ('Nehru loved children; his birthday, 14 November, is Children’s Day.', 'ନେହେରୁ ପିଲାଙ୍କୁ ଭଲ ପାଉଥିଲେ; ତାଙ୍କ ଜନ୍ମଦିନ 14 ନଭେମ୍ବର ଶିଶୁ ଦିବସ।', 'नेहरू बच्चों से प्यार करते थे; उनका जन्मदिन 14 नवंबर बाल दिवस है।'),
  ),
  _tf(
    _family,
    ('We should help our family with small jobs at home.', 'ଘରେ ଛୋଟ କାମରେ ଆମେ ପରିବାରକୁ ସାହାଯ୍ୟ କରିବା ଉଚିତ।', 'हमें घर के छोटे कामों में परिवार की मदद करनी चाहिए।'),
    true,
    ('Helping at home, like tidying toys, is part of being a family.', 'ଖେଳନା ସଜାଡ଼ିବା ପରି ଘର କାମରେ ସାହାଯ୍ୟ ପରିବାରର ଅଂଶ।', 'खिलौने समेटने जैसे घर के काम में मदद करना परिवार का हिस्सा है।'),
  ),
  _tf(
    _helpers,
    ('A doctor helps us when we are ill.', 'ଅସୁସ୍ଥ ହେଲେ ଡାକ୍ତର ଆମକୁ ସାହାଯ୍ୟ କରନ୍ତି।', 'बीमार होने पर डॉक्टर हमारी मदद करते हैं।'),
    true,
    ('Doctors check us and give medicine to make us well.', 'ଡାକ୍ତର ଆମକୁ ପରୀକ୍ଷା କରି ଭଲ ହେବାକୁ ଔଷଧ ଦିଅନ୍ତି।', 'डॉक्टर जाँच करके हमें ठीक होने की दवा देते हैं।'),
  ),
  _tf(
    _helpers,
    ('We should cross the road at the zebra crossing.', 'ଆମେ ଜେବ୍ରା କ୍ରସିଂରେ ରାସ୍ତା ପାର ହେବା ଉଚିତ।', 'हमें ज़ेबरा क्रॉसिंग पर सड़क पार करनी चाहिए।'),
    true,
    ('The zebra crossing is the safe place to cross.', 'ଜେବ୍ରା କ୍ରସିଂ ପାର ହେବାର ସୁରକ୍ଷିତ ସ୍ଥାନ।', 'ज़ेबरा क्रॉसिंग सड़क पार करने की सुरक्षित जगह है।'),
  ),
  _tf(
    _india,
    ('The Indian flag has four colours.', 'ଭାରତୀୟ ପତାକାରେ ଚାରିଟି ରଙ୍ଗ ଅଛି।', 'भारतीय झंडे में चार रंग हैं।'),
    false,
    ('It has three bands — saffron, white and green — plus a navy blue wheel.', 'ଏଥିରେ ତିନୋଟି ପଟି — ଗେରୁଆ, ଧଳା ଓ ସବୁଜ — ସହ ଗାଢ଼ ନୀଳ ଚକ।', 'इसमें तीन पट्टियाँ — केसरिया, सफ़ेद और हरी — और एक गहरे नीले रंग का चक्र है।'),
  ),
  _tf(
    _india,
    ('Odisha is a state of India.', 'ଓଡ଼ିଶା ଭାରତର ଏକ ରାଜ୍ୟ।', 'ओडिशा भारत का एक राज्य है।'),
    true,
    ('Odisha is on the east coast of India.', 'ଓଡ଼ିଶା ଭାରତର ପୂର୍ବ ଉପକୂଳରେ ଅଛି।', 'ओडिशा भारत के पूर्वी तट पर है।'),
  ),
  _fill(
    _family,
    ('My mother’s brother is my ___.', 'ମୋ ମା’ଙ୍କ ଭାଇ ମୋର ___।', 'मेरी माँ के भाई मेरे ___ हैं।'),
    [
      ('uncle', 'ମାମୁଁ', 'मामा'),
      ('grandfather', 'ଅଜା', 'नाना'),
      ('brother', 'ଭାଇ', 'भाई'),
      ('nephew', 'ଭଣଜା', 'भांजा'),
    ],
    0,
    ('Your mother’s brother is your maternal uncle.', 'ମା’ଙ୍କ ଭାଇ ତୁମର ମାମୁଁ।', 'माँ के भाई तुम्हारे मामा हैं।'),
  ),
  _fill(
    _helpers,
    ('A ___ grows rice and vegetables.', '___ ଧାନ ଓ ପରିବା ଚାଷ କରନ୍ତି।', '___ धान और सब्ज़ियाँ उगाते हैं।'),
    [
      ('farmer', 'ଚାଷୀ', 'किसान'),
      ('pilot', 'ପାଇଲଟ', 'पायलट'),
      ('tailor', 'ଦରଜି', 'दर्ज़ी'),
      ('guard', 'ପହରାଦାର', 'चौकीदार'),
    ],
    0,
    ('Farmers grow the food we eat.', 'ଚାଷୀ ଆମ ଖାଦ୍ୟ ଚାଷ କରନ୍ତି।', 'किसान हमारा भोजन उगाते हैं।'),
  ),
  _fill(
    _india,
    ('The capital of India is ___.', 'ଭାରତର ରାଜଧାନୀ ___।', 'भारत की राजधानी ___ है।'),
    [
      ('New Delhi', 'ନୂଆଦିଲ୍ଲୀ', 'नई दिल्ली'),
      ('Mumbai', 'ମୁମ୍ବାଇ', 'मुंबई'),
      ('Puri', 'ପୁରୀ', 'पुरी'),
      ('Kolkata', 'କୋଲକାତା', 'कोलकाता'),
    ],
    0,
    ('New Delhi is the capital of India.', 'ନୂଆଦିଲ୍ଲୀ ଭାରତର ରାଜଧାନୀ।', 'नई दिल्ली भारत की राजधानी है।'),
  ),
  _m(
    _helpers,
    ('Match each helper to their tool.', 'ପ୍ରତ୍ୟେକ ସହାୟକଙ୍କୁ ତାଙ୍କ ଉପକରଣ ସହ ମିଳାଅ।', 'हर सहायक को उसके औज़ार से मिलाओ।'),
    [
      (('Doctor', 'ଡାକ୍ତର', 'डॉक्टर'), ('Stethoscope', 'ଷ୍ଟେଥୋସ୍କୋପ', 'स्टेथोस्कोप')),
      (('Tailor', 'ଦରଜି', 'दर्ज़ी'), ('Needle', 'ଛୁଞ୍ଚି', 'सुई')),
      (('Farmer', 'ଚାଷୀ', 'किसान'), ('Plough', 'ଲଙ୍ଗଳ', 'हल')),
      (('Carpenter', 'ବଢ଼େଇ', 'बढ़ई'), ('Saw', 'କରତ', 'आरी')),
    ],
    ('Every helper uses special tools for their work.', 'ପ୍ରତ୍ୟେକ ସହାୟକ କାମ ପାଇଁ ବିଶେଷ ଉପକରଣ ବ୍ୟବହାର କରନ୍ତି।', 'हर सहायक अपने काम के लिए खास औज़ार इस्तेमाल करता है।'),
  ),
  _m(
    _india,
    ('Match each national symbol.', 'ପ୍ରତ୍ୟେକ ଜାତୀୟ ପ୍ରତୀକ ମିଳାଅ।', 'हर राष्ट्रीय प्रतीक मिलाओ।'),
    [
      (('National animal', 'ଜାତୀୟ ପଶୁ', 'राष्ट्रीय पशु'), ('Tiger', 'ବାଘ', 'बाघ')),
      (('National bird', 'ଜାତୀୟ ପକ୍ଷୀ', 'राष्ट्रीय पक्षी'), ('Peacock', 'ମୟୂର', 'मोर')),
      (('National flower', 'ଜାତୀୟ ଫୁଲ', 'राष्ट्रीय फूल'), ('Lotus', 'ପଦ୍ମ', 'कमल')),
      (('National fruit', 'ଜାତୀୟ ଫଳ', 'राष्ट्रीय फल'), ('Mango', 'ଆମ୍ବ', 'आम')),
    ],
    ('These symbols stand for India.', 'ଏହି ପ୍ରତୀକଗୁଡ଼ିକ ଭାରତକୁ ବୁଝାନ୍ତି।', 'ये प्रतीक भारत को दर्शाते हैं।'),
  ),
  _m(
    _family,
    ('Match each place to what we do there.', 'ପ୍ରତ୍ୟେକ ସ୍ଥାନକୁ ସେଠାରେ ଯାହା କରୁ ସହ ମିଳାଅ।', 'हर जगह को वहाँ किए जाने वाले काम से मिलाओ।'),
    [
      (('School', 'ବିଦ୍ୟାଳୟ', 'स्कूल'), ('Learn', 'ଶିଖିବା', 'सीखना')),
      (('Kitchen', 'ରୋଷେଇ ଘର', 'रसोई'), ('Cook', 'ରାନ୍ଧିବା', 'खाना बनाना')),
      (('Playground', 'ଖେଳପଡ଼ିଆ', 'खेल का मैदान'), ('Play', 'ଖେଳିବା', 'खेलना')),
      (('Bedroom', 'ଶୋଇବା ଘର', 'शयनकक्ष'), ('Sleep', 'ଶୋଇବା', 'सोना')),
    ],
    ('Different places are used for different things.', 'ଭିନ୍ନ ସ୍ଥାନ ଭିନ୍ନ କାମ ପାଇଁ ବ୍ୟବହୃତ ହୁଏ।', 'अलग-अलग जगहें अलग-अलग कामों के लिए होती हैं।'),
  ),
];
