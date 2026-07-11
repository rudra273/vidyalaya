import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme.dart';
import '../../../../data/programming/interpreter/py_error.dart';

// ─── Output console ───────────────────────────────────────────────────────────
//
// A terminal-styled panel that shows a program's stdout, or a friendly error
// card when something went wrong. Dark in both app themes so it reads as a
// "screen".

class PyConsole extends StatelessWidget {
  final String output;
  final PyError? error;

  /// Shown before the first run.
  final bool idle;

  const PyConsole({
    super.key,
    required this.output,
    this.error,
    this.idle = false,
  });

  @override
  Widget build(BuildContext context) {
    final mono = GoogleFonts.jetBrainsMono(
      fontSize: 13.5,
      height: 1.5,
      color: const Color(0xFFE6EDE8),
    );

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 60),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1512),
        borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
        border: Border.all(color: const Color(0xFF25322B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _Dot(Color(0xFFE86A5E)),
              const SizedBox(width: 6),
              const _Dot(Color(0xFFE6B95A)),
              const SizedBox(width: 6),
              const _Dot(Color(0xFF6BC48A)),
              const SizedBox(width: 10),
              Text(
                'Output',
                style: mono.copyWith(
                  fontSize: 11,
                  color: const Color(0xFF6D7E75),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (idle)
            Text('▸ Tap Run to see what happens',
                style: mono.copyWith(color: const Color(0xFF6D7E75)))
          else ...[
            if (output.isNotEmpty)
              SelectableText(output.trimRight(), style: mono),
            if (error != null) _ErrorView(error: error!, mono: mono),
            if (output.isEmpty && error == null)
              Text('(no output)',
                  style: mono.copyWith(color: const Color(0xFF6D7E75))),
          ],
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final PyError error;
  final TextStyle mono;
  const _ErrorView({required this.error, required this.mono});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1714),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF5C2E28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🐛 ', style: TextStyle(fontSize: 14)),
              Expanded(
                child: Text(
                  error.line != null ? 'Line ${error.line}' : 'Oops!',
                  style: mono.copyWith(
                    color: const Color(0xFFF0A79D),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(error.message,
              style: mono.copyWith(color: const Color(0xFFF3D8D3))),
          if (error.hint != null) ...[
            const SizedBox(height: 6),
            Text('💡 ${error.hint}',
                style: mono.copyWith(
                    color: const Color(0xFFCBB98A), fontSize: 12)),
          ],
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot(this.color);
  @override
  Widget build(BuildContext context) => Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}
