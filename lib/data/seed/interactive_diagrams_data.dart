import 'package:flutter/material.dart';

enum DiagramLanguage { english, hindi, odia }

class DiagramText {
  final String en;
  final String hi;
  final String or;

  const DiagramText({required this.en, required this.hi, required this.or});

  String inLanguage(DiagramLanguage language) => switch (language) {
    DiagramLanguage.english => en,
    DiagramLanguage.hindi => hi,
    DiagramLanguage.odia => or,
  };
}

class InteractiveDiagramLabel {
  final String id;
  final DiagramText title;
  final DiagramText explanation;
  final Offset position;

  const InteractiveDiagramLabel({
    required this.id,
    required this.title,
    required this.explanation,
    required this.position,
  });
}

class InteractiveDiagram {
  final String id;
  final DiagramText title;
  final DiagramText description;
  final String imagePath;
  final double aspectRatio;
  final List<InteractiveDiagramLabel> labels;

  const InteractiveDiagram({
    required this.id,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.aspectRatio,
    required this.labels,
  });
}

const interactiveDiagrams = [
  InteractiveDiagram(
    id: 'animal_cell',
    title: DiagramText(en: 'Animal Cell', hi: 'जंतु कोशिका', or: 'ପ୍ରାଣୀ କୋଷ'),
    description: DiagramText(
      en: 'Explore the main parts of an animal cell.',
      hi: 'जंतु कोशिका के मुख्य भागों को जानें।',
      or: 'ପ୍ରାଣୀ କୋଷର ମୁଖ୍ୟ ଅଂଶଗୁଡ଼ିକୁ ଜାଣନ୍ତୁ।',
    ),
    imagePath: 'assets/diagrams/interactive/animal_cell.jpg',
    aspectRatio: 1,
    labels: [
      InteractiveDiagramLabel(
        id: 'membrane',
        title: DiagramText(
          en: 'Cell membrane',
          hi: 'कोशिका झिल्ली',
          or: 'କୋଷ ଝିଲ୍ଲୀ',
        ),
        explanation: DiagramText(
          en: 'The thin outer boundary that controls what enters and leaves the cell.',
          hi: 'पतली बाहरी सीमा जो कोशिका में पदार्थों के आने और बाहर जाने को नियंत्रित करती है।',
          or: 'ପତଳା ବାହ୍ୟ ସୀମା ଯାହା କୋଷ ଭିତରକୁ ଓ ବାହାରକୁ ପଦାର୍ଥର ଯାତାୟାତ ନିୟନ୍ତ୍ରଣ କରେ।',
        ),
        position: Offset(0.91, 0.50),
      ),
      InteractiveDiagramLabel(
        id: 'cytoplasm',
        title: DiagramText(
          en: 'Cytoplasm',
          hi: 'कोशिकाद्रव्य',
          or: 'କୋଷଦ୍ରବ୍ୟ',
        ),
        explanation: DiagramText(
          en: 'A jelly-like material where the cell organelles are suspended.',
          hi: 'जेली जैसा पदार्थ जिसमें कोशिकांग स्थित रहते हैं।',
          or: 'ଜେଲି ପରି ପଦାର୍ଥ ଯେଉଁଥିରେ କୋଷାଙ୍ଗଗୁଡ଼ିକ ରହିଥାଏ।',
        ),
        position: Offset(0.25, 0.35),
      ),
      InteractiveDiagramLabel(
        id: 'nucleus',
        title: DiagramText(en: 'Nucleus', hi: 'केंद्रक', or: 'ନ୍ୟୁକ୍ଲିୟସ୍'),
        explanation: DiagramText(
          en: 'The control centre of the cell. It contains genetic material.',
          hi: 'कोशिका का नियंत्रण केंद्र। इसमें आनुवंशिक पदार्थ होता है।',
          or: 'କୋଷର ନିୟନ୍ତ୍ରଣ କେନ୍ଦ୍ର। ଏଥିରେ ଆନୁବଂଶିକ ପଦାର୍ଥ ରହିଥାଏ।',
        ),
        position: Offset(0.50, 0.51),
      ),
      InteractiveDiagramLabel(
        id: 'mitochondria',
        title: DiagramText(
          en: 'Mitochondrion',
          hi: 'माइटोकॉन्ड्रिया',
          or: 'ମାଇଟୋକଣ୍ଡ୍ରିଆ',
        ),
        explanation: DiagramText(
          en: 'Releases usable energy from food for the cell.',
          hi: 'कोशिका के लिए भोजन से उपयोगी ऊर्जा मुक्त करता है।',
          or: 'କୋଷ ପାଇଁ ଖାଦ୍ୟରୁ ବ୍ୟବହାରଯୋଗ୍ୟ ଶକ୍ତି ମୁକ୍ତ କରେ।',
        ),
        position: Offset(0.69, 0.20),
      ),
      InteractiveDiagramLabel(
        id: 'er',
        title: DiagramText(
          en: 'Endoplasmic reticulum',
          hi: 'अंतर्द्रव्यी जालिका',
          or: 'ଅନ୍ତଃପ୍ଲାଜ୍ମିକ ଜାଲିକା',
        ),
        explanation: DiagramText(
          en: 'A membrane network that helps make and transport materials.',
          hi: 'झिल्लियों का जाल जो पदार्थों के निर्माण और परिवहन में सहायता करता है।',
          or: 'ଝିଲ୍ଲୀର ଜାଲ ଯାହା ପଦାର୍ଥ ତିଆରି ଓ ପରିବହନରେ ସାହାଯ୍ୟ କରେ।',
        ),
        position: Offset(0.43, 0.29),
      ),
      InteractiveDiagramLabel(
        id: 'golgi',
        title: DiagramText(
          en: 'Golgi apparatus',
          hi: 'गॉल्जी तंत्र',
          or: 'ଗଲ୍‌ଜି ଯନ୍ତ୍ର',
        ),
        explanation: DiagramText(
          en: 'Modifies, sorts and packages proteins for transport.',
          hi: 'प्रोटीन को बदलता, छाँटता और परिवहन के लिए पैक करता है।',
          or: 'ପ୍ରୋଟିନ୍‌କୁ ପରିବର୍ତ୍ତନ, ବିଭାଜନ ଓ ପରିବହନ ପାଇଁ ପ୍ୟାକ୍ କରେ।',
        ),
        position: Offset(0.71, 0.67),
      ),
      InteractiveDiagramLabel(
        id: 'ribosomes',
        title: DiagramText(en: 'Ribosomes', hi: 'राइबोसोम', or: 'ରାଇବୋସୋମ୍'),
        explanation: DiagramText(
          en: 'Tiny structures that build proteins.',
          hi: 'छोटी संरचनाएँ जो प्रोटीन बनाती हैं।',
          or: 'କ୍ଷୁଦ୍ର ଗଠନ ଯାହା ପ୍ରୋଟିନ୍ ତିଆରି କରେ।',
        ),
        position: Offset(0.37, 0.20),
      ),
      InteractiveDiagramLabel(
        id: 'lysosome',
        title: DiagramText(en: 'Lysosome', hi: 'लाइसोसोम', or: 'ଲାଇସୋସୋମ୍'),
        explanation: DiagramText(
          en: 'A small sac that breaks down waste and worn-out cell parts.',
          hi: 'छोटी थैली जो अपशिष्ट और पुराने कोशिकीय भागों को तोड़ती है।',
          or: 'କ୍ଷୁଦ୍ର ଥଳି ଯାହା ବର୍ଜ୍ୟ ଓ ପୁରୁଣା କୋଷୀୟ ଅଂଶକୁ ଭାଙ୍ଗେ।',
        ),
        position: Offset(0.81, 0.39),
      ),
    ],
  ),
  InteractiveDiagram(
    id: 'water_cycle',
    title: DiagramText(en: 'Water Cycle', hi: 'जल चक्र', or: 'ଜଳ ଚକ୍ର'),
    description: DiagramText(
      en: 'Follow water as it moves through Earth and the atmosphere.',
      hi: 'पृथ्वी और वायुमंडल में जल की यात्रा को समझें।',
      or: 'ପୃଥିବୀ ଓ ବାୟୁମଣ୍ଡଳରେ ଜଳର ଯାତ୍ରାକୁ ବୁଝନ୍ତୁ।',
    ),
    imagePath: 'assets/diagrams/interactive/water_cycle.jpg',
    aspectRatio: 1.5,
    labels: [
      InteractiveDiagramLabel(
        id: 'evaporation',
        title: DiagramText(en: 'Evaporation', hi: 'वाष्पीकरण', or: 'ବାଷ୍ପୀକରଣ'),
        explanation: DiagramText(
          en: 'Sunlight heats surface water and changes it into water vapour.',
          hi: 'सूर्य का ताप सतही जल को जलवाष्प में बदल देता है।',
          or: 'ସୂର୍ଯ୍ୟତାପ ଭୂପୃଷ୍ଠର ଜଳକୁ ଜଳୀୟ ବାଷ୍ପରେ ପରିଣତ କରେ।',
        ),
        position: Offset(0.20, 0.48),
      ),
      InteractiveDiagramLabel(
        id: 'condensation',
        title: DiagramText(en: 'Condensation', hi: 'संघनन', or: 'ଘନୀଭବନ'),
        explanation: DiagramText(
          en: 'Cooling water vapour forms tiny droplets that gather as clouds.',
          hi: 'ठंडी जलवाष्प छोटी बूंदें बनाती है जो बादलों में इकट्ठी होती हैं।',
          or: 'ଥଣ୍ଡା ଜଳୀୟ ବାଷ୍ପ କ୍ଷୁଦ୍ର ବିନ୍ଦୁ ହୋଇ ମେଘରେ ଏକାଠି ହୁଏ।',
        ),
        position: Offset(0.47, 0.17),
      ),
      InteractiveDiagramLabel(
        id: 'precipitation',
        title: DiagramText(en: 'Precipitation', hi: 'वर्षण', or: 'ବୃଷ୍ଟିପାତ'),
        explanation: DiagramText(
          en: 'Water falls from clouds as rain, snow or hail.',
          hi: 'जल बादलों से वर्षा, हिम या ओलों के रूप में गिरता है।',
          or: 'ଜଳ ମେଘରୁ ବର୍ଷା, ତୁଷାର କିମ୍ବା କୁଆପଥର ରୂପେ ପଡ଼େ।',
        ),
        position: Offset(0.75, 0.29),
      ),
      InteractiveDiagramLabel(
        id: 'runoff',
        title: DiagramText(
          en: 'Surface runoff',
          hi: 'सतही अपवाह',
          or: 'ଭୂପୃଷ୍ଠ ପ୍ରବାହ',
        ),
        explanation: DiagramText(
          en: 'Water flows downhill through streams and rivers toward larger water bodies.',
          hi: 'जल ढलान पर नदियों और धाराओं से बड़े जलाशयों की ओर बहता है।',
          or: 'ଜଳ ଢାଲୁ ପଥରେ ଝରଣା ଓ ନଦୀ ଦେଇ ବଡ଼ ଜଳାଶୟକୁ ବହେ।',
        ),
        position: Offset(0.68, 0.58),
      ),
      InteractiveDiagramLabel(
        id: 'infiltration',
        title: DiagramText(
          en: 'Infiltration',
          hi: 'अंतःस्रवण',
          or: 'ଅନୁପ୍ରବେଶ',
        ),
        explanation: DiagramText(
          en: 'Some water soaks into soil and replenishes groundwater.',
          hi: 'कुछ जल मिट्टी में रिसकर भूजल को फिर से भरता है।',
          or: 'କିଛି ଜଳ ମାଟିରେ ଶୋଷି ହୋଇ ଭୂତଳ ଜଳକୁ ପୁନଃ ପୂରଣ କରେ।',
        ),
        position: Offset(0.84, 0.72),
      ),
      InteractiveDiagramLabel(
        id: 'collection',
        title: DiagramText(en: 'Collection', hi: 'संचयन', or: 'ସଂଗ୍ରହ'),
        explanation: DiagramText(
          en: 'Water gathers in oceans, lakes and rivers before the cycle repeats.',
          hi: 'चक्र दोहरने से पहले जल महासागरों, झीलों और नदियों में इकट्ठा होता है।',
          or: 'ଚକ୍ର ପୁଣି ଆରମ୍ଭ ହେବା ପୂର୍ବରୁ ଜଳ ସମୁଦ୍ର, ହ୍ରଦ ଓ ନଦୀରେ ସଂଗ୍ରହ ହୁଏ।',
        ),
        position: Offset(0.29, 0.72),
      ),
      InteractiveDiagramLabel(
        id: 'transpiration',
        title: DiagramText(
          en: 'Transpiration',
          hi: 'वाष्पोत्सर्जन',
          or: 'ବାଷ୍ପୋତ୍ସର୍ଜନ',
        ),
        explanation: DiagramText(
          en: 'Plants release water vapour from their leaves into the air.',
          hi: 'पौधे अपनी पत्तियों से जलवाष्प वायु में छोड़ते हैं।',
          or: 'ଉଦ୍ଭିଦ ପତ୍ରରୁ ଜଳୀୟ ବାଷ୍ପ ବାୟୁକୁ ଛାଡ଼େ।',
        ),
        position: Offset(0.90, 0.47),
      ),
    ],
  ),
];
