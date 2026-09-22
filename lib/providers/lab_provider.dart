import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../data/services/lab_service.dart';

/// Enabled for beta builds with --dart-define=ENABLE_LABS=true.
final labsEnabledProvider = Provider<bool>(
  (ref) => const bool.fromEnvironment('ENABLE_LABS', defaultValue: false),
);

bool labAvailableForSelection({
  required bool enabled,
  required String board,
  required Iterable<int> selectedClasses,
}) =>
    enabled && board == 'scert_odisha' && selectedClasses.contains(7);

final labServiceProvider = Provider<LabService>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return LabService(client: client);
});
