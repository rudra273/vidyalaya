import 'package:flutter/material.dart';

import '../app/theme.dart';

// ─── Class scope toggle ───────────────────────────────────────────────────────
//
// "My classes / All classes" switch for Explore content lists (diagrams,
// formulas). The class set comes from the Explore class filter.

class ClassScopeToggle extends StatelessWidget {
  /// True when only content for the student's classes is shown.
  final bool mine;
  final ValueChanged<bool> onChanged;

  /// Set when "My classes" matched nothing, so everything is shown anyway.
  final bool showingAllAsFallback;

  const ClassScopeToggle({
    super.key,
    required this.mine,
    required this.onChanged,
    this.showingAllAsFallback = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        8,
        AppSpacing.screenPadding,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: true, label: Text('My classes')),
              ButtonSegment(value: false, label: Text('All classes')),
            ],
            selected: {mine},
            onSelectionChanged: (s) => onChanged(s.single),
          ),
          if (showingAllAsFallback)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Nothing here for your classes yet — showing everything.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}
