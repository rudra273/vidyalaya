import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../data/models/plus.dart';
import '../../providers/plus_provider.dart';
import '../../utils/ai_labels.dart';
import '../../widgets/ai_robot_mark.dart';
import '../../widgets/chunky_button.dart';

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
    // The page tone, so the comparison card can sit on it as a surface.
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
    final dark = theme.brightness == Brightness.dark;
    final active = status?.state == PlusState.active;
    final canRequest = status != null && status.available && status.canRequest;
    final message = status == null ? null : plusMessage(status);
    final mood = active
        ? BotMood.cheering
        : widget.limitReached
        ? BotMood.resting
        : BotMood.idle;
    final accent = dark ? AppColors.green500Dark : AppColors.green600;
    final headingStyle = theme.textTheme.headlineLarge?.copyWith(
      height: 1.15,
      letterSpacing: -0.3,
    );

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The body scrolls on short screens; the actions below stay put.
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                4,
                AppSpacing.screenPadding,
                8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─── Header ───
                  Center(child: AiBot(size: 72, mood: mood)),
                  const SizedBox(height: 14),
                  if (widget.limitReached)
                    Text(
                      "That's all your questions for today",
                      textAlign: TextAlign.center,
                      style: headingStyle,
                    )
                  else
                    Text(
                      'Vidyakalp Plus',
                      textAlign: TextAlign.center,
                      style: headingStyle,
                    ),
                  if (!widget.limitReached && !active) ...[
                    const SizedBox(height: 6),
                    Text.rich(
                      TextSpan(
                        text: 'More room to learn with ',
                        children: [
                          TextSpan(
                            text: 'Plus',
                            style: TextStyle(
                              color: accent,
                              fontWeight: AppFontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                  if (widget.limitReached) ...[
                    const SizedBox(height: 6),
                    Text(
                      'They refresh ${refreshPhrase(widget.limitResetsAt)}.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                  // ─── What Plus gives ───
                  if (!active) ...[
                    const SizedBox(height: 22),
                    const _PlusComparison(),
                    const SizedBox(height: 18),
                    Text(
                      plusNotForSale,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: AppFontSize.body,
                        height: 1.5,
                        color: dark ? AppColors.ink2Dark : AppColors.ink2,
                      ),
                    ),
                  ],
                  // ─── Where the request stands ───
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.tilePad),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.tileRadius,
                        ),
                      ),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                  if (plus.error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      plus.error!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // ─── Actions ───
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              16,
              AppSpacing.screenPadding,
              12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (canRequest) ...[
                  ChunkyButton(
                    label: 'Request Plus',
                    onPressed: plus.requesting
                        ? null
                        : () => ref
                              .read(plusProvider.notifier)
                              .request(widget.source),
                    trailing: plus.requesting
                        ? SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: dark ? AppColors.ink3Dark : AppColors.ink2,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 6),
                ],
                SizedBox(
                  height: 48,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: cs.onSurface,
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: AppFontWeight.semibold,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(canRequest ? 'Not now' : 'Close'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Free vs Plus table ───

/// Free and Plus side by side, in words only: the Plus column is outlined in
/// green. Rows shared by both plans come first, then [plusFeatureLines].
class _PlusComparison extends StatelessWidget {
  const _PlusComparison();

  static const _freeCol = 64.0;
  static const _plusCol = 76.0;
  static const _rightPad = 10.0;
  static const _shared = [
    'Answers from your textbooks',
    'Books, quizzes and study tools',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final muted = dark ? AppColors.ink2Dark : AppColors.ink2;
    final faint = dark ? AppColors.ink3Dark : AppColors.ink3;
    final accent = dark ? AppColors.green500Dark : AppColors.green600;
    final accentInk = dark ? const Color(0xFF5ADBA6) : AppColors.green700;
    final columnFill = dark ? AppColors.green100Dark : AppColors.green50;
    final line = dark ? AppColors.hairlineDark : AppColors.hairline;

    Widget mark({required bool included, required bool plus}) {
      return Semantics(
        label: included ? 'Included' : 'Not included',
        child: ExcludeSemantics(
          child: included
              ? Icon(
                  Icons.check_circle_rounded,
                  size: plus ? 24 : 22,
                  color: plus ? accentInk : muted,
                )
              : Icon(Icons.remove_rounded, size: 22, color: faint),
        ),
      );
    }

    Widget row(String name, {required bool free}) {
      return Container(
        constraints: const BoxConstraints(minHeight: 64),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: line)),
        ),
        padding: const EdgeInsets.only(right: _rightPad),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 8, 10),
                child: Text(
                  name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 15,
                    height: 1.35,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: _freeCol,
              child: Center(child: mark(included: free, plus: false)),
            ),
            SizedBox(
              width: _plusCol,
              child: Center(child: mark(included: true, plus: true)),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 0, 6),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // The highlighted Plus column, standing a little proud of the card.
          Positioned(
            top: -14,
            bottom: -14,
            right: _rightPad,
            width: _plusCol,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: columnFill,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accent, width: 2),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 44,
                child: Padding(
                  padding: const EdgeInsets.only(right: _rightPad),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'WHAT YOU GET',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: AppFontWeight.bold,
                            letterSpacing: 0.5,
                            color: muted,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: _freeCol,
                        child: Text(
                          'Free',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppFontSize.body,
                            fontWeight: AppFontWeight.semibold,
                            color: muted,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: _plusCol,
                        child: Text(
                          'Plus',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppFontSize.body,
                            fontWeight: AppFontWeight.bold,
                            color: accentInk,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              for (final name in _shared) row(name, free: true),
              for (final name in plusFeatureLines) row(name, free: false),
            ],
          ),
        ],
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
