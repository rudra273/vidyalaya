import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../data/math/math_generators.dart';
import '../../../data/math/math_models.dart';
import '../../../data/math/multiplication_tables_data.dart';
import '../../../providers/math_progress_provider.dart';
import '../../../utils/haptics.dart';
import '../../../widgets/calm_widgets.dart';
import '../../../widgets/pressable.dart';
import 'math_home_screen.dart';
import 'widgets/math_numpad.dart';

// ─── Multiplication Tables ────────────────────────────────────────────────────
//
// Browse tables 1–20 as a chip grid; picking one shows the full table with its
// memory tip, and a Practise button drills that table's facts in random order.

class MathTablesScreen extends ConsumerStatefulWidget {
  const MathTablesScreen({super.key});

  @override
  ConsumerState<MathTablesScreen> createState() => _MathTablesScreenState();
}

class _MathTablesScreenState extends ConsumerState<MathTablesScreen> {
  int _selected = 2;

  @override
  Widget build(BuildContext context) {
    final accent = MathHomeScreen.accentOf(context);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tip = tipForTable(_selected);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Multiplication Tables')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          const SizedBox(height: 14),

          // Table picker
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: allTables.map((t) {
                final on = t == _selected;
                return Pressable(
                  onTap: () {
                    Haptics.selection(ref);
                    setState(() => _selected = t);
                  },
                  child: Container(
                    width: 48,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: on
                          ? accent
                          : (isDark ? cs.surface : Colors.white),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.tileRadius),
                      border: Border.all(
                        color: on ? accent : cs.outlineVariant,
                      ),
                    ),
                    child: Text(
                      '$t',
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: on ? Colors.white : cs.onSurface,
                              ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          if (tip != null) ...[
            const SizedBox(height: 18),
            Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              padding: const EdgeInsets.all(AppSpacing.cardPad),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                border: Border.all(color: accent.withValues(alpha: 0.25)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline_rounded,
                      color: accent, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                          color: cs.onSurfaceVariant, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ],

          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding, 24, AppSpacing.screenPadding, 4),
            child: SectionHead(label: 'The $_selected× table'),
          ),

          // The table itself
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? cs.surface : Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Column(
                children: List.generate(tableUpTo, (i) {
                  final n = i + 1;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 13),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: n == tableUpTo
                              ? Colors.transparent
                              : cs.outlineVariant,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$_selected × $n',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          '${_selected * n}',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: accent,
                              ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding, 22, AppSpacing.screenPadding, 0),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Haptics.light(ref);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => _TablePracticeScreen(table: _selected),
                    ),
                  );
                },
                icon: const Icon(Icons.fitness_center_rounded),
                label: Text(
                  'Practise the $_selected× table',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Practice ─────────────────────────────────────────────────────────────────
//
// All 12 facts of one table, shuffled, answered on the numpad. Pushed as a plain
// MaterialPageRoute (the formulas calculator precedent) since it's a leaf detail
// of the selected table rather than a deep-linkable destination.

class _TablePracticeScreen extends ConsumerStatefulWidget {
  final int table;
  const _TablePracticeScreen({required this.table});

  @override
  ConsumerState<_TablePracticeScreen> createState() =>
      _TablePracticeScreenState();
}

class _TablePracticeScreenState extends ConsumerState<_TablePracticeScreen> {
  static const _toolId = 'math-tables';

  late List<MathFact> _facts;
  int _index = 0;
  int _correct = 0;
  bool _finished = false;
  bool? _lastWasRight;

  final _entry = NumpadValue();

  @override
  void initState() {
    super.initState();
    _facts = buildTableQuestions(widget.table, upTo: tableUpTo);
  }

  void _restart() {
    setState(() {
      _facts = buildTableQuestions(widget.table, upTo: tableUpTo);
      _index = 0;
      _correct = 0;
      _finished = false;
      _lastWasRight = null;
      _entry.clear();
    });
  }

  void _submit() {
    final typed = _entry.intValue;
    if (typed == null) return;

    final right = typed == _facts[_index].answer;
    right ? Haptics.medium(ref) : Haptics.error(ref);

    final isLast = _index == _facts.length - 1;

    setState(() {
      if (right) _correct++;
      _lastWasRight = right;
      _entry.clear();
      if (isLast) {
        _finished = true;
      } else {
        _index++;
      }
    });

    if (isLast) {
      ref.read(mathProgressProvider.notifier).recordScore(_toolId, _correct);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = MathHomeScreen.accentOf(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text('Practise ${widget.table}×')),
      body: _finished
          ? _resultView(accent)
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_index + 1} of ${_facts.length}',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                color: AppColors.textMuted,
                                letterSpacing: 0.5,
                              ),
                        ),
                        Text(
                          'Correct $_correct',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                color: accent,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: (_index + 1) / _facts.length,
                      minHeight: 6,
                      backgroundColor: cs.outlineVariant,
                      valueColor: AlwaysStoppedAnimation(accent),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      _facts[_index].prompt,
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
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
                      submitLabel: 'Check',
                      allowNegative: false,
                      onDigit: (d) => setState(() => _entry.addDigit(d)),
                      onBackspace: () => setState(() => _entry.backspace()),
                      onToggleSign: () {},
                      onSubmit: _entry.isEmpty ? null : _submit,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _resultView(Color accent) {
    final best = ref.watch(mathProgressProvider).bestFor(_toolId);
    final perfect = _correct == _facts.length;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              perfect
                  ? Icons.emoji_events_rounded
                  : Icons.celebration_rounded,
              size: 64,
              color: accent,
            ),
            const SizedBox(height: 12),
            Text(
              '$_correct / ${_facts.length} correct',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              perfect
                  ? 'You know the ${widget.table}× table!'
                  : 'Run it again to lock it in.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
            if (best != null) ...[
              const SizedBox(height: 10),
              Text(
                'Best: $best',
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
                onPressed: _restart,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: accent),
                onPressed: () => context.pop(),
                child: const Text('Back to tables'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
