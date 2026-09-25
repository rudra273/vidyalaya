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

/// Deep link back to the conversation a past question was asked in — its own
/// subject thread when it had one, otherwise the general chat.
String recentQuestionResumePath(RecentQuestion question) {
  // Resume the conversation the question was asked in — don't seed the
  // composer with it. It's already asked and answered; re-typing it into the
  // input reads as if the tap did nothing.
  final subject = question.subject;
  if (subject == null) return '/learn/ai?resume=1';
  return '/learn/ai?resume=1&subject=${Uri.encodeComponent(subject)}';
}
