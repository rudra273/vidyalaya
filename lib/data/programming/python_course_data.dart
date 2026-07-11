import 'python_models.dart';
import 'python_beginner_data.dart';
import 'python_intermediate_data.dart';
import 'python_advanced_data.dart';

// ─── Python course (aggregated) ───────────────────────────────────────────────
//
// All chapters in course order. Lookups by id back the go_router routes so we
// pass ids in the URL rather than fragile `state.extra` objects.

const List<PythonChapter> pythonChapters = [
  ...pythonBeginnerChapters,
  ...pythonIntermediateChapters,
  ...pythonAdvancedChapters,
];

/// Total lesson count across the course, used for the overall progress ring.
int get pythonTotalLessons =>
    pythonChapters.fold(0, (sum, c) => sum + c.lessons.length);

List<PythonChapter> pythonChaptersFor(PythonLevel level) =>
    pythonChapters.where((c) => c.level == level).toList();

PythonChapter? pythonChapterById(String id) {
  for (final c in pythonChapters) {
    if (c.id == id) return c;
  }
  return null;
}

PythonLesson? pythonLessonById(String id) {
  for (final c in pythonChapters) {
    for (final l in c.lessons) {
      if (l.id == id) return l;
    }
  }
  return null;
}

/// The chapter a lesson belongs to (for "finish lesson" navigation).
PythonChapter? pythonChapterOfLesson(String lessonId) {
  for (final c in pythonChapters) {
    if (c.lessons.any((l) => l.id == lessonId)) return c;
  }
  return null;
}
