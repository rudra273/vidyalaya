class DiagramCategory {
  final String id;
  final String titleEn;
  final String titleOr;
  final String titleHi;
  final List<Diagram> diagrams;

  const DiagramCategory({
    required this.id,
    required this.titleEn,
    required this.titleOr,
    required this.titleHi,
    required this.diagrams,
  });
}

class Diagram {
  final String id;
  final String titleEn;
  final String titleOr;
  final String titleHi;
  final String descriptionEn;
  final String descriptionOr;
  final String descriptionHi;
  final String imagePath;

  const Diagram({
    required this.id,
    required this.titleEn,
    required this.titleOr,
    required this.titleHi,
    required this.descriptionEn,
    required this.descriptionOr,
    required this.descriptionHi,
    required this.imagePath,
  });
}

const diagramCategories = [
  DiagramCategory(
    id: 'bio',
    titleEn: 'Biology',
    titleOr: 'ଜୀବବିଜ୍ଞାନ',
    titleHi: 'जीव विज्ञान',
    diagrams: [
      Diagram(
        id: 'human_cell',
        titleEn: 'Human Cell',
        titleOr: 'ମାନବ କୋଷ',
        titleHi: 'मानव कोशिका',
        descriptionEn: 'A detailed diagram of a human cell showing its organelles like nucleus, mitochondria, and cell membrane.',
        descriptionOr: 'ନିୟୁକ୍ଲିୟସ୍, ମାଇଟୋକଣ୍ଡ୍ରିଆ ଏବଂ କୋଷ ଝିଲ୍ଲୀ ପରି ଏହାର ଅଙ୍ଗିକା ଦେଖାଉଥିବା ଏକ ମାନବ କୋଷର ଏକ ବିସ୍ତୃତ ଚିତ୍ର |',
        descriptionHi: 'एक मानव कोशिका का विस्तृत चित्र, जिसमें नाभिक, माइटोकॉन्ड्रिया और कोशिका झिल्ली जैसे कोशिकांग दर्शाए गए हैं।',
        imagePath: 'assets/diagrams/Human_cell.png',
      ),
      Diagram(
        id: 'food_chain',
        titleEn: 'Food Chain',
        titleOr: 'ଖାଦ୍ୟ ଶୃଙ୍ଖଳା',
        titleHi: 'खाद्य श्रृंखला',
        descriptionEn: 'A diagram showing how energy flows from one organism to another, starting from the Sun, through producers to consumers.',
        descriptionOr: 'ସୂର୍ଯ୍ୟଙ୍କଠାରୁ ଆରମ୍ଭ କରି ଉତ୍ପାଦକ ଏବଂ ଉପଭୋକ୍ତା ମଧ୍ୟ ଦେଇ ଶକ୍ତି କିପରି ଗୋଟିଏ ଜୀବରୁ ଅନ୍ୟ ଜୀବକୁ ପ୍ରବାହିତ ହୁଏ ତାହା ଦର୍ଶାଉଥିବା ଏକ ଚିତ୍ର |',
        descriptionHi: 'एक आरेख जो दिखाता है कि ऊर्जा सूर्य से शुरू होकर उत्पादकों और उपभोक्ताओं के माध्यम से एक जीव से दूसरे जीव में कैसे प्रवाहित होती है।',
        imagePath: 'assets/diagrams/food_chain.png',
      ),
      Diagram(
        id: 'human_digestive_system',
        titleEn: 'Human Digestive System',
        titleOr: 'ମାନବ ପାଚନ ତନ୍ତ୍ର',
        titleHi: 'मानव पाचन तंत्र',
        descriptionEn: 'A detailed diagram of the human digestive tract, illustrating key organs including the mouth, stomach, intestines, liver, and pancreas.',
        descriptionOr: 'ମାନବ ପାଚନ ପ୍ରକ୍ରିୟାର ଏକ ବିସ୍ତୃତ ଚିତ୍ର, ଯେଉଁଥିରେ ପାଟି, ପାକସ୍ଥଳୀ, ଅନ୍ତ୍ର, ଯକୃତ ଏବଂ ଅଗ୍ନ୍ୟାଶୟ ପରି ମୁଖ୍ୟ ଅଙ୍ଗଗୁଡ଼ିକୁ ଦର୍ଶାଯାଇଛି |',
        descriptionHi: 'मानव पाचन तंत्र का एक विस्तृत आरेख, जिसमें मुँह, आमाशय, आंतें, यकृत और अग्न्याशय जैसे प्रमुख अंग दिखाए गए हैं।',
        imagePath: 'assets/diagrams/human_digestive_system.png',
      ),
      Diagram(
        id: 'human_heart',
        titleEn: 'Human Heart',
        titleOr: 'ମାନବ ହୃତ୍‌ପିଣ୍ଡ',
        titleHi: 'मानव हृदय',
        descriptionEn: 'A cross-sectional diagram of the human heart, showing chambers, valves, and the flow of oxygenated and deoxygenated blood.',
        descriptionOr: 'ମାନବ ହୃତ୍‌ପିଣ୍ଡର ଏକ ପ୍ରସ୍ଥଚ୍ଛେଦ ଚିତ୍ର, ଯେଉଁଥିରେ ପ୍ରକୋଷ୍ଠ, କବାଟିକା ଏବଂ ଅମ୍ଳଜାନଯୁକ୍ତ ଓ ଅମ୍ଳଜାନବିହୀନ ରକ୍ତର ପ୍ରବାହ ଦର୍ଶାଯାଇଛି |',
        descriptionHi: 'मानव हृदय का एक अनुप्रस्थ काट आरेख, जिसमें कक्ष, कपाट और ऑक्सीजन युक्त व ऑक्सीजन रहित रक्त का प्रवाह दिखाया गया है।',
        imagePath: 'assets/diagrams/human_heart.png',
      ),
      Diagram(
        id: 'photosynthesis',
        titleEn: 'Photosynthesis',
        titleOr: 'ଆଲୋକଶ୍ଳେଷଣ',
        titleHi: 'प्रकाश संश्लेषण',
        descriptionEn: 'A diagram showing how plants produce glucose and oxygen using sunlight, water, and carbon dioxide.',
        descriptionOr: 'ସୂର୍ଯ୍ୟକିରଣ, ଜଳ ଏବଂ ଅଙ୍ଗାରକାମ୍ଳ ବ୍ୟବହାର କରି ଉଦ୍ଭିଦଗୁଡ଼ିକ କିପରି ଗ୍ଲୁକୋଜ୍ ଏବଂ ଅମ୍ଳଜାନ ପ୍ରସ୍ତୁତ କରନ୍ତି ତାହା ଦର୍ଶାଉଥିବା ଚିତ୍ର |',
        descriptionHi: 'एक आरेख जो दिखाता है कि पौधे धूप, पानी और कार्बन डाइऑक्साइड का उपयोग करके ग्लूकोज और ऑक्सीजन का उत्पादन कैसे करते हैं।',
        imagePath: 'assets/diagrams/photosynthesis.png',
      ),
    ],
  ),
  DiagramCategory(
    id: 'geo',
    titleEn: 'Geography',
    titleOr: 'ଭୂଗୋଳ',
    titleHi: 'भूगोल',
    diagrams: [
      Diagram(
        id: 'earth_layers',
        titleEn: 'Layers of the Earth',
        titleOr: 'ପୃଥିବୀର ସ୍ତର',
        titleHi: 'पृथ्वी की परतें',
        descriptionEn: 'A cross-section of the Earth showing the crust, mantle, outer core, and inner core.',
        descriptionOr: 'ପୃଥିବୀର ଭୂତ୍ୱକ, ମାଣ୍ଟଲ୍, ବାହ୍ୟ କେନ୍ଦ୍ର ଏବଂ ଆଭ୍ୟନ୍ତରୀଣ କେନ୍ଦ୍ର ଦେଖାଉଥିବା ଏକ ପ୍ରସ୍ଥଚ୍ଛେଦ |',
        descriptionHi: 'पृथ्वी का एक अनुप्रस्थ काट, जिसमें भूपर्पटी, मेंटल, बाहरी क्रोड और आंतरिक क्रोड दर्शाए गए हैं।',
        imagePath: 'assets/diagrams/earthlayers.png',
      ),
      Diagram(
        id: 'volcano',
        titleEn: 'Volcano Cross-Section',
        titleOr: 'ଆଗ୍ନେୟଗିରିର ପ୍ରସ୍ଥଚ୍ଛେଦ',
        titleHi: 'ज्वालामुखी का अनुप्रस्थ काट',
        descriptionEn: 'A cross-sectional diagram of a volcano showing the magma chamber, vent, crater, lava flow, and ash cloud.',
        descriptionOr: 'ଆଗ୍ନେୟଗିରିର ଏକ ପ୍ରସ୍ଥଚ୍ଛେଦ ଚିତ୍ର ଯେଉଁଥିରେ ମ୍ୟାଗ୍ମା ପ୍ରକୋଷ୍ଠ, ନଳୀ, କ୍ରେଟର, ଲାଭା ପ୍ରବାହ ଏବଂ ଭସ୍ମ ବାଦଲ ଦର୍ଶାଯାଇଛି |',
        descriptionHi: 'एक ज्वालामुखी का अनुप्रस्थ काट आरेख, जिसमें मैग्मा कक्ष, निकास द्वार, क्रेटर, लावा प्रवाह और राख का बादल दिखाया गया है।',
        imagePath: 'assets/diagrams/volcano.png',
      ),
    ],
  ),
  DiagramCategory(
    id: 'sci',
    titleEn: 'Science',
    titleOr: 'ବିଜ୍ଞାନ',
    titleHi: 'विज्ञान',
    diagrams: [
      Diagram(
        id: 'water_cycle',
        titleEn: 'The Water Cycle',
        titleOr: 'ଜଳ ଚକ୍ର',
        titleHi: 'जल चक्र',
        descriptionEn: 'The continuous movement of water within the Earth and atmosphere through evaporation, condensation, and precipitation.',
        descriptionOr: 'ବାଷ୍ପୀକରଣ, ଘନୀଭବନ ଏବଂ ବୃଷ୍ଟିପାତ ମାଧ୍ୟମରେ ପୃଥିବୀ ଏବଂ ବାୟୁମଣ୍ଡଳ ମଧ୍ୟରେ ଜଳର ନିରନ୍ତର ଗତି |',
        descriptionHi: 'वाष्पीकरण, संघनन और वर्षण के माध्यम से पृथ्वी और वायुमंडल के भीतर जल की निरंतर गति।',
        imagePath: 'assets/diagrams/watercycle.png',
      ),
      Diagram(
        id: 'electric_circuit',
        titleEn: 'Simple Electric Circuit',
        titleOr: 'ସରଳ ବିଦ୍ୟୁତ ପରିପଥ',
        titleHi: 'सरल विद्युत परिपथ',
        descriptionEn: 'A diagram of a basic electric circuit showing a battery, switch, light bulb, and wires to demonstrate current flow.',
        descriptionOr: 'ବ୍ୟାଟେରୀ, ସୁଇଚ୍, ବଲ୍‌ବ ଏବଂ ତାର ଦେଖାଉଥିବା ଏକ ସରଳ ବିଦ୍ୟୁତ ପରିପଥର ଚିତ୍ର, ଯାହା ବିଦ୍ୟୁତ ପ୍ରବାହକୁ ଦର୍ଶାଉଛି |',
        descriptionHi: 'एक बुनियादी विद्युत परिपथ का आरेख जिसमें बैटरी, स्विच, light bulb और तार दिखाए गए हैं, जो विद्युत प्रवाह को प्रदर्शित करते हैं।',
        imagePath: 'assets/diagrams/Electric_circuit.png',
      ),
      Diagram(
        id: 'atom_structure',
        titleEn: 'Structure of an Atom',
        titleOr: 'ପରମାଣୁର ଗଠନ',
        titleHi: 'परमाणु की संरचना',
        descriptionEn: 'A diagram illustrating the subatomic particles: protons and neutrons in the nucleus, and electrons in outer shells.',
        descriptionOr: 'ପରମାଣୁର କଣିକାଗୁଡ଼ିକୁ ଦର୍ଶାଉଥିବା ଚିତ୍ର: କେନ୍ଦ୍ରୀୟ ନ୍ୟուକ୍ଲିୟସରେ ଥିବା ପ୍ରୋଟୋନ ଓ ନ୍ୟୁଟ୍ରୋନ, ଏବଂ ବାହ୍ୟ କକ୍ଷପଥରେ ଥିବା ଇଲେକ୍ଟ୍ରୋନ |',
        descriptionHi: 'एक परमाणु के कणों को दर्शाने वाला आरेख: नाभिक में प्रोटॉन और न्यूट्रॉन, और बाहरी कक्षाओं में इलेक्ट्रॉन।',
        imagePath: 'assets/diagrams/atom_structure.png',
      ),
      Diagram(
        id: 'reflection_light',
        titleEn: 'Reflection of Light',
        titleOr: 'ଆଲୋକର ପ୍ରତିଫଳନ',
        titleHi: 'प्रकाश का परावर्तन',
        descriptionEn: 'A diagram explaining the reflection of light on a plane mirror, showing the incident ray, normal, and reflected ray.',
        descriptionOr: 'ଏକ ସମତଳ ଦର୍ପଣରେ ଆଲୋକର ପ୍ରତିଫଳନକୁ ବୁଝାଉଥିବା ଚିତ୍ର, ଯେଉଁଥିରେ ଆପତିତ ରଶ୍ମି, ଅଭିଲମ୍ବ ଏବଂ ପ୍ରତିଫଳିତ ରଶ୍ମି ଦର୍ଶାଯାଇଛି |',
        descriptionHi: 'एक समतल दर्पण पर प्रकाश के परावर्तन को समझाने वाला आरेख, जिसमें आपतित किरण, अभिलंब और परावर्तित किरण को दर्शाया गया है।',
        imagePath: 'assets/diagrams/refelection_light.png',
      ),
      Diagram(
        id: 'states_of_matter',
        titleEn: 'States of Matter',
        titleOr: 'ପଦାର୍ଥର ଅବସ୍ଥା',
        titleHi: 'पदार्थ की अवस्थाएँ',
        descriptionEn: 'A diagram illustrating the arrangement of particles in solids, liquids, and gases, and their transition processes.',
        descriptionOr: 'କଠିନ, ତରଳ ଏବଂ ଗ୍ୟାସୀୟ ପଦାର୍ଥରେ କଣିକାଗୁଡ଼ିକର ସଜ୍ଜୀକରଣ ଏବଂ ସେଗୁଡ଼ିକର ଅବସ୍ଥା ପରିବର୍ତ୍ତନ ପ୍ରକ୍ରିୟାକୁ ଦର୍ଶାଉଥିବା ଏକ ଚିତ୍ର |',
        descriptionHi: 'ठोस, तरल और गैस में कणों की व्यवस्था और उनकी अवस्था परिवर्तन प्रक्रियाओं को दर्शाने वाला आरेख।',
        imagePath: 'assets/diagrams/states_of_matter.png',
      ),
    ],
  ),
];
