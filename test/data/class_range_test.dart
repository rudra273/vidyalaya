import 'package:flutter_test/flutter_test.dart';
import 'package:vidyalaya/data/math/formulas/formulas.dart';
import 'package:vidyalaya/data/models/class_range.dart';
import 'package:vidyalaya/data/seed/interactive_diagrams_data.dart';

Set<String> toolsFor(Set<int> classes) => {
  for (final e in exploreToolClassRanges.entries)
    if (e.value.fitsAny(classes)) e.key,
};

void main() {
  test('range bounds are inclusive', () {
    const r = ClassRange(6, 10);
    expect(r.contains(5), isFalse);
    expect(r.contains(6), isTrue);
    expect(r.contains(10), isTrue);
    expect(r.contains(11), isFalse);
    expect(r.fitsAny({2, 7}), isTrue);
    expect(r.fitsAny(const <int>{}), isFalse);
  });

  test('Class 1 gets Math and Cosmulator up front', () {
    expect(toolsFor({1}), {'math', 'cosmulator'});
  });

  test('Class 6 gets the lab and Python but not the periodic table', () {
    final tools = toolsFor({6});
    expect(tools, containsAll(['virtual-lab', 'python', 'timeline']));
    expect(tools, isNot(contains('periodic-table')));
  });

  test('Class 10 gets every tool', () {
    expect(toolsFor({10}), exploreToolClassRanges.keys.toSet());
  });

  test('every diagram has a range, and every range names a real diagram', () {
    final ids = interactiveDiagrams.map((d) => d.id).toSet();
    expect(diagramClassRanges.keys.toSet(), ids);
  });

  test('diagram ranges run to Class 10, maths diagrams to Class 8', () {
    for (final d in interactiveDiagrams) {
      final r = diagramClassRanges[d.id]!;
      expect(r.max, d.section == DiagramSection.math ? 8 : 10, reason: d.id);
      expect(r.min, inInclusiveRange(1, r.max), reason: d.id);
    }
  });

  test('every formula category has a range running to Class 10', () {
    expect(
      formulaCategoryClassRanges.keys.toSet(),
      formulaCategories.map((c) => c.name).toSet(),
    );
    for (final r in formulaCategoryClassRanges.values) {
      expect(r.max, 10);
    }
  });
}
