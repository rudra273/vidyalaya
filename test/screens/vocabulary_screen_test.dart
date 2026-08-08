import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyalaya/providers/core_providers.dart';
import 'package:vidyalaya/providers/vocabulary_provider.dart';
import 'package:vidyalaya/screens/learn/vocabulary_screen.dart';

/// Tall viewport so a jump has plenty of list above and below it.
const _surface = Size(400, 800);

late SharedPreferences _prefs;

/// The screen reads the regional language, which resolves through
/// [sharedPreferencesProvider] — overridden in `main.dart`, so tests must
/// supply it too.
Widget harness() => ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(_prefs)],
      child: const MaterialApp(home: VocabularyScreen()),
    );

/// All words, used to tell word cards apart from headers and other labels.
late Set<String> _allWords;

/// First letters of the word cards on screen, ordered top to bottom.
///
/// Ordered geometrically rather than by tree order — a sliver list keeps
/// recycled children in an order that doesn't track what the user sees.
List<String> visibleInitials(WidgetTester tester) {
  final viewport = tester.getRect(find.byType(CustomScrollView));
  final entries = <MapEntry<double, String>>[];

  for (final element in find.byType(Text).evaluate()) {
    final text = (element.widget as Text).data;
    if (text == null || !_allWords.contains(text)) continue;

    final rect = tester.getRect(find.byWidget(element.widget));
    // Ignore cards scrolled out of view but still built in the cache extent.
    if (rect.bottom <= viewport.top || rect.top >= viewport.bottom) continue;
    entries.add(MapEntry(rect.top, text[0].toUpperCase()));
  }

  entries.sort((a, b) => a.key.compareTo(b.key));
  return entries.map((e) => e.value).toList();
}

/// The word list's scroll position.
///
/// Not `Scrollable.first` — that is the search field's own horizontal
/// scroller, whose extent is always zero.
ScrollPosition listPosition(WidgetTester tester) {
  final scrollable = tester
      .widgetList<Scrollable>(find.byType(Scrollable))
      .firstWhere((s) => s.axisDirection == AxisDirection.down);
  return scrollable.controller!.position;
}

Future<void> pumpScreen(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(_surface);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(harness());
  await tester.pumpAndSettle();
}

Finder get sliderFinder => find.byWidgetPredicate(
      (w) => w is Container && w.constraints?.maxWidth == 22,
    );

/// Taps the A-Z slider on [letter].
///
/// The slider maps a touch's dy to a letter by dividing its *full* height into
/// 26 bands, so the tap is aimed at the centre of the target band rather than
/// at the rendered glyph (which `spaceEvenly` insets slightly).
Future<void> tapLetter(WidgetTester tester, String letter) async {
  const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  final box = tester.getRect(sliderFinder.first);
  final extent = box.height / alphabet.length;
  final dy = box.top + extent * (alphabet.indexOf(letter) + 0.5);

  await tester.tapAt(Offset(box.center.dx, dy));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    _prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer();
    addTearDown(container.dispose);
    _allWords = {
      for (final w in container.read(vocabularyIndexProvider).words) w.word.word,
    };
  });

  group('A-Z jump', () {
    // Regression guard for the original bug: the jump used an estimated
    // offset (index * 190), which drifted further the deeper the letter, so
    // pressing a late letter landed dozens of cards away from it.
    for (final letter in ['A', 'M', 'S', 'T', 'Z']) {
      testWidgets('$letter lands on $letter', (tester) async {
        await pumpScreen(tester);

        await tapLetter(tester, letter);

        final initials = visibleInitials(tester);
        expect(initials, isNotEmpty, reason: 'no word cards visible after jump');
        expect(
          initials.first,
          letter,
          reason: 'jumped to $letter but the top card starts with '
              '${initials.first}',
        );
      });
    }

    testWidgets('jumping to Z reaches the end of the list', (tester) async {
      await pumpScreen(tester);
      await tapLetter(tester, 'Z');

      // Z is the last section, so the old bad maxScrollExtent clamp showed up
      // here first — the list should genuinely be at its end.
      final position = listPosition(tester);
      expect(position.pixels, closeTo(position.maxScrollExtent, 1.0));
    });

    testWidgets('an unused letter does nothing', (tester) async {
      await pumpScreen(tester);

      final before = visibleInitials(tester);
      await tapLetter(tester, 'X'); // the seed data has no X words
      expect(visibleInitials(tester), before);
    });
  });

  group('search', () {
    testWidgets('filters the list and hides the slider', (tester) async {
      await pumpScreen(tester);

      await tester.enterText(find.byType(TextField), 'abandon');
      await tester.pumpAndSettle();

      expect(find.text('Abandon'), findsOneWidget);
      // Slider is hidden while searching, since results span many letters.
      expect(
        find.byWidgetPredicate(
          (w) => w is Container && w.constraints?.maxWidth == 22,
        ),
        findsNothing,
      );
    });

    testWidgets('shows an empty state for no matches', (tester) async {
      await pumpScreen(tester);

      await tester.enterText(find.byType(TextField), 'zzzqqqnotaword');
      await tester.pumpAndSettle();

      expect(find.text('No words found'), findsOneWidget);
    });

    testWidgets('clearing restores the full list and the slider',
        (tester) async {
      await pumpScreen(tester);

      await tester.enterText(find.byType(TextField), 'abandon');
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('No words found'), findsNothing);
      expect(
        find.byWidgetPredicate(
          (w) => w is Container && w.constraints?.maxWidth == 22,
        ),
        findsOneWidget,
      );
    });

    testWidgets('typing character by character stays consistent',
        (tester) async {
      // Exercises the incremental-narrowing path in the screen.
      await pumpScreen(tester);

      for (final q in ['a', 'ab', 'aba', 'aban', 'abando', 'abandon']) {
        await tester.enterText(find.byType(TextField), q);
        await tester.pumpAndSettle();
      }
      expect(find.text('Abandon'), findsOneWidget);

      // Retyping the same query from scratch must give the same result.
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'abandon');
      await tester.pumpAndSettle();
      expect(find.text('Abandon'), findsOneWidget);
    });
  });

  group('letter headers', () {
    testWidgets('a sticky header is shown for the current section',
        (tester) async {
      await pumpScreen(tester);

      expect(find.byType(SliverPersistentHeader), findsWidgets);
      await tapLetter(tester, 'M');
      expect(find.text('M'), findsWidgets);
    });

    testWidgets('headers do not stack up and crowd out the list',
        (tester) async {
      // Regression guard: pinned headers that are direct children of the
      // scroll view all stick at once, stacking into a wall of letters that
      // pushed the words off screen.
      await pumpScreen(tester);

      final viewport = tester.getRect(find.byType(CustomScrollView));
      final pinnedAtTop = tester
          .widgetList<Text>(find.descendant(
            of: find.byType(SliverPersistentHeader),
            matching: find.byType(Text),
          ))
          .where((t) => t.data != null && t.data!.length == 1)
          .where((t) {
            final r = tester.getRect(find.byWidget(t));
            return r.top >= viewport.top && r.bottom <= viewport.bottom;
          })
          .length;

      expect(
        pinnedAtTop,
        lessThanOrEqualTo(2),
        reason: 'only the current section header should be pinned',
      );
      // Words must actually be visible, not buried under headers.
      expect(visibleInitials(tester), isNotEmpty);
    });
  });
}
