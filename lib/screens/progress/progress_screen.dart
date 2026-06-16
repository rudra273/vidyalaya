import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../profile/widgets/learning_summary.dart';

/// Standalone Progress page. Reached from the Profile "My Learning" row and the
/// Home learning-streak chip. Renders the shared [LearningSummary] dashboard.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'My Learning',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            8,
            AppSpacing.screenPadding,
            40,
          ),
          child: const LearningSummary(showHeader: false),
        ),
      ),
    );
  }
}
