import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/models/learn_assist.dart';
import '../../data/models/recent_question.dart';
import '../../data/seed/ai_suggestions.dart';
import '../../providers/auth_provider.dart';
import '../../providers/core_providers.dart';
import '../../providers/ingested_books_provider.dart';
import '../../providers/learn_assist_provider.dart';
import '../../providers/recent_questions_provider.dart';
import '../../providers/user_selection_provider.dart';
import '../../utils/ai_labels.dart';
import '../../utils/haptics.dart';
import '../../widgets/ask_card.dart';
import '../../widgets/calm_widgets.dart';
import '../../widgets/clay_card.dart';
import '../../widgets/pressable.dart';

/// Haptic tap → push, shared by every row on this page.
void _navTap(WidgetRef ref, BuildContext context, String path) {
  Haptics.light(ref);
  context.push(path);
}

/// The **AI** tab — the front door to everything the AI can do. It is a
/// landing page, not the chat itself: every action here pushes the full-screen
/// Q&A chat (`/learn/ai`), which keeps its own composer, history and streaming.
///
/// Hero → Pick up where you left off → Snap a page → Ask about (subjects) →
/// Try asking → More (Tutor).
class AiHubScreen extends ConsumerWidget {
  const AiHubScreen({super.key});

  /// Warm the plan + quota cache once, off the build frame (same pattern as
  /// the chat screen's `_ensureAccountSummary`).
  void _ensureAccountSummary(WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cache = ref.read(backendAccountCacheProvider.notifier);
      cache.ensureUser();
      cache.ensureUsage();
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSignedIn = ref
        .watch(authStateProvider)
        .maybeWhen(data: (user) => user != null, orElse: () => false);
    final account = ref.watch(backendAccountCacheProvider);
    if (isSignedIn && (!account.userLoaded || !account.usageLoaded)) {
      _ensureAccountSummary(ref);
    }

    // Same board/class the chat resolves to, so the subjects offered here are
    // exactly the conversations the chat can open.
    final classNo = resolveLearnAssistClass(ref.watch(userSelectionProvider));
    final board = ref.watch(userBoardProvider);
    final subjects = learnAssistSubjects(
      ref.watch(ingestedBooksProvider),
      board,
      classNo,
    );

    // Locally-kept questions, so "pick up where you left off" can span every
    // subject at once — backend history is cached one conversation at a time.
    final recents = ref.watch(recentQuestionsProvider);

    final lastChat = ref
        .read(userPrefsRepositoryProvider)
        .getChatLastActivity(LearnAssistChannel.learnAssist);
    // Older than a day and "continue" stops meaning anything — the fresh-start
    // rule in the chat will have tucked that conversation away anyway.
    final showContinue =
        lastChat != null &&
        DateTime.now().difference(lastChat) < const Duration(days: 1);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          PageTitle(
            title: 'AI Learning',
            sub: _statusLine(isSignedIn, account),
          ),
          const SizedBox(height: AppSpacing.sectionGap - 14),

          // ── Ask ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            child: AiAskHero(
              headline: 'Ask anything from your textbooks.',
              sub: 'Clear answers in English, Odia or Hindi.',
              onAsk: (style) => _navTap(
                ref,
                context,
                '/learn/ai?focus=1&style=${style.key}',
              ),
              onCamera: () => _navTap(ref, context, '/learn/ai?camera=1'),
            ),
          ),

          // ── Pick up where you left off ───────────────────────────────
          // Real recent questions when we have them; the plain "continue"
          // row is the fallback for a conversation started before this
          // list existed.
          if (recents.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sectionGap),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: SectionHead(
                label: 'Pick up where you left off',
                action: 'Open chat',
                onAction: () => _navTap(ref, context, '/learn/ai?resume=1'),
              ),
            ),
            SizedBox(
              // Fits the eyebrow, two wrapped lines of question and the
              // timestamp without the text spilling over the row below.
              height: 98,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                itemCount: recents.length > 6 ? 6 : recents.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final question = recents[index];
                  return _RecentQuestionCard(
                    question: question,
                    board: board,
                    classNo: classNo,
                    onTap: () =>
                        _navTap(ref, context, _resumePath(question)),
                  );
                },
              ),
            ),
          ] else if (showContinue) ...[
            const SizedBox(height: AppSpacing.sectionGap),
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: SectionHead(label: 'Continue'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: _HubRow(
                color: _isDark(context) ? AppColors.cAiDark : AppColors.cAi,
                icon: Icons.forum_rounded,
                title: 'Continue your chat',
                sub: 'Last opened ${_ago(lastChat)}',
                onTap: () => _navTap(ref, context, '/learn/ai?resume=1'),
              ),
            ),
          ],

          // ── Ask about a subject ──────────────────────────────────────
          if (subjects.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sectionGap),
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: SectionHead(label: 'Ask about'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      // Wider gutters than the flat tiles needed — the clay
                      // shadows want room to fall before the next card starts.
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.5,
                    ),
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  return _SubjectTile(
                    subject: subject,
                    board: board,
                    classNo: classNo,
                    onTap: () => _navTap(
                      ref,
                      context,
                      '/learn/ai?subject=${Uri.encodeComponent(subject)}'
                      '&focus=1',
                    ),
                  );
                },
              ),
            ),
          ],

          // ── Starter questions ────────────────────────────────────────
          const SizedBox(height: AppSpacing.sectionGap),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            child: SectionHead(label: 'Try asking'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            child: Column(
              children: [
                for (final question in aiSuggestionsFor(null)) ...[
                  _StarterRow(
                    text: question,
                    onTap: () => _navTap(
                      ref,
                      context,
                      '/learn/ai?prefill=${Uri.encodeComponent(question)}',
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),

          // ── More ─────────────────────────────────────────────────────
          const SizedBox(height: AppSpacing.sectionGap - 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            child: SectionHead(label: 'More'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            child: _TutorRow(
              onTap: () => _navTap(ref, context, '/learn-ai/tutor'),
            ),
          ),
        ],
      ),
    );
  }

  /// Plan + quota line under the page title. Falls back to a plain description
  /// while the account loads, so the header never jumps or shows a spinner.
  static String _statusLine(bool isSignedIn, BackendAccountState account) {
    if (!isSignedIn) return 'Sign in to ask questions';

    final usage = account.usage.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    if (usage == null) return 'Ask questions about your textbooks';

    final plan = planLabel(
      account.user.maybeWhen(data: (u) => u?.planKey, orElse: () => null) ??
          'free',
    );
    if (usage.unlimited) return '$plan plan · Unlimited questions';
    if (usage.remaining <= 0) {
      return 'No questions left today — they refresh tomorrow';
    }
    final word = usage.remaining == 1 ? 'question' : 'questions';
    return '$plan plan · ${usage.remaining} $word left today';
  }

  static bool _isDark(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark;
}

/// Deep link back to the conversation a past question was asked in — its own
/// subject thread when it had one, otherwise the general chat.
String _resumePath(RecentQuestion question) {
  // Resume the conversation the question was asked in — don't seed the
  // composer with it. It's already asked and answered; re-typing it into the
  // input reads as if the tap did nothing.
  final subject = question.subject;
  if (subject == null) return '/learn/ai?resume=1';
  return '/learn/ai?resume=1&subject=${Uri.encodeComponent(subject)}';
}

/// Coarse "how long ago" label — minutes, hours, days, then weeks.
String _ago(DateTime then) {
  final diff = DateTime.now().difference(then);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago';
  }
  if (diff.inHours < 24) {
    return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
  }
  if (diff.inDays == 1) return 'yesterday';
  if (diff.inDays < 7) return '${diff.inDays} days ago';
  final weeks = diff.inDays ~/ 7;
  return '$weeks week${weeks == 1 ? '' : 's'} ago';
}

// ─── Recent question card (horizontal scroller item) ────────────────────

class _RecentQuestionCard extends StatelessWidget {
  final RecentQuestion question;
  final String board;
  final int classNo;
  final VoidCallback onTap;

  const _RecentQuestionCard({
    required this.question,
    required this.board,
    required this.classNo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subject = question.subject;
    final accent = subject == null
        ? cs.primary
        : AppColors.subjectColor(subject, Theme.of(context).brightness);

    return Pressable(
      onTap: onTap,
      scale: 0.97,
      child: Container(
        width: 208,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border.all(color: cs.outline),
          borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (subject == null
                      ? 'Any subject'
                      : formatSubject(subject, board: board, classNo: classNo))
                  .toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: accent,
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: Text(
                question.text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12.5,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _ago(question.askedAt),
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.ink3Dark : AppColors.ink3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Rows and tiles ─────────────────────────────────────────────────────

/// Bordered surface row: tinted tile + title + sub + chevron.
class _HubRow extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String sub;
  final VoidCallback onTap;

  const _HubRow({
    required this.color,
    required this.icon,
    required this.title,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.cardPad - 4,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border.all(color: cs.outline),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        child: Row(
          children: [
            Tile(color: color, icon: icon, size: 38, radius: 11),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontSize: 12.5),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: isDark ? AppColors.ink3Dark : AppColors.ink3,
            ),
          ],
        ),
      ),
    );
  }
}

/// One ingested subject, as a coloured tile. Seven pill chips wrapped into an
/// undifferentiated grey blob; a tile grid is scannable and matches Explore.
///
/// Uses [ClayCard] with the same depth as Home's mini-tool grid, so both tile
/// grids read as one surface — and both drop to flat cards together when
/// claymorphism is turned off in Settings → Appearance.
class _SubjectTile extends ConsumerWidget {
  final String subject;
  final String board;
  final int classNo;
  final VoidCallback onTap;

  const _SubjectTile({
    required this.subject,
    required this.board,
    required this.classNo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meta = subjectMeta(subject);
    final color = AppColors.subjectColor(
      subject,
      Theme.of(context).brightness,
    );

    return Pressable(
      onTap: onTap,
      scale: 0.96,
      child: ClayCard(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        radius: AppSpacing.tileRadius,
        blur: 11,
        distance: 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Tile(
              color: color,
              icon: meta.icon,
              meta: meta,
              size: 28,
              radius: 9,
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                formatSubject(subject, board: board, classNo: classNo),
                maxLines: 1,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A starter question — opens the chat with it already typed in.
class _StarterRow extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _StarterRow({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Pressable(
      onTap: onTap,
      scale: 0.98,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border.all(color: cs.outline),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 13.5),
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.north_east_rounded,
              size: 15,
              color: isDark ? AppColors.ink3Dark : AppColors.ink3,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tutor row ───────────────────────────────────────────────────────────

class _TutorRow extends StatelessWidget {
  final VoidCallback onTap;

  const _TutorRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.cTutorDark : AppColors.cTutor;
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.cardPad - 4,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border.all(color: cs.outline),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        child: Row(
          children: [
            Tile(
              color: accent,
              icon: Icons.school_rounded,
              size: 38,
              radius: 11,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'AI Tutor',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(fontSize: 15),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'Preview',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Step-by-step guided lessons, subject by subject',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontSize: 12.5),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: isDark ? AppColors.ink3Dark : AppColors.ink3,
            ),
          ],
        ),
      ),
    );
  }
}
