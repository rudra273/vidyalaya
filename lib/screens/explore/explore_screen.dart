import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../providers/core_providers.dart';
import '../../providers/progress_provider.dart';
import '../../utils/haptics.dart';
import '../../widgets/calm_widgets.dart';
import '../../widgets/pressable.dart';

/// The **Explore** tab — interactive learning tools, presented as a tasteful
/// duotone grid (faint glyph backdrop, tinted tile, serif title) plus a
/// "Coming soon" group.
class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  void _open(BuildContext context, WidgetRef ref, _Tool tool) {
    Haptics.light(ref);
    ref.read(userPrefsRepositoryProvider).recordToolOpened(tool.id);
    ref.read(progressProvider.notifier).refresh();
    context.push(tool.route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tools = _tools(isDark);
    final soon = _soon(isDark);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            const PageTitle(
              title: 'Explore',
              sub: 'Hands-on, interactive learning',
            ),
            const SizedBox(height: AppSpacing.sectionGap - 14),
            const Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
              child: SectionHead(label: 'Explore & Play'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              child: _Grid(
                items: tools,
                onTap: (t) => _open(context, ref, t),
              ),
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            const Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
              child: SectionHead(label: 'Coming soon'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              child: _Grid(items: soon, soon: true),
            ),
          ],
        ),
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  final List<_Tool> items;
  final bool soon;
  final ValueChanged<_Tool>? onTap;

  const _Grid({required this.items, this.soon = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      const gap = AppSpacing.stackGap;
      final cellW = (c.maxWidth - gap) / 2;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: items.map((t) {
          return SizedBox(
            width: cellW,
            child: _ToolCard(
              tool: t,
              soon: soon,
              onTap: onTap == null ? null : () => onTap!(t),
            ),
          );
        }).toList(),
      );
    });
  }
}

class _ToolCard extends StatelessWidget {
  final _Tool tool;
  final bool soon;
  final VoidCallback? onTap;

  const _ToolCard({required this.tool, this.soon = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Pressable(
      onTap: soon ? null : onTap,
      child: Opacity(
        opacity: soon ? 0.72 : 1,
        child: Container(
          height: 152,
          padding: const EdgeInsets.all(AppSpacing.cardPad),
          decoration: BoxDecoration(
            color: cs.surface,
            border: Border.all(color: cs.outline),
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // faint glyph backdrop
              Positioned(
                right: -16,
                bottom: -18,
                child: Icon(
                  tool.icon,
                  size: 92,
                  color: tool.color.withValues(alpha: 0.12),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Tile(color: tool.color, icon: tool.icon, size: 46),
                      if (soon)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color:
                                  isDark ? AppColors.hairlineDark : AppColors.hairline,
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'SOON',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: isDark
                                  ? AppColors.ink3Dark
                                  : AppColors.ink3,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    tool.title,
                    style:
                        Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontSize: 16.5,
                              height: 1.12,
                            ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    tool.sub,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12.5,
                        ),
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

// ─── Tool data ───────────────────────────────────────────────────────────

class _Tool {
  final String id;
  final String title;
  final String sub;
  final IconData icon;
  final Color color;
  final String route;

  const _Tool({
    required this.id,
    required this.title,
    required this.sub,
    required this.icon,
    required this.color,
    this.route = '',
  });
}

List<_Tool> _tools(bool isDark) => [
      // Math is a hub: tables, drills, quizzes and Formulas all live inside it.
      _Tool(
        id: 'math',
        title: 'Math',
        sub: 'Tables, drills & quizzes',
        icon: Icons.calculate_rounded,
        color: isDark ? AppColors.cMathHubDark : AppColors.cMathHub,
        route: '/learn/math',
      ),
      _Tool(
        id: 'python',
        title: 'Python',
        sub: 'Learn to code, playfully',
        icon: Icons.code_rounded,
        color: isDark ? AppColors.cPythonDark : AppColors.cPython,
        route: '/learn/python',
      ),
      _Tool(
        id: 'periodic-table',
        title: 'Periodic Table',
        sub: 'Explore the elements',
        icon: Icons.grid_view_rounded,
        color: isDark ? AppColors.cPeriodicDark : AppColors.cPeriodic,
        route: '/learn/periodic-table',
      ),
      _Tool(
        id: 'vocabulary',
        title: 'Vocabulary',
        sub: 'Build your word power',
        icon: Icons.menu_book_outlined,
        color: isDark ? AppColors.cEnglishDark : AppColors.cEnglish,
        route: '/learn/vocabulary',
      ),
      _Tool(
        id: 'diagrams',
        title: 'Diagrams',
        sub: 'Interactive diagrams',
        icon: Icons.account_tree_rounded,
        color: isDark ? AppColors.cDiagramsDark : AppColors.cDiagrams,
        route: '/learn/diagrams',
      ),
      _Tool(
        id: 'timeline',
        title: 'Timeline',
        sub: 'Major history events',
        icon: Icons.timeline_rounded,
        color: isDark ? AppColors.cTimelineDark : AppColors.cTimeline,
        route: '/learn/timeline',
      ),
      _Tool(
        id: 'cosmulator',
        title: 'Cosmulator',
        sub: 'Solar system in 3D',
        icon: Icons.public_rounded,
        color: isDark ? AppColors.cCosmosDark : AppColors.cCosmos,
        route: '/learn/cosmulator',
      ),
    ];

List<_Tool> _soon(bool isDark) => [
      _Tool(
        id: 'quizzes',
        title: 'Quizzes',
        sub: 'Test yourself',
        icon: Icons.help_outline_rounded,
        color: isDark ? AppColors.cMathsDark : AppColors.cMaths,
      ),
      _Tool(
        id: 'virtual-lab',
        title: 'Virtual Science Lab',
        sub: 'Run experiments',
        icon: Icons.science_rounded,
        color: isDark ? AppColors.cScienceDark : AppColors.cScience,
      ),
    ];
