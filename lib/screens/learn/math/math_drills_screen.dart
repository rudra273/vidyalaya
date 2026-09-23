import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../data/math/math_generators.dart';
import '../../../data/math/math_models.dart';
import '../../../providers/math_progress_provider.dart';
import '../../../utils/haptics.dart';
import '../../../widgets/calm_widgets.dart';
import '../../../widgets/pressable.dart';
import 'math_home_screen.dart';
import 'widgets/math_numpad.dart';

// ─── Speed Drills ─────────────────────────────────────────────────────────────
//
// A 60-second sprint: answer as many single-operation facts as possible. Score is
// the number answered correctly. Wrong answers move on rather than blocking, so
// the clock always keeps running.

const _roundSeconds = 60;

/// Selectable operator sets. Keeping this small means one tap to start.
const _opSets = <_OpSet>[
  _OpSet('Add & subtract', [MathOp.add, MathOp.sub]),
  _OpSet('Times tables', [MathOp.mul]),
  _OpSet('Multiply & divide', [MathOp.mul, MathOp.div]),
  _OpSet('Everything', [MathOp.add, MathOp.sub, MathOp.mul, MathOp.div]),
];

class _OpSet {
  final String label;
  final List<MathOp> ops;
  const _OpSet(this.label, this.ops);

  String get symbols => ops.map((o) => o.symbol).join('  ');
}

class MathDrillsScreen extends ConsumerStatefulWidget {
  const MathDrillsScreen({super.key});

  @override
  ConsumerState<MathDrillsScreen> createState() => _MathDrillsScreenState();
}

class _MathDrillsScreenState extends ConsumerState<MathDrillsScreen> {
  static const _toolId = 'math-drills';

  bool _running = false;
  bool _finished = false;
  _OpSet _opSet = _opSets.first;

  List<MathFact> _facts = const [];
  int _index = 0;
  int _correct = 0;
  int _attempts = 0;
  int _secondsLeft = _roundSeconds;
  Timer? _ticker;

  final _entry = NumpadValue();

  /// Brief green/red flash after each answer, cleared by a short timer.
  bool? _lastWasRight;
  Timer? _flashTimer;

  @override
  void dispose() {
    _ticker?.cancel();
    _flashTimer?.cancel();
    super.dispose();
  }

