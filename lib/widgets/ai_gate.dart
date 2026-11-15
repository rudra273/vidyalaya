import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/theme.dart';
import '../providers/learn_assist_provider.dart';
import '../providers/user_selection_provider.dart';
import 'ai_robot_mark.dart';

// ─── AI gate ───────────────────────────────────────────────────────────────
// Wraps every AI screen. The child is only built when the student's class
// has textbooks behind the AI, so its initState (history loads, camera,
// image recovery) never runs for a class the AI cannot serve.

class AiGate extends ConsumerWidget {
  const AiGate({super.key, required this.child, this.inShell = false});

  final Widget child;

  /// True on a bottom-nav tab (the shell owns the Scaffold); false for a
  /// pushed route, which needs its own app bar and back button.
  final bool inShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(aiAccessProvider) == AiAccess.available) return child;

    final view = _AiComingSoonView(classNo: ref.watch(primaryClassProvider));
    if (inShell) return SafeArea(child: view);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: view,
    );
  }
}

class _AiComingSoonView extends StatelessWidget {
  const _AiComingSoonView({required this.classNo});

  final int classNo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding + 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AiBot(size: 88, mood: BotMood.resting),
            const SizedBox(height: 20),
            Text(
              'AI for Class $classNo is coming soon',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'We are adding your textbooks so the AI can answer from them. '
              'Until then, your books and study tools are all here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
