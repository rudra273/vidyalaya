import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../providers/regional_language_provider.dart';
import '../../widgets/regional_language_switch.dart';

class FormulaData {
  final String titleEn;
  final String titleOr;
  final String titleHi;
  final String formula;
  final FormulaType type;
  final String category;
  final String descEn;
  final String descOr;
  final String descHi;

  const FormulaData({
    required this.titleEn,
    required this.titleOr,
    required this.titleHi,
    required this.formula,
    required this.type,
    required this.category,
    required this.descEn,
    required this.descOr,
    required this.descHi,
  });

  /// Title in the chosen regional language.
  String regionalTitle(RegionalLanguage lang) =>
      lang == RegionalLanguage.hindi ? titleHi : titleOr;

  /// Description in the chosen regional language.
  String regionalDesc(RegionalLanguage lang) =>
      lang == RegionalLanguage.hindi ? descHi : descOr;

  /// The geometric figure that illustrates this formula, or `null` for purely
  /// numeric formulas (interest, quadratic, temperature, speed) where no
  /// figure is meaningful.
  FormulaDiagram? get diagram {
    switch (type) {
      case FormulaType.circleArea:
      case FormulaType.circleCircumference:
        return FormulaDiagram.circle;
      case FormulaType.pythagoras:
        return FormulaDiagram.rightTriangle;
      case FormulaType.cylinderVolume:
        return FormulaDiagram.cylinder;
      case FormulaType.rectanglePerimeter:
      case FormulaType.rectangleArea:
        return FormulaDiagram.rectangle;
      case FormulaType.squarePerimeter:
      case FormulaType.squareArea:
        return FormulaDiagram.square;
      case FormulaType.triangleArea:
        return FormulaDiagram.triangle;
      case FormulaType.triangleAreaTrig:
        return FormulaDiagram.triangleTrig;
      case FormulaType.cubeVolume:
        return FormulaDiagram.cube;
      case FormulaType.cuboidVolume:
        return FormulaDiagram.cuboid;
      case FormulaType.simpleInterest:
      case FormulaType.quadratic:
      case FormulaType.speedDistanceTime:
      case FormulaType.fahrenheitToCelsius:
      case FormulaType.celsiusToFahrenheit:
        return null;
    }
  }
}

/// Kinds of geometric figures drawn by [FormulaDiagramPainter].
enum FormulaDiagram {
  circle,
  rightTriangle,
  triangle,
  triangleTrig,
  rectangle,
  square,
  cube,
  cuboid,
  cylinder,
}

enum FormulaType {
  simpleInterest,
  circleArea,
  circleCircumference,
  pythagoras,
  cylinderVolume,
  quadratic,
  rectanglePerimeter,
  rectangleArea,
  squarePerimeter,
  squareArea,
  triangleArea,
  cubeVolume,
  cuboidVolume,
  speedDistanceTime,
  fahrenheitToCelsius,
  celsiusToFahrenheit,
  triangleAreaTrig,
}

