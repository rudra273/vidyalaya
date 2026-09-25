import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../data/models/ingested_books.dart';
import '../data/services/learn_assist_service.dart';
import 'auth_provider.dart';

final learnAssistServiceProvider = Provider<LearnAssistService>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return LearnAssistService(
    client: client,
    idTokenProvider: ({required forceRefresh}) async {
      final user = ref.read(firebaseAuthProvider).currentUser;
      return user?.getIdToken(forceRefresh);
    },
  );
});

/// LearnAssist serves classes 6-12; younger classes will get a separate
/// generic agent and must never drive this channel's class/subject selection.
const int learnAssistMinClass = 6;

/// Subjects the AI can retrieve textbook content for, per board + class.
/// Strictly reflects the ingested vector DB — empty when nothing is ingested.
List<String> learnAssistSubjects(
  IngestedBooks ingestedBooks,
  String board,
  int classNo,
) {
  return ingestedBooks
      .subjectsFor(board, classNo)
      .map((subject) => subject.subject)
      .toList()
    ..sort();
}

String detectLearnAssistLanguage(String text) {
  final hasOdia = RegExp(r'[\u0B00-\u0B7F]').hasMatch(text);
  if (hasOdia) return 'or';
  final hasDevanagari = RegExp(r'[\u0900-\u097F]').hasMatch(text);
  return hasDevanagari ? 'hi' : 'en';
}

/// The chat language selected when a conversation first opens. Keep this
/// separate from [detectLearnAssistLanguage]: script detection remains useful
/// when a student explicitly switches the chat picker back to Auto.
String defaultLearnAssistLanguage(String? preferredLanguage) {
  return switch (preferredLanguage?.trim().toLowerCase()) {
    'or' => 'or',
    'hi' => 'hi',
    _ => 'en',
  };
}
