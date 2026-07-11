import '../../providers/regional_language_provider.dart';
import 'elements/elements_001_040.dart';
import 'elements/elements_041_080.dart';
import 'elements/elements_081_118.dart';

// ─── Element model ───
// Plain immutable const data (no codegen / serialization) — this is static
// display-only seed content, mirroring the rest of lib/data/science.
//
// Layout note: `group`/`period` are used for grid placement. Lanthanides use
// period 8 and actinides period 9 with `group` repurposed as a column index,
// so they render as the two detached bottom rows.
class ElementData {
  final int atomicNumber;
  final String symbol;
  final String name;
  final String nameOdia;
  final String nameHindi;
  final int group;
  final int period;
  final String category;

  // Core chemistry
  final String atomicMass; // e.g. '1.008'; synthetic → '[294]'
  final String state; // 'Gas' | 'Liquid' | 'Solid'
  final List<int> shells; // electrons per shell, e.g. [2, 8, 1]
  final String valency; // e.g. '1', '2, 3', '0'

  // Physical properties (nullable — unknown for some synthetic elements).
  // Display strings with units, e.g. '−259 °C', '0.97 g/cm³'.
  final String? meltingPoint;
  final String? boilingPoint;
  final String? density;

  // Student-friendly (classes 6–8 level)
  final String description;
  final String uses;
  final String funFact;

  // Discovery — e.g. 'Henry Cavendish, 1766' or 'Known since ancient times'
  final String discovery;

  const ElementData({
    required this.atomicNumber,
    required this.symbol,
    required this.name,
    required this.nameOdia,
    required this.nameHindi,
    required this.group,
    required this.period,
    required this.category,
    required this.atomicMass,
    required this.state,
    required this.shells,
    required this.valency,
    this.meltingPoint,
    this.boilingPoint,
    this.density,
    required this.description,
    required this.uses,
    required this.funFact,
    required this.discovery,
  });

  /// The element's name in the chosen regional language (one at a time),
  /// shown alongside the always-present English [name].
  String regionalName(RegionalLanguage lang) =>
      lang == RegionalLanguage.hindi ? nameHindi : nameOdia;
}

// ─── Full table ───
// Aggregated from per-range part files (mirrors the seed_data.dart pattern).
const List<ElementData> periodicTableElements = [
  ...elements001to040,
  ...elements041to080,
  ...elements081to118,
];
