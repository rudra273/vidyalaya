import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyalaya/data/models/ingested_books.dart';
import 'package:vidyalaya/providers/core_providers.dart';
import 'package:vidyalaya/providers/learn_assist_provider.dart';
import 'package:vidyalaya/providers/user_selection_provider.dart';
import 'package:vidyalaya/widgets/ai_gate.dart';

// ─── AI access by class ───────────────────────────────────────────────────────

void main() {
  const science = IngestedSubject(
    subject: 'science',
    bookName: 'Science',
    language: 'en',
  );
  const books = IngestedBooks({
    'scert_odisha': {
      7: [science],
      8: [science],
    },
    'ncert': {
      6: [science],
    },
  });

  group('aiAccessFor', () {
    test('below class 6 is hidden, even with textbooks', () {
      const withClass5 = IngestedBooks({
        'scert_odisha': {
          5: [science],
        },
      });
      for (var c = 1; c <= 5; c++) {
        expect(aiAccessFor(withClass5, 'scert_odisha', c), AiAccess.hidden);
      }
    });

    test('class 6+ without textbooks is coming soon', () {
      expect(aiAccessFor(books, 'scert_odisha', 6), AiAccess.comingSoon);
      expect(aiAccessFor(books, 'ncert', 10), AiAccess.comingSoon);
      expect(aiAccessFor(books, 'other_board', 8), AiAccess.comingSoon);
    });

    test('class 6+ with textbooks is available', () {
      expect(aiAccessFor(books, 'scert_odisha', 7), AiAccess.available);
      expect(aiAccessFor(books, 'ncert', 6), AiAccess.available);
    });
  });

  group('AiGate', () {
    Future<void> pumpGate(WidgetTester tester, AiAccess access) async {
      SharedPreferences.setMockInitialValues({'primary_class': 6});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            accountUidProvider.overrideWithValue(null),
            aiAccessProvider.overrideWithValue(access),
          ],
          child: const MaterialApp(
            home: Scaffold(body: AiGate(inShell: true, child: Text('chat'))),
          ),
        ),
      );
    }

    testWidgets('shows the child when available', (tester) async {
      await pumpGate(tester, AiAccess.available);
      expect(find.text('chat'), findsOneWidget);
    });

    testWidgets('shows coming soon instead of the child', (tester) async {
      await pumpGate(tester, AiAccess.comingSoon);
      expect(find.text('chat'), findsNothing);
      expect(find.text('AI for Class 6 is coming soon'), findsOneWidget);
    });
  });
}
