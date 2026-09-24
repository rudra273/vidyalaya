import 'package:flutter/material.dart';

import '../../../providers/regional_language_provider.dart';

// ─── Formula models ───────────────────────────────────────────────────────────
//
// Plain const data. Each formula carries its own calculator: the input fields
// it needs and a top-level `compute` function (tear-offs are const, so the
// whole catalogue stays const). A formula with no inputs is a reference card.

/// Reads the raw text of a calculator's inputs.
class FormulaValues {
  final Map<String, String> _raw;

  const FormulaValues(this._raw);

  /// The number typed into [key], or `null` when it is empty or not a number.
  double? n(String key) => double.tryParse((_raw[key] ?? '').trim());

  /// A comma- or space-separated list of numbers typed into [key], or `null`
  /// when it is empty or any entry is not a number.
  List<double>? list(String key) {
    final parts = (_raw[key] ?? '')
        .split(RegExp(r'[,\s]+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return null;
    final values = parts.map(double.tryParse).toList();
    if (values.any((v) => v == null)) return null;
    return values.cast<double>();
  }
}

/// Computes the result line, or `null` while inputs are incomplete / invalid.
typedef FormulaCompute = String? Function(FormulaValues v);

/// One calculator input. [key] is the variable shown as `key =`.
class FormulaInput {
  final String key;
  final String hint;

  /// Accepts a list of numbers (e.g. "4, 8, 15") instead of a single number.
  final bool isList;

  const FormulaInput(this.key, this.hint, {this.isList = false});
}

/// Kinds of geometric figures drawn by `FormulaDiagramPainter`.
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

class FormulaData {
  /// Stable id (used in tests and by future "Ask about this" context).
  final String id;
  final String titleEn;
  final String titleOr;
  final String titleHi;
  final String formula;
  final String category;
  final String descEn;
  final String descOr;
  final String descHi;
  final List<FormulaInput> inputs;
  final FormulaCompute? compute;

  /// The figure that illustrates this formula, or `null` for purely numeric ones.
  final FormulaDiagram? diagram;

  const FormulaData({
    required this.id,
    required this.titleEn,
    required this.titleOr,
    required this.titleHi,
    required this.formula,
    required this.category,
    required this.descEn,
    required this.descOr,
    required this.descHi,
    this.inputs = const [],
    this.compute,
    this.diagram,
  });

  /// Reference cards (tables, identities) have nothing to calculate.
  bool get hasCalculator => compute != null && inputs.isNotEmpty;

  /// Runs the calculator on raw input text. Never throws.
  String? calculate(Map<String, String> raw) {
    if (!hasCalculator) return null;
    try {
      return compute!(FormulaValues(raw));
    } catch (_) {
      return 'Error in calculation';
    }
  }

  /// Title in the chosen app language.
  String regionalTitle(RegionalLanguage lang) => switch (lang) {
    RegionalLanguage.english => titleEn,
    RegionalLanguage.odia => titleOr,
    RegionalLanguage.hindi => titleHi,
  };

  /// Description in the chosen app language.
  String regionalDesc(RegionalLanguage lang) => switch (lang) {
    RegionalLanguage.english => descEn,
    RegionalLanguage.odia => descOr,
    RegionalLanguage.hindi => descHi,
  };
}

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

  String regionalTitle(RegionalLanguage lang) => switch (lang) {
    RegionalLanguage.english => name,
    RegionalLanguage.odia => titleOr,
    RegionalLanguage.hindi => titleHi,
  };
}

// ─── Number formatting shared by the compute functions ────────────────────────

/// Fixed decimals, as the original calculators did.
String fx(num v, [int digits = 2]) => v.toStringAsFixed(digits);

/// Up to [digits] decimals with trailing zeros dropped: 2.50 → 2.5, 3.00 → 3.
String nice(num v, [int digits = 4]) {
  final s = v.toStringAsFixed(digits);
  if (!s.contains('.')) return s;
  return s.replaceFirst(RegExp(r'\.?0+$'), '');
}

/// Degrees → radians.
double rad(double deg) => deg * 3.141592653589793 / 180;
