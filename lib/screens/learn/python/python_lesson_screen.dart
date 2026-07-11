import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../data/programming/interpreter/py_runner.dart';
import '../../../data/programming/python_course_data.dart';
import '../../../data/programming/python_models.dart';
import '../../../providers/python_progress_provider.dart';
import '../../../utils/haptics.dart';
import 'widgets/py_code_card.dart';
import 'widgets/py_console.dart';
import 'widgets/py_editor.dart';
import 'widgets/py_run_host.dart';

// ─── Lesson screen ────────────────────────────────────────────────────────────
//
// Pages through a lesson's blocks. The last page shows a "Finish lesson" button
// that records completion and pops back to the chapter.

class PythonLessonScreen extends ConsumerStatefulWidget {
  final String lessonId;
  const PythonLessonScreen({super.key, required this.lessonId});

  @override
  ConsumerState<PythonLessonScreen> createState() =>
      _PythonLessonScreenState();
}

class _PythonLessonScreenState extends ConsumerState<PythonLessonScreen> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lesson = pythonLessonById(widget.lessonId);
    if (lesson == null) {
      return const Scaffold(body: Center(child: Text('Lesson not found')));
    }
    final blocks = lesson.blocks;
    final isLast = _page == blocks.length - 1;
    final accent = Theme.of(context).brightness == Brightness.dark
        ? AppColors.cPythonDark
        : AppColors.cPython;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(lesson.title)),
      body: Column(
        children: [
          _ProgressDots(count: blocks.length, index: _page, accent: accent),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: blocks.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) => SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: _BlockView(block: blocks[i]),
              ),
            ),
          ),
          _NavBar(
            page: _page,
            count: blocks.length,
            accent: accent,
            onBack: _page == 0
                ? null
                : () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    ),
            onNext: isLast
                ? () => _finish(lesson)
                : () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    ),
            isLast: isLast,
          ),
        ],
      ),
    );
  }

  Future<void> _finish(PythonLesson lesson) async {
    Haptics.medium(ref);
    await ref.read(pythonProgressProvider.notifier).completeLesson(lesson.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text('Lesson complete: ${lesson.title}')),
          ],
        ),
      ),
    );
    context.pop();
  }
}

// ─── Block rendering ──────────────────────────────────────────────────────────

class _BlockView extends StatelessWidget {
  final LessonBlock block;
  const _BlockView({required this.block});

  @override
  Widget build(BuildContext context) {
    return switch (block) {
      TextBlock() => _TextBlockView(text: (block as TextBlock).text),
      CodeBlock() => _CodeBlockView(block: block as CodeBlock),
      ChallengeBlock() => _ChallengeBlockView(block: block as ChallengeBlock),
    };
  }
}

class _TextBlockView extends StatelessWidget {
  final String text;
  const _TextBlockView({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
          children: _parseBold(text, context),
        ),
      ),
    );
  }

  // Renders **bold** spans; everything else is plain.
  List<TextSpan> _parseBold(String src, BuildContext context) {
    final spans = <TextSpan>[];
    final re = RegExp(r'\*\*(.+?)\*\*');
    int last = 0;
    for (final m in re.allMatches(src)) {
      if (m.start > last) spans.add(TextSpan(text: src.substring(last, m.start)));
      spans.add(TextSpan(
        text: m.group(1),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ));
      last = m.end;
    }
    if (last < src.length) spans.add(TextSpan(text: src.substring(last)));
    return spans;
  }
}

class _CodeBlockView extends StatelessWidget {
  final CodeBlock block;
  const _CodeBlockView({required this.block});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PyCodeCard(code: block.code, presetInputs: block.presetInputs),
        const SizedBox(height: 14),
        Text(
          'Expected output',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textMuted,
                letterSpacing: 0.5,
              ),
        ),
        const SizedBox(height: 6),
        PyConsole(output: block.expectedOutput),
      ],
    );
  }
}

class _ChallengeBlockView extends ConsumerStatefulWidget {
  final ChallengeBlock block;
  const _ChallengeBlockView({required this.block});

  @override
  ConsumerState<_ChallengeBlockView> createState() =>
      _ChallengeBlockViewState();
}

