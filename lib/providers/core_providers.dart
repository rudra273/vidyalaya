import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/user_prefs_repository.dart';

/// Provider for SharedPreferences instance.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope',
  );
});

/// Provider for the UserPrefsRepository.
final userPrefsRepositoryProvider = Provider<UserPrefsRepository>((ref) {
  return UserPrefsRepository(ref.watch(sharedPreferencesProvider));
});
