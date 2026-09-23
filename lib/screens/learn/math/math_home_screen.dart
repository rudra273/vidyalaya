import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../data/math/math_tools_data.dart';
import '../../../providers/math_progress_provider.dart';
import '../../../utils/haptics.dart';
import '../../../widgets/calm_widgets.dart';
import '../../../widgets/pressable.dart';

// ─── Math hub ─────────────────────────────────────────────────────────────────
//
// Fans out to the math practice tools: Formulas pinned as a big reference card up
// top (it's the one tool students come back to mid-homework), then a row per
// practice tool showing the student's best score.

class MathHomeScreen extends ConsumerWidget {
  const MathHomeScreen({super.key});

  static Color accentOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.cMathHubDark
          : AppColors.cMathHub;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(mathProgressProvider);
    final accent = accentOf(context);
    final formulas = mathToolById('math-formulas');
    final practice = mathTools.where((t) => t.id != 'math-formulas');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Math')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          const SizedBox(height: 12),
          if (formulas != null) _FormulasCard(tool: formulas, accent: accent),
          const Padding(
            padding: EdgeInsets.fromLTRB(
                AppSpacing.screenPadding, 22, AppSpacing.screenPadding, 4),
            child: SectionHead(label: 'Practise & play'),
          ),
          for (final tool in practice)
            _ToolRow(
              tool: tool,
              best: progress.bestFor(tool.id),
              accent: accent,
            ),
        ],
      ),
    );
  }
}

// ─── Formulas: the pinned reference card ──────────────────────────────────────

class _FormulasCard extends ConsumerWidget {
  final MathTool tool;
  final Color accent;

  const _FormulasCard({required this.tool, required this.accent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Pressable(
        onTap: () {
          Haptics.light(ref);
          context.push(tool.route);
        },
        child: Container(
          height: 150,
          padding: const EdgeInsets.all(AppSpacing.cardPad),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: accent.withValues(alpha: 0.28)),
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // Faint glyph backdrop, matching the Explore tile treatment.
              Positioned(
                right: -18,
                bottom: -22,
                child: Icon(
                  tool.icon,
                  size: 116,
                  color: accent.withValues(alpha: 0.14),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Tile(color: accent, icon: tool.icon, size: 46),
                  const Spacer(),
                  Text(
                    tool.title,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontSize: 22, height: 1.1),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Look up any formula, then calculate with it',
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward_rounded,
                          size: 20, color: accent),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolRow extends ConsumerWidget {
  final MathTool tool;
  final int? best;
  final Color accent;

  const _ToolRow({required this.tool, required this.best, required this.accent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding, 6, AppSpacing.screenPadding, 6),
      child: Pressable(
        onTap: () {
          Haptics.light(ref);
          context.push(tool.route);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? cs.surface : Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(
              color: best != null
                  ? accent.withValues(alpha: 0.4)
                  : cs.outlineVariant,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Tile(color: accent, icon: tool.icon, size: 46),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tool.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tool.sub,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                    ),
                    if (tool.scored && best != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.emoji_events_rounded,
                              size: 14, color: accent),
                          const SizedBox(width: 5),
                          Text(
                            'Best: $best',
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
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
