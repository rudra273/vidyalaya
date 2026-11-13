import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../data/avatars.dart';
import '../../data/seed/seed_data.dart' show boardLabel;
import '../../utils/haptics.dart';
import '../../providers/auth_provider.dart';
import '../../providers/avatar_provider.dart';
import '../../providers/games_progress_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/recent_questions_provider.dart';
import '../../providers/regional_language_provider.dart';
import '../../providers/rollout_switches_provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../widgets/ai_robot_mark.dart';
import '../../widgets/home_ai_chat.dart';
import '../../widgets/calm_widgets.dart';
import '../../widgets/pressable.dart';
import '../../widgets/share_feedback_banner.dart';
import '../../data/seed/vocabulary_data.dart';
import '../../data/seed/warmup_data.dart';
import '../../providers/user_selection_provider.dart';
import 'widgets/warmup_card.dart';

/// Haptic tap → navigate, the pattern every Home tile shares. Uses `push` by
/// default; pass [replace] for tabs that should swap the current route.
void _navTap(
  WidgetRef ref,
  BuildContext context,
  String path, {
  bool replace = false,
}) {
  Haptics.light(ref);
  if (replace) {
    context.go(path);
  } else {
    context.push(path);
  }
}

/// AI-first Home.
/// Greeting + notifications → streak week → AI card → interactive lessons
/// (coming soon) → study tools → word of the day → warm-up → share.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksEnabled = ref.watch(booksEnabledProvider);
    final streak = ref.watch(progressProvider).currentStreak;
    final dailyDone = ref.watch(gamesProgressProvider).dailyDoneToday;
    final unread = ref.watch(notificationsUnreadCountProvider);
    final classNo = ref.watch(primaryClassProvider);
    final board = ref.watch(userBoardProvider);
    final user = ref
        .watch(authStateProvider)
        .maybeWhen(data: (u) => u, orElse: () => null);

    final firstName = _firstName(user);
    final avatarLetter = (firstName.isNotEmpty ? firstName[0] : 'S')
        .toUpperCase();
    final lateNight = _isLateNight();

    // One warm-up a day, pitched at the lowest class the student has selected
    // (null = draw from the whole pool) so it never lands above their level.
    final selectedClasses = ref.watch(exploreClassSelectionProvider);
    final warmupQuestion = warmupForDate(
      DateTime.now(),
      classNo: selectedClasses.isEmpty
          ? null
          : (selectedClasses.toList()..sort()).first,
    );

    // The AI card offers to resume the latest question — but only while it's
    // fresh. A week-old "Continue" reads as stale, not helpful.
    final recents = ref.watch(recentQuestionsProvider);
    final lastQuestion =
        recents.isNotEmpty &&
            DateTime.now().difference(recents.first.askedAt) <
                const Duration(days: 7)
        ? recents.first
        : null;

    const pad = EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          // ── Greeting + notifications + avatar ───────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              18,
              AppSpacing.screenPadding,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_greeting()}, $firstName',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lateNight
                            ? 'Rest now. Study fresh tomorrow.'
                            : 'Class $classNo · ${boardLabel(board)}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _muted(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _BellButton(
                  unread: unread,
                  onTap: () => _navTap(ref, context, '/notifications'),
                ),
                const SizedBox(width: 8),
                _Avatar(
                  letter: avatarLetter,
                  avatar: ref.watch(selectedAvatarProvider),
                  onTap: () => _navTap(ref, context, '/profile', replace: true),
                ),
              ],
            ),
          ),

          // ── Streak week ──────────────────────────────────────────
          const SizedBox(height: 18),
          Padding(
            padding: pad,
            child: _StreakWeek(
              streak: streak,
              onTap: () => _navTap(ref, context, '/progress'),
            ),
          ),

          // ── AI card ──────────────────────────────────────────────
          const SizedBox(height: 14),
          Padding(
            padding: pad,
            child: HomeAiChat(
              mood: lateNight ? BotMood.resting : BotMood.idle,
              onChat: () => _navTap(ref, context, '/learn/ai?focus=1'),
              onCamera: () => _navTap(ref, context, '/learn/ai?camera=1'),
              resumeText: lastQuestion?.text,
              onResume: lastQuestion == null
                  ? null
                  : () => _navTap(
                      ref,
                      context,
                      recentQuestionResumePath(lastQuestion),
                    ),
            ),
          ),

          // ── Interactive lessons (placeholder) ────────────────────
          // Reserved for the upcoming interactive Maths / English / Science
          // lessons. Until they ship, the cards say so instead of linking.
          const SizedBox(height: AppSpacing.sectionGap),
          const Padding(
            padding: pad,
            child: _SectionTitle(title: 'Interactive lessons', tag: 'Soon'),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 132,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: pad,
              itemCount: _lessonPreviews.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) =>
                  _LessonPreviewCard(preview: _lessonPreviews[i]),
            ),
          ),

          // ── Study tools ──────────────────────────────────────────
          const SizedBox(height: AppSpacing.sectionGap),
          const Padding(padding: pad, child: _SectionTitle(title: 'Study tools')),
          const SizedBox(height: 12),
          SizedBox(
            height: 92,
            child: Builder(
              builder: (context) {
                final dark = _isDark(context);
                final tools = <_ToolItem>[
                  if (booksEnabled)
                    _ToolItem(
                      'Books',
                      Icons.menu_book_rounded,
                      dark ? AppColors.cAiDark : AppColors.cAi,
                      '/library',
                    ),
                  _ToolItem(
                    'Quizzes',
                    Icons.quiz_rounded,
                    dark ? AppColors.cEnglishDark : AppColors.cEnglish,
                    '/learn/quiz',
                  ),
                  _ToolItem(
                    'Notes',
                    Icons.edit_note_rounded,
                    dark ? AppColors.cSocialDark : AppColors.cSocial,
                    '/notes',
                  ),
                  _ToolItem(
                    'Timetable',
                    Icons.calendar_month_rounded,
                    dark ? AppColors.cScienceDark : AppColors.cScience,
                    '/timetable',
                  ),
                  if (booksEnabled)
                    _ToolItem(
                      'Bookmarks',
                      Icons.bookmark_rounded,
                      dark ? AppColors.cHindiDark : AppColors.cHindi,
                      '/bookmarks',
                    ),
                  _ToolItem(
                    'Vocabulary',
                    Icons.translate_rounded,
                    dark ? AppColors.cFormulasDark : AppColors.cFormulas,
                    '/learn/vocabulary',
                  ),
                  _ToolItem(
                    'Games',
                    Icons.extension_rounded,
                    dark ? AppColors.cMathsDark : AppColors.cMaths,
                    '/games',
                    // Dot until today's Daily Brain Challenge is done.
                    badge: !dailyDone,
                  ),
                ];
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: pad,
                  itemCount: tools.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 6),
                  itemBuilder: (context, i) => _ToolButton(
                    item: tools[i],
                    onTap: () => _navTap(ref, context, tools[i].route),
                  ),
                );
              },
            ),
          ),

          // ── Word of the day ──────────────────────────────────────
          const SizedBox(height: AppSpacing.sectionGap - 6),
          const Padding(padding: pad, child: _SectionTitle(title: 'Word of the day')),
          const SizedBox(height: 10),
          Padding(
            padding: pad,
            child: _WordOfDayCard(
              word: wordOfTheDay(),
              regionalLang: ref.watch(dictionaryDefaultLanguageProvider),
            ),
          ),

          // ── Today's warm-up ─────────────────────────────────────
          const SizedBox(height: AppSpacing.sectionGap),
          const Padding(padding: pad, child: _SectionTitle(title: "Today's warm-up")),
          const SizedBox(height: 10),
          Padding(
            padding: pad,
            child: WarmupCard(
              // Keyed by question id so the card resets its answered state when
              // the day rolls over while Home is still on screen.
              key: ValueKey(warmupQuestion.id),
              question: warmupQuestion,
            ),
          ),

          // ── Share & rate ─────────────────────────────────────────
          const SizedBox(height: AppSpacing.sectionGap),
          const Padding(padding: pad, child: ShareFeedbackBanner()),
        ],
      ),
    );
  }

  static String _firstName(User? user) {
    final dn = user?.displayName?.trim() ?? '';
    if (dn.isNotEmpty) return dn.split(' ').first;
    return 'Student';
  }

  /// Late at night (and pre-dawn) Home nudges the student to rest instead of
  /// pushing them to keep studying, and the bot rests too.
  static bool _isLateNight() {
    final h = DateTime.now().hour;
    return h >= 22 || h < 5;
  }

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h >= 22 || h < 5) return 'Good night';
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  static bool _isDark(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark;
}

