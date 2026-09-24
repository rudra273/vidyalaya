import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../data/science/periodic_table_data.dart';
import '../../providers/regional_language_provider.dart';
import '../../widgets/regional_language_switch.dart';

// ─── Category metadata ───
// Single source of truth for category label + color, shared by the grid cells,
// the legend, and the detail sheet.
class _CategoryInfo {
  final String label;
  final Color color;
  const _CategoryInfo(this.label, this.color);
}

const Map<String, _CategoryInfo> _categoryInfo = {
  'alkali_metal': _CategoryInfo('Alkali Metal', Colors.orange),
  'alkaline_earth': _CategoryInfo('Alkaline Earth', Colors.amber),
  'transition_metal': _CategoryInfo('Transition Metal', Colors.blue),
  'post_transition': _CategoryInfo('Post-transition', Colors.blueGrey),
  'metalloid': _CategoryInfo('Metalloid', Colors.teal),
  'nonmetal': _CategoryInfo('Nonmetal', Colors.lightGreen),
  'halogen': _CategoryInfo('Halogen', Colors.cyan),
  'noble_gas': _CategoryInfo('Noble Gas', Colors.purpleAccent),
  'lanthanide': _CategoryInfo('Lanthanide', Colors.pinkAccent),
  'actinide': _CategoryInfo('Actinide', Colors.deepPurpleAccent),
  'unknown': _CategoryInfo('Unknown', Colors.grey),
};

Color _categoryColor(String category) =>
    _categoryInfo[category]?.color ?? Colors.grey;

String _categoryLabel(String category, RegionalLanguage language) {
  final labels = switch (language) {
    RegionalLanguage.english => const {
      'alkali_metal': 'Alkali Metal',
      'alkaline_earth': 'Alkaline Earth',
      'transition_metal': 'Transition Metal',
      'post_transition': 'Post-transition Metal',
      'metalloid': 'Metalloid',
      'nonmetal': 'Nonmetal',
      'halogen': 'Halogen',
      'noble_gas': 'Noble Gas',
      'lanthanide': 'Lanthanide',
      'actinide': 'Actinide',
      'unknown': 'Unknown',
    },
    RegionalLanguage.hindi => const {
      'alkali_metal': 'क्षार धातु',
      'alkaline_earth': 'क्षारीय मृदा धातु',
      'transition_metal': 'संक्रमण धातु',
      'post_transition': 'संक्रमण-पश्च धातु',
      'metalloid': 'उपधातु',
      'nonmetal': 'अधातु',
      'halogen': 'हैलोजन',
      'noble_gas': 'उत्कृष्ट गैस',
      'lanthanide': 'लैंथेनाइड',
      'actinide': 'ऐक्टिनाइड',
      'unknown': 'अज्ञात',
    },
    RegionalLanguage.odia => const {
      'alkali_metal': 'କ୍ଷାର ଧାତୁ',
      'alkaline_earth': 'କ୍ଷାରୀୟ ମୃତ୍ତିକା ଧାତୁ',
      'transition_metal': 'ସଂକ୍ରମଣ ଧାତୁ',
      'post_transition': 'ସଂକ୍ରମଣ-ପର ଧାତୁ',
      'metalloid': 'ଉପଧାତୁ',
      'nonmetal': 'ଅଧାତୁ',
      'halogen': 'ହାଲୋଜେନ୍',
      'noble_gas': 'ନିଷ୍କ୍ରିୟ ଗ୍ୟାସ',
      'lanthanide': 'ଲାନ୍ଥାନାଇଡ୍',
      'actinide': 'ଆକ୍ଟିନାଇଡ୍',
      'unknown': 'ଅଜଣା',
    },
  };
  return labels[category] ?? _categoryInfo[category]?.label ?? category;
}

String _stateLabel(String state, RegionalLanguage language) {
  final labels = switch (language) {
    RegionalLanguage.english => const {
      'Gas': 'Gas',
      'Liquid': 'Liquid',
      'Solid': 'Solid',
      'Unknown': 'Unknown',
    },
    RegionalLanguage.hindi => const {
      'Gas': 'गैस',
      'Liquid': 'द्रव',
      'Solid': 'ठोस',
      'Unknown': 'अज्ञात',
    },
    RegionalLanguage.odia => const {
      'Gas': 'ଗ୍ୟାସ',
      'Liquid': 'ତରଳ',
      'Solid': 'କଠିନ',
      'Unknown': 'ଅଜଣା',
    },
  };
  return labels[state] ?? state;
}

class _PeriodicTableCopy {
  const _PeriodicTableCopy(this.language);