const _allFormulas = [
  // Arithmetic
  FormulaData(
    titleEn: 'Simple Interest',
    titleOr: 'ସରଳ ସୁଧ',
    titleHi: 'साधारण ब्याज',
    formula: 'SI = (P × R × T) / 100',
    type: FormulaType.simpleInterest,
    category: 'Arithmetic',
    descEn: 'Calculates the simple interest earned on a principal sum over a period of time.',
    descOr: 'ଏକ ନିର୍ଦ୍ଦିଷ୍ଟ ସମୟ ପାଇଁ ମୂଳଧନ ଉପରେ ମିଳୁଥିବା ସରଳ ସୁଧ ହିସାବ କରେ।',
    descHi: 'एक निश्चित अवधि के लिए मूलधन पर अर्जित साधारण ब्याज की गणना करता है।',
  ),

  // Algebra
  FormulaData(
    titleEn: 'Quadratic Equation',
    titleOr: 'ଦ୍ୱିଘାତ ସମୀକରଣ',
    titleHi: 'द्विघात समीकरण',
    formula: 'x = (-b ± √(b² - 4ac)) / 2a',
    type: FormulaType.quadratic,
    category: 'Algebra',
    descEn: 'Finds the unknown variable x (roots) in a second-degree polynomial equation.',
    descOr: 'ଏକ ଦ୍ୱିଘାତ ସମୀକରଣରେ ଅଜ୍ଞାତ ରାଶି x ର ମୂଲ୍ୟ (ମୂଳ) ନିର୍ଣ୍ଣୟ କରେ।',
    descHi: 'एक द्विघात समीकरण में अज्ञात राशि x का मान (मूल) ज्ञात करता है।',
  ),

  // Geometry
  FormulaData(
    titleEn: 'Area of a Circle',
    titleOr: 'ବୃତ୍ତର କ୍ଷେତ୍ରଫଳ',
    titleHi: 'वृत्त का क्षेत्रफल',
    formula: 'A = πr²',
    type: FormulaType.circleArea,
    category: 'Geometry',
    descEn: 'Calculates the total 2D space enclosed within a circle.',
    descOr: 'ଏକ ବୃତ୍ତ ମଧ୍ୟରେ ଥିବା ସମୁଦାୟ ସ୍ଥାନ ବା କ୍ଷେତ୍ରଫଳ ହିସାବ କରେ।',
    descHi: 'एक वृत्त के भीतर घिरे कुल द्वि-आयामी क्षेत्रफल की गणना करता है।',
  ),
  FormulaData(
    titleEn: 'Circumference of Circle',
    titleOr: 'ବୃତ୍ତର ପରିଧି',
    titleHi: 'वृत्त की परिधि',
    formula: 'C = 2πr',
    type: FormulaType.circleCircumference,
    category: 'Geometry',
    descEn: 'Calculates the total length of the outer boundary of a circle.',
    descOr: 'ଏକ ବୃତ୍ତର ଚାରିପାଖର ସମୁଦାୟ ଦୈର୍ଘ୍ୟ ବା ପରିଧି ହିସାବ କରେ।',
    descHi: 'एक वृत्त की बाहरी सीमा की कुल लंबाई या परिधि की गणना करता है।',
  ),
  FormulaData(
    titleEn: 'Pythagorean Theorem',
    titleOr: 'ପିଥାଗୋରାସ୍ ଉପପାଦ୍ୟ',
    titleHi: 'पाइथागोरस प्रमेय',
    formula: 'c = √(a² + b²)',
    type: FormulaType.pythagoras,
    category: 'Geometry',
    descEn: 'Finds the longest side (hypotenuse) of a right-angled triangle.',
    descOr: 'ଏକ ସମକୋଣୀ ତ୍ରିଭୁଜର ସବୁଠାରୁ ବଡ଼ ବାହୁ (କର୍ଣ୍ଣ) ନିର୍ଣ୍ଣୟ କରେ।',
    descHi: 'एक समकोण त्रिभुज की सबसे लंबी भुजा (कर्ण) ज्ञात करता है।',
  ),
  FormulaData(
    titleEn: 'Volume of a Cylinder',
    titleOr: 'ସିଲିଣ୍ଡରର ଆୟତନ',
    titleHi: 'बेलन का आयतन',
    formula: 'V = πr²h',
    type: FormulaType.cylinderVolume,
    category: 'Geometry',
    descEn: 'Calculates the total 3D space occupied by a cylinder.',
    descOr: 'ଏକ ସିଲିଣ୍ଡର ଦ୍ୱାରା ଅଧିକାର କରାଯାଇଥିବା ସମୁଦାୟ ଆୟତନ ହିସାବ କରେ।',
    descHi: 'एक बेलन द्वारा घेरे गए कुल त्रि-आयामी आयतन की गणना करता है।',
  ),
  FormulaData(
    titleEn: 'Perimeter of Rectangle',
    titleOr: 'ଆୟତକ୍ଷେତ୍ରର ପରିସୀମା',
    titleHi: 'आयत की परिमिति',
    formula: 'P = 2(l + w)',
    type: FormulaType.rectanglePerimeter,
    category: 'Geometry',
    descEn: 'Calculates the total length of the outer boundary of a rectangle.',
    descOr: 'ଏକ ଆୟତକ୍ଷେତ୍ରର ଚାରିପାଖର ସମୁଦାୟ ଦୈର୍ଘ୍ୟ ବା ପରିସୀମା ହିସାବ କରେ।',
    descHi: 'एक आयत की बाहरी सीमा की कुल लंबाई या परिमिति की गणना करता है।',
  ),
  FormulaData(
    titleEn: 'Area of Rectangle',
    titleOr: 'ଆୟତକ୍ଷେତ୍ରର କ୍ଷେତ୍ରଫଳ',
    titleHi: 'आयत का क्षेत्रफल',
    formula: 'A = l × w',
    type: FormulaType.rectangleArea,
    category: 'Geometry',
    descEn: 'Calculates the 2D surface area of a rectangle.',
    descOr: 'ଏକ ଆୟତକ୍ଷେତ୍ରର ପୃଷ୍ଠତଳର ସମୁଦାୟ କ୍ଷେତ୍ରଫଳ ହିସାବ କରେ।',
    descHi: 'एक आयत के द्वि-आयामी पृष्ठीय क्षेत्रफल की गणना करता है।',
  ),
  FormulaData(
    titleEn: 'Perimeter of Square',
    titleOr: 'ବର୍ଗକ୍ଷେତ୍ରର ପରିସୀମା',
    titleHi: 'वर्ग की परिमिति',
    formula: 'P = 4a',
    type: FormulaType.squarePerimeter,
    category: 'Geometry',
    descEn: 'Calculates the total boundary length of a square.',
    descOr: 'ଏକ ବର୍ଗକ୍ଷେତ୍ରର ଚାରିପାଖର ସମୁଦାୟ ଦୈର୍ଘ୍ୟ ହିସାବ କରେ।',
    descHi: 'एक वर्ग की कुल सीमा लंबाई की गणना करता है।',
  ),
  FormulaData(
    titleEn: 'Area of Square',
    titleOr: 'ବର୍ଗକ୍ଷେତ୍ରର କ୍ଷେତ୍ରଫଳ',
    titleHi: 'वर्ग का क्षेत्रफल',
    formula: 'A = a²',
    type: FormulaType.squareArea,
    category: 'Geometry',
    descEn: 'Calculates the surface area enclosed by a square.',
    descOr: 'ଏକ ବର୍ଗକ୍ଷେତ୍ର ମଧ୍ୟରେ ଥିବା ସମୁଦାୟ କ୍ଷେତ୍ରଫଳ ହିସାବ କରେ।',
    descHi: 'एक वर्ग के भीतर घिरे क्षेत्रफल की गणना करता है।',
  ),
  FormulaData(
    titleEn: 'Area of Triangle',
    titleOr: 'ତ୍ରିଭୁଜର କ୍ଷେତ୍ରଫଳ',
    titleHi: 'त्रिभुज का क्षेत्रफल',
    formula: 'A = ½ × b × h',
    type: FormulaType.triangleArea,
    category: 'Geometry',
    descEn: 'Calculates the space enclosed by a triangle using its base and height.',
    descOr: 'ଭୂମି ଏବଂ ଉଚ୍ଚତା ବ୍ୟବହାର କରି ଏକ ତ୍ରିଭୁଜର କ୍ଷେତ୍ରଫଳ ହିସାବ କରେ।',
    descHi: 'आधार और ऊँचाई का उपयोग करके एक त्रिभुज के क्षेत्रफल की गणना करता है।',
  ),
  FormulaData(
    titleEn: 'Volume of Cube',
    titleOr: 'ଘନର ଆୟତନ',
    titleHi: 'घन का आयतन',
    formula: 'V = a³',
    type: FormulaType.cubeVolume,
    category: 'Geometry',
    descEn: 'Calculates the total 3D space occupied by a cube.',
    descOr: 'ଏକ ଘନ (Cube) ର ସମୁଦାୟ ଆୟତନ ହିସାବ କରେ।',
    descHi: 'एक घन (Cube) द्वारा घेरे गए कुल आयतन की गणना करता है।',
  ),
  FormulaData(
    titleEn: 'Volume of Cuboid',
    titleOr: 'ଆୟତଘନର ଆୟତନ',
    titleHi: 'घनाभ का आयतन',
    formula: 'V = l × w × h',
    type: FormulaType.cuboidVolume,
    category: 'Geometry',
    descEn: 'Calculates the 3D space enclosed by a rectangular cuboid.',
    descOr: 'ଏକ ଆୟତଘନ (Cuboid) ର ସମୁଦାୟ ଆୟତନ ହିସାବ କରେ।',
    descHi: 'एक घनाभ (Cuboid) द्वारा घेरे गए कुल आयतन की गणना करता है।',
  ),

  // Trigonometry
  FormulaData(
    titleEn: 'Area of Triangle (Trig)',
    titleOr: 'ତ୍ରିଭୁଜର କ୍ଷେତ୍ରଫଳ',
    titleHi: 'त्रिभुज का क्षेत्रफल (त्रिकोणमिति)',
    formula: 'A = ½ ab sin(C)',
    type: FormulaType.triangleAreaTrig,
    category: 'Trigonometry',
    descEn: 'Calculates the area of a triangle using two sides and the included angle.',
    descOr: 'ଦୁଇଟି ବାହୁ ଏବଂ ସେମାନଙ୍କ ମଧ୍ୟବର୍ତ୍ତୀ କୋଣ ବ୍ୟବହାର କରି ତ୍ରିଭୁଜର କ୍ଷେତ୍ରଫଳ ହିସାବ କରେ।',
    descHi: 'दो भुजाओं और उनके बीच के कोण का उपयोग करके त्रिभुज के क्षेत्रफल की गणना करता है।',
  ),

  // Science
  FormulaData(
    titleEn: 'Speed, Distance, Time',
    titleOr: 'ବେଗ, ଦୂରତା, ସମୟ',
    titleHi: 'चाल, दूरी, समय',
    formula: 's = d / t',
    type: FormulaType.speedDistanceTime,
    category: 'Science',
    descEn: 'Calculates the speed of an object based on distance traveled over time.',
    descOr: 'ଦୂରତା ଏବଂ ସମୟ ଉପରେ ଭିତ୍ତି କରି ଏକ ବସ୍ତୁର ବେଗ ହିସାବ କରେ।',
    descHi: 'दूरी और समय के आधार पर किसी वस्तु की चाल की गणना करता है।',
  ),
  FormulaData(
    titleEn: 'Fahrenheit to Celsius',
    titleOr: 'ଫାରେନହାଇଟରୁ ସେଲସିୟସ',
    titleHi: 'फारेनहाइट से सेल्सियस',
    formula: 'C = (F - 32) × 5/9',
    type: FormulaType.fahrenheitToCelsius,
    category: 'Science',
    descEn: 'Converts temperature from the Fahrenheit scale to the Celsius scale.',
    descOr: 'ତାପମାତ୍ରାକୁ ଫାରେନହାଇଟ୍ ରୁ ସେଲସିୟସ୍ ସ୍କେଲ୍ କୁ ପରିବର୍ତ୍ତନ କରେ।',
    descHi: 'तापमान को फारेनहाइट पैमाने से सेल्सियस पैमाने में परिवर्तित करता है।',
  ),
  FormulaData(
    titleEn: 'Celsius to Fahrenheit',
    titleOr: 'ସେଲସିୟସରୁ ଫାରେନହାଇଟ',
    titleHi: 'सेल्सियस से फारेनहाइट',
    formula: 'F = (C × 9/5) + 32',
    type: FormulaType.celsiusToFahrenheit,
    category: 'Science',
    descEn: 'Converts temperature from the Celsius scale to the Fahrenheit scale.',
    descOr: 'ତାପମାତ୍ରାକୁ ସେଲସିୟସ୍ ରୁ ଫାରେନହାଇଟ୍ ସ୍କେଲ୍ କୁ ପରିବର୍ତ୍ତନ କରେ।',
    descHi: 'तापमान को सेल्सियस पैमाने से फारेनहाइट पैमाने में परिवर्तित करता है।',
  ),
];

