// ─── Class range ──────────────────────────────────────────────────────────────
//
// Which classes a piece of Explore content is meant for. Content outside the
// student's selected classes is never hidden outright — it moves to a "More"
// section — so a range is a recommendation, not a lock.

class ClassRange {
  final int min;
  final int max;

  const ClassRange(this.min, this.max);

  /// Every class the app serves.
  static const all = ClassRange(1, 10);

  bool contains(int classNo) => classNo >= min && classNo <= max;

  /// True when any of [classes] falls in this range.
  bool fitsAny(Iterable<int> classes) => classes.any(contains);

  @override
  String toString() => min == max ? 'Class $min' : 'Classes $min–$max';
}

/// Explore tool id → the classes it is recommended for.
const exploreToolClassRanges = <String, ClassRange>{
  'math': ClassRange.all,
  'diagrams': ClassRange(3, 10),
  'cosmulator': ClassRange.all,
  'periodic-table': ClassRange(7, 10),
  'vocabulary': ClassRange(3, 10),
  'python': ClassRange(6, 10),
  'quiz': ClassRange(3, 10),
  'virtual-lab': ClassRange(5, 10),
  'timeline': ClassRange(5, 10),
};

/// Diagram id → recommended classes. Upper bounds run to Class 10 (revision
/// value), except maths diagrams, which stop at Class 8.
const diagramClassRanges = <String, ClassRange>{
  // Biology
  'animal_cell': ClassRange(6, 10),
  'plant_cell': ClassRange(6, 10),
  'flower_parts': ClassRange(5, 10),
  'leaf_structure': ClassRange(5, 10),
  'photosynthesis': ClassRange(5, 10),
  'human_digestive_system': ClassRange(5, 10),
  'food_chain': ClassRange(3, 10),
  'respiratory_system': ClassRange(6, 10),
  'human_heart': ClassRange(6, 10),
  'human_eye': ClassRange(7, 10),
  'excretory_system': ClassRange(7, 10),
  'human_ear': ClassRange(8, 10),
  'human_brain': ClassRange(8, 10),
  // Science
  'water_cycle': ClassRange(3, 10),
  'states_of_matter': ClassRange(4, 10),
  'reflection_light': ClassRange(6, 10),
  'simple_machines': ClassRange(6, 10),
  'electric_circuit': ClassRange(6, 10),
  'magnetic_field': ClassRange(6, 10),
  'atom_structure': ClassRange(8, 10),
  'lens_refraction': ClassRange(8, 10),
  // Geography
  'solar_system': ClassRange(3, 10),
  'india_states_map': ClassRange(4, 10),
  'odisha_districts': ClassRange(4, 10),
  'earth_layers': ClassRange(5, 10),
  'volcano': ClassRange(5, 10),
  'latitudes_longitudes': ClassRange(6, 10),
  'soil_profile': ClassRange(7, 10),
  // Maths
  'angles_triangles': ClassRange(5, 8),
  'solid_shapes': ClassRange(5, 8),
  'circle_parts': ClassRange(6, 8),
};

/// Formula category name → recommended classes (upper bound Class 10).
const formulaCategoryClassRanges = <String, ClassRange>{
  'Measurement': ClassRange(3, 10),
  'Arithmetic': ClassRange(5, 10),
  'Algebra': ClassRange(7, 10),
  'Geometry': ClassRange(5, 10),
  'Coordinate Geometry': ClassRange(9, 10),
  'Trigonometry': ClassRange(9, 10),
  'Statistics & Probability': ClassRange(6, 10),
  'Physics': ClassRange(8, 10),
};
