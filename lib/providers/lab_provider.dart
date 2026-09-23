import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Enable the pilot explicitly with `--dart-define=ENABLE_LABS=true`.
final labsEnabledProvider = Provider<bool>(
  (ref) => const bool.fromEnvironment('ENABLE_LABS', defaultValue: false),
);

bool labAvailableForSelection({
  required bool enabled,
  required String board,
  required Iterable<int> selectedClasses,
}) => enabled && board == 'scert_odisha' && selectedClasses.contains(7);
