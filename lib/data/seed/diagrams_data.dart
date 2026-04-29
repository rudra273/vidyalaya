class DiagramCategory {
  final String id;
  final String titleEn;
  final String titleOr;
  final List<Diagram> diagrams;

  const DiagramCategory({
    required this.id,
    required this.titleEn,
    required this.titleOr,
    required this.diagrams,
  });
}

class Diagram {
  final String id;
  final String titleEn;
  final String titleOr;
  final String descriptionEn;
  final String descriptionOr;
  final String imagePath;

  const Diagram({
    required this.id,
    required this.titleEn,
    required this.titleOr,
    required this.descriptionEn,
    required this.descriptionOr,
    required this.imagePath,
  });
}

const diagramCategories = [
  DiagramCategory(
    id: 'bio',
    titleEn: 'Biology',
    titleOr: 'ଜୀବବିଜ୍ଞାନ',
    diagrams: [
      Diagram(
        id: 'human_cell',
        titleEn: 'Human Cell',
        titleOr: 'ମାନବ କୋଷ',
        descriptionEn: 'A detailed diagram of a human cell showing its organelles like nucleus, mitochondria, and cell membrane.',
        descriptionOr: 'ନିୟୁକ୍ଲିୟସ୍, ମାଇଟୋକଣ୍ଡ୍ରିଆ ଏବଂ କୋଷ ଝିଲ୍ଲୀ ପରି ଏହାର ଅଙ୍ଗିକା ଦେଖାଉଥିବା ଏକ ମାନବ କୋଷର ଏକ ବିସ୍ତୃତ ଚିତ୍ର |',
        imagePath: 'assets/diagrams/Human_cell.png',
      ),
    ],
  ),
  DiagramCategory(
    id: 'geo',
    titleEn: 'Geography',
    titleOr: 'ଭୂଗୋଳ',
    diagrams: [
      Diagram(
        id: 'earth_layers',
        titleEn: 'Layers of the Earth',
        titleOr: 'ପୃଥିବୀର ସ୍ତର',
        descriptionEn: 'A cross-section of the Earth showing the crust, mantle, outer core, and inner core.',
        descriptionOr: 'ପୃଥିବୀର ଭୂତ୍ୱକ, ମାଣ୍ଟଲ୍, ବାହ୍ୟ କେନ୍ଦ୍ର ଏବଂ ଆଭ୍ୟନ୍ତରୀଣ କେନ୍ଦ୍ର ଦେଖାଉଥିବା ଏକ ପ୍ରସ୍ଥଚ୍ଛେଦ |',
        imagePath: 'assets/diagrams/earthlayers.png',
      ),
    ],
  ),
  DiagramCategory(
    id: 'sci',
    titleEn: 'Science',
    titleOr: 'ବିଜ୍ଞାନ',
    diagrams: [
      Diagram(
        id: 'water_cycle',
        titleEn: 'The Water Cycle',
        titleOr: 'ଜଳ ଚକ୍ର',
        descriptionEn: 'The continuous movement of water within the Earth and atmosphere through evaporation, condensation, and precipitation.',
        descriptionOr: 'ବାଷ୍ପୀକରଣ, ଘନୀଭବନ ଏବଂ ବୃଷ୍ଟିପାତ ମାଧ୍ୟମରେ ପୃଥିବୀ ଏବଂ ବାୟୁମଣ୍ଡଳ ମଧ୍ୟରେ ଜଳର ନିରନ୍ତର ଗତି |',
        imagePath: 'assets/diagrams/watercycle.png',
      ),
    ],
  ),
];
