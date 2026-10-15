import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyalaya/providers/core_providers.dart';
import 'package:vidyalaya/screens/learn/math/math_graph_screen.dart';
import 'package:vidyalaya/screens/learn/math/math_practice_screen.dart';
import 'package:vidyalaya/screens/learn/vocabulary_play_screen.dart';
import 'package:vidyalaya/screens/learn/vocabulary_practice_screen.dart';

// ─── New content screens ──────────────────────────────────────────────────────
//
// The tools added with the content expansion lay out at a small phone width in
// English and Odia without overflowing, and their main interactions work.

late SharedPreferences _prefs;

Widget _harness(Widget home) => ProviderScope(
  overrides: [sharedPreferencesProvider.overrideWithValue(_prefs)],
  child: MaterialApp(home: home),
);

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(360, 740);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  for (final lang in ['en', 'or']) {
    group('language $lang', () {
      setUp(() async {
        SharedPreferences.setMockInitialValues({'regional_language': lang});
        _prefs = await SharedPreferences.getInstance();
      });

      testWidgets('clock & money round can be played through', (tester) async {
        _phone(tester);
        await tester.pumpWidget(_harness(MathPracticeScreen.clockMoney()));
        // Stops one short of the end: finishing a round records a score,
        // which needs Firebase.
        for (var i = 0; i < 9; i++) {
          // Tap the first option, then move on.
          final options = find.byType(InkWell);
          await tester.tap(options.first);
          await tester.pump();
          await tester.scrollUntilVisible(
            find.byType(FilledButton),
            200,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.tap(find.byType(FilledButton));
          await tester.pump();
        }
        expect(find.textContaining('10 of 10'), findsOneWidget);
      });

      testWidgets('word problems lay out', (tester) async {
        _phone(tester);
        await tester.pumpWidget(_harness(MathPracticeScreen.wordProblems()));
        await tester.pump();
        expect(find.textContaining('1 of 10'), findsOneWidget);
      });

      testWidgets('graph plotter shows the meeting point', (tester) async {
        _phone(tester);
        await tester.pumpWidget(_harness(const MathGraphScreen()));
        expect(find.text('y = x'), findsOneWidget);
        await tester.scrollUntilVisible(find.text('Add a second line'), 200);
        await tester.tap(find.text('Add a second line'));
        await tester.pump();
        await tester.scrollUntilVisible(
          find.textContaining('The lines meet at'),
          200,
        );
        expect(find.textContaining('The lines meet at (2, 2)'), findsOneWidget);
      });

      testWidgets('vocabulary hub lists the word sets', (tester) async {
        _phone(tester);
        await tester.pumpWidget(_harness(const VocabularyPracticeScreen()));
        await tester.pump();
        expect(find.text('Dictionary words'), findsOneWidget);
        await tester.scrollUntilVisible(find.text('Idioms'), 200);
        expect(find.text('Idioms'), findsOneWidget);
      });

      testWidgets('flashcards flip and advance', (tester) async {
        _phone(tester);
        await tester.pumpWidget(
          _harness(const VocabularyPlayScreen(source: 'idioms', mode: 'cards')),
        );
        await tester.pump();
        expect(find.text('Tap to see the meaning'), findsOneWidget);
        await tester.tap(find.text('Tap to see the meaning'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Got it'));
        await tester.pumpAndSettle();
        expect(find.textContaining('2 of 20'), findsOneWidget);
      });

      testWidgets('vocabulary quiz answers and moves on', (tester) async {
        _phone(tester);
        await tester.pumpWidget(
          _harness(
            const VocabularyPlayScreen(source: 'phrasal-verbs', mode: 'quiz'),
          ),
        );
        await tester.pump();
        expect(find.text('What does this mean?'), findsOneWidget);
        await tester.tap(find.byType(InkWell).first);
        await tester.pump();
        await tester.scrollUntilVisible(find.text('Next'), 200);
        await tester.tap(find.text('Next'));
        await tester.pump();
        expect(find.textContaining('2 of 10'), findsOneWidget);
      });
    });
  }
}
