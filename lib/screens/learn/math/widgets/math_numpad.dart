import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../../../utils/haptics.dart';
import '../../../../widgets/pressable.dart';

// ─── Math numpad ──────────────────────────────────────────────────────────────
//
// An on-screen numeric keypad, so timed drills never get the OS keyboard sliding
// over the question. Shared by Flash Math, Speed Drills and table practice.

/// Big read-only display of the answer being typed.
class MathAnswerDisplay extends StatelessWidget {
  final String value;
  final Color accent;

  /// Shown greyed when [value] is empty.
  final String placeholder;

  const MathAnswerDisplay({
    super.key,
    required this.value,
    required this.accent,
    this.placeholder = '—',
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final empty = value.isEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Text(
        empty ? placeholder : value,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: empty ? cs.onSurfaceVariant : accent,
              letterSpacing: 1,
            ),
      ),
    );
  }
}

/// A 4×3 numeric keypad: digits, a sign toggle, backspace and submit.
class MathNumpad extends ConsumerWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onToggleSign;

  /// Null disables the submit button (e.g. while the answer is empty).
  final VoidCallback? onSubmit;
  final Color accent;
  final String submitLabel;

  /// Hides the `±` key for tools whose answers are never negative.
  final bool allowNegative;

  const MathNumpad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    required this.onToggleSign,
    required this.onSubmit,
    required this.accent,
    this.submitLabel = 'Check',
    this.allowNegative = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                for (final d in row) ...[
                  Expanded(
                    child: _Key(
                      label: d,
                      onTap: () {
                        Haptics.selection(ref);
                        onDigit(d);
                      },
                    ),
                  ),
                  if (d != row.last) const SizedBox(width: 10),
                ],
              ],
            ),
          ),
        Row(
          children: [
            Expanded(
              child: allowNegative
                  ? _Key(
                      label: '±',
                      onTap: () {
                        Haptics.selection(ref);
                        onToggleSign();
                      },
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Key(
                label: '0',
                onTap: () {
                  Haptics.selection(ref);
                  onDigit('0');
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Key(
                icon: Icons.backspace_outlined,
                onTap: () {
                  Haptics.selection(ref);
                  onBackspace();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: onSubmit,
            child: Text(
              submitLabel,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  const _Key({this.label, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Pressable(
      onTap: onTap,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? cs.surface : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: icon != null
            ? Icon(icon, size: 22, color: cs.onSurface)
            : Text(
                label!,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
              ),
      ),
    );
  }
}

/// Holds the digits being typed, so each screen doesn't re-implement the same
/// string juggling. Negative values are represented by a leading `-`.
class NumpadValue {
  String _raw = '';

  String get text {
    if (_raw.isEmpty) return '';
    return _raw == '-' ? '-' : _raw;
  }

  bool get isEmpty => _raw.isEmpty || _raw == '-';

  int? get intValue => int.tryParse(_raw);

  void addDigit(String d) {
    // Cap the length so a stuck finger can't overflow the display.
    if (_raw.replaceFirst('-', '').length >= 6) return;
    if (_raw == '0') {
      _raw = d;
    } else if (_raw == '-0') {
      _raw = '-$d';
    } else {
      _raw += d;
    }
  }

  void backspace() {
    if (_raw.isEmpty) return;
    _raw = _raw.substring(0, _raw.length - 1);
  }

  void toggleSign() {
    if (_raw.startsWith('-')) {
      _raw = _raw.substring(1);
    } else {
      _raw = '-$_raw';
    }
  }

  void clear() => _raw = '';
}
