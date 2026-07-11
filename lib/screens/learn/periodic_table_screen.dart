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

String _categoryLabel(String category) =>
    _categoryInfo[category]?.label ??
    category.split('_').map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1)).join(' ');

class PeriodicTableScreen extends ConsumerStatefulWidget {
  const PeriodicTableScreen({super.key});

  @override
  ConsumerState<PeriodicTableScreen> createState() => _PeriodicTableScreenState();
}

class _PeriodicTableScreenState extends ConsumerState<PeriodicTableScreen> {
  static const double _elementWidth = 72.0;
  static const double _elementHeight = 84.0;
  static const double _gap = 4.0;

  final TransformationController _transformController = TransformationController();
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
      builder: (context) => _ElementDetailSheet(element: element, color: color, lang: lang),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(regionalLanguageProvider);
    final double tableWidth = 18 * _colStride;
    final double tableHeight = 10 * _rowStride;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search name, symbol or number…',
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _query = v),
              )
            : const Text('Periodic Table'),
        actions: [
          IconButton(
            icon: Icon(_searching ? Icons.close : Icons.search),
            tooltip: _searching ? 'Close search' : 'Search',
            onPressed: _searching ? _closeSearch : _openSearch,
          ),
          if (!_searching) const RegionalLanguageSwitch(),
        ],
      ),
      body: Column(
        children: [
          const _CategoryLegend(),
          Expanded(
            child: Stack(
              children: [
                InteractiveViewer(
                  key: _viewerKey,
                  transformationController: _transformController,
                  boundaryMargin: const EdgeInsets.all(80.0),
                  minScale: 0.2,
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
                            highlighted: _highlightedAtomicNumber == e.atomicNumber,
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
  const _CategoryLegend();

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
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  entry.value.label,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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

  const _SearchResultsOverlay({required this.results, required this.lang, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: results.isEmpty
            ? const Center(
                child: Text('No elements found', style: TextStyle(color: AppColors.textMuted)),
              )
            : ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, i) {
                  final e = results[i];
                  final color = _categoryColor(e.category);
                  final isDark = Theme.of(context).brightness == Brightness.dark;
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
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                    title: Text(e.name),
                    subtitle: Text(e.regionalName(lang)),
                    trailing: Text('#${e.atomicNumber}', style: const TextStyle(color: AppColors.textMuted)),
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
  final bool highlighted;
  final VoidCallback onTap;

  const _ElementCell({
    required this.element,
    required this.color,
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
            color: highlighted ? color : color.withValues(alpha: isDark ? 0.6 : 0.4),
            width: highlighted ? 3 : 1.5,
          ),
          boxShadow: highlighted
              ? [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 12, spreadRadius: 1)]
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
                fontSize: 10,
                color: textColor.withValues(alpha: 0.7),
                fontWeight: FontWeight.bold,
              ),
            ),
            Center(
              child: Text(
                element.symbol,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  height: 1.0,
                ),
              ),
            ),
            Center(
              child: Text(
                element.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 9, color: textColor.withValues(alpha: 0.9)),
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
  final ElementData element;
  final Color color;
  final RegionalLanguage lang;

  const _ElementDetailSheet({required this.element, required this.color, required this.lang});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                    'Atomic Number: ${element.atomicNumber}',
                    style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600),
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
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Text(
                  element.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  element.regionalName(lang),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    _categoryLabel(element.category),
                    style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                element.description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),

              const SizedBox(height: 20),

              // Key stats grid
              _statGrid(context, cs),

              const SizedBox(height: 20),

              // Electron shells
              _sectionTitle(context, Icons.blur_circular, 'Electrons per shell'),
              const SizedBox(height: 8),
              _shellChips(),

              // Physical properties
              if (element.meltingPoint != null ||
                  element.boilingPoint != null ||
                  element.density != null) ...[
                const SizedBox(height: 20),
                _sectionTitle(context, Icons.thermostat, 'Physical properties'),
                const SizedBox(height: 8),
                _physicalRow(context, cs),
              ],

              // Uses
              const SizedBox(height: 20),
              _sectionTitle(context, Icons.build_rounded, 'Common uses'),
              const SizedBox(height: 6),
              Text(element.uses, style: Theme.of(context).textTheme.bodyMedium),

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
                          Text('Fun fact',
                              style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(element.funFact, style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Discovery
              const SizedBox(height: 20),
              _sectionTitle(context, Icons.history_edu, 'Discovery'),
              const SizedBox(height: 6),
              Text(element.discovery, style: Theme.of(context).textTheme.bodyMedium),

              const SizedBox(height: 24),

              // Ask AI placeholder
              // TODO: wire to the AI tutor chat, pre-filled with a question about this element.
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('AI tutor for elements is coming soon!')),
                  );
                },
                icon: const Icon(Icons.auto_awesome),
                label: Text('Ask AI about ${element.name}'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: BorderSide(color: color.withValues(alpha: 0.6)),
                  foregroundColor: color,
                ),
              ),
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
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _statGrid(BuildContext context, ColorScheme cs) {
    final stats = <List<String>>[
      ['Atomic Mass', element.atomicMass],
      ['State', element.state],
      ['Valency', element.valency],
      ['Group', element.group > 18 ? '—' : '${element.group}'],
      ['Period', element.period > 7 ? '—' : '${element.period}'],
      ['Category', _categoryLabel(element.category)],
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
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s[1],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
              Text('Shell ${i + 1}', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
              const SizedBox(height: 2),
              Text('${element.shells[i]} e⁻', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        );
      }),
    );
  }

  Widget _physicalRow(BuildContext context, ColorScheme cs) {
    final items = <List<String>>[
      if (element.meltingPoint != null) ['Melting', element.meltingPoint!],
      if (element.boilingPoint != null) ['Boiling', element.boilingPoint!],
      if (element.density != null) ['Density', element.density!],
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
            if (i > 0) Container(width: 1, height: 36, color: cs.outlineVariant),
            Expanded(
              child: Column(
                children: [
                  Text(items[i][0],
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(items[i][1],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
