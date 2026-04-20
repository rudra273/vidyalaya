import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository for persisting user preferences (selected classes, last read book, etc.)
/// Uses SharedPreferences — data survives cache clears but not app uninstall.
class UserPrefsRepository {
  static const _selectedClassesKey = 'selected_classes';
  static const _lastReadBookIdKey = 'last_read_book_id';
  static const _bookPagePrefix = 'book_page_';
  static const _bookmarksPrefix = 'bookmarks_';
  static const _readerModeKey = 'reader_view_mode';  // 'paginated' | 'scroll'
  static const _readerFilterKey = 'reader_filter';    // 'none' | 'dark' | 'sepia'

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
}
