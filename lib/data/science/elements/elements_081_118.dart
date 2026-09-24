import '../periodic_table_data.dart';

// ─── Elements 81–118 (Thallium → Oganesson) ───
// Static, display-only seed content. Physical-property strings carry their
// units; genuinely unmeasured values for superheavy elements are left null.
const List<ElementData> elements081to118 = [
  ElementData(
    atomicNumber: 81,
    symbol: 'Tl',
    name: 'Thallium',
    nameOdia: 'ଥାଲିୟମ୍',
    nameHindi: 'थैलियम',
    group: 13,
    period: 6,
    category: 'post_transition',
    atomicMass: '204.38',
    state: 'Solid',
    shells: [2, 8, 18, 32, 18, 3],
    valency: '1, 3',
    meltingPoint: '304 °C',
    boilingPoint: '1473 °C',
    density: '11.85 g/cm³',
    description: LocalizedElementText(
      english:
          'Thallium is a soft, heavy grey metal whose compounds are highly poisonous.',
      hindi:
          'थैलियम एक नरम, भारी भूरे रंग की धातु है जिसके यौगिक अत्यधिक जहरीले होते हैं।',
      odia:
          'ଥାଲିୟମ୍ ହେଉଛି ଏକ ନରମ, ଭାରୀ ଧୂସର ଧାତୁ ଯାହାର ଯ ounds ଗିକ ଅତ୍ୟଧିକ ବିଷାକ୍ତ।',
    ),
    uses: LocalizedElementText(
      english: 'Electronics, infrared detectors, and some special glass.',
      hindi: 'इलेक्ट्रॉनिक्स, इन्फ्रारेड डिटेक्टर और कुछ विशेष ग्लास।',
      odia: 'ଇଲେକ୍ଟ୍ରୋନିକ୍ସ, ଇନଫ୍ରାଡ୍ ଡିଟେକ୍ଟର୍ ଏବଂ କିଛି ସ୍ୱତନ୍ତ୍ର ଗ୍ଲାସ୍।',
    ),
    funFact: LocalizedElementText(
      english:
          'It was once used as rat poison, but is so toxic to people that this was banned in many countries.',
      hindi:
          'एक समय इसका उपयोग चूहे मारने वाले जहर के रूप में किया जाता था, लेकिन यह लोगों के लिए इतना जहरीला है कि कई देशों में इस पर प्रतिबंध लगा दिया गया है।',
      odia:
          'ଏହା ଏକଦା ମୂଷା ବିଷ ଭାବରେ ବ୍ୟବହୃତ ହେଉଥିଲା, କିନ୍ତୁ ଲୋକଙ୍କ ପାଇଁ ଏତେ ବିଷାକ୍ତ ଯେ ଏହାକୁ ଅନେକ ଦେଶରେ ନିଷେଧ କରାଯାଇଥିଲା।',
    ),
    discovery: LocalizedElementText(
      english: 'William Crookes, 1861',
      hindi: 'विलियम क्रुक्स, 1861',
      odia: 'ୱିଲିୟମ୍ କ୍ରୁକସ୍, 1861',
    ),
  ),
  ElementData(
    atomicNumber: 82,
    symbol: 'Pb',
    name: 'Lead',
    nameOdia: 'ସୀସା',
    nameHindi: 'सीसा',
    group: 14,
    period: 6,
    category: 'post_transition',
    atomicMass: '207.2',
    state: 'Solid',
    shells: [2, 8, 18, 32, 18, 4],
    valency: '2, 4',
    meltingPoint: '327 °C',
    boilingPoint: '1749 °C',
    density: '11.34 g/cm³',
    description: LocalizedElementText(
      english:
          'Lead is a soft, dense, bluish-grey metal that is easy to bend and shape.',
      hindi:
          'सीसा एक नरम, सघन, नीले-भूरे रंग की धातु है जिसे मोड़ना और आकार देना आसान है।',
      odia: 'ଲିଡ୍ ହେଉଛି ଏକ ନରମ, ଘନ, ନୀଳ-ଧୂସର ଧାତୁ ଯାହା ବଙ୍କା ଏବଂ ଆକୃତିର ସହଜ।',
    ),
    uses: LocalizedElementText(
      english: 'Car batteries, radiation shielding, and older water pipes.',
      hindi: 'कार बैटरियां, विकिरण परिरक्षण, और पुराने पानी के पाइप।',
      odia: 'କାର୍ ବ୍ୟାଟେରୀ, ବିକିରଣ ield ାଲ ଏବଂ ପୁରୁଣା ଜଳ ପାଇପ୍।',
    ),
    funFact: LocalizedElementText(
      english:
          'Lead is so good at blocking radiation that it is used to make aprons that protect you during X-rays.',
      hindi:
          'सीसा विकिरण को रोकने में इतना अच्छा है कि इसका उपयोग एप्रन बनाने में किया जाता है जो एक्स-रे के दौरान आपकी रक्षा करता है।',
      odia:
          'ଲିଡ୍ ବିକିରଣକୁ ଅବରୋଧ କରିବାରେ ଏତେ ଭଲ ଯେ ଏହା ଆପ୍ରୋନ୍ ତିଆରିରେ ବ୍ୟବହୃତ ହୁଏ ଯାହା ଏକ୍ସ-ରେ ସମୟରେ ଆପଣଙ୍କୁ ସୁରକ୍ଷା ଦେଇଥାଏ।',
    ),
    discovery: LocalizedElementText(
      english: 'Known since ancient times',
      hindi: 'प्राचीन काल से जाना जाता है',
      odia: 'ପ୍ରାଚୀନ କାଳରୁ ଜଣାଶୁଣା।',
    ),
  ),
  ElementData(
    atomicNumber: 83,
    symbol: 'Bi',
    name: 'Bismuth',
    nameOdia: 'ବିସ୍‌ମଥ୍',
    nameHindi: 'बिस्मथ',
    group: 15,
    period: 6,
    category: 'post_transition',
    atomicMass: '208.98',
    state: 'Solid',
    shells: [2, 8, 18, 32, 18, 5],
    valency: '3, 5',
    meltingPoint: '271 °C',
    boilingPoint: '1564 °C',
    density: '9.78 g/cm³',
    description: LocalizedElementText(
      english:
          'Bismuth is a brittle metal that forms beautiful rainbow-coloured crystals.',
      hindi:
          'बिस्मथ एक भंगुर धातु है जो सुंदर इंद्रधनुषी रंग के क्रिस्टल बनाती है।',
      odia:
          'ବିସ୍ମୁଟ୍ ହେଉଛି ଏକ ଭଗ୍ନ ଧାତୁ ଯାହା ସୁନ୍ଦର ଇନ୍ଦ୍ରଧନୁ ରଙ୍ଗର ସ୍ଫଟିକ୍ ସୃଷ୍ଟି କରେ।',
    ),
    uses: LocalizedElementText(
      english: 'Stomach medicines, cosmetics, and low-melting-point alloys.',
      hindi:
          'पेट की दवाएँ, सौंदर्य प्रसाधन, और कम पिघलने बिंदु वाली मिश्र धातुएँ।',
      odia: 'ପେଟ medicines ଷଧ, ପ୍ରସାଧନ ସାମଗ୍ରୀ, ଏବଂ କମ୍ ତରଳିବା ପଏଣ୍ଟ ଆଲୋଇସ୍।',
    ),
    funFact: LocalizedElementText(
      english:
          'A bismuth compound is the pink medicine many people take to settle an upset stomach.',
      hindi:
          'बिस्मथ यौगिक एक गुलाबी दवा है जिसे बहुत से लोग पेट की ख़राबी को ठीक करने के लिए लेते हैं।',
      odia:
          'ଏକ ବିସ୍ମୁଥ୍ ଯ ound ଗିକ ହେଉଛି ଗୋଲାପୀ medicine ଷଧ ଯାହା ଅନେକ ଲୋକ ଏକ ପେଟର ସମାଧାନ ପାଇଁ ଗ୍ରହଣ କରନ୍ତି।',
    ),
    discovery: LocalizedElementText(
      english: 'Known since ancient times',
      hindi: 'प्राचीन काल से जाना जाता है',
      odia: 'ପ୍ରାଚୀନ କାଳରୁ ଜଣାଶୁଣା।',
    ),
  ),
  ElementData(
    atomicNumber: 84,
    symbol: 'Po',
    name: 'Polonium',
    nameOdia: 'ପୋଲୋନିୟମ୍',
    nameHindi: 'पोलोनियम',
    group: 16,
    period: 6,
    category: 'metalloid',
    atomicMass: '[209]',
    state: 'Solid',
    shells: [2, 8, 18, 32, 18, 6],
    valency: '2, 4',
    meltingPoint: '254 °C',
    boilingPoint: '962 °C',
    density: '9.20 g/cm³',
    description: LocalizedElementText(
      english:
          'Polonium is a rare, highly radioactive element that gives off a lot of heat.',
      hindi:
          'पोलोनियम एक दुर्लभ, अत्यधिक रेडियोधर्मी तत्व है जो बहुत अधिक गर्मी उत्सर्जित करता है।',
      odia:
          'ପୋଲୋନିୟମ୍ ହେଉଛି ଏକ ବିରଳ, ଅତ୍ୟଧିକ ରେଡିଓଆକ୍ଟିଭ୍ ଉପାଦାନ ଯାହା ପ୍ରଚୁର ଉତ୍ତାପ ଦେଇଥାଏ।',
    ),
    uses: LocalizedElementText(
      english: 'Anti-static devices and as a heat source in some spacecraft.',
      hindi: 'कुछ अंतरिक्षयानों में स्थैतिकरोधी उपकरण और ताप स्रोत के रूप में।',
      odia: 'ଆଣ୍ଟି-ଷ୍ଟାଟିକ୍ ଉପକରଣ ଏବଂ କିଛି ମହାକାଶଯାନରେ ଉତ୍ତାପ ଉତ୍ସ ଭାବରେ।',
    ),
    funFact: LocalizedElementText(
      english:
          'Marie Curie named it after Poland, her home country, when she discovered it.',
      hindi:
          'जब मैरी क्यूरी ने इसकी खोज की तो उन्होंने इसका नाम अपने गृह देश पोलैंड के नाम पर रखा।',
      odia:
          'ମ୍ୟାରି କ୍ୟୁରି ଏହାକୁ ଆବିଷ୍କାର କଲାବେଳେ ତାଙ୍କ ଦେଶ ପୋଲାଣ୍ଡ ନାମରେ ନାମିତ କଲେ।',
    ),
    discovery: LocalizedElementText(
      english: 'Marie and Pierre Curie, 1898',
      hindi: 'मैरी और पियरे क्यूरी, 1898',
      odia: 'ମାରି ଏବଂ ପିଆର କ୍ୟୁରି, 1898',
    ),
  ),
  ElementData(
    atomicNumber: 85,
    symbol: 'At',
    name: 'Astatine',
    nameOdia: 'ଆଷ୍ଟାଟିନ୍',
    nameHindi: 'एस्टाटीन',
    group: 17,
    period: 6,
    category: 'halogen',
    atomicMass: '[210]',
    state: 'Solid',
    shells: [2, 8, 18, 32, 18, 7],
    valency: '1',
    meltingPoint: '302 °C',
    boilingPoint: '337 °C',
    density: null,
    description: LocalizedElementText(
      english:
          'Astatine is an extremely rare, radioactive halogen that quickly falls apart.',
      hindi:
          'एस्टैटिन एक अत्यंत दुर्लभ, रेडियोधर्मी हैलोजन है जो जल्दी से टूट जाता है।',
      odia:
          'ଆଷ୍ଟାଟାଇନ୍ ଏକ ଅତ୍ୟନ୍ତ ବିରଳ, ରେଡିଓଆକ୍ଟିଭ୍ ହାଲୋଜେନ୍ ଯାହା ଶୀଘ୍ର ଅଲଗା ହୋଇଯାଏ।',
    ),
    uses: LocalizedElementText(
      english: 'Scientific research only; being studied for cancer treatment.',
      hindi:
          'केवल वैज्ञानिक अनुसंधान; कैंसर के इलाज के लिए अध्ययन किया जा रहा है।',
      odia:
          'କେବଳ ବ Scientific ଜ୍ଞାନିକ ଅନୁସନ୍ଧାନ; କର୍କଟ ଚିକିତ୍ସା ପାଇଁ ଅଧ୍ୟୟନ କରାଯାଉଛି।',
    ),
    funFact: LocalizedElementText(
      english:
          'It is the rarest naturally occurring element on Earth — less than a spoonful exists in the whole crust at any time.',
      hindi:
          'यह पृथ्वी पर प्राकृतिक रूप से पाया जाने वाला सबसे दुर्लभ तत्व है - किसी भी समय पूरी परत में एक चम्मच से भी कम तत्व मौजूद होता है।',
      odia:
          'ଏହା ପୃଥିବୀରେ କ୍ୱଚିତ୍ ପ୍ରାକୃତିକ ଭାବରେ ଘଟୁଥିବା ଉପାଦାନ - ଯେକ any ଣସି ସମୟରେ ସମଗ୍ର ଭୂତଳରେ ଏକ ଚାମଚରୁ କମ୍ ବିଦ୍ୟମାନ।',
    ),
    discovery: LocalizedElementText(
      english: 'Corson, MacKenzie & Segrè, 1940',
      hindi: 'कोर्सन, मैकेंज़ी और सेग्रे, 1940',
      odia: 'କର୍ସନ୍, ମ୍ୟାକେଞ୍ଜି ଏବଂ ସେଗ୍ରୋ, 1940',
    ),
  ),
  ElementData(
    atomicNumber: 86,
    symbol: 'Rn',
    name: 'Radon',
    nameOdia: 'ରାଡନ୍',
    nameHindi: 'रेडॉन',
    group: 18,
    period: 6,
    category: 'noble_gas',
    atomicMass: '[222]',
    state: 'Gas',
    shells: [2, 8, 18, 32, 18, 8],
    valency: '0',
    meltingPoint: '−71 °C',
    boilingPoint: '−62 °C',
    density: '0.00973 g/cm³',
    description: LocalizedElementText(
      english:
          'Radon is a colourless, radioactive noble gas that seeps up from rocks and soil.',
      hindi:
          'रेडॉन एक रंगहीन, रेडियोधर्मी उत्कृष्ट गैस है जो चट्टानों और मिट्टी से रिसती है।',
      odia:
          'ରେଡନ୍ ହେଉଛି ଏକ ରଙ୍ଗହୀନ, ରେଡିଓଆକ୍ଟିଭ୍ ନୋବଲ୍ ଗ୍ୟାସ୍ ଯାହା ପଥର ଏବଂ ମାଟିରୁ ବାହାରିଥାଏ।',
    ),
    uses: LocalizedElementText(
      english: 'Very limited; occasionally used in some medical treatments.',
      hindi: 'बहुत सीमित; कभी-कभी कुछ चिकित्सा उपचारों में उपयोग किया जाता है।',
      odia: 'ବହୁତ ସୀମିତ; ବେଳେବେଳେ କିଛି ଚିକିତ୍ସା ଚିକିତ୍ସାରେ ବ୍ୟବହୃତ ହୁଏ।',
    ),
    funFact: LocalizedElementText(
      english:
          'Radon can build up inside houses, so many homes are tested for it to keep the air safe.',
      hindi:
          'रेडॉन घरों के अंदर जमा हो सकता है, इसलिए कई घरों में हवा को सुरक्षित रखने के लिए इसका परीक्षण किया जाता है।',
      odia:
          'ରେଡନ୍ ଘର ଭିତରେ ନିର୍ମାଣ କରିପାରିବ, ତେଣୁ ବାୟୁକୁ ସୁରକ୍ଷିତ ରଖିବା ପାଇଁ ଅନେକ ଘର ପରୀକ୍ଷା କରାଯାଏ।',
    ),
    discovery: LocalizedElementText(
      english: 'Friedrich Ernst Dorn, 1900',
      hindi: 'फ्रेडरिक अर्न्स्ट डोर्न, 1900',
      odia: 'ଫ୍ରିଡ୍ରିଚ୍ ଏର୍ନଷ୍ଟ ଡର୍ନ୍, 1900',
    ),
  ),
  ElementData(
    atomicNumber: 87,
    symbol: 'Fr',
    name: 'Francium',
    nameOdia: 'ଫ୍ରାନ୍‌ସିୟମ୍',
    nameHindi: 'फ्रैंसियम',
    group: 1,
    period: 7,
    category: 'alkali_metal',
    atomicMass: '[223]',
    state: 'Solid',
    shells: [2, 8, 18, 32, 18, 8, 1],
    valency: '1',
    meltingPoint: null,
    boilingPoint: null,
    density: null,
    description: LocalizedElementText(
      english:
          'Francium is an intensely radioactive metal that exists only in tiny, fleeting amounts.',
      hindi:
          'फ्रांसियम एक अत्यंत रेडियोधर्मी धातु है जो केवल छोटी, क्षणभंगुर मात्रा में मौजूद होती है।',
      odia:
          'ଫ୍ରାନ୍ସିୟମ୍ ହେଉଛି ଏକ ତୀବ୍ର ରେଡିଓଆକ୍ଟିଭ୍ ଧାତୁ ଯାହା କେବଳ କ୍ଷୁଦ୍ର, ଅଳ୍ପ ସମୟ ମଧ୍ୟରେ ବିଦ୍ୟମାନ।',
    ),
    uses: LocalizedElementText(
      english: 'Scientific research only; no everyday uses.',
      hindi: 'केवल वैज्ञानिक अनुसंधान; कोई रोजमर्रा का उपयोग नहीं.',
      odia:
          'କେବଳ ବ Scientific ଜ୍ଞାନିକ ଅନୁସନ୍ଧାନ; କ every ଣସି ଦ day ନନ୍ଦିନ ବ୍ୟବହାର ନାହିଁ।',
    ),
    funFact: LocalizedElementText(
      english:
          'It is so unstable that only a few atoms have ever been studied at once — you could never hold a real piece of it.',
      hindi:
          'यह इतना अस्थिर है कि एक बार में केवल कुछ परमाणुओं का ही अध्ययन किया गया है - आप कभी भी इसका वास्तविक टुकड़ा नहीं पकड़ सकते।',
      odia:
          'ଏହା ଏତେ ଅସ୍ଥିର ଯେ କେବଳ ଅଳ୍ପ କିଛି ପରମାଣୁ ଏକାସାଙ୍ଗରେ ଅଧ୍ୟୟନ କରିସାରିଛନ୍ତି - ଆପଣ ଏହାର ପ୍ରକୃତ ଖଣ୍ଡ କେବେବି ଧରି ପାରିବେ ନାହିଁ।',
    ),
    discovery: LocalizedElementText(
      english: 'Marguerite Perey, 1939',
      hindi: 'मार्गुएराइट पेरी, 1939',
      odia: 'ମାରଗୁଏରାଇଟ୍ ପେରେ, 1939',
    ),
  ),
  ElementData(
    atomicNumber: 88,
    symbol: 'Ra',
    name: 'Radium',
    nameOdia: 'ରେଡିୟମ୍',
    nameHindi: 'रेडियम',
    group: 2,
    period: 7,
    category: 'alkaline_earth',
    atomicMass: '[226]',
    state: 'Solid',
    shells: [2, 8, 18, 32, 18, 8, 2],
    valency: '2',
    meltingPoint: '700 °C',
    boilingPoint: '1737 °C',
    density: '5.5 g/cm³',
    description: LocalizedElementText(
      english: 'Radium is a radioactive metal that faintly glows in the dark.',
      hindi: 'रेडियम एक रेडियोधर्मी धातु है जो अंधेरे में हल्की चमकती है।',
      odia:
          'ରେଡିୟମ୍ ହେଉଛି ଏକ ରେଡିଓଆକ୍ଟିଭ୍ ଧାତୁ ଯାହା ଅନ୍ଧାରରେ ଦୁର୍ବଳ ଭାବରେ ଆଲୋକିତ ହୁଏ।',
    ),
    uses: LocalizedElementText(
      english:
          'Historically used in glow-in-the-dark paint on clocks and dials.',
      hindi:
          'ऐतिहासिक रूप से घड़ियों और डायल पर अंधेरे में चमकने वाले पेंट में उपयोग किया जाता है।',
      odia:
          'ଘଣ୍ଟା ଏବଂ ଡାଏଲରେ ଗ୍ଲୋ-ଇନ୍-ଅନ୍ଧାର ରଙ୍ଗରେ Histor ତିହାସିକ ଭାବରେ ବ୍ୟବହୃତ।',
    ),
    funFact: LocalizedElementText(
      english:
          'Its glowing paint once decorated watch dials, until people learned how dangerous its radiation really was.',
      hindi:
          'इसके चमकते पेंट ने एक बार घड़ी के डायल को सजाया, जब तक लोगों को पता नहीं चला कि इसका विकिरण वास्तव में कितना खतरनाक था।',
      odia:
          'ଏହାର ଉଜ୍ଜ୍ୱଳ ରଙ୍ଗ ଥରେ ଘଣ୍ଟା ଡାଏଲ୍କୁ ସଜାଇଥିଲା, ଯେପର୍ଯ୍ୟନ୍ତ ଲୋକମାନେ ଜାଣି ନଥିଲେ ଯେ ଏହାର ବିକିରଣ ପ୍ରକୃତରେ କେତେ ବିପଜ୍ଜନକ।',
    ),
    discovery: LocalizedElementText(
      english: 'Marie and Pierre Curie, 1898',
      hindi: 'मैरी और पियरे क्यूरी, 1898',
      odia: 'ମାରି ଏବଂ ପିଆର କ୍ୟୁରି, 1898',
    ),
  ),
  ElementData(
    atomicNumber: 89,
    symbol: 'Ac',
    name: 'Actinium',
    nameOdia: 'ଆକ୍‌ଟିନିୟମ୍',
    nameHindi: 'एक्टिनियम',
    group: 3,
    period: 9,
    category: 'actinide',
    atomicMass: '[227]',
    state: 'Solid',
    shells: [2, 8, 18, 32, 18, 9, 2],
    valency: '3',
    meltingPoint: '1050 °C',
    boilingPoint: '3200 °C',
    density: '10.07 g/cm³',
    description: LocalizedElementText(
      english:
          'Actinium is a silvery, radioactive metal that glows with a pale blue light.',
      hindi:
          'एक्टिनियम एक चांदी जैसी रेडियोधर्मी धातु है जो हल्की नीली रोशनी से चमकती है।',
      odia:
          'ଆକ୍ଟିନିୟମ୍ ହେଉଛି ଏକ ରୂପା, ରେଡିଓଆକ୍ଟିଭ୍ ଧାତୁ ଯାହା ଏକ ନୀଳ ରଙ୍ଗର ଆଲୋକ ସହିତ ଆଲୋକିତ ହୁଏ।',
    ),
    uses: LocalizedElementText(
      english: 'Scientific research and some targeted cancer therapies.',
      hindi: 'वैज्ञानिक अनुसंधान और कुछ लक्षित कैंसर उपचार।',
      odia:
          'ବ Scientific ଜ୍ଞାନିକ ଅନୁସନ୍ଧାନ ଏବଂ କିଛି ଲକ୍ଷ୍ୟ ରଖାଯାଇଥିବା କର୍କଟ ଚିକିତ୍ସା।',
    ),
    funFact: LocalizedElementText(
      english:
          'It gives its name to the actinides, the whole bottom row of radioactive metals in the table.',
      hindi:
          'यह एक्टिनाइड्स, तालिका में रेडियोधर्मी धातुओं की पूरी निचली पंक्ति को अपना नाम देता है।',
      odia:
          'ଏହା ଟେବୁଲରେ ଥିବା ରେଡ଼ିଓଏକ୍ଟିଭ୍ ଧାତୁର ସମଗ୍ର ତଳ ଧାଡି ଆକ୍ଟିନାଇଡ୍ସକୁ ଏହାର ନାମ ଦେଇଥାଏ।',
    ),
    discovery: LocalizedElementText(
      english: 'André-Louis Debierne, 1899',
      hindi: 'आंद्रे-लुई डेबिर्न, 1899',
      odia: 'ଆଣ୍ଡ୍ରେ-ଲୁଇସ୍ ଡେବିର୍ନେ, 1899',
    ),
  ),
  ElementData(
    atomicNumber: 90,
    symbol: 'Th',
    name: 'Thorium',
    nameOdia: 'ଥୋରିୟମ୍',
    nameHindi: 'थोरियम',
    group: 4,
    period: 9,
    category: 'actinide',
    atomicMass: '232.04',
    state: 'Solid',
    shells: [2, 8, 18, 32, 18, 10, 2],
    valency: '4',
    meltingPoint: '1750 °C',
    boilingPoint: '4788 °C',
    density: '11.72 g/cm³',
    description: LocalizedElementText(
      english:
          'Thorium is a radioactive metal that could be used as a future nuclear fuel.',
      hindi:
          'थोरियम एक रेडियोधर्मी धातु है जिसका उपयोग भविष्य में परमाणु ईंधन के रूप में किया जा सकता है।',
      odia:
          'ଥୋରିୟମ୍ ହେଉଛି ଏକ ରେଡିଓଆକ୍ଟିଭ୍ ଧାତୁ ଯାହା ଭବିଷ୍ୟତରେ ଆଣବିକ ଇନ୍ଧନ ଭାବରେ ବ୍ୟବହୃତ ହୋଇପାରେ।',
    ),
    uses: LocalizedElementText(
      english: 'Studied as nuclear fuel; once used in gas lamp mantles.',
      hindi:
          'परमाणु ईंधन के रूप में अध्ययन किया गया; एक बार गैस लैंप मेंटल में उपयोग किया जाता था।',
      odia:
          'ପରମାଣୁ ଇନ୍ଧନ ଭାବରେ ଅଧ୍ୟୟନ; ଥରେ ଗ୍ୟାସ୍ ଲ୍ୟାମ୍ପ ମେଣ୍ଟରେ ବ୍ୟବହୃତ ହୁଏ।',
    ),
    funFact: LocalizedElementText(
      english:
          'India has huge thorium reserves and is researching thorium-powered reactors for clean energy.',
      hindi:
          'भारत के पास विशाल थोरियम भंडार है और स्वच्छ ऊर्जा के लिए थोरियम-संचालित रिएक्टरों पर शोध किया जा रहा है।',
      odia:
          'ଭାରତରେ ବିଶାଳ ଥୋରିୟମ୍ ଭଣ୍ଡାର ଅଛି ଏବଂ ସ୍ୱଚ୍ଛ ଶକ୍ତି ପାଇଁ ଥୋରିୟମ୍ ଚାଳିତ ରିଆକ୍ଟର ଗବେଷଣା କରୁଛି।',
    ),
    discovery: LocalizedElementText(
      english: 'Jöns Jacob Berzelius, 1828',
      hindi: 'जॉन्स जैकब बर्ज़ेलियस, 1828',
      odia: 'ଜୋନ୍ସ ଯାଦବ ବର୍ଜେଲିୟସ୍, 1828',
    ),
  ),
  ElementData(
    atomicNumber: 91,
    symbol: 'Pa',
    name: 'Protactinium',
    nameOdia: 'ପ୍ରୋଟାକ୍‌ଟିନିୟମ୍',
    nameHindi: 'प्रोटैक्टिनियम',
    group: 5,
    period: 9,
    category: 'actinide',
    atomicMass: '231.04',
    state: 'Solid',
    shells: [2, 8, 18, 32, 20, 9, 2],
    valency: '4, 5',
    meltingPoint: '1568 °C',
    boilingPoint: null,
    density: '15.37 g/cm³',
    description: LocalizedElementText(
      english:
          'Protactinium is a rare, silvery, radioactive metal that is very hard to obtain.',
      hindi:
          'प्रोटैक्टीनियम एक दुर्लभ, चांदी जैसा, रेडियोधर्मी धातु है जिसे प्राप्त करना बहुत कठिन है।',
      odia:
          'ପ୍ରୋଟାକ୍ଟିନିୟମ୍ ହେଉଛି ଏକ ବିରଳ, ରୂପା, ରେଡିଓଆକ୍ଟିଭ୍ ଧାତୁ ଯାହା ପାଇବା କଷ୍ଟକର।',
    ),
    uses: LocalizedElementText(
      english: 'Scientific research only; no everyday uses.',
      hindi: 'केवल वैज्ञानिक अनुसंधान; कोई रोजमर्रा का उपयोग नहीं.',
      odia:
          'କେବଳ ବ Scientific ଜ୍ଞାନିକ ଅନୁସନ୍ଧାନ; କ every ଣସି ଦ day ନନ୍ଦିନ ବ୍ୟବହାର ନାହିଁ।',
    ),
    funFact: LocalizedElementText(
      english:
          'Its name means "before actinium," because it decays into actinium over time.',
      hindi:
          'इसके नाम का अर्थ है "एक्टिनियम से पहले", क्योंकि यह समय के साथ क्षय होकर एक्टिनियम में बदल जाता है।',
      odia:
          'ଏହାର ନାମ ଅର୍ଥ ହେଉଛି "ଆକ୍ଟିନିୟମ୍ ପୂର୍ବରୁ", କାରଣ ଏହା ସମୟ ସହିତ ଆକ୍ଟିନିୟମ୍ରେ କ୍ଷୟ ହୁଏ।',
    ),
    discovery: LocalizedElementText(
      english: 'Hahn, Meitner & Soddy, 1917',
      hindi: 'हैन, मीटनर और सोड्डी, 1917',
      odia: 'ହାନ୍, ମେଟନର୍ ଏବଂ ସୋଡି, 1917',
    ),
  ),
  ElementData(
    atomicNumber: 92,
    symbol: 'U',
    name: 'Uranium',
    nameOdia: 'ୟୁରାନିୟମ୍',
    nameHindi: 'यूरेनियम',
    group: 6,
    period: 9,
    category: 'actinide',
    atomicMass: '238.03',
    state: 'Solid',
    shells: [2, 8, 18, 32, 21, 9, 2],
    valency: '4, 6',
    meltingPoint: '1132 °C',
    boilingPoint: '4131 °C',
    density: '19.05 g/cm³',
    description: LocalizedElementText(
      english:
          'Uranium is a dense, radioactive metal whose atoms can be split to release huge energy.',
      hindi:
          'यूरेनियम एक सघन, रेडियोधर्मी धातु है जिसके परमाणुओं को विभाजित करके भारी ऊर्जा उत्सर्जित की जा सकती है।',
      odia:
          'ୟୁରାନିୟମ୍ ହେଉଛି ଏକ ଘନ, ରେଡିଓଆକ୍ଟିଭ୍ ଧାତୁ ଯାହାର ପରମାଣୁ ବିରାଟ ଶକ୍ତି ମୁକ୍ତ କରିବାକୁ ବିଭକ୍ତ ହୋଇପାରେ।',
    ),
    uses: LocalizedElementText(
      english: 'Fuel for nuclear power plants and in nuclear weapons.',
      hindi: 'परमाणु ऊर्जा संयंत्रों और परमाणु हथियारों के लिए ईंधन।',
      odia: 'ଆଣବିକ ଶକ୍ତି କେନ୍ଦ୍ର ଏବଂ ଆଣବିକ ଅସ୍ତ୍ର ପାଇଁ ଇନ୍ଧନ।',
    ),
    funFact: LocalizedElementText(
      english:
          'A single kilogram of uranium can release as much energy as thousands of kilograms of coal.',
      hindi:
          'एक किलोग्राम यूरेनियम हजारों किलोग्राम कोयले जितनी ऊर्जा उत्सर्जित कर सकता है।',
      odia:
          'ଗୋଟିଏ କିଲୋଗ୍ରାମ ୟୁରାନିୟମ୍ ହଜାରେ କିଲୋଗ୍ରାମ କୋଇଲା ପରି ଶକ୍ତି ମୁକ୍ତ କରିପାରିବ।',
    ),
    discovery: LocalizedElementText(
      english: 'Martin Heinrich Klaproth, 1789',
      hindi: 'मार्टिन हेनरिक क्लैप्रोथ, 1789',
      odia: 'ମାର୍ଟିନ ହେନ୍ରିଚ୍ କ୍ଲାପ୍ରୋଟ୍, 1789',
    ),
  ),
  ElementData(
    atomicNumber: 93,
    symbol: 'Np',
    name: 'Neptunium',
    nameOdia: 'ନେପ୍‌ଟୁନିୟମ୍',
    nameHindi: 'नेप्च्यूनियम',
    group: 7,
    period: 9,
    category: 'actinide',
    atomicMass: '[237]',
    state: 'Solid',
    shells: [2, 8, 18, 32, 22, 9, 2],
    valency: '4, 5, 6',
    meltingPoint: '644 °C',
    boilingPoint: null,
    density: '20.45 g/cm³',
    description: LocalizedElementText(
      english:
          'Neptunium is a man-made radioactive metal, the first element beyond uranium.',
      hindi:
          'नेपच्यूनियम एक मानव निर्मित रेडियोधर्मी धातु है, जो यूरेनियम के बाद पहला तत्व है।',
      odia:
          'ନେପ୍ଟୁନିୟମ୍ ହେଉଛି ମନୁଷ୍ୟକୃତ ରେଡିଓଆକ୍ଟିଭ୍ ଧାତୁ, ୟୁରାନିୟମ୍ ବାହାରେ ପ୍ରଥମ ଉପାଦାନ।',
    ),
    uses: LocalizedElementText(
      english: 'Scientific research and in some neutron-detection instruments.',
      hindi: 'वैज्ञानिक अनुसंधान और कुछ न्यूट्रॉन-पता लगाने वाले उपकरणों में।',
      odia: 'ବ Scientific ଜ୍ଞାନିକ ଅନୁସନ୍ଧାନ ଏବଂ କିଛି ନିଉଟ୍ରନ୍-ଚିହ୍ନଟ ଉପକରଣରେ।',
    ),
    funFact: LocalizedElementText(
      english:
          'It is named after the planet Neptune, following uranium which is named after Uranus.',
      hindi:
          'इसका नाम यूरेनियम के नाम पर नेपच्यून ग्रह के नाम पर रखा गया है जिसका नाम यूरेनस के नाम पर रखा गया है।',
      odia:
          'ୟୁରାନିୟମକୁ ଅନୁସରଣ କରି ଏହା ନେପଟୁନ୍ ଗ୍ରହର ନାମରେ ନାମିତ ହୋଇଛି ଯାହା ୟୁରାନସ୍ ନାମରେ ନାମିତ।',
    ),
    discovery: LocalizedElementText(
      english: 'McMillan & Abelson, 1940',
      hindi: 'मैकमिलन और एबेलसन, 1940',
      odia: 'ମ୍ୟାକମିଲାନ୍ ଏବଂ ଆବେଲସନ୍, 1940',
    ),
  ),
  ElementData(
    atomicNumber: 94,
    symbol: 'Pu',
    name: 'Plutonium',
    nameOdia: 'ପ୍ଲୁଟୋନିୟମ୍',
    nameHindi: 'प्लूटोनियम',
    group: 8,
    period: 9,
    category: 'actinide',
    atomicMass: '[244]',
    state: 'Solid',
    shells: [2, 8, 18, 32, 24, 8, 2],
    valency: '4, 6',
    meltingPoint: '640 °C',
    boilingPoint: '3228 °C',
    density: '19.82 g/cm³',
    description: LocalizedElementText(
      english:
          'Plutonium is a man-made radioactive metal used to release nuclear energy.',
      hindi:
          'प्लूटोनियम एक मानव निर्मित रेडियोधर्मी धातु है जिसका उपयोग परमाणु ऊर्जा जारी करने के लिए किया जाता है।',
      odia:
          'ପ୍ଲୁଟୋନିୟମ୍ ହେଉଛି ଏକ ମାନବ ନିର୍ମିତ ରେଡିଓଆକ୍ଟିଭ୍ ଧାତୁ ଯାହା ଆଣବିକ ଶକ୍ତି ମୁକ୍ତ କରିବାରେ ବ୍ୟବହୃତ ହୁଏ।',
    ),
    uses: LocalizedElementText(
      english: 'Nuclear reactors, weapons, and power sources for spacecraft.',
      hindi: 'अंतरिक्ष यान के लिए परमाणु रिएक्टर, हथियार और ऊर्जा स्रोत।',
      odia: 'ମହାକାଶଯାନ ପାଇଁ ଆଣବିକ ରିଆକ୍ଟର, ଅସ୍ତ୍ରଶସ୍ତ୍ର ଏବଂ ଶକ୍ତି ଉତ୍ସ।',
    ),
    funFact: LocalizedElementText(
      english:
          'Plutonium power packs keep the Voyager space probes running as they travel beyond our solar system.',
      hindi:
          'प्लूटोनियम पावर पैक वोयाजर अंतरिक्ष जांच को चालू रखते हैं क्योंकि वे हमारे सौर मंडल से परे यात्रा करते हैं।',
      odia:
          'ପ୍ଲୁଟୋନିୟମ୍ ପାୱାର୍ ପ୍ୟାକ୍ ଭଏଜର୍ ସ୍ପେସ୍ ପ୍ରୋବଗୁଡିକ ଚାଲୁ ରଖେ ଯେହେତୁ ସେମାନେ ଆମର ସ ar ର ପ୍ରଣାଳୀ ବାହାରେ ଯାତ୍ରା କରନ୍ତି।',
    ),
    discovery: LocalizedElementText(
      english: 'Seaborg and team, 1940',
      hindi: 'सीबोर्ग और टीम, 1940',
      odia: 'ସେବର୍ଗ ଏବଂ ଦଳ, 1940',
    ),
  ),
  ElementData(
    atomicNumber: 95,
    symbol: 'Am',
    name: 'Americium',
    nameOdia: 'ଆମେରିସିୟମ୍',
    nameHindi: 'अमेरिसियम',
    group: 9,
    period: 9,
    category: 'actinide',
    atomicMass: '[243]',
    state: 'Solid',
    shells: [2, 8, 18, 32, 25, 8, 2],
    valency: '3',
    meltingPoint: '1176 °C',
    boilingPoint: '2011 °C',
    density: '13.67 g/cm³',
    description: LocalizedElementText(
      english:
          'Americium is a man-made radioactive metal used in tiny amounts in everyday devices.',
      hindi:
          'अमेरिकियम एक मानव निर्मित रेडियोधर्मी धातु है जिसका उपयोग रोजमर्रा के उपकरणों में थोड़ी मात्रा में किया जाता है।',
      odia:
          'ଆମେରିସିୟମ୍ ହେଉଛି ଏକ ମନୁଷ୍ୟକୃତ ରେଡିଓଆକ୍ଟିଭ୍ ଧାତୁ ଯାହାକି ଦ day ନନ୍ଦିନ ଉପକରଣରେ ଅଳ୍ପ ପରିମାଣରେ ବ୍ୟବହୃତ ହୁଏ।',
    ),
    uses: LocalizedElementText(
      english: 'Smoke detectors and measuring instruments.',
      hindi: 'धुआं डिटेक्टर और मापने के उपकरण।',
      odia: 'ଧୂଆଁ ଡିଟେକ୍ଟର ଏବଂ ମାପ ଯନ୍ତ୍ର।',
    ),
    funFact: LocalizedElementText(
      english:
          'A tiny speck of americium sits inside most household smoke detectors, helping them sense smoke.',
      hindi:
          'अमेरिकियम का एक छोटा सा कण अधिकांश घरेलू धूम्रपान डिटेक्टरों के अंदर बैठता है, जिससे उन्हें धुएं को समझने में मदद मिलती है।',
      odia:
          'ଆମେରିକାର ଏକ କ୍ଷୁଦ୍ର ଦାଗ ଅଧିକାଂଶ ଘରର ଧୂଆଁ ଡିଟେକ୍ଟର ଭିତରେ ବସି ସେମାନଙ୍କୁ ଧୂଆଁ ଅନୁଭବ କରିବାରେ ସାହାଯ୍ୟ କରେ।',
    ),
    discovery: LocalizedElementText(
      english: 'Seaborg and team, 1944',
      hindi: 'सीबोर्ग और टीम, 1944',
      odia: 'ସେବର୍ଗ ଏବଂ ଦଳ, 1944',
    ),
  ),
  ElementData(
    atomicNumber: 96,
    symbol: 'Cm',
    name: 'Curium',
    nameOdia: 'କ୍ୟୁରିୟମ୍',
    nameHindi: 'क्यूरियम',
    group: 10,
    period: 9,
    category: 'actinide',
    atomicMass: '[247]',
    state: 'Solid',
    shells: [2, 8, 18, 32, 25, 9, 2],
    valency: '3',
    meltingPoint: '1340 °C',
    boilingPoint: null,
    density: '13.51 g/cm³',
    description: LocalizedElementText(
      english:
          'Curium is a man-made radioactive metal that glows in the dark from its own energy.',
      hindi:
          'क्यूरियम एक मानव निर्मित रेडियोधर्मी धातु है जो अंधेरे में अपनी ऊर्जा से चमकती है।',
      odia:
          'କ୍ୟୁରିୟମ୍ ହେଉଛି ଏକ ମାନବ ନିର୍ମିତ ରେଡିଓଆକ୍ଟିଭ୍ ଧାତୁ ଯାହା ନିଜ ଶକ୍ତିରୁ ଅନ୍ଧକାରରେ owes ଲସି ଉଠେ।',
    ),
    uses: LocalizedElementText(
      english: 'Power sources and X-ray instruments on space missions.',
      hindi: 'अंतरिक्ष अभियानों पर विद्युत स्रोत और एक्स-रे उपकरण।',
      odia: 'ମହାକାଶ ମିଶନରେ ଶକ୍ତି ଉତ୍ସ ଏବଂ ଏକ୍ସ-ରେ ଯନ୍ତ୍ରଗୁଡ଼ିକ।',
    ),
    funFact: LocalizedElementText(
      english:
          'It is named after Marie and Pierre Curie, the famous couple who studied radioactivity.',
      hindi:
          'इसका नाम रेडियोधर्मिता का अध्ययन करने वाले प्रसिद्ध जोड़े मैरी और पियरे क्यूरी के नाम पर रखा गया है।',
      odia:
          'ରେଡିଓଆକ୍ଟିଭିଟି ଅଧ୍ୟୟନ କରୁଥିବା ପ୍ରସିଦ୍ଧ ଦମ୍ପତି ମାରି ଏବଂ ପିଆର କ୍ୟୁରିଙ୍କ ନାମରେ ଏହାର ନାମକରଣ କରାଯାଇଛି।',
    ),
    discovery: LocalizedElementText(
      english: 'Seaborg and team, 1944',
      hindi: 'सीबोर्ग और टीम, 1944',
      odia: 'ସେବର୍ଗ ଏବଂ ଦଳ, 1944',
    ),
  ),
  ElementData(
    atomicNumber: 97,
    symbol: 'Bk',
    name: 'Berkelium',
    nameOdia: 'ବର୍କେଲିୟମ୍',
    nameHindi: 'बर्केलियम',
    group: 11,
    period: 9,
    category: 'actinide',
    atomicMass: '[247]',
    state: 'Solid',
    shells: [2, 8, 18, 32, 27, 8, 2],
    valency: '3',
    meltingPoint: '986 °C',
    boilingPoint: null,
    density: '14.78 g/cm³',
    description: LocalizedElementText(
      english:
          'Berkelium is a rare, man-made radioactive metal made only in tiny amounts.',
      hindi:
          'बर्केलियम एक दुर्लभ, मानव निर्मित रेडियोधर्मी धातु है जो केवल थोड़ी मात्रा में बनाई जाती है।',
      odia:
          'ବର୍କେଲିୟମ୍ ହେଉଛି ଏକ ବିରଳ, ମନୁଷ୍ୟକୃତ ରେଡିଓଆକ୍ଟିଭ୍ ଧାତୁ ଯାହା ଅଳ୍ପ ପରିମାଣରେ ନିର୍ମିତ।',
    ),
    uses: LocalizedElementText(
      english: 'Scientific research only; used to make heavier elements.',
      hindi:
          'केवल वैज्ञानिक अनुसंधान; भारी तत्वों को बनाने के लिए उपयोग किया जाता है।',
      odia:
          'କେବଳ ବ Scientific ଜ୍ଞାନିକ ଅନୁସନ୍ଧାନ; ଭାରୀ ଉପାଦାନ ତିଆରି କରିବାରେ ବ୍ୟବହୃତ ହୁଏ।',
    ),
    funFact: LocalizedElementText(
      english:
          'It was used to help create the super-heavy element tennessine in the laboratory.',
      hindi:
          'इसका उपयोग प्रयोगशाला में अति-भारी तत्व टेनेसीन बनाने में मदद के लिए किया गया था।',
      odia:
          'ଲାବୋରେଟୋରୀରେ ସୁପର-ଭାରୀ ଉପାଦାନ ଟେନେସିନ୍ ସୃଷ୍ଟି କରିବାରେ ଏହା ବ୍ୟବହୃତ ହୋଇଥିଲା।',
    ),
    discovery: LocalizedElementText(
      english: 'Seaborg and team, 1949',
      hindi: 'सीबॉर्ग और टीम, 1949',
      odia: 'ସେବର୍ଗ ଏବଂ ଦଳ, 1949',
    ),
  ),
  ElementData(
    atomicNumber: 98,
    symbol: 'Cf',
    name: 'Californium',
    nameOdia: 'କାଲିଫୋର୍ନିୟମ୍',
    nameHindi: 'कैलिफ़ोर्नियम',
    group: 12,
    period: 9,
    category: 'actinide',
    atomicMass: '[251]',
    state: 'Solid',
    shells: [2, 8, 18, 32, 28, 8, 2],
    valency: '3',
    meltingPoint: '900 °C',
    boilingPoint: null,
    density: '15.1 g/cm³',
    description: LocalizedElementText(
      english:
          'Californium is a man-made radioactive metal that is a powerful source of neutrons.',
      hindi:
          'कैलिफ़ोर्नियम एक मानव निर्मित रेडियोधर्मी धातु है जो न्यूट्रॉन का एक शक्तिशाली स्रोत है।',
      odia:
          'କାଲିଫର୍ନିଆ ଏକ ମନୁଷ୍ୟକୃତ ରେଡ଼ିଓଏକ୍ଟିଭ୍ ଧାତୁ ଯାହା ନ୍ୟୁଟ୍ରନ୍ ର ଏକ ଶକ୍ତିଶାଳୀ ଉତ୍ସ।',
    ),
    uses: LocalizedElementText(
      english: 'Detecting gold and oil, and starting up nuclear reactors.',
      hindi: 'सोने और तेल का पता लगाना और परमाणु रिएक्टर शुरू करना।',
      odia: 'ସୁନା ଏବଂ ତେଲ ଚିହ୍ନଟ କରିବା, ଏବଂ ଆଣବିକ ରିଆକ୍ଟର ଆରମ୍ଭ କରିବା।',
    ),
    funFact: LocalizedElementText(
      english:
          'It is one of the most expensive materials on Earth, worth far more than gold by weight.',
      hindi:
          'यह पृथ्वी पर सबसे महंगी सामग्रियों में से एक है, जिसका मूल्य वजन के हिसाब से सोने से कहीं अधिक है।',
      odia:
          'ଏହା ପୃଥିବୀର ସବୁଠାରୁ ମହଙ୍ଗା ସାମଗ୍ରୀ ମଧ୍ୟରୁ ଗୋଟିଏ, ଓଜନ ଅନୁଯାୟୀ ସୁନାଠାରୁ ବହୁ ମୂଲ୍ୟବାନ।',
    ),
    discovery: LocalizedElementText(
      english: 'Seaborg and team, 1950',
      hindi: 'सीबॉर्ग और टीम, 1950',
      odia: 'ସେବର୍ଗ ଏବଂ ଦଳ, 1950',
    ),
  ),
  ElementData(
    atomicNumber: 99,
    symbol: 'Es',
    name: 'Einsteinium',
    nameOdia: 'ଆଇନ୍‌ଷ୍ଟାଇନିୟମ୍',
    nameHindi: 'आइंस्टीनियम',
    group: 13,
    period: 9,
    category: 'actinide',
    atomicMass: '[252]',
    state: 'Solid',
    shells: [2, 8, 18, 32, 29, 8, 2],
    valency: '3',
    meltingPoint: '860 °C',
    boilingPoint: null,
    density: '8.84 g/cm³',
    description: LocalizedElementText(
      english:
          'Einsteinium is a man-made radioactive metal first found in the debris of a nuclear blast.',
      hindi:
          'आइंस्टीनियम एक मानव निर्मित रेडियोधर्मी धातु है जो सबसे पहले परमाणु विस्फोट के मलबे में पाई गई थी।',
      odia:
          'ଆଇନଷ୍ଟେନିୟମ୍ ହେଉଛି ଏକ ମନୁଷ୍ୟ ଦ୍ୱାରା ନିର୍ମିତ ରେଡିଓଆକ୍ଟିଭ୍ ଧାତୁ ଯାହା ପରମାଣୁ ବିସ୍ଫୋରଣର ଆବର୍ଜନାରେ ପ୍ରଥମେ ମିଳିଥିଲା।',
    ),
    uses: LocalizedElementText(
      english: 'Scientific research only; no everyday uses.',
      hindi: 'केवल वैज्ञानिक अनुसंधान; कोई रोजमर्रा का उपयोग नहीं.',
      odia:
          'କେବଳ ବ Scientific ଜ୍ଞାନିକ ଅନୁସନ୍ଧାନ; କ every ଣସି ଦ day ନନ୍ଦିନ ବ୍ୟବହାର ନାହିଁ।',
    ),
    funFact: LocalizedElementText(
      english:
          'It is named after Albert Einstein and was discovered in the fallout of a hydrogen bomb test.',
      hindi:
          'इसका नाम अल्बर्ट आइंस्टीन के नाम पर रखा गया है और इसकी खोज हाइड्रोजन बम परीक्षण के परिणामस्वरूप हुई थी।',
      odia:
          'ଏହାର ନାମ ଆଲବର୍ଟ ଆଇନଷ୍ଟାଇନଙ୍କ ନାମରେ ନାମିତ ହୋଇଛି ଏବଂ ହାଇଡ୍ରୋଜେନ ବୋମା ପରୀକ୍ଷଣରେ ଏହା ଆବିଷ୍କୃତ ହୋଇଛି।',
    ),
    discovery: LocalizedElementText(
      english: 'Ghiorso and team, 1952',
      hindi: 'घियोर्सो और टीम, 1952',
      odia: 'Ghiorso ଏବଂ ଦଳ, 1952',
    ),
  ),
  ElementData(
    atomicNumber: 100,
    symbol: 'Fm',
    name: 'Fermium',
    nameOdia: 'ଫର୍ମିୟମ୍',
    nameHindi: 'फर्मियम',
    group: 14,
    period: 9,
    category: 'actinide',
    atomicMass: '[257]',
    state: 'Solid',
    shells: [2, 8, 18, 32, 30, 8, 2],
    valency: '3',
    meltingPoint: '1527 °C',
    boilingPoint: null,
    density: null,
    description: LocalizedElementText(
      english:
          'Fermium is a man-made radioactive metal that exists only briefly in laboratories.',
      hindi:
          'फ़र्मियम एक मानव निर्मित रेडियोधर्मी धातु है जो प्रयोगशालाओं में केवल थोड़े समय के लिए मौजूद होती है।',
      odia:
          'ଫର୍ମିୟମ୍ ହେଉଛି ଏକ ମାନବ ନିର୍ମିତ ରେଡିଓଆକ୍ଟିଭ୍ ଧାତୁ ଯାହା କେବଳ ଲାବୋରେଟୋରୀରେ ବିଦ୍ୟମାନ।',
    ),
    uses: LocalizedElementText(
      english: 'Scientific research only; no everyday uses.',
      hindi: 'केवल वैज्ञानिक अनुसंधान; कोई रोजमर्रा का उपयोग नहीं.',
      odia:
          'କେବଳ ବ Scientific ଜ୍ଞାନିକ ଅନୁସନ୍ଧାନ; କ every ଣସି ଦ day ନନ୍ଦିନ ବ୍ୟବହାର ନାହିଁ।',
    ),
    funFact: LocalizedElementText(
      english:
          'It is named after Enrico Fermi, the scientist who built the first nuclear reactor.',
      hindi:
          'इसका नाम पहला परमाणु रिएक्टर बनाने वाले वैज्ञानिक एनरिको फर्मी के नाम पर रखा गया है।',
      odia:
          'ପ୍ରଥମ ଆଣବିକ ରିଆକ୍ଟର ନିର୍ମାଣ କରିଥିବା ବ scientist ଜ୍ଞାନିକ ଏନ୍ରିକୋ ଫର୍ମୀଙ୍କ ନାମରେ ଏହାର ନାମକରଣ କରାଯାଇଛି।',
    ),
    discovery: LocalizedElementText(
      english: 'Ghiorso and team, 1952',
      hindi: 'घियोर्सो और टीम, 1952',
      odia: 'Ghiorso ଏବଂ ଦଳ, 1952',
    ),
  ),
  ElementData(
    atomicNumber: 101,
    symbol: 'Md',
    name: 'Mendelevium',
    nameOdia: 'ମେଣ୍ଡେଲେଭିୟମ୍',
    nameHindi: 'मेंडेलीवियम',
    group: 15,
    period: 9,
    category: 'actinide',
    atomicMass: '[258]',
    state: 'Solid',
    shells: [2, 8, 18, 32, 31, 8, 2],
    valency: '2, 3',
    meltingPoint: '827 °C',
    boilingPoint: null,
    density: null,
    description: LocalizedElementText(
      english:
          'Mendelevium is a man-made radioactive element created a few atoms at a time.',
      hindi:
          'मेंडेलीवियम एक मानव निर्मित रेडियोधर्मी तत्व है जो एक समय में कुछ परमाणु बनाता है।',
      odia:
          'ମେଣ୍ଡେଲେଭିୟମ୍ ହେଉଛି ଏକ ମନୁଷ୍ୟ ଦ୍ୱାରା ନିର୍ମିତ ରେଡିଓଆକ୍ଟିଭ୍ ଉପାଦାନ ଯାହା ଏକ ସମୟରେ କିଛି ପରମାଣୁ ସୃଷ୍ଟି କରିଥିଲା।',
    ),
    uses: LocalizedElementText(
      english: 'Scientific research only; no everyday uses.',
      hindi: 'केवल वैज्ञानिक अनुसंधान; कोई रोजमर्रा का उपयोग नहीं.',
      odia:
          'କେବଳ ବ Scientific ଜ୍ଞାନିକ ଅନୁସନ୍ଧାନ; କ every ଣସି ଦ day ନନ୍ଦିନ ବ୍ୟବହାର ନାହିଁ।',
    ),
    funFact: LocalizedElementText(
      english:
          'It is named after Dmitri Mendeleev, who invented the periodic table.',
      hindi:
          'इसका नाम दिमित्री मेंडेलीव के नाम पर रखा गया है, जिन्होंने आवर्त सारणी का आविष्कार किया था।',
      odia:
          'ପର୍ଯ୍ୟାୟ ଟେବୁଲ୍ ଉଦ୍ଭାବନ କରିଥିବା ଦିମିତ୍ରୀ ମେଣ୍ଡେଲିଭଙ୍କ ନାମରେ ଏହାର ନାମକରଣ କରାଯାଇଛି।',
    ),
    discovery: LocalizedElementText(
      english: 'Ghiorso and team, 1955',
      hindi: 'घियोर्सो और टीम, 1955',
      odia: 'Ghiorso ଏବଂ ଦଳ, 1955',
    ),
  ),
  ElementData(
    atomicNumber: 102,
    symbol: 'No',
    name: 'Nobelium',
    nameOdia: 'ନୋବେଲିୟମ୍',
    nameHindi: 'नोबेलियम',
    group: 16,
    period: 9,
    category: 'actinide',
    atomicMass: '[259]',
    state: 'Solid',
    shells: [2, 8, 18, 32, 32, 8, 2],
    valency: '2, 3',
    meltingPoint: '827 °C',
    boilingPoint: null,
    density: null,
    description: LocalizedElementText(
      english:
          'Nobelium is a man-made radioactive element that lasts only a short time.',
      hindi:
          'नोबेलियम एक मानव निर्मित रेडियोधर्मी तत्व है जो थोड़े समय के लिए ही रहता है।',
      odia:
          'ନୋବେଲିୟମ୍ ହେଉଛି ଏକ ମନୁଷ୍ୟ ଦ୍ୱାରା ନିର୍ମିତ ରେଡିଓଆକ୍ଟିଭ୍ ଉପାଦାନ ଯାହା କେବଳ ଅଳ୍ପ ସମୟ ପର୍ଯ୍ୟନ୍ତ ରହିଥାଏ।',
    ),
    uses: LocalizedElementText(
      english: 'Scientific research only; no everyday uses.',
      hindi: 'केवल वैज्ञानिक अनुसंधान; कोई रोजमर्रा का उपयोग नहीं.',
      odia:
          'କେବଳ ବ Scientific ଜ୍ଞାନିକ ଅନୁସନ୍ଧାନ; କ every ଣସି ଦ day ନନ୍ଦିନ ବ୍ୟବହାର ନାହିଁ।',
    ),
    funFact: LocalizedElementText(
      english:
          'It is named after Alfred Nobel, the inventor of dynamite who created the Nobel Prizes.',
      hindi:
          'इसका नाम डायनामाइट के आविष्कारक अल्फ्रेड नोबेल के नाम पर रखा गया है, जिन्होंने नोबेल पुरस्कारों का निर्माण किया था।',
      odia:
          'ନୋବେଲ ପୁରସ୍କାର ସୃଷ୍ଟି କରିଥିବା ଡାଇନାମାଇଟ୍ ର ଉଦ୍ଭାବକ ଆଲଫ୍ରେଡ୍ ନୋବେଲଙ୍କ ନାମରେ ଏହାର ନାମକରଣ କରାଯାଇଛି।',
    ),
    discovery: LocalizedElementText(
      english: 'JINR Dubna, 1966',
      hindi: 'जेआईएनआर डुबना, 1966',
      odia: 'JINR Dubna, 1966',
    ),
  ),
  ElementData(
    atomicNumber: 103,
    symbol: 'Lr',
    name: 'Lawrencium',
    nameOdia: 'ଲରେନ୍‌ସିୟମ୍',
    nameHindi: 'लॉरेंसियम',
    group: 17,
    period: 9,
    category: 'actinide',
    atomicMass: '[266]',
    state: 'Solid',
    shells: [2, 8, 18, 32, 32, 8, 3],
    valency: '3',
    meltingPoint: '1627 °C',
    boilingPoint: null,
    density: null,
    description: LocalizedElementText(
      english:
          'Lawrencium is a man-made radioactive element and the last of the actinide row.',
      hindi:
          'लॉरेंसियम एक मानव निर्मित रेडियोधर्मी तत्व है और एक्टिनाइड पंक्ति का अंतिम तत्व है।',
      odia:
          'ଲରେନ୍ସିୟମ୍ ହେଉଛି ଏକ ମନୁଷ୍ୟ ଦ୍ୱାରା ନିର୍ମିତ ରେଡିଓଆକ୍ଟିଭ୍ ଉପାଦାନ ଏବଂ ଆକ୍ଟିନାଇଡ୍ ଧାଡିର ଶେଷ।',
    ),
    uses: LocalizedElementText(
      english: 'Scientific research only; no everyday uses.',
      hindi: 'केवल वैज्ञानिक अनुसंधान; कोई रोजमर्रा का उपयोग नहीं.',
      odia:
          'କେବଳ ବ Scientific ଜ୍ଞାନିକ ଅନୁସନ୍ଧାନ; କ every ଣସି ଦ day ନନ୍ଦିନ ବ୍ୟବହାର ନାହିଁ।',
    ),
    funFact: LocalizedElementText(
      english:
          'It is named after Ernest Lawrence, who invented the cyclotron atom-smasher.',
      hindi:
          'इसका नाम अर्नेस्ट लॉरेंस के नाम पर रखा गया है, जिन्होंने साइक्लोट्रॉन एटम-स्मैशर का आविष्कार किया था।',
      odia:
          'ଏହାର ନାମ ଏର୍ନେଷ୍ଟ ଲରେନ୍ସଙ୍କ ନାମରେ ନାମିତ, ଯିଏ ସାଇକ୍ଲୋଟ୍ରନ୍ ପରମାଣୁ-ସ୍ମାସର ଉଦ୍ଭାବନ କରିଥିଲେ।',
    ),
    discovery: LocalizedElementText(
      english: 'Ghiorso and team, 1961',
      hindi: 'घियोर्सो और टीम, 1961',
      odia: 'Ghiorso ଏବଂ ଦଳ, 1961',
    ),
  ),
  ElementData(
    atomicNumber: 104,
    symbol: 'Rf',
    name: 'Rutherfordium',
    nameOdia: 'ରଦରଫୋର୍ଡିୟମ୍',
    nameHindi: 'रदरफोर्डियम',
    group: 4,
    period: 7,
    category: 'transition_metal',
    atomicMass: '[267]',
    state: 'Solid',
    shells: [2, 8, 18, 32, 32, 10, 2],
    valency: '4',
    meltingPoint: null,
    boilingPoint: null,
    density: null,
    description: LocalizedElementText(
      english:
          'Rutherfordium is a man-made radioactive element created in particle accelerators.',
      hindi:
          'रदरफोर्डियम एक मानव निर्मित रेडियोधर्मी तत्व है जो कण त्वरक में बनाया जाता है।',
      odia:
          'ରାଉଟରଫୋର୍ଡିୟମ୍ ହେଉଛି ଏକ ମନୁଷ୍ୟକୃତ ରେଡିଓଆକ୍ଟିଭ୍ ଉପାଦାନ ଯାହା କଣିକା ତ୍ୱରାନ୍ୱିତକାରୀରେ ସୃଷ୍ଟି।',
    ),
    uses: LocalizedElementText(
      english: 'Scientific research only; no everyday uses.',
      hindi: 'केवल वैज्ञानिक अनुसंधान; कोई रोजमर्रा का उपयोग नहीं.',
      odia:
          'କେବଳ ବ Scientific ଜ୍ଞାନିକ ଅନୁସନ୍ଧାନ; କ every ଣସି ଦ day ନନ୍ଦିନ ବ୍ୟବହାର ନାହିଁ।',
    ),
    funFact: LocalizedElementText(
      english:
          'It is named after Ernest Rutherford, who discovered the atomic nucleus.',
      hindi:
          'इसका नाम अर्नेस्ट रदरफोर्ड के नाम पर रखा गया है, जिन्होंने परमाणु नाभिक की खोज की थी।',
      odia:
          'ପରମାଣୁ ନ୍ୟୁକ୍ଲିଅସ୍ ଆବିଷ୍କାର କରିଥିବା ଏର୍ନଷ୍ଟ ରାଉଟରଫୋର୍ଡଙ୍କ ନାମରେ ଏହାର ନାମକରଣ କରାଯାଇଛି।',
    ),
    discovery: LocalizedElementText(
      english: 'JINR Dubna & Berkeley, 1964',
      hindi: 'जेआईएनआर डुबना और बर्कले, 1964',
      odia: 'JINR Dubna & Berkeley, 1964',
    ),
  ),
  ElementData(
    atomicNumber: 105,
    symbol: 'Db',
    name: 'Dubnium',
    nameOdia: 'ଡବ୍‌ନିୟମ୍',
    nameHindi: 'डब्नियम',
    group: 5,
    period: 7,
    category: 'transition_metal',
    atomicMass: '[268]',
    state: 'Solid',
    shells: [2, 8, 18, 32, 32, 11, 2],
    valency: '5',
    meltingPoint: null,
    boilingPoint: null,
    density: null,
    description: LocalizedElementText(
      english:
          'Dubnium is a man-made radioactive element that exists for only moments.',
      hindi:
          'डब्नियम एक मानव निर्मित रेडियोधर्मी तत्व है जो केवल क्षणों के लिए मौजूद रहता है।',
      odia:
          'ଡବନିୟମ୍ ହେଉଛି ଏକ ମନୁଷ୍ୟ ଦ୍ୱାରା ନିର୍ମିତ ରେଡିଓଆକ୍ଟିଭ୍ ଉପାଦାନ ଯାହା କେବଳ କ୍ଷଣ ପାଇଁ ବିଦ୍ୟମାନ।',
    ),
    uses: LocalizedElementText(
      english: 'Scientific research only; no everyday uses.',
      hindi: 'केवल वैज्ञानिक अनुसंधान; कोई रोजमर्रा का उपयोग नहीं.',
      odia:
          'କେବଳ ବ Scientific ଜ୍ଞାନିକ ଅନୁସନ୍ଧାନ; କ every ଣସି ଦ day ନନ୍ଦିନ ବ୍ୟବହାର ନାହିଁ।',
    ),
    funFact: LocalizedElementText(
      english:
          'It is named after Dubna in Russia, home to a famous laboratory that makes new elements.',
      hindi:
          'इसका नाम रूस में डुबना के नाम पर रखा गया है, जहां एक प्रसिद्ध प्रयोगशाला है जो नए तत्व बनाती है।',
      odia:
          'Russia ଷର ଡୁବନା ନାମରେ ଏହାର ନାମକରଣ କରାଯାଇଛି, ଏକ ପ୍ରସିଦ୍ଧ ଲାବୋରେଟୋରୀ ଯାହା ନୂତନ ଉପାଦାନ ତିଆରି କରେ।',
    ),
    discovery: LocalizedElementText(
      english: 'JINR Dubna & Berkeley, 1968',
      hindi: 'जेआईएनआर डुबना और बर्कले, 1968',
      odia: 'JINR Dubna & Berkeley, 1968',
    ),
  ),
  ElementData(
    atomicNumber: 106,
    symbol: 'Sg',
    name: 'Seaborgium',
    nameOdia: 'ସିବୋର୍ଗିୟମ୍',
    nameHindi: 'सीबोर्गियम',
    group: 6,
    period: 7,
    category: 'transition_metal',
    atomicMass: '[269]',
    state: 'Solid',
    shells: [2, 8, 18, 32, 32, 12, 2],
    valency: '6',
    meltingPoint: null,
    boilingPoint: null,
    density: null,
    description: LocalizedElementText(
      english:
          'Seaborgium is a man-made radioactive element produced atom by atom.',
      hindi:
          'सीबोर्गियम एक मानव निर्मित रेडियोधर्मी तत्व है जो परमाणु द्वारा परमाणु निर्मित होता है।',
      odia:
          'ସେବୋର୍ଗିୟମ୍ ହେଉଛି ମନୁଷ୍ୟ ଦ୍ୱାରା ନିର୍ମିତ ରେଡ଼ିଓଏକ୍ଟିଭ୍ ଉପାଦାନ ଯାହା ପରମାଣୁ ଦ୍ୱାରା ଉତ୍ପନ୍ନ।',
    ),
    uses: LocalizedElementText(
      english: 'Scientific research only; no everyday uses.',
      hindi: 'केवल वैज्ञानिक अनुसंधान; कोई रोजमर्रा का उपयोग नहीं.',
      odia:
          'କେବଳ ବ Scientific ଜ୍ଞାନିକ ଅନୁସନ୍ଧାନ; କ every ଣସି ଦ day ନନ୍ଦିନ ବ୍ୟବହାର ନାହିଁ।',
    ),
    funFact: LocalizedElementText(
      english:
          'It was named after Glenn Seaborg while he was still alive — a rare honour for a scientist.',
      hindi:
          'इसका नाम ग्लेन सीबॉर्ग के नाम पर रखा गया था जब वह जीवित थे - एक वैज्ञानिक के लिए एक दुर्लभ सम्मान।',
      odia:
          'ସେ ଜୀବିତ ଥିବାବେଳେ ଏହାର ନାମ ଗ୍ଲେନ୍ ସେବର୍ଗଙ୍କ ନାମରେ ନାମିତ କରାଯାଇଥିଲା - ଜଣେ ବ scientist ଜ୍ଞାନିକଙ୍କ ପାଇଁ ଏକ ବିରଳ ସମ୍ମାନ।',
    ),
    discovery: LocalizedElementText(
      english: 'Ghiorso and team, 1974',
      hindi: 'घियोर्सो और टीम, 1974',
      odia: 'Ghiorso ଏବଂ ଦଳ, 1974',
    ),
  ),
  ElementData(
    atomicNumber: 107,
    symbol: 'Bh',
    name: 'Bohrium',
    nameOdia: 'ବୋରିୟମ୍',
    nameHindi: 'बोहरियम',
    group: 7,
    period: 7,
    category: 'transition_metal',
    atomicMass: '[270]',
    state: 'Solid',
    shells: [2, 8, 18, 32, 32, 13, 2],
    valency: '7',
    meltingPoint: null,
    boilingPoint: null,
    density: null,
    description: LocalizedElementText(
      english:
          'Bohrium is a man-made radioactive element created in tiny numbers of atoms.',
      hindi:
          'बोहरियम एक मानव निर्मित रेडियोधर्मी तत्व है जो छोटी संख्या में परमाणुओं में निर्मित होता है।',
      odia:
          'ବୋହରିୟମ୍ ହେଉଛି ମନୁଷ୍ୟ ଦ୍ୱାରା ନିର୍ମିତ ରେଡ଼ିଓଏକ୍ଟିଭ୍ ଉପାଦାନ ଯାହା ଅଳ୍ପ ସଂଖ୍ୟକ ପରମାଣୁରେ ସୃଷ୍ଟି।',
    ),
    uses: LocalizedElementText(
      english: 'Scientific research only; no everyday uses.',
      hindi: 'केवल वैज्ञानिक अनुसंधान; कोई रोजमर्रा का उपयोग नहीं.',
      odia:
          'କେବଳ ବ Scientific ଜ୍ଞାନିକ ଅନୁସନ୍ଧାନ; କ every ଣସି ଦ day ନନ୍ଦିନ ବ୍ୟବହାର ନାହିଁ।',
    ),
    funFact: LocalizedElementText(
      english:
          'It is named after Niels Bohr, who explained how electrons orbit inside atoms.',
      hindi:
          'इसका नाम नील्स बोह्र के नाम पर रखा गया है, जिन्होंने बताया कि इलेक्ट्रॉन परमाणुओं के अंदर कैसे परिक्रमा करते हैं।',
      odia:
          'ଏହା ନିଲ୍ସ ବୋହରଙ୍କ ନାମରେ ନାମିତ ହୋଇଛି, ଯିଏ ପରମାଣୁ ଭିତରେ କିପରି ଇଲେକ୍ଟ୍ରନ୍ ଗତି କରନ୍ତି ତାହା ବ୍ୟାଖ୍ୟା କରିଥିଲେ।',
    ),
    discovery: LocalizedElementText(
      english: 'GSI Darmstadt, 1981',
      hindi: 'जीएसआई डार्मस्टेड, 1981',
      odia: 'GSI Darmstadt, 1981',
    ),
  ),
  ElementData(
    atomicNumber: 108,
    symbol: 'Hs',
    name: 'Hassium',
    nameOdia: 'ହାସିୟମ୍',
    nameHindi: 'हैसियम',
    group: 8,
    period: 7,
    category: 'transition_metal',
    atomicMass: '[269]',
    state: 'Solid',
    shells: [2, 8, 18, 32, 32, 14, 2],
    valency: '8',
    meltingPoint: null,
    boilingPoint: null,
    density: null,
    description: LocalizedElementText(
      english:
          'Hassium is a man-made radioactive element that survives for only a fraction of a second.',
      hindi:
          'हैसियम एक मानव निर्मित रेडियोधर्मी तत्व है जो एक सेकंड के कुछ अंश तक ही जीवित रहता है।',
      odia:
          'ହାସିୟମ୍ ହେଉଛି ଏକ ମନୁଷ୍ୟ ଦ୍ୱାରା ନିର୍ମିତ ରେଡିଓଆକ୍ଟିଭ୍ ଉପାଦାନ ଯାହା କେବଳ ଏକ ସେକେଣ୍ଡର କିଛି ଅଂଶ ପାଇଁ ବଞ୍ଚିଥାଏ।',
    ),
    uses: LocalizedElementText(
      english: 'Scientific research only; no everyday uses.',
      hindi: 'केवल वैज्ञानिक अनुसंधान; कोई रोजमर्रा का उपयोग नहीं.',
      odia:
          'କେବଳ ବ Scientific ଜ୍ଞାନିକ ଅନୁସନ୍ଧାନ; କ every ଣସି ଦ day ନନ୍ଦିନ ବ୍ୟବହାର ନାହିଁ।',
    ),
    funFact: LocalizedElementText(
      english:
          'Its name comes from the Latin word for the German state of Hesse.',
      hindi: 'इसका नाम जर्मन राज्य हेस्से के लिए लैटिन शब्द से आया है।',
      odia: 'ଏହାର ନାମ ଜର୍ମାନୀର ହେସେ ରାଜ୍ୟ ପାଇଁ ଲାଟିନ୍ ଶବ୍ଦରୁ ଆସିଛି।',
    ),
    discovery: LocalizedElementText(
      english: 'GSI Darmstadt, 1984',
      hindi: 'जीएसआई डार्मस्टेड, 1984',
      odia: 'GSI Darmstadt, 1984',
    ),
  ),
  ElementData(
    atomicNumber: 109,
    symbol: 'Mt',
    name: 'Meitnerium',
    nameOdia: 'ମାଇଟ୍‌ନେରିୟମ୍',
    nameHindi: 'माइट्नेरियम',
    group: 9,
    period: 7,
    category: 'unknown',
    atomicMass: '[278]',
    state: 'Solid',
    shells: [2, 8, 18, 32, 32, 15, 2],
    valency: '3',
    meltingPoint: null,
    boilingPoint: null,
    density: null,
    description: LocalizedElementText(
      english:
          'Meitnerium is a man-made radioactive element made only a few atoms at a time.',
      hindi:
          'मीटनेरियम एक मानव निर्मित रेडियोधर्मी तत्व है जो एक समय में केवल कुछ परमाणु बनाता है।',
      odia:
          'ମେଟେନେରିୟମ୍ ହେଉଛି ଏକ ମନୁଷ୍ୟ ଦ୍ୱାରା ନିର୍ମିତ ରେଡିଓଆକ୍ଟିଭ୍ ଉପାଦାନ ଯାହା ଏକ ସମୟରେ ମାତ୍ର ଅଳ୍ପ ପରମାଣୁ ତିଆରି କରେ।',
    ),
    uses: LocalizedElementText(
      english: 'Scientific research only; no everyday uses.',
      hindi: 'केवल वैज्ञानिक अनुसंधान; कोई रोजमर्रा का उपयोग नहीं.',
      odia:
          'କେବଳ ବ Scientific ଜ୍ଞାନିକ ଅନୁସନ୍ଧାନ; କ every ଣସି ଦ day ନନ୍ଦିନ ବ୍ୟବହାର ନାହିଁ।',
    ),
    funFact: LocalizedElementText(
      english:
          'It is named after Lise Meitner, a physicist who helped explain nuclear fission.',
      hindi:
          'इसका नाम भौतिक विज्ञानी लिसे मीटनर के नाम पर रखा गया है, जिन्होंने परमाणु विखंडन को समझाने में मदद की थी।',
      odia:
          'ପରମାଣୁ ବିଭାଜନକୁ ବ୍ୟାଖ୍ୟା କରିବାରେ ସାହାଯ୍ୟ କରିଥିବା ପଦାର୍ଥ ବିଜ୍ଞାନୀ ଲିଜ୍ ମେଟନର୍ଙ୍କ ନାମରେ ଏହାର ନାମକରଣ କରାଯାଇଛି।',
    ),
    discovery: LocalizedElementText(
      english: 'GSI Darmstadt, 1982',
      hindi: 'जीएसआई डार्मस्टेड, 1982',
      odia: 'GSI Darmstadt, 1982',
    ),
  ),
  ElementData(
    atomicNumber: 110,
    symbol: 'Ds',
    name: 'Darmstadtium',
    nameOdia: 'ଡାର୍ମଷ୍ଟାଡ଼ିୟମ୍',
    nameHindi: 'डार्मस्टेडेटियम',
    group: 10,
    period: 7,
    category: 'unknown',
    atomicMass: '[281]',
    state: 'Solid',
    shells: [2, 8, 18, 32, 32, 16, 2],
    valency: '6',
    meltingPoint: null,
    boilingPoint: null,
    density: null,
    description: LocalizedElementText(
      english:
          'Darmstadtium is a man-made radioactive element created in a particle accelerator.',
      hindi:
          'डार्मस्टेडियम एक मानव निर्मित रेडियोधर्मी तत्व है जो कण त्वरक में बनाया जाता है।',
      odia:
          'ଡାରମଷ୍ଟାଡିୟମ୍ ହେଉଛି ଏକ ମନୁଷ୍ୟ ଦ୍ୱାରା ନିର୍ମିତ ରେଡିଓଆକ୍ଟିଭ୍ ଉପାଦାନ ଯାହା ଏକ କଣିକା ତ୍ୱରାନ୍ୱିତକାରୀରେ ସୃଷ୍ଟି।',
    ),
    uses: LocalizedElementText(
      english: 'Scientific research only; no everyday uses.',
      hindi: 'केवल वैज्ञानिक अनुसंधान; कोई रोजमर्रा का उपयोग नहीं.',
      odia:
          'କେବଳ ବ Scientific ଜ୍ଞାନିକ ଅନୁସନ୍ଧାନ; କ every ଣସି ଦ day ନନ୍ଦିନ ବ୍ୟବହାର ନାହିଁ।',
    ),
    funFact: LocalizedElementText(
      english:
          'It is named after Darmstadt, the German city where it was first made.',
      hindi:
          'इसका नाम जर्मन शहर डार्मस्टेड के नाम पर रखा गया है, जहां इसे पहली बार बनाया गया था।',
      odia:
          'ଜର୍ମାନୀର ସହର ଡାରମଷ୍ଟାଡଙ୍କ ନାମରେ ଏହାର ନାମକରଣ କରାଯାଇଥିଲା ଯେଉଁଠାରେ ଏହା ପ୍ରଥମେ ତିଆରି କରାଯାଇଥିଲା।',
    ),
    discovery: LocalizedElementText(
      english: 'GSI Darmstadt, 1994',
      hindi: 'जीएसआई डार्मस्टेड, 1994',
      odia: 'GSI Darmstadt, 1994',
    ),
  ),
  ElementData(
    atomicNumber: 111,
    symbol: 'Rg',
    name: 'Roentgenium',
    nameOdia: 'ରୋଣ୍ଟ୍‌ଜେନିୟମ୍',
    nameHindi: 'रोएंटजेनियम',
    group: 11,
    period: 7,
    category: 'unknown',
    atomicMass: '[282]',
    state: 'Solid',
    shells: [2, 8, 18, 32, 32, 17, 2],
    valency: '3',
    meltingPoint: null,
    boilingPoint: null,
    density: null,
    description: LocalizedElementText(
      english:
          'Roentgenium is a man-made radioactive element that exists for only an instant.',
      hindi:
          'रोएंटजेनियम एक मानव निर्मित रेडियोधर्मी तत्व है जो केवल एक पल के लिए मौजूद रहता है।',
      odia:
          'ରୋଣ୍ଟେଜେନିୟମ୍ ହେଉଛି ଏକ ମନୁଷ୍ୟ ଦ୍ୱାରା ନିର୍ମିତ ରେଡିଓଆକ୍ଟିଭ୍ ଉପାଦାନ ଯାହା କେବଳ ଏକ କ୍ଷଣ ପାଇଁ ବିଦ୍ୟମାନ।',
    ),
    uses: LocalizedElementText(
      english: 'Scientific research only; no everyday uses.',
      hindi: 'केवल वैज्ञानिक अनुसंधान; कोई रोजमर्रा का उपयोग नहीं.',
      odia:
          'କେବଳ ବ Scientific ଜ୍ଞାନିକ ଅନୁସନ୍ଧାନ; କ every ଣସି ଦ day ନନ୍ଦିନ ବ୍ୟବହାର ନାହିଁ।',
    ),
    funFact: LocalizedElementText(
      english: 'It is named after Wilhelm Roentgen, who discovered X-rays.',
      hindi:
          'इसका नाम विल्हेम रोएंटजेन के नाम पर रखा गया है, जिन्होंने एक्स-रे की खोज की थी।',
      odia:
          'ଏକ୍ସ-ରେ ଆବିଷ୍କାର କରିଥିବା ୱିଲହେଲମ୍ ରୋଏଣ୍ଟେନ୍ଙ୍କ ନାମରେ ଏହାର ନାମକରଣ କରାଯାଇଛି।',
    ),
    discovery: LocalizedElementText(
      english: 'GSI Darmstadt, 1994',
      hindi: 'जीएसआई डार्मस्टेड, 1994',
      odia: 'GSI Darmstadt, 1994',
    ),
  ),
  ElementData(
    atomicNumber: 112,
    symbol: 'Cn',
    name: 'Copernicium',
    nameOdia: 'କୋପର୍ନିସିୟମ୍',
    nameHindi: 'कोपरनिसियम',
    group: 12,
    period: 7,
    category: 'transition_metal',
    atomicMass: '[285]',
    state: 'Solid',
    shells: [2, 8, 18, 32, 32, 18, 2],
    valency: '2',
    meltingPoint: null,
    boilingPoint: null,
    density: null,
    description: LocalizedElementText(
      english:
          'Copernicium is a man-made radioactive element thought to behave like a heavy gas.',
      hindi:
          'कॉपरनिसियम एक मानव निर्मित रेडियोधर्मी तत्व है जो भारी गैस की तरह व्यवहार करता है।',
      odia:
          'କପର୍ନିସିୟମ୍ ହେଉଛି ଏକ ମନୁଷ୍ୟ ଦ୍ୱାରା ନିର୍ମିତ ରେଡିଓଆକ୍ଟିଭ୍ ଉପାଦାନ ଯାହା ଏକ ଭାରୀ ଗ୍ୟାସ୍ ପରି ବ୍ୟବହାର କରିବାକୁ ଚିନ୍ତା କରାଯାଏ।',
    ),
    uses: LocalizedElementText(
      english: 'Scientific research only; no everyday uses.',
      hindi: 'केवल वैज्ञानिक अनुसंधान; कोई रोजमर्रा का उपयोग नहीं.',
      odia:
          'କେବଳ ବ Scientific ଜ୍ଞାନିକ ଅନୁସନ୍ଧାନ; କ every ଣସି ଦ day ନନ୍ଦିନ ବ୍ୟବହାର ନାହିଁ।',
    ),
    funFact: LocalizedElementText(
      english:
          'It is named after the astronomer Nicolaus Copernicus, who showed Earth orbits the Sun.',
      hindi:
          'इसका नाम खगोलशास्त्री निकोलस कोपरनिकस के नाम पर रखा गया है, जिन्होंने दिखाया कि पृथ्वी सूर्य की परिक्रमा करती है।',
      odia:
          'ଜ୍ୟୋତିର୍ବିଜ୍ଞାନୀ ନିକୋଲସ୍ କୋପର୍ନିକସ୍ଙ୍କ ନାମରେ ଏହା ନାମିତ ହୋଇଛି, ଯିଏ ପୃଥିବୀ ସୂର୍ଯ୍ୟଙ୍କ ପରିକ୍ରମା କରିଥିଲେ।',
    ),
    discovery: LocalizedElementText(
      english: 'GSI Darmstadt, 1996',
      hindi: 'जीएसआई डार्मस्टेड, 1996',
      odia: 'GSI Darmstadt, 1996',
    ),
  ),
  ElementData(
    atomicNumber: 113,
    symbol: 'Nh',
    name: 'Nihonium',
    nameOdia: 'ନିହୋନିୟମ୍',
    nameHindi: 'निहोनियम',
    group: 13,
    period: 7,
    category: 'unknown',
    atomicMass: '[286]',
    state: 'Solid',
    shells: [2, 8, 18, 32, 32, 18, 3],
    valency: '1',
    meltingPoint: null,
    boilingPoint: null,
    density: null,
    description: LocalizedElementText(
      english:
          'Nihonium is a man-made radioactive element that lasts only a moment.',
      hindi:
          'निहोनियम एक मानव निर्मित रेडियोधर्मी तत्व है जो केवल एक क्षण तक रहता है।',
      odia:
          'ନିହୋନିୟମ୍ ହେଉଛି ଏକ ମନୁଷ୍ୟ ଦ୍ୱାରା ନିର୍ମିତ ରେଡିଓଆକ୍ଟିଭ୍ ଉପାଦାନ ଯାହା କେବଳ କିଛି କ୍ଷଣ ପର୍ଯ୍ୟନ୍ତ ରହିଥାଏ।',
    ),
    uses: LocalizedElementText(
      english: 'Scientific research only; no everyday uses.',
      hindi: 'केवल वैज्ञानिक अनुसंधान; कोई रोजमर्रा का उपयोग नहीं.',
      odia:
          'କେବଳ ବ Scientific ଜ୍ଞାନିକ ଅନୁସନ୍ଧାନ; କ every ଣସି ଦ day ନନ୍ଦିନ ବ୍ୟବହାର ନାହିଁ।',
    ),
    funFact: LocalizedElementText(
      english:
          'Its name comes from "Nihon," the Japanese word for Japan, where it was discovered.',
      hindi:
          'इसका नाम "निहोन" से आया है, जो जापान के लिए जापानी शब्द है, जहां इसकी खोज की गई थी।',
      odia:
          'ଏହାର ନାମ ଜାପାନ ପାଇଁ ଜାପାନୀ ଶବ୍ଦ "ନିହନ୍" ରୁ ଆସିଛି, ଯେଉଁଠାରେ ଏହା ଆବିଷ୍କୃତ ହୋଇଥିଲା।',
    ),
    discovery: LocalizedElementText(
      english: 'RIKEN, 2004',
      hindi: 'रिकेन, 2004',
      odia: 'RIKEN, 2004',
    ),
  ),
  ElementData(
    atomicNumber: 114,
    symbol: 'Fl',
    name: 'Flerovium',
    nameOdia: 'ଫ୍ଲେରୋଭିୟମ୍',
    nameHindi: 'फ्लेरोवियम',
    group: 14,
    period: 7,
    category: 'post_transition',
    atomicMass: '[289]',
    state: 'Solid',
    shells: [2, 8, 18, 32, 32, 18, 4],
    valency: '2, 4',
    meltingPoint: null,
    boilingPoint: null,
    density: null,
    description: LocalizedElementText(
      english:
          'Flerovium is a man-made radioactive element studied for its unusual chemistry.',
      hindi:
          'फ्लेरोवियम एक मानव निर्मित रेडियोधर्मी तत्व है जिसका अध्ययन इसके असामान्य रसायन विज्ञान के लिए किया गया है।',
      odia:
          'ଫ୍ଲେରୋଭିୟମ୍ ହେଉଛି ଏକ ମାନବ ନିର୍ମିତ ରେଡିଓଆକ୍ଟିଭ୍ ଉପାଦାନ ଯାହା ଏହାର ଅସାଧାରଣ ରସାୟନ ପାଇଁ ଅଧ୍ୟୟନ କରାଯାଇଥିଲା।',
    ),
    uses: LocalizedElementText(
      english: 'Scientific research only; no everyday uses.',
      hindi: 'केवल वैज्ञानिक अनुसंधान; कोई रोजमर्रा का उपयोग नहीं.',
      odia:
          'କେବଳ ବ Scientific ଜ୍ଞାନିକ ଅନୁସନ୍ଧାନ; କ every ଣସି ଦ day ନନ୍ଦିନ ବ୍ୟବହାର ନାହିଁ।',
    ),
    funFact: LocalizedElementText(
      english:
          'Scientists hoped it might be part of an "island of stability" of longer-lasting super-heavy atoms.',
      hindi:
          'वैज्ञानिकों को उम्मीद थी कि यह लंबे समय तक चलने वाले अति-भारी परमाणुओं के "स्थिरता के द्वीप" का हिस्सा हो सकता है।',
      odia:
          'ବ long ଜ୍ଞାନିକମାନେ ଆଶା କରିଥିଲେ ଯେ ଏହା ଦୀର୍ଘସ୍ଥାୟୀ ସୁପର ଭାରୀ ପରମାଣୁର ଏକ "ସ୍ଥିରତାର ଦ୍ୱୀପ" ର ଅଂଶ ହୋଇପାରେ।',
    ),
    discovery: LocalizedElementText(
      english: 'JINR Dubna & Livermore, 1998',
      hindi: 'जेआईएनआर डुबना और लिवरमोर, 1998',
      odia: 'JINR Dubna & Livermore, 1998',
    ),
  ),
  ElementData(
    atomicNumber: 115,
    symbol: 'Mc',
    name: 'Moscovium',
    nameOdia: 'ମସ୍‌କୋଭିୟମ୍',
    nameHindi: 'मॉस्कोवियम',
    group: 15,
    period: 7,
    category: 'unknown',
    atomicMass: '[290]',
    state: 'Solid',
    shells: [2, 8, 18, 32, 32, 18, 5],
    valency: '1, 3',
    meltingPoint: null,
    boilingPoint: null,
    density: null,
    description: LocalizedElementText(
      english:
          'Moscovium is a man-made radioactive element created only a few atoms at a time.',
      hindi:
          'मोस्कोवियम एक मानव निर्मित रेडियोधर्मी तत्व है जो एक समय में केवल कुछ परमाणु बनाता है।',
      odia:
          'ମସ୍କୋଭିୟମ୍ ହେଉଛି ଏକ ମନୁଷ୍ୟ ଦ୍ୱାରା ନିର୍ମିତ ରେଡିଓଆକ୍ଟିଭ୍ ଉପାଦାନ ଯାହା ଏକ ସମୟରେ ମାତ୍ର ଅଳ୍ପ ପରମାଣୁ ସୃଷ୍ଟି କରେ।',
    ),
    uses: LocalizedElementText(
      english: 'Scientific research only; no everyday uses.',
      hindi: 'केवल वैज्ञानिक अनुसंधान; कोई रोजमर्रा का उपयोग नहीं.',
      odia:
          'କେବଳ ବ Scientific ଜ୍ଞାନିକ ଅନୁସନ୍ଧାନ; କ every ଣସି ଦ day ନନ୍ଦିନ ବ୍ୟବହାର ନାହିଁ।',
    ),
    funFact: LocalizedElementText(
      english:
          'It is named after the Moscow region of Russia, home to the lab that helped make it.',
      hindi:
          'इसका नाम रूस के मॉस्को क्षेत्र के नाम पर रखा गया है, जहां उस प्रयोगशाला ने इसे बनाने में मदद की थी।',
      odia:
          'ଏହାକୁ Russia ଷର ମସ୍କୋ ଅଞ୍ଚଳ ନାମରେ ନାମିତ କରାଯାଇଛି, ଯେଉଁ ଲ୍ୟାବ ଏହାକୁ ତିଆରି କରିବାରେ ସାହାଯ୍ୟ କରିଛି।',
    ),
    discovery: LocalizedElementText(
      english: 'JINR Dubna & Livermore, 2003',
      hindi: 'जेआईएनआर डुबना और लिवरमोर, 2003',
      odia: 'JINR Dubna & Livermore, 2003',
    ),
  ),
  ElementData(
    atomicNumber: 116,
    symbol: 'Lv',
    name: 'Livermorium',
    nameOdia: 'ଲିଭରମୋରିୟମ୍',
    nameHindi: 'लिवरमोरियम',
    group: 16,
    period: 7,
    category: 'unknown',
    atomicMass: '[293]',
    state: 'Solid',
    shells: [2, 8, 18, 32, 32, 18, 6],
    valency: '2, 4',
    meltingPoint: null,
    boilingPoint: null,
    density: null,
    description: LocalizedElementText(
      english:
          'Livermorium is a man-made radioactive element that survives for a tiny fraction of a second.',
      hindi:
          'लिवरमोरियम एक मानव निर्मित रेडियोधर्मी तत्व है जो एक सेकंड के एक छोटे से अंश तक जीवित रहता है।',
      odia:
          'ଲିଭରମୋରିୟମ୍ ହେଉଛି ଏକ ମନୁଷ୍ୟ ଦ୍ୱାରା ନିର୍ମିତ ରେଡିଓଆକ୍ଟିଭ୍ ଉପାଦାନ ଯାହା ଏକ ସେକେଣ୍ଡର କ୍ଷୁଦ୍ର ଅଂଶ ପାଇଁ ବଞ୍ଚିଥାଏ।',
    ),
    uses: LocalizedElementText(
      english: 'Scientific research only; no everyday uses.',
      hindi: 'केवल वैज्ञानिक अनुसंधान; कोई रोजमर्रा का उपयोग नहीं.',
      odia:
          'କେବଳ ବ Scientific ଜ୍ଞାନିକ ଅନୁସନ୍ଧାନ; କ every ଣସି ଦ day ନନ୍ଦିନ ବ୍ୟବହାର ନାହିଁ।',
    ),
    funFact: LocalizedElementText(
      english:
          'It is named after the Livermore laboratory in the United States.',
      hindi:
          'इसका नाम संयुक्त राज्य अमेरिका में लिवरमोर प्रयोगशाला के नाम पर रखा गया है।',
      odia: 'ଯୁକ୍ତରାଷ୍ଟ୍ରର ଲିଭରମୋର ଲାବୋରେଟୋରୀ ନାମରେ ଏହାର ନାମକରଣ କରାଯାଇଛି।',
    ),
    discovery: LocalizedElementText(
      english: 'JINR Dubna & Livermore, 2000',
      hindi: 'जेआईएनआर डुबना और लिवरमोर, 2000',
      odia: 'JINR Dubna & Livermore, 2000',
    ),
  ),
  ElementData(
    atomicNumber: 117,
    symbol: 'Ts',
    name: 'Tennessine',
    nameOdia: 'ଟେନେସିନ୍',
    nameHindi: 'टेनेसीन',
    group: 17,
    period: 7,
    category: 'unknown',
    atomicMass: '[294]',
    state: 'Solid',
    shells: [2, 8, 18, 32, 32, 18, 7],
    valency: '1',
    meltingPoint: null,
    boilingPoint: null,
    density: null,
    description: LocalizedElementText(
      english:
          'Tennessine is one of the newest man-made radioactive elements ever created.',
      hindi:
          'टेनेसीन अब तक बनाए गए सबसे नए मानव निर्मित रेडियोधर्मी तत्वों में से एक है।',
      odia:
          'ଟେନେସିନ୍ ହେଉଛି ସୃଷ୍ଟି ହୋଇଥିବା ନୂତନ ମାନବ-ନିର୍ମିତ ରେଡିଓଆକ୍ଟିଭ୍ ଉପାଦାନ ମଧ୍ୟରୁ ଗୋଟିଏ।',
    ),
    uses: LocalizedElementText(
      english: 'Scientific research only; no everyday uses.',
      hindi: 'केवल वैज्ञानिक अनुसंधान; कोई रोजमर्रा का उपयोग नहीं.',
      odia:
          'କେବଳ ବ Scientific ଜ୍ଞାନିକ ଅନୁସନ୍ଧାନ; କ every ଣସି ଦ day ନନ୍ଦିନ ବ୍ୟବହାର ନାହିଁ।',
    ),
    funFact: LocalizedElementText(
      english:
          'It is named after the U.S. state of Tennessee, which supplied material used to make it.',
      hindi:
          'इसका नाम अमेरिकी राज्य टेनेसी के नाम पर रखा गया है, जिसने इसे बनाने के लिए सामग्री की आपूर्ति की थी।',
      odia:
          'ଏହାକୁ ଆମେରିକାର ଟେନେସି ରାଜ୍ୟ ନାମରେ ନାମିତ କରାଯାଇଛି, ଯାହା ଏହାକୁ ତିଆରି କରିବା ପାଇଁ ବ୍ୟବହୃତ ସାମଗ୍ରୀ ଯୋଗାଉଥିଲା।',
    ),
    discovery: LocalizedElementText(
      english: 'JINR Dubna, Oak Ridge & Livermore, 2010',
      hindi: 'जेआईएनआर डुबना, ओक रिज और लिवरमोर, 2010',
      odia: 'JINR Dubna, Oak Ridge & Livermore, 2010',
    ),
  ),
  ElementData(
    atomicNumber: 118,
    symbol: 'Og',
    name: 'Oganesson',
    nameOdia: 'ଓଗାନେସନ୍',
    nameHindi: 'ओगेनेसन',
    group: 18,
    period: 7,
    category: 'unknown',
    atomicMass: '[294]',
    state: 'Solid',
    shells: [2, 8, 18, 32, 32, 18, 8],
    valency: '0',
    meltingPoint: null,
    boilingPoint: null,
    density: null,
    description: LocalizedElementText(
      english:
          'Oganesson is the heaviest element ever made and sits at the very end of the periodic table.',
      hindi:
          'ओगेनसन अब तक का सबसे भारी तत्व है और आवर्त सारणी के बिल्कुल अंत में बैठता है।',
      odia:
          'ଓଗାନେସନ ହେଉଛି ସବୁଠାରୁ ଭାରୀ ଉପାଦାନ ଯାହା ପର୍ଯ୍ୟାୟ ଟେବୁଲର ଶେଷରେ ବସିଥାଏ।',
    ),
    uses: LocalizedElementText(
      english: 'Scientific research only; no everyday uses.',
      hindi: 'केवल वैज्ञानिक अनुसंधान; कोई रोजमर्रा का उपयोग नहीं.',
      odia:
          'କେବଳ ବ Scientific ଜ୍ଞାନିକ ଅନୁସନ୍ଧାନ; କ every ଣସି ଦ day ନନ୍ଦିନ ବ୍ୟବହାର ନାହିଁ।',
    ),
    funFact: LocalizedElementText(
      english:
          'It is the heaviest known element, and one of the very few named after a scientist still living at the time.',
      hindi:
          'यह सबसे भारी ज्ञात तत्व है, और उस समय जीवित किसी वैज्ञानिक के नाम पर रखे गए बहुत कम तत्वों में से एक है।',
      odia:
          'ଏହା ସବୁଠାରୁ ଭାରୀ ଜଣାଶୁଣା ଉପାଦାନ, ଏବଂ ସେହି ସମୟରେ ବଞ୍ଚିଥିବା ବ scientist ଜ୍ଞାନିକଙ୍କ ନାମରେ ନାମିତ ଖୁବ୍ କମ୍ ମଧ୍ୟରୁ ଗୋଟିଏ।',
    ),
    discovery: LocalizedElementText(
      english: 'JINR Dubna & Livermore, 2006',
      hindi: 'जेआईएनआर डुबना और लिवरमोर, 2006',
      odia: 'JINR Dubna & Livermore, 2006',
    ),
  ),
];
