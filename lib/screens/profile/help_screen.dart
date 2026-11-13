import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_info.dart';
import '../../app/theme.dart';
import '../../providers/rollout_switches_provider.dart';
import '../../widgets/calm_widgets.dart';
import '../plus/plus_sheet.dart' show plusNotForSale;

// ─── FAQ content ─────────────────────────────────────────────────────────
// Answers describe what the app does today; keep them in step with the code.
// No limit numbers anywhere: the server owns the allowance and Plus limits.

class _Faq {
  final String question;
  final String answer;

  const _Faq(this.question, this.answer);

  bool matches(String query) =>
      question.toLowerCase().contains(query) ||
      answer.toLowerCase().contains(query);
}

List<_Faq> _faqs({required bool booksEnabled}) => [
  _Faq(
    'Do I need an account?',
    booksEnabled
        ? 'No. You can read books, use the study tools and games, and keep '
              'your timetable and notes without one. Sign in with Google to '
              'ask the AI questions and save your name and school.'
        : 'No. You can use the study tools and games, and keep your '
              'timetable and notes without one. Sign in with Google to ask '
              'the AI questions and save your name and school.',
  ),
  const _Faq(
    'How do the daily AI questions work?',
    'You get one daily allowance of questions, shared by every AI chat in the '
        'app. If a question fails before you get an answer, it is not '
        'counted. Your questions come back when the allowance resets, and the '
        'AI screen shows how many you have left and when they come back.',
  ),
  const _Faq(
    'How do I get Plus?',
    'Sign in, open Profile and tap Request Plus on the Plus card. Our team '
        'looks at each request by hand, and if Plus is added it turns on for '
        'your account for a limited time. $plusNotForSale',
  ),
  if (booksEnabled)
    const _Faq(
      'Can I read books offline?',
      'Yes. Open Profile, tap Settings, then Manage downloads, and download '
          'the books you want. Downloaded books open without the internet. '
          'You can delete them there too, to free up space.',
    ),
  const _Faq(
    'How do I change my class or language?',
    'Open Profile and tap Edit next to Student profile. You can change your '
        'class, board and preferred language there, even without signing in.',
  ),
  const _Faq(
    'How do I delete my account?',
    'Open Profile, tap Settings, then Delete account. It opens our account '
        'deletion page, where you can ask for your account and data to be '
        'deleted.',
  ),
];

// ─── Help screen ─────────────────────────────────────────────────────────

/// **Help and feedback** — searchable FAQ, feedback links and app info.
class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final booksEnabled = ref.watch(booksEnabledProvider);
    final query = _query.trim().toLowerCase();
    final faqs = _faqs(
      booksEnabled: booksEnabled,
    ).where((faq) => query.isEmpty || faq.matches(query)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Help and feedback', style: theme.textTheme.headlineSmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/profile'),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            8,
            AppSpacing.screenPadding,
            24,
          ),
          children: [
            _SearchField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 20),

            // ── Common questions ─────────────────────────────────
            const SectionHead(label: 'Common questions'),
            if (faqs.isEmpty)
              _NoMatches(query: _query.trim())
            else
              _FaqCard(faqs: faqs, expandFirst: query.isEmpty),

            const SizedBox(height: 24),

            // ── Still stuck? ─────────────────────────────────────
            const SectionHead(label: 'Still stuck?'),
            const _ContactCards(),

            const SizedBox(height: 28),
            const _FooterLinks(),
          ],
        ),
      ),
    );
  }
}

// ─── Search ──────────────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final ink2 = isDark ? AppColors.ink2Dark : AppColors.ink2;
    OutlineInputBorder pill(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
      borderSide: BorderSide(color: color, width: width),
    );

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) => TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontSize: AppFontSize.content,
          color: cs.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'Search help',
          filled: true,
          fillColor: cs.surface,
          prefixIcon: Icon(Icons.search_rounded, size: 22, color: ink2),
          suffixIcon: value.text.isEmpty
              ? null
              : IconButton(
                  icon: Icon(Icons.close_rounded, size: 20, color: ink2),
                  tooltip: 'Clear search',
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: pill(cs.outline, 2),
          enabledBorder: pill(cs.outline, 2),
          focusedBorder: pill(cs.primary, 2),
        ),
      ),
    );
  }
}

class _NoMatches extends StatelessWidget {
  final String query;

  const _NoMatches({required this.query});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPad),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Text(
        'Nothing matches "$query". Try other words, or send us feedback '
        'below.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

// ─── FAQ card + expandable item ──────────────────────────────────────────

class _FaqCard extends StatelessWidget {
  final List<_Faq> faqs;
  final bool expandFirst;

  const _FaqCard({required this.faqs, required this.expandFirst});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        children: [
          for (var i = 0; i < faqs.length; i++)
            _FaqItem(
              // Keyed by question so filtering keeps each item's open state.
              key: ValueKey(faqs[i].question),
              faq: faqs[i],
              initiallyOpen: expandFirst && i == 0,
              last: i == faqs.length - 1,
            ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final _Faq faq;
  final bool initiallyOpen;
  final bool last;

  const _FaqItem({
    super.key,
    required this.faq,
    required this.initiallyOpen,
    required this.last,
  });

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  late bool _open = widget.initiallyOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final hair = isDark ? AppColors.hairline2Dark : AppColors.hairline2;
    final ink2 = isDark ? AppColors.ink2Dark : AppColors.ink2;

    return Container(
      decoration: widget.last
          ? null
          : BoxDecoration(
              border: Border(bottom: BorderSide(color: hair)),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            expanded: _open,
            child: InkWell(
              onTap: () => setState(() => _open = !_open),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 52),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.faq.question,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: AppFontSize.content,
                            fontWeight: AppFontWeight.semibold,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      AnimatedRotation(
                        turns: _open ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 22,
                          color: _open ? cs.onSurface : ink2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _open
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: Text(
                      widget.faq.answer,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: AppFontSize.body,
                        height: 1.5,
                        color: ink2,
                      ),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

// ─── Feedback cards ──────────────────────────────────────────────────────

class _ContactCards extends StatelessWidget {
  const _ContactCards();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _ContactCard(
              color: isDark ? AppColors.cAiDark : AppColors.cAi,
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Send feedback',
              sub: 'Ideas and suggestions',
              onTap: () => context.push('/feedback'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ContactCard(
              color: isDark ? AppColors.cMathsDark : AppColors.cMaths,
              icon: Icons.warning_amber_rounded,
              title: 'Report a problem',
              sub: 'Something is not working',
              onTap: () => context.push('/feedback'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String sub;
  final VoidCallback onTap;

  const _ContactCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Material(
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        side: BorderSide(color: cs.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Tile(color: color, icon: icon, size: 44, radius: 14),
              const SizedBox(height: 10),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: AppFontSize.content,
                  fontWeight: AppFontWeight.semibold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(sub, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Footer: policy, about, version ──────────────────────────────────────

class _FooterLinks extends StatelessWidget {
  const _FooterLinks();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final linkStyle = theme.textTheme.labelLarge?.copyWith(
      fontSize: AppFontSize.body,
      fontWeight: AppFontWeight.semibold,
      color: theme.colorScheme.primary,
    );
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        TextButton(
          onPressed: () => context.push('/privacy-policy'),
          child: Text('Privacy Policy', style: linkStyle),
        ),
        TextButton(
          onPressed: () => context.push('/about'),
          child: Text('About', style: linkStyle),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Version $kAppVersionName',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: AppFontSize.body,
            ),
          ),
        ),
      ],
    );
  }
}
