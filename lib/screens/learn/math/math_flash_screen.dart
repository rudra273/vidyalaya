import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../data/math/math_generators.dart';
import '../../../data/math/math_models.dart';
import '../../../providers/math_progress_provider.dart';
import '../../../utils/haptics.dart';
import '../../../widgets/calm_widgets.dart';
import '../../../widgets/pressable.dart';
import 'math_home_screen.dart';
import 'widgets/countdown_ring.dart';
import 'widgets/flash_custom_sheet.dart';
import 'widgets/math_numpad.dart';

// ─── Flash Math ───────────────────────────────────────────────────────────────
//
// A chain of operations flashes one step at a time; the student holds the running
// total in their head and types it at the end. Optional checkpoints ask for the
// running total mid-chain.
//
// This is the first repeating-timer screen in the app. The rules it establishes:
// keep the Timer in a field, cancel it in dispose() *and* before every phase
// change, and guard async callbacks with `if (!mounted) return;`.

enum _Phase { setup, flashing, answering, result }

class MathFlashScreen extends ConsumerStatefulWidget {
  const MathFlashScreen({super.key});

  @override
  ConsumerState<MathFlashScreen> createState() => _MathFlashScreenState();
}

class _MathFlashScreenState extends ConsumerState<MathFlashScreen> {
  /// The hub's row reads this id, so the headline best is the Medium score.
  static const _toolId = 'math-flash';

  /// Bests are kept per difficulty — a Hard round with checkpoints asks more
  /// questions than an Easy one, so a single shared best would compare rounds
  /// that aren't comparable. Custom rounds key on their actual settings for the
  /// same reason: 3 steps and 12 steps aren't the same achievement.
  String get _scoreKey {
    if (_preset.id == flashCustomId) {
      final ops = _preset.allowedOps.map((o) => o.name).join('');
      return '$_toolId-custom-${_preset.steps}-'
          '${_preset.secondsPerStep}-$ops';
    }
    return _preset.id == 'medium' ? _toolId : '$_toolId-${_preset.id}';
  }

  _Phase _phase = _Phase.setup;
  MathFlashPreset _preset = mathFlashPresets[1];
  bool _checkpoints = false;

  MathFlashChain? _chain;
  Timer? _timer;

  /// -1 means "showing the starting value"; 0..steps-1 index into chain.steps.
  int _cursor = -1;

  /// Which step index the current answer prompt refers to. The final prompt uses
  /// the last step index.
  int _promptForStep = 0;

  /// Checkpoints already answered, so resuming the chain doesn't re-ask the one
  /// we just paused on.
  final Set<int> _answeredCheckpoints = {};

  final _entry = NumpadValue();
  int _correctPrompts = 0;
  int _totalPrompts = 0;
  final List<String> _mistakes = [];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ─── Round lifecycle ──────────────────────────────────────────────────────

  void _startRound() {
    final chain = buildFlashChain(_preset, withCheckpoints: _checkpoints);
    setState(() {
      _chain = chain;
      _cursor = -1;
      _correctPrompts = 0;
      _totalPrompts = 0;
      _mistakes.clear();
      _answeredCheckpoints.clear();
      _entry.clear();
      _phase = _Phase.flashing;
    });
    _scheduleNextFlash();
  }

  /// Shows the current value for one step duration, then advances. Each tick
  /// either reveals the next step, pauses at a checkpoint, or hands over to the
  /// final answer prompt.
  void _scheduleNextFlash() {
    _timer?.cancel();
    _timer = Timer(_preset.stepDuration, () {
      if (!mounted) return;
      final chain = _chain;
      if (chain == null) return;

      // The step just displayed was a checkpoint — pause and ask for the total.
      if (_cursor >= 0 &&
          chain.isCheckpoint(_cursor) &&
          !_answeredCheckpoints.contains(_cursor)) {
        _askFor(_cursor);
        return;
      }

      final next = _cursor + 1;

      // Reached the end of the chain — ask for the final answer.
      if (next >= chain.steps.length) {
        _askFor(chain.steps.length - 1);
        return;
      }

      setState(() => _cursor = next);
      _scheduleNextFlash();
    });
  }

