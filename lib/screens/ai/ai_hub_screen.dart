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
import '../../widgets/ai_robot_mark.dart';
import '../../widgets/ask_card.dart';
import '../../widgets/calm_widgets.dart';
import '../../widgets/surface_card.dart';
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
      cache.ensureProfile();
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSignedIn = ref
        .watch(authStateProvider)
        .maybeWhen(data: (user) => user != null, orElse: () => false);
    final account = ref.watch(backendAccountCacheProvider);
    if (isSignedIn &&
        (!account.userLoaded ||
            !account.usageLoaded ||
            !account.profileLoaded)) {
      _ensureAccountSummary(ref);
    }

    // Same board/class the chat resolves to, so the subjects offered here are
    // exactly the conversations the chat can open.
    final classNo = ref.watch(primaryClassProvider);
    final board = ref.watch(userBoardProvider);
    final subjects = learnAssistSubjects(
      ref.watch(activeIngestedBooksProvider),
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
            trailing: _PlanPill(account: account, isSignedIn: isSignedIn),
          ),
          const SizedBox(height: AppSpacing.sectionGap - 14),

          // ── Ask ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            child: AiAskHero(
              headline: 'What shall we work on today?',
              sub: 'Answers in English, Odia or Hindi.',
              mood: _outOfQuestions(account) ? BotMood.resting : BotMood.idle,
              onAsk: (style) =>
                  _navTap(ref, context, '/learn/ai?focus=1&style=${style.key}'),
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
              height: 116,
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
                    onTap: () => _navTap(
                      ref,
                      context,
                      recentQuestionResumePath(question),
                    ),
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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  // Fixed height fits the glyph and a two-line name such as
                  // "Geography & Economics" at any width.
                  mainAxisExtent: 108,
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
  static String? _statusLine(bool isSignedIn, BackendAccountState account) {
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
    final refresh = refreshPhrase(usage.resetsAt);
    if (usage.remaining <= 0) {
      return 'No questions left today. They refresh $refresh.';
    }
    // The pill shows the count; the line only adds when it refreshes.
    return 'Questions refresh $refresh';
  }

  static bool _outOfQuestions(BackendAccountState account) {
    final usage = account.usage.maybeWhen(data: (v) => v, orElse: () => null);
    return usage != null && !usage.unlimited && usage.remaining <= 0;
  }

  static bool _isDark(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark;
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
      child: SizedBox(
        width: 250,
        child: SurfaceCard(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          radius: 18,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (subject == null
                        ? 'Any subject'
                        : formatSubject(
                            subject,
                            board: board,
                            classNo: classNo,
                          ))
                    .toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppFontSize.small,
                  fontWeight: AppFontWeight.bold,
                  letterSpacing: 0.5,
                  color: accent,
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  question.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.35,
                    fontWeight: AppFontWeight.medium,
                  ),
                ),
              ),
              Text(
                _ago(question.askedAt),
                style: TextStyle(
                  fontSize: AppFontSize.small + 1,
                  color: isDark ? AppColors.ink2Dark : AppColors.ink2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Rows and tiles ─────────────────────────────────────────────────────

/// Surface row: tinted tile + title + sub + chevron.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Pressable(
      onTap: onTap,
      child: SurfaceCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.cardPad - 4,
          vertical: 12,
        ),
        radius: AppSpacing.cardRadius,
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: AppFontSize.content,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: AppFontSize.small,
                    ),
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
/// A [SurfaceCard] like Explore's tool cards, so the two grids match.
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
    final color = AppColors.subjectColor(subject, Theme.of(context).brightness);

    return Pressable(
      onTap: onTap,
      scale: 0.96,
      child: SurfaceCard(
        padding: const EdgeInsets.fromLTRB(8, 14, 8, 10),
        radius: 18,
        child: Column(
          children: [
            Tile(
              color: color,
              icon: meta.icon,
              meta: meta,
              size: 44,
              radius: 14,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                formatSubject(subject, board: board, classNo: classNo),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: AppFontSize.small + 1,
                  height: 1.2,
                  fontWeight: AppFontWeight.semibold,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Pressable(
      onTap: onTap,
      scale: 0.98,
      child: SurfaceCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        radius: 16,
        child: Row(
          children: [
            Expanded(
              child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.cTutorDark : AppColors.cTutor;
    return Pressable(
      onTap: onTap,
      child: SurfaceCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.cardPad - 4,
          vertical: 12,
        ),
        radius: AppSpacing.cardRadius,
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
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontSize: AppFontSize.content),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'Preview',
                        style: TextStyle(
                          fontSize: AppFontSize.caption,
                          fontWeight: AppFontWeight.semibold,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Step-by-step guided lessons, subject by subject',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: AppFontSize.small,
                    ),
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

// ─── Plan pill ──────────────────────────────────────────────────────────
// "Plus · 49 left" beside the title. Tapping it says when questions refresh.

class _PlanPill extends StatelessWidget {
  const _PlanPill({required this.account, required this.isSignedIn});

  final BackendAccountState account;
  final bool isSignedIn;

  @override
  Widget build(BuildContext context) {
    if (!isSignedIn) return const SizedBox.shrink();
    final usage = account.usage.maybeWhen(data: (v) => v, orElse: () => null);
    if (usage == null) return const SizedBox.shrink();
    final dark = Theme.of(context).brightness == Brightness.dark;
    final plan = planLabel(
      account.user.maybeWhen(data: (u) => u?.planKey, orElse: () => null) ??
          'free',
    );
    final label = usage.unlimited ? plan : '$plan · ${usage.remaining} left';
    final ink = dark ? AppColors.green500Dark : AppColors.green700;
    return Tooltip(
      message: usage.unlimited
          ? 'Unlimited questions'
          : 'Questions refresh ${refreshPhrase(usage.resetsAt)}',
      triggerMode: TooltipTriggerMode.tap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: dark ? AppColors.green100Dark : AppColors.green100,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_rounded, size: 15, color: ink),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: AppFontSize.small + 1,
                fontWeight: AppFontWeight.semibold,
                color: ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
