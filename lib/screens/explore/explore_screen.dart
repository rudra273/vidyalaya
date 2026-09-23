import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../providers/core_providers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ingested_books_provider.dart';
import '../../providers/lab_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/user_selection_provider.dart';
import '../../data/seed/seed_data.dart'
    show availableClassNumbersForBoard, boardLabel;
import '../../data/services/backend_auth_service.dart';
import '../../utils/haptics.dart';
import '../../widgets/calm_widgets.dart';
import '../../widgets/pressable.dart';

/// The **Explore** tab — interactive learning tools, presented as a tasteful
/// duotone grid (faint glyph backdrop, tinted tile, serif title) plus a
/// "Coming soon" group.
class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  void _showClassFilter(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ClassFilterSheet(),
    );
  }

  void _open(BuildContext context, WidgetRef ref, _Tool tool) {
    Haptics.light(ref);
    ref.read(userPrefsRepositoryProvider).recordToolOpened(tool.id);
    final selectedClasses = ref.read(userSelectionProvider);
    unawaited(
      ref
          .read(learningEventServiceProvider)
          .recordBestEffort(
            eventType: 'content_opened',
            feature: 'tool',
            board: ref.read(userBoardProvider),
            classNo: selectedClasses.length == 1
                ? selectedClasses.single
                : null,
          ),
    );
    ref.read(progressProvider.notifier).refresh();
    context.push(tool.route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn = ref
        .watch(authStateProvider)
        .maybeWhen(data: (user) => user != null, orElse: () => false);
    final account = ref.watch(backendAccountCacheProvider);
    if (signedIn &&
        (!account.profileLoaded || !account.explorePreferencesLoaded)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        final cache = ref.read(backendAccountCacheProvider.notifier);
        cache.ensureProfile();
        cache.ensureExplorePreferences();
      });
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final classes = ref.watch(userSelectionProvider).toList()..sort();
    final labsAvailable = labAvailableForSelection(classes);
    final tools = _tools(isDark, labsAvailable);
    final soon = _soon(isDark);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            PageTitle(
              title: 'Explore',
              sub: 'Hands-on, interactive learning',
              trailing: IconBox(
                icon: Icons.filter_list_rounded,
                tooltip: 'Filter classes',
                onTap: () => _showClassFilter(context),
              ),
            ),
            const SizedBox(height: AppSpacing.sectionGap - 4),
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: SectionHead(label: 'Explore & Play'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: _Grid(items: tools, onTap: (t) => _open(context, ref, t)),
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: SectionHead(label: 'Coming soon'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: _Grid(items: soon, soon: true),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClassFilterSheet extends ConsumerStatefulWidget {
  const _ClassFilterSheet();

  @override
  ConsumerState<_ClassFilterSheet> createState() => _ClassFilterSheetState();
}

class _ClassFilterSheetState extends ConsumerState<_ClassFilterSheet> {
  bool _isSaving = false;
  String _selectionMode = 'selected';
  late Set<int> _draftClasses;

  @override
  void initState() {
    super.initState();
    _draftClasses = Set<int>.from(ref.read(userSelectionProvider));
    final preferences = ref
        .read(backendAccountCacheProvider)
        .explorePreferences
        .maybeWhen(data: (value) => value, orElse: () => null);
    if (preferences != null) _selectionMode = preferences.selectionMode;
  }

  void _selectMode(String mode, Set<int> available, int? primaryClass) {
    setState(() {
      _selectionMode = mode;
      if (mode == 'all') {
        _draftClasses = Set<int>.from(available);
      } else if (mode == 'primary' && primaryClass != null) {
        _draftClasses = {primaryClass};
      }
    });
  }

  Future<void> _apply(Set<int> selectedClasses) async {
    if (selectedClasses.isEmpty || _isSaving) return;
    final signedIn = ref
        .read(authStateProvider)
        .maybeWhen(data: (user) => user != null, orElse: () => false);
    if (!signedIn) {
      ref.read(userSelectionProvider.notifier).setClasses(selectedClasses);
      if (mounted) Navigator.of(context).pop();
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref
          .read(backendAccountCacheProvider.notifier)
          .saveExplorePreferences(
            ExplorePreferences(
              selectionMode: _selectionMode,
              selectedClasses: _selectionMode == 'selected'
                  ? (selectedClasses.toList()..sort())
                  : const [],
            ),
          );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Couldn\'t save class selection. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(backendAccountCacheProvider);
    final board = ref.watch(userBoardProvider);
    final available = {
      ...availableClassNumbersForBoard(board),
      ...ref.watch(activeIngestedBooksProvider).classesFor(board),
    }.toList()..sort();
    final availableClasses = available.toSet();
    final savedClasses = ref.watch(userSelectionProvider);
    final isSignedIn = ref
        .watch(authStateProvider)
        .maybeWhen(data: (user) => user != null, orElse: () => false);
    final primaryClass =
        account.profile.maybeWhen(
          data: (profile) => profile?.classNo,
          orElse: () => null,
        ) ??
        (isSignedIn || savedClasses.isEmpty
            ? null
            : (savedClasses.toList()..sort()).first);
    final selectedClasses = _draftClasses.intersection(availableClasses);
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.78,
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          10,
          AppSpacing.screenPadding,
          AppSpacing.screenPadding,
        ),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filter classes',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${boardLabel(board)} · ${selectedClasses.length} selected',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('My class'),
                  selected: _selectionMode == 'primary',
                  onSelected:
                      primaryClass != null &&
                          availableClasses.contains(primaryClass)
                      ? (_) => _selectMode(
                          'primary',
                          availableClasses,
                          primaryClass,
                        )
                      : null,
                ),
                ChoiceChip(
                  label: const Text('All available'),
                  selected: _selectionMode == 'all',
                  onSelected: (_) =>
                      _selectMode('all', availableClasses, primaryClass),
                ),
                ChoiceChip(
                  label: const Text('Choose classes'),
                  selected: _selectionMode == 'selected',
                  onSelected: (_) =>
                      _selectMode('selected', availableClasses, primaryClass),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Available classes',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 10),
            Flexible(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final classNumber in available)
                      FilterChip(
                        label: Text('Class $classNumber'),
                        selected: selectedClasses.contains(classNumber),
                        onSelected: (_) {
                          setState(() {
                            _selectionMode = 'selected';
                            if (!_draftClasses.add(classNumber)) {
                              _draftClasses.remove(classNumber);
                            }
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedClasses.isEmpty || _isSaving
                    ? null
                    : () => _apply(selectedClasses),
                child: Text(_isSaving ? 'Saving…' : 'Apply filter'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  final List<_Tool> items;
  final bool soon;
  final ValueChanged<_Tool>? onTap;

  const _Grid({required this.items, this.soon = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        const gap = AppSpacing.stackGap;
        final cellW = (c.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: items.map((t) {
            return SizedBox(
              width: cellW,
              child: _ToolCard(
                tool: t,
                soon: soon,
                onTap: onTap == null ? null : () => onTap!(t),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _ToolCard extends StatelessWidget {
  final _Tool tool;
  final bool soon;
  final VoidCallback? onTap;

  const _ToolCard({required this.tool, this.soon = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      button: !soon,
      enabled: !soon,
      label: soon ? '${tool.title}, coming soon' : tool.title,
      child: Pressable(
        onTap: soon ? null : onTap,
        child: Opacity(
          opacity: soon ? 0.72 : 1,
          child: Container(
            constraints: const BoxConstraints(minHeight: 152),
            padding: const EdgeInsets.all(AppSpacing.cardPad),
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border.all(color: cs.outline),
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            ),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // faint glyph backdrop
                Positioned(
                  right: -16,
                  bottom: -18,
                  child: Icon(
                    tool.icon,
                    size: 92,
                    color: tool.color.withValues(alpha: 0.12),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Tile(color: tool.color, icon: tool.icon, size: 46),
                        if (soon)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isDark
                                    ? AppColors.hairlineDark
                                    : AppColors.hairline,
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'SOON',
                              style: TextStyle(
                                fontSize: AppFontSize.caption,
                                fontWeight: AppFontWeight.bold,
                                letterSpacing: 0.5,
                                color: isDark
                                    ? AppColors.ink3Dark
                                    : AppColors.ink3,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      tool.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontSize: AppFontSize.content,
                            height: 1.12,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tool.sub,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: AppFontSize.small,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Tool data ───────────────────────────────────────────────────────────

class _Tool {
  final String id;
  final String title;
  final String sub;
  final IconData icon;
  final Color color;
  final String route;

  const _Tool({
    required this.id,
    required this.title,
    required this.sub,
    required this.icon,
    required this.color,
    this.route = '',
  });
}

List<_Tool> _tools(bool isDark, bool labsAvailable) => [
  // Math is a hub: tables, drills, quizzes and Formulas all live inside it.
  _Tool(
    id: 'math',
    title: 'Math',
    sub: 'Tables, drills & quizzes',
    icon: Icons.calculate_rounded,
    color: isDark ? AppColors.cMathHubDark : AppColors.cMathHub,
    route: '/learn/math',
  ),
  _Tool(
    id: 'diagrams',
    title: 'Diagrams',
    sub: 'Interactive diagrams',
    icon: Icons.account_tree_rounded,
    color: isDark ? AppColors.cDiagramsDark : AppColors.cDiagrams,
    route: '/learn/diagrams',
  ),
  _Tool(
    id: 'cosmulator',
    title: 'Cosmulator',
    sub: 'Solar system in 3D',
    icon: Icons.public_rounded,
    color: isDark ? AppColors.cCosmosDark : AppColors.cCosmos,
    route: '/learn/cosmulator',
  ),
  _Tool(
    id: 'periodic-table',
    title: 'Periodic Table',
    sub: 'Explore the elements',
    icon: Icons.grid_view_rounded,
    color: isDark ? AppColors.cPeriodicDark : AppColors.cPeriodic,
    route: '/learn/periodic-table',
  ),
  _Tool(
    id: 'vocabulary',
    title: 'Vocabulary',
    sub: 'Build your word power',
    icon: Icons.menu_book_outlined,
    color: isDark ? AppColors.cEnglishDark : AppColors.cEnglish,
    route: '/learn/vocabulary',
  ),
  _Tool(
    id: 'python',
    title: 'Python',
    sub: 'Learn to code, playfully',
    icon: Icons.code_rounded,
    color: isDark ? AppColors.cPythonDark : AppColors.cPython,
    route: '/learn/python',
  ),
  if (labsAvailable)
    _Tool(
      id: 'virtual-lab',
      title: 'Science Lab',
      sub: 'Try two experiments',
      icon: Icons.science_rounded,
      color: isDark ? AppColors.cScienceDark : AppColors.cScience,
      route: '/labs',
    ),
  _Tool(
    id: 'timeline',
    title: 'Timeline',
    sub: 'Major history events',
    icon: Icons.timeline_rounded,
    color: isDark ? AppColors.cTimelineDark : AppColors.cTimeline,
    route: '/learn/timeline',
  ),
];

List<_Tool> _soon(bool isDark) => [
  _Tool(
    id: 'quizzes',
    title: 'Quizzes',
    sub: 'Test yourself',
    icon: Icons.help_outline_rounded,
    color: isDark ? AppColors.cMathsDark : AppColors.cMaths,
  ),
];
