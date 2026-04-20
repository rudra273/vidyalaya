import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/highlight.dart';
import '../models/timetable_period.dart';

/// Repository for persisting user preferences (selected classes, last read book, etc.)
/// Uses SharedPreferences — data survives cache clears but not app uninstall.
class UserPrefsRepository {
  static const _selectedClassesKey = 'selected_classes';
  static const _lastReadBookIdKey = 'last_read_book_id';
  static const _bookPagePrefix = 'book_page_';
  static const _bookmarksPrefix = 'bookmarks_';
  static const _highlightsPrefix = 'highlights_';
  static const _readerModeKey = 'reader_view_mode';
  static const _readerFilterKey = 'reader_filter';
  static const _timetableKey = 'timetable_data';

  final SharedPreferences _prefs;

  UserPrefsRepository(this._prefs);

  // ─── Selected Classes ───────────────────────────────────────────────────

  Set<int> getSelectedClasses() {
    final jsonStr = _prefs.getString(_selectedClassesKey);
    if (jsonStr == null) return {};
    final list = jsonDecode(jsonStr) as List;
    return list.map((e) => e as int).toSet();
  }

  Future<void> setSelectedClasses(Set<int> classes) async {
    await _prefs.setString(_selectedClassesKey, jsonEncode(classes.toList()));
  }

  // ─── Last Read Book ─────────────────────────────────────────────────────

  String? getLastReadBookId() {
    return _prefs.getString(_lastReadBookIdKey);
  }

  Future<void> setLastReadBookId(String bookId) async {
    await _prefs.setString(_lastReadBookIdKey, bookId);
  }

  // ─── Per-Book Last Read Page ────────────────────────────────────────────

  int getLastReadPage(String bookId) {
    return _prefs.getInt('$_bookPagePrefix$bookId') ?? 0;
  }

  Future<void> setLastReadPage(String bookId, int page) async {
    await _prefs.setInt('$_bookPagePrefix$bookId', page);
  }

  // ─── Per-Book Bookmarks ─────────────────────────────────────────────────

  List<int> getBookmarks(String bookId) {
    final jsonStr = _prefs.getString('$_bookmarksPrefix$bookId');
    if (jsonStr == null) return [];
    final list = jsonDecode(jsonStr) as List;
    return list.map((e) => e as int).toList()..sort();
  }

  Future<void> setBookmarks(String bookId, List<int> pages) async {
    pages.sort();
    await _prefs.setString('$_bookmarksPrefix$bookId', jsonEncode(pages));
  }

  Future<void> toggleBookmark(String bookId, int page) async {
    final bookmarks = getBookmarks(bookId);
    if (bookmarks.contains(page)) {
      bookmarks.remove(page);
    } else {
      bookmarks.add(page);
    }
    await setBookmarks(bookId, bookmarks);
  }

  bool isBookmarked(String bookId, int page) {
    return getBookmarks(bookId).contains(page);
  }

  // ─── Per-Book Highlights ────────────────────────────────────────────────

  List<Highlight> getHighlights(String bookId) {
    final jsonStr = _prefs.getString('$_highlightsPrefix$bookId');
    if (jsonStr == null) return [];
    final list = jsonDecode(jsonStr) as List;
    return list.map((e) => Highlight.fromJson(e as Map<String, dynamic>)).toList();
  }

  List<Highlight> getHighlightsForPage(String bookId, int page) {
    return getHighlights(bookId).where((h) => h.pageNumber == page).toList();
  }

  Future<void> _saveHighlights(String bookId, List<Highlight> highlights) async {
    final json = highlights.map((h) => h.toJson()).toList();
    await _prefs.setString('$_highlightsPrefix$bookId', jsonEncode(json));
  }

  Future<void> addHighlight(Highlight highlight) async {
    final highlights = getHighlights(highlight.bookId);
    highlights.add(highlight);
    await _saveHighlights(highlight.bookId, highlights);
  }

  Future<void> removeHighlight(String bookId, String highlightId) async {
    final highlights = getHighlights(bookId);
    highlights.removeWhere((h) => h.id == highlightId);
    await _saveHighlights(bookId, highlights);
  }

  Future<void> updateHighlightNote(
      String bookId, String highlightId, String? note) async {
    final highlights = getHighlights(bookId);
    final index = highlights.indexWhere((h) => h.id == highlightId);
    if (index != -1) {
      highlights[index] = highlights[index].copyWith(note: note);
      await _saveHighlights(bookId, highlights);
    }
  }

  // ─── Reader Preferences ─────────────────────────────────────────────────

  String getReaderViewMode() {
    return _prefs.getString(_readerModeKey) ?? 'paginated';
  }

  Future<void> setReaderViewMode(String mode) async {
    await _prefs.setString(_readerModeKey, mode);
  }

  String getReaderFilter() {
    return _prefs.getString(_readerFilterKey) ?? 'none';
  }

  Future<void> setReaderFilter(String filter) async {
    await _prefs.setString(_readerFilterKey, filter);
  }

  // ─── Timetable ──────────────────────────────────────────────────────────

  Map<String, List<TimetablePeriod>> getTimetable() {
    final jsonStr = _prefs.getString(_timetableKey);
    if (jsonStr == null) return {};

    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    return map.map((key, value) {
      final list = (value as List)
          .map((e) => TimetablePeriod.fromJson(e as Map<String, dynamic>))
          .toList();
      return MapEntry(key, list);
    });
  }

  Future<void> saveTimetable(Map<String, List<TimetablePeriod>> timetable) async {
    final map = timetable.map((key, value) {
      return MapEntry(key, value.map((p) => p.toJson()).toList());
    });
    await _prefs.setString(_timetableKey, jsonEncode(map));
  }
}
