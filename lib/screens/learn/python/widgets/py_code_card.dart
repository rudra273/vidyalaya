import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme.dart';
import '../../../../data/programming/interpreter/py_runner.dart';
import '../../../../utils/haptics.dart';
import 'py_console.dart';
import 'py_run_host.dart';

// ─── Read-only runnable code card ─────────────────────────────────────────────
//
// Shows a Python snippet with a Run button. Output appears in an inline console
// below. Used by lesson CodeBlocks (the student reads the code and runs it).

class PyCodeCard extends ConsumerStatefulWidget {
  final String code;
  final List<String> presetInputs;

  const PyCodeCard({
    super.key,
    required this.code,
    this.presetInputs = const [],
  });

  @override
  ConsumerState<PyCodeCard> createState() => _PyCodeCardState();
}

class _PyCodeCardState extends ConsumerState<PyCodeCard> {
  PyRunResult? _result;
  bool _running = false;

  Future<void> _run() async {
    Haptics.light(ref);
    setState(() => _running = true);
    final result = await runPython(
      context,
      widget.code,
      presetInputs: widget.presetInputs,
    );
    if (!mounted) return;
    setState(() {
      _result = result;
      _running = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mono = GoogleFonts.jetBrainsMono(
      fontSize: 13.5,
      height: 1.55,
      color: const Color(0xFFE6EDE8),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0E1512),
            borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
            border: Border.all(color: const Color(0xFF25322B)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(widget.code, style: mono),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: _running ? null : _run,
            icon: _running
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow_rounded, size: 20),
            label: Text(_running ? 'Running…' : 'Run'),
          ),
        ),
        if (_result != null) ...[
          const SizedBox(height: 12),
          PyConsole(output: _result!.output, error: _result!.error),
        ],
      ],
    );
  }
}
