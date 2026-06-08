import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../providers/reading_provider.dart';
import '../../providers/books_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/core_providers.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/calm_widgets.dart';
import '../../widgets/clay_card.dart';
import '../../data/models/book.dart';

/// AI-first Home — "Calm Scholar" layout.
/// Wordmark → AI Learning (Ask hero + Tutor row + future agents teaser) →
/// Jump back in → Study tools → Recently added.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastReadBook = ref.watch(readingProvider);
    final books = ref.watch(selectedBooksProvider);
    final booksEnabled = ref.watch(booksEnabledProvider);
    final streak = ref.watch(progressProvider).currentStreak;
    final user = ref.watch(authStateProvider).maybeWhen(
          data: (u) => u,
          orElse: () => null,
        );

    final firstName = _firstName(user);
    final avatarLetter = (firstName.isNotEmpty ? firstName[0] : 'S')
        .toUpperCase();

    final showContinueReading = booksEnabled && lastReadBook != null;
    final showRecentlyAdded = booksEnabled && books.isNotEmpty;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          // ── top bar: wordmark + streak + avatar ─────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              12,
              AppSpacing.screenPadding,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'Vidyālaya',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ),
                    if (streak > 0) ...[
                      _StreakChip(streak: streak,
                          onTap: () => context.push('/progress')),
                      const SizedBox(width: 12),
                    ],
                    _Avatar(
                      letter: avatarLetter,
                      onTap: () => context.go('/profile'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '${_greeting()}, $firstName — let\'s keep learning.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.ink2Dark
                            : AppColors.ink2,
                      ),
                ),
              ],
            ),
          ),

          // ── AI Learning section ─────────────────────────────────
          const SizedBox(height: AppSpacing.sectionGap),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            child: SectionHead(label: 'AI Learning'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding),
            child: _AskHero(onTap: () => context.push('/learn/ai')),
          ),
          const SizedBox(height: AppSpacing.stackGap),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding),
            child: _TutorRow(onTap: () => context.push('/learn-ai/tutor')),
          ),
          const SizedBox(height: AppSpacing.stackGap),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            child: _FutureAgentsRow(),
          ),

          // ── Jump back in (reading, demoted) ─────────────────────
          if (showContinueReading) ...[
            const SizedBox(height: AppSpacing.sectionGap),
            const Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              child: SectionHead(label: 'Jump back in'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              child: _ContinueCard(book: lastReadBook),
            ),
          ],

          // ── Study tools ──────────────────────────────────────────
          const SizedBox(height: AppSpacing.sectionGap),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            child: SectionHead(label: 'Study tools'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding),
            child: Row(
              children: [
                Expanded(
                  child: _MiniTool(
                    color: _isDark(context)
                        ? AppColors.cAiDark
                        : AppColors.cAi,
                    icon: Icons.bookmark_rounded,
                    label: 'Bookmarks',
                    sub: 'Saved',
                    onTap: () => context.push('/bookmarks'),
                  ),
                ),
                const SizedBox(width: AppSpacing.stackGap),
                Expanded(
                  child: _MiniTool(
                    color: _isDark(context)
                        ? AppColors.cEnglishDark
                        : AppColors.cEnglish,
                    icon: Icons.calendar_month_rounded,
                    label: 'Timetable',
                    sub: 'Classes',
                    onTap: () => context.push('/timetable'),
                  ),
                ),
                const SizedBox(width: AppSpacing.stackGap),
                Expanded(
                  child: _MiniTool(
                    color: _isDark(context)
                        ? AppColors.cSocialDark
                        : AppColors.cSocial,
                    icon: Icons.edit_note_rounded,
                    label: 'Notes',
                    sub: 'Highlights',
                    onTap: () => context.push('/notes'),
                  ),
                ),
              ],
            ),
          ),

          // ── Recently added ───────────────────────────────────────
          if (showRecentlyAdded) ...[
            const SizedBox(height: AppSpacing.sectionGap),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              child: SectionHead(
                label: 'Recently added',
                action: 'See all',
                onAction: () => context.go('/library'),
              ),
            ),
            SizedBox(
              height: 196,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding),
                itemCount: books.length > 8 ? 8 : books.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.stackGap),
                itemBuilder: (context, index) {
                  final book = books[index];
                  return _RecentBookCard(book: book);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _firstName(User? user) {
    final dn = user?.displayName?.trim() ?? '';
    if (dn.isNotEmpty) return dn.split(' ').first;
    return 'Student';
  }

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  static bool _isDark(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark;
}

// ─── Streak chip (uses maths/coral hue per design) ──────────────────────

class _StreakChip extends StatelessWidget {
  final int streak;
  final VoidCallback onTap;

  const _StreakChip({required this.streak, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final accent = isDark ? AppColors.cMathsDark : AppColors.cMaths;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(9, 6, 12, 6),
        decoration: BoxDecoration(
          color: Color.alphaBlend(accent.withValues(alpha: 0.12), cs.surface),
          border: Border.all(color: accent.withValues(alpha: 0.26)),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_fire_department_rounded,
                size: 17, color: accent),
            const SizedBox(width: 5),
            Text(
              '$streak',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String letter;
  final VoidCallback onTap;

  const _Avatar({required this.letter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
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
        child: Text(
          letter,
          style: TextStyle(
            fontFamily: Theme.of(context)
                .textTheme
                .displaySmall
                ?.fontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: cs.primary,
          ),
        ),
      ),
    );
  }
}

// ─── Ask hero: dark green gradient card ─────────────────────────────────

class _AskHero extends StatelessWidget {
  final VoidCallback onTap;

  const _AskHero({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final heroColor = isDark ? AppColors.heroDark : AppColors.hero;
    final hero2 = isDark ? AppColors.hero2Dark : AppColors.hero2;
    final accent =
        isDark ? AppColors.green500Dark : AppColors.green500;
    const inkLight = AppColors.heroInk;
    final inkMuted = AppColors.heroInk.withValues(alpha: 0.62);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPad + 4),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.95, -0.8),
            radius: 1.3,
            colors: [hero2, heroColor],
          ),
          border: Border.all(
            color: isDark
                ? AppColors.heroLineDark
                : AppColors.heroLine,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // faint glyph
            Positioned(
              right: -22,
              top: -20,
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 150,
                color: accent.withValues(alpha: 0.16),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // top row
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(Icons.auto_awesome_rounded,
                          size: 18, color: accent),
                    ),
                    const SizedBox(width: 9),
                    Text(
                      'Q&A',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: inkMuted,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Live',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: accent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Ask anything from your textbooks.',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: inkLight,
                      ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Answers grounded in your SCERT books — with citations back to the page.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: inkMuted,
                      ),
                ),
                const SizedBox(height: 16),
                // faux input bar
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Ask a question…',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.heroInk.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.green600,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(Icons.arrow_forward_rounded,
                            size: 19, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // suggestion chips
                SizedBox(
                  height: 30,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final c in const [
                        'Explain photosynthesis',
                        'Solve 2x + 3 = 7',
                        'Summarise Chapter 4',
                      ])
                        Padding(
                          padding: const EdgeInsets.only(right: 7),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    Colors.white.withValues(alpha: 0.16),
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              c,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: inkMuted,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPad),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border.all(color: cs.outline),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        child: Row(
          children: [
            Tile(color: accent, icon: Icons.school_rounded, size: 48, radius: 14),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'AI Tutor',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontSize: 18,
                                ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Color.alphaBlend(
                            accent.withValues(alpha: 0.15),
                            cs.surface,
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'PREVIEW',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Step-by-step guided lessons, subject by subject',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 13.5,
                        ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 19,
                color: isDark ? AppColors.ink3Dark : AppColors.ink3),
          ],
        ),
      ),
    );
  }
}

