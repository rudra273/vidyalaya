import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../data/math/formulas/formulas.dart';
import '../../data/models/class_range.dart';
import '../../providers/regional_language_provider.dart';
import '../../providers/user_selection_provider.dart';
import '../../widgets/class_scope_toggle.dart';
import '../../widgets/regional_language_switch.dart';

class MathFormulasScreen extends ConsumerStatefulWidget {
  const MathFormulasScreen({super.key});

  @override
  ConsumerState<MathFormulasScreen> createState() => _MathFormulasScreenState();
}

class _MathFormulasScreenState extends ConsumerState<MathFormulasScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  bool _mine = true;

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

  List<FormulaData> get _matches => allFormulas.where((f) {
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
    // Search always covers every formula; the class scope only trims the grid.
    final classes = ref.watch(exploreClassSelectionProvider);
    final forClasses = formulaCategories
        .where(
          (c) => (formulaCategoryClassRanges[c.name] ?? ClassRange.all)
              .fitsAny(classes),
        )
        .toList(growable: false);
    final fallback = _mine && forClasses.isEmpty;
    final categories = _mine && !fallback ? forClasses : formulaCategories;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Formulas'),
        actions: const [RegionalLanguageSwitch()],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              8,
              AppSpacing.screenPadding,
              12,
            ),
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),
          if (!isSearching)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ClassScopeToggle(
                mine: _mine,
                showingAllAsFallback: fallback,
                onChanged: (v) => setState(() => _mine = v),
              ),
            ),
          Expanded(
            child: isSearching
                ? _buildSearchResults(lang)
                : _buildCategoryGrid(context, lang, categories),
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
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        8,
        AppSpacing.screenPadding,
        16,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) =>
          _FormulaCard(formulaData: results[index], lang: lang),
    );
  }

  Widget _buildCategoryGrid(
    BuildContext context,
    RegionalLanguage lang,
    List<FormulaCategory> categories,
  ) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        8,
        AppSpacing.screenPadding,
        16,
      ),
      // A fixed height (rather than an aspect ratio) leaves room for a
      // two-line name such as "Statistics & Probability" on narrow phones.
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 178,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final count = category.formulas.length;
        return GestureDetector(
          onTap: () => context.push(
            '/learn/math-formulas/category/${Uri.encodeComponent(category.name)}',
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? cs.surface : Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(color: cs.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            // The translated label and formula count need a little more room
            // than this compact category tile originally allowed.
            padding: const EdgeInsets.all(14),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: AppFontWeight.bold,
                        height: 1.15,
                      ),
                    ),
                    Text(
                      category.regionalTitle(lang),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: AppFontWeight.semibold,
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
      },
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
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              8,
              AppSpacing.screenPadding,
              12,
            ),
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),
          Expanded(
            child: formulas.isEmpty
                ? const Center(child: Text('No formulas found.'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      8,
                      AppSpacing.screenPadding,
                      16,
                    ),
                    itemCount: formulas.length,
                    itemBuilder: (context, index) {
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

  const _FormulaCard({required this.formulaData, required this.lang});

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
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: AppFontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formulaData.regionalTitle(lang),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                          fontWeight: AppFontWeight.semibold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: cs.secondaryContainer.withValues(
                                alpha: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              formulaData.formula,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                color: cs.onSecondaryContainer,
                                fontWeight: AppFontWeight.semibold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.textMuted),
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

  const _CalculatorPage({required this.formulaData, required this.lang});

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
    for (final input in widget.formulaData.inputs) {
      _controllers[input.key] = TextEditingController()
        ..addListener(_calculate);
    }
  }

  void _calculate() {
    setState(() {
      _result = widget.formulaData.calculate({
        for (final e in _controllers.entries) e.key: e.value.text,
      });
    });
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
                fontWeight: AppFontWeight.bold,
                fontSize: AppFontSize.title,
              ),
            ),
            Text(
              widget.formulaData.regionalTitle(widget.lang),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
                fontWeight: AppFontWeight.semibold,
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
                        color: cs.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 18,
                              color: cs.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.formulaData.descEn,
                                style: Theme.of(context).textTheme.bodyMedium
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
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: cs.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      widget.formulaData.formula,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: AppFontSize.title,
                        color: cs.primary,
                        fontWeight: AppFontWeight.bold,
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
          if (widget.formulaData.hasCalculator)
            _CalculatorDock(
              result: _result,
              inputs: [
                for (final input in widget.formulaData.inputs)
                  _InputField(
                    input: input,
                    controller: _controllers[input.key]!,
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
  final FormulaInput input;
  final TextEditingController controller;

  const _InputField({required this.input, required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      // Lists need a comma, which numeric keypads often lack.
      keyboardType: input.isList
          ? TextInputType.text
          : const TextInputType.numberWithOptions(decimal: true, signed: true),
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        isDense: true,
        labelText: input.hint,
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            '${input.key} =',
            style: TextStyle(
              fontFamily: 'monospace',
              fontWeight: AppFontWeight.bold,
              color: cs.primary,
              fontSize: AppFontSize.content,
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                fontSize: AppFontSize.small,
                fontWeight: AppFontWeight.bold,
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
                  fontSize: hasResult ? AppFontSize.title : AppFontSize.content,
                  fontWeight: AppFontWeight.bold,
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

  void _label(
    Canvas canvas,
    String text,
    Offset at, {
    bool italic = true,
    double fontSize = 15,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: labelColor,
          fontSize: fontSize,
          fontWeight: AppFontWeight.semibold,
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
    _label(
      canvas,
      'c',
      Offset((p2.dx + p3.dx) / 2 + 6, (p2.dy + p3.dy) / 2 - 6),
    );
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
    _label(
      canvas,
      'C',
      Offset(p1.dx + 32, bottom - 14),
      italic: false,
      fontSize: AppFontSize.body,
    );
    _label(canvas, 'b', Offset((p1.dx + p2.dx) / 2, bottom + 12));
    _label(
      canvas,
      'a',
      Offset((p1.dx + apex.dx) / 2 - 12, (p1.dy + apex.dy) / 2),
    );
  }

  void _drawRectangle(Canvas canvas, Size size, Paint s, Paint f) {
    final rect = Rect.fromLTWH(
      24,
      size.height * 0.28,
      size.width - 48,
      size.height * 0.44,
    );
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
      height: side,
    );
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
  void _drawBox(
    Canvas canvas,
    Rect front,
    double d,
    Paint s,
    Paint f,
    Paint dash,
  ) {
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
      center: Offset(cx, topY),
      width: rx * 2,
      height: ry * 2,
    );
    final botRect = Rect.fromCenter(
      center: Offset(cx, botY),
      width: rx * 2,
      height: ry * 2,
    );
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
