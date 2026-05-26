import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../data/seed/seed_data.dart';
import '../data/services/learn_assist_service.dart';

final learnAssistServiceProvider = Provider<LearnAssistService>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return LearnAssistService(client: client);
});

int resolveLearnAssistClass(Set<int> selectedClasses) {
  if (selectedClasses.isEmpty) return 8;
  final sorted = selectedClasses.toList()..sort();
  return sorted.first;
}

List<int> learnAssistClassOptions(Set<int> selectedClasses) {
  if (selectedClasses.isEmpty) return const [8];
  return selectedClasses.toList()..sort();
}

List<String> learnAssistSubjectsForClass(int classNo) {
  return getBooksByClass(classNo).map((book) => book.subject).toSet().toList()
    ..sort();
}

String detectLearnAssistLanguage(String text) {
  final hasOdia = RegExp(r'[\u0B00-\u0B7F]').hasMatch(text);
  return hasOdia ? 'or' : 'en';
}
