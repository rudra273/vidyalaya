import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/recent_question.dart';
import 'auth_provider.dart';
import 'core_providers.dart';

/// The student's latest AI questions, read from SharedPreferences. Kept in a
/// notifier (rather than read inline) so the AI tab's "pick up where you left
/// off" row updates the moment the chat records a new question.
class RecentQuestionsNotifier extends Notifier<List<RecentQuestion>> {
  @override
  List<RecentQuestion> build() {
    final uid = ref
        .watch(authStateProvider)
        .maybeWhen(data: (user) => user?.uid, orElse: () => null);
    if (uid == null) return const [];
    return ref.read(userPrefsRepositoryProvider).getRecentQuestions(uid);
  }

  void refresh() {
    final uid = ref.read(firebaseAuthProvider).currentUser?.uid;
    state = uid == null
        ? const []
        : ref.read(userPrefsRepositoryProvider).getRecentQuestions(uid);
  }

  Future<void> clear() async {
    final uid = ref.read(firebaseAuthProvider).currentUser?.uid;
    if (uid != null) {
      await ref.read(userPrefsRepositoryProvider).clearRecentQuestions(uid);
    }
    state = const [];
  }
}

final recentQuestionsProvider =
    NotifierProvider<RecentQuestionsNotifier, List<RecentQuestion>>(
      RecentQuestionsNotifier.new,
    );
