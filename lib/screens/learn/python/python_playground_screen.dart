import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../data/programming/interpreter/py_runner.dart';
import '../../../providers/core_providers.dart';
import '../../../utils/haptics.dart';
import 'widgets/py_console.dart';
import 'widgets/py_editor.dart';
import 'widgets/py_run_host.dart';

// ─── Playground ───────────────────────────────────────────────────────────────
//
// Free-form editor + Run + console. The last code is saved so a student's
// experiments survive an app restart. A menu offers a few fun starter examples.

const _defaultCode = '''# Welcome to the Playground! 🧪
# Type any Python and press Run.

for i in range(1, 6):
    print("⭐" * i)
''';

const _examples = <(String, String)>[
  (
    'Star triangle',
    'for i in range(1, 6):\n    print("⭐" * i)\n',
  ),
  (
    'Table of 7',
    'for i in range(1, 11):\n    print(f"7 x {i} = {7 * i}")\n',
  ),
  (
    'Countdown rocket',
    'n = 5\nwhile n > 0:\n    print(n)\n    n -= 1\nprint("🚀 Liftoff!")\n',
  ),
  (
    'Ask my name',
    'name = input("What is your name? ")\nprint(f"Hello, {name}! 👋")\n',
  ),
  (
    'Even numbers',
    'for i in range(1, 21):\n    if i % 2 == 0:\n        print(i)\n',
  ),
];

class PythonPlaygroundScreen extends ConsumerStatefulWidget {
  const PythonPlaygroundScreen({super.key});

  @override
  ConsumerState<PythonPlaygroundScreen> createState() =>
      _PythonPlaygroundScreenState();
}

class _PythonPlaygroundScreenState
    extends ConsumerState<PythonPlaygroundScreen> {
  late final TextEditingController _controller;
  PyRunResult? _result;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    final saved = ref.read(userPrefsRepositoryProvider).getPythonPlaygroundCode();
    _controller = TextEditingController(text: saved ?? _defaultCode);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    Haptics.light(ref);
    FocusScope.of(context).unfocus();
    setState(() => _running = true);
    // Save first (fire-and-forget) so the input dialog isn't gated on it, then
    // run — runPython uses `context` synchronously to open the input sheet.
    unawaited(ref
        .read(userPrefsRepositoryProvider)
        .setPythonPlaygroundCode(_controller.text));
    final result = await runPython(context, _controller.text);
    if (!mounted) return;
    setState(() {
      _result = result;
      _running = false;
    });
  }

  void _loadExample() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text('Load an example',
                style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 8),
            ..._examples.map(
              (e) => ListTile(
                leading: const Icon(Icons.code_rounded),
                title: Text(e.$1),
                onTap: () => Navigator.of(ctx).pop(e.$2),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (choice != null) {
      setState(() {
        _controller.text = choice;
        _result = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Playground 🧪'),
        actions: [
          IconButton(
            tooltip: 'Load example',
            icon: const Icon(Icons.lightbulb_outline_rounded),
            onPressed: _loadExample,
          ),
          IconButton(
            tooltip: 'Clear',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => setState(() {
              _controller.clear();
              _result = null;
            }),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          PyEditor(controller: _controller, minLines: 8),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _running ? null : _run,
            icon: _running
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow_rounded),
            label: Text(_running ? 'Running…' : 'Run'),
          ),
          const SizedBox(height: 16),
          PyConsole(
            output: _result?.output ?? '',
            error: _result?.error,
            idle: _result == null,
          ),
        ],
      ),
    );
  }
}
