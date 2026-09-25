import '../lab_kit.dart';
import 'circuit_rig.dart';
import 'fizz_rig.dart';
import 'float_rig.dart';
import 'indicator_rig.dart';
import 'mirror_rig.dart';
import 'pendulum_rig.dart';

// ─── Rig registry ─────────────────────────────────────────────────────────────

const labRigs = <String, LabRig>{
  'circuit': CircuitRig(),
  'pendulum': PendulumRig(),
  'mirror': MirrorRig(),
  'float': FloatRig(),
  'indicator': IndicatorRig(),
  'fizz': FizzRig(),
};
