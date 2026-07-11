import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/services/feedback_service.dart';
import '../../providers/auth_provider.dart';
import '../../utils/haptics.dart';
import '../../widgets/calm_widgets.dart';

/// **Send feedback** — a single open box for anything: bug reports,
/// feature requests, ideas. Name/email are attached silently from the
/// signed-in user (nothing extra is asked if signed out). Responses go
/// to the team's Google Sheet via [FeedbackService].
class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final _controller = TextEditingController();
  var _isSending = false;
  var _sent = false;
  var _rating = 0; // 0 = not rated (optional)

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

    final user = ref
        .read(authStateProvider)
        .maybeWhen(data: (u) => u, orElse: () => null);

    final ok = await FeedbackService.submit(
      message: message,
      name: user?.displayName,
      email: user?.email,
      rating: _rating > 0 ? _rating : null,
    );

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
        title: const Text('Send feedback'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: _sent
            ? _ThankYou(onDone: () => context.pop())
            : ListView(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                children: [
                  // ── We hear you ─────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Tile(
                        color: cs.primary,
                        icon: Icons.forum_rounded,
                        size: 46,
                        radius: 13,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'We hear you.',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontSize: 22, height: 1.1),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Vidyālaya is built for students like you — '
                              'and your words decide what we build next.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontSize: 13,
                                    color: muted,
                                    height: 1.4,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // ── One box for everything ──────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: cs.surface,
                      border: Border.all(color: cs.outline),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.cardRadius),
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
                        hintText:
                            'Found a bug? Want a new feature or a book we '
                            'don\'t have yet? Tell us anything…',
                        hintStyle: TextStyle(
                          color: muted,
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                      style: const TextStyle(fontSize: 14.5, height: 1.45),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Optional star rating ────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: cs.surface,
                      border: Border.all(color: cs.outline),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.cardRadius),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Rate your experience',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontSize: 13, color: muted),
                          ),
                        ),
                        for (var star = 1; star <= 5; star++)
                          InkWell(
                            borderRadius: BorderRadius.circular(99),
                            onTap: () {
                              Haptics.selection(ref);
                              // Tap the same star again to clear.
                              setState(
                                () => _rating = _rating == star ? 0 : star,
                              );
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              child: Icon(
                                star <= _rating
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                size: 26,
                                color: star <= _rating
                                    ? const Color(0xFFF5B301)
                                    : muted,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

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
                      label: Text(_isSending ? 'Sending…' : 'Send feedback'),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'Every message goes straight to the team — bugs, ideas '
                    'and feature requests all welcome.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11.5,
                          color: muted,
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
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 8),
            Text(
              'Your feedback is on its way to the team. '
              'We read every single message.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 13.5,
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
