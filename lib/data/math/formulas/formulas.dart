import 'package:flutter/material.dart';

import 'algebra.dart';
import 'arithmetic.dart';
import 'coordinate_geometry.dart';
import 'formula_models.dart';
import 'geometry.dart';
import 'measurement.dart';
import 'physics.dart';
import 'statistics.dart';
import 'trigonometry.dart';

export 'formula_models.dart';

// ─── Formula catalogue ────────────────────────────────────────────────────────
//
// Adding a formula: add a FormulaData (with its inputs + compute function) to
// the matching category file. Adding a category: a new file, an entry in
// [formulaCategories], and its list in [allFormulas].

const allFormulas = <FormulaData>[
  ...measurementFormulas,
  ...arithmeticFormulas,
  ...algebraFormulas,
  ...geometryFormulas,
  ...coordinateGeometryFormulas,
  ...trigonometryFormulas,
  ...statisticsFormulas,
  ...physicsFormulas,
];

/// Category cards, in the order shown on the Formulas grid (roughly by class).
const formulaCategories = [
  FormulaCategory(
    name: 'Measurement',
    titleOr: 'ମାପ',
    titleHi: 'मापन',
    icon: Icons.straighten_rounded,
    color: Color(0xFF0EA5E9), // sky
  ),
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
    name: 'Coordinate Geometry',
    titleOr: 'ସ୍ଥାନାଙ୍କ ଜ୍ୟାମିତି',
    titleHi: 'निर्देशांक ज्यामिति',
    icon: Icons.scatter_plot_rounded,
    color: Color(0xFFEC4899), // pink
  ),
  FormulaCategory(
    name: 'Trigonometry',
    titleOr: 'ତ୍ରିକୋଣମିତି',
    titleHi: 'त्रिकोणमिति',
    icon: Icons.change_history_rounded,
    color: Color(0xFFEF4444), // red
  ),
  FormulaCategory(
    name: 'Statistics & Probability',
    titleOr: 'ପରିସଂଖ୍ୟାନ ଓ ସମ୍ଭାବ୍ୟତା',
    titleHi: 'सांख्यिकी और प्रायिकता',
    icon: Icons.bar_chart_rounded,
    color: Color(0xFF6366F1), // indigo
  ),
  FormulaCategory(
    name: 'Physics',
    titleOr: 'ପଦାର୍ଥ ବିଜ୍ଞାନ',
    titleHi: 'भौतिकी',
    icon: Icons.science_rounded,
    color: Color(0xFF10B981), // green
  ),
];

/// Old category names that still arrive via deep links.
const _legacyCategoryNames = {'Science': 'Physics'};

FormulaCategory? formulaCategoryByName(String name) {
  final resolved = _legacyCategoryNames[name] ?? name;
  for (final c in formulaCategories) {
    if (c.name == resolved) return c;
  }
  return null;
}

FormulaData? formulaById(String id) {
  for (final f in allFormulas) {
    if (f.id == id) return f;
  }
  return null;
}

extension FormulaCategoryFormulas on FormulaCategory {
  /// Formulas belonging to this category, in catalogue order.
  List<FormulaData> get formulas =>
      allFormulas.where((f) => f.category == name).toList();
}
