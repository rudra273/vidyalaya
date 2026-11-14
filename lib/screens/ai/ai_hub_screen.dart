import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ingested_books_provider.dart';
import '../../providers/learn_assist_provider.dart';
import '../../providers/recent_questions_provider.dart';
import '../../providers/user_selection_provider.dart';
import '../../utils/ai_labels.dart';
import '../../utils/haptics.dart';
import '../../widgets/ai_robot_mark.dart';
import '../../widgets/agent_mark.dart';
import '../../widgets/calm_widgets.dart';
import '../../widgets/chunky_button.dart';
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
/// Pick up where you left off → Ask about a subject → Learn with a teacher
/// (the AI agents, coming soon). Plain asking lives on the Ask tab, so there is no
/// question field here.
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

    final brightness = Theme.of(context).brightness;

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

          // ── Pick up where you left off ───────────────────────────────
          // The latest chat, one tap away. With nothing asked yet the same
          // card invites a first question instead.
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            child: recents.isEmpty
                ? _ContinueCard(
                    mood: _outOfQuestions(account)
                        ? BotMood.resting
                        : BotMood.idle,
                    eyebrow: 'Learn Assist',
                    title: 'Ask anything from your books',
                    action: 'Ask a question',
                    onTap: () {
                      Haptics.light(ref);
                      context.go('/ask');
                    },
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SectionHead(
                        label: 'Pick up where you left off',
                        action: 'All chats',
                        onAction: () {
                          Haptics.light(ref);
                          context.go('/ask');
                        },
                      ),
                      _ContinueCard(
                        mood: _outOfQuestions(account)
                            ? BotMood.resting
                            : BotMood.idle,
                        eyebrow:
                            '${recents.first.subject == null ? 'All subjects' : formatSubject(recents.first.subject!, board: board, classNo: classNo)}'
                            ' · ${_ago(recents.first.askedAt)}',
                        title: recents.first.text,
                        action: 'Continue this chat',
                        onTap: () => _navTap(
                          ref,
                          context,
                          recentQuestionResumePath(recents.first),
                        ),
                      ),
                    ],
                  ),
          ),

          // ── Ask about a subject ──────────────────────────────────────
          if (subjects.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sectionGap),
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: SectionHead(label: 'Ask about a subject'),
            ),
            for (final group in _groupSubjects(subjects))
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  0,
                  AppSpacing.screenPadding,
                  14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.$1,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: AppFontWeight.semibold,
                        color: brightness == Brightness.dark
                            ? AppColors.ink2Dark
                            : AppColors.ink2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final subject in group.$2)
                          _SubjectChip(
                            subject: subject,
                            label: formatSubject(
                              subject,
                              board: board,
                              classNo: classNo,
                            ),
                            onTap: () => _navTap(
                              ref,
                              context,
                              '/learn/ai?subject='
                              '${Uri.encodeComponent(subject)}&focus=1',
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
          // ── Learn with a teacher ─────────────────────────────────────
          // The AI agents, all still on their way, so the section sits at the
          // bottom of the page until they open.
          const SizedBox(height: AppSpacing.sectionGap),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            child: SectionHead(label: 'Learn with a teacher'),
          ),
          SizedBox(
            height: 148,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              children: [
                _AgentCard(
                  agent: AiAgent.tutor,
                  title: 'AI Tutor',
                  sub: 'Teaches any subject',
                  soon: true,
                  onTap: () => _comingSoon(ref, context, 'AI Tutor'),
                ),
                const SizedBox(width: 10),
                _AgentCard(
                  agent: AiAgent.maths,
                  title: 'Learn Maths',
                  sub: 'Maths you work out by doing',
                  soon: true,
                  onTap: () => _comingSoon(ref, context, 'Learn Maths'),
                ),
                const SizedBox(width: 10),
                _AgentCard(
                  agent: AiAgent.english,
                  title: 'Learn English',
                  sub: 'Speak, read and write',
                  soon: true,
                  onTap: () => _comingSoon(ref, context, 'Learn English'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void _comingSoon(WidgetRef ref, BuildContext context, String name) {
    Haptics.light(ref);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$name is coming soon.')));
  }

  /// Subjects in their families, in a fixed order, so fourteen chips read as
  /// three short groups instead of one long run.
  static List<(String, List<String>)> _groupSubjects(List<String> subjects) {
    const languages = {'english', 'hindi', 'odia', 'sanskrit'};
    const mathsScience = {'maths', 'math', 'science'};
    const social = {'social', 'social_science'};
    final groups = <String, List<String>>{
      'Languages': [],
      'Maths and Science': [],
      'Social Science': [],
      'More': [],
    };
    for (final subject in subjects) {
      final family = canonicalSubjectKey(subject);
      final name = languages.contains(family)
          ? 'Languages'
          : mathsScience.contains(family)
          ? 'Maths and Science'
          : social.contains(family)
          ? 'Social Science'
          : 'More';
      groups[name]!.add(subject);
    }
    return [
      for (final entry in groups.entries)
        if (entry.value.isNotEmpty) (entry.key, entry.value),
    ];
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
    // The pill shows the count (tap it for when they refresh).
    return null;
  }

  static bool _outOfQuestions(BackendAccountState account) {
    final usage = account.usage.maybeWhen(data: (v) => v, orElse: () => null);
    return usage != null && !usage.unlimited && usage.remaining <= 0;
  }
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

// ─── Continue card ──────────────────────────────────────────────────────

/// The Learn Assist bot, the last question (or an invitation to ask the
/// first), and one button.
class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
    required this.mood,
    required this.eyebrow,
    required this.title,
    required this.action,
    required this.onTap,
  });

  final BotMood mood;
  final String eyebrow;
  final String title;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(24),
        border: isDark ? null : Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AiBot(size: 48, mood: mood),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: AppFontWeight.semibold,
                        color: isDark ? AppColors.ink2Dark : AppColors.ink2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        height: 1.3,
                        fontWeight: AppFontWeight.semibold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ChunkyButton(label: action, height: 52, onPressed: onTap),
        ],
      ),
    );
  }
}

