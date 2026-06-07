import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/feature_card.dart';

/// Home "Explore" quick actions, driven by [FeatureCard]. The old disabled
/// "Assignment (soon)" tile was removed in the AI-first refactor.
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  static const _actions = <_QuickAction>[
    _QuickAction(
      route: '/bookmarks',
      data: FeatureCardData(
        id: 'bookmarks',
        title: 'Bookmarks',
        subtitle: 'Saved pages',
        icon: Icons.bookmark_rounded,
        color: Color(0xFF2E7D32),
      ),
    ),
    _QuickAction(
      route: '/timetable',
      data: FeatureCardData(
        id: 'timetable',
        title: 'Timetable',
        subtitle: 'My classes',
        icon: Icons.calendar_month_rounded,
        color: Color(0xFF1565C0),
      ),
    ),
    _QuickAction(
      route: '/notes',
      data: FeatureCardData(
        id: 'notes',
        title: 'Notes',
        subtitle: 'My highlights',
        icon: Icons.edit_note_rounded,
        color: Color(0xFFFF8F00),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: _actions.length,
      itemBuilder: (context, index) {
        final action = _actions[index];
        return FeatureCard(
          data: action.data,
          onTap: () => context.push(action.route),
        );
      },
    );
  }
}

class _QuickAction {
  final FeatureCardData data;
  final String route;

  const _QuickAction({required this.data, required this.route});
}
