import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/lab/lab_catalog.dart';
import '../../data/models/virtual_lab.dart';
import '../../providers/core_providers.dart';
import '../../utils/haptics.dart';
import '../../widgets/pressable.dart';
import 'lab_bench_screen.dart';
import 'lab_kit.dart';
import 'lab_widgets.dart';
import 'rigs/rigs.dart';

// ─── Science Lab hub ──────────────────────────────────────────────────────────
//
// A playground of experiments. Every card plays a live, looping miniature of
// its experiment so students see what they will do before they tap in.

class LabHomeScreen extends ConsumerStatefulWidget {
  const LabHomeScreen({super.key});

  @override
  ConsumerState<LabHomeScreen> createState() => _LabHomeScreenState();
}

class _LabHomeScreenState extends ConsumerState<LabHomeScreen>
    with TickerProviderStateMixin, LabClockMixin {
  List<LabAttempt> _history = const [];

  @override
  void initState() {
    super.initState();
    _history = ref.read(userPrefsRepositoryProvider).getLabAttempts();
    ref.listenManual(userPrefsRepositoryProvider, (previous, next) {
      setState(() => _history = next.getLabAttempts());
    });
  }

  Future<void> _open(LabExperiment lab) async {
    Haptics.light(ref);
    await context.push('/labs/${lab.id}');
    if (!mounted) return;
    setState(
      () => _history = ref.read(userPrefsRepositoryProvider).getLabAttempts(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = LabPalette.of(context);
    final earned = labExperiments.fold<int>(
      0,
      (sum, lab) => sum + labStars(_history, lab.id),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Science Lab'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/explore'),
        ),
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
            _Hero(
              clock: clock,
              p: p,
              earned: earned,
              total: labExperiments.length * 3,
            ),
            for (final subject in LabSubject.values) ...[
              const SizedBox(height: 22),
              _SubjectHead(subject: subject, p: p),
              const SizedBox(height: 12),
              _Grid(
                labs: labExperiments
                    .where((lab) => lab.subject == subject)
                    .toList(),
                clock: clock,
                p: p,
                history: _history,
                onTap: _open,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Hero ─────────────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  final ValueNotifier<double> clock;
  final LabPalette p;
  final int earned;
  final int total;

  const _Hero({
    required this.clock,
    required this.p,
    required this.earned,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final bg = p.dark ? AppColors.heroDark : AppColors.hero;
    final bg2 = p.dark ? AppColors.hero2Dark : AppColors.hero2;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius + 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [bg2, bg],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: LabBubblesPainter(
                  clock: clock,
                  colors: [p.green, p.gold, p.sky, p.pink, p.violet],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.cardPad,
                AppSpacing.cardPad,
                110,
                AppSpacing.cardPad,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.science_rounded,
                      color: AppColors.heroInk,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Play. Predict. Discover.',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.heroInk,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _HeroPill(
                        icon: Icons.star_rounded,
                        color: p.gold,
                        text: '$earned / $total',
                      ),
                      _HeroPill(
                        icon: Icons.biotech_rounded,
                        color: p.green,
                        text: '${labExperiments.length}',
                      ),
                    ],
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

class _HeroPill extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _HeroPill({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.heroInk,
            fontWeight: AppFontWeight.bold,
            fontSize: AppFontSize.body,
          ),
        ),
      ],
    ),
  );
}

// ─── Subjects ─────────────────────────────────────────────────────────────────

class _SubjectHead extends StatelessWidget {
  final LabSubject subject;
  final LabPalette p;

  const _SubjectHead({required this.subject, required this.p});

  @override
  Widget build(BuildContext context) {
    final physics = subject == LabSubject.physics;
    return Row(
      children: [
        LabBadge(
          icon: physics ? Icons.bolt_rounded : Icons.science_rounded,
          color: p.subject(subject),
          size: 30,
        ),
        const SizedBox(width: 10),
        Text(
          physics ? 'Physics' : 'Chemistry',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }
}

class _Grid extends StatelessWidget {
  final List<LabExperiment> labs;
  final ValueNotifier<double> clock;
  final LabPalette p;
  final List<LabAttempt> history;
  final ValueChanged<LabExperiment> onTap;

  const _Grid({
    required this.labs,
    required this.clock,
    required this.p,
    required this.history,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < labs.length; i += 2) {
      rows.add(
        Padding(
          padding: EdgeInsets.only(top: i == 0 ? 0 : 12),
          child: Row(
            children: [
              for (var j = i; j < i + 2; j++) ...[
                if (j > i) const SizedBox(width: 12),
                Expanded(
                  child: j < labs.length
                      ? _ExperimentCard(
                          lab: labs[j],
                          clock: clock,
                          p: p,
                          stars: labStars(history, labs[j].id),
                          offset: j * 1.3,
                          onTap: () => onTap(labs[j]),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}

class _ExperimentCard extends StatelessWidget {
  final LabExperiment lab;
  final ValueNotifier<double> clock;
  final LabPalette p;
  final int stars;
  final double offset;
  final VoidCallback onTap;

  const _ExperimentCard({
    required this.lab,
    required this.clock,
    required this.p,
    required this.stars,
    required this.offset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = p.accent(lab.id);
    final rig = labRigs[lab.id]!;
    return Semantics(
      button: true,
      label: '${lab.title}, $stars of 3 stars',
      child: Pressable(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: accent.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: p.dark ? 0.12 : 0.16),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1.15,
                child: ExcludeSemantics(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomPaint(
                        painter: LabBenchPainter(accent: accent, p: p),
                      ),
                      CustomPaint(
                        painter: LabPreviewPainter(
                          rig: rig,
                          clock: clock,
                          p: p,
                          offset: offset,
                        ),
                      ),
                      Positioned(
                        left: 10,
                        top: 10,
                        child: LabBadge(
                          icon: rig.icon,
                          color: accent,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lab.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: AppFontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LabStars(earned: stars, color: p.gold, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
