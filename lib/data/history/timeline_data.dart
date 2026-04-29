class HistoricalEvent {
  final String year;
  final String title;
  final String titleOdia;
  final String description;
  final String descriptionOdia;
  final String era;

  const HistoricalEvent({
    required this.year,
    required this.title,
    required this.titleOdia,
    required this.description,
    required this.descriptionOdia,
    required this.era,
  });
}

const List<HistoricalEvent> timelineEvents = [
  // Ancient India
  HistoricalEvent(
    year: '2500 BCE',
    title: 'Indus Valley Civilization',
    titleOdia: 'ସିନ୍ଧୁ ଉପତ୍ୟକା ସଭ୍ୟତା',
    description: 'Flourishing of one of the world\'s oldest urban civilizations in the northwestern regions of South Asia.',
    descriptionOdia: 'ଦକ୍ଷିଣ ଏସିଆର ଉତ୍ତର-ପଶ୍ଚିମ ଅଞ୍ଚଳରେ ବିଶ୍ୱର ଅନ୍ୟତମ ପ୍ରାଚୀନ ସହରାଞ୍ଚଳ ସଭ୍ୟତାର ବିକାଶ।',
    era: 'Ancient India',
  ),
  HistoricalEvent(
    year: '1500 BCE',
    title: 'Vedic Period Begins',
    titleOdia: 'ବୈଦିକ ଯୁଗର ଆରମ୍ଭ',
    description: 'Composition of the Vedas and the beginning of the Vedic culture in the Indian subcontinent.',
    descriptionOdia: 'ବେଦର ରଚନା ଏବଂ ଭାରତୀୟ ଉପମହାଦେଶରେ ବୈଦିକ ସଂସ୍କୃତିର ଆରମ୍ଭ।',
    era: 'Ancient India',
  ),
  HistoricalEvent(
    year: '563 BCE',
    title: 'Birth of Gautama Buddha',
    titleOdia: 'ଗୌତମ ବୁଦ୍ଧଙ୍କ ଜନ୍ମ',
    description: 'Siddhartha Gautama, the founder of Buddhism, was born in Lumbini.',
    descriptionOdia: 'ବୌଦ୍ଧ ଧର୍ମର ପ୍ରତିଷ୍ଠାତା ସିଦ୍ଧାର୍ଥ ଗୌତମଙ୍କର ଲୁମ୍ବିନୀଠାରେ ଜନ୍ମ।',
    era: 'Ancient India',
  ),
  HistoricalEvent(
    year: '322 BCE',
    title: 'Maurya Empire Established',
    titleOdia: 'ମୌର୍ଯ୍ୟ ସାମ୍ରାଜ୍ୟ ପ୍ରତିଷ୍ଠା',
    description: 'Chandragupta Maurya founds the Maurya Empire, the first pan-Indian empire.',
    descriptionOdia: 'ଚନ୍ଦ୍ରଗୁପ୍ତ ମୌର୍ଯ୍ୟଙ୍କ ଦ୍ୱାରା ପ୍ରଥମ ସର୍ବଭାରତୀୟ ସାମ୍ରାଜ୍ୟ - ମୌର୍ଯ୍ୟ ସାମ୍ରାଜ୍ୟ ପ୍ରତିଷ୍ଠା।',
    era: 'Ancient India',
  ),
  HistoricalEvent(
    year: '261 BCE',
    title: 'Kalinga War',
    titleOdia: 'କଳିଙ୍ଗ ଯୁଦ୍ଧ',
    description: 'Emperor Ashoka invades Kalinga. The massive bloodshed prompts him to embrace Buddhism and non-violence.',
    descriptionOdia: 'ସମ୍ରାଟ ଅଶୋକ କଳିଙ୍ଗ ଆକ୍ରମଣ କରନ୍ତି। ବ୍ୟାପକ ରକ୍ତପାତ ତାଙ୍କୁ ବୌଦ୍ଧ ଧର୍ମ ଏବଂ ଅହିଂସା ଗ୍ରହଣ କରିବାକୁ ପ୍ରେରିତ କରିଥିଲା।',
    era: 'Odisha History',
  ),
  HistoricalEvent(
    year: '320 CE',
    title: 'Gupta Empire Established',
    titleOdia: 'ଗୁପ୍ତ ସାମ୍ରାଜ୍ୟ ପ୍ରତିଷ୍ଠା',
    description: 'Chandragupta I establishes the Gupta Empire, marking the Golden Age of India.',
    descriptionOdia: 'ପ୍ରଥମ ଚନ୍ଦ୍ରଗୁପ୍ତଙ୍କ ଦ୍ୱାରା ଗୁପ୍ତ ସାମ୍ରାଜ୍ୟ ପ୍ରତିଷ୍ଠା, ଯାହା ଭାରତର ସୁବର୍ଣ୍ଣ ଯୁଗ ଭାବରେ ପରିଚିତ।',
    era: 'Ancient India',
  ),

  // Medieval India
  HistoricalEvent(
    year: '1192 CE',
    title: 'Second Battle of Tarain',
    titleOdia: 'ତରାଇନର ଦ୍ୱିତୀୟ ଯୁଦ୍ଧ',
    description: 'Muhammad Ghori defeats Prithviraj Chauhan, paving the way for Islamic rule in India.',
    descriptionOdia: 'ପୃଥ୍ୱୀରାଜ ଚୌହାନଙ୍କୁ ମହମ୍ମଦ ଘୋରୀ ପରାସ୍ତ କଲେ, ଯାହା ଭାରତରେ ଇସଲାମିକ୍ ଶାସନ ପାଇଁ ପଥ ପରିଷ୍କାର କଲା।',
    era: 'Medieval India',
  ),
  HistoricalEvent(
    year: '1435 CE',
    title: 'Gajapati Empire Founded',
    titleOdia: 'ଗଜପତି ସାମ୍ରାଜ୍ୟ ପ୍ରତିଷ୍ଠା',
    description: 'Kapilendra Deva establishes the powerful Gajapati dynasty in Odisha.',
    descriptionOdia: 'କପିଳେନ୍ଦ୍ର ଦେବଙ୍କ ଦ୍ୱାରା ଓଡ଼ିଶାରେ ଶକ୍ତିଶାଳୀ ଗଜପତି ରାଜବଂଶ ପ୍ରତିଷ୍ଠା।',
    era: 'Odisha History',
  ),
  HistoricalEvent(
    year: '1526 CE',
    title: 'First Battle of Panipat',
    titleOdia: 'ପାନିପଥର ପ୍ରଥମ ଯୁଦ୍ଧ',
    description: 'Babur defeats Ibrahim Lodi, marking the beginning of the Mughal Empire in India.',
    descriptionOdia: 'ବାବର ଇବ୍ରାହିମ ଲୋଦୀଙ୍କୁ ପରାସ୍ତ କଲେ, ଯାହା ଭାରତରେ ମୋଗଲ ସାମ୍ରାଜ୍ୟର ଆରମ୍ଭ ଥିଲା।',
    era: 'Medieval India',
  ),
  HistoricalEvent(
    year: '1568 CE',
    title: 'Fall of Independent Odisha',
    titleOdia: 'ସ୍ୱାଧୀନ ଓଡ଼ିଶାର ପତନ',
    description: 'Mukunda Deva is defeated, and Odisha loses its independence to the Bengal Sultanate.',
    descriptionOdia: 'ମୁକୁନ୍ଦ ଦେବଙ୍କ ପରାଜୟ, ଏବଂ ବଙ୍ଗଳା ସୁଲତାନଙ୍କ ଦ୍ୱାରା ଓଡ଼ିଶାର ସ୍ୱାଧୀନତା ଲୋପ।',
    era: 'Odisha History',
  ),

  // Modern India
  HistoricalEvent(
    year: '1757 CE',
    title: 'Battle of Plassey',
    titleOdia: 'ପଲାସୀ ଯୁଦ୍ଧ',
    description: 'British East India Company defeats the Nawab of Bengal, establishing British political power in India.',
    descriptionOdia: 'ବ୍ରିଟିଶ୍ ଇଷ୍ଟ୍ ଇଣ୍ଡିଆ କମ୍ପାନୀ ବଙ୍ଗଳାର ନବାବଙ୍କୁ ପରାସ୍ତ କରି ଭାରତରେ ରାଜନୈତିକ କ୍ଷମତା ସ୍ଥାପନ କଲା।',
    era: 'Modern India',
  ),
  HistoricalEvent(
    year: '1803 CE',
    title: 'British Occupation of Odisha',
    titleOdia: 'ଓଡ଼ିଶାରେ ବ୍ରିଟିଶ୍ ଅଧିକାର',
    description: 'The British East India Company captures Odisha from the Marathas.',
    descriptionOdia: 'ବ୍ରିଟିଶ୍ ଇଷ୍ଟ୍ ଇଣ୍ଡିଆ କମ୍ପାନୀ ମରାଠାମାନଙ୍କ ଠାରୁ ଓଡ଼ିଶା ଦଖଲ କଲା।',
    era: 'Odisha History',
  ),
  HistoricalEvent(
    year: '1817 CE',
    title: 'Paika Rebellion',
    titleOdia: 'ପାଇକ ବିଦ୍ରୋହ',
    description: 'An armed rebellion against the British East India Company\'s rule in Odisha, led by Bakshi Jagabandhu.',
    descriptionOdia: 'ବକ୍ସି ଜଗବନ୍ଧୁଙ୍କ ନେତୃତ୍ୱରେ ଓଡ଼ିଶାରେ ବ୍ରିଟିଶ୍ ଇଷ୍ଟ୍ ଇଣ୍ଡିଆ କମ୍ପାନୀ ବିରୋଧରେ ଏକ ସଶସ୍ତ୍ର ବିଦ୍ରୋହ।',
    era: 'Odisha History',
  ),
  HistoricalEvent(
    year: '1857 CE',
    title: 'Rebellion of 1857',
    titleOdia: '୧୮୫୭ର ସିପାହୀ ବିଦ୍ରୋହ',
    description: 'The first major widespread uprising against the British East India Company (First War of Independence).',
    descriptionOdia: 'ବ୍ରିଟିଶ୍ ଇଷ୍ଟ୍ ଇଣ୍ଡିଆ କମ୍ପାନୀ ବିରୋଧରେ ପ୍ରଥମ ବ୍ୟାପକ ବିଦ୍ରୋହ (ପ୍ରଥମ ସ୍ୱାଧୀନତା ସଂଗ୍ରାମ)।',
    era: 'Modern India',
  ),
  HistoricalEvent(
    year: '1885 CE',
    title: 'Formation of Indian National Congress',
    titleOdia: 'ଭାରତୀୟ ଜାତୀୟ କଂଗ୍ରେସ ପ୍ରତିଷ୍ଠା',
    description: 'The INC is founded, which later becomes the principal leader of the Indian independence movement.',
    descriptionOdia: 'ଭାରତୀୟ ଜାତୀୟ କଂଗ୍ରେସର ପ୍ରତିଷ୍ଠା, ଯାହା ପରବର୍ତ୍ତୀ ସମୟରେ ଭାରତୀୟ ସ୍ୱାଧୀନତା ଆନ୍ଦୋଳନର ମୁଖ୍ୟ ନେତା ପାଲଟିଥିଲା।',
    era: 'Modern India',
  ),
  HistoricalEvent(
    year: '1936 CE',
    title: 'Formation of Separate Odisha Province',
    titleOdia: 'ସ୍ୱତନ୍ତ୍ର ଓଡ଼ିଶା ପ୍ରଦେଶ ଗଠନ',
    description: 'On April 1, Odisha becomes a separate province on linguistic grounds (celebrated as Utkala Dibasa).',
    descriptionOdia: 'ଏପ୍ରିଲ୍ ୧ ତାରିଖରେ ଭାଷା ଭିତ୍ତିରେ ଓଡ଼ିଶା ଏକ ସ୍ୱତନ୍ତ୍ର ପ୍ରଦେଶ ଭାବରେ ଗଠିତ ହେଲା (ଉତ୍କଳ ଦିବସ)।',
    era: 'Odisha History',
  ),
  HistoricalEvent(
    year: '1942 CE',
    title: 'Quit India Movement',
    titleOdia: 'ଭାରତ ଛାଡ଼ ଆନ୍ଦୋଳନ',
    description: 'Mahatma Gandhi launches the Quit India Movement, demanding an end to British rule.',
    descriptionOdia: 'ବ୍ରିଟିଶ୍ ଶାସନର ଅନ୍ତ ଦାବି କରି ମହାତ୍ମା ଗାନ୍ଧୀଙ୍କ ଦ୍ୱାରା ଭାରତ ଛାଡ଼ ଆନ୍ଦୋଳନ ଆରମ୍ଭ।',
    era: 'Modern India',
  ),
  HistoricalEvent(
    year: '1947 CE',
    title: 'Indian Independence',
    titleOdia: 'ଭାରତର ସ୍ୱାଧୀନତା',
    description: 'India gains independence from British rule on August 15, leading to the partition of the subcontinent.',
    descriptionOdia: 'ଅଗଷ୍ଟ ୧୫ରେ ଭାରତ ବ୍ରିଟିଶ୍ ଶାସନରୁ ସ୍ୱାଧୀନତା ଲାଭ କଲା।',
    era: 'Modern India',
  ),
];
