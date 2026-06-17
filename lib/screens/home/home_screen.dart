import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../data/avatars.dart';
import '../../providers/reading_provider.dart';
import '../../providers/books_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/avatar_provider.dart';
import '../../providers/core_providers.dart';
import '../../providers/progress_provider.dart';
import '../../providers/regional_language_provider.dart';
import '../../widgets/calm_widgets.dart';
import '../../widgets/clay_card.dart';
import '../../widgets/pressable.dart';
import '../../data/models/book.dart';
import '../../data/seed/vocabulary_data.dart';

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
    final user = ref
        .watch(authStateProvider)
        .maybeWhen(data: (u) => u, orElse: () => null);

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
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(fontSize: 23),
                      ),
                    ),
                    if (streak > 0) ...[
                      _StreakChip(
                        streak: streak,
                        onTap: () => context.push('/progress'),
                      ),
                      const SizedBox(width: 12),
                    ],
                    _Avatar(
                      letter: avatarLetter,
                      avatar: ref.watch(selectedAvatarProvider),
                      onTap: () => context.go('/profile'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _greetingLine(firstName),
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
              horizontal: AppSpacing.screenPadding,
            ),
            child: _AskHero(
              onTap: () => context.push('/learn/ai'),
              onAsk: () => context.push('/learn/ai?focus=1'),
            ),
          ),
          const SizedBox(height: AppSpacing.stackGap),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            child: _TutorRow(onTap: () => context.push('/learn-ai/tutor')),
          ),

          // ── Word of the day ──────────────────────────────────────
          const SizedBox(height: AppSpacing.sectionGap),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            child: SectionHead(label: 'Word of the day'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            child: _WordOfDayCard(
              word: wordOfTheDay(),
              regionalLang: ref.watch(regionalLanguageProvider),
            ),
          ),

          // ── Jump back in (reading, demoted) ─────────────────────
          if (showContinueReading) ...[
            const SizedBox(height: AppSpacing.sectionGap),
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: SectionHead(label: 'Jump back in'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: _ContinueCard(
                book: lastReadBook,
                lastPage: ref
                    .read(userPrefsRepositoryProvider)
                    .getLastReadPage(lastReadBook.id),
              ),
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
              horizontal: AppSpacing.screenPadding,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _MiniTool(
                    color: _isDark(context) ? AppColors.cAiDark : AppColors.cAi,
                    icon: Icons.bookmark_rounded,
                    label: 'Bookmarks',
                    onTap: () => context.push('/bookmarks'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MiniTool(
                    color: _isDark(context)
                        ? AppColors.cEnglishDark
                        : AppColors.cEnglish,
                    icon: Icons.calendar_month_rounded,
                    label: 'Timetable',
                    onTap: () => context.push('/timetable'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MiniTool(
                    color: _isDark(context)
                        ? AppColors.cSocialDark
                        : AppColors.cSocial,
                    icon: Icons.edit_note_rounded,
                    label: 'Notes',
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
                horizontal: AppSpacing.screenPadding,
              ),
              child: SectionHead(
                label: 'Recently added',
                action: 'See all',
                onAction: () => context.go('/library'),
              ),
            ),
            SizedBox(
              height: 168,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
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

  /// Full greeting line, time-of-day aware. Late at night (and pre-dawn) we
  /// nudge the student to rest instead of pushing them to keep studying.
  static String _greetingLine(String firstName) {
    final h = DateTime.now().hour;
    if (h >= 22 || h < 5) {
      return 'Good night, $firstName — time to rest, study fresh tomorrow.';
    }
    return '${_greeting()}, $firstName — let\'s keep learning.';
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
            Icon(Icons.local_fire_department_rounded, size: 17, color: accent),
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
  final StudentAvatar? avatar;
  final VoidCallback onTap;

  const _Avatar({required this.letter, this.avatar, required this.onTap});

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
        child: avatar != null
            ? ClipOval(
                child: SvgPicture.asset(
                  avatar!.assetPath,
                  width: 38,
                  height: 38,
                ),
              )
            : Text(
                letter,
                style: TextStyle(
                  fontFamily:
                      Theme.of(context).textTheme.displaySmall?.fontFamily,
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

  /// Open Q&A with the composer focused (keyboard up) — used by the Ask bar so
  /// tapping a thing that looks like an input lands ready to type.
  final VoidCallback onAsk;

  const _AskHero({required this.onTap, required this.onAsk});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final heroColor = isDark ? AppColors.heroDark : AppColors.hero;
    final hero2 = isDark ? AppColors.hero2Dark : AppColors.hero2;
    final accent = isDark ? AppColors.green500Dark : AppColors.green500;
    const inkLight = AppColors.heroInk;
    final inkMuted = AppColors.heroInk.withValues(alpha: 0.62);

    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPad - 2),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.95, -0.8),
            radius: 1.3,
            colors: [hero2, heroColor],
          ),
          border: Border.all(
            color: isDark ? AppColors.heroLineDark : AppColors.heroLine,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome_rounded, size: 15, color: accent),
                const SizedBox(width: 7),
                Text(
                  'Q&A',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: inkMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Ask anything from your textbooks.',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: inkLight),
            ),
            const SizedBox(height: 5),
            Text(
              'Clear, simple answers — type a question or snap a photo of it.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: inkMuted,
              ),
            ),
            const SizedBox(height: 14),
            // faux input bar — taps open Q&A with the keyboard already up
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onAsk,
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 5, 5, 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.14),
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Ask a question…',
                        style: TextStyle(
                          fontSize: 13.5,
                          color: AppColors.heroInk.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.green600,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 17,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
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
                          ?.copyWith(fontSize: 20, height: 1.05),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '/${word.pronunciation}/ · ${word.partOfSpeech}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: muted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // English meaning
          _MeaningRow(
            label: 'Meaning',
            text: word.meaningEn,
            accent: accent,
          ),
          const SizedBox(height: 10),

          // Regional-language meaning (student's default language)
          _MeaningRow(
            label: regionalLang.labelEn,
            text: word.regionalMeaning(regionalLang),
            accent: accent,
          ),

          const SizedBox(height: 14),
          Divider(height: 1, color: cs.outline),
          const SizedBox(height: 12),

          // Example sentence with the word emphasised
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.format_quote_rounded, size: 16, color: accent),
              const SizedBox(width: 8),
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

class _MeaningRow extends StatelessWidget {
  final String label;
  final String text;
  final Color accent;

  const _MeaningRow({
    required this.label,
    required this.text,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: accent,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
        ),
      ],
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
      fontSize: 13.5,
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
              fontWeight: FontWeight.w700,
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

// ─── Continue reading card ──────────────────────────────────────────────

class _ContinueCard extends StatelessWidget {
  final Book book;

  /// Real last-read page (0-based) from prefs; -1/0 means not started yet. We
  /// show only this — the book's total page count isn't known until the PDF
  /// loads in the reader, so there's no honest percentage to display here.
  final int lastPage;

  const _ContinueCard({required this.book, required this.lastPage});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final subjectColor = AppColors.subjectColor(book.subject, brightness);

    return GestureDetector(
      onTap: () => context.push('/reader/${book.id}'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPad - 4),
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
                    book.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 17,
                      height: 1.15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Class ${book.classNumber} · ${_capitalize(book.subject)}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontSize: 12.5),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.play_circle_outline_rounded,
                        size: 14,
                        color: subjectColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        lastPage > 0
                            ? 'Resume on page ${lastPage + 1}'
                            : 'Start reading',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: subjectColor,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 64,
              height: 84,
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
  final VoidCallback onTap;

  const _MiniTool({
    required this.color,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: ClayCard(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        radius: AppSpacing.tileRadius,
        blur: 13,
        distance: 4,
        child: Row(
          children: [
            Tile(color: color, icon: icon, size: 26, radius: 8),
            const SizedBox(width: 7),
            Expanded(
              // Scale the label down rather than clipping it on narrow screens.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
        width: 106,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 130,
              child: BookCover(subjectKey: book.subject, title: book.title),
            ),
            const SizedBox(height: 6),
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
