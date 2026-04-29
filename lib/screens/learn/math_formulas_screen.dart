import 'dart:math';
import 'package:flutter/material.dart';
import '../../app/theme.dart';

class FormulaData {
  final String title;
  final String formula;
  final _FormulaType type;
  final String category;
  final String descEn;
  final String descOr;
  
  const FormulaData({
    required this.title, 
    required this.formula, 
    required this.type,
    required this.category,
    required this.descEn,
    required this.descOr,
  });
}

enum _FormulaType {
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
    title: 'Simple Interest (ସରଳ ସୁଧ)', 
    formula: 'SI = (P × R × T) / 100', 
    type: _FormulaType.simpleInterest,
    category: 'Arithmetic',
    descEn: 'Calculates the simple interest earned on a principal sum over a period of time.',
    descOr: 'ଏକ ନିର୍ଦ୍ଦିଷ୍ଟ ସମୟ ପାଇଁ ମୂଳଧନ ଉପରେ ମିଳୁଥିବା ସରଳ ସୁଧ ହିସାବ କରେ।',
  ),
  
  // Algebra
  FormulaData(
    title: 'Quadratic Equation (ଦ୍ୱିଘାତ ସମୀକରଣ)', 
    formula: 'x = (-b ± √(b² - 4ac)) / 2a', 
    type: _FormulaType.quadratic,
    category: 'Algebra',
    descEn: 'Finds the unknown variable x (roots) in a second-degree polynomial equation.',
    descOr: 'ଏକ ଦ୍ୱିଘାତ ସମୀକରଣରେ ଅଜ୍ଞାତ ରାଶି x ର ମୂଲ୍ୟ (ମୂଳ) ନିର୍ଣ୍ଣୟ କରେ।',
  ),

  // Geometry
  FormulaData(
    title: 'Area of a Circle (ବୃତ୍ତର କ୍ଷେତ୍ରଫଳ)', 
    formula: 'A = πr²', 
    type: _FormulaType.circleArea,
    category: 'Geometry',
    descEn: 'Calculates the total 2D space enclosed within a circle.',
    descOr: 'ଏକ ବୃତ୍ତ ମଧ୍ୟରେ ଥିବା ସମୁଦାୟ ସ୍ଥାନ ବା କ୍ଷେତ୍ରଫଳ ହିସାବ କରେ।',
  ),
  FormulaData(
    title: 'Circumference of Circle (ବୃତ୍ତର ପରିଧି)', 
    formula: 'C = 2πr', 
    type: _FormulaType.circleCircumference,
    category: 'Geometry',
    descEn: 'Calculates the total length of the outer boundary of a circle.',
    descOr: 'ଏକ ବୃତ୍ତର ଚାରିପାଖର ସମୁଦାୟ ଦୈର୍ଘ୍ୟ ବା ପରିଧି ହିସାବ କରେ।',
  ),
  FormulaData(
    title: 'Pythagorean Theorem (ପିଥାଗୋରାସ୍ ଉପପାଦ୍ୟ)', 
    formula: 'c = √(a² + b²)', 
    type: _FormulaType.pythagoras,
    category: 'Geometry',
    descEn: 'Finds the longest side (hypotenuse) of a right-angled triangle.',
    descOr: 'ଏକ ସମକୋଣୀ ତ୍ରିଭୁଜର ସବୁଠାରୁ ବଡ଼ ବାହୁ (କର୍ଣ୍ଣ) ନିର୍ଣ୍ଣୟ କରେ।',
  ),
  FormulaData(
    title: 'Volume of a Cylinder (ସିଲିଣ୍ଡରର ଆୟତନ)', 
    formula: 'V = πr²h', 
    type: _FormulaType.cylinderVolume,
    category: 'Geometry',
    descEn: 'Calculates the total 3D space occupied by a cylinder.',
    descOr: 'ଏକ ସିଲିଣ୍ଡର ଦ୍ୱାରା ଅଧିକାର କରାଯାଇଥିବା ସମୁଦାୟ ଆୟତନ ହିସାବ କରେ।',
  ),
  FormulaData(
    title: 'Perimeter of Rectangle (ଆୟତକ୍ଷେତ୍ରର ପରିସୀମା)', 
    formula: 'P = 2(l + w)', 
    type: _FormulaType.rectanglePerimeter,
    category: 'Geometry',
    descEn: 'Calculates the total length of the outer boundary of a rectangle.',
    descOr: 'ଏକ ଆୟତକ୍ଷେତ୍ରର ଚାରିପାଖର ସମୁଦାୟ ଦୈର୍ଘ୍ୟ ବା ପରିସୀମା ହିସାବ କରେ।',
  ),
  FormulaData(
    title: 'Area of Rectangle (ଆୟତକ୍ଷେତ୍ରର କ୍ଷେତ୍ରଫଳ)', 
    formula: 'A = l × w', 
    type: _FormulaType.rectangleArea,
    category: 'Geometry',
    descEn: 'Calculates the 2D surface area of a rectangle.',
    descOr: 'ଏକ ଆୟତକ୍ଷେତ୍ରର ପୃଷ୍ଠତଳର ସମୁଦାୟ କ୍ଷେତ୍ରଫଳ ହିସାବ କରେ।',
  ),
  FormulaData(
    title: 'Perimeter of Square (ବର୍ଗକ୍ଷେତ୍ରର ପରିସୀମା)', 
    formula: 'P = 4a', 
    type: _FormulaType.squarePerimeter,
    category: 'Geometry',
    descEn: 'Calculates the total boundary length of a square.',
    descOr: 'ଏକ ବର୍ଗକ୍ଷେତ୍ରର ଚାରିପାଖର ସମୁଦାୟ ଦୈର୍ଘ୍ୟ ହିସାବ କରେ।',
  ),
  FormulaData(
    title: 'Area of Square (ବର୍ଗକ୍ଷେତ୍ରର କ୍ଷେତ୍ରଫଳ)', 
    formula: 'A = a²', 
    type: _FormulaType.squareArea,
    category: 'Geometry',
    descEn: 'Calculates the surface area enclosed by a square.',
    descOr: 'ଏକ ବର୍ଗକ୍ଷେତ୍ର ମଧ୍ୟରେ ଥିବା ସମୁଦାୟ କ୍ଷେତ୍ରଫଳ ହିସାବ କରେ।',
  ),
  FormulaData(
    title: 'Area of Triangle (ତ୍ରିଭୁଜର କ୍ଷେତ୍ରଫଳ)', 
    formula: 'A = ½ × b × h', 
    type: _FormulaType.triangleArea,
    category: 'Geometry',
    descEn: 'Calculates the space enclosed by a triangle using its base and height.',
    descOr: 'ଭୂମି ଏବଂ ଉଚ୍ଚତା ବ୍ୟବହାର କରି ଏକ ତ୍ରିଭୁଜର କ୍ଷେତ୍ରଫଳ ହିସାବ କରେ।',
  ),
  FormulaData(
    title: 'Volume of Cube (ଘନର ଆୟତନ)', 
    formula: 'V = a³', 
    type: _FormulaType.cubeVolume,
    category: 'Geometry',
    descEn: 'Calculates the total 3D space occupied by a cube.',
    descOr: 'ଏକ ଘନ (Cube) ର ସମୁଦାୟ ଆୟତନ ହିସାବ କରେ।',
  ),
  FormulaData(
    title: 'Volume of Cuboid (ଆୟତଘନର ଆୟତନ)', 
    formula: 'V = l × w × h', 
    type: _FormulaType.cuboidVolume,
    category: 'Geometry',
    descEn: 'Calculates the 3D space enclosed by a rectangular cuboid.',
    descOr: 'ଏକ ଆୟତଘନ (Cuboid) ର ସମୁଦାୟ ଆୟତନ ହିସାବ କରେ।',
  ),

  // Trigonometry
  FormulaData(
    title: 'Area of Triangle (Trig) (ତ୍ରିଭୁଜର କ୍ଷେତ୍ରଫଳ)', 
    formula: 'A = ½ ab sin(C)', 
    type: _FormulaType.triangleAreaTrig,
    category: 'Trigonometry',
    descEn: 'Calculates the area of a triangle using two sides and the included angle.',
    descOr: 'ଦୁଇଟି ବାହୁ ଏବଂ ସେମାନଙ୍କ ମଧ୍ୟବର୍ତ୍ତୀ କୋଣ ବ୍ୟବହାର କରି ତ୍ରିଭୁଜର କ୍ଷେତ୍ରଫଳ ହିସାବ କରେ।',
  ),

  // Science
  FormulaData(
    title: 'Speed, Distance, Time (ବେଗ, ଦୂରତା, ସମୟ)', 
    formula: 's = d / t', 
    type: _FormulaType.speedDistanceTime,
    category: 'Science',
    descEn: 'Calculates the speed of an object based on distance traveled over time.',
    descOr: 'ଦୂରତା ଏବଂ ସମୟ ଉପରେ ଭିତ୍ତି କରି ଏକ ବସ୍ତୁର ବେଗ ହିସାବ କରେ।',
  ),
  FormulaData(
    title: 'Fahrenheit to Celsius (ଫାରେନହାଇଟରୁ ସେଲସିୟସ)', 
    formula: 'C = (F - 32) × 5/9', 
    type: _FormulaType.fahrenheitToCelsius,
    category: 'Science',
    descEn: 'Converts temperature from the Fahrenheit scale to the Celsius scale.',
    descOr: 'ତାପମାତ୍ରାକୁ ଫାରେନହାଇଟ୍ ରୁ ସେଲସିୟସ୍ ସ୍କେଲ୍ କୁ ପରିବର୍ତ୍ତନ କରେ।',
  ),
  FormulaData(
    title: 'Celsius to Fahrenheit (ସେଲସିୟସରୁ ଫାରେନହାଇଟ)', 
    formula: 'F = (C × 9/5) + 32', 
    type: _FormulaType.celsiusToFahrenheit,
    category: 'Science',
    descEn: 'Converts temperature from the Celsius scale to the Fahrenheit scale.',
    descOr: 'ତାପମାତ୍ରାକୁ ସେଲସିୟସ୍ ରୁ ଫାରେନହାଇଟ୍ ସ୍କେଲ୍ କୁ ପରିବର୍ତ୍ତନ କରେ।',
  ),
];

