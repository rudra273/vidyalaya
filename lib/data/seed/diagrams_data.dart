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
    ],
  ),
];
