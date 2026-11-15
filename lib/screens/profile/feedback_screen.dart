import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/services/feedback_service.dart';
import '../../utils/haptics.dart';
import '../../widgets/calm_widgets.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final _controller = TextEditingController();
  var _isSending = false;
  var _sent = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final message = _controller.text.trim();
    if (message.isEmpty || _isSending) return;

    Haptics.light(ref);
    setState(() => _isSending = true);

    final ok = await FeedbackService.submit(message: message);

    if (!mounted) return;
    setState(() => _isSending = false);

    if (ok) {
      Haptics.medium(ref);
      setState(() => _sent = true);
    } else {
      Haptics.error(ref);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Couldn't send right now. Check your connection and try again.",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.ink2Dark : AppColors.ink2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report a problem'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/settings'),
        ),
      ),
      body: SafeArea(
        child: _sent
            ? _ThankYou(
                onDone: () =>
                    context.canPop() ? context.pop() : context.go('/settings'),
              )
            : ListView(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: cs.surface,
                      border: Border.all(color: cs.outline),
                      borderRadius: BorderRadius.circular(
                        AppSpacing.cardRadius,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    child: TextField(
                      controller: _controller,
                      minLines: 6,
                      maxLines: 12,
                      maxLength: 2000,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        counterText: '',
                        hintText: 'What happened? Include the steps you took.',
                        hintStyle: TextStyle(
                          color: muted,
                          fontSize: AppFontSize.body,
                          height: 1.45,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: AppFontSize.content,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  SizedBox(
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: _isSending ? null : _submit,
                      icon: _isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded, size: 18),
                      label: Text(_isSending ? 'Sending…' : 'Send report'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─── Thank-you state after a successful send ──────────────────────────────

class _ThankYou extends StatelessWidget {
  const _ThankYou({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.ink2Dark : AppColors.ink2;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tile(
              color: cs.primary,
              icon: Icons.check_rounded,
              size: 64,
              radius: 20,
            ),
            const SizedBox(height: 20),
            Text(
              'Thank you!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: AppFontSize.heading,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your report was sent to the team.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: AppFontSize.body,
                color: muted,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: onDone, child: const Text('Done')),
          ],
        ),
      ),
    );
  }
}
