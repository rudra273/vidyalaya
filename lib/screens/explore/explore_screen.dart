import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../providers/core_providers.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/feature_card.dart';

/// The **Explore** tab (formerly "Learn"): the interactive learning *tools*,
/// de-tangled from AI (the AI agents now live in the Learn AI tab).
///
/// Tools are driven from data and laid out as a 2-column grid to keep the scroll
/// short. Opening a live tool records learning activity (bumps the tools-opened
/// counter and keeps the learning streak alive).
class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  void _openTool(BuildContext context, WidgetRef ref, _ExploreTool tool) {
    // Record before navigating away so the activity always lands.
    ref.read(userPrefsRepositoryProvider).recordToolOpened(tool.data.id);
    ref.read(progressProvider.notifier).refresh();
    context.push(tool.route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                16,
                AppSpacing.screenPadding,
                16,
              ),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Explore',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
            ),
            _SectionHeader(icon: Icons.science_rounded, title: 'Explore & Play'),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              sliver: SliverGrid(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.95,
                    ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final tool = _interactiveTools[index];
                  return FeatureCard(
                    data: tool.data,
                    onTap: () => _openTool(context, ref, tool),
                  );
                }, childCount: _interactiveTools.length),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            _SectionHeader(icon: Icons.upcoming_rounded, title: 'Coming soon'),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                0,
                AppSpacing.screenPadding,
                24,
              ),
              sliver: SliverList.separated(
                itemCount: _comingSoon.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) => FeatureCard(
                  data: _comingSoon[index],
                  layout: FeatureCardLayout.row,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        0,
        AppSpacing.screenPadding,
        12,
      ),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Icon(icon, size: 20, color: cs.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

/// A live interactive tool: its card data + the route it opens.
class _ExploreTool {
  final FeatureCardData data;
  final String route;

  const _ExploreTool({required this.data, required this.route});
}

const _interactiveTools = <_ExploreTool>[
  _ExploreTool(
    route: '/learn/math-formulas',
    data: FeatureCardData(
      id: 'math-formulas',
      title: 'Math Formulas',
      subtitle: 'Formulas & calculator',
      icon: Icons.functions,
      color: Colors.blueAccent,
    ),
  ),
  _ExploreTool(
    route: '/learn/periodic-table',
    data: FeatureCardData(
      id: 'periodic-table',
      title: 'Periodic Table',
      subtitle: 'Explore the elements',
      icon: Icons.science,
      color: Colors.purpleAccent,
    ),
  ),
  _ExploreTool(
    route: '/learn/diagrams',
    data: FeatureCardData(
      id: 'diagrams',
      title: 'Science Diagrams',
      subtitle: 'Interactive diagrams',
      icon: Icons.schema,
      color: Colors.teal,
    ),
  ),
  _ExploreTool(
    route: '/learn/timeline',
    data: FeatureCardData(
      id: 'timeline',
      title: 'Timeline',
      subtitle: 'Major history events',
      icon: Icons.history_edu,
      color: Colors.amber,
    ),
  ),
  _ExploreTool(
    route: '/learn/cosmulator',
    data: FeatureCardData(
      id: 'cosmulator',
      title: 'Cosmulator',
      subtitle: 'Solar system in 3D',
      icon: Icons.public,
      color: Colors.indigoAccent,
    ),
  ),
];

const _comingSoon = <FeatureCardData>[
  FeatureCardData(
    id: 'quizzes',
    title: 'Interactive Quizzes',
    subtitle: 'Chapter-wise quizzes with score tracking',
    icon: Icons.quiz,
    color: Colors.pinkAccent,
    status: FeatureStatus.comingSoon,
  ),
  FeatureCardData(
    id: 'virtual-lab',
    title: 'Virtual Science Lab',
    subtitle: 'Safe physics & chemistry experiments',
    icon: Icons.biotech,
    color: Colors.lightGreen,
    status: FeatureStatus.comingSoon,
  ),
];
