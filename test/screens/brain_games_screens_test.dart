import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyalaya/providers/core_providers.dart';
import 'package:vidyalaya/screens/games/element_match_screen.dart';
import 'package:vidyalaya/screens/games/games_home_screen.dart';
import 'package:vidyalaya/screens/games/sudoku_screen.dart';
import 'package:vidyalaya/screens/games/word_builder_screen.dart';

// ─── Brain games screens ──────────────────────────────────────────────────────
//
// Every screen lays out at a small phone width, at every level, without
// overflowing. Layout errors surface as test exceptions.

late SharedPreferences _prefs;

Widget _harness(Widget home) => ProviderScope(
  overrides: [sharedPreferencesProvider.overrideWithValue(_prefs)],
  child: MaterialApp(home: home),
);

Future<void> _phone(WidgetTester tester) async {
  tester.view.physicalSize = const Size(360, 740);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({'regional_language': 'or'});
    _prefs = await SharedPreferences.getInstance();
  });

  testWidgets('hub shows the daily challenge and every game', (tester) async {
    await _phone(tester);
    await tester.pumpWidget(_harness(const GamesHomeScreen()));
    await tester.pump();
    expect(find.text('Daily Brain Challenge'), findsOneWidget);
    for (final title in [
      'Speed Drills',
      'Word Builder',
      'Sudoku',
      'Element Match',
    ]) {
      await tester.scrollUntilVisible(find.text(title).last, 100);
      expect(find.text(title), findsWidgets);
    }
  });

  testWidgets('sudoku lays out at every size', (tester) async {
    await _phone(tester);
    await tester.pumpWidget(_harness(const SudokuScreen()));
    for (final label in ['4 × 4', '6 × 6', '9 × 9']) {
      await tester.tap(find.text(label));
      await tester.pump();
    }
    expect(find.text('Hint'), findsOneWidget);
    await tester.pumpWidget(const SizedBox()); // dispose the ticker
  });

  testWidgets('word builder: hints alone solve a word', (tester) async {
    await _phone(tester);
    await tester.pumpWidget(_harness(const WordBuilderScreen()));
    for (final label in ['Easy', 'Medium', 'Hard']) {
      await tester.tap(find.text(label));
      await tester.pump();
    }
    expect(find.text('Word 1 of 10'), findsOneWidget);
    for (var i = 0; i < 10; i++) {
      await tester.ensureVisible(find.text('Hint'));
      await tester.tap(find.text('Hint'));
      await tester.pump();
    }
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Word 2 of 10'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('element match lays out at every level', (tester) async {
    await _phone(tester);
    await tester.pumpWidget(_harness(const ElementMatchScreen()));
    for (final label in ['Easy', 'Medium', 'Hard']) {
      await tester.tap(find.text(label));
      await tester.pump();
    }
    expect(find.text('Moves 0'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
