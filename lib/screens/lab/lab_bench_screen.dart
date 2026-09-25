import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/lab/lab_catalog.dart';
import '../../data/lab/lab_rules.dart';
import '../../data/lab/lab_words.dart';
import '../../data/models/virtual_lab.dart';
import '../../providers/core_providers.dart';
import '../../providers/regional_language_provider.dart';
import '../../utils/haptics.dart';
import '../../widgets/pressable.dart';
import '../../widgets/regional_language_switch.dart';
import 'lab_kit.dart';
import 'lab_widgets.dart';
import 'rigs/rigs.dart';

// ─── Lab bench ────────────────────────────────────────────────────────────────
//
// One experiment, played in three moves: set up the apparatus with picture
// tokens, pick a prediction, press run. The stage plays the experiment and the
// result lands under it. Every attempt is saved on the device.

class LabBenchScreen extends ConsumerStatefulWidget {
  final String labId;

  const LabBenchScreen({super.key, required this.labId});

  @override
  ConsumerState<LabBenchScreen> createState() => _LabBenchScreenState();
}

class _LabBenchScreenState extends ConsumerState<LabBenchScreen>
    with TickerProviderStateMixin, LabClockMixin {
  late final LabRig _rig = labRigs[widget.labId]!;
  late final LabExperiment _lab = _rig.lab;

  late Map<String, Object> _controls = Map.of(_lab.defaultControls);
  late Map<String, Object> _previous = _controls;
  double _changedAt = -99;

  String? _prediction;
  LabObservation? _result;
  LabAttempt? _attempt;
  double? _runStartedAt;
  bool _revealed = false;
  double? _confettiAt;
  bool _whyOpen = false;
  int _nudge = 0;
  int _runToken = 0;
  Timer? _revealTimer;

  List<LabAttempt> _history = const [];
  late String _sessionId = newLabSessionId();

  bool get _running => _result != null && !_revealed;

  @override
  void initState() {
    super.initState();
    _history = ref.read(userPrefsRepositoryProvider).getLabAttempts();
    ref.listenManual(userPrefsRepositoryProvider, (previous, next) {
      setState(() {
        _clearRun();
        _prediction = null;
        _sessionId = newLabSessionId();
        _history = next.getLabAttempts();
      });
    });
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    super.dispose();
  }

  void _clearRun() {
    _revealTimer?.cancel();
    _runToken++;
    _result = null;
    _attempt = null;
    _runStartedAt = null;
    _revealed = false;
    _confettiAt = null;
    _whyOpen = false;
  }

  // ─── Moves ─────────────────────────────────────────────────────────────

  void _setControls(Map<String, Object> next) {
    if (_running) return;
    Haptics.selection(ref);
    setState(() {
      final hadResult = _result != null;
      _previous = _controls;
      _controls = next;
      _changedAt = clock.value;
      _clearRun();
      if (hadResult) _prediction = null;
    });
  }

  void _predict(String outcome) {
    if (_running) return;
    Haptics.selection(ref);
    setState(() {
      if (_result != null) _clearRun();
      _prediction = outcome;
    });
  }

  void _run() {
    final prediction = _prediction;
    if (_running) return;
    if (prediction == null) {
      Haptics.error(ref);
      setState(() => _nudge++);
      return;
    }
    Haptics.light(ref);
    final attempt = LabAttempt.create(
      labId: _lab.id,
      prediction: prediction,
      controls: Map.of(_controls),
      clientSessionId: _sessionId,
    );
    final token = ++_runToken;
    setState(() {
      _attempt = attempt;
      _result = evaluateLab(_lab.id, attempt.controls);
      _runStartedAt = clock.value;
      _revealed = false;
      _whyOpen = false;
    });
    _save(attempt);
    if (still) {
      _reveal(attempt);
      return;
    }
    _revealTimer?.cancel();
    _revealTimer = Timer(
      Duration(milliseconds: (_rig.runSeconds * 1000).round()),
      () {
        if (mounted && token == _runToken) _reveal(attempt);
      },
    );
  }

  void _reveal(LabAttempt attempt) {
    attempt.correct ? Haptics.medium(ref) : Haptics.light(ref);
    setState(() {
      _revealed = true;
      _confettiAt = attempt.correct && !still ? clock.value : null;
    });
  }

  Future<void> _save(LabAttempt attempt) async {
    final repository = ref.read(userPrefsRepositoryProvider);
    try {
      await repository.saveLabAttempt(attempt);
      if (!mounted || ref.read(userPrefsRepositoryProvider) != repository) {
        return;
      }
      setState(() => _history = repository.getLabAttempts());
    } catch (_) {
      if (mounted && ref.read(userPrefsRepositoryProvider) == repository) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save this attempt. Please try again.'),
          ),
        );
      }
    }
  }

  void _again() {
    Haptics.light(ref);
    setState(() {
      _clearRun();
      _prediction = null;
    });
  }

  void _next() {
    final i = labExperiments.indexWhere((lab) => lab.id == _lab.id);
    final next = labExperiments[(i + 1) % labExperiments.length];
    context.pushReplacement('/labs/${next.id}');
  }

  // ─── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final p = LabPalette.of(context);
    final accent = p.accent(_lab.id);
    final lang = ref.watch(regionalLanguageProvider);
    final stars = labStars(_history, _lab.id);
    final screenH = MediaQuery.sizeOf(context).height;
    final stageH = (screenH * 0.42).clamp(260.0, 420.0);

    return Scaffold(
      appBar: AppBar(
        title: Text(_lab.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/labs'),
        ),
        actions: const [RegionalLanguageSwitch()],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            4,
            AppSpacing.screenPadding,
            32,
          ),
          children: [
            _QuestionBar(
              icon: _rig.icon,
              accent: accent,
              question: _lab.question.of(lang),
              stars: stars,
              starColor: p.gold,
            ),
            const SizedBox(height: 12),
            _stage(p, accent, stageH),
            _grow(
              _revealed && _attempt != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: _resultCard(p, accent, lang),
                    )
                  : const SizedBox(width: double.infinity),
            ),
            const SizedBox(height: 14),
            IgnorePointer(
              ignoring: _running,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _running ? 0.5 : 1,
                child: Column(
                  children: [
                    for (final control in _rig.controls)
                      _controlStrip(control, p, accent, lang),
                    if (!_revealed) _predictionStrip(p, accent, lang),
                  ],
                ),
              ),
            ),
            if (!_revealed) ...[
              const SizedBox(height: 10),
              _RunButton(
                clock: clock,
                accent: accent,
                ready: _prediction != null,
                runStartedAt: _runStartedAt,
                runSeconds: _rig.runSeconds,
                still: still,
                onTap: _run,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Grows open smoothly, or snaps when motion is reduced.
  Widget _grow(Widget child) => still
      ? child
      : AnimatedSize(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: child,
        );

  Widget _stage(LabPalette p, Color accent, double height) {
    final scene = LabScene(
      controls: _controls,
      previous: _previous,
      sinceChange: 99,
      result: _revealed ? _result : null,
      t: 0,
      runT: 0,
      p: p,
    );
    return Semantics(
      label: _rig.describe(scene),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: accent.withValues(alpha: 0.35)),
          ),
          child: LayoutBuilder(
            builder: (context, box) {
              final size = box.biggest;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (details) {
                  final next = _rig.onStageTap(
                    details.localPosition,
                    size,
                    _controls,
                  );
                  if (next != null) _setControls(next);
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(
                      painter: LabBenchPainter(accent: accent, p: p),
                    ),
                    CustomPaint(
                      painter: LabStagePainter(
                        rig: _rig,
                        clock: clock,
                        controls: _controls,
                        previous: _previous,
                        changedAt: _changedAt,
                        runStartedAt: _runStartedAt,
                        result: _result,
                        p: p,
                        still: still,
                      ),
                    ),
                    if (_confettiAt != null)
                      IgnorePointer(
                        child: CustomPaint(
                          painter: LabConfettiPainter(
                            clock: clock,
                            startedAt: _confettiAt!,
                            colors: [
                              p.gold,
                              p.coral,
                              p.green,
                              p.sky,
                              p.violet,
                              p.pink,
                            ],
                          ),
                        ),
                      ),
                    if (_revealed && _attempt != null)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: _VerdictBadge(
                          correct: _attempt!.correct,
                          p: p,
                          still: still,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _controlStrip(
    LabControl control,
    LabPalette p,
    Color accent,
    RegionalLanguage lang,
  ) {
    final values = _lab.controls[control.key]!;
    return LabStrip(
      icon: control.icon,
      accent: accent,
      semanticsLabel: control.key.replaceAll('_', ' '),
      tokens: [
        for (final value in values)
          LabToken(
            glyph: (canvas, size) => control.glyph(canvas, size, value, p),
            signature: '${control.key}:$value:${p.dark}',
            caption: control.caption(value, lang),
            selected: _controls[control.key] == value,
            accent: accent,
            onTap: () => _setControls({..._controls, control.key: value}),
          ),
      ],
    );
  }

  Widget _predictionStrip(LabPalette p, Color accent, RegionalLanguage lang) {
    final strip = LabStrip(
      icon: Icons.psychology_alt_rounded,
      accent: p.violet,
      semanticsLabel: 'Your prediction',
      tokens: [
        for (final outcome in _lab.outcomes)
          LabToken(
            glyph: (canvas, size) =>
                _rig.paintOutcome(canvas, size, outcome, _controls, p),
            signature: '$outcome:${_controls.toString()}:${p.dark}',
            caption: labWord(outcome, lang),
            selected: _prediction == outcome,
            dimmed: _prediction != null && _prediction != outcome,
            accent: p.violet,
            size: 68,
            onTap: () => _predict(outcome),
          ),
      ],
    );
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.fromLTRB(8, 2, 0, 2),
      decoration: BoxDecoration(
        color: p.violet.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: p.violet.withValues(alpha: 0.22)),
      ),
      child: TweenAnimationBuilder<double>(
        key: ValueKey(_nudge),
        tween: Tween(begin: _nudge == 0 ? 1 : 0, end: 1),
        duration: const Duration(milliseconds: 500),
        builder: (context, k, child) => Transform.translate(
          offset: Offset(math.sin(k * math.pi * 6) * 8 * (1 - k), 0),
          child: child,
        ),
        child: strip,
      ),
    );
  }

  Widget _resultCard(LabPalette p, Color accent, RegionalLanguage lang) {
    final attempt = _attempt!;
    final result = _result!;
    final cs = Theme.of(context).colorScheme;
    final verdictColor = attempt.correct ? p.green : p.amber;
    Widget glyph(String outcome, Color ring) => Container(
      width: 54,
      height: 54,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ring, width: 2),
      ),
      child: CustomPaint(
        painter: LabGlyphPainter(
          (canvas, size) =>
              _rig.paintOutcome(canvas, size, outcome, attempt.controls, p),
          '$outcome:${p.dark}',
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          verdictColor.withValues(alpha: 0.08),
          cs.surface,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: verdictColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              glyph(attempt.prediction, p.violet),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  attempt.correct
                      ? Icons.drag_handle_rounded
                      : Icons.arrow_forward_rounded,
                  color: verdictColor,
                ),
              ),
              glyph(result.outcome, verdictColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  attempt.correct ? 'Spot on!' : 'Surprise!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: verdictColor,
                    fontWeight: AppFontWeight.extraBold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final stat in _rig.stats(result, lang))
                _StatChip(stat: stat, color: accent),
            ],
          ),
          const SizedBox(height: 6),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _whyOpen = !_whyOpen),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  LabBadge(
                    icon: Icons.lightbulb_rounded,
                    color: p.gold,
                    size: 26,
                  ),
                  const SizedBox(width: 8),
                  Text('Why?', style: Theme.of(context).textTheme.titleSmall),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _whyOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_whyOpen)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                result.explanation.of(lang),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(height: 1.45),
              ),
            ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _again,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Again'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _next,
                  style: FilledButton.styleFrom(backgroundColor: accent),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Next'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Stars earned in a lab: one per correct prediction, up to three.
