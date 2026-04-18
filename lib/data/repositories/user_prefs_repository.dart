import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository for persisting user preferences (selected classes, last read book, etc.)
/// Uses SharedPreferences — data survives cache clears but not app uninstall.
class UserPrefsRepository {
  static const _selectedClassesKey = 'selected_classes';
  static const _lastReadBookIdKey = 'last_read_book_id';

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
}