  final RegionalLanguage language;

  String get searchHint => switch (language) {
    RegionalLanguage.english => 'Search name, symbol or number…',
    RegionalLanguage.hindi => 'नाम, प्रतीक या संख्या खोजें…',
    RegionalLanguage.odia => 'ନାମ, ସଙ୍କେତ କିମ୍ବା ସଂଖ୍ୟା ଖୋଜନ୍ତୁ…',
  };

  String get closeSearch => switch (language) {
    RegionalLanguage.english => 'Close search',
    RegionalLanguage.hindi => 'खोज बंद करें',
    RegionalLanguage.odia => 'ସନ୍ଧାନ ବନ୍ଦ କରନ୍ତୁ',
  };

  String get search => switch (language) {
    RegionalLanguage.english => 'Search',
    RegionalLanguage.hindi => 'खोजें',
    RegionalLanguage.odia => 'ସନ୍ଧାନ',
  };

  String get noElementsFound => switch (language) {
    RegionalLanguage.english => 'No elements found',
    RegionalLanguage.hindi => 'कोई तत्व नहीं मिला',
    RegionalLanguage.odia => 'କୌଣସି ମୌଳ ମିଳିଲା ନାହିଁ',
  };

  String atomicNumber(int number) => switch (language) {
    RegionalLanguage.english => 'Atomic Number: $number',
    RegionalLanguage.hindi => 'परमाणु क्रमांक: $number',
    RegionalLanguage.odia => 'ପରମାଣୁ କ୍ରମାଙ୍କ: $number',
  };

  String get atomicMass => switch (language) {
    RegionalLanguage.english => 'Atomic Mass',
    RegionalLanguage.hindi => 'परमाणु द्रव्यमान',
    RegionalLanguage.odia => 'ପରମାଣୁ ଭର',
  };

  String get state => switch (language) {
    RegionalLanguage.english => 'State',
    RegionalLanguage.hindi => 'अवस्था',
    RegionalLanguage.odia => 'ଅବସ୍ଥା',
  };

  String get valency => switch (language) {
    RegionalLanguage.english => 'Valency',
    RegionalLanguage.hindi => 'संयोजकता',
    RegionalLanguage.odia => 'ଯୋଜ୍ୟତା',
  };

  String get group => switch (language) {
    RegionalLanguage.english => 'Group',
    RegionalLanguage.hindi => 'समूह',
    RegionalLanguage.odia => 'ଗୋଷ୍ଠୀ',
  };

  String get period => switch (language) {
    RegionalLanguage.english => 'Period',
    RegionalLanguage.hindi => 'आवर्त',
    RegionalLanguage.odia => 'ପର୍ଯ୍ୟାୟ',
  };

  String get category => switch (language) {
    RegionalLanguage.english => 'Category',
    RegionalLanguage.hindi => 'श्रेणी',
    RegionalLanguage.odia => 'ଶ୍ରେଣୀ',
  };

  String get electronsPerShell => switch (language) {
    RegionalLanguage.english => 'Electrons per shell',
    RegionalLanguage.hindi => 'प्रति कोश इलेक्ट्रॉन',
    RegionalLanguage.odia => 'ପ୍ରତି କକ୍ଷରେ ଇଲେକ୍ଟ୍ରନ୍',
  };

  String shell(int number) => switch (language) {
    RegionalLanguage.english => 'Shell $number',
    RegionalLanguage.hindi => 'कोश $number',
    RegionalLanguage.odia => 'କକ୍ଷ $number',
  };

  String get physicalProperties => switch (language) {
    RegionalLanguage.english => 'Physical properties',
    RegionalLanguage.hindi => 'भौतिक गुण',
    RegionalLanguage.odia => 'ଭୌତିକ ଗୁଣଧର୍ମ',
  };

  String get melting => switch (language) {
    RegionalLanguage.english => 'Melting',
    RegionalLanguage.hindi => 'गलनांक',
    RegionalLanguage.odia => 'ଗଳନାଙ୍କ',
  };

  String get boiling => switch (language) {
    RegionalLanguage.english => 'Boiling',
    RegionalLanguage.hindi => 'क्वथनांक',
    RegionalLanguage.odia => 'ସ୍ଫୁଟନାଙ୍କ',
  };

  String get density => switch (language) {
    RegionalLanguage.english => 'Density',
    RegionalLanguage.hindi => 'घनत्व',
    RegionalLanguage.odia => 'ଘନତ୍ୱ',
  };

  String get commonUses => switch (language) {
    RegionalLanguage.english => 'Common uses',
    RegionalLanguage.hindi => 'सामान्य उपयोग',
    RegionalLanguage.odia => 'ସାଧାରଣ ବ୍ୟବହାର',
  };