int labStars(List<LabAttempt> history, String labId) =>
    math.min(3, history.where((a) => a.labId == labId && a.correct).length);

// ─── Pieces ───────────────────────────────────────────────────────────────────

class _QuestionBar extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String question;
  final int stars;
  final Color starColor;

  const _QuestionBar({
    required this.icon,
    required this.accent,
    required this.question,
    required this.stars,
    required this.starColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        LabBadge(icon: icon, color: accent, size: 40),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            question,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: AppFontWeight.bold,
              height: 1.25,
            ),
          ),
        ),
        const SizedBox(width: 8),
        LabStars(earned: stars, color: starColor, size: 18),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final LabStat stat;
  final Color color;

  const _StatChip({required this.stat, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(stat.icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          stat.value,
          style: TextStyle(
            fontWeight: AppFontWeight.bold,
            fontSize: AppFontSize.body,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    ),
  );
}

class _VerdictBadge extends StatelessWidget {
  final bool correct;
  final LabPalette p;
  final bool still;

  const _VerdictBadge({
    required this.correct,
    required this.p,
    required this.still,
  });

  @override
  Widget build(BuildContext context) {
    final color = correct ? p.green : p.amber;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: still ? 1 : 0, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.elasticOut,
      builder: (context, k, child) => Transform.scale(scale: k, child: child),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.45),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          correct ? Icons.check_rounded : Icons.auto_awesome_rounded,
          color: Colors.white,
          size: 30,
          semanticLabel: correct ? 'Prediction correct' : 'Prediction missed',
        ),
      ),
    );
  }
}

