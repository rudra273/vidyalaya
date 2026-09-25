import 'dart:math';

import '../science/periodic_table_data.dart';

// ─── Element Match ────────────────────────────────────────────────────────────
//
// A memory game: every element appears as two face-down cards, its symbol and
// its name. Levels widen the pool of elements and add pairs.

enum ElementLevel {
  easy(label: 'Easy', pairs: 6, maxAtomicNumber: 20),
  medium(label: 'Medium', pairs: 8, maxAtomicNumber: 30),
  hard(label: 'Hard', pairs: 10, maxAtomicNumber: 56);

  final String label;
  final int pairs;

  /// Elements are drawn from atomic numbers 1..this.
  final int maxAtomicNumber;

  const ElementLevel({
    required this.label,
    required this.pairs,
    required this.maxAtomicNumber,
  });

  String get sub => 'Elements 1–$maxAtomicNumber · $pairs pairs';
}

class ElementCard {
  final ElementData element;

  /// True for the symbol face, false for the name face.
  final bool isSymbol;

  const ElementCard({required this.element, required this.isSymbol});

  int get pairId => element.atomicNumber;
}

/// A shuffled deck of 2 × [level].pairs cards.
List<ElementCard> buildElementDeck(ElementLevel level, {Random? random}) {
  final rng = random ?? Random();
  final pool = [
    for (final e in periodicTableElements)
      if (e.atomicNumber <= level.maxAtomicNumber) e,
  ]..shuffle(rng);
  return [
    for (final e in pool.take(level.pairs)) ...[
      ElementCard(element: e, isSymbol: true),
      ElementCard(element: e, isSymbol: false),
    ],
  ]..shuffle(rng);
}
