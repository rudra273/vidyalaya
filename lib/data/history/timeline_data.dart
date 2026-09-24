class HistoricalEvent {
  final String year;
  final String title;
  final String titleOdia;
  final String titleHindi;
  final String description;
  final String descriptionOdia;
  final String descriptionHindi;
  final String era;

  /// Geographic scope of the event. One of:
  /// - [kRegionWorld] for world history,
  /// - [kRegionIndia] for pan-India events,
  /// - an Indian state name (e.g. `'Odisha'`, see [indianStates]) for
  ///   state-level events.
  final String region;

  const HistoricalEvent({
    required this.year,
    required this.title,
    required this.titleOdia,
    required this.titleHindi,
    required this.description,
    required this.descriptionOdia,
    required this.descriptionHindi,
    required this.era,
    required this.region,
  });
}

/// Region scope sentinels used by [HistoricalEvent.region].
const String kRegionWorld = 'World';
const String kRegionIndia = 'India';

/// The 28 Indian states (excluding union territories), alphabetical, used to
/// populate the state-picker in the timeline filter. Odisha is the default
/// state for this app's primary audience.
const List<String> indianStates = [
  'Andhra Pradesh',
  'Arunachal Pradesh',
  'Assam',
  'Bihar',
  'Chhattisgarh',
  'Goa',
  'Gujarat',
  'Haryana',
  'Himachal Pradesh',
  'Jharkhand',
  'Karnataka',
  'Kerala',
  'Madhya Pradesh',
  'Maharashtra',
  'Manipur',
  'Meghalaya',
  'Mizoram',
  'Nagaland',
  'Odisha',
  'Punjab',
  'Rajasthan',
  'Sikkim',
  'Tamil Nadu',
  'Telangana',
  'Tripura',
  'Uttar Pradesh',
  'Uttarakhand',
  'West Bengal',
];