class MathFormulasScreen extends StatefulWidget {
  const MathFormulasScreen({super.key});

  @override
  State<MathFormulasScreen> createState() => _MathFormulasScreenState();
}

class _MathFormulasScreenState extends State<MathFormulasScreen> {
  final _searchController = TextEditingController();
  List<FormulaData> _filteredFormulas = _allFormulas;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Arithmetic',
    'Algebra',
    'Geometry',
    'Trigonometry',
    'Science'
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterFormulas);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterFormulas() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFormulas = _allFormulas.where((f) {
        final matchesQuery = f.title.toLowerCase().contains(query) || f.formula.toLowerCase().contains(query);
        final matchesCategory = _selectedCategory == 'All' || f.category == _selectedCategory;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _filterFormulas();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Math Formulas'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search formulas...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
          
          // Categories
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      if (selected) _onCategorySelected(category);
                    },
                    backgroundColor: cs.surface,
                    selectedColor: cs.primaryContainer,
                    checkmarkColor: cs.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? cs.onPrimaryContainer : AppColors.textMuted,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? cs.primary : cs.outlineVariant,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: _filteredFormulas.isEmpty
                ? const Center(child: Text('No formulas found.'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: _filteredFormulas.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _filteredFormulas.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'More formulas coming soon...',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textMuted,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        );
                      }
                      final f = _filteredFormulas[index];
                      return _FormulaCard(formulaData: f);
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

  const _FormulaCard({
    required this.formulaData,
  });

  void _openCalculator(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CalculatorSheet(formulaData: formulaData),
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
                        formulaData.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
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

class _CalculatorSheet extends StatefulWidget {
  final FormulaData formulaData;

  const _CalculatorSheet({
    required this.formulaData,
  });

  @override
  State<_CalculatorSheet> createState() => _CalculatorSheetState();
}

class _CalculatorSheetState extends State<_CalculatorSheet> {
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
      case _FormulaType.simpleInterest: keys = ['P', 'R', 'T']; break;
      case _FormulaType.circleArea: keys = ['r']; break;
      case _FormulaType.circleCircumference: keys = ['r']; break;
      case _FormulaType.pythagoras: keys = ['a', 'b']; break;
      case _FormulaType.cylinderVolume: keys = ['r', 'h']; break;
      case _FormulaType.quadratic: keys = ['a', 'b', 'c']; break;
      case _FormulaType.rectanglePerimeter: keys = ['l', 'w']; break;
      case _FormulaType.rectangleArea: keys = ['l', 'w']; break;
      case _FormulaType.squarePerimeter: keys = ['a']; break;
      case _FormulaType.squareArea: keys = ['a']; break;
      case _FormulaType.triangleArea: keys = ['b', 'h']; break;
      case _FormulaType.cubeVolume: keys = ['a']; break;
      case _FormulaType.cuboidVolume: keys = ['l', 'w', 'h']; break;
      case _FormulaType.speedDistanceTime: keys = ['d', 't']; break;
      case _FormulaType.fahrenheitToCelsius: keys = ['F']; break;
      case _FormulaType.celsiusToFahrenheit: keys = ['C']; break;
      case _FormulaType.triangleAreaTrig: keys = ['a', 'b', 'C (deg)']; break;
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
          case _FormulaType.simpleInterest:
            final p = double.tryParse(_controllers['P']!.text);
            final r = double.tryParse(_controllers['R']!.text);
            final t = double.tryParse(_controllers['T']!.text);
            if (p != null && r != null && t != null) _result = 'SI = ${((p * r * t) / 100).toStringAsFixed(2)}';
            break;
          case _FormulaType.circleArea:
            final r = double.tryParse(_controllers['r']!.text);
            if (r != null) _result = 'A = ${(pi * r * r).toStringAsFixed(4)}';
            break;
          case _FormulaType.circleCircumference:
            final r = double.tryParse(_controllers['r']!.text);
            if (r != null) _result = 'C = ${(2 * pi * r).toStringAsFixed(4)}';
            break;
          case _FormulaType.pythagoras:
            final a = double.tryParse(_controllers['a']!.text);
            final b = double.tryParse(_controllers['b']!.text);
            if (a != null && b != null) _result = 'c = ${sqrt((a * a) + (b * b)).toStringAsFixed(4)}';
            break;
          case _FormulaType.cylinderVolume:
            final r = double.tryParse(_controllers['r']!.text);
            final h = double.tryParse(_controllers['h']!.text);
            if (r != null && h != null) _result = 'V = ${(pi * r * r * h).toStringAsFixed(4)}';
            break;
          case _FormulaType.quadratic:
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
          case _FormulaType.rectanglePerimeter:
            final l = double.tryParse(_controllers['l']!.text);
            final w = double.tryParse(_controllers['w']!.text);
            if (l != null && w != null) _result = 'P = ${(2 * (l + w)).toStringAsFixed(2)}';
            break;
          case _FormulaType.rectangleArea:
            final l = double.tryParse(_controllers['l']!.text);
            final w = double.tryParse(_controllers['w']!.text);
            if (l != null && w != null) _result = 'A = ${(l * w).toStringAsFixed(2)}';
            break;
          case _FormulaType.squarePerimeter:
            final a = double.tryParse(_controllers['a']!.text);
            if (a != null) _result = 'P = ${(4 * a).toStringAsFixed(2)}';
            break;
          case _FormulaType.squareArea:
            final a = double.tryParse(_controllers['a']!.text);
            if (a != null) _result = 'A = ${(a * a).toStringAsFixed(2)}';
            break;
          case _FormulaType.triangleArea:
            final b = double.tryParse(_controllers['b']!.text);
            final h = double.tryParse(_controllers['h']!.text);
            if (b != null && h != null) _result = 'A = ${(0.5 * b * h).toStringAsFixed(2)}';
            break;
          case _FormulaType.cubeVolume:
            final a = double.tryParse(_controllers['a']!.text);
            if (a != null) _result = 'V = ${(a * a * a).toStringAsFixed(2)}';
            break;
          case _FormulaType.cuboidVolume:
            final l = double.tryParse(_controllers['l']!.text);
            final w = double.tryParse(_controllers['w']!.text);
            final h = double.tryParse(_controllers['h']!.text);
            if (l != null && w != null && h != null) _result = 'V = ${(l * w * h).toStringAsFixed(2)}';
            break;
          case _FormulaType.speedDistanceTime:
            final d = double.tryParse(_controllers['d']!.text);
            final t = double.tryParse(_controllers['t']!.text);
            if (d != null && t != null && t != 0) _result = 's = ${(d / t).toStringAsFixed(2)}';
            break;
          case _FormulaType.fahrenheitToCelsius:
            final f = double.tryParse(_controllers['F']!.text);
            if (f != null) _result = 'C = ${((f - 32) * 5 / 9).toStringAsFixed(2)}°C';
            break;
          case _FormulaType.celsiusToFahrenheit:
            final c = double.tryParse(_controllers['C']!.text);
            if (c != null) _result = 'F = ${((c * 9 / 5) + 32).toStringAsFixed(2)}°F';
            break;
          case _FormulaType.triangleAreaTrig:
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
      case _FormulaType.simpleInterest:
        if (key == 'P') return 'Principal (e.g. 1000)';
        if (key == 'R') return 'Rate % (e.g. 5)';
        if (key == 'T') return 'Time in years (e.g. 2)';
        break;
      case _FormulaType.circleArea:
      case _FormulaType.circleCircumference:
        if (key == 'r') return 'Radius (e.g. 5)';
        break;
      case _FormulaType.pythagoras:
        if (key == 'a') return 'Side a (e.g. 3)';
        if (key == 'b') return 'Side b (e.g. 4)';
        break;
      case _FormulaType.cylinderVolume:
        if (key == 'r') return 'Radius (e.g. 3)';
        if (key == 'h') return 'Height (e.g. 10)';
        break;
      case _FormulaType.quadratic:
        if (key == 'a') return 'Coefficient a';
        if (key == 'b') return 'Coefficient b';
        if (key == 'c') return 'Constant c';
        break;
      case _FormulaType.rectanglePerimeter:
      case _FormulaType.rectangleArea:
        if (key == 'l') return 'Length (e.g. 5)';
        if (key == 'w') return 'Width (e.g. 3)';
        break;
      case _FormulaType.squarePerimeter:
      case _FormulaType.squareArea:
      case _FormulaType.cubeVolume:
        if (key == 'a') return 'Side length (e.g. 4)';
        break;
      case _FormulaType.triangleArea:
        if (key == 'b') return 'Base (e.g. 10)';
        if (key == 'h') return 'Height (e.g. 5)';
        break;
      case _FormulaType.cuboidVolume:
        if (key == 'l') return 'Length (e.g. 5)';
        if (key == 'w') return 'Width (e.g. 3)';
        if (key == 'h') return 'Height (e.g. 2)';
        break;
      case _FormulaType.speedDistanceTime:
        if (key == 'd') return 'Distance (e.g. 100)';
        if (key == 't') return 'Time (e.g. 2)';
        break;
      case _FormulaType.fahrenheitToCelsius:
        if (key == 'F') return 'Fahrenheit (e.g. 98.6)';
        break;
      case _FormulaType.celsiusToFahrenheit:
        if (key == 'C') return 'Celsius (e.g. 37)';
        break;
      case _FormulaType.triangleAreaTrig:
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

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.formulaData.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Formula Descriptions (English and Odia)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? cs.surfaceContainerHighest.withValues(alpha: 0.3) : cs.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
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
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: cs.onSurface,
                          ),
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
                          widget.formulaData.descOr,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: cs.onSurface,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
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
            const SizedBox(height: 24),
            ..._controllers.entries.map((e) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextField(
                  controller: e.value,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  decoration: InputDecoration(
                    labelText: _getHint(e.key),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        '${e.key} =',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _result != null ? cs.primary : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'Result',
                    style: TextStyle(
                      color: _result != null ? cs.onPrimary.withValues(alpha: 0.8) : AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _result ?? 'Enter values to calculate',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _result != null ? cs.onPrimary : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