  String get funFact => switch (language) {
    RegionalLanguage.english => 'Fun fact',
    RegionalLanguage.hindi => 'रोचक तथ्य',
    RegionalLanguage.odia => 'ମଜାଦାର ତଥ୍ୟ',
  };

  String get discovery => switch (language) {
    RegionalLanguage.english => 'Discovery',
    RegionalLanguage.hindi => 'खोज',
    RegionalLanguage.odia => 'ଆବିଷ୍କାର',
  };

  String askAi(String elementName) => switch (language) {
    RegionalLanguage.english => 'Ask AI about $elementName',
    RegionalLanguage.hindi => '$elementName के बारे में AI से पूछें',
    RegionalLanguage.odia => '$elementName ବିଷୟରେ AIକୁ ପଚାରନ୍ତୁ',
  };
}

class PeriodicTableScreen extends ConsumerStatefulWidget {
  const PeriodicTableScreen({super.key});

  @override
  ConsumerState<PeriodicTableScreen> createState() =>
      _PeriodicTableScreenState();
}

class _PeriodicTableScreenState extends ConsumerState<PeriodicTableScreen> {
  static const double _elementWidth = 72.0;
  static const double _elementHeight = 84.0;
  static const double _gap = 4.0;
  static const double _initialScale = 0.8;
  static const double _minimumScale = 0.2;
  static const double _initialLeftPadding = 24.0;
  static const double _initialTopPadding = 24.0;

  final TransformationController _transformController =
      TransformationController(
        Matrix4.identity()
          ..translateByDouble(_initialLeftPadding, _initialTopPadding, 0, 1)
          ..scaleByDouble(_initialScale, _initialScale, _initialScale, 1),
      );
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _viewerKey = GlobalKey();

  bool _searching = false;
  String _query = '';
  int? _highlightedAtomicNumber;

