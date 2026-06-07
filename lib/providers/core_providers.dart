import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/cache/cache_store.dart';
import '../data/repositories/user_prefs_repository.dart';

/// Provider for SharedPreferences instance.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope',
  );
});

final cacheStoreProvider = Provider<CacheStore>((ref) {
  throw UnimplementedError(
    'cacheStoreProvider must be overridden in ProviderScope',
  );
});

/// Provider for the UserPrefsRepository.
final userPrefsRepositoryProvider = Provider<UserPrefsRepository>((ref) {
  return UserPrefsRepository(ref.watch(sharedPreferencesProvider));
});

/// Whether the reading/books feature ("Library") is enabled.
///
/// Books are now the app's tertiary feature and carry copyright risk, so every
/// book surface (the Library tab, the Home "recently added" row, continue-
/// reading) reads this flag and hides cleanly when it is false — leaving AI and
/// the tools fully functional with no dead links. Defaults to true for now.
final booksEnabledProvider = Provider<bool>((ref) => true);