class _RunButton extends StatelessWidget {
  final ValueNotifier<double> clock;
  final Color accent;
  final bool ready;
  final double? runStartedAt;
  final double runSeconds;
  final bool still;
  final VoidCallback onTap;

  const _RunButton({
    required this.clock,
    required this.accent,
    required this.ready,
    required this.runStartedAt,
    required this.runSeconds,
    required this.still,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final running = runStartedAt != null;
    return Center(
      child: Semantics(
        button: true,
        enabled: ready && !running,
        label: running ? 'Experiment running' : 'Run the experiment',
        child: Pressable(
          onTap: running ? null : onTap,
          scale: 0.92,
          child: SizedBox(
            width: 104,
            height: 104,
            child: ValueListenableBuilder<double>(
              valueListenable: clock,
              builder: (context, t, _) {
                final pulse = ready && !running && !still ? (t * 0.9) % 1 : 0.0;
                final progress = running
                    ? ((t - runStartedAt!) / runSeconds).clamp(0.0, 1.0)
                    : 0.0;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    if (pulse > 0)
                      Container(
                        width: 78 + 26 * pulse,
                        height: 78 + 26 * pulse,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: accent.withValues(alpha: 0.5 * (1 - pulse)),
                            width: 3,
                          ),
                        ),
                      ),
                    if (running)
                      SizedBox(
                        width: 90,
                        height: 90,
                        child: CircularProgressIndicator(
                          value: still ? null : progress,
                          strokeWidth: 4,
                          color: accent,
                          backgroundColor: accent.withValues(alpha: 0.15),
                        ),
                      ),
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: ready || running
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color.lerp(accent, Colors.white, 0.25)!,
                                  accent,
                                ],
                              )
                            : null,
                        color: ready || running
                            ? null
                            : cs.surfaceContainerHighest,
                        boxShadow: ready
                            ? [
                                BoxShadow(
                                  color: accent.withValues(alpha: 0.4),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        running
                            ? Icons.visibility_rounded
                            : Icons.play_arrow_rounded,
                        size: 42,
                        color: ready || running
                            ? Colors.white
                            : cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