  void _askFor(int stepIndex) {
    _timer?.cancel();
    setState(() {
      _promptForStep = stepIndex;
      _entry.clear();
      _phase = _Phase.answering;
    });
  }

  void _submitAnswer() {
    final chain = _chain;
    final typed = _entry.intValue;
    if (chain == null || typed == null) return;

    final expected = chain.steps[_promptForStep].runningValue;
    final right = typed == expected;
    right ? Haptics.medium(ref) : Haptics.error(ref);

    _totalPrompts++;
    if (right) {
      _correctPrompts++;
    } else {
      final label = _promptForStep == chain.steps.length - 1
          ? 'Final answer'
          : 'After step ${_promptForStep + 1}';
      _mistakes.add('$label: you said $typed, it was $expected');
    }

    final isFinalPrompt = _promptForStep == chain.steps.length - 1;
    if (isFinalPrompt) {
      _finishRound();
    } else {
      // A checkpoint was answered — resume flashing from where we paused.
      _answeredCheckpoints.add(_promptForStep);
      setState(() {
        _entry.clear();
        _phase = _Phase.flashing;
      });
      _scheduleNextFlash();
    }
  }

  void _finishRound() {
    _timer?.cancel();
    ref
        .read(mathProgressProvider.notifier)
        .recordScore(_scoreKey, _correctPrompts);
    setState(() => _phase = _Phase.result);
  }

  void _backToSetup() {
    _timer?.cancel();
    setState(() {
      _phase = _Phase.setup;
      _chain = null;
      _cursor = -1;
      _entry.clear();
    });
  }

  /// True when a round is in flight, so the back button should bail out of the
  /// round rather than leaving the screen.
  bool get _roundInProgress =>
      _phase == _Phase.flashing || _phase == _Phase.answering;

  @override
  Widget build(BuildContext context) {
    final accent = MathHomeScreen.accentOf(context);

    return BackButtonListener(
      onBackButtonPressed: () async {
        if (_roundInProgress) {
          _backToSetup();
          return true; // handled — stay on the screen
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Flash Math'),
          leading: _roundInProgress
              ? IconButton(
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'End round',
                  onPressed: _backToSetup,
                )
              : null,
        ),
        body: switch (_phase) {
          _Phase.setup => _SetupView(
              preset: _preset,
              checkpoints: _checkpoints,
              accent: accent,
              best: ref.watch(mathProgressProvider).bestFor(_scoreKey),
              onPreset: (p) => setState(() => _preset = p),
              onCheckpoints: (v) => setState(() => _checkpoints = v),
              onStart: _startRound,
            ),
          _Phase.flashing => _FlashView(
              chain: _chain!,
              cursor: _cursor,
              accent: accent,
              stepDuration: _preset.stepDuration,
            ),
          _Phase.answering => _AnswerView(
              chain: _chain!,
              promptForStep: _promptForStep,
              entry: _entry,
              accent: accent,
              onChanged: () => setState(() {}),
              onSubmit: _entry.isEmpty ? null : _submitAnswer,
            ),
          _Phase.result => _ResultView(
              correct: _correctPrompts,
              total: _totalPrompts,
              chain: _chain!,
              mistakes: _mistakes,
              accent: accent,
              onAgain: _startRound,
              onChange: _backToSetup,
            ),
        },
      ),
    );
  }
}

// ─── Setup ────────────────────────────────────────────────────────────────────

class _SetupView extends StatelessWidget {
  final MathFlashPreset preset;
  final bool checkpoints;
  final Color accent;
  final int? best;
  final ValueChanged<MathFlashPreset> onPreset;
  final ValueChanged<bool> onCheckpoints;
  final VoidCallback onStart;

