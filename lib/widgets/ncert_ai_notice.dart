import 'package:flutter/material.dart';

import '../app/theme.dart';

/// Explains the current AI and textbook support for NCERT students.
class NcertAiNotice extends StatelessWidget {
  const NcertAiNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: cs.secondary.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.construction_rounded, color: cs.onSecondaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'NCERT textbook support is coming soon. You can still ask questions and get answers from AI’s general knowledge.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSecondaryContainer,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