/// A formula category shown as a card on the grid. The [name] matches the
/// [FormulaData.category] string used to group the formulas.
class FormulaCategory {
  final String name;
  final String titleOr;
  final String titleHi;
  final IconData icon;
  final Color color;

  const FormulaCategory({
    required this.name,
    required this.titleOr,
    required this.titleHi,
    required this.icon,
    required this.color,
  });

  String regionalTitle(RegionalLanguage lang) =>
      lang == RegionalLanguage.hindi ? titleHi : titleOr;

  /// Formulas belonging to this category.
  List<FormulaData> get formulas =>
      _allFormulas.where((f) => f.category == name).toList();
}

const _formulaCategories = [
  FormulaCategory(
    name: 'Arithmetic',
    titleOr: 'ଗଣିତ',
    titleHi: 'अंकगणित',
    icon: Icons.calculate_rounded,
    color: Color(0xFF3B82F6), // blue
  ),
  FormulaCategory(
    name: 'Algebra',
    titleOr: 'ବୀଜଗଣିତ',
    titleHi: 'बीजगणित',
    icon: Icons.functions_rounded,
    color: Color(0xFF8B5CF6), // purple
  ),
  FormulaCategory(
    name: 'Geometry',
    titleOr: 'ଜ୍ୟାମିତି',
    titleHi: 'ज्यामिति',
    icon: Icons.category_rounded,
    color: Color(0xFFF59E0B), // amber
  ),
  FormulaCategory(
    name: 'Trigonometry',
    titleOr: 'ତ୍ରିକୋଣମିତି',
    titleHi: 'त्रिकोणमिति',
    icon: Icons.change_history_rounded,
    color: Color(0xFFEF4444), // red
  ),
  FormulaCategory(
    name: 'Science',
    titleOr: 'ବିଜ୍ଞାନ',
    titleHi: 'विज्ञान',
    icon: Icons.science_rounded,
    color: Color(0xFF10B981), // green
  ),
];