  const _SetupView({
    required this.preset,
    required this.checkpoints,
    required this.accent,
    required this.best,
    required this.onPreset,
    required this.onCheckpoints,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              Icon(Icons.bolt_rounded, color: accent, size: 30),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  best == null
                      ? 'Each step shows for a moment, then disappears. Add it up as you go.'
                      : 'Your best on ${preset.label}: $best correct.',
                  style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(
              AppSpacing.screenPadding, 24, AppSpacing.screenPadding, 4),
          child: SectionHead(label: 'Difficulty'),
        ),
        for (final p in mathFlashPresets)
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding, 5, AppSpacing.screenPadding, 5),
            child: _PresetRow(
              preset: p,
              selected: p.id == preset.id,
              accent: accent,
              onTap: () => onPreset(p),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding, 5, AppSpacing.screenPadding, 5),
          child: _CustomRow(
            preset: preset,
            selected: preset.id == flashCustomId,
            accent: accent,
            onPicked: onPreset,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding, 18, AppSpacing.screenPadding, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? cs.surface : Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: accent,
              value: checkpoints,
              onChanged: onCheckpoints,
              title: const Text(
                'Checkpoints',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                'Also ask for the total part-way through',
                style: TextStyle(color: AppColors.textMuted),
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
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text(
                'Start round',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PresetRow extends ConsumerWidget {
  final MathFlashPreset preset;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  const _PresetRow({
    required this.preset,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Pressable(
      onTap: () {
        Haptics.selection(ref);
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: 0.12)
              : (isDark ? cs.surface : Colors.white),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
            color: selected ? accent : cs.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? accent : cs.outlineVariant,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    preset.label,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    preset.blurb,
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opens the custom settings sheet. Shows the chosen settings once configured,
/// so it reads as a fourth difficulty option rather than a hidden menu.
class _CustomRow extends ConsumerWidget {
  final MathFlashPreset preset;
  final bool selected;
  final Color accent;
  final ValueChanged<MathFlashPreset> onPicked;

  const _CustomRow({
    required this.preset,
    required this.selected,
    required this.accent,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Pressable(
      onTap: () async {
        Haptics.light(ref);
        final result = await showFlashCustomSheet(
          context,
          // Seed the sheet from the current settings so tweaking is iterative.
          initial: preset,
          accent: accent,
        );
        if (result != null) onPicked(result);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: 0.12)
              : (isDark ? cs.surface : Colors.white),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
            color: selected ? accent : cs.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.tune_rounded,
              color: selected ? accent : cs.outlineVariant,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Custom',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    selected
                        ? preset.blurb
                        : 'Choose the speed, count and operations',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

// ─── Flashing ─────────────────────────────────────────────────────────────────

class _FlashView extends StatelessWidget {
  final MathFlashChain chain;
  final int cursor;
  final Color accent;

  /// How long the current value stays on screen — drives the countdown ring.
  final Duration stepDuration;

  const _FlashView({
    required this.chain,
    required this.cursor,
    required this.accent,
    required this.stepDuration,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final showingStart = cursor < 0;
    final text = showingStart
        ? '${chain.start}'
        : chain.steps[cursor].display;
    final stepLabel = showingStart
        ? 'Start'
        : 'Step ${cursor + 1} of ${chain.steps.length}';
    final progress =
        showingStart ? 0.0 : (cursor + 1) / chain.steps.length;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: cs.outlineVariant,
              valueColor: AlwaysStoppedAnimation(accent),
              borderRadius: BorderRadius.circular(999),
            ),
            const SizedBox(height: 14),
            Text(
              stepLabel,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textMuted,
                    letterSpacing: 0.5,
                  ),
            ),
            Expanded(
              child: Center(
                // The ValueKey remounts both the ring and the pop-in scale on
                // every step, so the countdown always restarts from full.
                child: CountdownRing(
                  key: ValueKey(cursor),
                  duration: stepDuration,
                  accent: accent,
                  track: cs.outlineVariant,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.6, end: 1),
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutBack,
                    builder: (context, v, child) =>
                        Transform.scale(scale: v, child: child),
                    child: Text(
                      text,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 72,
                            fontWeight: FontWeight.w800,
                            color: showingStart ? cs.onSurface : accent,
                          ),
                    ),
                  ),
                ),
              ),
            ),
            Text(
              'Keep the running total in your head',
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─── Answering ────────────────────────────────────────────────────────────────

class _AnswerView extends StatelessWidget {
  final MathFlashChain chain;
  final int promptForStep;
  final NumpadValue entry;
  final Color accent;
  final VoidCallback onChanged;
  final VoidCallback? onSubmit;

  const _AnswerView({
    required this.chain,
    required this.promptForStep,
    required this.entry,
    required this.accent,
    required this.onChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final isFinal = promptForStep == chain.steps.length - 1;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            Text(
              isFinal ? 'What\'s the answer?' : 'Checkpoint',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              isFinal
                  ? 'The total after all ${chain.steps.length} steps'
                  : 'The total after step ${promptForStep + 1}',
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 18),
            MathAnswerDisplay(value: entry.text, accent: accent),
            const SizedBox(height: 18),
            MathNumpad(
              accent: accent,
              submitLabel: isFinal ? 'Check answer' : 'Continue',
              onDigit: (d) {
                entry.addDigit(d);
                onChanged();
              },
              onBackspace: () {
                entry.backspace();
                onChanged();
              },
              onToggleSign: () {
                entry.toggleSign();
                onChanged();
              },
              onSubmit: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Result ───────────────────────────────────────────────────────────────────

class _ResultView extends StatelessWidget {
  final int correct;
  final int total;
  final MathFlashChain chain;
  final List<String> mistakes;
  final Color accent;
  final VoidCallback onAgain;
  final VoidCallback onChange;

  const _ResultView({
    required this.correct,
    required this.total,
    required this.chain,
    required this.mistakes,
    required this.accent,
    required this.onAgain,
    required this.onChange,
  });

  bool get _perfect => total > 0 && correct == total;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        const SizedBox(height: 12),
        Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 420),
            curve: Curves.elasticOut,
            builder: (context, v, child) =>
                Transform.scale(scale: 0.7 + v * 0.3, child: child),
            child: Icon(
              _perfect
                  ? Icons.emoji_events_rounded
                  : correct > 0
                      ? Icons.celebration_rounded
                      : Icons.fitness_center_rounded,
              size: 64,
              color: accent,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            '$correct / $total correct',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            _perfect
                ? 'Perfect — try a harder level!'
                : 'Keep practising, you\'ll get faster.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
        const SizedBox(height: 22),

        // The chain recap, so a wrong answer is a teaching moment.
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? cs.surface : Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The chain',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              _RecapRow(label: 'Start', value: '${chain.start}', accent: accent),
              for (var i = 0; i < chain.steps.length; i++)
                _RecapRow(
                  label: chain.steps[i].display,
                  value: '${chain.steps[i].runningValue}',
                  accent: accent,
                  isCheckpoint: chain.isCheckpoint(i),
                ),
            ],
          ),
        ),

        if (mistakes.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Where it slipped',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                for (final m in mistakes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(m, style: const TextStyle(height: 1.4)),
                  ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            onPressed: onAgain,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Play again'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onChange,
            child: const Text('Change difficulty'),
          ),
        ),
      ],
    );
  }
}

class _RecapRow extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  final bool isCheckpoint;

  const _RecapRow({
    required this.label,
    required this.value,
    required this.accent,
    this.isCheckpoint = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              '→ $value',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          if (isCheckpoint)
            Icon(Icons.flag_rounded, size: 15, color: accent),
        ],
      ),
    );
  }
}
