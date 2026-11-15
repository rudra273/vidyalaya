import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyalaya/data/repositories/user_prefs_repository.dart';

// ─── Saved-data parsing ───────────────────────────────────────────────────────
//
// One bad stored value must fall back to the empty default (and be dropped),
// never throw while a screen builds.

void main() {
  Future<(UserPrefsRepository, SharedPreferences)> repoWith(
    Map<String, Object> values,
  ) async {
    SharedPreferences.setMockInitialValues(values);
    final prefs = await SharedPreferences.getInstance();
    return (UserPrefsRepository(prefs), prefs);
  }

  group('corrupt values fall back and are removed', () {
    test('selected classes', () async {
      final (repo, prefs) = await repoWith({
        'selected_classes': 'not json',
        'library_selected_classes': '["a"]',
      });
      expect(repo.getSelectedClasses(), isEmpty);
      expect(repo.getLibrarySelectedClasses(), isEmpty);
      expect(prefs.containsKey('selected_classes'), isFalse);
      expect(prefs.containsKey('library_selected_classes'), isFalse);
    });

    test('bookmarks and highlights', () async {
      final (repo, prefs) = await repoWith({
        'bookmarks_b1': '{"x":1}',
        'highlights_b1': '[1, 2]',
      });
      expect(repo.getBookmarks('b1'), isEmpty);
      expect(repo.getHighlights('b1'), isEmpty);
      expect(prefs.containsKey('bookmarks_b1'), isFalse);
      // The fallback list stays usable for callers that add to it.
      await repo.toggleBookmark('b1', 3);
      expect(repo.getBookmarks('b1'), [3]);
    });

    test('notes, timetable and scores', () async {
      final (repo, _) = await repoWith({
        'standalone_notes': '[{"id": 1}]',
        'timetable_data': '[]',
        'python_completed_lessons': '[1]',
        'python_quiz_scores': '{"c1": "x"}',
        'math_best_scores': 'oops',
      });
      expect(repo.getNotes(), isEmpty);
      expect(repo.getTimetable(), isEmpty);
      expect(repo.getPythonCompletedLessons(), isEmpty);
      expect(repo.getPythonQuizScores(), isEmpty);
      expect(repo.getMathBestScores(), isEmpty);
    });

    test('time slots fall back to the default day', () async {
      final (repo, prefs) = await repoWith({'time_slots_data': '{bad'});
      expect(repo.getTimeSlots(), isNotEmpty);
      expect(prefs.containsKey('time_slots_data'), isFalse);
    });

    test('a value stored with the wrong type', () async {
      final (repo, _) = await repoWith({'selected_classes': 7});
      expect(repo.getSelectedClasses(), isEmpty);
    });
  });

  test('valid values still parse', () async {
    final (repo, _) = await repoWith({
      'selected_classes': '[8, 9]',
      'bookmarks_b1': '[5, 2]',
      'math_best_scores': '{"t": 4}',
    });
    expect(repo.getSelectedClasses(), {8, 9});
    expect(repo.getBookmarks('b1'), [2, 5]);
    expect(repo.getMathBestScores(), {'t': 4});
  });

  test('clearBookData removes only that book', () async {
    final (repo, prefs) = await repoWith({
      'book_page_b1': 4,
      'bookmarks_b1': '[1]',
      'highlights_b1': '[]',
      'bookmarks_b2': '[2]',
      'last_read_book_id': 'b1',
      'recent_book_ids': ['b1', 'b2'],
    });
    await repo.clearBookData('b1');
    expect(prefs.containsKey('book_page_b1'), isFalse);
    expect(repo.getBookmarks('b1'), isEmpty);
    expect(prefs.containsKey('highlights_b1'), isFalse);
    expect(repo.getLastReadBookId(), isNull);
    expect(repo.getRecentBookIds(), ['b2']);
    expect(repo.getBookmarks('b2'), [2]);
  });
}
