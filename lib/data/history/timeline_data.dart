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

  /// Signed year for ordering (BCE negative), parsed from [year]. Handles
  /// "320 CE", "c. 3100 BCE" and "12th century CE" (taken as its midpoint).
  int get sortYear => timelineSortYear(year);
}

final _yearPattern = RegExp(
  r'(\d+)(?:st|nd|rd|th)?\s*(century)?\s*(BCE|CE)?',
  caseSensitive: false,
);

/// See [HistoricalEvent.sortYear]. Unparseable years sort last.
int timelineSortYear(String year) {
  final m = _yearPattern.firstMatch(year);
  if (m == null) return 1 << 30;
  var n = int.parse(m[1]!);
  if (m[2] != null) n = (n - 1) * 100 + 50;
  return (m[3]?.toUpperCase() == 'BCE') ? -n : n;
}

/// Events oldest first; events in the same year keep their listed order.
List<HistoricalEvent> sortedChronologically(Iterable<HistoricalEvent> events) {
  final indexed = events.toList().asMap().entries.toList()
    ..sort((a, b) {
      final byYear = a.value.sortYear.compareTo(b.value.sortYear);
      return byYear != 0 ? byYear : a.key.compareTo(b.key);
    });
  return [for (final e in indexed) e.value];
}

/// States that actually have events, in [indianStates] order — the state
/// picker offers only these, so no choice leads to an empty timeline.
final List<String> statesWithEvents = [
  for (final s in indianStates)
    if (timelineEvents.any((e) => e.region == s)) s,
];

/// Region scope sentinels used by [HistoricalEvent.region].
const String kRegionWorld = 'World';
const String kRegionIndia = 'India';

