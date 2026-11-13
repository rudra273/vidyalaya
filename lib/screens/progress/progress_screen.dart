import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../widgets/calm_widgets.dart';
import '../profile/widgets/learning_summary.dart';

/// Standalone Progress page. Reached from the Profile "My Learning" row and the
/// Home learning-streak chip. Renders the shared [LearningSummary] dashboard.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 40),
          children: [
            PageTitle(
              title: 'My Learning',
              onBack: () =>
                  context.canPop() ? context.pop() : context.go('/profile'),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                16,
                AppSpacing.screenPadding,
                0,
              ),
              child: LearningSummary(showHeader: false),
            ),
          ],
        ),
      ),
    );
  }
}