// ─── Agent card ─────────────────────────────────────────────────────────

/// One AI teacher: its face, name and a line on what it does, on a soft card
/// in its own colour. [soon] marks one that isn't open yet.
class _AgentCard extends StatelessWidget {
  const _AgentCard({
    required this.agent,
    required this.title,
    required this.sub,
    required this.onTap,
    this.soon = false,
  });

  final AiAgent agent;
  final String title;
  final String sub;
  final bool soon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final b = theme.brightness;
    final isDark = b == Brightness.dark;
    return Semantics(
      button: true,
      label: soon ? '$title, coming soon' : '$title. $sub',
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        scale: 0.97,
        child: Container(
          width: 132,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: agent.tint(b),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AgentMark(agent: agent, size: 44),
                  const Spacer(),
                  if (soon)
                    Container(
                      height: 22,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surface3Dark
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Soon',
                        style: TextStyle(
                          fontSize: AppFontSize.small,
                          fontWeight: AppFontWeight.bold,
                          color: isDark ? AppColors.ink2Dark : AppColors.ink2,
                        ),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: AppFontSize.content,
                  fontWeight: AppFontWeight.bold,
                  color: agent.ink(b),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                sub,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  height: 1.3,
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

// ─── Subject chip ───────────────────────────────────────────────────────

/// One subject the chat can open: its glyph in a tinted circle, then its name.
class _SubjectChip extends StatelessWidget {
  const _SubjectChip({
    required this.subject,
    required this.label,
    required this.onTap,
  });

  final String subject;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final meta = subjectMeta(subject);
    return Material(
      color: cs.surface,
      shape: StadiumBorder(
        side: isDark ? BorderSide.none : BorderSide(color: cs.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Tile(
                color: AppColors.subjectColor(subject, theme.brightness),
                icon: meta.icon,
                meta: meta,
                size: 32,
                radius: 16,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: AppFontWeight.semibold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Plan pill ──────────────────────────────────────────────────────────
// "49 left today" beside the title, worded as on the Ask tab. Tapping it says when questions refresh.

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
    final label = usage.unlimited ? plan : '${usage.remaining} left today';
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
