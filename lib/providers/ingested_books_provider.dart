import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../data/models/ingested_books.dart';
import '../data/services/learn_assist_service.dart';

/// Reference of vector-DB-ingested books, loaded from the bundled asset in
/// main() and injected via ProviderScope overrides (same pattern as
/// sharedPreferencesProvider).
final ingestedBooksProvider = Provider<IngestedBooks>((ref) {
  throw UnimplementedError(
    'ingestedBooksProvider must be overridden in ProviderScope',
  );
});

/// Refresh AI textbook coverage from the API while retaining the bundled
/// manifest when the device is offline or the server is being upgraded.
final remoteIngestedBooksProvider = FutureProvider<IngestedBooks>((ref) async {
  final bundled = ref.watch(ingestedBooksProvider);
  try {
    final response = await http
        .get(LearnAssistService.defaultBaseUrl.resolve('/catalog/v1'))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode != 200) return bundled;
    return IngestedBooks.fromCatalogApi(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  } catch (_) {
    return bundled;
  }
});

final activeIngestedBooksProvider = Provider<IngestedBooks>((ref) {
  final bundled = ref.watch(ingestedBooksProvider);
  return ref.watch(remoteIngestedBooksProvider).maybeWhen(
    data: (catalog) => catalog,
    orElse: () => bundled,
  );
});
