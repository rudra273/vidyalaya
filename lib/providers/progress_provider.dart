import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core_providers.dart';

/// Aggregated *learning* statistics (not reading alone): the streak counts any
/// learning activity, and AI sessions + tools opened sit alongside reading.
class ProgressStats {
  final int currentStreak; // learning streak — any activity keeps it alive
  final int totalPagesRead;
  final int totalStudySeconds;
  final int pagesReadToday;
  final int aiSessions;
  final int toolsOpened;
  final Map<String, int> subjectPages;

  const ProgressStats({
    required this.currentStreak,
    required this.totalPagesRead,
    required this.totalStudySeconds,
    required this.pagesReadToday,
    required this.aiSessions,
    required this.toolsOpened,
    required this.subjectPages,
  });
}

class ProgressNotifier extends Notifier<ProgressStats> {
  @override
  ProgressStats build() {
    return _loadStats();
  }

  ProgressStats _loadStats() {
    final repo = ref.read(userPrefsRepositoryProvider);
    
    final currentStreak = repo.getCurrentStreak();
    final totalPagesRead = repo.getTotalPagesRead();
    final totalStudySeconds = repo.getTotalStudySeconds();
    final pagesReadToday = repo.getPagesReadToday();
    final aiSessions = repo.getAiSessions();
    final toolsOpened = repo.getToolsOpened();

    // Standard subjects
    final subjects = ['Mathematics', 'Science', 'Odia', 'English', 'History', 'Geography'];
    final subjectPages = <String, int>{};
    
    for (final subject in subjects) {
      final pages = repo.getSubjectPages(subject);
      if (pages > 0) {
        subjectPages[subject] = pages;
      }
    }

    return ProgressStats(
      currentStreak: currentStreak,
      totalPagesRead: totalPagesRead,
      totalStudySeconds: totalStudySeconds,
      pagesReadToday: pagesReadToday,
      aiSessions: aiSessions,
      toolsOpened: toolsOpened,
      subjectPages: subjectPages,
    );
  }

  void refresh() {
    state = _loadStats();
  }
}

final progressProvider = NotifierProvider<ProgressNotifier, ProgressStats>(
  ProgressNotifier.new,
);
