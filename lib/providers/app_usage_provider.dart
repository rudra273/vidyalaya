import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/user_prefs_repository.dart';
import 'core_providers.dart';

// ─── App use tracking ───────────────────────────────────────────────────────
// Counts the time the app is open in the foreground, per local day, for the
// Study time chart on Profile. It starts timing on resume, and saves on pause
// and once a minute, so a killed app loses at most a minute. Stored on the
// device only.

/// Longest stretch counted from one save to the next. Guards against a clock
/// change or a missed pause being counted as hours of use.
const _maxStretch = Duration(minutes: 5);
const _saveEvery = Duration(minutes: 1);

class AppUsageNotifier extends Notifier<Map<String, int>>
    with WidgetsBindingObserver {
  DateTime? _since;
  Timer? _timer;
  // Held from build so the final save on dispose never touches `ref`.
  late UserPrefsRepository _repo;

  /// Overridable clock for tests.
  DateTime Function() now = DateTime.now;

  @override
  Map<String, int> build() {
    _repo = ref.read(userPrefsRepositoryProvider);
    final binding = WidgetsBinding.instance;
    binding.addObserver(this);
    final lifecycle = binding.lifecycleState;
    if (lifecycle == null || lifecycle == AppLifecycleState.resumed) {
      _start();
    }
    ref.onDispose(() {
      binding.removeObserver(this);
      _stop();
    });
    return _repo.getDailyAppUseSeconds();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _start();
    } else {
      _stop();
    }
  }

  void _start() {
    if (_since != null) return;
    _since = now();
    _timer = Timer.periodic(_saveEvery, (_) => _save());
  }

  void _stop() {
    _save();
    _timer?.cancel();
    _timer = null;
    _since = null;
  }

  /// Adds the time since the last save to today, then restarts the count.
  void _save() {
    final since = _since;
    if (since == null) return;
    final at = now();
    _since = at;
    var stretch = at.difference(since);
    if (stretch.isNegative) return;
    if (stretch > _maxStretch) stretch = _maxStretch;
    final seconds = stretch.inSeconds;
    if (seconds <= 0) return;
    final repo = _repo;
    unawaited(
      repo.addAppUseSeconds(at, seconds).then((_) {
        if (ref.mounted) state = repo.getDailyAppUseSeconds();
      }),
    );
  }
}

final appUsageProvider = NotifierProvider<AppUsageNotifier, Map<String, int>>(
  AppUsageNotifier.new,
);
