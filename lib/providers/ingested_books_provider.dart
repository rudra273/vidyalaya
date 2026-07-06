import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/ingested_books.dart';

/// Reference of vector-DB-ingested books, loaded from the bundled asset in
/// main() and injected via ProviderScope overrides (same pattern as
/// sharedPreferencesProvider).
final ingestedBooksProvider = Provider<IngestedBooks>((ref) {
  throw UnimplementedError(
    'ingestedBooksProvider must be overridden in ProviderScope',
  );
});
