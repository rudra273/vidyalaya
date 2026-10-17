import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../data/models/plus.dart';
import '../../providers/plus_provider.dart';
import '../../utils/ai_labels.dart';

// ─── Plus sheet ───

/// What Plus gives, in words only: the limits are still being validated, so no
/// numbers are promised here.
const plusFeatureLines = [
  'More AI questions every day',
  'Higher limits on tests, Tutor and Speaking as they launch',
];

const plusNotForSale =
    "Plus isn't for sale yet. Asking costs nothing, and we add Plus to "
    'selected accounts for a limited time.';

/// Opens the Plus sheet: what Plus gives, and where the student's request
/// stands. Set [limitReached] when a refused question opened it; [limitResetsAt]
/// is when the allowance refills.
Future<void> showPlusSheet(
  BuildContext context, {
  required String source,
  bool limitReached = false,
  DateTime? limitResetsAt,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => PlusSheet(
      source: source,
      limitReached: limitReached,
      limitResetsAt: limitResetsAt,
    ),
  );
}

class PlusSheet extends ConsumerStatefulWidget {
  /// A [PlusSource]: the screen the student opened this from.
  final String source;
  final bool limitReached;
  final DateTime? limitResetsAt;

  const PlusSheet({
    super.key,
    required this.source,
    this.limitReached = false,
    this.limitResetsAt,
  });

  @override
  ConsumerState<PlusSheet> createState() => _PlusSheetState();
}

class _PlusSheetState extends ConsumerState<PlusSheet> {
  @override
  void initState() {
    super.initState();
    // The student may have been approved since this was last checked.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(plusProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final plus = ref.watch(plusProvider);
    final status = plus.status;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final active = status?.state == PlusState.active;
    final canRequest = status != null && status.available && status.canRequest;
    final message = status == null ? null : plusMessage(status);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          4,
          AppSpacing.screenPadding,
          20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.limitReached
                  ? "That's all your questions for today"
                  : 'Vidyakalp Plus',
              style: theme.textTheme.titleLarge,
            ),
            if (widget.limitReached) ...[
              const SizedBox(height: 6),
              Text(
                'They refresh ${refreshPhrase(widget.limitResetsAt)}.',
                style: theme.textTheme.bodyMedium,
              ),
            ],
            if (!active) ...[
              const SizedBox(height: 16),
              for (final line in plusFeatureLines)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 20,
                        color: cs.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(line, style: theme.textTheme.bodyMedium),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 4),
              Text(plusNotForSale, style: theme.textTheme.bodySmall),
            ],
            if (message != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.tilePad),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
                ),
                child: Text(message, style: theme.textTheme.bodyMedium),
              ),
            ],
            if (plus.error != null) ...[
              const SizedBox(height: 12),
              Text(
                plus.error!,
                style: theme.textTheme.bodySmall?.copyWith(color: cs.error),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                if (canRequest)
                  Expanded(
                    child: FilledButton(
                      onPressed: plus.requesting
                          ? null
                          : () => ref
                                .read(plusProvider.notifier)
                                .request(widget.source),
                      child: plus.requesting
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Request Plus'),
                    ),
                  ),
                if (canRequest) const SizedBox(width: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(canRequest ? 'Not now' : 'Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// What to tell the student about where their request stands, or null when
/// there is nothing to add. Declines are always neutral: no reason, no blame.
String? plusMessage(PlusStatus status) {
  switch (status.state) {
    case PlusState.active:
      if (status.planKey == 'pro') {
        return 'Your account already has everything in Plus.';
      }
      final until = status.plusExpiresAt;
      return until == null
          ? 'Plus is on for your account.'
          : 'Plus is on for your account until ${shortDate(until)}.';
    case PlusState.pending:
      return "Plus requested. We'll review it. You don't need to do anything: "
          "it shows up here when it's added.";
    case PlusState.declined:
      final again = status.canRequestAgainAt;
      return again == null
          ? "Plus isn't available for your account right now."
          : "Plus isn't available for your account right now. "
                'You can ask again after ${shortDate(again)}.';
    case PlusState.expired:
      return 'Your Plus access has ended. You can ask for it again.';
    case PlusState.none:
      return null;
  }
}