// ─── Future agents teaser: low-key dashed-border row ────────────────────

class _FutureAgentsRow extends StatelessWidget {
  const _FutureAgentsRow();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final accent = isDark ? AppColors.cScienceDark : AppColors.cScience;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.cardPad, vertical: 13),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          cs.onSurface.withValues(alpha: 0.025),
          cs.surface,
        ),
        border: Border.all(
          color: isDark ? AppColors.hairlineDark : AppColors.hairline,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Row(
        children: [
          Tile(color: accent, icon: Icons.dashboard_customize_rounded,
              size: 40, radius: 11),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'More AI agents on the way',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.ink2Dark
                            : AppColors.ink2,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Built to grow — new tutors & helpers over time',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12.5,
                      ),
                ),
              ],
            ),
          ),
          Icon(Icons.lock_outline_rounded,
              size: 17,
              color: isDark ? AppColors.ink3Dark : AppColors.ink3),
        ],
      ),
    );
  }
}

// ─── Continue reading card ──────────────────────────────────────────────

class _ContinueCard extends StatelessWidget {
  final Book book;

  const _ContinueCard({required this.book});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final subjectColor = AppColors.subjectColor(book.subject, brightness);

    return GestureDetector(
      onTap: () => context.push('/reader/${book.id}'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPad),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border.all(color: cs.outline),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CONTINUE READING',
                    style: kEyebrow(context).copyWith(color: subjectColor),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    book.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 21,
                          height: 1.1,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Class ${book.classNumber} · ${_capitalize(book.subject)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                        ),
                  ),
                  const SizedBox(height: 13),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: 0.42,
                      minHeight: 5,
                      backgroundColor: brightness == Brightness.dark
                          ? AppColors.surface3Dark
                          : AppColors.surface3,
                      valueColor: AlwaysStoppedAnimation(subjectColor),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Page 38 of 92 · 42%',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 86,
              height: 110,
              child: BookCover(subjectKey: book.subject, big: false),
            ),
          ],
        ),
      ),
    );
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ─── Mini tool tile (3-column grid) ─────────────────────────────────────

class _MiniTool extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final String sub;
  final VoidCallback onTap;

  const _MiniTool({
    required this.color,
    required this.icon,
    required this.label,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClayCard(
        padding: const EdgeInsets.all(AppSpacing.tilePad),
        blur: 13,
        distance: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Tile(color: color, icon: icon, size: 38, radius: 11),
            const SizedBox(height: 10),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 1),
            Text(
              sub,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Recently added book card (horizontal scroller item) ───────────────

class _RecentBookCard extends StatelessWidget {
  final Book book;

  const _RecentBookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    final meta = subjectMeta(book.subject);
    return GestureDetector(
      onTap: () => context.push('/reader/${book.id}'),
      child: SizedBox(
        width: 124,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 154,
              child:
                  BookCover(subjectKey: book.subject, title: book.title),
            ),
            const SizedBox(height: 7),
            Text(
              meta.label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.ink2Dark
                        : AppColors.ink2,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
