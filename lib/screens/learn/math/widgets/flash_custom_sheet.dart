import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../../../data/math/math_models.dart';
import '../../../../utils/haptics.dart';

// ─── Flash Math custom settings ───────────────────────────────────────────────
//
// A bottom sheet for picking step count, seconds per step and which operations
// appear. Returns the assembled preset, or null if dismissed.

Future<MathFlashPreset?> showFlashCustomSheet(
  BuildContext context, {
  required MathFlashPreset initial,
  required Color accent,
}) {
  return showModalBottomSheet<MathFlashPreset>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _FlashCustomSheet(initial: initial, accent: accent),
  );
}

class _FlashCustomSheet extends ConsumerStatefulWidget {
  final MathFlashPreset initial;
  final Color accent;

  const _FlashCustomSheet({required this.initial, required this.accent});

  @override
  ConsumerState<_FlashCustomSheet> createState() => _FlashCustomSheetState();
}

class _FlashCustomSheetState extends ConsumerState<_FlashCustomSheet> {
  late int _steps = widget.initial.steps;
  late double _seconds = widget.initial.secondsPerStep;
  late final Set<MathOp> _ops = {...widget.initial.allowedOps};

  /// Division needs at least one other operation to build a chain from, and an
  /// empty set has nothing to generate at all.
  bool get _opsValid => _ops.isNotEmpty && _ops != {MathOp.div};

  void _toggleOp(MathOp op) {
    Haptics.selection(ref);
    setState(() {
      if (_ops.contains(op)) {
        _ops.remove(op);
      } else {
        _ops.add(op);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = widget.accent;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding, 8, AppSpacing.screenPadding, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Text(
              'Custom round',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 4),
            Text(
              describeFlashSettings(_steps, _seconds, _ops.toList()),
              style: TextStyle(color: accent, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 22),

            // ── Steps ──
            _Label(text: 'How many numbers', value: '$_steps'),
            Slider(
              value: _steps.toDouble(),
              min: flashMinSteps.toDouble(),
              max: flashMaxSteps.toDouble(),
              divisions: flashMaxSteps - flashMinSteps,
              activeColor: accent,
              label: '$_steps',
              onChanged: (v) {
                final next = v.round();
                if (next != _steps) {
                  Haptics.selection(ref);
                  setState(() => _steps = next);
                }
              },
            ),

            const SizedBox(height: 8),

            // ── Seconds ──
            _Label(
              text: 'Seconds each number shows',
              value: '${_secondsText}s',
            ),
            Slider(
              value: _seconds,
              min: flashMinSeconds,
              max: flashMaxSeconds,
              // 0.5s increments across the range.
              divisions: ((flashMaxSeconds - flashMinSeconds) / 0.5).round(),
              activeColor: accent,
              label: '${_secondsText}s',
              onChanged: (v) {
                if (v != _seconds) {
                  Haptics.selection(ref);
                  setState(() => _seconds = v);
                }
              },
            ),

            const SizedBox(height: 18),

            // ── Operations ──
            Text(
              'Operations',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (final op in MathOp.values) ...[
                  Expanded(
                    child: _OpChip(
                      op: op,
                      selected: _ops.contains(op),
                      accent: accent,
                      onTap: () => _toggleOp(op),
                    ),
                  ),
                  if (op != MathOp.values.last) const SizedBox(width: 10),
                ],
              ],
            ),
            if (!_opsValid) ...[
              const SizedBox(height: 10),
              Text(
                _ops.isEmpty
                    ? 'Pick at least one operation.'
                    : 'Division needs another operation to work with.',
                style: const TextStyle(
                  color: Color(0xFFC0483C),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: _opsValid
                    ? () {
                        Haptics.light(ref);
                        Navigator.of(context).pop(
                          widget.initial.copyWith(
                            id: flashCustomId,
                            label: 'Custom',
                            steps: _steps,
                            secondsPerStep: _seconds,
                            // Keep a stable display order regardless of tap order.
                            allowedOps: MathOp.values
                                .where(_ops.contains)
                                .toList(),
                          ),
                        );
                      }
                    : null,
                child: const Text(
                  'Use these settings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _secondsText =>
      _seconds == _seconds.roundToDouble() ? '${_seconds.round()}' : '$_seconds';
}

class _Label extends StatelessWidget {
  final String text;
  final String value;

  const _Label({required this.text, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _OpChip extends StatelessWidget {
  final MathOp op;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  const _OpChip({
    required this.op,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: selected
          ? accent.withValues(alpha: 0.14)
          : (isDark ? cs.surface : Colors.white),
      borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
        child: Container(
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
            border: Border.all(
              color: selected ? accent : cs.outlineVariant,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            op.symbol,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: selected ? accent : cs.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