const List<HistoricalEvent> timelineEvents = [
  // Ancient India
  HistoricalEvent(
    year: '2500 BCE',
    title: 'Indus Valley Civilization',
    titleOdia: 'ସିନ୍ଧୁ ଉପତ୍ୟକା ସଭ୍ୟତା',
    titleHindi: 'सिंधु घाटी सभ्यता',
    description:
        'Flourishing of one of the world\'s oldest urban civilizations in the northwestern regions of South Asia.',
    descriptionOdia:
        'ଦକ୍ଷିଣ ଏସିଆର ଉତ୍ତର-ପଶ୍ଚିମ ଅଞ୍ଚଳରେ ବିଶ୍ୱର ଅନ୍ୟତମ ପ୍ରାଚୀନ ସହରାଞ୍ଚଳ ସଭ୍ୟତାର ବିକାଶ।',
    descriptionHindi:
        'दक्षिण एशिया के उत्तर-पश्चिमी क्षेत्रों में विश्व की सबसे प्राचीन नगरीय सभ्यताओं में से एक का विकास।',
    era: 'Ancient',
    region: kRegionIndia,
  ),
  HistoricalEvent(
    year: '1500 BCE',
    title: 'Vedic Period Begins',
    titleOdia: 'ବୈଦିକ ଯୁଗର ଆରମ୍ଭ',
    titleHindi: 'वैदिक काल का आरंभ',
    description:
        'Composition of the Vedas and the beginning of the Vedic culture in the Indian subcontinent.',
    descriptionOdia: 'ବେଦର ରଚନା ଏବଂ ଭାରତୀୟ ଉପମହାଦେଶରେ ବୈଦିକ ସଂସ୍କୃତିର ଆରମ୍ଭ।',
    descriptionHindi:
        'वेदों की रचना और भारतीय उपमहाद्वीप में वैदिक संस्कृति का आरंभ।',
    era: 'Ancient',
    region: kRegionIndia,
  ),
  HistoricalEvent(
    year: '563 BCE',
    title: 'Birth of Gautama Buddha',
    titleOdia: 'ଗୌତମ ବୁଦ୍ଧଙ୍କ ଜନ୍ମ',
    titleHindi: 'गौतम बुद्ध का जन्म',
    description:
        'Siddhartha Gautama, the founder of Buddhism, was born in Lumbini.',
    descriptionOdia:
        'ବୌଦ୍ଧ ଧର୍ମର ପ୍ରତିଷ୍ଠାତା ସିଦ୍ଧାର୍ଥ ଗୌତମଙ୍କର ଲୁମ୍ବିନୀଠାରେ ଜନ୍ମ।',
    descriptionHindi:
        'बौद्ध धर्म के संस्थापक सिद्धार्थ गौतम का जन्म लुंबिनी में हुआ।',
    era: 'Ancient',
    region: kRegionIndia,
  ),
  HistoricalEvent(
    year: '322 BCE',
    title: 'Maurya Empire Established',
    titleOdia: 'ମୌର୍ଯ୍ୟ ସାମ୍ରାଜ୍ୟ ପ୍ରତିଷ୍ଠା',
    titleHindi: 'मौर्य साम्राज्य की स्थापना',
    description:
        'Chandragupta Maurya founds the Maurya Empire, the first pan-Indian empire.',
    descriptionOdia:
        'ଚନ୍ଦ୍ରଗୁପ୍ତ ମୌର୍ଯ୍ୟଙ୍କ ଦ୍ୱାରା ପ୍ରଥମ ସର୍ବଭାରତୀୟ ସାମ୍ରାଜ୍ୟ - ମୌର୍ଯ୍ୟ ସାମ୍ରାଜ୍ୟ ପ୍ରତିଷ୍ଠା।',
    descriptionHindi:
        'चंद्रगुप्त मौर्य ने प्रथम अखिल भारतीय साम्राज्य - मौर्य साम्राज्य की स्थापना की।',
    era: 'Ancient',
    region: kRegionIndia,
  ),
  HistoricalEvent(
    year: '261 BCE',
    title: 'Kalinga War',
    titleOdia: 'କଳିଙ୍ଗ ଯୁଦ୍ଧ',
    titleHindi: 'कलिंग युद्ध',
    description:
        'Emperor Ashoka invades Kalinga. The massive bloodshed prompts him to embrace Buddhism and non-violence.',
    descriptionOdia:
        'ସମ୍ରାଟ ଅଶୋକ କଳିଙ୍ଗ ଆକ୍ରମଣ କରନ୍ତି। ବ୍ୟାପକ ରକ୍ତପାତ ତାଙ୍କୁ ବୌଦ୍ଧ ଧର୍ମ ଏବଂ ଅହିଂସା ଗ୍ରହଣ କରିବାକୁ ପ୍ରେରିତ କରିଥିଲା।',
    descriptionHindi:
        'सम्राट अशोक ने कलिंग पर आक्रमण किया। भारी रक्तपात ने उन्हें बौद्ध धर्म और अहिंसा अपनाने के लिए प्रेरित किया।',
    era: 'Ancient',
    region: 'Odisha',
  ),
  HistoricalEvent(
    year: '320 CE',
    title: 'Gupta Empire Established',
    titleOdia: 'ଗୁପ୍ତ ସାମ୍ରାଜ୍ୟ ପ୍ରତିଷ୍ଠା',
    titleHindi: 'गुप्त साम्राज्य की स्थापना',
    description:
        'Chandragupta I establishes the Gupta Empire, marking the Golden Age of India.',
    descriptionOdia:
        'ପ୍ରଥମ ଚନ୍ଦ୍ରଗୁପ୍ତଙ୍କ ଦ୍ୱାରା ଗୁପ୍ତ ସାମ୍ରାଜ୍ୟ ପ୍ରତିଷ୍ଠା, ଯାହା ଭାରତର ସୁବର୍ଣ୍ଣ ଯୁଗ ଭାବରେ ପରିଚିତ।',
    descriptionHindi:
        'चंद्रगुप्त प्रथम ने गुप्त साम्राज्य की स्थापना की, जिसे भारत का स्वर्ण युग कहा जाता है।',
    era: 'Ancient',
    region: kRegionIndia,
  ),

  // Medieval India
  HistoricalEvent(
    year: '1192 CE',
    title: 'Second Battle of Tarain',
    titleOdia: 'ତରାଇନର ଦ୍ୱିତୀୟ ଯୁଦ୍ଧ',
    titleHindi: 'तराइन का द्वितीय युद्ध',
    description:
        'Muhammad Ghori defeats Prithviraj Chauhan, paving the way for Islamic rule in India.',
    descriptionOdia:
        'ପୃଥ୍ୱୀରାଜ ଚୌହାନଙ୍କୁ ମହମ୍ମଦ ଘୋରୀ ପରାସ୍ତ କଲେ, ଯାହା ଭାରତରେ ଇସଲାମିକ୍ ଶାସନ ପାଇଁ ପଥ ପରିଷ୍କାର କଲା।',
    descriptionHindi:
        'मुहम्मद ग़ोरी ने पृथ्वीराज चौहान को पराजित किया, जिसने भारत में इस्लामी शासन का मार्ग प्रशस्त किया।',
    era: 'Medieval',
    region: kRegionIndia,
  ),
  HistoricalEvent(
    year: '1435 CE',
    title: 'Gajapati Empire Founded',
    titleOdia: 'ଗଜପତି ସାମ୍ରାଜ୍ୟ ପ୍ରତିଷ୍ଠା',
    titleHindi: 'गजपति साम्राज्य की स्थापना',
    description:
        'Kapilendra Deva establishes the powerful Gajapati dynasty in Odisha.',
    descriptionOdia:
        'କପିଳେନ୍ଦ୍ର ଦେବଙ୍କ ଦ୍ୱାରା ଓଡ଼ିଶାରେ ଶକ୍ତିଶାଳୀ ଗଜପତି ରାଜବଂଶ ପ୍ରତିଷ୍ଠା।',
    descriptionHindi:
        'कपिलेन्द्र देव ने ओडिशा में शक्तिशाली गजपति राजवंश की स्थापना की।',
    era: 'Medieval',
    region: 'Odisha',
  ),
  HistoricalEvent(
    year: '1526 CE',
    title: 'First Battle of Panipat',
    titleOdia: 'ପାନିପଥର ପ୍ରଥମ ଯୁଦ୍ଧ',
    titleHindi: 'पानीपत का प्रथम युद्ध',
    description:
        'Babur defeats Ibrahim Lodi, marking the beginning of the Mughal Empire in India.',
    descriptionOdia:
        'ବାବର ଇବ୍ରାହିମ ଲୋଦୀଙ୍କୁ ପରାସ୍ତ କଲେ, ଯାହା ଭାରତରେ ମୋଗଲ ସାମ୍ରାଜ୍ୟର ଆରମ୍ଭ ଥିଲା।',
    descriptionHindi:
        'बाबर ने इब्राहिम लोदी को पराजित किया, जिससे भारत में मुगल साम्राज्य का आरंभ हुआ।',
    era: 'Medieval',
    region: kRegionIndia,
  ),
  HistoricalEvent(
    year: '1568 CE',
    title: 'Fall of Independent Odisha',
    titleOdia: 'ସ୍ୱାଧୀନ ଓଡ଼ିଶାର ପତନ',
    titleHindi: 'स्वतंत्र ओडिशा का पतन',
    description:
        'Mukunda Deva is defeated, and Odisha loses its independence to the Bengal Sultanate.',
    descriptionOdia:
        'ମୁକୁନ୍ଦ ଦେବଙ୍କ ପରାଜୟ, ଏବଂ ବଙ୍ଗଳା ସୁଲତାନଙ୍କ ଦ୍ୱାରା ଓଡ଼ିଶାର ସ୍ୱାଧୀନତା ଲୋପ।',
    descriptionHindi:
        'मुकुंद देव की पराजय हुई और ओडिशा ने बंगाल सल्तनत के हाथों अपनी स्वतंत्रता खो दी।',
    era: 'Medieval',
    region: 'Odisha',
  ),

  // Modern India
  HistoricalEvent(
    year: '1757 CE',
    title: 'Battle of Plassey',
    titleOdia: 'ପଲାସୀ ଯୁଦ୍ଧ',
    titleHindi: 'प्लासी का युद्ध',
    description:
        'British East India Company defeats the Nawab of Bengal, establishing British political power in India.',
    descriptionOdia:
        'ବ୍ରିଟିଶ୍ ଇଷ୍ଟ୍ ଇଣ୍ଡିଆ କମ୍ପାନୀ ବଙ୍ଗଳାର ନବାବଙ୍କୁ ପରାସ୍ତ କରି ଭାରତରେ ରାଜନୈତିକ କ୍ଷମତା ସ୍ଥାପନ କଲା।',
    descriptionHindi:
        'ब्रिटिश ईस्ट इंडिया कंपनी ने बंगाल के नवाब को पराजित कर भारत में अपनी राजनीतिक शक्ति स्थापित की।',
    era: 'Modern',
    region: kRegionIndia,
  ),
  HistoricalEvent(
    year: '1803 CE',
    title: 'British Occupation of Odisha',
    titleOdia: 'ଓଡ଼ିଶାରେ ବ୍ରିଟିଶ୍ ଅଧିକାର',
    titleHindi: 'ओडिशा पर ब्रिटिश अधिकार',
    description:
        'The British East India Company captures Odisha from the Marathas.',
    descriptionOdia:
        'ବ୍ରିଟିଶ୍ ଇଷ୍ଟ୍ ଇଣ୍ଡିଆ କମ୍ପାନୀ ମରାଠାମାନଙ୍କ ଠାରୁ ଓଡ଼ିଶା ଦଖଲ କଲା।',
    descriptionHindi:
        'ब्रिटिश ईस्ट इंडिया कंपनी ने मराठों से ओडिशा पर अधिकार कर लिया।',
    era: 'Modern',
    region: 'Odisha',
  ),
  HistoricalEvent(
    year: '1817 CE',
    title: 'Paika Rebellion',
    titleOdia: 'ପାଇକ ବିଦ୍ରୋହ',
    titleHindi: 'पाइका विद्रोह',
    description:
        'An armed rebellion against the British East India Company\'s rule in Odisha, led by Bakshi Jagabandhu.',
    descriptionOdia:
        'ବକ୍ସି ଜଗବନ୍ଧୁଙ୍କ ନେତୃତ୍ୱରେ ଓଡ଼ିଶାରେ ବ୍ରିଟିଶ୍ ଇଷ୍ଟ୍ ଇଣ୍ଡିଆ କମ୍ପାନୀ ବିରୋଧରେ ଏକ ସଶସ୍ତ୍ର ବିଦ୍ରୋହ।',
    descriptionHindi:
        'बख्शी जगबंधु के नेतृत्व में ओडिशा में ब्रिटिश ईस्ट इंडिया कंपनी के शासन के विरुद्ध एक सशस्त्र विद्रोह।',
    era: 'Modern',
    region: 'Odisha',
  ),
  HistoricalEvent(
    year: '1857 CE',
    title: 'Rebellion of 1857',
    titleOdia: '୧୮୫୭ର ସିପାହୀ ବିଦ୍ରୋହ',
    titleHindi: '1857 का विद्रोह',
    description:
        'The first major widespread uprising against the British East India Company (First War of Independence).',
    descriptionOdia:
        'ବ୍ରିଟିଶ୍ ଇଷ୍ଟ୍ ଇଣ୍ଡିଆ କମ୍ପାନୀ ବିରୋଧରେ ପ୍ରଥମ ବ୍ୟାପକ ବିଦ୍ରୋହ (ପ୍ରଥମ ସ୍ୱାଧୀନତା ସଂଗ୍ରାମ)।',
    descriptionHindi:
        'ब्रिटिश ईस्ट इंडिया कंपनी के विरुद्ध पहला बड़ा व्यापक विद्रोह (प्रथम स्वतंत्रता संग्राम)।',
    era: 'Modern',
    region: kRegionIndia,
  ),
  HistoricalEvent(
    year: '1885 CE',
    title: 'Formation of Indian National Congress',
    titleOdia: 'ଭାରତୀୟ ଜାତୀୟ କଂଗ୍ରେସ ପ୍ରତିଷ୍ଠା',
    titleHindi: 'भारतीय राष्ट्रीय कांग्रेस की स्थापना',
    description:
        'The INC is founded, which later becomes the principal leader of the Indian independence movement.',
    descriptionOdia:
        'ଭାରତୀୟ ଜାତୀୟ କଂଗ୍ରେସର ପ୍ରତିଷ୍ଠା, ଯାହା ପରବର୍ତ୍ତୀ ସମୟରେ ଭାରତୀୟ ସ୍ୱାଧୀନତା ଆନ୍ଦୋଳନର ମୁଖ୍ୟ ନେତା ପାଲଟିଥିଲା।',
    descriptionHindi:
        'भारतीय राष्ट्रीय कांग्रेस की स्थापना, जो बाद में भारतीय स्वतंत्रता आंदोलन की प्रमुख नेता बनी।',
    era: 'Modern',
    region: kRegionIndia,
  ),
  HistoricalEvent(
    year: '1936 CE',
    title: 'Formation of Separate Odisha Province',
    titleOdia: 'ସ୍ୱତନ୍ତ୍ର ଓଡ଼ିଶା ପ୍ରଦେଶ ଗଠନ',
    titleHindi: 'पृथक ओडिशा प्रांत का गठन',
    description:
        'On April 1, Odisha becomes a separate province on linguistic grounds (celebrated as Utkala Dibasa).',
    descriptionOdia:
        'ଏପ୍ରିଲ୍ ୧ ତାରିଖରେ ଭାଷା ଭିତ୍ତିରେ ଓଡ଼ିଶା ଏକ ସ୍ୱତନ୍ତ୍ର ପ୍ରଦେଶ ଭାବରେ ଗଠିତ ହେଲା (ଉତ୍କଳ ଦିବସ)।',
    descriptionHindi:
        '1 अप्रैल को भाषा के आधार पर ओडिशा एक पृथक प्रांत बना (उत्कल दिवस के रूप में मनाया जाता है)।',
    era: 'Modern',
    region: 'Odisha',
  ),
  HistoricalEvent(
    year: '1942 CE',
    title: 'Quit India Movement',
    titleOdia: 'ଭାରତ ଛାଡ଼ ଆନ୍ଦୋଳନ',
    titleHindi: 'भारत छोड़ो आंदोलन',
    description:
        'Mahatma Gandhi launches the Quit India Movement, demanding an end to British rule.',
    descriptionOdia:
        'ବ୍ରିଟିଶ୍ ଶାସନର ଅନ୍ତ ଦାବି କରି ମହାତ୍ମା ଗାନ୍ଧୀଙ୍କ ଦ୍ୱାରା ଭାରତ ଛାଡ଼ ଆନ୍ଦୋଳନ ଆରମ୍ଭ।',
    descriptionHindi:
        'ब्रिटिश शासन की समाप्ति की मांग करते हुए महात्मा गांधी ने भारत छोड़ो आंदोलन आरंभ किया।',
    era: 'Modern',
    region: kRegionIndia,
  ),
  HistoricalEvent(
    year: '1947 CE',
    title: 'Indian Independence',
    titleOdia: 'ଭାରତର ସ୍ୱାଧୀନତା',
    titleHindi: 'भारत की स्वतंत्रता',
    description:
        'India gains independence from British rule on August 15, leading to the partition of the subcontinent.',
    descriptionOdia: 'ଅଗଷ୍ଟ ୧୫ରେ ଭାରତ ବ୍ରିଟିଶ୍ ଶାସନରୁ ସ୍ୱାଧୀନତା ଲାଭ କଲା।',
    descriptionHindi:
        '15 अगस्त को भारत ने ब्रिटिश शासन से स्वतंत्रता प्राप्त की, जिसके साथ उपमहाद्वीप का विभाजन हुआ।',
    era: 'Modern',
    region: kRegionIndia,
  ),

  // ─── World History ──────────────────────────────────────────────────────
  HistoricalEvent(
    year: 'c. 3100 BCE',
    title: 'Unification of Ancient Egypt',
    titleOdia: 'ପ୍ରାଚୀନ ମିଶରର ଏକୀକରଣ',
    titleHindi: 'प्राचीन मिस्र का एकीकरण',
    description:
        'Upper and Lower Egypt are united under one ruler, beginning the era of the Egyptian dynasties.',
    descriptionOdia:
        'ଉପର ଓ ତଳ ମିଶର ଜଣେ ଶାସକଙ୍କ ଅଧୀନରେ ଏକତ୍ରିତ ହୋଇ ମିଶରୀୟ ରାଜବଂଶମାନଙ୍କ ଯୁଗ ଆରମ୍ଭ ହୁଏ।',
    descriptionHindi:
        'ऊपरी और निचला मिस्र एक शासक के अधीन एकीकृत हुए, जिससे मिस्री राजवंशों का युग आरंभ हुआ।',
    era: 'Ancient',
    region: kRegionWorld,
  ),
  HistoricalEvent(
    year: 'c. 1750 BCE',
    title: 'Code of Hammurabi',
    titleOdia: 'ହାମ୍ମୁରାବିଙ୍କ ଆଇନ ସଂହିତା',
    titleHindi: 'हम्मुराबी की विधि संहिता',
    description:
        'Babylonian king Hammurabi issues one of the earliest surviving written law codes.',
    descriptionOdia:
        'ବାବିଲୋନର ରାଜା ହାମ୍ମୁରାବି ପ୍ରାଚୀନତମ ସଂରକ୍ଷିତ ଲିଖିତ ଆଇନ ସଂହିତାମାନଙ୍କ ମଧ୍ୟରୁ ଗୋଟିଏ ଜାରି କରନ୍ତି।',
    descriptionHindi:
        'बेबीलोन के राजा हम्मुराबी ने सबसे प्राचीन सुरक्षित लिखित विधि संहिताओं में से एक जारी की।',
    era: 'Ancient',
    region: kRegionWorld,
  ),
  HistoricalEvent(
    year: '551 BCE',
    title: 'Birth of Confucius',
    titleOdia: 'କନଫ୍ୟୁସିୟସଙ୍କ ଜନ୍ମ',
    titleHindi: 'कन्फ्यूशियस का जन्म',
    description:
        'The Chinese teacher and philosopher Confucius is born; his ideas profoundly influence East Asian societies.',
    descriptionOdia:
        'ଚୀନର ଶିକ୍ଷକ ଓ ଦାର୍ଶନିକ କନଫ୍ୟୁସିୟସଙ୍କ ଜନ୍ମ ହୁଏ; ତାଙ୍କ ଚିନ୍ତାଧାରା ପୂର୍ବ ଏସିଆର ସମାଜକୁ ଗଭୀର ଭାବରେ ପ୍ରଭାବିତ କରେ।',
    descriptionHindi:
        'चीनी शिक्षक और दार्शनिक कन्फ्यूशियस का जन्म हुआ; उनके विचारों ने पूर्वी एशियाई समाजों को गहराई से प्रभावित किया।',
    era: 'Ancient',
    region: kRegionWorld,
  ),
  HistoricalEvent(
    year: '509 BCE',
    title: 'Roman Republic Established',
    titleOdia: 'ରୋମାନ୍ ଗଣରାଜ୍ୟ ପ୍ରତିଷ୍ଠା',
    titleHindi: 'रोमन गणराज्य की स्थापना',
    description:
        'Romans overthrow their monarchy and establish a republic that shapes later ideas of government and law.',
    descriptionOdia:
        'ରୋମାନମାନେ ରାଜତନ୍ତ୍ରକୁ ହଟାଇ ଏକ ଗଣରାଜ୍ୟ ପ୍ରତିଷ୍ଠା କରନ୍ତି, ଯାହା ପରବର୍ତ୍ତୀ ଶାସନ ଓ ଆଇନ ଚିନ୍ତାଧାରାକୁ ପ୍ରଭାବିତ କରେ।',
    descriptionHindi:
        'रोमनों ने राजतंत्र हटाकर एक गणराज्य स्थापित किया, जिसने शासन और कानून की बाद की धारणाओं को प्रभावित किया।',
    era: 'Ancient',
    region: kRegionWorld,
  ),
  HistoricalEvent(
    year: '776 BCE',
    title: 'First Ancient Olympic Games',
    titleOdia: 'ପ୍ରଥମ ପ୍ରାଚୀନ ଅଲିମ୍ପିକ୍ କ୍ରୀଡ଼ା',
    titleHindi: 'प्रथम प्राचीन ओलंपिक खेल',
    description:
        'The first recorded Olympic Games are held at Olympia in ancient Greece.',
    descriptionOdia:
        'ପ୍ରାଚୀନ ଗ୍ରୀସର ଅଲିମ୍ପିଆଠାରେ ପ୍ରଥମ ଲିପିବଦ୍ଧ ଅଲିମ୍ପିକ୍ କ୍ରୀଡ଼ା ଅନୁଷ୍ଠିତ ହୁଏ।',
    descriptionHindi:
        'प्राचीन ग्रीस के ओलंपिया में पहले लिखित ओलंपिक खेलों का आयोजन हुआ।',
    era: 'Ancient',
    region: kRegionWorld,
  ),
  HistoricalEvent(
    year: '27 BCE',
    title: 'Beginning of the Roman Empire',
    titleOdia: 'ରୋମାନ୍ ସାମ୍ରାଜ୍ୟର ଆରମ୍ଭ',
    titleHindi: 'रोमन साम्राज्य का आरंभ',
    description:
        'Octavian becomes Augustus, marking the beginning of the Roman Empire.',
    descriptionOdia:
        'ଅକ୍ଟାଭିଆନ୍ ଅଗଷ୍ଟସ ହୁଅନ୍ତି, ଯାହା ରୋମାନ୍ ସାମ୍ରାଜ୍ୟର ଆରମ୍ଭକୁ ସୂଚିତ କରେ।',
    descriptionHindi:
        'ऑक्टेवियन ऑगस्टस बने, जिससे रोमन साम्राज्य का आरंभ माना जाता है।',
    era: 'Ancient',
    region: kRegionWorld,
  ),
  HistoricalEvent(
    year: '622 CE',
    title: 'Hijra to Medina',
    titleOdia: 'ମଦିନାକୁ ହିଜରତ',
    titleHindi: 'मदीना की हिजरत',
    description:
        'Prophet Muhammad migrates from Mecca to Medina; this event begins the Islamic calendar.',
    descriptionOdia:
        'ପୟଗମ୍ବର ମହମ୍ମଦ ମକ୍କାରୁ ମଦିନାକୁ ଯାତ୍ରା କରନ୍ତି; ଏହି ଘଟଣାରୁ ଇସଲାମୀ ପଞ୍ଜିକାର ଆରମ୍ଭ ହୁଏ।',
    descriptionHindi:
        'पैगंबर मुहम्मद मक्का से मदीना गए; इस घटना से इस्लामी कैलेंडर का आरंभ होता है।',
    era: 'Medieval',
    region: kRegionWorld,
  ),
  HistoricalEvent(
    year: '800 CE',
    title: 'Charlemagne Crowned Emperor',
    titleOdia: 'ଚାର୍ଲେମେନ୍ ସମ୍ରାଟ ଭାବେ ଅଭିଷିକ୍ତ',
    titleHindi: 'शारलेमेन का सम्राट के रूप में राज्याभिषेक',
    description:
        'Charlemagne is crowned emperor in Rome, strengthening a large western European empire.',
    descriptionOdia:
        'ଚାର୍ଲେମେନ୍ ରୋମରେ ସମ୍ରାଟ ଭାବେ ଅଭିଷିକ୍ତ ହୋଇ ପଶ୍ଚିମ ୟୁରୋପର ଏକ ବିଶାଳ ସାମ୍ରାଜ୍ୟକୁ ସୁଦୃଢ଼ କରନ୍ତି।',
    descriptionHindi:
        'शारलेमेन का रोम में सम्राट के रूप में राज्याभिषेक हुआ, जिससे पश्चिमी यूरोप का एक विशाल साम्राज्य मजबूत हुआ।',
    era: 'Medieval',
    region: kRegionWorld,
  ),
  HistoricalEvent(
    year: '1066 CE',
    title: 'Norman Conquest of England',
    titleOdia: 'ଇଂଲଣ୍ଡର ନର୍ମାନ୍ ବିଜୟ',
    titleHindi: 'इंग्लैंड पर नॉर्मन विजय',
    description:
        'William of Normandy defeats King Harold at the Battle of Hastings and becomes king of England.',
    descriptionOdia:
        'ହେଷ୍ଟିଙ୍ଗସ୍ ଯୁଦ୍ଧରେ ନର୍ମାଣ୍ଡିର ଉଇଲିୟମ୍ ରାଜା ହାରୋଲ୍ଡଙ୍କୁ ପରାସ୍ତ କରି ଇଂଲଣ୍ଡର ରାଜା ହୁଅନ୍ତି।',
    descriptionHindi:
        'हेस्टिंग्स के युद्ध में नॉर्मंडी के विलियम ने राजा हेरोल्ड को हराकर इंग्लैंड के राजा बने।',
    era: 'Medieval',
    region: kRegionWorld,
  ),
  HistoricalEvent(
    year: '1206 CE',
    title: 'Mongol Empire Founded',
    titleOdia: 'ମଙ୍ଗୋଲ ସାମ୍ରାଜ୍ୟ ପ୍ରତିଷ୍ଠା',
    titleHindi: 'मंगोल साम्राज्य की स्थापना',
    description:
        'Genghis Khan unites Mongol tribes and founds an empire that becomes the largest contiguous land empire in history.',
    descriptionOdia:
        'ଚେଙ୍ଗିସ୍ ଖାନ୍ ମଙ୍ଗୋଲ ଜନଜାତିମାନଙ୍କୁ ଏକତ୍ରିତ କରି ଇତିହାସର ସବୁଠାରୁ ବଡ଼ ସଂଲଗ୍ନ ଭୂ-ସାମ୍ରାଜ୍ୟ ପାଲଟିଥିବା ଏକ ସାମ୍ରାଜ୍ୟ ପ୍ରତିଷ୍ଠା କରନ୍ତି।',
    descriptionHindi:
        'चंगेज़ ख़ान ने मंगोल कबीलों को एकजुट कर एक ऐसे साम्राज्य की स्थापना की जो इतिहास का सबसे बड़ा सटा हुआ भू-साम्राज्य बना।',
    era: 'Medieval',
    region: kRegionWorld,
  ),
  HistoricalEvent(
    year: '1215 CE',
    title: 'Magna Carta Sealed',
    titleOdia: 'ମାଗ୍ନା କାର୍ଟାରେ ମୋହର',
    titleHindi: 'मैग्ना कार्टा पर मुहर',
    description:
        'King John of England seals the Magna Carta, an important step in limiting royal power under law.',
    descriptionOdia:
        'ଇଂଲଣ୍ଡର ରାଜା ଜନ୍ ମାଗ୍ନା କାର୍ଟାରେ ମୋହର ଦିଅନ୍ତି; ଆଇନ ଅଧୀନରେ ରାଜକୀୟ କ୍ଷମତା ସୀମିତ କରିବାରେ ଏହା ଏକ ଗୁରୁତ୍ୱପୂର୍ଣ୍ଣ ପଦକ୍ଷେପ ଥିଲା।',
    descriptionHindi:
        'इंग्लैंड के राजा जॉन ने मैग्ना कार्टा पर मुहर लगाई; यह कानून के तहत राजकीय शक्ति सीमित करने की दिशा में महत्वपूर्ण कदम था।',
    era: 'Medieval',
    region: kRegionWorld,
  ),
  HistoricalEvent(
    year: '1453 CE',
    title: 'Fall of Constantinople',
    titleOdia: 'କନଷ୍ଟାଣ୍ଟିନୋପଲର ପତନ',
    titleHindi: 'कॉन्स्टेंटिनोपल का पतन',
    description:
        'The Ottoman Empire captures Constantinople, ending the Byzantine Empire.',
    descriptionOdia:
        'ଓଟୋମାନ୍ ସାମ୍ରାଜ୍ୟ କନଷ୍ଟାଣ୍ଟିନୋପଲ ଦଖଲ କରି ବାଇଜାଣ୍ଟାଇନ୍ ସାମ୍ରାଜ୍ୟର ଅନ୍ତ ଆଣେ।',
    descriptionHindi:
        'ओटोमन साम्राज्य ने कॉन्स्टेंटिनोपल पर अधिकार कर बीजान्टिन साम्राज्य का अंत किया।',
    era: 'Medieval',
    region: kRegionWorld,
  ),
  HistoricalEvent(
    year: '1492 CE',
    title: 'Columbus Reaches the Americas',
    titleOdia: 'କଲମ୍ବସ୍ ଆମେରିକାରେ ପହଞ୍ଚନ୍ତି',
    titleHindi: 'कोलंबस अमेरिका पहुँचे',
    description:
        'Christopher Columbus reaches the Caribbean, initiating sustained contact between Europe and the Americas.',
    descriptionOdia:
        'କ୍ରିଷ୍ଟୋଫର କଲମ୍ବସ୍ କାରିବିଆନରେ ପହଞ୍ଚନ୍ତି, ଯାହା ୟୁରୋପ ଓ ଆମେରିକା ମଧ୍ୟରେ ନିରନ୍ତର ସମ୍ପର୍କର ଆରମ୍ଭ କରେ।',
    descriptionHindi:
        'क्रिस्टोफर कोलंबस कैरिबियन पहुँचे, जिससे यूरोप और अमेरिका के बीच निरंतर संपर्क शुरू हुआ।',
    era: 'Modern',
    region: kRegionWorld,
  ),
  HistoricalEvent(
    year: '1517 CE',
    title: 'Protestant Reformation Begins',
    titleOdia: 'ପ୍ରୋଟେଷ୍ଟାଣ୍ଟ ସଂସ୍କାର ଆନ୍ଦୋଳନର ଆରମ୍ଭ',
    titleHindi: 'प्रोटेस्टेंट सुधार आंदोलन का आरंभ',
    description:
        'Martin Luther challenges practices of the Catholic Church, beginning the Protestant Reformation in Europe.',
    descriptionOdia:
        'ମାର୍ଟିନ୍ ଲୁଥର କାଥଲିକ୍ ଚର୍ଚ୍ଚର କିଛି ପ୍ରଥାକୁ ଚ୍ୟାଲେଞ୍ଜ କରି ୟୁରୋପରେ ପ୍ରୋଟେଷ୍ଟାଣ୍ଟ ସଂସ୍କାର ଆନ୍ଦୋଳନ ଆରମ୍ଭ କରନ୍ତି।',
    descriptionHindi:
        'मार्टिन लूथर ने कैथोलिक चर्च की कुछ प्रथाओं को चुनौती दी, जिससे यूरोप में प्रोटेस्टेंट सुधार आंदोलन शुरू हुआ।',
    era: 'Modern',
    region: kRegionWorld,
  ),
  HistoricalEvent(
    year: '1776 CE',
    title: 'American Declaration of Independence',
    titleOdia: 'ଆମେରିକୀୟ ସ୍ୱାଧୀନତା ଘୋଷଣା',
    titleHindi: 'अमेरिकी स्वतंत्रता की घोषणा',
    description:
        'The Thirteen Colonies declare independence from Britain, founding the United States of America.',
    descriptionOdia:
        'ତେରଟି ଉପନିବେଶ ବ୍ରିଟେନରୁ ସ୍ୱାଧୀନତା ଘୋଷଣା କରି ଯୁକ୍ତରାଷ୍ଟ୍ର ଆମେରିକାର ଭିତ୍ତି ସ୍ଥାପନ କରନ୍ତି।',
    descriptionHindi:
        'तेरह उपनिवेशों ने ब्रिटेन से स्वतंत्रता की घोषणा की, जिससे संयुक्त राज्य अमेरिका की नींव पड़ी।',
    era: 'Modern',
    region: kRegionWorld,
  ),
  HistoricalEvent(
    year: '1789 CE',
    title: 'French Revolution Begins',
    titleOdia: 'ଫରାସୀ ବିପ୍ଳବର ଆରମ୍ଭ',
    titleHindi: 'फ्रांसीसी क्रांति का आरंभ',
    description:
        'The storming of the Bastille marks the start of the French Revolution.',
    descriptionOdia: 'ବାଷ୍ଟିଲ୍ ଆକ୍ରମଣ ଫରାସୀ ବିପ୍ଳବର ଆରମ୍ଭ ସୂଚାଇଥାଏ।',
    descriptionHindi:
        'बास्तील पर हमला फ्रांसीसी क्रांति की शुरुआत का प्रतीक है।',
    era: 'Modern',
    region: kRegionWorld,
  ),
  HistoricalEvent(
    year: '1804 CE',
    title: 'Haitian Independence',
    titleOdia: 'ହାଇତିର ସ୍ୱାଧୀନତା',
    titleHindi: 'हैती की स्वतंत्रता',
    description:
        'Haiti gains independence from France after a successful revolution by formerly enslaved people.',
    descriptionOdia:
        'ପୂର୍ବତନ ଦାସମାନଙ୍କ ସଫଳ ବିପ୍ଳବ ପରେ ହାଇତି ଫ୍ରାନ୍ସରୁ ସ୍ୱାଧୀନତା ପାଏ।',
    descriptionHindi:
        'पूर्व दास बनाए गए लोगों की सफल क्रांति के बाद हैती ने फ्रांस से स्वतंत्रता प्राप्त की।',
    era: 'Modern',
    region: kRegionWorld,
  ),
  HistoricalEvent(
    year: '1868 CE',
    title: 'Meiji Restoration',
    titleOdia: 'ମେଜି ପୁନରୁତ୍ଥାନ',
    titleHindi: 'मेइजी पुनर्स्थापना',
    description:
        'Political power is restored to Japan\'s emperor, starting rapid modernization and industrialization.',
    descriptionOdia:
        'ଜାପାନର ସମ୍ରାଟଙ୍କ ହାତକୁ ରାଜନୈତିକ କ୍ଷମତା ଫେରେ; ଦ୍ରୁତ ଆଧୁନିକୀକରଣ ଓ ଶିଳ୍ପାୟନ ଆରମ୍ଭ ହୁଏ।',
    descriptionHindi:
        'जापान के सम्राट को राजनीतिक सत्ता वापस मिली, जिससे तीव्र आधुनिकीकरण और औद्योगीकरण आरंभ हुआ।',
    era: 'Modern',
    region: kRegionWorld,
  ),
  HistoricalEvent(
    year: '1914 CE',
    title: 'World War I Begins',
    titleOdia: 'ପ୍ରଥମ ବିଶ୍ୱଯୁଦ୍ଧର ଆରମ୍ଭ',
    titleHindi: 'प्रथम विश्व युद्ध का आरंभ',
    description:
        'A conflict beginning in Europe expands into a global war involving many countries and empires.',
    descriptionOdia:
        'ୟୁରୋପରେ ଆରମ୍ଭ ହୋଇଥିବା ସଂଘର୍ଷ ଅନେକ ଦେଶ ଓ ସାମ୍ରାଜ୍ୟକୁ ନେଇ ଏକ ବିଶ୍ୱଯୁଦ୍ଧରେ ପରିଣତ ହୁଏ।',
    descriptionHindi:
        'यूरोप में शुरू हुआ संघर्ष अनेक देशों और साम्राज्यों को शामिल करते हुए वैश्विक युद्ध बन गया।',
    era: 'Modern',
    region: kRegionWorld,
  ),
  HistoricalEvent(
    year: '1917 CE',
    title: 'Russian Revolution',
    titleOdia: 'ରୁଷ ବିପ୍ଳବ',
    titleHindi: 'रूसी क्रांति',
    description:
        'The Bolsheviks take power in Russia, leading to the creation of the Soviet Union.',
    descriptionOdia:
        'ବଲସେଭିକମାନେ ରୁଷିଆରେ କ୍ଷମତା ଗ୍ରହଣ କରନ୍ତି, ଯାହା ସୋଭିଏତ ସଂଘ ଗଠନର ପଥ ପ୍ରସ୍ତୁତ କରେ।',
    descriptionHindi:
        'बोल्शेविकों ने रूस में सत्ता संभाली, जिससे सोवियत संघ के गठन का मार्ग बना।',
    era: 'Modern',
    region: kRegionWorld,
  ),
  HistoricalEvent(
    year: '1929 CE',
    title: 'Great Depression Begins',
    titleOdia: 'ମହାମନ୍ଦାର ଆରମ୍ଭ',
    titleHindi: 'महामंदी का आरंभ',
    description:
        'A stock market crash in the United States helps trigger a severe worldwide economic depression.',
    descriptionOdia:
        'ଯୁକ୍ତରାଷ୍ଟ୍ରର ଶେୟାର ବଜାର ପତନ ବିଶ୍ୱବ୍ୟାପୀ ଗୁରୁତର ଆର୍ଥିକ ମନ୍ଦା ସୃଷ୍ଟିରେ ସହାୟକ ହୁଏ।',
    descriptionHindi:
        'संयुक्त राज्य अमेरिका में शेयर बाजार के पतन ने गंभीर वैश्विक आर्थिक मंदी को जन्म देने में भूमिका निभाई।',
    era: 'Modern',
    region: kRegionWorld,
  ),
  HistoricalEvent(
    year: '1939 CE',
    title: 'World War II Begins',
    titleOdia: 'ଦ୍ୱିତୀୟ ବିଶ୍ୱଯୁଦ୍ଧର ଆରମ୍ଭ',
    titleHindi: 'द्वितीय विश्व युद्ध का आरंभ',
    description:
        'Germany invades Poland, beginning World War II in Europe and a conflict that spreads across the globe.',
    descriptionOdia:
        'ଜର୍ମାନୀ ପୋଲାଣ୍ଡ ଉପରେ ଆକ୍ରମଣ କରେ; ଏଥିରୁ ୟୁରୋପରେ ଦ୍ୱିତୀୟ ବିଶ୍ୱଯୁଦ୍ଧ ଆରମ୍ଭ ହୋଇ ବିଶ୍ୱବ୍ୟାପୀ ସଂଘର୍ଷ ପ୍ରସାରିତ ହୁଏ।',
    descriptionHindi:
        'जर्मनी ने पोलैंड पर आक्रमण किया, जिससे यूरोप में द्वितीय विश्व युद्ध शुरू हुआ और संघर्ष विश्वभर में फैल गया।',
    era: 'Modern',
    region: kRegionWorld,
  ),
  HistoricalEvent(
    year: '1945 CE',
    title: 'End of World War II',
    titleOdia: 'ଦ୍ୱିତୀୟ ବିଶ୍ୱଯୁଦ୍ଧର ସମାପ୍ତି',
    titleHindi: 'द्वितीय विश्व युद्ध की समाप्ति',
    description: 'World War II ends, reshaping the global political order.',
    descriptionOdia:
        'ଦ୍ୱିତୀୟ ବିଶ୍ୱଯୁଦ୍ଧ ସମାପ୍ତ ହୁଏ, ବିଶ୍ୱ ରାଜନୈତିକ ବ୍ୟବସ୍ଥାକୁ ନୂତନ ରୂପ ଦିଏ।',
    descriptionHindi:
        'द्वितीय विश्व युद्ध समाप्त हुआ, जिसने वैश्विक राजनीतिक व्यवस्था को नया रूप दिया।',
    era: 'Modern',
    region: kRegionWorld,
  ),
  HistoricalEvent(
    year: '1945 CE',
    title: 'United Nations Founded',
    titleOdia: 'ଜାତିସଂଘ ପ୍ରତିଷ୍ଠା',
    titleHindi: 'संयुक्त राष्ट्र की स्थापना',
    description:
        'The United Nations is established to promote international peace, cooperation and human rights.',
    descriptionOdia:
        'ଆନ୍ତର୍ଜାତିକ ଶାନ୍ତି, ସହଯୋଗ ଓ ମାନବାଧିକାରକୁ ଆଗେଇ ନେବା ପାଇଁ ଜାତିସଂଘ ପ୍ରତିଷ୍ଠିତ ହୁଏ।',
    descriptionHindi:
        'अंतरराष्ट्रीय शांति, सहयोग और मानवाधिकारों को बढ़ावा देने के लिए संयुक्त राष्ट्र की स्थापना हुई।',
    era: 'Modern',
    region: kRegionWorld,
  ),
  HistoricalEvent(
    year: '1948 CE',
    title: 'Universal Declaration of Human Rights',
    titleOdia: 'ମାନବାଧିକାରର ସାର୍ବଜନୀନ ଘୋଷଣା',
    titleHindi: 'मानवाधिकारों की सार्वभौम घोषणा',
    description:
        'The United Nations adopts the Universal Declaration of Human Rights as a common standard for all people.',
    descriptionOdia:
        'ଜାତିସଂଘ ସମସ୍ତ ଲୋକଙ୍କ ପାଇଁ ଏକ ସାଧାରଣ ମାନଦଣ୍ଡ ଭାବେ ମାନବାଧିକାରର ସାର୍ବଜନୀନ ଘୋଷଣାକୁ ଗ୍ରହଣ କରେ।',
    descriptionHindi:
        'संयुक्त राष्ट्र ने सभी लोगों के लिए एक समान मानक के रूप में मानवाधिकारों की सार्वभौम घोषणा अपनाई।',
    era: 'Modern',
    region: kRegionWorld,
  ),
  HistoricalEvent(
    year: '1969 CE',
    title: 'First Moon Landing',
    titleOdia: 'ପ୍ରଥମ ଚନ୍ଦ୍ର ଅବତରଣ',
    titleHindi: 'चंद्रमा पर पहला मानव अवतरण',
    description:
        'Apollo 11 lands astronauts on the Moon, a landmark achievement in space exploration.',
    descriptionOdia:
        'ଆପୋଲୋ ୧୧ ମହାକାଶଚାରୀଙ୍କୁ ଚନ୍ଦ୍ରରେ ଅବତରଣ କରାଏ; ଏହା ମହାକାଶ ଅନୁସନ୍ଧାନର ଏକ ଐତିହାସିକ ସଫଳତା।',
    descriptionHindi:
        'अपोलो 11 ने अंतरिक्ष यात्रियों को चंद्रमा पर उतारा; यह अंतरिक्ष अन्वेषण की एक ऐतिहासिक उपलब्धि थी।',
    era: 'Modern',
    region: kRegionWorld,
  ),
  HistoricalEvent(
    year: '1989 CE',
    title: 'Fall of the Berlin Wall',
    titleOdia: 'ବର୍ଲିନ ପ୍ରାଚୀରର ପତନ',
    titleHindi: 'बर्लिन की दीवार का पतन',
    description:
        'The Berlin Wall opens, becoming a powerful symbol of the end of divisions in Cold War Europe.',
    descriptionOdia:
        'ବର୍ଲିନ ପ୍ରାଚୀର ଖୋଲାଯାଏ, ଯାହା ଶୀତଳ ଯୁଦ୍ଧକାଳୀନ ୟୁରୋପର ବିଭାଜନ ଶେଷ ହେବାର ଶକ୍ତିଶାଳୀ ପ୍ରତୀକ ପାଲଟେ।',
    descriptionHindi:
        'बर्लिन की दीवार खुली, जो शीत युद्धकालीन यूरोप के विभाजनों के अंत का शक्तिशाली प्रतीक बनी।',
    era: 'Modern',
    region: kRegionWorld,
  ),
  HistoricalEvent(
    year: '1994 CE',
    title: 'End of Apartheid in South Africa',
    titleOdia: 'ଦକ୍ଷିଣ ଆଫ୍ରିକାରେ ବର୍ଣ୍ଣବୈଷମ୍ୟର ଅନ୍ତ',
    titleHindi: 'दक्षिण अफ्रीका में रंगभेद का अंत',
    description:
        'South Africa holds its first democratic election open to all races, and Nelson Mandela becomes president.',
    descriptionOdia:
        'ଦକ୍ଷିଣ ଆଫ୍ରିକାରେ ସମସ୍ତ ଜାତି ପାଇଁ ଖୋଲା ପ୍ରଥମ ଗଣତାନ୍ତ୍ରିକ ନିର୍ବାଚନ ହୁଏ ଏବଂ ନେଲସନ ମଣ୍ଡେଲା ରାଷ୍ଟ୍ରପତି ହୁଅନ୍ତି।',
    descriptionHindi:
        'दक्षिण अफ्रीका में सभी नस्लों के लिए खुला पहला लोकतांत्रिक चुनाव हुआ और नेल्सन मंडेला राष्ट्रपति बने।',
    era: 'Modern',
    region: kRegionWorld,
  ),
  HistoricalEvent(
    year: '2001 CE',
    title: 'September 11 Attacks',
    titleOdia: 'ସେପ୍ଟେମ୍ବର ୧୧ ଆକ୍ରମଣ',
    titleHindi: '11 सितंबर के हमले',
    description:
        'Coordinated terrorist attacks in the United States reshape global security and international politics.',
    descriptionOdia:
        'ଯୁକ୍ତରାଷ୍ଟ୍ରରେ ସମନ୍ୱିତ ଆତଙ୍କବାଦୀ ଆକ୍ରମଣ ବିଶ୍ୱ ସୁରକ୍ଷା ଓ ଆନ୍ତର୍ଜାତିକ ରାଜନୀତିକୁ ପରିବର୍ତ୍ତନ କରେ।',
    descriptionHindi:
        'संयुक्त राज्य अमेरिका में समन्वित आतंकवादी हमलों ने वैश्विक सुरक्षा और अंतरराष्ट्रीय राजनीति को बदल दिया।',
    era: 'Modern',
    region: kRegionWorld,
  ),
  HistoricalEvent(
    year: '2020 CE',
    title: 'COVID-19 Pandemic',
    titleOdia: 'କୋଭିଡ୍-୧୯ ମହାମାରୀ',
    titleHindi: 'कोविड-19 महामारी',
    description:
        'COVID-19 spreads worldwide, causing a global public-health emergency and major social and economic disruption.',
    descriptionOdia:
        'କୋଭିଡ୍-୧୯ ସାରା ବିଶ୍ୱରେ ବ୍ୟାପି ଏକ ବିଶ୍ୱବ୍ୟାପୀ ଜନସ୍ୱାସ୍ଥ୍ୟ ଜରୁରୀ ପରିସ୍ଥିତି ଓ ବଡ଼ ସାମାଜିକ-ଆର୍ଥିକ ବ୍ୟାଘାତ ସୃଷ୍ଟି କରେ।',
    descriptionHindi:
        'कोविड-19 विश्वभर में फैला, जिससे वैश्विक जन-स्वास्थ्य आपातस्थिति और बड़ा सामाजिक व आर्थिक व्यवधान पैदा हुआ।',
    era: 'Modern',
    region: kRegionWorld,
  ),

  // ─── Tamil Nadu ─────────────────────────────────────────────────────────
  HistoricalEvent(
    year: '300 BCE',
    title: 'Rise of the Sangam Age',
    titleOdia: 'ସଙ୍ଗମ ଯୁଗର ଉତ୍ଥାନ',
    titleHindi: 'संगम युग का उदय',
    description:
        'Flourishing of classical Tamil literature under the Chera, Chola and Pandya kingdoms.',
    descriptionOdia:
        'ଚେର, ଚୋଳ ଓ ପାଣ୍ଡ୍ୟ ରାଜ୍ୟ ଅଧୀନରେ ଶାସ୍ତ୍ରୀୟ ତାମିଲ ସାହିତ୍ୟର ବିକାଶ।',
    descriptionHindi:
        'चेर, चोल और पांड्य राज्यों के अधीन शास्त्रीय तमिल साहित्य का विकास।',
    era: 'Ancient',
    region: 'Tamil Nadu',
  ),
  HistoricalEvent(
    year: '1010 CE',
    title: 'Brihadeeswara Temple Built',
    titleOdia: 'ବୃହଦୀଶ୍ୱର ମନ୍ଦିର ନିର୍ମାଣ',
    titleHindi: 'बृहदेश्वर मंदिर का निर्माण',
    description:
        'Raja Raja Chola I completes the great Brihadeeswara Temple at Thanjavur.',
    descriptionOdia:
        'ରାଜା ରାଜା ଚୋଳ ପ୍ରଥମ ଥାଞ୍ଜାଭୁରଠାରେ ମହାନ ବୃହଦୀଶ୍ୱର ମନ୍ଦିର ସମ୍ପୂର୍ଣ୍ଣ କରନ୍ତି।',
    descriptionHindi:
        'राजा राजा चोल प्रथम ने तंजावुर में महान बृहदेश्वर मंदिर का निर्माण पूर्ण किया।',
    era: 'Medieval',
    region: 'Tamil Nadu',
  ),

  // ─── West Bengal ────────────────────────────────────────────────────────
  HistoricalEvent(
    year: '1690 CE',
    title: 'Founding of Calcutta',
    titleOdia: 'କଲିକତାର ପ୍ରତିଷ୍ଠା',
    titleHindi: 'कलकत्ता की स्थापना',
    description:
        'Job Charnock establishes a British trading post that grows into Calcutta.',
    descriptionOdia:
        'ଜବ୍ ଚାର୍ନକ୍ ଏକ ବ୍ରିଟିଶ୍ ବାଣିଜ୍ୟ କେନ୍ଦ୍ର ପ୍ରତିଷ୍ଠା କରନ୍ତି ଯାହା କଲିକତାରେ ପରିଣତ ହୁଏ।',
    descriptionHindi:
        'जॉब चार्नक ने एक ब्रिटिश व्यापारिक चौकी स्थापित की जो आगे चलकर कलकत्ता बनी।',
    era: 'Modern',
    region: 'West Bengal',
  ),

  // ─── Maharashtra ────────────────────────────────────────────────────────
  HistoricalEvent(
    year: '1674 CE',
    title: 'Coronation of Shivaji',
    titleOdia: 'ଶିବାଜୀଙ୍କ ରାଜ୍ୟାଭିଷେକ',
    titleHindi: 'शिवाजी का राज्याभिषेक',
    description:
        'Chhatrapati Shivaji is crowned, founding the Maratha Empire at Raigad.',
    descriptionOdia:
        'ଛତ୍ରପତି ଶିବାଜୀ ରାୟଗଡ଼ଠାରେ ମରାଠା ସାମ୍ରାଜ୍ୟ ପ୍ରତିଷ୍ଠା କରି ରାଜ୍ୟାଭିଷିକ୍ତ ହୁଅନ୍ତି।',
    descriptionHindi:
        'छत्रपति शिवाजी का राज्याभिषेक हुआ, जिन्होंने रायगढ़ में मराठा साम्राज्य की स्थापना की।',
    era: 'Medieval',
    region: 'Maharashtra',
  ),
];