Color _muted(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? AppColors.ink2Dark
    : AppColors.ink2;

// ─── Section title ──────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.tag});

  final String title;

  /// Small pill after the title, e.g. "Soon".
  final String? tag;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      header: true,
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: AppFontWeight.bold,
            ),
          ),
          if (tag != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: cs.secondary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                tag!,
                style: TextStyle(
                  fontSize: AppFontSize.small,
                  fontWeight: AppFontWeight.bold,
                  color: cs.onSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Notifications bell ─────────────────────────────────────────────────

class _BellButton extends StatelessWidget {
  const _BellButton({required this.unread, required this.onTap});

  final int unread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: unread > 0 ? 'Notifications, $unread new' : 'Notifications',
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        scale: 0.92,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: cs.surface, shape: BoxShape.circle),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.notifications_none_rounded, color: cs.onSurface),
              if (unread > 0)
                Positioned(
                  top: 10,
                  right: 11,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0884A),
                      shape: BoxShape.circle,
                      border: Border.all(color: cs.surface, width: 2),
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

// ─── Streak week ────────────────────────────────────────────────────────
// The current streak, with this week's days ticked: every day inside the
// streak (which always ends today, since opening the app records activity).

class _StreakWeek extends StatelessWidget {
  const _StreakWeek({required this.streak, required this.onTap});

  final int streak;
  final VoidCallback onTap;

  static const _flame = Color(0xFFF0884A);
  static const _flameInk = Color(0xFFA8501A);
  static const _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final today = DateTime.now();
    final todayIndex = today.weekday - 1; // Monday = 0
    final empty = dark ? AppColors.surface3Dark : AppColors.surface3;

    return Semantics(
      button: true,
      label: '$streak day streak. Open progress',
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        size: 20,
                        color: _flame,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$streak',
                        style: TextStyle(
                          fontSize: AppFontSize.headingSmall,
                          fontWeight: AppFontWeight.bold,
                          color: dark ? _flame : _flameInk,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'day streak',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _muted(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (var i = 0; i < 7; i++)
                      _day(
                        context,
                        label: _labels[i],
                        done: i <= todayIndex && todayIndex - i < streak,
                        isToday: i == todayIndex,
                        empty: empty,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _day(
    BuildContext context, {
    required String label,
    required bool done,
    required bool isToday,
    required Color empty,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: done ? _flame : empty,
            shape: BoxShape.circle,
            border: isToday && !done
                ? Border.all(color: _flame, width: 2)
                : null,
          ),
          child: done
              ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: AppFontSize.small,
            fontWeight: isToday ? AppFontWeight.bold : AppFontWeight.medium,
            color: isToday
                ? Theme.of(context).colorScheme.onSurface
                : _muted(context),
          ),
        ),
      ],
    );
  }
}

// ─── Interactive lesson previews ────────────────────────────────────────

class _LessonPreview {
  const _LessonPreview(this.subject, this.glyph, this.light, this.dark);
  final String subject;
  final String glyph;
  final Color light;
  final Color dark;
}

const _lessonPreviews = [
  _LessonPreview('Maths', 'π', AppColors.cMaths, AppColors.cMathsDark),
  _LessonPreview('English', 'Aa', AppColors.cEnglish, AppColors.cEnglishDark),
  _LessonPreview(
    'Science',
    'H₂O',
    AppColors.cScience,
    AppColors.cScienceDark,
  ),
];

class _LessonPreviewCard extends StatelessWidget {
  const _LessonPreviewCard({required this.preview});

  final _LessonPreview preview;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final hue = dark ? preview.dark : preview.light;
    return Semantics(
      button: true,
      label: 'Interactive ${preview.subject} lessons, coming soon',
      excludeSemantics: true,
      child: Pressable(
        onTap: () {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  'Interactive ${preview.subject} lessons are coming soon.',
                ),
              ),
            );
        },
        child: Container(
          width: 150,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(
              color: dark ? AppColors.surface3Dark : AppColors.hairline,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color.alphaBlend(
                    hue.withValues(alpha: dark ? 0.2 : 0.14),
                    cs.surface,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  preview.glyph,
                  style: TextStyle(
                    fontFamily: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.fontFamily,
                    fontSize: preview.glyph.length > 2 ? 14 : 19,
                    fontWeight: AppFontWeight.semibold,
                    color: hue,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                preview.subject,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 2),
              Text(
                'Coming soon',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _muted(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Study tool button (horizontal row) ─────────────────────────────────

class _ToolItem {
  const _ToolItem(
    this.label,
    this.icon,
    this.color,
    this.route, {
    this.badge = false,
  });
  final String label;
  final IconData icon;
  final Color color;
  final String route;
  final bool badge;
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({required this.item, required this.onTap});

  final _ToolItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      button: true,
      label: item.label,
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        child: SizedBox(
          width: 76,
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Color.alphaBlend(
                        item.color.withValues(alpha: dark ? 0.18 : 0.13),
                        cs.surface,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(item.icon, size: 26, color: item.color),
                  ),
                  if (item.badge)
                    Positioned(
                      right: -1,
                      top: -1,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          // A fixed alert red: a dot in the tile's own hue
                          // vanished against its tinted background.
                          color: AppColors.badge,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: AppFontWeight.semibold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String letter;
  final StudentAvatar? avatar;
  final VoidCallback onTap;

  const _Avatar({required this.letter, this.avatar, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      button: true,
      label: 'Profile',
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        scale: 0.92,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              cs.primary.withValues(alpha: isDark ? 0.18 : 0.12),
              cs.surface,
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? AppColors.green100Dark : AppColors.green100,
            ),
          ),
          alignment: Alignment.center,
          child: avatar != null
              ? ClipOval(
                  child: SvgPicture.asset(
                    avatar!.assetPath,
                    width: 42,
                    height: 42,
                  ),
                )
              : Text(
                  letter,
                  style: TextStyle(
                    fontFamily: Theme.of(
                      context,
                    ).textTheme.displaySmall?.fontFamily,
                    fontSize: AppFontSize.content,
                    fontWeight: AppFontWeight.semibold,
                    color: cs.primary,
                  ),
                ),
        ),
      ),
    );
  }
}

// ─── Word of the day card ───────────────────────────────────────────────

class _WordOfDayCard extends StatelessWidget {
  final VocabularyWord word;
  final RegionalLanguage regionalLang;

  const _WordOfDayCard({required this.word, required this.regionalLang});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.cEnglishDark : AppColors.cEnglish;
    final muted = isDark ? AppColors.ink2Dark : AppColors.ink2;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPad - 2),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Word + part of speech
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Tile(
                color: accent,
                icon: Icons.menu_book_rounded,
                size: 38,
                radius: 11,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      word.word,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontSize: AppFontSize.headingSmall,
                            height: 1.05,
                          ),
                    ),
                    const SizedBox(height: 2),
                    // Upright respelling (its capitals mark the stressed
                    // syllable, which italics made hard to read); only the
                    // part of speech is italic, dictionary-style.
                    Text.rich(
                      TextSpan(
                        text: '/${word.pronunciation}/ · ',
                        children: [
                          TextSpan(
                            text: word.partOfSpeech,
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: AppFontSize.small,
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ),
              // Shortcut into the full vocabulary list — the card is a teaser
              // for it, so the jump lives right next to the word.
              Pressable(
                onTap: () => context.push('/learn/vocabulary'),
                scale: 0.94,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'More',
                        style: TextStyle(
                          fontSize: AppFontSize.small,
                          fontWeight: AppFontWeight.bold,
                          color: accent,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 13,
                        color: accent,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Both meanings on one line each, no label eyebrows — the card is
          // ambient content, so it stays short next to the taller AI hero.
          Text(
            word.meaningEn,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.35),
          ),
          const SizedBox(height: 4),
          Text(
            word.regionalMeaning(regionalLang),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.35, color: muted),
          ),

          const SizedBox(height: 10),

          // Example sentence with the word emphasised
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.format_quote_rounded, size: 15, color: accent),
              const SizedBox(width: 7),
              Expanded(
                child: _ExampleSentence(
                  sentence: word.sentence,
                  word: word.word,
                  accent: accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The example sentence, with the day's word shown in bold + accent colour.
class _ExampleSentence extends StatelessWidget {
  final String sentence;
  final String word;
  final Color accent;

  const _ExampleSentence({
    required this.sentence,
    required this.word,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.bodySmall?.copyWith(
      fontSize: AppFontSize.body,
      height: 1.45,
      fontStyle: FontStyle.italic,
    );
    final lower = sentence.toLowerCase();
    final idx = lower.indexOf(word.toLowerCase());

    if (idx < 0) {
      return Text(sentence, style: base);
    }

    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: sentence.substring(0, idx)),
          TextSpan(
            text: sentence.substring(idx, idx + word.length),
            style: TextStyle(
              fontWeight: AppFontWeight.bold,
              color: accent,
              fontStyle: FontStyle.italic,
            ),
          ),
          TextSpan(text: sentence.substring(idx + word.length)),
        ],
      ),
    );
  }
}
