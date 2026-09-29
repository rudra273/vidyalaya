import 'dart:math';

import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../data/models/localized_text.dart';
import '../../../data/models/regional_language.dart';

// ─── Match-the-pairs board ────────────────────────────────────────────────────
//
// Left items stay in order; right items are shuffled. Tap a left item, then the
// right item it goes with. Once every left item is paired, "Check" reveals each
// pair in green or red and reports whether all of them were right.

class QuizMatchBoard extends StatefulWidget {
  final List<(LocalizedText, LocalizedText)> pairs;
  final RegionalLanguage lang;
  final Color accent;

  /// Called once, when the student checks their pairs.
  final ValueChanged<bool> onChecked;

  const QuizMatchBoard({
    super.key,
    required this.pairs,
    required this.lang,
    required this.accent,
    required this.onChecked,
  });

  @override
  State<QuizMatchBoard> createState() => _QuizMatchBoardState();
}

class _QuizMatchBoardState extends State<QuizMatchBoard> {
  /// Display order of the right column, as indexes into [QuizMatchBoard.pairs].
  late List<int> _rightOrder;

  /// Left index → chosen right index (both into [QuizMatchBoard.pairs]).
  final Map<int, int> _chosen = {};
  int? _activeLeft;
  bool _checked = false;

  static const _green = Color(0xFF3E8E5A);
  static const _red = Color(0xFFC0483C);

  @override
  void initState() {
    super.initState();
    final n = widget.pairs.length;
    _rightOrder = List.generate(n, (i) => i);
    // Never deal the right column in its answer order.
    final rng = Random();
    do {
      _rightOrder.shuffle(rng);
    } while (n > 1 && List.generate(n, (i) => _rightOrder[i] == i).every((x) => x));
  }

  void _tapLeft(int i) {
    if (_checked) return;
    setState(() => _activeLeft = _activeLeft == i ? null : i);
  }

  void _tapRight(int r) {
    if (_checked || _activeLeft == null) return;
    setState(() {
      _chosen.removeWhere((_, v) => v == r);
      _chosen[_activeLeft!] = r;
      final open = List.generate(
        widget.pairs.length,
        (i) => i,
      ).where((i) => !_chosen.containsKey(i));
      _activeLeft = open.isEmpty ? null : open.first;
    });
  }

  void _check() {
    final allRight = _chosen.entries.every((e) => e.key == e.value);
    setState(() => _checked = true);
    widget.onChecked(allRight);
  }

  /// Colour for a paired slot: pair colour before checking, green/red after.
  Color? _pairColor(int left) {
    final r = _chosen[left];
    if (r == null) return null;
    if (_checked) return r == left ? _green : _red;
    return widget.accent;
  }

  @override
  Widget build(BuildContext context) {
    final pairs = widget.pairs;
    final done = _chosen.length == pairs.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < pairs.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _Cell(
                    label: pairs[i].$1.of(widget.lang),
                    badge: '${i + 1}',
                    color: _activeLeft == i ? widget.accent : _pairColor(i),
                    selected: _activeLeft == i,
                    onTap: () => _tapLeft(i),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: _rightCell(_rightOrder[i])),
              ],
            ),
          ),
        if (_checked && _chosen.entries.any((e) => e.key != e.value)) ...[
          const SizedBox(height: 4),
          Text(
            'Correct pairs',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          for (var i = 0; i < pairs.length; i++)
            Text(
              '${i + 1}. ${pairs[i].$1.of(widget.lang)} → '
              '${pairs[i].$2.of(widget.lang)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
        ],
        if (!_checked) ...[
          const SizedBox(height: 6),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: widget.accent),
            onPressed: done ? _check : null,
            child: Text(done ? 'Check' : 'Tap a left item, then its match'),
          ),
        ],
      ],
    );
  }

  Widget _rightCell(int r) {
    final left = _chosen.entries
        .where((e) => e.value == r)
        .map((e) => e.key)
        .firstOrNull;
    return _Cell(
      label: widget.pairs[r].$2.of(widget.lang),
      badge: left == null ? null : '${left + 1}',
      color: left == null ? null : _pairColor(left),
      selected: false,
      onTap: () => _tapRight(r),
    );
  }
}

class _Cell extends StatelessWidget {
  final String label;
  final String? badge;
  final Color? color;
  final bool selected;
  final VoidCallback onTap;

  const _Cell({
    required this.label,
    required this.badge,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final c = color;
    return Material(
      color: c == null
          ? cs.surface
          : c.withValues(alpha: selected ? 0.2 : 0.12),
      borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
            border: Border.all(
              color: c ?? cs.outlineVariant,
              width: selected ? 2 : 1.5,
            ),
          ),
          child: Row(
            children: [
              if (badge != null) ...[
                CircleAvatar(
                  radius: 11,
                  backgroundColor: c ?? cs.outline,
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: AppFontWeight.semibold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