FormulaCategory? formulaCategoryByName(String name) {
  for (final c in _formulaCategories) {
    if (c.name == name) return c;
  }
  return null;
}

class MathFormulasScreen extends ConsumerStatefulWidget {
  const MathFormulasScreen({super.key});

  @override
  ConsumerState<MathFormulasScreen> createState() => _MathFormulasScreenState();
}

class _MathFormulasScreenState extends ConsumerState<MathFormulasScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.toLowerCase().trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FormulaData> get _matches => _allFormulas.where((f) {
        return f.titleEn.toLowerCase().contains(_query) ||
            f.titleOr.contains(_query) ||
            f.titleHi.contains(_query) ||
            f.formula.toLowerCase().contains(_query) ||
            f.category.toLowerCase().contains(_query);
      }).toList();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final lang = ref.watch(regionalLanguageProvider);
    final isSearching = _query.isNotEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Math Formulas'),
        actions: const [RegionalLanguageSwitch()],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search all formulas...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
          Expanded(
            child: isSearching
                ? _buildSearchResults(lang)
                : _buildCategoryGrid(context, lang),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(RegionalLanguage lang) {
    final results = _matches;
    if (results.isEmpty) {
      return const Center(child: Text('No formulas found.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: results.length,
      itemBuilder: (context, index) =>
          _FormulaCard(formulaData: results[index], lang: lang),
    );
  }

  Widget _buildCategoryGrid(BuildContext context, RegionalLanguage lang) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GridView.count(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.05,
      children: _formulaCategories.map((category) {
        final count = category.formulas.length;
        return GestureDetector(
          onTap: () => context.push(
            '/learn/math-formulas/category/${category.name}',
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? cs.surface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(category.icon, color: category.color, size: 28),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      category.regionalTitle(lang),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$count formula${count == 1 ? '' : 's'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Detail screen showing all formulas for a single [category], with a search
/// box scoped to just that category.
class FormulaCategoryScreen extends ConsumerStatefulWidget {
  final FormulaCategory category;

  const FormulaCategoryScreen({super.key, required this.category});

  @override
  ConsumerState<FormulaCategoryScreen> createState() =>
      _FormulaCategoryScreenState();
}

class _FormulaCategoryScreenState extends ConsumerState<FormulaCategoryScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.toLowerCase().trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final lang = ref.watch(regionalLanguageProvider);
    final category = widget.category;

    final formulas = category.formulas.where((f) {
      if (_query.isEmpty) return true;
      return f.titleEn.toLowerCase().contains(_query) ||
          f.titleOr.contains(_query) ||
          f.titleHi.contains(_query) ||
          f.formula.toLowerCase().contains(_query);
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('${category.name} / ${category.regionalTitle(lang)}'),
        actions: const [RegionalLanguageSwitch()],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search ${category.name}...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
          Expanded(
            child: formulas.isEmpty
                ? const Center(child: Text('No formulas found.'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: formulas.length + 1,
                    itemBuilder: (context, index) {
                      if (index == formulas.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'More formulas coming soon...',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textMuted,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                          ),
                        );
                      }
                      return _FormulaCard(
                        formulaData: formulas[index],
                        lang: lang,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FormulaCard extends StatelessWidget {
  final FormulaData formulaData;
  final RegionalLanguage lang;

  const _FormulaCard({
    required this.formulaData,
    required this.lang,
  });

  void _openCalculator(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            _CalculatorPage(formulaData: formulaData, lang: lang),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? cs.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openCalculator(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formulaData.titleEn,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formulaData.regionalTitle(lang),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: cs.secondaryContainer.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              formulaData.formula,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                color: cs.onSecondaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CalculatorPage extends StatefulWidget {
  final FormulaData formulaData;
  final RegionalLanguage lang;

  const _CalculatorPage({
    required this.formulaData,
    required this.lang,
  });

  @override
  State<_CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<_CalculatorPage> {
  final Map<String, TextEditingController> _controllers = {};
  String? _result;

  @override
  void initState() {
    super.initState();
    _setupControllers();
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _setupControllers() {
    List<String> keys = [];
    switch (widget.formulaData.type) {
      case FormulaType.simpleInterest: keys = ['P', 'R', 'T']; break;
      case FormulaType.circleArea: keys = ['r']; break;
      case FormulaType.circleCircumference: keys = ['r']; break;
      case FormulaType.pythagoras: keys = ['a', 'b']; break;
      case FormulaType.cylinderVolume: keys = ['r', 'h']; break;
      case FormulaType.quadratic: keys = ['a', 'b', 'c']; break;
      case FormulaType.rectanglePerimeter: keys = ['l', 'w']; break;
      case FormulaType.rectangleArea: keys = ['l', 'w']; break;
      case FormulaType.squarePerimeter: keys = ['a']; break;
      case FormulaType.squareArea: keys = ['a']; break;
      case FormulaType.triangleArea: keys = ['b', 'h']; break;
      case FormulaType.cubeVolume: keys = ['a']; break;
      case FormulaType.cuboidVolume: keys = ['l', 'w', 'h']; break;
      case FormulaType.speedDistanceTime: keys = ['d', 't']; break;
      case FormulaType.fahrenheitToCelsius: keys = ['F']; break;
      case FormulaType.celsiusToFahrenheit: keys = ['C']; break;
      case FormulaType.triangleAreaTrig: keys = ['a', 'b', 'C (deg)']; break;
    }
    for (var key in keys) {
      _controllers[key] = TextEditingController();
      _controllers[key]!.addListener(_calculate);
    }
  }

  void _calculate() {
    setState(() {
      _result = null;
      try {
        switch (widget.formulaData.type) {
          case FormulaType.simpleInterest:
            final p = double.tryParse(_controllers['P']!.text);
            final r = double.tryParse(_controllers['R']!.text);
            final t = double.tryParse(_controllers['T']!.text);
            if (p != null && r != null && t != null) _result = 'SI = ${((p * r * t) / 100).toStringAsFixed(2)}';
            break;
          case FormulaType.circleArea:
            final r = double.tryParse(_controllers['r']!.text);
            if (r != null) _result = 'A = ${(pi * r * r).toStringAsFixed(4)}';
            break;
          case FormulaType.circleCircumference:
            final r = double.tryParse(_controllers['r']!.text);
            if (r != null) _result = 'C = ${(2 * pi * r).toStringAsFixed(4)}';
            break;
          case FormulaType.pythagoras:
            final a = double.tryParse(_controllers['a']!.text);
            final b = double.tryParse(_controllers['b']!.text);
            if (a != null && b != null) _result = 'c = ${sqrt((a * a) + (b * b)).toStringAsFixed(4)}';
            break;
          case FormulaType.cylinderVolume:
            final r = double.tryParse(_controllers['r']!.text);
            final h = double.tryParse(_controllers['h']!.text);
            if (r != null && h != null) _result = 'V = ${(pi * r * r * h).toStringAsFixed(4)}';
            break;
          case FormulaType.quadratic:
            final a = double.tryParse(_controllers['a']!.text);
            final b = double.tryParse(_controllers['b']!.text);
            final c = double.tryParse(_controllers['c']!.text);
            if (a != null && b != null && c != null) {
              if (a == 0) {
                _result = 'Not a quadratic (a cannot be 0)';
                return;
              }
              final d = (b * b) - (4 * a * c);
              if (d > 0) {
                final r1 = (-b + sqrt(d)) / (2 * a);
                final r2 = (-b - sqrt(d)) / (2 * a);
                _result = 'x = ${r1.toStringAsFixed(4)} or x = ${r2.toStringAsFixed(4)}';
              } else if (d == 0) {
                _result = 'x = ${(-b / (2 * a)).toStringAsFixed(4)}';
              } else {
                final real = -b / (2 * a);
                final imag = sqrt(-d) / (2 * a);
                _result = 'x = ${real.toStringAsFixed(4)} ± ${imag.toStringAsFixed(4)}i';
              }
            }
            break;
          case FormulaType.rectanglePerimeter:
            final l = double.tryParse(_controllers['l']!.text);
            final w = double.tryParse(_controllers['w']!.text);
            if (l != null && w != null) _result = 'P = ${(2 * (l + w)).toStringAsFixed(2)}';
            break;
          case FormulaType.rectangleArea:
            final l = double.tryParse(_controllers['l']!.text);
            final w = double.tryParse(_controllers['w']!.text);
            if (l != null && w != null) _result = 'A = ${(l * w).toStringAsFixed(2)}';
            break;
          case FormulaType.squarePerimeter:
            final a = double.tryParse(_controllers['a']!.text);
            if (a != null) _result = 'P = ${(4 * a).toStringAsFixed(2)}';
            break;
          case FormulaType.squareArea:
            final a = double.tryParse(_controllers['a']!.text);
            if (a != null) _result = 'A = ${(a * a).toStringAsFixed(2)}';
            break;
          case FormulaType.triangleArea:
            final b = double.tryParse(_controllers['b']!.text);
            final h = double.tryParse(_controllers['h']!.text);
            if (b != null && h != null) _result = 'A = ${(0.5 * b * h).toStringAsFixed(2)}';
            break;
          case FormulaType.cubeVolume:
            final a = double.tryParse(_controllers['a']!.text);
            if (a != null) _result = 'V = ${(a * a * a).toStringAsFixed(2)}';
            break;
          case FormulaType.cuboidVolume:
            final l = double.tryParse(_controllers['l']!.text);
            final w = double.tryParse(_controllers['w']!.text);
            final h = double.tryParse(_controllers['h']!.text);
            if (l != null && w != null && h != null) _result = 'V = ${(l * w * h).toStringAsFixed(2)}';
            break;
          case FormulaType.speedDistanceTime:
            final d = double.tryParse(_controllers['d']!.text);
            final t = double.tryParse(_controllers['t']!.text);
            if (d != null && t != null && t != 0) _result = 's = ${(d / t).toStringAsFixed(2)}';
            break;
          case FormulaType.fahrenheitToCelsius:
            final f = double.tryParse(_controllers['F']!.text);
            if (f != null) _result = 'C = ${((f - 32) * 5 / 9).toStringAsFixed(2)}°C';
            break;
          case FormulaType.celsiusToFahrenheit:
            final c = double.tryParse(_controllers['C']!.text);
            if (c != null) _result = 'F = ${((c * 9 / 5) + 32).toStringAsFixed(2)}°F';
            break;
          case FormulaType.triangleAreaTrig:
            final a = double.tryParse(_controllers['a']!.text);
            final b = double.tryParse(_controllers['b']!.text);
            final angleDeg = double.tryParse(_controllers['C (deg)']!.text);
            if (a != null && b != null && angleDeg != null) {
              final angleRad = angleDeg * pi / 180;
              _result = 'A = ${(0.5 * a * b * sin(angleRad)).toStringAsFixed(4)}';
            }
            break;
        }
      } catch (e) {
        _result = 'Error in calculation';
      }
    });
  }

  String _getHint(String key) {
    switch (widget.formulaData.type) {
      case FormulaType.simpleInterest:
        if (key == 'P') return 'Principal (e.g. 1000)';
        if (key == 'R') return 'Rate % (e.g. 5)';
        if (key == 'T') return 'Time in years (e.g. 2)';
        break;
      case FormulaType.circleArea:
      case FormulaType.circleCircumference:
        if (key == 'r') return 'Radius (e.g. 5)';
        break;
      case FormulaType.pythagoras:
        if (key == 'a') return 'Side a (e.g. 3)';
        if (key == 'b') return 'Side b (e.g. 4)';
        break;
      case FormulaType.cylinderVolume:
        if (key == 'r') return 'Radius (e.g. 3)';
        if (key == 'h') return 'Height (e.g. 10)';
        break;
      case FormulaType.quadratic:
        if (key == 'a') return 'Coefficient a';
        if (key == 'b') return 'Coefficient b';
        if (key == 'c') return 'Constant c';
        break;
      case FormulaType.rectanglePerimeter:
      case FormulaType.rectangleArea:
        if (key == 'l') return 'Length (e.g. 5)';
        if (key == 'w') return 'Width (e.g. 3)';
        break;
      case FormulaType.squarePerimeter:
      case FormulaType.squareArea:
      case FormulaType.cubeVolume:
        if (key == 'a') return 'Side length (e.g. 4)';
        break;
      case FormulaType.triangleArea:
        if (key == 'b') return 'Base (e.g. 10)';
        if (key == 'h') return 'Height (e.g. 5)';
        break;
      case FormulaType.cuboidVolume:
        if (key == 'l') return 'Length (e.g. 5)';
        if (key == 'w') return 'Width (e.g. 3)';
        if (key == 'h') return 'Height (e.g. 2)';
        break;
      case FormulaType.speedDistanceTime:
        if (key == 'd') return 'Distance (e.g. 100)';
        if (key == 't') return 'Time (e.g. 2)';
        break;
      case FormulaType.fahrenheitToCelsius:
        if (key == 'F') return 'Fahrenheit (e.g. 98.6)';
        break;
      case FormulaType.celsiusToFahrenheit:
        if (key == 'C') return 'Celsius (e.g. 37)';
        break;
      case FormulaType.triangleAreaTrig:
        if (key == 'a') return 'Side a (e.g. 10)';
        if (key == 'b') return 'Side b (e.g. 12)';
        if (key == 'C (deg)') return 'Included Angle (e.g. 30)';
        break;
    }
    return key;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final diagram = widget.formulaData.diagram;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.formulaData.titleEn,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              widget.formulaData.regionalTitle(widget.lang),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Reference material scrolls freely at the top.
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Geometric figure illustrating the formula (geometry only).
                  if (diagram != null) ...[
                    _FormulaDiagramView(diagram: diagram, color: cs.primary),
                    const SizedBox(height: 16),
                  ],

                  // Formula Descriptions (English and Odia)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? cs.surfaceContainerHighest.withValues(alpha: 0.3)
                          : cs.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: cs.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, size: 18, color: cs.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.formulaData.descEn,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: cs.onSurface),
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(height: 1),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.translate, size: 18, color: cs.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.formulaData.regionalDesc(widget.lang),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: cs.onSurface, height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: cs.primary.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      widget.formulaData.formula,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 18,
                        color: cs.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Fixed calculator dock: result sits directly above the inputs and
          // the whole block rides up above the keyboard, so the live result is
          // always visible right next to the fields being edited.
          _CalculatorDock(
            result: _result,
            inputs: [
              for (final e in _controllers.entries)
                _InputField(
                  varKey: e.key,
                  hint: _getHint(e.key),
                  controller: e.value,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A single labeled numeric input used inside the calculator dock.
class _InputField extends StatelessWidget {
  final String varKey;
  final String hint;
  final TextEditingController controller;

  const _InputField({
    required this.varKey,
    required this.hint,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true, signed: true),
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        isDense: true,
        labelText: hint,
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            '$varKey =',
            style: TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: cs.primary,
              fontSize: 16,
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// Fixed bottom dock pairing the live result with the input fields. Because it
/// lives outside the scroll view, the Scaffold lifts it above the keyboard,
/// keeping result and inputs together and always visible.
class _CalculatorDock extends StatelessWidget {
  final String? result;
  final List<Widget> inputs;

  const _CalculatorDock({required this.result, required this.inputs});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ResultBar(result: result),
              const SizedBox(height: 12),
              // One input per row.
              for (int i = 0; i < inputs.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                inputs[i],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Live result card shown inside the calculator dock, directly above the
/// inputs. Highlights when a value is available.
class _ResultBar extends StatelessWidget {
  final String? result;

  const _ResultBar({required this.result});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasResult = result != null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: hasResult ? cs.primary : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
          child: Row(
            children: [
              Text(
                'RESULT',
                style: TextStyle(
                  color: hasResult
                      ? cs.onPrimary.withValues(alpha: 0.8)
                      : AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  result ?? 'Enter values to calculate',
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: hasResult ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: hasResult ? cs.onPrimary : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}

/// Themed container that renders the geometric figure for a formula.
class _FormulaDiagramView extends StatelessWidget {
  final FormulaDiagram diagram;
  final Color color;

  const _FormulaDiagramView({required this.diagram, required this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = cs.onSurface.withValues(alpha: 0.75);

    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? cs.surfaceContainerHighest.withValues(alpha: 0.3)
            : cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.all(20),
      child: CustomPaint(
        painter: FormulaDiagramPainter(
          diagram: diagram,
          stroke: color,
          fill: color.withValues(alpha: 0.12),
          labelColor: labelColor,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

/// Draws simple, labeled geometric figures illustrating a formula's variables.
class FormulaDiagramPainter extends CustomPainter {
  final FormulaDiagram diagram;
  final Color stroke;
  final Color fill;
  final Color labelColor;

  FormulaDiagramPainter({
    required this.diagram,
    required this.stroke,
    required this.fill,
    required this.labelColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;
    final fillPaint = Paint()
      ..color = fill
      ..style = PaintingStyle.fill;
    final dashPaint = Paint()
      ..color = stroke.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    switch (diagram) {
      case FormulaDiagram.circle:
        _drawCircle(canvas, size, strokePaint, fillPaint, dashPaint);
        break;
      case FormulaDiagram.rightTriangle:
        _drawRightTriangle(canvas, size, strokePaint, fillPaint);
        break;
      case FormulaDiagram.triangle:
        _drawTriangle(canvas, size, strokePaint, fillPaint, dashPaint);
        break;
      case FormulaDiagram.triangleTrig:
        _drawTriangleTrig(canvas, size, strokePaint, fillPaint);
        break;
      case FormulaDiagram.rectangle:
        _drawRectangle(canvas, size, strokePaint, fillPaint);
        break;
      case FormulaDiagram.square:
        _drawSquare(canvas, size, strokePaint, fillPaint);
        break;
      case FormulaDiagram.cube:
        _drawCube(canvas, size, strokePaint, fillPaint, dashPaint);
        break;
      case FormulaDiagram.cuboid:
        _drawCuboid(canvas, size, strokePaint, fillPaint, dashPaint);
        break;
      case FormulaDiagram.cylinder:
        _drawCylinder(canvas, size, strokePaint, fillPaint, dashPaint);
        break;
    }
  }

  void _label(Canvas canvas, String text, Offset at,
      {bool italic = true, double fontSize = 15}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: labelColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          fontFamily: 'serif',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawCircle(Canvas canvas, Size size, Paint s, Paint f, Paint dash) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 8;
    canvas.drawCircle(center, radius, f);
    canvas.drawCircle(center, radius, s);
    // radius line
    final edge = center + Offset(radius, 0);
    canvas.drawLine(center, edge, dash);
    canvas.drawCircle(center, 3, Paint()..color = stroke);
    _label(canvas, 'r', Offset(center.dx + radius / 2, center.dy - 12));
  }

  void _drawRightTriangle(Canvas canvas, Size size, Paint s, Paint f) {
    final left = 20.0;
    final bottom = size.height - 24;
    final top = 24.0;
    final right = size.width - 24;
    final p1 = Offset(left, bottom); // right-angle corner
    final p2 = Offset(right, bottom);
    final p3 = Offset(left, top);
    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..close();
    canvas.drawPath(path, f);
    canvas.drawPath(path, s);
    // right-angle marker
    const m = 12.0;
    canvas.drawPath(
      Path()
        ..moveTo(p1.dx + m, p1.dy)
        ..lineTo(p1.dx + m, p1.dy - m)
        ..lineTo(p1.dx, p1.dy - m),
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    _label(canvas, 'b', Offset((p1.dx + p2.dx) / 2, bottom + 12));
    _label(canvas, 'a', Offset(left - 12, (p1.dy + p3.dy) / 2));
    _label(canvas, 'c', Offset((p2.dx + p3.dx) / 2 + 6, (p2.dy + p3.dy) / 2 - 6));
  }

  void _drawTriangle(Canvas canvas, Size size, Paint s, Paint f, Paint dash) {
    final left = 24.0;
    final right = size.width - 24;
    final bottom = size.height - 24;
    final apex = Offset(size.width * 0.42, 20);
    final p1 = Offset(left, bottom);
    final p2 = Offset(right, bottom);
    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(apex.dx, apex.dy)
      ..close();
    canvas.drawPath(path, f);
    canvas.drawPath(path, s);
    // height (dashed from apex to base)
    final foot = Offset(apex.dx, bottom);
    canvas.drawLine(apex, foot, dash);
    _label(canvas, 'h', Offset(apex.dx + 12, (apex.dy + bottom) / 2));
    _label(canvas, 'b', Offset((p1.dx + p2.dx) / 2, bottom + 12));
  }

  void _drawTriangleTrig(Canvas canvas, Size size, Paint s, Paint f) {
    final left = 28.0;
    final bottom = size.height - 24;
    final apex = Offset(size.width * 0.62, 20);
    final p1 = Offset(left, bottom);
    final p2 = Offset(size.width - 24, bottom);
    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(apex.dx, apex.dy)
      ..close();
    canvas.drawPath(path, f);
    canvas.drawPath(path, s);
    // included angle marker at p1
    canvas.drawArc(
      Rect.fromCircle(center: p1, radius: 22),
      -atan2(apex.dy - p1.dy, apex.dx - p1.dx),
      atan2(apex.dy - p1.dy, apex.dx - p1.dx),
      false,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    _label(canvas, 'C', Offset(p1.dx + 32, bottom - 14), italic: false, fontSize: 13);
    _label(canvas, 'b', Offset((p1.dx + p2.dx) / 2, bottom + 12));
    _label(canvas, 'a', Offset((p1.dx + apex.dx) / 2 - 12, (p1.dy + apex.dy) / 2));
  }

  void _drawRectangle(Canvas canvas, Size size, Paint s, Paint f) {
    final rect = Rect.fromLTWH(
        24, size.height * 0.28, size.width - 48, size.height * 0.44);
    canvas.drawRect(rect, f);
    canvas.drawRect(rect, s);
    _label(canvas, 'l', Offset(rect.center.dx, rect.bottom + 12));
    _label(canvas, 'w', Offset(rect.left - 12, rect.center.dy));
  }

  void _drawSquare(Canvas canvas, Size size, Paint s, Paint f) {
    final side = min(size.width, size.height) - 48;
    final rect = Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: side,
        height: side);
    canvas.drawRect(rect, f);
    canvas.drawRect(rect, s);
    _label(canvas, 'a', Offset(rect.center.dx, rect.bottom + 12));
    _label(canvas, 'a', Offset(rect.left - 12, rect.center.dy));
  }

  void _drawCube(Canvas canvas, Size size, Paint s, Paint f, Paint dash) {
    final side = min(size.width, size.height) - 70;
    final ox = (size.width - side) / 2 - 14;
    final oy = (size.height - side) / 2 + 8;
    const d = 26.0; // depth offset
    final front = Rect.fromLTWH(ox, oy, side, side);
    _drawBox(canvas, front, d, s, f, dash);
    _label(canvas, 'a', Offset(front.center.dx, front.bottom + 12));
    _label(canvas, 'a', Offset(front.left - 12, front.center.dy));
  }

  void _drawCuboid(Canvas canvas, Size size, Paint s, Paint f, Paint dash) {
    final w = size.width - 80;
    final h = size.height * 0.4;
    final ox = 24.0;
    final oy = (size.height - h) / 2;
    const d = 30.0;
    final front = Rect.fromLTWH(ox, oy, w, h);
    _drawBox(canvas, front, d, s, f, dash);
    _label(canvas, 'l', Offset(front.center.dx, front.bottom + 12));
    _label(canvas, 'w', Offset(front.left - 12, front.center.dy));
    _label(canvas, 'h', Offset(front.right + d / 2 + 8, front.top + d / 2 - 4));
  }

  /// Shared helper: an isometric-ish box from a [front] face with depth [d].
  void _drawBox(Canvas canvas, Rect front, double d, Paint s, Paint f, Paint dash) {
    final off = Offset(d, -d);
    // back (dashed, hidden edges)
    final back = front.shift(off);
    canvas.drawLine(back.bottomLeft, back.bottomRight, dash);
    canvas.drawLine(back.bottomLeft, back.topLeft, dash);
    canvas.drawLine(front.bottomLeft, back.bottomLeft, dash);
    // top + right faces (filled)
    final topFace = Path()
      ..moveTo(front.left, front.top)
      ..lineTo(front.right, front.top)
      ..lineTo(back.right, back.top)
      ..lineTo(back.left, back.top)
      ..close();
    final rightFace = Path()
      ..moveTo(front.right, front.top)
      ..lineTo(front.right, front.bottom)
      ..lineTo(back.right, back.bottom)
      ..lineTo(back.right, back.top)
      ..close();
    canvas.drawPath(topFace, f);
    canvas.drawPath(rightFace, f);
    canvas.drawRect(front, f);
    // visible edges
    canvas.drawRect(front, s);
    canvas.drawPath(topFace, s);
    canvas.drawPath(rightFace, s);
  }

  void _drawCylinder(Canvas canvas, Size size, Paint s, Paint f, Paint dash) {
    final cx = size.width / 2;
    final rx = (size.width - 80) / 2;
    final ry = 14.0;
    final topY = 24.0;
    final botY = size.height - 28;
    final topRect = Rect.fromCenter(
        center: Offset(cx, topY), width: rx * 2, height: ry * 2);
    final botRect = Rect.fromCenter(
        center: Offset(cx, botY), width: rx * 2, height: ry * 2);
    // body fill
    final body = Path()
      ..moveTo(cx - rx, topY)
      ..lineTo(cx - rx, botY)
      ..arcTo(botRect, pi, -pi, false)
      ..lineTo(cx + rx, topY)
      ..close();
    canvas.drawPath(body, f);
    // sides
    canvas.drawLine(Offset(cx - rx, topY), Offset(cx - rx, botY), s);
    canvas.drawLine(Offset(cx + rx, topY), Offset(cx + rx, botY), s);
    // bottom ellipse: front arc solid, back arc dashed
    canvas.drawArc(botRect, 0, pi, false, s);
    canvas.drawArc(botRect, pi, pi, false, dash);
    // top ellipse (full, on top)
    canvas.drawOval(topRect, f);
    canvas.drawOval(topRect, s);
    // radius on top
    canvas.drawLine(Offset(cx, topY), Offset(cx + rx, topY), dash);
    _label(canvas, 'r', Offset(cx + rx / 2, topY - 12));
    _label(canvas, 'h', Offset(cx + rx + 14, (topY + botY) / 2));
  }

  @override
  bool shouldRepaint(covariant FormulaDiagramPainter old) =>
      old.diagram != diagram ||
      old.stroke != stroke ||
      old.fill != fill ||
      old.labelColor != labelColor;
}
