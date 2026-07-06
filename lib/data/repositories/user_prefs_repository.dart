import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/highlight.dart';
import '../models/note.dart';
import '../models/timetable_period.dart';
import '../models/time_slot.dart';

/// Repository for persisting user preferences (selected classes, last read book, etc.)
/// Uses SharedPreferences — data survives cache clears but not app uninstall.
class UserPrefsRepository {
  static const _selectedClassesKey = 'selected_classes';
  static const _selectedBoardKey = 'selected_board';
  static const _lastReadBookIdKey = 'last_read_book_id';
  static const _bookPagePrefix = 'book_page_';
  static const _bookmarksPrefix = 'bookmarks_';
  static const _highlightsPrefix = 'highlights_';
  static const _readerModeKey = 'reader_view_mode';
  static const _readerFilterKey = 'reader_filter';
  static const _timetableKey = 'timetable_data';
  static const _onboardingKey = 'has_completed_onboarding';
  static const _avatarIdKey = 'avatar_id';
  static const _regionalLanguageKey = 'regional_language';
  static const _preferredLanguageKey = 'preferred_language';

  final SharedPreferences _prefs;

  UserPrefsRepository(this._prefs);

  // ─── Onboarding ─────────────────────────────────────────────────────────

  bool getHasCompletedOnboarding() {
    return _prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> setHasCompletedOnboarding(bool value) async {
    await _prefs.setBool(_onboardingKey, value);
  }

  // ─── Avatar ─────────────────────────────────────────────────────────────
  //
  // Students pick from bundled illustrations instead of uploading a photo
  // (under-13 privacy). Stores the avatar id, or null for the letter default.

  String? getAvatarId() {
    return _prefs.getString(_avatarIdKey);
  }

  Future<void> setAvatarId(String? id) async {
    if (id == null) {
      await _prefs.remove(_avatarIdKey);
    } else {
      await _prefs.setString(_avatarIdKey, id);
    }
  }

  // ─── Regional Language ──────────────────────────────────────────────────
  //
  // The second language shown alongside English in the Explore tools
  // (diagrams, timeline, math formulas). Either 'or' (Odia) or 'hi' (Hindi).
  // Null means "follow the profile preference / board default"; once the
  // student switches it explicitly, the choice is remembered here.

  String? getRegionalLanguage() {
    return _prefs.getString(_regionalLanguageKey);
  }

  Future<void> setRegionalLanguage(String code) async {
    await _prefs.setString(_regionalLanguageKey, code);
  }

  /// Forget the explicit language switch (used when the board changes, so the
  /// language follows the new board's default).
  Future<void> clearRegionalLanguage() async {
    await _prefs.remove(_regionalLanguageKey);
  }

  // ─── Preferred Language ─────────────────────────────────────────────────
  //
  // The profile's preferred language ('en', 'or' or 'hi'). Local mirror of
  // the backend profile field so signed-out students can pick a language and
  // keep it across restarts; it also seeds the first profile save on sign-in.

  String? getPreferredLanguage() {
    return _prefs.getString(_preferredLanguageKey);
  }

  Future<void> setPreferredLanguage(String code) async {
    await _prefs.setString(_preferredLanguageKey, code);
  }

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

  // ─── Selected Board ─────────────────────────────────────────────────────

  String getSelectedBoard() {
    return _prefs.getString(_selectedBoardKey) ?? 'scert_odisha';
  }

  Future<void> setSelectedBoard(String board) async {
    await _prefs.setString(_selectedBoardKey, board);
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
    return list
        .map((e) => Highlight.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  List<Highlight> getHighlightsForPage(String bookId, int page) {
    return getHighlights(bookId).where((h) => h.pageNumber == page).toList();
  }

  Future<void> _saveHighlights(
    String bookId,
    List<Highlight> highlights,
  ) async {
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
    String bookId,
    String highlightId,
    String? note,
  ) async {
    final highlights = getHighlights(bookId);
    final index = highlights.indexWhere((h) => h.id == highlightId);
    if (index != -1) {
      highlights[index] = highlights[index].copyWith(note: note);
      await _saveHighlights(bookId, highlights);
    }
  }

  // ─── Standalone Notes ───────────────────────────────────────────────────
  //
  // Free-form notes the student types directly (not tied to a book/highlight).
  // Stored as a single JSON list under [_notesKey]. Local-only for now; a
  // backend sync may replace this later.

  static const _notesKey = 'standalone_notes';

  /// All standalone notes, most recently updated first.
  List<Note> getNotes() {
    final jsonStr = _prefs.getString(_notesKey);
    if (jsonStr == null) return [];
    final list = jsonDecode(jsonStr) as List;
    final notes = list
        .map((e) => Note.fromJson(e as Map<String, dynamic>))
        .toList();
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  Note? getNote(String id) {
    for (final n in getNotes()) {
      if (n.id == id) return n;
    }
    return null;
  }

  Future<void> _saveNotes(List<Note> notes) async {
    final json = notes.map((n) => n.toJson()).toList();
    await _prefs.setString(_notesKey, jsonEncode(json));
  }

  /// Inserts a new note or replaces an existing one with the same id.
  Future<void> upsertNote(Note note) async {
    final notes = getNotes();
    final index = notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      notes[index] = note;
    } else {
      notes.add(note);
    }
    await _saveNotes(notes);
  }

  Future<void> deleteNote(String id) async {
    final notes = getNotes()..removeWhere((n) => n.id == id);
    await _saveNotes(notes);
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

  static const _timeSlotsKey = 'time_slots_data';

  List<TimeSlot> getTimeSlots() {
    final jsonStr = _prefs.getString(_timeSlotsKey);
    if (jsonStr == null) {
      // Default time slots
      return [
        const TimeSlot(
          id: 'ts1',
          name: 'Period 1',
          startTime: '10:30',
          endTime: '11:15',
        ),
        const TimeSlot(
          id: 'ts2',
          name: 'Period 2',
          startTime: '11:15',
          endTime: '12:00',
        ),
        const TimeSlot(
          id: 'ts3',
          name: 'Short Break',
          startTime: '12:00',
          endTime: '12:15',
          isBreak: true,
        ),
        const TimeSlot(
          id: 'ts4',
          name: 'Period 3',
          startTime: '12:15',
          endTime: '13:00',
        ),
        const TimeSlot(
          id: 'ts5',
          name: 'Lunch',
          startTime: '13:00',
          endTime: '14:00',
          isBreak: true,
        ),
        const TimeSlot(
          id: 'ts6',
          name: 'Period 4',
          startTime: '14:00',
          endTime: '14:45',
        ),
        const TimeSlot(
          id: 'ts7',
          name: 'Period 5',
          startTime: '15:00',
          endTime: '15:45',
        ),
      ];
    }
    final list = jsonDecode(jsonStr) as List;
    return list
        .map((e) => TimeSlot.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveTimeSlots(List<TimeSlot> slots) async {
    final jsonList = slots.map((s) => s.toJson()).toList();
    await _prefs.setString(_timeSlotsKey, jsonEncode(jsonList));
  }

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

  Future<void> saveTimetable(
    Map<String, List<TimetablePeriod>> timetable,
  ) async {
    final map = timetable.map((key, value) {
      return MapEntry(key, value.map((p) => p.toJson()).toList());
    });
    await _prefs.setString(_timetableKey, jsonEncode(map));
  }

  // ─── Chat session recency ────────────────────────────────────────────────
  //
  // Tracks when the student last interacted with an AI chat (per channel).
  // The chat screen uses this to start fresh — suggestions up front, previous
  // conversation behind a "load" link — when they've been away a while.

  static const _chatLastActivityPrefix = 'chat_last_activity_';

  DateTime? getChatLastActivity(String channel) {
    final millis = _prefs.getInt('$_chatLastActivityPrefix$channel');
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> recordChatActivity(String channel) async {
    await _prefs.setInt(
      '$_chatLastActivityPrefix$channel',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  // ─── Learning Analytics ──────────────────────────────────────────────────
  //
  // Tracks ALL learning activity, not just reading: pages read, AI sessions,
  // and interactive tools opened. The streak is a *learning* streak — any of
  // these actions keeps it alive (see [_recordActivityToday]).

  static const _totalStudySecondsKey = 'total_study_seconds';
  static const _totalPagesReadKey = 'total_pages_read';
  static const _pagesReadTodayKey = 'pages_read_today';
  static const _lastActiveDateKey = 'last_active_date';
  static const _currentStreakKey = 'current_streak';
  static const _subjectProgressPrefix = 'subject_progress_';
  static const _aiSessionsKey = 'ai_sessions_total';
  static const _toolsOpenedKey = 'tools_opened_total';

  int getTotalStudySeconds() => _prefs.getInt(_totalStudySecondsKey) ?? 0;

  Future<void> addStudySeconds(int seconds) async {
    final current = getTotalStudySeconds();
    await _prefs.setInt(_totalStudySecondsKey, current + seconds);
  }

  int getTotalPagesRead() => _prefs.getInt(_totalPagesReadKey) ?? 0;

  int getPagesReadToday() {
    _recordActivityToday();
    return _prefs.getInt(_pagesReadTodayKey) ?? 0;
  }

  Future<void> addPagesRead(int pages, String subject) async {
    await _recordActivityToday();

    final currentTotal = getTotalPagesRead();
    await _prefs.setInt(_totalPagesReadKey, currentTotal + pages);

    final currentToday = _prefs.getInt(_pagesReadTodayKey) ?? 0;
    await _prefs.setInt(_pagesReadTodayKey, currentToday + pages);

    final subjectKey = '$_subjectProgressPrefix$subject';
    final currentSubject = _prefs.getInt(subjectKey) ?? 0;
    await _prefs.setInt(subjectKey, currentSubject + pages);
  }

  int getSubjectPages(String subject) {
    return _prefs.getInt('$_subjectProgressPrefix$subject') ?? 0;
  }

  // ─── AI sessions & tools (learning activity) ──────────────────────────────

  int getAiSessions() => _prefs.getInt(_aiSessionsKey) ?? 0;

  int getToolsOpened() => _prefs.getInt(_toolsOpenedKey) ?? 0;

  /// Records one AI Q&A/Tutor interaction. Keeps the learning streak alive.
  Future<void> recordAiSession() async {
    await _prefs.setInt(_aiSessionsKey, getAiSessions() + 1);
    await _recordActivityToday();
  }

  /// Records opening an interactive learning tool. Keeps the learning streak
  /// alive. [toolId] is accepted for future per-tool analytics.
  Future<void> recordToolOpened(String toolId) async {
    await _prefs.setInt(_toolsOpenedKey, getToolsOpened() + 1);
    await _recordActivityToday();
  }

  int getCurrentStreak() {
    _recordActivityToday();
    return _prefs.getInt(_currentStreakKey) ?? 0;
  }

  /// Rolls over the day and advances the learning streak. Idempotent within a
  /// day. Called by every learning action (reading, AI, tools) so the streak
  /// reflects all learning — not reading alone.
  Future<void> _recordActivityToday() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastDate = _prefs.getString(_lastActiveDateKey);

    if (lastDate != today) {
      await _prefs.setInt(_pagesReadTodayKey, 0);

      int streak = _prefs.getInt(_currentStreakKey) ?? 0;
      if (lastDate != null) {
        final last = DateTime.parse(lastDate);
        final current = DateTime.parse(today);
        final diff = current.difference(last).inDays;

        if (diff == 1) {
          streak += 1;
        } else {
          streak = 1;
        }
      } else {
        streak = 1;
      }

      await _prefs.setInt(_currentStreakKey, streak);
      await _prefs.setString(_lastActiveDateKey, today);
    }
  }
}
