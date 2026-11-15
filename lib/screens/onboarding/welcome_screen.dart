import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../data/seed/seed_data.dart';
import '../../providers/auth_provider.dart';
import '../../providers/core_providers.dart';
import '../../providers/regional_language_provider.dart';
import '../../providers/user_selection_provider.dart';
import '../../widgets/ai_robot_mark.dart';
import '../../widgets/chunky_button.dart';
import '../../widgets/pressable.dart';
import '../../widgets/vidyakalp_logo.dart';

// ─── Welcome flow ─────────────────────────────────────────────────────────
// Three short steps before Home:
//   1. Hello — sign in with Google, or carry on without an account.
//   2. Board and class.
//   3. Explanation language.
// Signed-in students skip step 1. Nothing is saved until the last step.

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  late final PageController _pages;
  late int _step;
  late int _selectedClass;
  late String _selectedBoard;
  late String _preferredLanguage;
  bool _signingIn = false;

  @override
  void initState() {
    super.initState();
    _selectedBoard = ref.read(userBoardProvider);
    _selectedClass = ref.read(primaryClassProvider);
    _preferredLanguage =
        ref.read(userPrefsRepositoryProvider).getPreferredLanguage() ??
        getBoardById(_selectedBoard)?.defaultLanguageCode ??
        'or';
    final signedIn = ref
        .read(authStateProvider)
        .maybeWhen(data: (u) => u != null, orElse: () => false);
    _step = signedIn ? 1 : 0;
    _pages = PageController(initialPage: _step);
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _goTo(int step) {
    setState(() => _step = step);
    _pages.animateToPage(
      step,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _signIn() async {
    setState(() => _signingIn = true);
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      if (mounted) _goTo(1);
    } catch (e) {
      // Closing the Google picker is not an error worth a message.
      final cancelled = e.toString().toLowerCase().contains('cancel');
      if (mounted && !cancelled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Couldn't sign in. Check your connection and try again.",
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _signingIn = false);
    }
  }

  void _finish() {
    final prefs = ref.read(userPrefsRepositoryProvider);
    ref.read(primaryClassProvider.notifier).setClass(_selectedClass);
    ref.read(exploreClassSelectionProvider.notifier).setClasses({
      _selectedClass,
    });
    ref.read(libraryClassSelectionProvider.notifier).setClasses({
      _selectedClass,
    });
    ref.read(userBoardProvider.notifier).setBoard(_selectedBoard);
    prefs.setPreferredLanguage(_preferredLanguage);
    prefs.setHasCompletedOnboarding(true);
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = ref
        .watch(authStateProvider)
        .maybeWhen(data: (u) => u != null, orElse: () => false);
    // Steps 2 and 3 show progress; step 1 is the greeting.
    final firstSetupStep = 1;

    return BackButtonListener(
      onBackButtonPressed: () async {
        if (_step > (signedIn ? firstSetupStep : 0)) {
          _goTo(_step - 1);
          return true;
        }
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              if (_step >= firstSetupStep)
                _StepHeader(
                  step: _step,
                  canGoBack: _step > (signedIn ? firstSetupStep : 0),
                  onBack: () => _goTo(_step - 1),
                ),
              Expanded(
                child: PageView(
                  controller: _pages,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _HelloStep(
                      busy: _signingIn,
                      onGoogle: _signIn,
                      onSkip: () => _goTo(1),
                    ),
                    _ClassStep(
                      board: _selectedBoard,
                      classNo: _selectedClass,
                      onBoard: (b) => setState(() {
                        _selectedBoard = b;
                        // A new board suggests its own medium, unless the
                        // student picks a language on the next step.
                        _preferredLanguage =
                            getBoardById(b)?.defaultLanguageCode ??
                            _preferredLanguage;
                      }),
                      onClass: (c) => setState(() => _selectedClass = c),
                      onContinue: () => _goTo(2),
                    ),
                    _LanguageStep(
                      language: _preferredLanguage,
                      onLanguage: (l) => setState(() => _preferredLanguage = l),
                      onFinish: _finish,
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
}

Color _muted(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? AppColors.ink2Dark
    : AppColors.ink2;

// ─── Step header: back + two-segment progress ───────────────────────────

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.step,
    required this.canGoBack,
    required this.onBack,
  });

  final int step;
  final bool canGoBack;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final track = dark ? AppColors.surface3Dark : const Color(0xFFCFDCD1);
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 8, 24, 0),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: canGoBack
                ? IconButton(
                    onPressed: onBack,
                    tooltip: 'Back',
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  )
                : null,
          ),
          Expanded(
            child: Semantics(
              label: 'Step $step of 2',
              child: Row(
                children: [
                  for (var i = 1; i <= 2; i++) ...[
                    if (i > 1) const SizedBox(width: 6),
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 8,
                        decoration: BoxDecoration(
                          color: i <= step ? cs.primary : track,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 1: hello ──────────────────────────────────────────────────────

class _HelloStep extends StatelessWidget {
  const _HelloStep({
    required this.busy,
    required this.onGoogle,
    required this.onSkip,
  });

  final bool busy;
  final VoidCallback onGoogle;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight - 52),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: VidyakalpLogo(size: 32),
                ),
                const Spacer(),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const AiBot(size: 96),
                    const SizedBox(width: 14),
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 26),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(18),
                            topRight: Radius.circular(18),
                            bottomRight: Radius.circular(18),
                            bottomLeft: Radius.circular(4),
                          ),
                        ),
                        child: Text(
                          'Hi, I am your study buddy.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: AppFontWeight.medium,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  'Your textbooks, explained the way you learn.',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontSize: AppFontSize.display,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Books, clear answers and practice for Classes 1 to 10.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: _muted(context),
                  ),
                ),
                const SizedBox(height: 24),
                const _Point(
                  icon: Icons.menu_book_rounded,
                  text: 'Ask anything from your school books',
                ),
                const _Point(
                  icon: Icons.translate_rounded,
                  text: 'Answers in English, Odia or Hindi',
                ),
                const _Point(
                  icon: Icons.check_rounded,
                  text: 'Works without an account',
                ),
                const Spacer(),
                const SizedBox(height: 24),
                ChunkyButton(
                  label: busy ? 'Signing in…' : 'Continue with Google',
                  onPressed: busy ? null : onGoogle,
                  leading: Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      'G',
                      style: TextStyle(
                        fontSize: AppFontSize.content,
                        fontWeight: AppFontWeight.extraBold,
                        color: Color(0xFF4285F4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ChunkyButton(
                  label: 'Continue without an account',
                  style: ChunkyStyle.secondary,
                  onPressed: busy ? null : onSkip,
                ),
                const SizedBox(height: 12),
                Text(
                  'You can sign in later from Profile.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _muted(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Point extends StatelessWidget {
  const _Point({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: cs.secondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: cs.onSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}

// ─── Shared: step title with the bot ────────────────────────────────────

class _StepTitle extends StatelessWidget {
  const _StepTitle({required this.title, required this.sub});

  final String title;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AiBot(size: 60, mood: BotMood.listening),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 4),
              Text(
                sub,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _muted(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A selectable card row (board, language) with a radio tick on the right.
class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.selected,
    required this.onTap,
    required this.title,
    required this.sub,
    this.leading,
    this.enabled = true,
  });

  final bool selected;
  final VoidCallback onTap;
  final String title;
  final String sub;
  final Widget? leading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final edge = selected
        ? cs.primary
        : (dark ? AppColors.surface3Dark : const Color(0xFFCFDCD1));
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: '$title, $sub',
      excludeSemantics: true,
      child: Pressable(
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.5,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            constraints: const BoxConstraints(minHeight: 68),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: selected
                  ? Color.alphaBlend(
                      cs.primary.withValues(alpha: dark ? 0.16 : 0.1),
                      cs.surface,
                    )
                  : cs.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: edge, width: 2),
              boxShadow: [BoxShadow(color: edge, offset: const Offset(0, 3))],
            ),
            child: Row(
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 14)],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        sub,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _muted(context),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: selected ? cs.primary : null,
                    shape: BoxShape.circle,
                    border: selected
                        ? null
                        : Border.all(color: _muted(context), width: 2),
                  ),
                  child: selected
                      ? Icon(Icons.check_rounded, size: 16, color: cs.onPrimary)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Step 2: board and class ────────────────────────────────────────────

class _ClassStep extends StatelessWidget {
  const _ClassStep({
    required this.board,
    required this.classNo,
    required this.onBoard,
    required this.onClass,
    required this.onContinue,
  });

  final String board;
  final int classNo;
  final ValueChanged<String> onBoard;
  final ValueChanged<int> onClass;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    // Classes come from readable books, not the separate AI catalog.
    final available = availableClassNumbersForBoard(board);
    final isAvailable = available.contains(classNo);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            children: [
              const _StepTitle(
                title: 'Which class are you in?',
                sub: 'I will bring the right books.',
              ),
              const SizedBox(height: 28),
              const _Label('Board'),
              for (final b in boards) ...[
                _ChoiceCard(
                  selected: b.id == board,
                  enabled: availableBoardIds.contains(b.id),
                  onTap: () => onBoard(b.id),
                  title: b.name,
                  sub: b.id == 'scert_odisha' ? 'Odia medium' : 'CBSE',
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 12),
              const _Label('Class'),
              GridView.count(
                crossAxisCount: 5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.05,
                children: [
                  for (var c = 1; c <= 10; c++)
                    _ClassChip(
                      classNo: c,
                      selected: c == classNo,
                      available: available.contains(c),
                      onTap: () => onClass(c),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  isAvailable
                      ? 'You can add more classes later in Books.'
                      : 'Class $classNo books are coming soon. Pick another class for now.',
                  key: ValueKey(isAvailable),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isAvailable
                        ? _muted(context)
                        : Theme.of(context).colorScheme.error,
                    fontWeight: isAvailable ? null : AppFontWeight.semibold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          child: ChunkyButton(
            label: 'Continue',
            onPressed: isAvailable ? onContinue : null,
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: AppFontSize.small,
          color: _muted(context),
        ),
      ),
    );
  }
}

class _ClassChip extends StatelessWidget {
  const _ClassChip({
    required this.classNo,
    required this.selected,
    required this.available,
    required this.onTap,
  });

  final int classNo;
  final bool selected;
  final bool available;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final edge = selected
        ? (dark ? const Color(0xFF1C7D55) : const Color(0xFF0A4C34))
        : (dark ? AppColors.surface3Dark : const Color(0xFFCFDCD1));
    return Semantics(
      button: true,
      selected: selected,
      label: available ? 'Class $classNo' : 'Class $classNo, coming soon',
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          decoration: BoxDecoration(
            color: selected ? cs.primary : cs.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: edge, offset: const Offset(0, 3))],
          ),
          alignment: Alignment.center,
          child: available
              ? Text(
                  '$classNo',
                  style: TextStyle(
                    fontSize: AppFontSize.title,
                    fontWeight: AppFontWeight.bold,
                    color: selected ? cs.onPrimary : cs.onSurface,
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$classNo',
                      style: TextStyle(
                        fontSize: AppFontSize.content,
                        fontWeight: AppFontWeight.semibold,
                        color: selected ? cs.onPrimary : _muted(context),
                      ),
                    ),
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 12,
                      color: selected ? cs.onPrimary : _muted(context),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── Step 3: explanation language ───────────────────────────────────────

class _LanguageStep extends StatelessWidget {
  const _LanguageStep({
    required this.language,
    required this.onLanguage,
    required this.onFinish,
  });

  final String language;
  final ValueChanged<String> onLanguage;
  final VoidCallback onFinish;

  static String _sub(RegionalLanguage l) => switch (l) {
    RegionalLanguage.english => 'Explanations in English',
    RegionalLanguage.odia => 'English with Odia meanings',
    RegionalLanguage.hindi => 'English with Hindi meanings',
  };

  static String _glyph(RegionalLanguage l) => switch (l) {
    RegionalLanguage.english => 'Aa',
    RegionalLanguage.odia => 'ଅ',
    RegionalLanguage.hindi => 'अ',
  };

  static (Color, Color) _hue(RegionalLanguage l) => switch (l) {
    RegionalLanguage.english => (AppColors.cEnglish, AppColors.cEnglishDark),
    RegionalLanguage.odia => (AppColors.cOdia, AppColors.cOdiaDark),
    RegionalLanguage.hindi => (AppColors.cHindi, AppColors.cHindiDark),
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            children: [
              const _StepTitle(
                title: 'How should I explain?',
                sub: 'Menus stay in English.',
              ),
              const SizedBox(height: 28),
              for (final l in RegionalLanguage.values) ...[
                _ChoiceCard(
                  selected: l.code == language,
                  onTap: () => onLanguage(l.code),
                  title: l.labelEn,
                  sub: _sub(l),
                  leading: Builder(
                    builder: (context) {
                      final (light, darkHue) = _hue(l);
                      final hue = dark ? darkHue : light;
                      return Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Color.alphaBlend(
                            hue.withValues(alpha: dark ? 0.2 : 0.14),
                            cs.surface,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          _glyph(l),
                          style: TextStyle(
                            fontSize: AppFontSize.headingSmall,
                            fontWeight: AppFontWeight.semibold,
                            color: hue,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 4),
              Text(
                'You can change this any time from Profile.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _muted(context),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          child: ChunkyButton(label: 'Start learning', onPressed: onFinish),
        ),
      ],
    );
  }
}
