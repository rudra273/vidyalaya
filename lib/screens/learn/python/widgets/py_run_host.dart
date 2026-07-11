import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme.dart';
import '../../../../data/programming/interpreter/py_runner.dart';

// ─── Run host ─────────────────────────────────────────────────────────────────
//
// Shared glue for running a program with a live input() dialog. Keeps the
// bottom-sheet prompt logic in one place so both the lesson code cards and the
// playground behave identically.

Future<PyRunResult> runPython(
  BuildContext context,
  String source, {
  List<String> presetInputs = const [],
}) {
  return PyRunner.run(
    source,
    presetInputs: presetInputs,
    onInput: (prompt) => _askInput(context, prompt),
  );
}

Future<String> _askInput(BuildContext context, String prompt) async {
  final controller = TextEditingController();
  final cs = Theme.of(context).colorScheme;

  final value = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('💬 ', style: TextStyle(fontSize: 18)),
                Expanded(
                  child: Text(
                    prompt.trim().isEmpty ? 'The program needs your input' : prompt,
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              autofocus: true,
              style: GoogleFonts.jetBrainsMono(),
              decoration: InputDecoration(
                hintText: 'Type your answer…',
                filled: true,
                fillColor: cs.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (v) => Navigator.of(ctx).pop(v),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(ctx).pop(controller.text),
                child: const Text('Enter'),
              ),
            ),
          ],
        ),
      );
    },
  );

  return value ?? '';
}