  void _start() {
    _ticker?.cancel();
    setState(() {
      _facts = buildDrillFacts(ops: _opSet.ops, count: 200);
      _index = 0;
      _correct = 0;
      _attempts = 0;
      _secondsLeft = _roundSeconds;
      _entry.clear();
      _lastWasRight = null;
      _running = true;
      _finished = false;
    });

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        _finish();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _finish() {
    _ticker?.cancel();
    _flashTimer?.cancel();
    ref.read(mathProgressProvider.notifier).recordScore(_toolId, _correct);
    setState(() {
      _running = false;
      _finished = true;
      _secondsLeft = 0;
    });
  }

  void _submit() {
    if (!_running) return;
    final typed = _entry.intValue;
    if (typed == null) return;

    final right = typed == _facts[_index].answer;
    right ? Haptics.medium(ref) : Haptics.error(ref);

    setState(() {
      _attempts++;
      if (right) _correct++;
      _lastWasRight = right;
      _entry.clear();
      // Wrap rather than run dry if the student is very fast.
      _index = (_index + 1) % _facts.length;
    });

    _flashTimer?.cancel();
    _flashTimer = Timer(const Duration(milliseconds: 320), () {
      if (!mounted) return;
      setState(() => _lastWasRight = null);
    });
  }

  void _reset() {
    _ticker?.cancel();
    _flashTimer?.cancel();
    setState(() {
      _running = false;
      _finished = false;
      _entry.clear();
      _lastWasRight = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = MathHomeScreen.accentOf(context);

    return BackButtonListener(
      onBackButtonPressed: () async {
        if (_running) {
          _reset();
          return true;
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Speed Drills'),
          leading: _running
              ? IconButton(
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'End drill',
                  onPressed: _reset,
                )
              : null,
        ),
        body: _running
            ? _playView(accent)
            : _finished
                ? _resultView(accent)
                : _setupView(accent),
      ),
    );
  }

  // ─── Setup ────────────────────────────────────────────────────────────────

  Widget _setupView(Color accent) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final best = ref.watch(mathProgressProvider).bestFor(_toolId);

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        const SizedBox(height: 14),
        Container(
          margin:
              const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          padding: const EdgeInsets.all(AppSpacing.cardPad),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: accent.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Icon(Icons.timer_outlined, color: accent, size: 30),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  best == null
                      ? 'Answer as many as you can in $_roundSeconds seconds.'
                      : 'Your best: $best correct in $_roundSeconds seconds.',
                  style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(
              AppSpacing.screenPadding, 24, AppSpacing.screenPadding, 4),
          child: SectionHead(label: 'What to practise'),
        ),
        for (final set in _opSets)
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding, 5, AppSpacing.screenPadding, 5),
            child: Pressable(
              onTap: () {
                Haptics.selection(ref);
                setState(() => _opSet = set);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: set.label == _opSet.label
                      ? accent.withValues(alpha: 0.12)
                      : (isDark ? cs.surface : Colors.white),
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  border: Border.all(
                    color: set.label == _opSet.label
                        ? accent
                        : cs.outlineVariant,
                    width: set.label == _opSet.label ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      set.label == _opSet.label
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: set.label == _opSet.label
                          ? accent
                          : cs.outlineVariant,
                      size: 22,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        set.label,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      set.symbols,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding, 26, AppSpacing.screenPadding, 0),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _start,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text(
                'Start drill',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Playing ──────────────────────────────────────────────────────────────

  Widget _playView(Color accent) {
    final cs = Theme.of(context).colorScheme;
    final fact = _facts[_index];
    final urgent = _secondsLeft <= 10;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 18,
                      color: urgent ? const Color(0xFFC0483C) : accent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_secondsLeft}s',
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: urgent
                                    ? const Color(0xFFC0483C)
                                    : cs.onSurface,
                              ),
                    ),
                  ],
                ),
                Text(
                  'Correct $_correct / $_attempts',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: _secondsLeft / _roundSeconds,
              minHeight: 6,
              backgroundColor: cs.outlineVariant,
              valueColor: AlwaysStoppedAnimation(
                urgent ? const Color(0xFFC0483C) : accent,
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            const SizedBox(height: 26),
            Text(
              fact.prompt,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: _lastWasRight == null
                        ? cs.onSurface
                        : (_lastWasRight!
                            ? const Color(0xFF3E8E5A)
                            : const Color(0xFFC0483C)),
                  ),
            ),
            const SizedBox(height: 20),
            MathAnswerDisplay(value: _entry.text, accent: accent),
            const SizedBox(height: 18),
            MathNumpad(
              accent: accent,
              submitLabel: 'Answer',
              onDigit: (d) => setState(() => _entry.addDigit(d)),
              onBackspace: () => setState(() => _entry.backspace()),
              onToggleSign: () => setState(() => _entry.toggleSign()),
              onSubmit: _entry.isEmpty ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Result ───────────────────────────────────────────────────────────────

  Widget _resultView(Color accent) {
    final best = ref.watch(mathProgressProvider).bestFor(_toolId);
    final accuracy =
        _attempts == 0 ? 0 : (_correct / _attempts * 100).round();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flag_circle_rounded, size: 64, color: accent),
            const SizedBox(height: 12),
            Text(
              "Time's up!",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Stat(label: 'Correct', value: '$_correct', accent: accent),
                const SizedBox(width: 12),
                _Stat(label: 'Attempted', value: '$_attempts', accent: accent),
                const SizedBox(width: 12),
                _Stat(label: 'Accuracy', value: '$accuracy%', accent: accent),
              ],
            ),
            if (best != null) ...[
              const SizedBox(height: 16),
              Text(
                _correct >= best
                    ? 'A new personal best!'
                    : 'Your best is $best.',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _start,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Go again'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: accent),
                onPressed: () => context.pop(),
                child: const Text('Back to Math'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _Stat({required this.label, required this.value, required this.accent});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? cs.surface : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
