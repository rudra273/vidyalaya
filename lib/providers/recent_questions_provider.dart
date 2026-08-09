import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/recent_question.dart';
import 'core_providers.dart';

/// The student's latest AI questions, read from SharedPreferences. Kept in a
/// notifier (rather than read inline) so the AI tab's "pick up where you left
/// off" row updates the moment the chat records a new question.
class RecentQuestionsNotifier extends Notifier<List<RecentQuestion>> {
  @override
  List<RecentQuestion> build() {
    return ref.read(userPrefsRepositoryProvider).getRecentQuestions();
  }

  void refresh() {
    state = ref.read(userPrefsRepositoryProvider).getRecentQuestions();
  }

  Future<void> clear() async {
    await ref.read(userPrefsRepositoryProvider).clearRecentQuestions();
    state = const [];
  }
}

final recentQuestionsProvider =
    NotifierProvider<RecentQuestionsNotifier, List<RecentQuestion>>(
      RecentQuestionsNotifier.new,
    );