  @override
  void dispose() {
    _transformController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  double get _colStride => _elementWidth + _gap;
  double get _rowStride => _elementHeight + _gap;

  // ─── Search ───
  List<ElementData> get _searchResults {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return periodicTableElements.where((e) {
      return e.name.toLowerCase().contains(q) ||
          e.symbol.toLowerCase() == q ||
          e.symbol.toLowerCase().startsWith(q) ||
          e.nameOdia.contains(_query.trim()) ||
          e.nameHindi.contains(_query.trim()) ||
          e.atomicNumber.toString() == q;
    }).toList();
  }

  void _openSearch() => setState(() => _searching = true);

  void _closeSearch() {
    setState(() {
      _searching = false;
      _query = '';
      _searchController.clear();
    });
  }

  void _selectFromSearch(ElementData e) {
    _closeSearch();
    _centerOnElement(e);
    setState(() => _highlightedAtomicNumber = e.atomicNumber);
    // Clear the highlight after a short glow.
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted && _highlightedAtomicNumber == e.atomicNumber) {
        setState(() => _highlightedAtomicNumber = null);
      }
    });
    _showElementDetails(context, e);
  }

  void _centerOnElement(ElementData e) {
    final viewportSize = _viewerKey.currentContext?.size;
    if (viewportSize == null) return;

    // Center of the target cell in table (child) coordinates.
    final cellCenterX = (e.group - 1) * _colStride + _elementWidth / 2;
    final cellCenterY = (e.period - 1) * _rowStride + _elementHeight / 2;

    const scale = 1.0;
    final tx = viewportSize.width / 2 - cellCenterX * scale;
    final ty = viewportSize.height / 2 - cellCenterY * scale;

    _transformController.value = Matrix4.identity()
      ..translateByDouble(tx, ty, 0, 1)
      ..scaleByDouble(scale, scale, scale, 1);
  }

  // ─── Detail sheet ───
  void _showElementDetails(BuildContext context, ElementData element) {
    final color = _categoryColor(element.category);
    final lang = ref.read(regionalLanguageProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _ElementDetailSheet(element: element, color: color, lang: lang),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(regionalLanguageProvider);
    final copy = _PeriodicTableCopy(lang);
    final double tableWidth = 18 * _colStride;
    final double tableHeight = 10 * _rowStride;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: copy.searchHint,
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _query = v),
              )
            : const Text('Periodic Table'),
        actions: [
          IconButton(
            icon: Icon(_searching ? Icons.close : Icons.search),
            tooltip: _searching ? copy.closeSearch : copy.search,
            onPressed: _searching ? _closeSearch : _openSearch,
          ),
          if (!_searching) const RegionalLanguageSwitch(),
        ],
      ),
      body: Column(
        children: [
          _CategoryLegend(language: lang),
          Expanded(
            child: Stack(
              children: [
                InteractiveViewer(
                  key: _viewerKey,
                  transformationController: _transformController,
                  boundaryMargin: const EdgeInsets.all(80.0),
                  minScale: _minimumScale,
                  maxScale: 3.0,
                  constrained: false,
                  child: SizedBox(
                    width: tableWidth,
                    height: tableHeight,
                    child: Stack(
                      children: periodicTableElements.map((e) {
                        final color = _categoryColor(e.category);
                        return Positioned(
                          left: (e.group - 1) * _colStride,
                          top: (e.period - 1) * _rowStride,
                          width: _elementWidth,
                          height: _elementHeight,
                          child: _ElementCell(
                            element: e,
                            color: color,
                            language: lang,
                            highlighted:
                                _highlightedAtomicNumber == e.atomicNumber,
                            onTap: () => _showElementDetails(context, e),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                if (_searching && _query.trim().isNotEmpty)
                  _SearchResultsOverlay(
                    results: _searchResults,
                    lang: lang,
                    onSelect: _selectFromSearch,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Legend ───
class _CategoryLegend extends StatelessWidget {
  const _CategoryLegend({required this.language});

  final RegionalLanguage language;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: _categoryInfo.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final entry = _categoryInfo.entries.elementAt(i);
          final color = entry.value.color;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _categoryLabel(entry.key, language),
                  style: const TextStyle(
                    fontSize: AppFontSize.small,
                    fontWeight: AppFontWeight.semibold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Search results overlay ───
class _SearchResultsOverlay extends StatelessWidget {
  final List<ElementData> results;
  final RegionalLanguage lang;
  final ValueChanged<ElementData> onSelect;

  const _SearchResultsOverlay({
    required this.results,
    required this.lang,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: results.isEmpty
            ? Center(
                child: Text(
                  _PeriodicTableCopy(lang).noElementsFound,
                  style: TextStyle(color: AppColors.textMuted),
                ),
              )
            : ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, i) {
                  final e = results[i];
                  final color = _categoryColor(e.category);
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  return ListTile(
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: isDark ? 0.3 : 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: color.withValues(alpha: 0.5)),
                      ),
                      child: Center(
                        child: Text(
                          e.symbol,
                          style: const TextStyle(
                            fontWeight: AppFontWeight.bold,
                            fontSize: AppFontSize.content,
                          ),
                        ),
                      ),
                    ),
                    title: Text(e.regionalName(lang)),
                    trailing: Text(
                      '#${e.atomicNumber}',
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                    onTap: () => onSelect(e),
                  );
                },
              ),
      ),
    );
  }
}

// ─── Grid cell ───
class _ElementCell extends StatelessWidget {
  final ElementData element;
  final Color color;
  final RegionalLanguage language;
  final bool highlighted;
  final VoidCallback onTap;

  const _ElementCell({
    required this.element,
    required this.color,
    required this.language,
    required this.highlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.3 : 0.2),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: highlighted
                ? color
                : color.withValues(alpha: isDark ? 0.6 : 0.4),
            width: highlighted ? 3 : 1.5,
          ),
          boxShadow: highlighted
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.6),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${element.atomicNumber}',
              style: TextStyle(
                fontSize: AppFontSize.caption,
                color: textColor.withValues(alpha: 0.7),
                fontWeight: AppFontWeight.bold,
              ),
            ),
            Center(
              child: Text(
                element.symbol,
                style: TextStyle(
                  fontSize: AppFontSize.heading,
                  fontWeight: AppFontWeight.bold,
                  color: textColor,
                  height: 1.0,
                ),
              ),
            ),
            Center(
              child: Text(
                element.regionalName(language),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppFontSize.caption,
                  color: textColor.withValues(alpha: 0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Detail sheet ───
class _ElementDetailSheet extends StatelessWidget {
  /// Ask AI stays off until Explore Assist can answer it (plan.md Phase 8).
  static const _showAskAi = false;

  final ElementData element;
  final Color color;
  final RegionalLanguage lang;

  const _ElementDetailSheet({
    required this.element,
    required this.color,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final copy = _PeriodicTableCopy(lang);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 24,
              top: 12,
              left: 20,
              right: 20,
            ),
            children: [
              // Grab handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    copy.atomicNumber(element.atomicNumber),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: AppFontWeight.semibold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              // Identity
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      element.symbol,
                      style: TextStyle(
                        fontSize: AppFontSize.hero,
                        fontWeight: AppFontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Text(
                  element.regionalName(lang),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: AppFontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    _categoryLabel(element.category, lang),
                    style: TextStyle(
                      color: color,
                      fontWeight: AppFontWeight.bold,
                      fontSize: AppFontSize.body,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                element.description.inLanguage(lang),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),

              const SizedBox(height: 20),

              // Key stats grid
              _statGrid(context, cs),

              const SizedBox(height: 20),

              // Electron shells
              _sectionTitle(
                context,
                Icons.blur_circular,
                copy.electronsPerShell,
              ),
              const SizedBox(height: 8),
              _shellChips(),

              // Physical properties
              if (element.meltingPoint != null ||
                  element.boilingPoint != null ||
                  element.density != null) ...[
                const SizedBox(height: 20),
                _sectionTitle(
                  context,
                  Icons.thermostat,
                  copy.physicalProperties,
                ),
                const SizedBox(height: 8),
                _physicalRow(context, cs),
              ],

              // Uses
              const SizedBox(height: 20),
              _sectionTitle(context, Icons.build_rounded, copy.commonUses),
              const SizedBox(height: 6),
              Text(
                element.uses.inLanguage(lang),
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              // Fun fact
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.16 : 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_rounded, color: color, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            copy.funFact,
                            style: TextStyle(
                              fontWeight: AppFontWeight.bold,
                              color: color,
                              fontSize: AppFontSize.body,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            element.funFact.inLanguage(lang),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Discovery
              const SizedBox(height: 20),
              _sectionTitle(context, Icons.history_edu, copy.discovery),
              const SizedBox(height: 6),
              Text(
                element.discovery.inLanguage(lang),
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              // Ask AI — hidden until the Explore Assist agent lands (plan.md Phase 8).
              // TODO: wire to Explore Assist, pre-filled with a question about this element.
              if (_showAskAi) ...[
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(switch (lang) {
                          RegionalLanguage.english =>
                            'AI tutor for elements is coming soon!',
                          RegionalLanguage.hindi =>
                            'तत्वों के लिए AI ट्यूटर जल्द आ रहा है!',
                          RegionalLanguage.odia =>
                            'ମୌଳଗୁଡ଼ିକ ପାଇଁ AI ଶିକ୍ଷକ ଶୀଘ୍ର ଆସୁଛି!',
                        }),
                      ),
                    );
                  },
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(copy.askAi(element.regionalName(lang))),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    side: BorderSide(color: color.withValues(alpha: 0.6)),
                    foregroundColor: color,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(BuildContext context, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: AppFontWeight.bold,
            fontSize: AppFontSize.body,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _statGrid(BuildContext context, ColorScheme cs) {
    final copy = _PeriodicTableCopy(lang);
    final stats = <List<String>>[
      [copy.atomicMass, element.atomicMass],
      [copy.state, _stateLabel(element.state, lang)],
      [copy.valency, element.valency],
      [copy.group, element.group > 18 ? '—' : '${element.group}'],
      [copy.period, element.period > 7 ? '—' : '${element.period}'],
      [copy.category, _categoryLabel(element.category, lang)],
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final tileWidth = (constraints.maxWidth - spacing * 2) / 3;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: stats.map((s) {
            return Container(
              width: tileWidth,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    s[0],
                    style: const TextStyle(
                      fontSize: AppFontSize.caption,
                      color: AppColors.textMuted,
                      fontWeight: AppFontWeight.semibold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s[1],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: AppFontWeight.bold,
                      fontSize: AppFontSize.body,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _shellChips() {
    final copy = _PeriodicTableCopy(lang);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(element.shells.length, (i) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              Text(
                copy.shell(i + 1),
                style: const TextStyle(
                  fontSize: AppFontSize.caption,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${element.shells[i]} e⁻',
                style: const TextStyle(fontWeight: AppFontWeight.bold),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _physicalRow(BuildContext context, ColorScheme cs) {
    final copy = _PeriodicTableCopy(lang);
    final items = <List<String>>[
      if (element.meltingPoint != null) [copy.melting, element.meltingPoint!],
      if (element.boilingPoint != null) [copy.boiling, element.boilingPoint!],
      if (element.density != null) [copy.density, element.density!],
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0)
              Container(width: 1, height: 36, color: cs.outlineVariant),
            Expanded(
              child: Column(
                children: [
                  Text(
                    items[i][0],
                    style: const TextStyle(
                      fontSize: AppFontSize.caption,
                      color: AppColors.textMuted,
                      fontWeight: AppFontWeight.semibold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    items[i][1],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: AppFontWeight.bold,
                      fontSize: AppFontSize.body,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
