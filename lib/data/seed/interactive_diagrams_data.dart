import 'package:flutter/material.dart';

part 'interactive_diagrams_remaining_data.dart';

enum DiagramLanguage { english, hindi, odia }

enum DiagramSection { biology, geography, science, math }

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
  final DiagramSection section;
  final DiagramText title;
  final DiagramText description;
  final String imagePath;
  final double aspectRatio;
  final List<InteractiveDiagramLabel> labels;

  const InteractiveDiagram({
    required this.id,
    required this.section,
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
    section: DiagramSection.biology,
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
    id: 'plant_cell',
    section: DiagramSection.biology,
    title: DiagramText(en: 'Plant Cell', hi: 'पादप कोशिका', or: 'ଉଦ୍ଭିଦ କୋଷ'),
    description: DiagramText(
      en: 'Explore the main structures of a plant cell.',
      hi: 'पादप कोशिका की मुख्य संरचनाओं को जानें।',
      or: 'ଉଦ୍ଭିଦ କୋଷର ମୁଖ୍ୟ ଗଠନଗୁଡ଼ିକୁ ଜାଣନ୍ତୁ।',
    ),
    imagePath: 'assets/diagrams/interactive/plant_cell.png',
    aspectRatio: 1,
    labels: [
      InteractiveDiagramLabel(
        id: 'cell_wall',
        title: DiagramText(
          en: 'Cell wall',
          hi: 'कोशिका भित्ति',
          or: 'କୋଷ ପ୍ରାଚୀର',
        ),
        explanation: DiagramText(
          en: 'A strong outer layer that supports, protects and gives shape to the cell.',
          hi: 'मजबूत बाहरी परत जो कोशिका को सहारा, सुरक्षा और आकार देती है।',
          or: 'ଦୃଢ଼ ବାହ୍ୟ ସ୍ତର ଯାହା କୋଷକୁ ଆଧାର, ସୁରକ୍ଷା ଓ ଆକାର ଦିଏ।',
        ),
        position: Offset(0.08, 0.50),
      ),
      InteractiveDiagramLabel(
        id: 'membrane',
        title: DiagramText(
          en: 'Cell membrane',
          hi: 'कोशिका झिल्ली',
          or: 'କୋଷ ଝିଲ୍ଲୀ',
        ),
        explanation: DiagramText(
          en: 'A thin boundary that controls what enters and leaves the cell.',
          hi: 'पतली सीमा जो कोशिका में पदार्थों के आने और बाहर जाने को नियंत्रित करती है।',
          or: 'ପତଳା ସୀମା ଯାହା କୋଷ ଭିତରକୁ ଓ ବାହାରକୁ ପଦାର୍ଥର ଯାତାୟାତ ନିୟନ୍ତ୍ରଣ କରେ।',
        ),
        position: Offset(0.17, 0.50),
      ),
      InteractiveDiagramLabel(
        id: 'chloroplast',
        title: DiagramText(en: 'Chloroplast', hi: 'हरितलवक', or: 'ହରିତଲବକ'),
        explanation: DiagramText(
          en: 'Contains chlorophyll and captures sunlight to make food by photosynthesis.',
          hi: 'इसमें पर्णहरित होता है और यह प्रकाश संश्लेषण द्वारा भोजन बनाने के लिए सूर्य का प्रकाश ग्रहण करता है।',
          or: 'ଏଥିରେ କ୍ଲୋରୋଫିଲ୍ ଥାଏ ଏବଂ ଆଲୋକ ସଂଶ୍ଳେଷଣ ଦ୍ୱାରା ଖାଦ୍ୟ ତିଆରି ପାଇଁ ସୂର୍ଯ୍ୟାଲୋକ ଗ୍ରହଣ କରେ।',
        ),
        position: Offset(0.26, 0.19),
      ),
      InteractiveDiagramLabel(
        id: 'vacuole',
        title: DiagramText(
          en: 'Central vacuole',
          hi: 'केंद्रीय रिक्तिका',
          or: 'କେନ୍ଦ୍ରୀୟ ରସଧାନୀ',
        ),
        explanation: DiagramText(
          en: 'A large fluid-filled sac that stores water and helps keep the cell firm.',
          hi: 'तरल से भरी बड़ी थैली जो जल का भंडारण करती है और कोशिका को दृढ़ रखने में मदद करती है।',
          or: 'ତରଳଭରା ବଡ଼ ଥଳି ଯାହା ଜଳ ସଞ୍ଚୟ କରେ ଓ କୋଷକୁ ଦୃଢ଼ ରଖିବାରେ ସାହାଯ୍ୟ କରେ।',
        ),
        position: Offset(0.50, 0.56),
      ),
      InteractiveDiagramLabel(
        id: 'nucleus',
        title: DiagramText(en: 'Nucleus', hi: 'केंद्रक', or: 'କେନ୍ଦ୍ରକ'),
        explanation: DiagramText(
          en: 'The control centre of the cell. It contains the genetic material.',
          hi: 'कोशिका का नियंत्रण केंद्र। इसमें आनुवंशिक पदार्थ होता है।',
          or: 'କୋଷର ନିୟନ୍ତ୍ରଣ କେନ୍ଦ୍ର। ଏଥିରେ ଆନୁବଂଶିକ ପଦାର୍ଥ ରହିଥାଏ।',
        ),
        position: Offset(0.75, 0.24),
      ),
      InteractiveDiagramLabel(
        id: 'cytoplasm',
        title: DiagramText(
          en: 'Cytoplasm',
          hi: 'कोशिकाद्रव्य',
          or: 'କୋଷଦ୍ରବ୍ୟ',
        ),
        explanation: DiagramText(
          en: 'A jelly-like material in which the cell structures are suspended.',
          hi: 'जेली जैसा पदार्थ जिसमें कोशिका की संरचनाएँ स्थित रहती हैं।',
          or: 'ଜେଲି ପରି ପଦାର୍ଥ ଯେଉଁଥିରେ କୋଷର ଗଠନଗୁଡ଼ିକ ରହିଥାଏ।',
        ),
        position: Offset(0.55, 0.15),
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
        position: Offset(0.82, 0.57),
      ),
    ],
  ),
  InteractiveDiagram(
    id: 'flower_parts',
    section: DiagramSection.biology,
    title: DiagramText(
      en: 'Parts of a Flower',
      hi: 'फूल के भाग',
      or: 'ଫୁଲର ଅଂଶ',
    ),
    description: DiagramText(
      en: 'Explore the reproductive and protective parts of a flower.',
      hi: 'फूल के प्रजनन और सुरक्षात्मक भागों को जानें।',
      or: 'ଫୁଲର ପ୍ରଜନନ ଓ ସୁରକ୍ଷାକାରୀ ଅଂଶଗୁଡ଼ିକୁ ଜାଣନ୍ତୁ।',
    ),
    imagePath: 'assets/diagrams/interactive/flower_parts.png',
    aspectRatio: 1,
    labels: [
      InteractiveDiagramLabel(
        id: 'petal',
        title: DiagramText(en: 'Petal', hi: 'पंखुड़ी', or: 'ପାଖୁଡ଼ା'),
        explanation: DiagramText(
          en: 'A colourful leaf-like part that attracts pollinators.',
          hi: 'रंगीन पत्ती जैसा भाग जो परागणकर्ताओं को आकर्षित करता है।',
          or: 'ରଙ୍ଗିନ ପତ୍ର ପରି ଅଂଶ ଯାହା ପରାଗବାହୀଙ୍କୁ ଆକର୍ଷିତ କରେ।',
        ),
        position: Offset(0.18, 0.35),
      ),
      InteractiveDiagramLabel(
        id: 'sepal',
        title: DiagramText(en: 'Sepal', hi: 'बाह्यदल', or: 'ବୃତ୍ତିପତ୍ର'),
        explanation: DiagramText(
          en: 'A green outer part that protects the flower while it is a bud.',
          hi: 'हरा बाहरी भाग जो कली की अवस्था में फूल की रक्षा करता है।',
          or: 'ସବୁଜ ବାହ୍ୟ ଅଂଶ ଯାହା କଢ଼ ଅବସ୍ଥାରେ ଫୁଲକୁ ସୁରକ୍ଷା କରେ।',
        ),
        position: Offset(0.77, 0.72),
      ),
      InteractiveDiagramLabel(
        id: 'stamen',
        title: DiagramText(en: 'Stamen', hi: 'पुंकेसर', or: 'ପୁଂକେଶର'),
        explanation: DiagramText(
          en: 'The male reproductive part, made of an anther and a filament.',
          hi: 'नर प्रजनन भाग, जो परागकोष और तंतु से बना होता है।',
          or: 'ପୁରୁଷ ପ୍ରଜନନ ଅଂଶ, ଯାହା ପରାଗଧାନୀ ଓ ପୁଂକେଶର ଦଣ୍ଡରୁ ଗଠିତ।',
        ),
        position: Offset(0.70, 0.38),
      ),
      InteractiveDiagramLabel(
        id: 'anther',
        title: DiagramText(en: 'Anther', hi: 'परागकोष', or: 'ପରାଗଧାନୀ'),
        explanation: DiagramText(
          en: 'The pollen-producing tip of a stamen.',
          hi: 'पुंकेसर का सिरा जहाँ परागकण बनते हैं।',
          or: 'ପୁଂକେଶରର ଶୀର୍ଷ ଅଂଶ ଯେଉଁଠାରେ ପରାଗରେଣୁ ତିଆରି ହୁଏ।',
        ),
        position: Offset(0.70, 0.24),
      ),
      InteractiveDiagramLabel(
        id: 'filament',
        title: DiagramText(en: 'Filament', hi: 'पुंतंतु', or: 'ପୁଂକେଶର ଦଣ୍ଡ'),
        explanation: DiagramText(
          en: 'A slender stalk that holds up the anther.',
          hi: 'पतला डंठल जो परागकोष को सहारा देता है।',
          or: 'ପତଳା ଦଣ୍ଡ ଯାହା ପରାଗଧାନୀକୁ ଧରି ରଖେ।',
        ),
        position: Offset(0.66, 0.47),
      ),
      InteractiveDiagramLabel(
        id: 'pistil',
        title: DiagramText(en: 'Pistil', hi: 'स्त्रीकेसर', or: 'ସ୍ତ୍ରୀକେଶର'),
        explanation: DiagramText(
          en: 'The female reproductive part, formed by the stigma, style and ovary.',
          hi: 'मादा प्रजनन भाग, जो वर्तिकाग्र, वर्तिका और अंडाशय से बना होता है।',
          or: 'ସ୍ତ୍ରୀ ପ୍ରଜନନ ଅଂଶ, ଯାହା ଗର୍ଭମୁଣ୍ଡ, ଗର୍ଭଦଣ୍ଡ ଓ ଡିମ୍ବାଶୟରୁ ଗଠିତ।',
        ),
        position: Offset(0.50, 0.42),
      ),
      InteractiveDiagramLabel(
        id: 'stigma',
        title: DiagramText(en: 'Stigma', hi: 'वर्तिकाग्र', or: 'ଗର୍ଭମୁଣ୍ଡ'),
        explanation: DiagramText(
          en: 'The sticky tip of the pistil that receives pollen.',
          hi: 'स्त्रीकेसर का चिपचिपा सिरा जो परागकण ग्रहण करता है।',
          or: 'ସ୍ତ୍ରୀକେଶରର ଅଠାଳିଆ ଶୀର୍ଷ ଯାହା ପରାଗରେଣୁ ଗ୍ରହଣ କରେ।',
        ),
        position: Offset(0.50, 0.15),
      ),
      InteractiveDiagramLabel(
        id: 'style',
        title: DiagramText(en: 'Style', hi: 'वर्तिका', or: 'ଗର୍ଭଦଣ୍ଡ'),
        explanation: DiagramText(
          en: 'The narrow stalk joining the stigma to the ovary.',
          hi: 'पतला भाग जो वर्तिकाग्र को अंडाशय से जोड़ता है।',
          or: 'ପତଳା ଦଣ୍ଡ ଯାହା ଗର୍ଭମୁଣ୍ଡକୁ ଡିମ୍ବାଶୟ ସହ ଯୋଡ଼େ।',
        ),
        position: Offset(0.50, 0.37),
      ),
      InteractiveDiagramLabel(
        id: 'ovary',
        title: DiagramText(en: 'Ovary', hi: 'अंडाशय', or: 'ଡିମ୍ବାଶୟ'),
        explanation: DiagramText(
          en: 'The swollen base of the pistil that contains ovules.',
          hi: 'स्त्रीकेसर का फूला हुआ आधार जिसमें बीजांड होते हैं।',
          or: 'ସ୍ତ୍ରୀକେଶରର ଫୁଲିଥିବା ତଳ ଅଂଶ ଯେଉଁଥିରେ ଡିମ୍ବକ ଥାଏ।',
        ),
        position: Offset(0.50, 0.66),
      ),
    ],
  ),
  InteractiveDiagram(
    id: 'leaf_structure',
    section: DiagramSection.biology,
    title: DiagramText(
      en: 'Structure of a Leaf',
      hi: 'पत्ती की संरचना',
      or: 'ପତ୍ରର ଗଠନ',
    ),
    description: DiagramText(
      en: 'Explore the external parts of a leaf and its stomata.',
      hi: 'पत्ती के बाहरी भागों और रंध्रों को जानें।',
      or: 'ପତ୍ରର ବାହ୍ୟ ଅଂଶ ଓ ପତ୍ରରନ୍ଧ୍ରକୁ ଜାଣନ୍ତୁ।',
    ),
    imagePath: 'assets/diagrams/interactive/leaf_structure.png',
    aspectRatio: 1.5,
    labels: [
      InteractiveDiagramLabel(
        id: 'blade',
        title: DiagramText(en: 'Leaf blade', hi: 'पर्णफलक', or: 'ପତ୍ରଫଳକ'),
        explanation: DiagramText(
          en: 'The broad, flat part that captures sunlight for photosynthesis.',
          hi: 'चौड़ा, चपटा भाग जो प्रकाश संश्लेषण के लिए सूर्य का प्रकाश ग्रहण करता है।',
          or: 'ଚଉଡ଼ା ଓ ଚେପଟା ଅଂଶ ଯାହା ଆଲୋକ ସଂଶ୍ଳେଷଣ ପାଇଁ ସୂର୍ଯ୍ୟାଲୋକ ଗ୍ରହଣ କରେ।',
        ),
        position: Offset(0.55, 0.26),
      ),
      InteractiveDiagramLabel(
        id: 'midrib',
        title: DiagramText(en: 'Midrib', hi: 'मध्यशिरा', or: 'ମଧ୍ୟଶିରା'),
        explanation: DiagramText(
          en: 'The main central vein that supports the blade and carries materials.',
          hi: 'मुख्य केंद्रीय शिरा जो पर्णफलक को सहारा देती है और पदार्थ पहुँचाती है।',
          or: 'ମୁଖ୍ୟ କେନ୍ଦ୍ରୀୟ ଶିରା ଯାହା ପତ୍ରଫଳକକୁ ଆଧାର ଦିଏ ଓ ପଦାର୍ଥ ପରିବହନ କରେ।',
        ),
        position: Offset(0.46, 0.48),
      ),
      InteractiveDiagramLabel(
        id: 'veins',
        title: DiagramText(en: 'Veins', hi: 'शिराएँ', or: 'ଶିରା'),
        explanation: DiagramText(
          en: 'Branching tubes that carry water and food through the leaf.',
          hi: 'शाखित नलिकाएँ जो पत्ती में जल और भोजन पहुँचाती हैं।',
          or: 'ଶାଖାଯୁକ୍ତ ନଳୀ ଯାହା ପତ୍ରରେ ଜଳ ଓ ଖାଦ୍ୟ ପରିବହନ କରେ।',
        ),
        position: Offset(0.67, 0.31),
      ),
      InteractiveDiagramLabel(
        id: 'petiole',
        title: DiagramText(en: 'Petiole', hi: 'पर्णवृंत', or: 'ପତ୍ରବୃନ୍ତ'),
        explanation: DiagramText(
          en: 'The stalk that attaches the leaf blade to the stem.',
          hi: 'डंठल जो पर्णफलक को तने से जोड़ता है।',
          or: 'ଡେମ୍ଫ ଯାହା ପତ୍ରଫଳକକୁ କାଣ୍ଡ ସହ ଯୋଡ଼େ।',
        ),
        position: Offset(0.13, 0.76),
      ),
      InteractiveDiagramLabel(
        id: 'stomata',
        title: DiagramText(en: 'Stomata', hi: 'रंध्र', or: 'ପତ୍ରରନ୍ଧ୍ର'),
        explanation: DiagramText(
          en: 'Tiny pores controlled by guard cells that exchange gases and release water vapour.',
          hi: 'रक्षक कोशिकाओं द्वारा नियंत्रित छोटे छिद्र जो गैसों का आदान-प्रदान करते हैं और जलवाष्प छोड़ते हैं।',
          or: 'ରକ୍ଷୀକୋଷ ଦ୍ୱାରା ନିୟନ୍ତ୍ରିତ କ୍ଷୁଦ୍ର ରନ୍ଧ୍ର ଯାହା ଗ୍ୟାସ୍ ବିନିମୟ କରେ ଓ ଜଳୀୟ ବାଷ୍ପ ଛାଡ଼େ।',
        ),
        position: Offset(0.85, 0.68),
      ),
    ],
  ),
  InteractiveDiagram(
    id: 'human_eye',
    section: DiagramSection.biology,
    title: DiagramText(en: 'Human Eye', hi: 'मानव नेत्र', or: 'ମାନବ ଚକ୍ଷୁ'),
    description: DiagramText(
      en: 'Follow light through the main structures of the human eye.',
      hi: 'मानव नेत्र की मुख्य संरचनाओं से होकर प्रकाश की यात्रा को समझें।',
      or: 'ମାନବ ଚକ୍ଷୁର ମୁଖ୍ୟ ଗଠନ ମଧ୍ୟରେ ଆଲୋକର ଯାତ୍ରାକୁ ବୁଝନ୍ତୁ।',
    ),
    imagePath: 'assets/diagrams/interactive/human_eye.png',
    aspectRatio: 1.5,
    labels: [
      InteractiveDiagramLabel(
        id: 'cornea',
        title: DiagramText(en: 'Cornea', hi: 'कॉर्निया', or: 'କର୍ଣ୍ଣିଆ'),
        explanation: DiagramText(
          en: 'The clear curved front surface that begins to focus incoming light.',
          hi: 'पारदर्शी घुमावदार सामने की सतह जो आने वाले प्रकाश को केंद्रित करना शुरू करती है।',
          or: 'ସ୍ୱଚ୍ଛ ବକ୍ର ସାମ୍ନା ସ୍ତର ଯାହା ଆସୁଥିବା ଆଲୋକକୁ କେନ୍ଦ୍ରିତ କରିବା ଆରମ୍ଭ କରେ।',
        ),
        position: Offset(0.13, 0.48),
      ),
      InteractiveDiagramLabel(
        id: 'iris',
        title: DiagramText(en: 'Iris', hi: 'परितारिका', or: 'କନୀନିକା'),
        explanation: DiagramText(
          en: 'The coloured ring that changes pupil size to control how much light enters.',
          hi: 'रंगीन वलय जो पुतली का आकार बदलकर प्रवेश करने वाले प्रकाश की मात्रा नियंत्रित करता है।',
          or: 'ରଙ୍ଗିନ ବଳୟ ଯାହା କନୀନିକାର ଆକାର ବଦଳାଇ ଆଲୋକର ପରିମାଣ ନିୟନ୍ତ୍ରଣ କରେ।',
        ),
        position: Offset(0.23, 0.38),
      ),
      InteractiveDiagramLabel(
        id: 'pupil',
        title: DiagramText(en: 'Pupil', hi: 'पुतली', or: 'ଚକ୍ଷୁତାରା'),
        explanation: DiagramText(
          en: 'The opening in the centre of the iris through which light enters.',
          hi: 'परितारिका के केंद्र का छिद्र जिससे प्रकाश प्रवेश करता है।',
          or: 'କନୀନିକାର ମଝିରେ ଥିବା ରନ୍ଧ୍ର ଯାହା ଦେଇ ଆଲୋକ ପ୍ରବେଶ କରେ।',
        ),
        position: Offset(0.22, 0.49),
      ),
      InteractiveDiagramLabel(
        id: 'lens',
        title: DiagramText(en: 'Lens', hi: 'नेत्र लेंस', or: 'ଚକ୍ଷୁ ଲେନ୍ସ'),
        explanation: DiagramText(
          en: 'A flexible transparent structure that focuses light onto the retina.',
          hi: 'लचीली पारदर्शी संरचना जो प्रकाश को रेटिना पर केंद्रित करती है।',
          or: 'ନମନୀୟ ସ୍ୱଚ୍ଛ ଗଠନ ଯାହା ଆଲୋକକୁ ଦୃଷ୍ଟିପଟଳ ଉପରେ କେନ୍ଦ୍ରିତ କରେ।',
        ),
        position: Offset(0.35, 0.49),
      ),
      InteractiveDiagramLabel(
        id: 'retina',
        title: DiagramText(en: 'Retina', hi: 'दृष्टिपटल', or: 'ଦୃଷ୍ଟିପଟଳ'),
        explanation: DiagramText(
          en: 'A light-sensitive layer that changes light into nerve signals.',
          hi: 'प्रकाश-संवेदी परत जो प्रकाश को तंत्रिका संकेतों में बदलती है।',
          or: 'ଆଲୋକ-ସମ୍ବେଦନଶୀଳ ସ୍ତର ଯାହା ଆଲୋକକୁ ସ୍ନାୟୁ ସଙ୍କେତରେ ପରିଣତ କରେ।',
        ),
        position: Offset(0.69, 0.20),
      ),
      InteractiveDiagramLabel(
        id: 'optic_nerve',
        title: DiagramText(
          en: 'Optic nerve',
          hi: 'दृष्टि तंत्रिका',
          or: 'ଦୃଷ୍ଟି ସ୍ନାୟୁ',
        ),
        explanation: DiagramText(
          en: 'Carries visual signals from the retina to the brain.',
          hi: 'दृष्टिपटल से दृश्य संकेतों को मस्तिष्क तक पहुँचाती है।',
          or: 'ଦୃଷ୍ଟିପଟଳରୁ ଦୃଶ୍ୟ ସଙ୍କେତକୁ ମସ୍ତିଷ୍କକୁ ବହନ କରେ।',
        ),
        position: Offset(0.88, 0.49),
      ),
    ],
  ),
  InteractiveDiagram(
    id: 'respiratory_system',
    section: DiagramSection.biology,
    title: DiagramText(
      en: 'Respiratory System',
      hi: 'श्वसन तंत्र',
      or: 'ଶ୍ୱସନ ତନ୍ତ୍ର',
    ),
    description: DiagramText(
      en: 'Trace the path of air through the human respiratory system.',
      hi: 'मानव श्वसन तंत्र में वायु के मार्ग को समझें।',
      or: 'ମାନବ ଶ୍ୱସନ ତନ୍ତ୍ରରେ ବାୟୁର ଗତିପଥକୁ ବୁଝନ୍ତୁ।',
    ),
    imagePath: 'assets/diagrams/interactive/respiratory_system.png',
    aspectRatio: 2 / 3,
    labels: [
      InteractiveDiagramLabel(
        id: 'nose',
        title: DiagramText(en: 'Nose', hi: 'नाक', or: 'ନାକ'),
        explanation: DiagramText(
          en: 'Filters, warms and moistens air as it enters the body.',
          hi: 'शरीर में प्रवेश करते समय वायु को छानती, गर्म और नम करती है।',
          or: 'ଶରୀରକୁ ପ୍ରବେଶ କରୁଥିବା ବାୟୁକୁ ଛାଣେ, ଉଷ୍ଣ ଓ ଆର୍ଦ୍ର କରେ।',
        ),
        position: Offset(0.42, 0.18),
      ),
      InteractiveDiagramLabel(
        id: 'trachea',
        title: DiagramText(en: 'Trachea', hi: 'श्वासनली', or: 'ଶ୍ୱାସନଳୀ'),
        explanation: DiagramText(
          en: 'A tube strengthened by cartilage rings that carries air toward the lungs.',
          hi: 'उपास्थि के छल्लों से मजबूत नली जो वायु को फेफड़ों की ओर ले जाती है।',
          or: 'ଉପାସ୍ଥି ବଳୟରେ ଦୃଢ଼ ହୋଇଥିବା ନଳୀ ଯାହା ବାୟୁକୁ ଫୁସ୍‌ଫୁସ୍‌କୁ ନେଇଯାଏ।',
        ),
        position: Offset(0.42, 0.37),
      ),
      InteractiveDiagramLabel(
        id: 'bronchi',
        title: DiagramText(en: 'Bronchi', hi: 'श्वसनी', or: 'ଶ୍ୱାସନଳିକା'),
        explanation: DiagramText(
          en: 'Two main branches that carry air from the trachea into the lungs.',
          hi: 'दो मुख्य शाखाएँ जो श्वासनली से वायु को फेफड़ों में ले जाती हैं।',
          or: 'ଦୁଇଟି ମୁଖ୍ୟ ଶାଖା ଯାହା ଶ୍ୱାସନଳୀରୁ ବାୟୁକୁ ଫୁସ୍‌ଫୁସ୍‌ ଭିତରକୁ ନେଇଯାଏ।',
        ),
        position: Offset(0.48, 0.49),
      ),
      InteractiveDiagramLabel(
        id: 'lungs',
        title: DiagramText(en: 'Lungs', hi: 'फेफड़े', or: 'ଫୁସ୍‌ଫୁସ୍‌'),
        explanation: DiagramText(
          en: 'A pair of spongy organs where oxygen enters the blood and carbon dioxide leaves it.',
          hi: 'स्पंजी अंगों की जोड़ी जहाँ ऑक्सीजन रक्त में जाती है और कार्बन डाइऑक्साइड बाहर निकलती है।',
          or: 'ସ୍ପଞ୍ଜ ପରି ଦୁଇଟି ଅଙ୍ଗ ଯେଉଁଠାରେ ଅମ୍ଳଜାନ ରକ୍ତକୁ ଯାଏ ଓ ଅଙ୍ଗାରକାମ୍ଳ ବାହାରେ।',
        ),
        position: Offset(0.27, 0.61),
      ),
      InteractiveDiagramLabel(
        id: 'alveoli',
        title: DiagramText(en: 'Alveoli', hi: 'वायुकोष', or: 'ବାୟୁକୋଷ'),
        explanation: DiagramText(
          en: 'Tiny air sacs where oxygen and carbon dioxide are exchanged with the blood.',
          hi: 'छोटे वायुकोष जहाँ रक्त के साथ ऑक्सीजन और कार्बन डाइऑक्साइड का आदान-प्रदान होता है।',
          or: 'କ୍ଷୁଦ୍ର ବାୟୁଥଳି ଯେଉଁଠାରେ ରକ୍ତ ସହ ଅମ୍ଳଜାନ ଓ ଅଙ୍ଗାରକାମ୍ଳର ବିନିମୟ ହୁଏ।',
        ),
        position: Offset(0.81, 0.29),
      ),
      InteractiveDiagramLabel(
        id: 'diaphragm',
        title: DiagramText(en: 'Diaphragm', hi: 'डायाफ्राम', or: 'ମଧ୍ୟଚ୍ଛଦା'),
        explanation: DiagramText(
          en: 'A dome-shaped muscle that changes chest volume to move air in and out.',
          hi: 'गुंबदाकार पेशी जो छाती का आयतन बदलकर वायु को अंदर और बाहर करती है।',
          or: 'ଗମ୍ବୁଜ ଆକାରର ପେଶୀ ଯାହା ବକ୍ଷଗହ୍ୱରର ଆୟତନ ବଦଳାଇ ବାୟୁକୁ ଭିତରକୁ ଓ ବାହାରକୁ ଚଳାଏ।',
        ),
        position: Offset(0.47, 0.78),
      ),
    ],
  ),
  InteractiveDiagram(
    id: 'water_cycle',
    section: DiagramSection.science,
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
  InteractiveDiagram(
    id: 'food_chain',
    section: DiagramSection.biology,
    title: DiagramText(
      en: 'Food Chain',
      hi: 'खाद्य शृंखला',
      or: 'ଖାଦ୍ୟ ଶୃଙ୍ଖଳା',
    ),
    description: DiagramText(
      en: 'Follow energy as it moves from the Sun through living things.',
      hi: 'सूर्य से जीवों तक ऊर्जा के प्रवाह को समझें।',
      or: 'ସୂର୍ଯ୍ୟରୁ ଜୀବମାନଙ୍କ ମଧ୍ୟରେ ଶକ୍ତିର ପ୍ରବାହକୁ ବୁଝନ୍ତୁ।',
    ),
    imagePath: 'assets/diagrams/interactive/food_chain.png',
    aspectRatio: 2.6667,
    labels: [
      InteractiveDiagramLabel(
        id: 'sun',
        title: DiagramText(en: 'Sun', hi: 'सूर्य', or: 'ସୂର୍ଯ୍ୟ'),
        explanation: DiagramText(
          en: 'The original source of energy for this food chain.',
          hi: 'इस खाद्य शृंखला की ऊर्जा का मूल स्रोत।',
          or: 'ଏହି ଖାଦ୍ୟ ଶୃଙ୍ଖଳାର ଶକ୍ତିର ମୂଳ ଉତ୍ସ।',
        ),
        position: Offset(0.07, 0.18),
      ),
      InteractiveDiagramLabel(
        id: 'grass',
        title: DiagramText(en: 'Grass', hi: 'घास', or: 'ଘାସ'),
        explanation: DiagramText(
          en: 'A producer that makes food using sunlight.',
          hi: 'एक उत्पादक जो सूर्य के प्रकाश से भोजन बनाता है।',
          or: 'ସୂର୍ଯ୍ୟାଲୋକ ବ୍ୟବହାର କରି ଖାଦ୍ୟ ତିଆରି କରୁଥିବା ଉତ୍ପାଦକ।',
        ),
        position: Offset(0.12, 0.72),
      ),
      InteractiveDiagramLabel(
        id: 'grasshopper',
        title: DiagramText(en: 'Grasshopper', hi: 'टिड्डा', or: 'ଝିଣ୍ଟିକା'),
        explanation: DiagramText(
          en: 'A primary consumer that eats the grass.',
          hi: 'एक प्राथमिक उपभोक्ता जो घास खाता है।',
          or: 'ଘାସ ଖାଉଥିବା ଏକ ପ୍ରାଥମିକ ଉପଭୋକ୍ତା।',
        ),
        position: Offset(0.34, 0.68),
      ),
      InteractiveDiagramLabel(
        id: 'frog',
        title: DiagramText(en: 'Frog', hi: 'मेंढक', or: 'ବେଙ୍ଗ'),
        explanation: DiagramText(
          en: 'A secondary consumer that eats the grasshopper.',
          hi: 'एक द्वितीयक उपभोक्ता जो टिड्डे को खाता है।',
          or: 'ଝିଣ୍ଟିକାକୁ ଖାଉଥିବା ଏକ ଦ୍ୱିତୀୟ ଉପଭୋକ୍ତା।',
        ),
        position: Offset(0.53, 0.68),
      ),
      InteractiveDiagramLabel(
        id: 'snake',
        title: DiagramText(en: 'Snake', hi: 'साँप', or: 'ସାପ'),
        explanation: DiagramText(
          en: 'A higher-level consumer that eats the frog.',
          hi: 'एक उच्च-स्तरीय उपभोक्ता जो मेंढक को खाता है।',
          or: 'ବେଙ୍ଗକୁ ଖାଉଥିବା ଏକ ଉଚ୍ଚ ସ୍ତରର ଉପଭୋକ୍ତା।',
        ),
        position: Offset(0.72, 0.66),
      ),
      InteractiveDiagramLabel(
        id: 'eagle',
        title: DiagramText(en: 'Eagle', hi: 'गरुड़', or: 'ଚିଲ'),
        explanation: DiagramText(
          en: 'The top consumer in this example food chain.',
          hi: 'इस उदाहरण खाद्य शृंखला का शीर्ष उपभोक्ता।',
          or: 'ଏହି ଉଦାହରଣ ଖାଦ୍ୟ ଶୃଙ୍ଖଳାର ଶୀର୍ଷ ଉପଭୋକ୍ତା।',
        ),
        position: Offset(0.91, 0.33),
      ),
    ],
  ),
  InteractiveDiagram(
    id: 'human_digestive_system',
    section: DiagramSection.biology,
    title: DiagramText(
      en: 'Human Digestive System',
      hi: 'मानव पाचन तंत्र',
      or: 'ମାନବ ପାଚନ ତନ୍ତ୍ର',
    ),
    description: DiagramText(
      en: 'Explore how food travels through the digestive system.',
      hi: 'जानें कि भोजन पाचन तंत्र से कैसे गुजरता है।',
      or: 'ଖାଦ୍ୟ ପାଚନ ତନ୍ତ୍ର ମଧ୍ୟରେ କିପରି ଯାଏ ତାହା ଜାଣନ୍ତୁ।',
    ),
    imagePath: 'assets/diagrams/interactive/human_digestive_system.png',
    aspectRatio: 0.6667,
    labels: [
      InteractiveDiagramLabel(
        id: 'mouth',
        title: DiagramText(en: 'Mouth', hi: 'मुँह', or: 'ମୁଖ'),
        explanation: DiagramText(
          en: 'Teeth and saliva begin breaking food into smaller pieces.',
          hi: 'दाँत और लार भोजन को छोटे भागों में तोड़ना शुरू करते हैं।',
          or: 'ଦାନ୍ତ ଓ ଲାଳ ଖାଦ୍ୟକୁ ଛୋଟ ଅଂଶରେ ଭାଙ୍ଗିବା ଆରମ୍ଭ କରେ।',
        ),
        position: Offset(0.42, 0.09),
      ),
      InteractiveDiagramLabel(
        id: 'oesophagus',
        title: DiagramText(en: 'Oesophagus', hi: 'ग्रासनली', or: 'ଗ୍ରାସନଳୀ'),
        explanation: DiagramText(
          en: 'A muscular tube that carries swallowed food to the stomach.',
          hi: 'एक पेशीय नली जो निगले हुए भोजन को आमाशय तक ले जाती है।',
          or: 'ଗିଳିଥିବା ଖାଦ୍ୟକୁ ପାକସ୍ଥଳୀକୁ ନେଉଥିବା ଏକ ପେଶୀମୟ ନଳୀ।',
        ),
        position: Offset(0.50, 0.28),
      ),
      InteractiveDiagramLabel(
        id: 'liver',
        title: DiagramText(en: 'Liver', hi: 'यकृत', or: 'ଯକୃତ'),
        explanation: DiagramText(
          en: 'Produces bile, which helps the body digest fats.',
          hi: 'पित्त बनाता है, जो शरीर को वसा पचाने में मदद करता है।',
          or: 'ପିତ୍ତ ତିଆରି କରେ, ଯାହା ଚର୍ବି ପାଚନରେ ସାହାଯ୍ୟ କରେ।',
        ),
        position: Offset(0.39, 0.45),
      ),
      InteractiveDiagramLabel(
        id: 'stomach',
        title: DiagramText(en: 'Stomach', hi: 'आमाशय', or: 'ପାକସ୍ଥଳୀ'),
        explanation: DiagramText(
          en: 'Churns food and mixes it with digestive juices.',
          hi: 'भोजन को मथकर पाचक रसों के साथ मिलाता है।',
          or: 'ଖାଦ୍ୟକୁ ଘାଣ୍ଟି ପାଚକ ରସ ସହିତ ମିଶାଏ।',
        ),
        position: Offset(0.62, 0.47),
      ),
      InteractiveDiagramLabel(
        id: 'pancreas',
        title: DiagramText(en: 'Pancreas', hi: 'अग्न्याशय', or: 'ଅଗ୍ନ୍ୟାଶୟ'),
        explanation: DiagramText(
          en: 'Releases enzymes that help digest carbohydrates, proteins and fats.',
          hi: 'कार्बोहाइड्रेट, प्रोटीन और वसा पचाने वाले एंजाइम छोड़ता है।',
          or: 'ଶର୍କରା, ପ୍ରୋଟିନ୍ ଓ ଚର୍ବି ପାଚନ ପାଇଁ ଏନ୍ଜାଇମ୍ ଛାଡ଼େ।',
        ),
        position: Offset(0.55, 0.53),
      ),
      InteractiveDiagramLabel(
        id: 'small_intestine',
        title: DiagramText(
          en: 'Small intestine',
          hi: 'छोटी आँत',
          or: 'କ୍ଷୁଦ୍ରାନ୍ତ୍ର',
        ),
        explanation: DiagramText(
          en: 'Completes most digestion and absorbs nutrients into the blood.',
          hi: 'अधिकांश पाचन पूरा करती है और पोषक तत्वों को रक्त में सोखती है।',
          or: 'ଅଧିକାଂଶ ପାଚନ ସମ୍ପୂର୍ଣ୍ଣ କରି ପୋଷକ ତତ୍ତ୍ୱକୁ ରକ୍ତରେ ଶୋଷେ।',
        ),
        position: Offset(0.51, 0.66),
      ),
      InteractiveDiagramLabel(
        id: 'large_intestine',
        title: DiagramText(
          en: 'Large intestine',
          hi: 'बड़ी आँत',
          or: 'ବୃହଦନ୍ତ୍ର',
        ),
        explanation: DiagramText(
          en: 'Absorbs water and forms the remaining waste.',
          hi: 'जल सोखती है और बचे हुए अपशिष्ट का निर्माण करती है।',
          or: 'ଜଳ ଶୋଷି ଅବଶିଷ୍ଟ ବର୍ଜ୍ୟ ପଦାର୍ଥ ତିଆରି କରେ।',
        ),
        position: Offset(0.70, 0.68),
      ),
      InteractiveDiagramLabel(
        id: 'rectum',
        title: DiagramText(en: 'Rectum', hi: 'मलाशय', or: 'ମଳାଶୟ'),
        explanation: DiagramText(
          en: 'Stores solid waste before it leaves the body.',
          hi: 'शरीर से बाहर निकलने से पहले ठोस अपशिष्ट को जमा रखता है।',
          or: 'ଶରୀରରୁ ବାହାରିବା ପୂର୍ବରୁ ଘନ ବର୍ଜ୍ୟକୁ ସଞ୍ଚୟ କରେ।',
        ),
        position: Offset(0.51, 0.82),
      ),
    ],
  ),
  InteractiveDiagram(
    id: 'human_heart',
    section: DiagramSection.biology,
    title: DiagramText(
      en: 'Human Heart',
      hi: 'मानव हृदय',
      or: 'ମାନବ ହୃତ୍‌ପିଣ୍ଡ',
    ),
    description: DiagramText(
      en: 'Explore the chambers and major blood vessels of the heart.',
      hi: 'हृदय के कक्षों और प्रमुख रक्त वाहिकाओं को जानें।',
      or: 'ହୃତ୍‌ପିଣ୍ଡର ପ୍ରକୋଷ୍ଠ ଓ ମୁଖ୍ୟ ରକ୍ତନଳୀଗୁଡ଼ିକୁ ଜାଣନ୍ତୁ।',
    ),
    imagePath: 'assets/diagrams/interactive/human_heart.png',
    aspectRatio: 1,
    labels: [
      InteractiveDiagramLabel(
        id: 'right_atrium',
        title: DiagramText(
          en: 'Right atrium',
          hi: 'दायाँ अलिंद',
          or: 'ଦକ୍ଷିଣ ଅଳିନ୍ଦ',
        ),
        explanation: DiagramText(
          en: 'Receives oxygen-poor blood returning from the body.',
          hi: 'शरीर से लौटने वाले ऑक्सीजन-विहीन रक्त को ग्रहण करता है।',
          or: 'ଶରୀରରୁ ଫେରୁଥିବା ଅମ୍ଳଜାନହୀନ ରକ୍ତକୁ ଗ୍ରହଣ କରେ।',
        ),
        position: Offset(0.35, 0.38),
      ),
      InteractiveDiagramLabel(
        id: 'right_ventricle',
        title: DiagramText(
          en: 'Right ventricle',
          hi: 'दायाँ निलय',
          or: 'ଦକ୍ଷିଣ ନିଳୟ',
        ),
        explanation: DiagramText(
          en: 'Pumps oxygen-poor blood toward the lungs.',
          hi: 'ऑक्सीजन-विहीन रक्त को फेफड़ों की ओर पंप करता है।',
          or: 'ଅମ୍ଳଜାନହୀନ ରକ୍ତକୁ ଫୁସଫୁସ ଆଡ଼କୁ ପମ୍ପ କରେ।',
        ),
        position: Offset(0.38, 0.69),
      ),
      InteractiveDiagramLabel(
        id: 'left_atrium',
        title: DiagramText(
          en: 'Left atrium',
          hi: 'बायाँ अलिंद',
          or: 'ବାମ ଅଳିନ୍ଦ',
        ),
        explanation: DiagramText(
          en: 'Receives oxygen-rich blood returning from the lungs.',
          hi: 'फेफड़ों से लौटने वाले ऑक्सीजन-युक्त रक्त को ग्रहण करता है।',
          or: 'ଫୁସଫୁସରୁ ଫେରୁଥିବା ଅମ୍ଳଜାନଯୁକ୍ତ ରକ୍ତକୁ ଗ୍ରହଣ କରେ।',
        ),
        position: Offset(0.68, 0.39),
      ),
      InteractiveDiagramLabel(
        id: 'left_ventricle',
        title: DiagramText(
          en: 'Left ventricle',
          hi: 'बायाँ निलय',
          or: 'ବାମ ନିଳୟ',
        ),
        explanation: DiagramText(
          en: 'Pumps oxygen-rich blood to the rest of the body.',
          hi: 'ऑक्सीजन-युक्त रक्त को पूरे शरीर में पंप करता है।',
          or: 'ଅମ୍ଳଜାନଯୁକ୍ତ ରକ୍ତକୁ ସମଗ୍ର ଶରୀରକୁ ପମ୍ପ କରେ।',
        ),
        position: Offset(0.66, 0.70),
      ),
      InteractiveDiagramLabel(
        id: 'septum',
        title: DiagramText(en: 'Septum', hi: 'हृदयपट', or: 'ହୃଦପଟ'),
        explanation: DiagramText(
          en: 'The muscular wall separating the right and left sides.',
          hi: 'दाएँ और बाएँ भाग को अलग करने वाली पेशीय दीवार।',
          or: 'ଦକ୍ଷିଣ ଓ ବାମ ପାର୍ଶ୍ୱକୁ ଅଲଗା କରୁଥିବା ପେଶୀମୟ ପ୍ରାଚୀର।',
        ),
        position: Offset(0.53, 0.68),
      ),
      InteractiveDiagramLabel(
        id: 'aorta',
        title: DiagramText(en: 'Aorta', hi: 'महाधमनी', or: 'ମହାଧମନୀ'),
        explanation: DiagramText(
          en: 'The largest artery, carrying oxygen-rich blood to the body.',
          hi: 'सबसे बड़ी धमनी, जो ऑक्सीजन-युक्त रक्त को शरीर तक ले जाती है।',
          or: 'ସବୁଠାରୁ ବଡ଼ ଧମନୀ, ଯାହା ଅମ୍ଳଜାନଯୁକ୍ତ ରକ୍ତକୁ ଶରୀରକୁ ନେଏ।',
        ),
        position: Offset(0.56, 0.10),
      ),
      InteractiveDiagramLabel(
        id: 'pulmonary_artery',
        title: DiagramText(
          en: 'Pulmonary artery',
          hi: 'फुफ्फुसीय धमनी',
          or: 'ଫୁସଫୁସୀୟ ଧମନୀ',
        ),
        explanation: DiagramText(
          en: 'Carries oxygen-poor blood from the heart to the lungs.',
          hi: 'हृदय से ऑक्सीजन-विहीन रक्त को फेफड़ों तक ले जाती है।',
          or: 'ହୃତ୍‌ପିଣ୍ଡରୁ ଅମ୍ଳଜାନହୀନ ରକ୍ତକୁ ଫୁସଫୁସକୁ ନେଏ।',
        ),
        position: Offset(0.69, 0.22),
      ),
      InteractiveDiagramLabel(
        id: 'vena_cava',
        title: DiagramText(en: 'Vena cava', hi: 'महाशिरा', or: 'ମହାଶିରା'),
        explanation: DiagramText(
          en: 'Returns oxygen-poor blood from the body to the heart.',
          hi: 'शरीर से ऑक्सीजन-विहीन रक्त को हृदय तक वापस लाती है।',
          or: 'ଶରୀରରୁ ଅମ୍ଳଜାନହୀନ ରକ୍ତକୁ ହୃତ୍‌ପିଣ୍ଡକୁ ଫେରାଇ ଆଣେ।',
        ),
        position: Offset(0.29, 0.22),
      ),
    ],
  ),
  InteractiveDiagram(
    id: 'photosynthesis',
    section: DiagramSection.biology,
    title: DiagramText(
      en: 'Photosynthesis',
      hi: 'प्रकाश संश्लेषण',
      or: 'ଆଲୋକଶ୍ଳେଷଣ',
    ),
    description: DiagramText(
      en: 'See how plants use light, water and carbon dioxide to make food.',
      hi: 'देखें कि पौधे प्रकाश, जल और कार्बन डाइऑक्साइड से भोजन कैसे बनाते हैं।',
      or: 'ଉଦ୍ଭିଦ ଆଲୋକ, ଜଳ ଓ ଅଙ୍ଗାରକାମ୍ଳରୁ ଖାଦ୍ୟ କିପରି ତିଆରି କରେ ଦେଖନ୍ତୁ।',
    ),
    imagePath: 'assets/diagrams/interactive/photosynthesis.png',
    aspectRatio: 1.5,
    labels: [
      InteractiveDiagramLabel(
        id: 'sunlight',
        title: DiagramText(
          en: 'Sunlight',
          hi: 'सूर्य का प्रकाश',
          or: 'ସୂର୍ଯ୍ୟାଲୋକ',
        ),
        explanation: DiagramText(
          en: 'Provides the energy needed for photosynthesis.',
          hi: 'प्रकाश संश्लेषण के लिए आवश्यक ऊर्जा प्रदान करता है।',
          or: 'ଆଲୋକଶ୍ଳେଷଣ ପାଇଁ ଆବଶ୍ୟକ ଶକ୍ତି ଯୋଗାଏ।',
        ),
        position: Offset(0.13, 0.10),
      ),
      InteractiveDiagramLabel(
        id: 'carbon_dioxide',
        title: DiagramText(
          en: 'Carbon dioxide',
          hi: 'कार्बन डाइऑक्साइड',
          or: 'ଅଙ୍ଗାରକାମ୍ଳ',
        ),
        explanation: DiagramText(
          en: 'Enters the leaves from the surrounding air.',
          hi: 'आसपास की वायु से पत्तियों में प्रवेश करती है।',
          or: 'ଚାରିପାଖର ବାୟୁରୁ ପତ୍ର ଭିତରକୁ ପ୍ରବେଶ କରେ।',
        ),
        position: Offset(0.16, 0.30),
      ),
      InteractiveDiagramLabel(
        id: 'water',
        title: DiagramText(en: 'Water', hi: 'जल', or: 'ଜଳ'),
        explanation: DiagramText(
          en: 'Roots absorb water from the soil and carry it upward.',
          hi: 'जड़ें मिट्टी से जल सोखकर उसे ऊपर पहुँचाती हैं।',
          or: 'ମୂଳ ମାଟିରୁ ଜଳ ଶୋଷି ଉପରକୁ ପହଞ୍ଚାଏ।',
        ),
        position: Offset(0.40, 0.81),
      ),
      InteractiveDiagramLabel(
        id: 'chlorophyll',
        title: DiagramText(en: 'Chlorophyll', hi: 'क्लोरोफिल', or: 'ହରିତକଣା'),
        explanation: DiagramText(
          en: 'The green pigment in leaves that captures light energy.',
          hi: 'पत्तियों का हरा वर्णक जो प्रकाश ऊर्जा को ग्रहण करता है।',
          or: 'ପତ୍ରର ସବୁଜ ବର୍ଣ୍ଣକ ଯାହା ଆଲୋକ ଶକ୍ତିକୁ ଗ୍ରହଣ କରେ।',
        ),
        position: Offset(0.53, 0.37),
      ),
      InteractiveDiagramLabel(
        id: 'glucose',
        title: DiagramText(en: 'Glucose', hi: 'ग्लूकोज़', or: 'ଗ୍ଲୁକୋଜ୍'),
        explanation: DiagramText(
          en: 'The sugar made by the plant and used as food.',
          hi: 'पौधे द्वारा बनाई गई शर्करा, जिसका उपयोग भोजन के रूप में होता है।',
          or: 'ଉଦ୍ଭିଦ ତିଆରି କରୁଥିବା ଶର୍କରା, ଯାହା ଖାଦ୍ୟ ଭାବେ ବ୍ୟବହୃତ ହୁଏ।',
        ),
        position: Offset(0.70, 0.37),
      ),
      InteractiveDiagramLabel(
        id: 'oxygen',
        title: DiagramText(en: 'Oxygen', hi: 'ऑक्सीजन', or: 'ଅମ୍ଳଜାନ'),
        explanation: DiagramText(
          en: 'Released from the leaves into the air.',
          hi: 'पत्तियों से वायु में छोड़ी जाती है।',
          or: 'ପତ୍ରରୁ ବାୟୁକୁ ଛାଡ଼ାଯାଏ।',
        ),
        position: Offset(0.82, 0.25),
      ),
    ],
  ),
  InteractiveDiagram(
    id: 'india_states_map',
    section: DiagramSection.geography,
    title: DiagramText(
      en: 'Map of India',
      hi: 'भारत का मानचित्र',
      or: 'ଭାରତର ମାନଚିତ୍ର',
    ),
    description: DiagramText(
      en: 'Explore selected states, capitals and major rivers of India.',
      hi: 'भारत के चुनिंदा राज्यों, राजधानियों और प्रमुख नदियों को जानें।',
      or: 'ଭାରତର ଚୟନିତ ରାଜ୍ୟ, ରାଜଧାନୀ ଓ ପ୍ରମୁଖ ନଦୀଗୁଡ଼ିକୁ ଜାଣନ୍ତୁ।',
    ),
    imagePath: 'assets/diagrams/interactive/india_states_map.png',
    aspectRatio: 2 / 3,
    labels: [
      InteractiveDiagramLabel(
        id: 'new_delhi',
        title: DiagramText(en: 'New Delhi', hi: 'नई दिल्ली', or: 'ନୂଆଦିଲ୍ଲୀ'),
        explanation: DiagramText(
          en: 'New Delhi is the national capital of India.',
          hi: 'नई दिल्ली भारत की राष्ट्रीय राजधानी है।',
          or: 'ନୂଆଦିଲ୍ଲୀ ଭାରତର ଜାତୀୟ ରାଜଧାନୀ।',
        ),
        position: Offset(0.32, 0.24),
      ),
      InteractiveDiagramLabel(
        id: 'odisha',
        title: DiagramText(
          en: 'Odisha — Bhubaneswar',
          hi: 'ओडिशा — भुवनेश्वर',
          or: 'ଓଡ଼ିଶା — ଭୁବନେଶ୍ୱର',
        ),
        explanation: DiagramText(
          en: 'Odisha is an eastern coastal state. Its capital is Bhubaneswar.',
          hi: 'ओडिशा पूर्वी तट का राज्य है। इसकी राजधानी भुवनेश्वर है।',
          or: 'ଓଡ଼ିଶା ପୂର୍ବ ଉପକୂଳର ଏକ ରାଜ୍ୟ। ଏହାର ରାଜଧାନୀ ଭୁବନେଶ୍ୱର।',
        ),
        position: Offset(0.59, 0.50),
      ),
      InteractiveDiagramLabel(
        id: 'maharashtra',
        title: DiagramText(
          en: 'Maharashtra — Mumbai',
          hi: 'महाराष्ट्र — मुंबई',
          or: 'ମହାରାଷ୍ଟ୍ର — ମୁମ୍ବାଇ',
        ),
        explanation: DiagramText(
          en: 'Maharashtra is a western state. Its capital is Mumbai.',
          hi: 'महाराष्ट्र पश्चिमी भारत का राज्य है। इसकी राजधानी मुंबई है।',
          or: 'ମହାରାଷ୍ଟ୍ର ପଶ୍ଚିମ ଭାରତର ଏକ ରାଜ୍ୟ। ଏହାର ରାଜଧାନୀ ମୁମ୍ବାଇ।',
        ),
        position: Offset(0.15, 0.52),
      ),
      InteractiveDiagramLabel(
        id: 'west_bengal',
        title: DiagramText(
          en: 'West Bengal — Kolkata',
          hi: 'पश्चिम बंगाल — कोलकाता',
          or: 'ପଶ୍ଚିମବଙ୍ଗ — କୋଲକାତା',
        ),
        explanation: DiagramText(
          en: 'West Bengal lies in eastern India. Its capital is Kolkata.',
          hi: 'पश्चिम बंगाल पूर्वी भारत में है। इसकी राजधानी कोलकाता है।',
          or: 'ପଶ୍ଚିମବଙ୍ଗ ପୂର୍ବ ଭାରତରେ ଅବସ୍ଥିତ। ଏହାର ରାଜଧାନୀ କୋଲକାତା।',
        ),
        position: Offset(0.67, 0.45),
      ),
      InteractiveDiagramLabel(
        id: 'tamil_nadu',
        title: DiagramText(
          en: 'Tamil Nadu — Chennai',
          hi: 'तमिलनाडु — चेन्नई',
          or: 'ତାମିଲନାଡୁ — ଚେନ୍ନାଇ',
        ),
        explanation: DiagramText(
          en: 'Tamil Nadu is a southern state. Its capital is Chennai.',
          hi: 'तमिलनाडु दक्षिणी भारत का राज्य है। इसकी राजधानी चेन्नई है।',
          or: 'ତାମିଲନାଡୁ ଦକ୍ଷିଣ ଭାରତର ଏକ ରାଜ୍ୟ। ଏହାର ରାଜଧାନୀ ଚେନ୍ନାଇ।',
        ),
        position: Offset(0.41, 0.74),
      ),
      InteractiveDiagramLabel(
        id: 'ganga',
        title: DiagramText(en: 'Ganga', hi: 'गंगा', or: 'ଗଙ୍ଗା'),
        explanation: DiagramText(
          en: 'A major northern river that flows eastward to the Bay of Bengal.',
          hi: 'उत्तरी भारत की प्रमुख नदी जो पूर्व की ओर बंगाल की खाड़ी में बहती है।',
          or: 'ଉତ୍ତର ଭାରତର ଏକ ପ୍ରମୁଖ ନଦୀ ଯାହା ପୂର୍ବ ଦିଗକୁ ବହି ବଙ୍ଗୋପସାଗରରେ ମିଶେ।',
        ),
        position: Offset(0.50, 0.34),
      ),
      InteractiveDiagramLabel(
        id: 'brahmaputra',
        title: DiagramText(
          en: 'Brahmaputra',
          hi: 'ब्रह्मपुत्र',
          or: 'ବ୍ରହ୍ମପୁତ୍ର',
        ),
        explanation: DiagramText(
          en: 'A great river that crosses northeastern India through Assam.',
          hi: 'एक विशाल नदी जो असम से होकर पूर्वोत्तर भारत में बहती है।',
          or: 'ଏକ ବିଶାଳ ନଦୀ ଯାହା ଆସାମ ଦେଇ ଉତ୍ତର-ପୂର୍ବ ଭାରତରେ ବହେ।',
        ),
        position: Offset(0.82, 0.34),
      ),
      InteractiveDiagramLabel(
        id: 'mahanadi',
        title: DiagramText(en: 'Mahanadi', hi: 'महानदी', or: 'ମହାନଦୀ'),
        explanation: DiagramText(
          en: 'A major river of central-eastern India that flows through Odisha.',
          hi: 'मध्य-पूर्वी भारत की प्रमुख नदी जो ओडिशा से होकर बहती है।',
          or: 'ମଧ୍ୟ-ପୂର୍ବ ଭାରତର ଏକ ପ୍ରମୁଖ ନଦୀ ଯାହା ଓଡ଼ିଶା ଦେଇ ବହେ।',
        ),
        position: Offset(0.56, 0.51),
      ),
      InteractiveDiagramLabel(
        id: 'godavari',
        title: DiagramText(en: 'Godavari', hi: 'गोदावरी', or: 'ଗୋଦାବରୀ'),
        explanation: DiagramText(
          en: 'A long peninsular river that flows eastward across the Deccan Plateau.',
          hi: 'लंबी प्रायद्वीपीय नदी जो दक्कन के पठार से पूर्व की ओर बहती है।',
          or: 'ଏକ ଦୀର୍ଘ ଉପଦ୍ୱୀପୀୟ ନଦୀ ଯାହା ଦାକ୍ଷିଣାତ୍ୟ ମାଳଭୂମି ଦେଇ ପୂର୍ବକୁ ବହେ।',
        ),
        position: Offset(0.45, 0.60),
      ),
      InteractiveDiagramLabel(
        id: 'kaveri',
        title: DiagramText(en: 'Kaveri', hi: 'कावेरी', or: 'କାବେରୀ'),
        explanation: DiagramText(
          en: 'A southern river that flows through Karnataka and Tamil Nadu.',
          hi: 'दक्षिणी नदी जो कर्नाटक और तमिलनाडु से होकर बहती है।',
          or: 'ଦକ୍ଷିଣ ଭାରତର ଏକ ନଦୀ ଯାହା କର୍ଣ୍ଣାଟକ ଓ ତାମିଲନାଡୁ ଦେଇ ବହେ।',
        ),
        position: Offset(0.35, 0.75),
      ),
    ],
  ),
  InteractiveDiagram(
    id: 'earth_layers',
    section: DiagramSection.geography,
    title: DiagramText(
      en: 'Layers of the Earth',
      hi: 'पृथ्वी की परतें',
      or: 'ପୃଥିବୀର ସ୍ତର',
    ),
    description: DiagramText(
      en: 'Travel from Earth’s thin crust to its hot inner core.',
      hi: 'पृथ्वी की पतली भूपर्पटी से गर्म आंतरिक क्रोड तक जाएँ।',
      or: 'ପୃଥିବୀର ପତଳା ଭୂତ୍ୱକରୁ ଉତ୍ତପ୍ତ ଅନ୍ତଃକେନ୍ଦ୍ର ପର୍ଯ୍ୟନ୍ତ ଜାଣନ୍ତୁ।',
    ),
    imagePath: 'assets/diagrams/interactive/earth_layers.png',
    aspectRatio: 1,
    labels: [
      InteractiveDiagramLabel(
        id: 'crust',
        title: DiagramText(en: 'Crust', hi: 'भूपर्पटी', or: 'ଭୂତ୍ୱକ'),
        explanation: DiagramText(
          en: 'The thin, solid outer layer where we live.',
          hi: 'पतली ठोस बाहरी परत जिस पर हम रहते हैं।',
          or: 'ପତଳା ଓ କଠିନ ବାହ୍ୟ ସ୍ତର ଯେଉଁଠାରେ ଆମେ ବାସ କରୁ।',
        ),
        position: Offset(0.08, 0.38),
      ),
      InteractiveDiagramLabel(
        id: 'mantle',
        title: DiagramText(en: 'Mantle', hi: 'मैंटल', or: 'ମାଣ୍ଟଲ୍'),
        explanation: DiagramText(
          en: 'A very thick layer of hot, slowly moving rock.',
          hi: 'गर्म, धीरे-धीरे गतिशील चट्टान की बहुत मोटी परत।',
          or: 'ଉତ୍ତପ୍ତ ଓ ଧୀରେ ଗତି କରୁଥିବା ଶିଳାର ଅତି ମୋଟା ସ୍ତର।',
        ),
        position: Offset(0.72, 0.43),
      ),
      InteractiveDiagramLabel(
        id: 'outer_core',
        title: DiagramText(
          en: 'Outer core',
          hi: 'बाहरी क्रोड',
          or: 'ବାହ୍ୟ କେନ୍ଦ୍ର',
        ),
        explanation: DiagramText(
          en: 'A liquid metal layer that helps create Earth’s magnetic field.',
          hi: 'तरल धातु की परत जो पृथ्वी का चुंबकीय क्षेत्र बनाने में मदद करती है।',
          or: 'ତରଳ ଧାତୁର ସ୍ତର ଯାହା ପୃଥିବୀର ଚୁମ୍ବକୀୟ କ୍ଷେତ୍ର ସୃଷ୍ଟିରେ ସାହାଯ୍ୟ କରେ।',
        ),
        position: Offset(0.59, 0.57),
      ),
      InteractiveDiagramLabel(
        id: 'inner_core',
        title: DiagramText(
          en: 'Inner core',
          hi: 'आंतरिक क्रोड',
          or: 'ଅନ୍ତଃକେନ୍ଦ୍ର',
        ),
        explanation: DiagramText(
          en: 'The hot, dense, solid centre of Earth.',
          hi: 'पृथ्वी का गर्म, घना और ठोस केंद्र।',
          or: 'ପୃଥିବୀର ଉତ୍ତପ୍ତ, ଘନ ଓ କଠିନ କେନ୍ଦ୍ର।',
        ),
        position: Offset(0.48, 0.57),
      ),
    ],
  ),
  InteractiveDiagram(
    id: 'volcano',
    section: DiagramSection.geography,
    title: DiagramText(
      en: 'Volcano Cross-Section',
      hi: 'ज्वालामुखी का अनुप्रस्थ काट',
      or: 'ଆଗ୍ନେୟଗିରିର ପ୍ରସ୍ଥଚ୍ଛେଦ',
    ),
    description: DiagramText(
      en: 'Look inside a volcano from its magma chamber to its crater.',
      hi: 'मैग्मा कक्ष से क्रेटर तक ज्वालामुखी के अंदर देखें।',
      or: 'ମ୍ୟାଗ୍ମା ପ୍ରକୋଷ୍ଠରୁ ଜ୍ୱାଳାମୁଖ ପର୍ଯ୍ୟନ୍ତ ଆଗ୍ନେୟଗିରି ଭିତରକୁ ଦେଖନ୍ତୁ।',
    ),
    imagePath: 'assets/diagrams/interactive/volcano.png',
    aspectRatio: 1,
    labels: [
      InteractiveDiagramLabel(
        id: 'ash_cloud',
        title: DiagramText(en: 'Ash cloud', hi: 'राख का बादल', or: 'ଭସ୍ମ ବାଦଲ'),
        explanation: DiagramText(
          en: 'Hot gas, ash and rock fragments thrown into the air.',
          hi: 'वायु में फेंकी गई गर्म गैस, राख और चट्टान के टुकड़े।',
          or: 'ବାୟୁକୁ ନିକ୍ଷେପ ହୋଇଥିବା ଉତ୍ତପ୍ତ ଗ୍ୟାସ୍, ଭସ୍ମ ଓ ଶିଳାଖଣ୍ଡ।',
        ),
        position: Offset(0.52, 0.08),
      ),
      InteractiveDiagramLabel(
        id: 'crater',
        title: DiagramText(en: 'Crater', hi: 'क्रेटर', or: 'ଜ୍ୱାଳାମୁଖ'),
        explanation: DiagramText(
          en: 'The bowl-shaped opening at the summit.',
          hi: 'शिखर पर स्थित कटोरे जैसा मुख।',
          or: 'ଶିଖରରେ ଥିବା ପାତ୍ର ଆକାରର ମୁଖ।',
        ),
        position: Offset(0.52, 0.27),
      ),
      InteractiveDiagramLabel(
        id: 'lava_flow',
        title: DiagramText(
          en: 'Lava flow',
          hi: 'लावा प्रवाह',
          or: 'ଲାଭା ପ୍ରବାହ',
        ),
        explanation: DiagramText(
          en: 'Molten rock flowing across Earth’s surface.',
          hi: 'पृथ्वी की सतह पर बहती हुई पिघली चट्टान।',
          or: 'ପୃଥିବୀ ପୃଷ୍ଠରେ ବହୁଥିବା ତରଳ ଶିଳା।',
        ),
        position: Offset(0.83, 0.38),
      ),
      InteractiveDiagramLabel(
        id: 'main_vent',
        title: DiagramText(en: 'Main vent', hi: 'मुख्य नली', or: 'ମୁଖ୍ୟ ନଳୀ'),
        explanation: DiagramText(
          en: 'The main passage through which magma rises.',
          hi: 'मुख्य मार्ग जिससे मैग्मा ऊपर उठता है।',
          or: 'ମ୍ୟାଗ୍ମା ଉପରକୁ ଉଠୁଥିବା ମୁଖ୍ୟ ପଥ।',
        ),
        position: Offset(0.52, 0.52),
      ),
      InteractiveDiagramLabel(
        id: 'side_vent',
        title: DiagramText(
          en: 'Side vent',
          hi: 'पार्श्व नली',
          or: 'ପାର୍ଶ୍ୱ ନଳୀ',
        ),
        explanation: DiagramText(
          en: 'A smaller branch where magma can escape.',
          hi: 'एक छोटी शाखा जिससे मैग्मा बाहर निकल सकता है।',
          or: 'ମ୍ୟାଗ୍ମା ବାହାରି ପାରୁଥିବା ଏକ ଛୋଟ ଶାଖା ପଥ।',
        ),
        position: Offset(0.65, 0.48),
      ),
      InteractiveDiagramLabel(
        id: 'magma_chamber',
        title: DiagramText(
          en: 'Magma chamber',
          hi: 'मैग्मा कक्ष',
          or: 'ମ୍ୟାଗ୍ମା ପ୍ରକୋଷ୍ଠ',
        ),
        explanation: DiagramText(
          en: 'An underground reservoir of molten rock.',
          hi: 'भूमिगत पिघली चट्टान का भंडार।',
          or: 'ଭୂଗର୍ଭରେ ତରଳ ଶିଳାର ଭଣ୍ଡାର।',
        ),
        position: Offset(0.51, 0.78),
      ),
      InteractiveDiagramLabel(
        id: 'rock_layers',
        title: DiagramText(en: 'Rock layers', hi: 'शैल परतें', or: 'ଶିଳା ସ୍ତର'),
        explanation: DiagramText(
          en: 'Layers built from earlier lava, ash and surrounding rock.',
          hi: 'पुराने लावा, राख और आसपास की चट्टान से बनी परतें।',
          or: 'ପୂର୍ବ ଲାଭା, ଭସ୍ମ ଓ ଚାରିପାଖର ଶିଳାରୁ ତିଆରି ସ୍ତର।',
        ),
        position: Offset(0.27, 0.55),
      ),
    ],
  ),
  InteractiveDiagram(
    id: 'electric_circuit',
    section: DiagramSection.science,
    title: DiagramText(
      en: 'Simple Electric Circuit',
      hi: 'सरल विद्युत परिपथ',
      or: 'ସରଳ ବିଦ୍ୟୁତ ପରିପଥ',
    ),
    description: DiagramText(
      en: 'Trace electric current around a complete circuit.',
      hi: 'एक पूर्ण परिपथ में विद्युत धारा का मार्ग देखें।',
      or: 'ଏକ ସମ୍ପୂର୍ଣ୍ଣ ପରିପଥରେ ବିଦ୍ୟୁତ ପ୍ରବାହର ପଥ ଦେଖନ୍ତୁ।',
    ),
    imagePath: 'assets/diagrams/interactive/electric_circuit.png',
    aspectRatio: 1.5,
    labels: [
      InteractiveDiagramLabel(
        id: 'cell',
        title: DiagramText(
          en: 'Electric cell',
          hi: 'विद्युत सेल',
          or: 'ବିଦ୍ୟୁତ କୋଷ',
        ),
        explanation: DiagramText(
          en: 'Supplies electrical energy to the circuit.',
          hi: 'परिपथ को विद्युत ऊर्जा प्रदान करता है।',
          or: 'ପରିପଥକୁ ବିଦ୍ୟୁତ ଶକ୍ତି ଯୋଗାଏ।',
        ),
        position: Offset(0.11, 0.48),
      ),
      InteractiveDiagramLabel(
        id: 'wire',
        title: DiagramText(
          en: 'Connecting wire',
          hi: 'संयोजक तार',
          or: 'ସଂଯୋଗୀ ତାର',
        ),
        explanation: DiagramText(
          en: 'Provides a conducting path for electric current.',
          hi: 'विद्युत धारा के लिए चालक मार्ग प्रदान करता है।',
          or: 'ବିଦ୍ୟୁତ ପ୍ରବାହ ପାଇଁ ପରିବାହୀ ପଥ ଯୋଗାଏ।',
        ),
        position: Offset(0.82, 0.31),
      ),
      InteractiveDiagramLabel(
        id: 'bulb',
        title: DiagramText(en: 'Light bulb', hi: 'बल्ब', or: 'ବଲ୍‌ବ'),
        explanation: DiagramText(
          en: 'Changes electrical energy into light and heat.',
          hi: 'विद्युत ऊर्जा को प्रकाश और ऊष्मा में बदलता है।',
          or: 'ବିଦ୍ୟୁତ ଶକ୍ତିକୁ ଆଲୋକ ଓ ତାପରେ ପରିଣତ କରେ।',
        ),
        position: Offset(0.57, 0.19),
      ),
      InteractiveDiagramLabel(
        id: 'switch',
        title: DiagramText(
          en: 'Closed switch',
          hi: 'बंद स्विच',
          or: 'ବନ୍ଦ ସୁଇଚ୍',
        ),
        explanation: DiagramText(
          en: 'Completes the path so current can flow.',
          hi: 'मार्ग को पूरा करता है ताकि धारा बह सके।',
          or: 'ପଥକୁ ସମ୍ପୂର୍ଣ୍ଣ କରେ ଯାହାଦ୍ୱାରା ବିଦ୍ୟୁତ ପ୍ରବାହିତ ହୁଏ।',
        ),
        position: Offset(0.57, 0.77),
      ),
      InteractiveDiagramLabel(
        id: 'current',
        title: DiagramText(
          en: 'Current direction',
          hi: 'धारा की दिशा',
          or: 'ପ୍ରବାହର ଦିଗ',
        ),
        explanation: DiagramText(
          en: 'Arrows show the conventional direction of current around the loop.',
          hi: 'तीर परिपथ में धारा की पारंपरिक दिशा दिखाते हैं।',
          or: 'ତୀରଗୁଡ଼ିକ ପରିପଥରେ ବିଦ୍ୟୁତ ପ୍ରବାହର ପାରମ୍ପରିକ ଦିଗ ଦେଖାଏ।',
        ),
        position: Offset(0.31, 0.25),
      ),
    ],
  ),
  InteractiveDiagram(
    id: 'atom_structure',
    section: DiagramSection.science,
    title: DiagramText(
      en: 'Structure of an Atom',
      hi: 'परमाणु की संरचना',
      or: 'ପରମାଣୁର ଗଠନ',
    ),
    description: DiagramText(
      en: 'Explore the nucleus, particles and electron shells of an atom.',
      hi: 'परमाणु के नाभिक, कणों और इलेक्ट्रॉन कोशों को जानें।',
      or: 'ପରମାଣୁର ନ୍ୟୁକ୍ଲିୟସ୍, କଣିକା ଓ ଇଲେକ୍ଟ୍ରନ୍ କକ୍ଷକୁ ଜାଣନ୍ତୁ।',
    ),
    imagePath: 'assets/diagrams/interactive/atom_structure.png',
    aspectRatio: 1,
    labels: [
      InteractiveDiagramLabel(
        id: 'nucleus',
        title: DiagramText(en: 'Nucleus', hi: 'नाभिक', or: 'ନ୍ୟୁକ୍ଲିୟସ୍'),
        explanation: DiagramText(
          en: 'The dense centre containing protons and neutrons.',
          hi: 'घना केंद्र जिसमें प्रोटॉन और न्यूट्रॉन होते हैं।',
          or: 'ପ୍ରୋଟୋନ୍ ଓ ନ୍ୟୁଟ୍ରୋନ୍ ଥିବା ଘନ କେନ୍ଦ୍ର।',
        ),
        position: Offset(0.50, 0.51),
      ),
      InteractiveDiagramLabel(
        id: 'proton',
        title: DiagramText(en: 'Proton', hi: 'प्रोटॉन', or: 'ପ୍ରୋଟୋନ୍'),
        explanation: DiagramText(
          en: 'A positively charged particle inside the nucleus.',
          hi: 'नाभिक के अंदर धन आवेश वाला कण।',
          or: 'ନ୍ୟୁକ୍ଲିୟସ୍ ଭିତରେ ଥିବା ଧନାତ୍ମକ ଆବେଶଯୁକ୍ତ କଣିକା।',
        ),
        position: Offset(0.46, 0.47),
      ),
      InteractiveDiagramLabel(
        id: 'neutron',
        title: DiagramText(en: 'Neutron', hi: 'न्यूट्रॉन', or: 'ନ୍ୟୁଟ୍ରୋନ୍'),
        explanation: DiagramText(
          en: 'An uncharged particle inside the nucleus.',
          hi: 'नाभिक के अंदर बिना आवेश वाला कण।',
          or: 'ନ୍ୟୁକ୍ଲିୟସ୍ ଭିତରେ ଥିବା ଆବେଶହୀନ କଣିକା।',
        ),
        position: Offset(0.55, 0.54),
      ),
      InteractiveDiagramLabel(
        id: 'electron',
        title: DiagramText(en: 'Electron', hi: 'इलेक्ट्रॉन', or: 'ଇଲେକ୍ଟ୍ରୋନ୍'),
        explanation: DiagramText(
          en: 'A negatively charged particle found around the nucleus.',
          hi: 'नाभिक के चारों ओर पाया जाने वाला ऋण आवेशित कण।',
          or: 'ନ୍ୟୁକ୍ଲିୟସ୍ ଚାରିପାଖରେ ଥିବା ଋଣାତ୍ମକ ଆବେଶଯୁକ୍ତ କଣିକା।',
        ),
        position: Offset(0.50, 0.08),
      ),
      InteractiveDiagramLabel(
        id: 'electron_shell',
        title: DiagramText(
          en: 'Electron shell',
          hi: 'इलेक्ट्रॉन कोश',
          or: 'ଇଲେକ୍ଟ୍ରୋନ୍ କକ୍ଷ',
        ),
        explanation: DiagramText(
          en: 'An energy level where electrons are represented around the nucleus.',
          hi: 'एक ऊर्जा स्तर जहाँ नाभिक के चारों ओर इलेक्ट्रॉन दर्शाए जाते हैं।',
          or: 'ନ୍ୟୁକ୍ଲିୟସ୍ ଚାରିପାଖରେ ଇଲେକ୍ଟ୍ରୋନ୍ ଦର୍ଶାଯାଉଥିବା ଶକ୍ତି ସ୍ତର।',
        ),
        position: Offset(0.84, 0.50),
      ),
    ],
  ),
  InteractiveDiagram(
    id: 'reflection_light',
    section: DiagramSection.science,
    title: DiagramText(
      en: 'Reflection of Light',
      hi: 'प्रकाश का परावर्तन',
      or: 'ଆଲୋକର ପ୍ରତିଫଳନ',
    ),
    description: DiagramText(
      en: 'Compare the incident and reflected rays at a plane mirror.',
      hi: 'समतल दर्पण पर आपतित और परावर्तित किरणों की तुलना करें।',
      or: 'ସମତଳ ଦର୍ପଣରେ ଆପତିତ ଓ ପ୍ରତିଫଳିତ ରଶ୍ମିକୁ ତୁଳନା କରନ୍ତୁ।',
    ),
    imagePath: 'assets/diagrams/interactive/reflection_light.png',
    aspectRatio: 1.5,
    labels: [
      InteractiveDiagramLabel(
        id: 'plane_mirror',
        title: DiagramText(
          en: 'Plane mirror',
          hi: 'समतल दर्पण',
          or: 'ସମତଳ ଦର୍ପଣ',
        ),
        explanation: DiagramText(
          en: 'A flat reflective surface that changes the ray’s direction.',
          hi: 'एक सपाट परावर्तक सतह जो किरण की दिशा बदलती है।',
          or: 'ରଶ୍ମିର ଦିଗ ବଦଳାଉଥିବା ଏକ ସମତଳ ପ୍ରତିଫଳକ ପୃଷ୍ଠ।',
        ),
        position: Offset(0.73, 0.51),
      ),
      InteractiveDiagramLabel(
        id: 'incident_ray',
        title: DiagramText(
          en: 'Incident ray',
          hi: 'आपतित किरण',
          or: 'ଆପତିତ ରଶ୍ମି',
        ),
        explanation: DiagramText(
          en: 'The incoming light ray that strikes the mirror.',
          hi: 'दर्पण से टकराने वाली आने वाली प्रकाश किरण।',
          or: 'ଦର୍ପଣରେ ପଡ଼ୁଥିବା ଆସୁଥିବା ଆଲୋକ ରଶ୍ମି।',
        ),
        position: Offset(0.39, 0.27),
      ),
      InteractiveDiagramLabel(
        id: 'normal',
        title: DiagramText(en: 'Normal', hi: 'अभिलंब', or: 'ଅଭିଲମ୍ବ'),
        explanation: DiagramText(
          en: 'An imaginary line perpendicular to the mirror at the point of incidence.',
          hi: 'आपतन बिंदु पर दर्पण के लंबवत एक काल्पनिक रेखा।',
          or: 'ଆପତନ ବିନ୍ଦୁରେ ଦର୍ପଣ ପ୍ରତି ଲମ୍ବ ଏକ କଳ୍ପିତ ରେଖା।',
        ),
        position: Offset(0.46, 0.50),
      ),
      InteractiveDiagramLabel(
        id: 'point_of_incidence',
        title: DiagramText(
          en: 'Point of incidence',
          hi: 'आपतन बिंदु',
          or: 'ଆପତନ ବିନ୍ଦୁ',
        ),
        explanation: DiagramText(
          en: 'The exact point where the incoming ray meets the mirror.',
          hi: 'वह बिंदु जहाँ आने वाली किरण दर्पण से मिलती है।',
          or: 'ଆସୁଥିବା ରଶ୍ମି ଦର୍ପଣକୁ ଭେଟୁଥିବା ନିର୍ଦ୍ଦିଷ୍ଟ ବିନ୍ଦୁ।',
        ),
        position: Offset(0.66, 0.50),
      ),
      InteractiveDiagramLabel(
        id: 'reflected_ray',
        title: DiagramText(
          en: 'Reflected ray',
          hi: 'परावर्तित किरण',
          or: 'ପ୍ରତିଫଳିତ ରଶ୍ମି',
        ),
        explanation: DiagramText(
          en: 'The light ray that travels away after striking the mirror.',
          hi: 'दर्पण से टकराने के बाद दूर जाने वाली प्रकाश किरण।',
          or: 'ଦର୍ପଣରେ ପଡ଼ିବା ପରେ ଦୂରକୁ ଯାଉଥିବା ଆଲୋକ ରଶ୍ମି।',
        ),
        position: Offset(0.40, 0.73),
      ),
    ],
  ),
  InteractiveDiagram(
    id: 'states_of_matter',
    section: DiagramSection.science,
    title: DiagramText(
      en: 'States of Matter',
      hi: 'पदार्थ की अवस्थाएँ',
      or: 'ପଦାର୍ଥର ଅବସ୍ଥା',
    ),
    description: DiagramText(
      en: 'Compare how particles are arranged in solids, liquids and gases.',
      hi: 'ठोस, द्रव और गैस में कणों की व्यवस्था की तुलना करें।',
      or: 'କଠିନ, ତରଳ ଓ ଗ୍ୟାସରେ କଣିକାର ବ୍ୟବସ୍ଥାକୁ ତୁଳନା କରନ୍ତୁ।',
    ),
    imagePath: 'assets/diagrams/interactive/states_of_matter.png',
    aspectRatio: 2,
    labels: [
      InteractiveDiagramLabel(
        id: 'solid',
        title: DiagramText(en: 'Solid', hi: 'ठोस', or: 'କଠିନ'),
        explanation: DiagramText(
          en: 'Particles are tightly packed in fixed, orderly positions.',
          hi: 'कण निश्चित और व्यवस्थित स्थानों पर कसकर जुड़े होते हैं।',
          or: 'କଣିକାଗୁଡ଼ିକ ନିର୍ଦ୍ଦିଷ୍ଟ ଓ ସୁସଜ୍ଜିତ ସ୍ଥାନରେ ଘନଭାବେ ରହେ।',
        ),
        position: Offset(0.17, 0.58),
      ),
      InteractiveDiagramLabel(
        id: 'liquid',
        title: DiagramText(en: 'Liquid', hi: 'द्रव', or: 'ତରଳ'),
        explanation: DiagramText(
          en: 'Particles stay close but can move past one another.',
          hi: 'कण पास रहते हैं लेकिन एक-दूसरे के आगे खिसक सकते हैं।',
          or: 'କଣିକାଗୁଡ଼ିକ ପାଖାପାଖି ରହିଲେ ମଧ୍ୟ ପରସ୍ପରକୁ ଅତିକ୍ରମ କରି ଗତି କରିପାରେ।',
        ),
        position: Offset(0.50, 0.62),
      ),
      InteractiveDiagramLabel(
        id: 'gas',
        title: DiagramText(en: 'Gas', hi: 'गैस', or: 'ଗ୍ୟାସ'),
        explanation: DiagramText(
          en: 'Particles are far apart and move freely in every direction.',
          hi: 'कण दूर-दूर होते हैं और हर दिशा में स्वतंत्र रूप से चलते हैं।',
          or: 'କଣିକାଗୁଡ଼ିକ ଦୂରେ ଦୂରେ ରହି ସବୁ ଦିଗରେ ସ୍ୱାଧୀନ ଭାବେ ଗତି କରେ।',
        ),
        position: Offset(0.83, 0.43),
      ),
      InteractiveDiagramLabel(
        id: 'melting_freezing',
        title: DiagramText(
          en: 'Melting and freezing',
          hi: 'गलन और जमना',
          or: 'ଗଳନ ଓ ଜମାଟ',
        ),
        explanation: DiagramText(
          en: 'Heating can change a solid to liquid; cooling reverses the change.',
          hi: 'गरम करने से ठोस द्रव बन सकता है; ठंडा करने से प्रक्रिया उलट जाती है।',
          or: 'ତାପ ଦେଲେ କଠିନ ପଦାର୍ଥ ତରଳ ହୁଏ; ଥଣ୍ଡା କଲେ ପ୍ରକ୍ରିୟା ଓଲଟିଯାଏ।',
        ),
        position: Offset(0.33, 0.38),
      ),
      InteractiveDiagramLabel(
        id: 'vaporisation_condensation',
        title: DiagramText(
          en: 'Vaporisation and condensation',
          hi: 'वाष्पीकरण और संघनन',
          or: 'ବାଷ୍ପୀକରଣ ଓ ଘନୀଭବନ',
        ),
        explanation: DiagramText(
          en: 'Heating can change liquid to gas; cooling changes gas to liquid.',
          hi: 'गरम करने से द्रव गैस बनता है; ठंडा करने से गैस द्रव बनती है।',
          or: 'ତାପ ଦେଲେ ତରଳ ଗ୍ୟାସ ହୁଏ; ଥଣ୍ଡା କଲେ ଗ୍ୟାସ ତରଳ ହୁଏ।',
        ),
        position: Offset(0.67, 0.38),
      ),
    ],
  ),
  ...remainingInteractiveDiagrams,
];

InteractiveDiagram? interactiveDiagramById(String id) {
  for (final diagram in interactiveDiagrams) {
    if (diagram.id == id) return diagram;
  }
  return null;
}
