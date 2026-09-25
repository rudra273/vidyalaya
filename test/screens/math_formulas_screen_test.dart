import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyalaya/data/math/formulas/formulas.dart';
import 'package:vidyalaya/providers/core_providers.dart';
import 'package:vidyalaya/screens/learn/math_formulas_screen.dart';

late SharedPreferences _prefs;

/// The screens read the regional language, which resolves through
/// [sharedPreferencesProvider] — overridden in `main.dart`, so tests must too.
Widget harness(Widget home) => ProviderScope(
  overrides: [sharedPreferencesProvider.overrideWithValue(_prefs)],
  child: MaterialApp(home: home),
);

Future<void> openFormula(
  WidgetTester tester,
  String category,
  String title,
) async {
  await tester.binding.setSurfaceSize(const Size(420, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    harness(FormulaCategoryScreen(category: formulaCategoryByName(category)!)),
  );
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(
    find.text(title),
    200,
    scrollable: find.descendant(
      of: find.byType(ListView),
      matching: find.byType(Scrollable),
    ),
  );
  await tester.tap(find.text(title));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    _prefs = await SharedPreferences.getInstance();
  });

  testWidgets('grid lists every category', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(harness(const MathFormulasScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All classes'));
    await tester.pumpAndSettle();
    for (final c in formulaCategories) {
      expect(find.text(c.name), findsOneWidget, reason: c.name);
    }
    expect(find.textContaining('coming soon'), findsNothing);
  });

  testWidgets('calculator fills in the blank value (Ohm\'s law)', (
    tester,
  ) async {
    await openFormula(tester, 'Physics', "Ohm's Law");
    await tester.enterText(
      find.widgetWithText(TextField, 'Current, amperes (e.g. 2)'),
      '2',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Resistance, ohms (e.g. 5)'),
      '5',
    );
    await tester.pump();
    expect(find.textContaining('V = 10 V'), findsOneWidget);
  });

  testWidgets('list input accepts comma-separated numbers', (tester) async {
    await openFormula(tester, 'Statistics & Probability', 'Median');
    await tester.enterText(find.byType(TextField), '3, 7, 7, 2, 9');
    await tester.pump();
    expect(find.textContaining('Median = 7'), findsOneWidget);
  });

  testWidgets('reference cards show no calculator', (tester) async {
    await openFormula(tester, 'Trigonometry', 'Standard Angle Values');
    expect(find.byType(TextField), findsNothing);
    expect(find.textContaining('√3/2'), findsOneWidget);
  });
}
