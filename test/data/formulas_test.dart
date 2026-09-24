import 'package:flutter_test/flutter_test.dart';
import 'package:vidyalaya/data/math/formulas/formulas.dart';

/// Runs formula [id] with [inputs] and returns the result line.
String? calc(String id, Map<String, String> inputs) {
  final f = formulaById(id);
  expect(f, isNotNull, reason: 'unknown formula id $id');
  return f!.calculate(inputs);
}

void main() {
  group('catalogue', () {
    test('ids are unique', () {
      final ids = allFormulas.map((f) => f.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('every formula belongs to a listed category and vice versa', () {
      final names = formulaCategories.map((c) => c.name).toSet();
      for (final f in allFormulas) {
        expect(names, contains(f.category), reason: f.id);
      }
      for (final c in formulaCategories) {
        expect(c.formulas, isNotEmpty, reason: c.name);
      }
    });

    test('every formula has all three languages', () {
      for (final f in allFormulas) {
        for (final text in [
          f.titleEn,
          f.titleOr,
          f.titleHi,
          f.descEn,
          f.descOr,
          f.descHi,
        ]) {
          expect(text.trim(), isNotEmpty, reason: f.id);
        }
      }
    });

    test('input keys are unique within a formula', () {
      for (final f in allFormulas) {
        final keys = f.inputs.map((i) => i.key).toList();
        expect(keys.toSet().length, keys.length, reason: f.id);
      }
    });

    test('catalogue has grown to the Phase 3 target', () {
      expect(allFormulas.length, greaterThanOrEqualTo(75));
    });

    test('calculators return null (not an error) when inputs are empty', () {
      for (final f in allFormulas.where((f) => f.hasCalculator)) {
        expect(f.calculate(const {}), isNull, reason: f.id);
      }
    });

    test('legacy Science deep link resolves to Physics', () {
      expect(formulaCategoryByName('Science')?.name, 'Physics');
      expect(formulaCategoryByName('Nope'), isNull);
    });

    test('standard angle table is a reference card', () {
      expect(formulaById('standard-angles')!.hasCalculator, isFalse);
    });
  });

  group('existing calculators keep their output', () {
    test('arithmetic', () {
      expect(
        calc('simple-interest', {'P': '1000', 'R': '5', 'T': '2'}),
        'SI = 100.00',
      );
      expect(
        calc('compound-interest', {'P': '1000', 'R': '10', 'T': '2'}),
        'A = 1210.00, CI = 210.00',
      );
      expect(calc('percentage', {'Value': '25', 'Total': '200'}), '12.50%');
      expect(
        calc('profit-percent', {'CP': '100', 'SP': '120'}),
        'Profit % = 20.00%',
      );
      expect(
        calc('loss-percent', {'CP': '100', 'SP': '80'}),
        'Loss % = 20.00%',
      );
    });

    test('average now takes a list', () {
      expect(calc('average', {'x': '10, 20, 30, 40'}), 'Mean = 25');
      expect(calc('average', {'x': '10, abc'}), isNull);
    });

    test('algebra', () {
      expect(
        calc('quadratic', {'a': '1', 'b': '-5', 'c': '6'}),
        'x = 3.0000 or x = 2.0000',
      );
      expect(
        calc('quadratic', {'a': '0', 'b': '1', 'c': '1'}),
        'Not a quadratic (a cannot be 0)',
      );
      expect(
        calc('a-plus-b-squared', {'a': '3', 'b': '2'}),
        '(a + b)² = 25.00',
      );
      expect(calc('ap-sum', {'a': '2', 'd': '3', 'n': '10'}), 'Sₙ = 155.00');
    });

    test('geometry', () {
      expect(calc('pythagoras', {'a': '3', 'b': '4'}), 'c = 5.0000');
      expect(calc('rectangle-area', {'l': '5', 'w': '3'}), 'A = 15.00');
      expect(
        calc('cuboid-volume', {'l': '5', 'w': '3', 'h': '2'}),
        'V = 30.00',
      );
    });

    test('trigonometry', () {
      expect(calc('sin-ratio', {'θ (deg)': '30'}), 'sin(θ) = 0.5000');
      expect(
        calc('law-of-cosines', {'a': '3', 'b': '4', 'C (deg)': '90'}),
        'c = 5.0000',
      );
    });

    test('physics (was Science)', () {
      expect(calc('speed', {'d': '100', 't': '2'}), 's = 50.00');
      expect(calc('fahrenheit-to-celsius', {'F': '212'}), 'C = 100.00°C');
      expect(calc('celsius-to-fahrenheit', {'C': '37'}), 'F = 98.60°F');
    });
  });

  group('new calculators', () {
    test('measurement converts from whichever box is filled', () {
      expect(
        calc('length-units', {'km': '1.5'}),
        '1.5 km = 1500 m = 150000 cm = 1500000 mm',
      );
      expect(
        calc('length-units', {'cm': '250'}),
        '0.0025 km = 2.5 m = 250 cm = 2500 mm',
      );
      expect(calc('time-units', {'min': '90'}), '1.5 h = 90 min = 5400 s');
      expect(calc('money-units', {'paise': '250'}), '2.5 ₹ = 250 paise');
      expect(
        calc('mass-units', {'kg': '1', 'g': '5'}),
        isNull,
        reason: 'two boxes filled is ambiguous',
      );
    });

    test('arithmetic additions', () {
      expect(
        calc('discount', {'MP': '500', 'D': '10'}),
        'Discount = 50.00, SP = 450.00',
      );
      expect(
        calc('percent-change', {'Old': '40', 'New': '50'}),
        'Increase = 25.00%',
      );
      expect(
        calc('percent-change', {'Old': '50', 'New': '40'}),
        'Decrease = 20.00%',
      );
      expect(
        calc('ratio-share', {'N': '600', 'a': '2', 'b': '3'}),
        'Share₁ = 240, Share₂ = 360',
      );
      expect(
        calc('unitary-method', {'n': '5', 'Cost': '50', 'm': '8'}),
        'One = 10, Cost of m = 80',
      );
      expect(calc('hcf-lcm', {'a': '12', 'b': '18'}), 'HCF = 6, LCM = 36');
      expect(
        calc('hcf-lcm', {'a': '1.5', 'b': '3'}),
        'Enter two positive whole numbers',
      );
    });

    test('algebra additions', () {
      expect(
        calc('a-plus-b-plus-c-squared', {'a': '1', 'b': '2', 'c': '3'}),
        '(a + b + c)² = 36',
      );
      expect(calc('sum-of-cubes', {'a': '2', 'b': '3'}), 'a³ + b³ = 35.00');
      expect(
        calc('difference-of-cubes', {'a': '3', 'b': '2'}),
        'a³ − b³ = 19.00',
      );
      expect(
        calc('laws-of-exponents', {'a': '2', 'm': '3', 'n': '2'}),
        'aᵐ⁺ⁿ = 32, aᵐ⁻ⁿ = 2, aᵐⁿ = 64',
      );
      expect(
        calc('discriminant', {'a': '1', 'b': '2', 'c': '5'}),
        'D = -16 → no real roots',
      );
      expect(
        calc('discriminant', {'a': '1', 'b': '2', 'c': '1'}),
        'D = 0 → two equal roots',
      );
      expect(calc('sum-first-n', {'n': '100'}), 'Sum = 5050');
      expect(calc('linear-equation', {'a': '2', 'b': '-6'}), 'x = 3');
    });

    test('geometry additions', () {
      expect(
        calc('triangle-perimeter', {'a': '3', 'b': '4', 'c': '5'}),
        'P = 12',
      );
      expect(
        calc('herons-formula', {'a': '3', 'b': '4', 'c': '5'}),
        's = 6, A = 6',
      );
      expect(
        calc('herons-formula', {'a': '1', 'b': '2', 'c': '5'}),
        'These sides cannot form a triangle',
      );
      expect(calc('parallelogram-area', {'b': '8', 'h': '5'}), 'A = 40');
      expect(calc('trapezium-area', {'a': '6', 'b': '10', 'h': '4'}), 'A = 32');
      expect(calc('rhombus-area', {'d₁': '6', 'd₂': '8'}), 'A = 24');
      expect(calc('sector-area', {'r': '7', 'θ (deg)': '360'}), 'A = 153.938');
      expect(
        calc('polygon-angle-sum', {'n': '6'}),
        'Sum = 720°, each (regular) = 120°',
      );
      expect(calc('cube-surface-area', {'a': '2'}), 'TSA = 24, LSA = 16');
      expect(
        calc('cuboid-surface-area', {'l': '5', 'w': '3', 'h': '2'}),
        'TSA = 62, LSA = 32',
      );
      expect(
        calc('cone', {'r': '3', 'h': '4'}),
        'l = 5, CSA = 47.1239, V = 37.6991',
      );
      expect(calc('sphere', {'r': '1'}), 'SA = 12.5664, V = 4.1888');
      expect(
        calc('hemisphere', {'r': '1'}),
        'CSA = 6.2832, TSA = 9.4248, V = 2.0944',
      );
    });

    test('coordinate geometry', () {
      const pts = {'x₁': '1', 'y₁': '2', 'x₂': '4', 'y₂': '6'};
      expect(calc('distance-formula', pts), 'd = 5');
      expect(calc('midpoint-formula', pts), 'M = (2.5, 4)');
      expect(calc('slope', pts), 'm = 1.3333');
      expect(
        calc('section-formula', {...pts, 'm': '1', 'n': '2'}),
        'P = (2, 3.3333)',
      );
      expect(
        calc('slope', {'x₁': '1', 'y₁': '2', 'x₂': '1', 'y₂': '6'}),
        'Vertical line: slope is undefined',
      );
      expect(
        calc('triangle-area-coordinates', {
          'x₁': '0',
          'y₁': '0',
          'x₂': '4',
          'y₂': '0',
          'x₃': '0',
          'y₃': '3',
        }),
        'A = 6',
      );
    });

    test('trigonometry additions', () {
      expect(
        calc('reciprocal-ratios', {'θ (deg)': '90'}),
        'cosec = 1, sec = undefined, cot = 0',
      );
      expect(calc('trig-identities', {'θ (deg)': '37'}), 'sin²θ + cos²θ = 1');
    });

    test('statistics & probability', () {
      expect(calc('median', {'x': '3, 7, 7, 2, 9'}), 'Median = 7');
      expect(calc('median', {'x': '4 1 3 2'}), 'Median = 2.5');
      expect(
        calc('mode', {'x': '3, 7, 7, 2, 9'}),
        'Mode = 7 (appears 2 times)',
      );
      expect(
        calc('mode', {'x': '1, 2, 3'}),
        'No mode (every value appears once)',
      );
      expect(calc('range', {'x': '3, 7, 2, 9'}), 'Range = 9 − 2 = 7');
      expect(
        calc('grouped-mean', {'x': '5, 15, 25', 'f': '2, 3, 5'}),
        'Σfx = 180, Σf = 10, x̄ = 18',
      );
      expect(
        calc('grouped-mean', {'x': '5, 15', 'f': '2'}),
        'Enter one frequency for each value',
      );
      expect(
        calc('probability', {'Fav': '1', 'Total': '4'}),
        'P(E) = 0.25, P(not E) = 0.75',
      );
    });

    test('physics additions', () {
      expect(
        calc('acceleration', {'u': '0', 'v': '20', 't': '5'}),
        'a = 4 m/s²',
      );
      expect(calc('force', {'m': '10', 'a': '2'}), 'F = 20 N');
      expect(calc('momentum', {'m': '50', 'v': '4'}), 'p = 200 kg·m/s');
      expect(calc('weight', {'m': '60'}), 'W = 588 N');
      expect(calc('density', {'m': '2', 'V': '0.001'}), 'ρ = 2000 kg/m³');
      expect(calc('pressure', {'F': '100', 'A': '0.5'}), 'P = 200 Pa');
      expect(calc('work', {'F': '20', 's': '5'}), 'W = 100 J');
      expect(calc('power', {'W': '1000', 't': '10'}), 'P = 100 W');
      expect(calc('kinetic-energy', {'m': '2', 'v': '3'}), 'KE = 9 J');
      expect(calc('potential-energy', {'m': '5', 'h': '10'}), 'PE = 490 J');
      expect(calc('ohms-law', {'I': '2', 'R': '5'}), 'V = 10 V');
      expect(calc('ohms-law', {'V': '12', 'R': '4'}), 'I = 3 A');
      expect(calc('ohms-law', {'V': '12', 'I': '3'}), 'R = 4 Ω');
      expect(
        calc('resistors', {'R': '2, 3, 6'}),
        'Series = 11 Ω, Parallel = 1 Ω',
      );
      expect(calc('electric-power', {'V': '220', 'I': '0.5'}), 'P = 110 W');
    });
  });
}