class _ChallengeBlockViewState extends ConsumerState<_ChallengeBlockView> {
  late final TextEditingController _controller;
  PyRunResult? _result;
  bool _running = false;
  bool _matched = false;
  bool _showHint = false;
  PyCancelToken? _cancelToken;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.block.starterCode);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    Haptics.light(ref);
    FocusScope.of(context).unfocus();
    final token = PyCancelToken();
    setState(() {
      _running = true;
      _cancelToken = token;
    });
    final result = await runPython(
      context,
      _controller.text,
      presetInputs: widget.block.presetInputs,
      cancelToken: token,
    );
    if (!mounted) return;
    final matched = widget.block.expectedOutput != null &&
        result.ok &&
        result.output == widget.block.expectedOutput;
    if (matched) Haptics.medium(ref);
    setState(() {
      _result = result;
      _running = false;
      _matched = matched;
      _cancelToken = null;
    });
  }

  void _stop() {
    Haptics.light(ref);
    _cancelToken?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).brightness == Brightness.dark
        ? AppColors.cPythonDark
        : AppColors.cPython;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
            border: Border.all(color: accent.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2, right: 8),
                child: Icon(Icons.flag_rounded, size: 18, color: accent),
              ),
              Expanded(
                child: Text(
                  widget.block.prompt,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        PyEditor(controller: _controller, minLines: 4),
        const SizedBox(height: 12),
        Row(
          children: [
            _running
                ? FilledButton.icon(
                    onPressed: _stop,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE86A5E),
                    ),
                    icon: const Icon(Icons.stop_rounded, size: 20),
                    label: const Text('Stop'),
                  )
                : FilledButton.icon(
                    onPressed: _run,
                    icon: const Icon(Icons.play_arrow_rounded, size: 20),
                    label: const Text('Run'),
                  ),
            const SizedBox(width: 10),
            TextButton.icon(
              onPressed: () => setState(() => _showHint = !_showHint),
              icon: const Icon(Icons.help_outline_rounded, size: 18),
              label: const Text('Hint'),
            ),
          ],
        ),
        if (_showHint) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded,
                    size: 18, color: AppColors.textMuted),
                const SizedBox(width: 8),
                Expanded(child: Text(widget.block.hint)),
              ],
            ),
          ),
        ],
        if (_matched) ...[
          const SizedBox(height: 12),
          _MatchBanner(accent: accent),
        ],
        if (_result != null) ...[
          const SizedBox(height: 12),
          PyConsole(
            output: _result!.output,
            error: _result!.error,
            stopped: _result!.stopped,
          ),
        ],
      ],
    );
  }
}

class _MatchBanner extends StatelessWidget {
  final Color accent;
  const _MatchBanner({required this.accent});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 280),
      curve: Curves.elasticOut,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_rounded, size: 20, color: accent),
            const SizedBox(width: 8),
            Text(
              'Output matches — well done!',
              style: TextStyle(fontWeight: FontWeight.w700, color: accent),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Chrome ───────────────────────────────────────────────────────────────────

class _ProgressDots extends StatelessWidget {
  final int count;
  final int index;
  final Color accent;
  const _ProgressDots(
      {required this.count, required this.index, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (i) {
          final active = i == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: active ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: active
                  ? accent
                  : Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  final int page;
  final int count;
  final Color accent;
  final VoidCallback? onBack;
  final VoidCallback onNext;
  final bool isLast;

  const _NavBar({
    required this.page,
    required this.count,
    required this.accent,
    required this.onBack,
    required this.onNext,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding, 8, AppSpacing.screenPadding, 12),
        child: Row(
          children: [
            if (onBack != null)
              OutlinedButton(
                onPressed: onBack,
                child: const Text('Back'),
              ),
            const Spacer(),
            FilledButton.icon(
              onPressed: onNext,
              icon: Icon(isLast
                  ? Icons.check_rounded
                  : Icons.arrow_forward_rounded),
              label: Text(isLast ? 'Finish lesson' : 'Next'),
            ),
          ],
        ),
      ),
    );
  }
}
