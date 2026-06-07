import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import 'agent.dart';

/// Landing screen for the **Learn AI** tab.
///
/// Instead of dropping a Class-5 student straight into a blank chat, this shows
/// a friendly *agent picker*: one card per [learnAgents] entry. Tapping a live
/// agent opens the real chat; a mock agent opens its preview.
class LearnAiHubScreen extends ConsumerWidget {
  const LearnAiHubScreen({super.key});

  void _openAgent(BuildContext context, LearnAgent agent) {
    switch (agent.status) {
      case AgentStatus.live:
        context.push('/learn/ai?channel=${agent.channel}');
      case AgentStatus.mock:
        context.push(agent.mockRoute!);
      case AgentStatus.comingSoon:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${agent.title} is coming soon!'),
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                16,
                AppSpacing.screenPadding,
                4,
              ),
              child: Text(
                'Learn with AI',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                0,
                AppSpacing.screenPadding,
                20,
              ),
              child: Text(
                'Pick a helper to get started.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                children: [
                  for (final agent in learnAgents)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _AgentCard(
                        agent: agent,
                        onTap: () => _openAgent(context, agent),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A prominent, tappable card for one AI agent. Sized for small fingers
/// (full-width, large icon + title + subtitle) with a status badge.
class _AgentCard extends StatelessWidget {
  final LearnAgent agent;
  final VoidCallback onTap;

  const _AgentCard({required this.agent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? cs.surface : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: cs.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(agent.icon, color: cs.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          agent.title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (agent.status != AgentStatus.live) ...[
                        const SizedBox(width: 8),
                        _StatusBadge(status: agent.status),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    agent.subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final AgentStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final label = switch (status) {
      AgentStatus.mock => 'Preview',
      AgentStatus.comingSoon => 'Soon',
      AgentStatus.live => 'Live',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: cs.tertiary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: cs.tertiary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