/// The 28 Indian states (excluding union territories), alphabetical. The
/// state picker shows the subset in [statesWithEvents]. Odisha is the default
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

  // ─── Odisha (Phase 4 additions) ─────────────────────────────────────────
  HistoricalEvent(
    year: 'c. 1st century BCE',
    title: 'King Kharavela of Kalinga',
    titleOdia: 'କଳିଙ୍ଗର ରାଜା ଖାରବେଳ',
    titleHindi: 'कलिंग के राजा खारवेल',
    description:
        'Kharavela of the Chedi (Mahameghavahana) dynasty makes Kalinga powerful again. His deeds are recorded in the Hathigumpha inscription at Udayagiri near Bhubaneswar.',
    descriptionOdia:
        'ଚେଦି (ମହାମେଘବାହନ) ବଂଶର ଖାରବେଳ କଳିଙ୍ଗକୁ ପୁଣି ଶକ୍ତିଶାଳୀ କରନ୍ତି। ତାଙ୍କ କୀର୍ତ୍ତି ଭୁବନେଶ୍ୱର ନିକଟ ଉଦୟଗିରିର ହାତୀଗୁମ୍ଫା ଶିଳାଲେଖରେ ଲିପିବଦ୍ଧ।',
    descriptionHindi:
        'चेदि (महामेघवाहन) वंश के खारवेल ने कलिंग को फिर से शक्तिशाली बनाया। उनके कार्य भुवनेश्वर के पास उदयगिरि के हाथीगुम्फा शिलालेख में दर्ज हैं।',
    era: 'Ancient',
    region: 'Odisha',
  ),
  HistoricalEvent(
    year: '11th century CE',
    title: 'Lingaraj Temple Built',
    titleOdia: 'ଲିଙ୍ଗରାଜ ମନ୍ଦିର ନିର୍ମାଣ',
    titleHindi: 'लिंगराज मंदिर का निर्माण',
    description:
        'The Lingaraj Temple, dedicated to Shiva, rises in Bhubaneswar, the "Temple City" of India, as a high point of Kalinga-style architecture.',
    descriptionOdia:
        'ଶିବଙ୍କୁ ଉତ୍ସର୍ଗୀକୃତ ଲିଙ୍ଗରାଜ ମନ୍ଦିର ଭାରତର "ମନ୍ଦିର ନଗରୀ" ଭୁବନେଶ୍ୱରରେ କଳିଙ୍ଗ ଶୈଳୀ ସ୍ଥାପତ୍ୟର ଏକ ଶିଖର ଭାବେ ନିର୍ମିତ ହୁଏ।',
    descriptionHindi:
        'शिव को समर्पित लिंगराज मंदिर भारत के "मंदिर नगर" भुवनेश्वर में कलिंग शैली की वास्तुकला के शिखर के रूप में बना।',
    era: 'Medieval',
    region: 'Odisha',
  ),
  HistoricalEvent(
    year: '1078 CE',
    title: 'Eastern Ganga Rule in Odisha',
    titleOdia: 'ଓଡ଼ିଶାରେ ପୂର୍ବ ଗଙ୍ଗ ଶାସନ',
    titleHindi: 'ओडिशा में पूर्वी गंग शासन',
    description:
        'Anantavarman Chodaganga Deva comes to the throne and the Eastern Ganga dynasty unites Odisha from the Ganga to the Godavari.',
    descriptionOdia:
        'ଅନନ୍ତବର୍ମନ ଚୋଡ଼ଗଙ୍ଗ ଦେବ ସିଂହାସନ ଆରୋହଣ କରନ୍ତି ଏବଂ ପୂର୍ବ ଗଙ୍ଗ ବଂଶ ଗଙ୍ଗାଠାରୁ ଗୋଦାବରୀ ପର୍ଯ୍ୟନ୍ତ ଓଡ଼ିଶାକୁ ଏକତ୍ର କରେ।',
    descriptionHindi:
        'अनंतवर्मन चोडगंग देव सिंहासन पर बैठे और पूर्वी गंग वंश ने गंगा से गोदावरी तक ओडिशा को एक किया।',
    era: 'Medieval',
    region: 'Odisha',
  ),
  HistoricalEvent(
    year: '12th century CE',
    title: 'Jagannath Temple, Puri',
    titleOdia: 'ପୁରୀ ଶ୍ରୀଜଗନ୍ନାଥ ମନ୍ଦିର',
    titleHindi: 'जगन्नाथ मंदिर, पुरी',
    description:
        'Anantavarman Chodaganga Deva begins building the great Jagannath Temple at Puri, home of the famous Rath Yatra.',
    descriptionOdia:
        'ଅନନ୍ତବର୍ମନ ଚୋଡ଼ଗଙ୍ଗ ଦେବ ପୁରୀରେ ମହାନ ଶ୍ରୀଜଗନ୍ନାଥ ମନ୍ଦିର ନିର୍ମାଣ ଆରମ୍ଭ କରନ୍ତି, ଯାହା ପ୍ରସିଦ୍ଧ ରଥଯାତ୍ରାର ପୀଠ।',
    descriptionHindi:
        'अनंतवर्मन चोडगंग देव ने पुरी में भव्य जगन्नाथ मंदिर का निर्माण आरंभ किया, जो प्रसिद्ध रथ यात्रा का केंद्र है।',
    era: 'Medieval',
    region: 'Odisha',
  ),
  HistoricalEvent(
    year: 'c. 1250 CE',
    title: 'Konark Sun Temple',
    titleOdia: 'କୋଣାର୍କ ସୂର୍ଯ୍ୟ ମନ୍ଦିର',
    titleHindi: 'कोणार्क सूर्य मंदिर',
    description:
        'King Narasimha Deva I builds the Sun Temple at Konark, shaped like a giant chariot with 24 carved stone wheels. It is now a UNESCO World Heritage Site.',
    descriptionOdia:
        'ରାଜା ପ୍ରଥମ ନରସିଂହ ଦେବ କୋଣାର୍କରେ ସୂର୍ଯ୍ୟ ମନ୍ଦିର ନିର୍ମାଣ କରନ୍ତି, ଯାହା 24ଟି ଖୋଦିତ ପଥର ଚକ ଥିବା ଏକ ବିଶାଳ ରଥ ଆକୃତିର। ଏହା ଏବେ ୟୁନେସ୍କୋ ବିଶ୍ୱ ଐତିହ୍ୟ ସ୍ଥଳ।',
    descriptionHindi:
        'राजा नरसिंह देव प्रथम ने कोणार्क में सूर्य मंदिर बनवाया, जो 24 नक्काशीदार पत्थर के पहियों वाले विशाल रथ के आकार का है। यह अब यूनेस्को विश्व धरोहर स्थल है।',
    era: 'Medieval',
    region: 'Odisha',
  ),
  HistoricalEvent(
    year: '1866 CE',
    title: 'Great Odisha Famine (Na\'anka Durbhiksha)',
    titleOdia: 'ନଅଙ୍କ ଦୁର୍ଭିକ୍ଷ',
    titleHindi: 'ओडिशा का महा अकाल (नअंक दुर्भिक्ष)',
    description:
        'A terrible famine kills about a million people in Odisha, about a third of its population, and exposes the neglect of British rule.',
    descriptionOdia:
        'ଏକ ଭୟଙ୍କର ଦୁର୍ଭିକ୍ଷରେ ଓଡ଼ିଶାର ପ୍ରାୟ ଦଶ ଲକ୍ଷ ଲୋକ, ଅର୍ଥାତ୍ ଜନସଂଖ୍ୟାର ପ୍ରାୟ ଏକ ତୃତୀୟାଂଶ ପ୍ରାଣ ହରାନ୍ତି, ଯାହା ବ୍ରିଟିଶ୍ ଶାସନର ଅବହେଳାକୁ ପ୍ରକାଶ କରେ।',
    descriptionHindi:
        'एक भयानक अकाल में ओडिशा के लगभग दस लाख लोग, यानी लगभग एक तिहाई आबादी, मारे गए, जिससे ब्रिटिश शासन की उपेक्षा उजागर हुई।',
    era: 'Modern',
    region: 'Odisha',
  ),
  HistoricalEvent(
    year: '1903 CE',
    title: 'Utkal Sammilani Founded',
    titleOdia: 'ଉତ୍କଳ ସମ୍ମିଳନୀ ପ୍ରତିଷ୍ଠା',
    titleHindi: 'उत्कल सम्मिलनी की स्थापना',
    description:
        'Madhusudan Das (Utkal Gourab) founds the Utkal Sammilani to unite all Odia-speaking areas into one province.',
    descriptionOdia:
        'ଉତ୍କଳ ଗୌରବ ମଧୁସୂଦନ ଦାସ ସମସ୍ତ ଓଡ଼ିଆ ଭାଷାଭାଷୀ ଅଞ୍ଚଳକୁ ଗୋଟିଏ ପ୍ରଦେଶରେ ଏକତ୍ର କରିବା ପାଇଁ ଉତ୍କଳ ସମ୍ମିଳନୀ ପ୍ରତିଷ୍ଠା କରନ୍ତି।',
    descriptionHindi:
        'उत्कल गौरव मधुसूदन दास ने सभी ओड़िया भाषी क्षेत्रों को एक प्रांत में मिलाने के लिए उत्कल सम्मिलनी की स्थापना की।',
    era: 'Modern',
    region: 'Odisha',
  ),
  HistoricalEvent(
    year: '1909 CE',
    title: 'Satyabadi School Founded',
    titleOdia: 'ସତ୍ୟବାଦୀ ବିଦ୍ୟାଳୟ ପ୍ରତିଷ୍ଠା',
    titleHindi: 'सत्यवादी विद्यालय की स्थापना',
    description:
        'Utkalmani Gopabandhu Das starts the Satyabadi Bana Vidyalaya near Puri, an open-air school that inspired a generation of nationalists.',
    descriptionOdia:
        'ଉତ୍କଳମଣି ଗୋପବନ୍ଧୁ ଦାସ ପୁରୀ ନିକଟରେ ସତ୍ୟବାଦୀ ବନ ବିଦ୍ୟାଳୟ ଆରମ୍ଭ କରନ୍ତି, ଯାହା ଏକ ପିଢ଼ି ଦେଶପ୍ରେମୀଙ୍କୁ ପ୍ରେରଣା ଦେଇଥିଲା।',
    descriptionHindi:
        'उत्कलमणि गोपबंधु दास ने पुरी के पास सत्यवादी वन विद्यालय शुरू किया, जिसने राष्ट्रवादियों की एक पीढ़ी को प्रेरित किया।',
    era: 'Modern',
    region: 'Odisha',
  ),
  HistoricalEvent(
    year: '1948 CE',
    title: 'Princely States Merge with Odisha',
    titleOdia: 'ଗଡ଼ଜାତ ରାଜ୍ୟମାନଙ୍କର ଓଡ଼ିଶାରେ ମିଶ୍ରଣ',
    titleHindi: 'रियासतों का ओडिशा में विलय',
    description:
        'The princely states (Garjats) join Odisha after independence; Mayurbhanj follows in 1949, giving the state its present shape.',
    descriptionOdia:
        'ସ୍ୱାଧୀନତା ପରେ ଗଡ଼ଜାତ ରାଜ୍ୟମାନେ ଓଡ଼ିଶାରେ ମିଶନ୍ତି; 1949ରେ ମୟୂରଭଞ୍ଜ ମିଶି ରାଜ୍ୟକୁ ଏହାର ବର୍ତ୍ତମାନ ଆକାର ଦିଏ।',
    descriptionHindi:
        'स्वतंत्रता के बाद रियासतें (गड़जात) ओडिशा में मिलीं; 1949 में मयूरभंज के विलय से राज्य को वर्तमान रूप मिला।',
    era: 'Modern',
    region: 'Odisha',
  ),
  HistoricalEvent(
    year: '1948 CE',
    title: 'Bhubaneswar Chosen as Capital',
    titleOdia: 'ଭୁବନେଶ୍ୱର ରାଜଧାନୀ ଭାବେ ମନୋନୀତ',
    titleHindi: 'भुवनेश्वर राजधानी चुना गया',
    description:
        'Prime Minister Nehru lays the foundation of a new planned capital at Bhubaneswar, which replaces Cuttack as the capital of Odisha.',
    descriptionOdia:
        'ପ୍ରଧାନମନ୍ତ୍ରୀ ନେହେରୁ ଭୁବନେଶ୍ୱରରେ ଏକ ନୂତନ ଯୋଜନାବଦ୍ଧ ରାଜଧାନୀର ଶିଳାନ୍ୟାସ କରନ୍ତି, ଯାହା କଟକ ପରିବର୍ତ୍ତେ ଓଡ଼ିଶାର ରାଜଧାନୀ ହୁଏ।',
    descriptionHindi:
        'प्रधानमंत्री नेहरू ने भुवनेश्वर में एक नई नियोजित राजधानी की नींव रखी, जो कटक के स्थान पर ओडिशा की राजधानी बनी।',
    era: 'Modern',
    region: 'Odisha',
  ),
  HistoricalEvent(
    year: '1957 CE',
    title: 'Hirakud Dam Inaugurated',
    titleOdia: 'ହୀରାକୁଦ ବନ୍ଧ ଉଦ୍‌ଘାଟନ',
    titleHindi: 'हीराकुंड बाँध का उद्घाटन',
    description:
        'The Hirakud Dam on the Mahanadi, one of the longest earthen dams in the world, opens to control floods, irrigate fields and make electricity.',
    descriptionOdia:
        'ମହାନଦୀ ଉପରେ ବିଶ୍ୱର ଅନ୍ୟତମ ଦୀର୍ଘତମ ମାଟି ବନ୍ଧ ହୀରାକୁଦ ବନ୍ଧ ବନ୍ୟା ନିୟନ୍ତ୍ରଣ, ଜଳସେଚନ ଓ ବିଦ୍ୟୁତ୍ ଉତ୍ପାଦନ ପାଇଁ ଖୋଲେ।',
    descriptionHindi:
        'महानदी पर बना हीराकुंड बाँध, दुनिया के सबसे लंबे मिट्टी के बाँधों में से एक, बाढ़ नियंत्रण, सिंचाई और बिजली के लिए खोला गया।',
    era: 'Modern',
    region: 'Odisha',
  ),
  HistoricalEvent(
    year: '1999 CE',
    title: 'Odisha Super Cyclone',
    titleOdia: 'ଓଡ଼ିଶା ମହାବାତ୍ୟା',
    titleHindi: 'ओडिशा महाचक्रवात',
    description:
        'A super cyclone strikes the Odisha coast and kills around 10,000 people. The disaster leads Odisha to build one of the best cyclone-warning and shelter systems in the world.',
    descriptionOdia:
        'ଏକ ମହାବାତ୍ୟା ଓଡ଼ିଶା ଉପକୂଳରେ ଆଘାତ କରି ପ୍ରାୟ 10,000 ଲୋକଙ୍କ ଜୀବନ ନିଏ। ଏହା ପରେ ଓଡ଼ିଶା ବିଶ୍ୱର ଅନ୍ୟତମ ଶ୍ରେଷ୍ଠ ବାତ୍ୟା ସତର୍କତା ଓ ଆଶ୍ରୟସ୍ଥଳୀ ବ୍ୟବସ୍ଥା ଗଢ଼େ।',
    descriptionHindi:
        'एक महाचक्रवात ने ओडिशा तट पर प्रहार किया और लगभग 10,000 लोगों की जान ली। इसके बाद ओडिशा ने दुनिया की सबसे अच्छी चक्रवात चेतावनी और आश्रय व्यवस्थाओं में से एक बनाई।',
    era: 'Modern',
    region: 'Odisha',
  ),
  HistoricalEvent(
    year: '2011 CE',
    title: 'Orissa Renamed Odisha',
    titleOdia: 'ଓଡ଼ିଶା ନାମକରଣ',
    titleHindi: 'उड़ीसा का नाम ओडिशा हुआ',
    description:
        'The state\'s name in English changes from Orissa to Odisha, and its language from Oriya to Odia, to match how they are said in Odia.',
    descriptionOdia:
        'ଇଂରାଜୀରେ ରାଜ୍ୟର ନାମ Orissa ରୁ Odisha ଓ ଭାଷାର ନାମ Oriya ରୁ Odia ହୁଏ, ଯାହା ଓଡ଼ିଆ ଉଚ୍ଚାରଣ ସହ ମେଳ ଖାଏ।',
    descriptionHindi:
        'अंग्रेज़ी में राज्य का नाम Orissa से Odisha और भाषा का नाम Oriya से Odia हुआ, ताकि ओड़िया उच्चारण से मेल खाए।',
    era: 'Modern',
    region: 'Odisha',
  ),
  HistoricalEvent(
    year: '2014 CE',
    title: 'Odia Declared a Classical Language',
    titleOdia: 'ଓଡ଼ିଆ ଶାସ୍ତ୍ରୀୟ ଭାଷା ଘୋଷିତ',
    titleHindi: 'ओड़िया शास्त्रीय भाषा घोषित',
    description:
        'Odia becomes the sixth Indian language to be given classical language status, recognising its long literary history.',
    descriptionOdia:
        'ଓଡ଼ିଆ ଶାସ୍ତ୍ରୀୟ ଭାଷାର ମାନ୍ୟତା ପାଇଥିବା ଷଷ୍ଠ ଭାରତୀୟ ଭାଷା ହୁଏ, ଯାହା ଏହାର ଦୀର୍ଘ ସାହିତ୍ୟିକ ଇତିହାସକୁ ସ୍ୱୀକୃତି ଦିଏ।',
    descriptionHindi:
        'ओड़िया शास्त्रीय भाषा का दर्जा पाने वाली छठी भारतीय भाषा बनी, जिससे इसके लंबे साहित्यिक इतिहास को मान्यता मिली।',
    era: 'Modern',
    region: 'Odisha',
  ),

  // ─── India & other states (Phase 4 additions) ───────────────────────────
  HistoricalEvent(
    year: 'c. 260 BCE',
    title: 'Ashoka\'s Edicts',
    titleOdia: 'ଅଶୋକଙ୍କ ଶିଳାଲେଖ',
    titleHindi: 'अशोक के शिलालेख',
    description:
        'After the Kalinga War, Emperor Ashoka carves edicts on rocks and pillars across India spreading dhamma: kindness, tolerance and non-violence.',
    descriptionOdia:
        'କଳିଙ୍ଗ ଯୁଦ୍ଧ ପରେ ସମ୍ରାଟ ଅଶୋକ ଭାରତ ସାରା ପଥର ଓ ସ୍ତମ୍ଭରେ ଧର୍ମ — ଦୟା, ସହନଶୀଳତା ଓ ଅହିଂସା ପ୍ରଚାର ପାଇଁ ଶିଳାଲେଖ ଖୋଦନ୍ତି।',
    descriptionHindi:
        'कलिंग युद्ध के बाद सम्राट अशोक ने पूरे भारत में चट्टानों और स्तंभों पर धम्म — दया, सहनशीलता और अहिंसा — फैलाने के लिए शिलालेख खुदवाए।',
    era: 'Ancient',
    region: kRegionIndia,
  ),
  HistoricalEvent(
    year: '985 CE',
    title: 'Rajaraja Chola I Becomes King',
    titleOdia: 'ରାଜରାଜ ଚୋଳ ପ୍ରଥମଙ୍କ ରାଜ୍ୟାରୋହଣ',
    titleHindi: 'राजराज चोल प्रथम राजा बने',
    description:
        'Rajaraja Chola I begins a reign that turns the Chola kingdom into a great empire with a powerful navy.',
    descriptionOdia:
        'ରାଜରାଜ ଚୋଳ ପ୍ରଥମଙ୍କ ଶାସନ ଆରମ୍ଭ ହୁଏ, ଯାହା ଚୋଳ ରାଜ୍ୟକୁ ଏକ ଶକ୍ତିଶାଳୀ ନୌସେନା ସହ ମହାନ ସାମ୍ରାଜ୍ୟରେ ପରିଣତ କରେ।',
    descriptionHindi:
        'राजराज चोल प्रथम का शासन शुरू हुआ, जिसने चोल राज्य को शक्तिशाली नौसेना वाले महान साम्राज्य में बदल दिया।',
    era: 'Medieval',
    region: 'Tamil Nadu',
  ),
  HistoricalEvent(
    year: '1206 CE',
    title: 'Delhi Sultanate Founded',
    titleOdia: 'ଦିଲ୍ଲୀ ସୁଲତାନାତ ପ୍ରତିଷ୍ଠା',
    titleHindi: 'दिल्ली सल्तनत की स्थापना',
    description:
        'Qutb-ud-din Aibak becomes the first Sultan of Delhi, beginning more than three centuries of Sultanate rule in north India.',
    descriptionOdia:
        'କୁତୁବୁଦ୍ଦିନ ଆଇବକ ଦିଲ୍ଲୀର ପ୍ରଥମ ସୁଲତାନ ହୁଅନ୍ତି, ଯାହା ଉତ୍ତର ଭାରତରେ ତିନି ଶତାବ୍ଦୀରୁ ଅଧିକ ସୁଲତାନାତ ଶାସନର ଆରମ୍ଭ।',
    descriptionHindi:
        'कुतुबुद्दीन ऐबक दिल्ली के पहले सुल्तान बने, जिससे उत्तर भारत में तीन शताब्दियों से अधिक के सल्तनत शासन की शुरुआत हुई।',
    era: 'Medieval',
    region: kRegionIndia,
  ),
  HistoricalEvent(
    year: '1336 CE',
    title: 'Vijayanagara Empire Founded',
    titleOdia: 'ବିଜୟନଗର ସାମ୍ରାଜ୍ୟ ପ୍ରତିଷ୍ଠା',
    titleHindi: 'विजयनगर साम्राज्य की स्थापना',
    description:
        'Harihara and Bukka found the Vijayanagara Empire, whose capital Hampi became one of the richest cities in the world.',
    descriptionOdia:
        'ହରିହର ଓ ବୁକ୍କ ବିଜୟନଗର ସାମ୍ରାଜ୍ୟ ପ୍ରତିଷ୍ଠା କରନ୍ତି, ଯାହାର ରାଜଧାନୀ ହମ୍ପି ବିଶ୍ୱର ଅନ୍ୟତମ ଧନୀ ସହର ହୋଇଥିଲା।',
    descriptionHindi:
        'हरिहर और बुक्का ने विजयनगर साम्राज्य की स्थापना की, जिसकी राजधानी हम्पी दुनिया के सबसे समृद्ध शहरों में से एक बनी।',
    era: 'Medieval',
    region: 'Karnataka',
  ),
  HistoricalEvent(
    year: '1498 CE',
    title: 'Vasco da Gama Reaches Calicut',
    titleOdia: 'ଭାସ୍କୋ ଡା ଗାମାଙ୍କ କାଲିକଟ ଆଗମନ',
    titleHindi: 'वास्को दा गामा कालीकट पहुँचे',
    description:
        'The Portuguese sailor Vasco da Gama lands at Calicut, opening a sea route from Europe to India around Africa.',
    descriptionOdia:
        'ପର୍ତ୍ତୁଗୀଜ୍ ନାବିକ ଭାସ୍କୋ ଡା ଗାମା କାଲିକଟରେ ପହଞ୍ଚନ୍ତି ଏବଂ ଆଫ୍ରିକା ଘେରି ୟୁରୋପରୁ ଭାରତକୁ ସମୁଦ୍ର ପଥ ଖୋଲନ୍ତି।',
    descriptionHindi:
        'पुर्तगाली नाविक वास्को दा गामा कालीकट पहुँचे और अफ्रीका का चक्कर लगाकर यूरोप से भारत का समुद्री मार्ग खोला।',
    era: 'Medieval',
    region: 'Kerala',
  ),
  HistoricalEvent(
    year: '1556 CE',
    title: 'Akbar Becomes Mughal Emperor',
    titleOdia: 'ଆକବରଙ୍କ ମୋଗଲ ସମ୍ରାଟ ହେବା',
    titleHindi: 'अकबर मुग़ल सम्राट बने',
    description:
        'After the Second Battle of Panipat, the young Akbar becomes emperor and goes on to build a vast, well-run empire known for religious tolerance.',
    descriptionOdia:
        'ପାଣିପଥର ଦ୍ୱିତୀୟ ଯୁଦ୍ଧ ପରେ ଯୁବ ଆକବର ସମ୍ରାଟ ହୁଅନ୍ତି ଏବଂ ଧାର୍ମିକ ସହନଶୀଳତା ପାଇଁ ଜଣାଶୁଣା ଏକ ବିଶାଳ, ସୁଶାସିତ ସାମ୍ରାଜ୍ୟ ଗଢ଼ନ୍ତି।',
    descriptionHindi:
        'पानीपत की दूसरी लड़ाई के बाद युवा अकबर सम्राट बने और धार्मिक सहिष्णुता के लिए प्रसिद्ध एक विशाल, सुशासित साम्राज्य बनाया।',
    era: 'Medieval',
    region: kRegionIndia,
  ),
  HistoricalEvent(
    year: '1858 CE',
    title: 'Crown Rule Begins in India',
    titleOdia: 'ଭାରତରେ ବ୍ରିଟିଶ୍ ରାଜମୁକୁଟ ଶାସନ ଆରମ୍ଭ',
    titleHindi: 'भारत में ब्रिटिश ताज का शासन आरंभ',
    description:
        'After the Rebellion of 1857, the British Crown takes over India from the East India Company.',
    descriptionOdia:
        '1857 ବିଦ୍ରୋହ ପରେ ବ୍ରିଟିଶ୍ ରାଜମୁକୁଟ ଇଷ୍ଟ ଇଣ୍ଡିଆ କମ୍ପାନୀଠାରୁ ଭାରତର ଶାସନ ଭାର ନିଏ।',
    descriptionHindi:
        '1857 के विद्रोह के बाद ब्रिटिश ताज ने ईस्ट इंडिया कंपनी से भारत का शासन अपने हाथ में ले लिया।',
    era: 'Modern',
    region: kRegionIndia,
  ),
  HistoricalEvent(
    year: '1905 CE',
    title: 'Partition of Bengal',
    titleOdia: 'ବଙ୍ଗ ବିଭାଜନ',
    titleHindi: 'बंगाल का विभाजन',
    description:
        'Lord Curzon divides Bengal. Indians protest with the Swadeshi movement, boycotting British goods, and the partition is reversed in 1911.',
    descriptionOdia:
        'ଲର୍ଡ କର୍ଜନ ବଙ୍ଗକୁ ବିଭାଜନ କରନ୍ତି। ଭାରତୀୟମାନେ ବ୍ରିଟିଶ୍ ସାମଗ୍ରୀ ବର୍ଜନ କରି ସ୍ୱଦେଶୀ ଆନ୍ଦୋଳନ ମାଧ୍ୟମରେ ବିରୋଧ କରନ୍ତି, ଏବଂ 1911ରେ ବିଭାଜନ ରଦ୍ଦ ହୁଏ।',
    descriptionHindi:
        'लॉर्ड कर्ज़न ने बंगाल का विभाजन किया। भारतीयों ने ब्रिटिश सामान का बहिष्कार कर स्वदेशी आंदोलन से विरोध किया, और 1911 में विभाजन रद्द हुआ।',
    era: 'Modern',
    region: kRegionIndia,
  ),
  HistoricalEvent(
    year: '1919 CE',
    title: 'Jallianwala Bagh Massacre',
    titleOdia: 'ଜାଲିଆନୱାଲାବାଗ ହତ୍ୟାକାଣ୍ଡ',
    titleHindi: 'जलियाँवाला बाग हत्याकांड',
    description:
        'British troops under General Dyer fire on a peaceful crowd in Amritsar, killing hundreds and turning many Indians firmly against British rule.',
    descriptionOdia:
        'ଜେନେରାଲ ଡାୟରଙ୍କ ନେତୃତ୍ୱରେ ବ୍ରିଟିଶ୍ ସୈନ୍ୟ ଅମୃତସରରେ ଏକ ଶାନ୍ତିପୂର୍ଣ୍ଣ ଜନସମାଗମ ଉପରେ ଗୁଳି ଚଳାଇ ଶହ ଶହ ଲୋକଙ୍କୁ ହତ୍ୟା କରନ୍ତି।',
    descriptionHindi:
        'जनरल डायर के नेतृत्व में ब्रिटिश सैनिकों ने अमृतसर में शांतिपूर्ण भीड़ पर गोली चलाकर सैकड़ों लोगों को मार डाला।',
    era: 'Modern',
    region: 'Punjab',
  ),
  HistoricalEvent(
    year: '1920 CE',
    title: 'Non-Cooperation Movement',
    titleOdia: 'ଅସହଯୋଗ ଆନ୍ଦୋଳନ',
    titleHindi: 'असहयोग आंदोलन',
    description:
        'Mahatma Gandhi asks Indians to stop cooperating with British rule: to leave government schools, courts and jobs, and to boycott foreign cloth.',
    descriptionOdia:
        'ମହାତ୍ମା ଗାନ୍ଧୀ ଭାରତୀୟମାନଙ୍କୁ ବ୍ରିଟିଶ୍ ଶାସନ ସହ ସହଯୋଗ ବନ୍ଦ କରିବାକୁ କହନ୍ତି: ସରକାରୀ ବିଦ୍ୟାଳୟ, ଅଦାଲତ ଓ ଚାକିରି ଛାଡ଼ିବା ଏବଂ ବିଦେଶୀ ବସ୍ତ୍ର ବର୍ଜନ କରିବା।',
    descriptionHindi:
        'महात्मा गांधी ने भारतीयों से ब्रिटिश शासन से सहयोग बंद करने को कहा: सरकारी स्कूल, अदालतें और नौकरियाँ छोड़ना और विदेशी कपड़े का बहिष्कार करना।',
    era: 'Modern',
    region: kRegionIndia,
  ),
  HistoricalEvent(
    year: '1930 CE',
    title: 'Dandi March (Salt Satyagraha)',
    titleOdia: 'ଦାଣ୍ଡି ଯାତ୍ରା (ଲବଣ ସତ୍ୟାଗ୍ରହ)',
    titleHindi: 'दांडी मार्च (नमक सत्याग्रह)',
    description:
        'Gandhi walks about 390 km from Sabarmati to Dandi and makes salt from sea water, breaking the British salt law.',
    descriptionOdia:
        'ଗାନ୍ଧୀ ସାବରମତୀରୁ ଦାଣ୍ଡି ପର୍ଯ୍ୟନ୍ତ ପ୍ରାୟ 390 କିମି ପଦଯାତ୍ରା କରି ସମୁଦ୍ର ଜଳରୁ ଲୁଣ ତିଆରି କରନ୍ତି ଓ ବ୍ରିଟିଶ୍ ଲବଣ ଆଇନ ଭାଙ୍ଗନ୍ତି।',
    descriptionHindi:
        'गांधी ने साबरमती से दांडी तक लगभग 390 किमी पैदल चलकर समुद्री पानी से नमक बनाया और ब्रिटिश नमक कानून तोड़ा।',
    era: 'Modern',
    region: kRegionIndia,
  ),
  HistoricalEvent(
    year: '1950 CE',
    title: 'Constitution of India Comes into Force',
    titleOdia: 'ଭାରତୀୟ ସମ୍ବିଧାନ ଲାଗୁ',
    titleHindi: 'भारत का संविधान लागू',
    description:
        'On 26 January India becomes a republic under its new Constitution, drafted by a committee led by Dr B. R. Ambedkar. The day is celebrated as Republic Day.',
    descriptionOdia:
        '26 ଜାନୁଆରୀରେ ଡକ୍ଟର ବି. ଆର୍. ଆମ୍ବେଦକରଙ୍କ ନେତୃତ୍ୱାଧୀନ କମିଟି ପ୍ରସ୍ତୁତ କରିଥିବା ନୂତନ ସମ୍ବିଧାନ ଅଧୀନରେ ଭାରତ ଗଣତନ୍ତ୍ର ହୁଏ। ଏହି ଦିନ ଗଣତନ୍ତ୍ର ଦିବସ ଭାବେ ପାଳିତ ହୁଏ।',
    descriptionHindi:
        '26 जनवरी को डॉ. बी. आर. आंबेडकर की अध्यक्षता वाली समिति द्वारा तैयार नए संविधान के तहत भारत गणतंत्र बना। यह दिन गणतंत्र दिवस के रूप में मनाया जाता है।',
    era: 'Modern',
    region: kRegionIndia,
  ),
  HistoricalEvent(
    year: '1951 CE',
    title: 'First General Elections',
    titleOdia: 'ପ୍ରଥମ ସାଧାରଣ ନିର୍ବାଚନ',
    titleHindi: 'पहले आम चुनाव',
    description:
        'India holds its first general elections (1951–52), with every adult allowed to vote: the largest election the world had seen.',
    descriptionOdia:
        'ଭାରତ ଏହାର ପ୍ରଥମ ସାଧାରଣ ନିର୍ବାଚନ (1951–52) କରେ, ଯେଉଁଥିରେ ପ୍ରତ୍ୟେକ ପ୍ରାପ୍ତବୟସ୍କ ଭୋଟ ଦେଇପାରିଲେ — ସେ ସମୟର ବିଶ୍ୱର ସର୍ବବୃହତ ନିର୍ବାଚନ।',
    descriptionHindi:
        'भारत ने अपने पहले आम चुनाव (1951–52) कराए, जिसमें हर वयस्क को वोट देने का अधिकार था — उस समय दुनिया का सबसे बड़ा चुनाव।',
    era: 'Modern',
    region: kRegionIndia,
  ),
  HistoricalEvent(
    year: 'c. 1966 CE',
    title: 'Green Revolution',
    titleOdia: 'ସବୁଜ ବିପ୍ଳବ',
    titleHindi: 'हरित क्रांति',
    description:
        'High-yield seeds, irrigation and fertilisers greatly increase wheat and rice harvests, helping India grow enough food for its people.',
    descriptionOdia:
        'ଅଧିକ ଅମଳକ୍ଷମ ବିହନ, ଜଳସେଚନ ଓ ସାର ଗହମ ଓ ଧାନ ଅମଳକୁ ବହୁତ ବଢ଼ାଏ, ଯାହା ଭାରତକୁ ଖାଦ୍ୟରେ ଆତ୍ମନିର୍ଭରଶୀଳ ହେବାରେ ସାହାଯ୍ୟ କରେ।',
    descriptionHindi:
        'अधिक उपज वाले बीज, सिंचाई और उर्वरकों ने गेहूँ और चावल की पैदावार बहुत बढ़ाई, जिससे भारत खाद्यान्न में आत्मनिर्भर बना।',
    era: 'Modern',
    region: kRegionIndia,
  ),
  HistoricalEvent(
    year: '1975 CE',
    title: 'India\'s First Satellite, Aryabhata',
    titleOdia: 'ଭାରତର ପ୍ରଥମ ଉପଗ୍ରହ ଆର୍ଯ୍ୟଭଟ୍ଟ',
    titleHindi: 'भारत का पहला उपग्रह आर्यभट',
    description:
        'ISRO\'s first satellite, named after the ancient mathematician Aryabhata, is launched into space.',
    descriptionOdia:
        'ପ୍ରାଚୀନ ଗଣିତଜ୍ଞ ଆର୍ଯ୍ୟଭଟ୍ଟଙ୍କ ନାମରେ ନାମିତ ଇସ୍ରୋର ପ୍ରଥମ ଉପଗ୍ରହ ମହାକାଶକୁ ଉତ୍କ୍ଷେପିତ ହୁଏ।',
    descriptionHindi:
        'प्राचीन गणितज्ञ आर्यभट के नाम पर इसरो का पहला उपग्रह अंतरिक्ष में प्रक्षेपित किया गया।',
    era: 'Modern',
    region: kRegionIndia,
  ),
  HistoricalEvent(
    year: '2023 CE',
    title: 'Chandrayaan-3 Lands on the Moon',
    titleOdia: 'ଚନ୍ଦ୍ରଯାନ-3ର ଚନ୍ଦ୍ରରେ ଅବତରଣ',
    titleHindi: 'चंद्रयान-3 चंद्रमा पर उतरा',
    description:
        'India becomes the first country to land a spacecraft near the Moon\'s south pole, and the fourth to land on the Moon at all.',
    descriptionOdia:
        'ଚନ୍ଦ୍ରର ଦକ୍ଷିଣ ମେରୁ ନିକଟରେ ମହାକାଶଯାନ ଅବତରଣ କରାଇଥିବା ଭାରତ ପ୍ରଥମ ଦେଶ ଏବଂ ଚନ୍ଦ୍ରରେ ଅବତରଣ କରିଥିବା ଚତୁର୍ଥ ଦେଶ ହୁଏ।',
    descriptionHindi:
        'भारत चंद्रमा के दक्षिणी ध्रुव के पास अंतरिक्ष यान उतारने वाला पहला देश और चंद्रमा पर उतरने वाला चौथा देश बना।',
    era: 'Modern',
    region: kRegionIndia,
  ),
];
