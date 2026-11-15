import 'dart:async';

import 'package:vidyalaya/widgets/ai_robot_mark.dart';

// ─── Test setup ───
// Runs before every test file. The AI bot loops forever, which would keep
// `pumpAndSettle` from ever settling, so tests show it still.

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  AiBot.debugHoldStill = true;
  await testMain();
}
