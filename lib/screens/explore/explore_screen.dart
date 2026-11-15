import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/models/class_range.dart';
import '../../providers/core_providers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ingested_books_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/user_selection_provider.dart';
import '../../data/seed/seed_data.dart'
    show availableClassNumbersForBoard, boardLabel;
import '../../data/services/backend_auth_service.dart';
import '../../utils/haptics.dart';
import '../../widgets/calm_widgets.dart';
import '../../widgets/pressable.dart';

/// The **Explore** tab — interactive learning tools: a search field, category
/// chips, one featured tool and a two-column grid of tinted tool cards.
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  /// The tool shown in the "Try this week" card, while nothing is filtered.
  static const _featuredId = 'virtual-lab';
  static const _featuredBlurb = 'Six experiments you can run on your phone.';

  final _search = TextEditingController();
  String _query = '';
  _ToolCategory? _category;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

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
    final selectedClasses = ref.read(exploreClassSelectionProvider);
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

  bool _matches(_Tool t) {
    if (_category != null && t.category != _category) return false;
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return t.title.toLowerCase().contains(q) || t.sub.toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
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
    final classes = ref.watch(exploreClassSelectionProvider);
    final tools = _tools(isDark);
    // Tools meant for the selected classes come first; the rest stay one tap
    // away under "More tools" rather than disappearing.
    bool fits(_Tool t) =>
        classes.isEmpty ||
        (exploreToolClassRanges[t.id] ?? ClassRange.all).fitsAny(classes);
    final filtering = _query.trim().isNotEmpty || _category != null;
    final featured = filtering
        ? null
        : tools.where((t) => t.id == _featuredId).firstOrNull;
    final shown = tools.where((t) => t != featured && _matches(t)).toList();
    final forYou = shown.where(fits).toList();
    final more = shown.where((t) => !fits(t)).toList();
    // While searching or filtering, every match shows in one grid, so a match
    // for another class is never hidden in the collapsed section.
    final grid = filtering ? [...forYou, ...more] : forYou;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 28),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: _SearchField(
                controller: _search,
                onChanged: (v) => setState(() => _query = v),
                onClear: () {
                  _search.clear();
                  setState(() => _query = '');
                },
              ),
            ),
            const SizedBox(height: 14),
            _CategoryChips(
              selected: _category,
              onSelected: (c) {
                Haptics.selection(ref);
                setState(() => _category = c);
              },
            ),
            const SizedBox(height: 16),
            if (featured != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  0,
                  AppSpacing.screenPadding,
                  AppSpacing.stackGap + 4,
                ),
                child: _FeaturedCard(
                  tool: featured,
                  blurb: _featuredBlurb,
                  onTap: () => _open(context, ref, featured),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: grid.isEmpty && (filtering || more.isEmpty)
                  ? const _NoMatches()
                  : _Grid(items: grid, onTap: (t) => _open(context, ref, t)),
            ),
            if (!filtering && more.isNotEmpty)
              _MoreTools(items: more, onTap: (t) => _open(context, ref, t)),
          ],
        ),
      ),
    );
  }
}

// ─── Search + categories ─────────────────────────────────────────────────

/// Outline colour of the search pill and unselected chips in light mode.
const _lineLight = Color(0xFFC6D5C9);

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final muted = dark ? AppColors.ink2Dark : AppColors.ink2;
    OutlineInputBorder pill(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
      borderSide: BorderSide(color: color, width: 2),
    );
    final idle = dark ? AppColors.surface3Dark : _lineLight;
    final focus = dark ? AppColors.green500Dark : AppColors.green600;

    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(fontSize: 15, color: cs.onSurface),
        cursorColor: focus,
        decoration: InputDecoration(
          hintText: 'Search tools and topics',
          hintStyle: TextStyle(fontSize: 15, color: muted),
          isCollapsed: true,
          filled: true,
          fillColor: cs.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          prefixIcon: Icon(Icons.search_rounded, size: 22, color: muted),
          prefixIconConstraints: const BoxConstraints(minWidth: 48),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  onPressed: onClear,
                  icon: Icon(Icons.close_rounded, size: 20, color: muted),
                ),
          border: pill(idle),
          enabledBorder: pill(idle),
          focusedBorder: pill(focus),
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final _ToolCategory? selected;
  final ValueChanged<_ToolCategory?> onSelected;

  const _CategoryChips({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final options = <_ToolCategory?>[null, ..._ToolCategory.values];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
        ),
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final c = options[i];
          return _Chip(
            label: c?.label ?? 'All',
            selected: c == selected,
            onTap: () => onSelected(c),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = cs.onSurface;
    final line = dark ? AppColors.surface3Dark : _lineLight;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? ink : Colors.transparent,
        shape: StadiumBorder(
          side: BorderSide(color: selected ? ink : line, width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              widthFactor: 1,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: AppFontSize.body,
                  fontWeight: selected
                      ? AppFontWeight.semibold
                      : AppFontWeight.medium,
                  color: selected ? cs.surface : ink,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NoMatches extends StatelessWidget {
  const _NoMatches();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 28,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 8),
          Text(
            'No tools match',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

// ─── Featured tool ───────────────────────────────────────────────────────

class _FeaturedCard extends StatelessWidget {
  final _Tool tool;
  final String blurb;
  final VoidCallback onTap;

  const _FeaturedCard({
    required this.tool,
    required this.blurb,
    required this.onTap,
  });

  static const _label = Color(0xFF7FE0B6);
  static const _body = Color(0xFFC9DDD2);

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      button: true,
      label: 'Try this week: ${tool.title}. $blurb',
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: dark ? AppColors.heroDark : AppColors.hero,
            borderRadius: BorderRadius.circular(24),
            border: dark ? Border.all(color: AppColors.heroLineDark) : null,
            boxShadow: dark
                ? null
                : const [
                    BoxShadow(
                      color: AppColors.onGreenDark,
                      offset: Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TRY THIS WEEK',
                      style: TextStyle(
                        fontSize: AppFontSize.small,
                        fontWeight: AppFontWeight.bold,
                        letterSpacing: 0.5,
                        color: _label,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tool.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontSize: AppFontSize.heading,
                            height: 1.15,
                            color: AppColors.heroInk,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      blurb,
                      style: const TextStyle(
                        fontSize: AppFontSize.body,
                        height: 1.35,
                        color: _body,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.green100Dark,
                  borderRadius: BorderRadius.circular(22),
                ),
                alignment: Alignment.center,
                child: Icon(tool.icon, size: 38, color: _label),
              ),
            ],
          ),
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
    _draftClasses = Set<int>.from(ref.read(exploreClassSelectionProvider));
    final preferences = ref
        .read(backendAccountCacheProvider)
        .explorePreferences
        .maybeWhen(data: (value) => value, orElse: () => null);
    _selectionMode =
        preferences?.selectionMode ??
        ref
            .read(userPrefsRepositoryProvider)
            .getExploreSelectionMode(uid: ref.read(accountUidProvider));
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
      ref
          .read(exploreClassSelectionProvider.notifier)
          .setClasses(selectedClasses);
      ref
          .read(userPrefsRepositoryProvider)
          .setExploreSelectionMode(_selectionMode);
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
    final board = ref.watch(userBoardProvider);
    final available = {
      ...availableClassNumbersForBoard(board),
      ...ref.watch(activeIngestedBooksProvider).classesFor(board),
    }.toList()..sort();
    final availableClasses = available.toSet();
    final primaryClass = ref.watch(primaryClassProvider);
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
                  onSelected: availableClasses.contains(primaryClass)
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
  final ValueChanged<_Tool>? onTap;

  const _Grid({required this.items, this.onTap});

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
                onTap: onTap == null ? null : () => onTap!(t),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

/// Collapsed section holding tools recommended for other classes.
class _MoreTools extends StatefulWidget {
  final List<_Tool> items;
  final ValueChanged<_Tool> onTap;

  const _MoreTools({required this.items, required this.onTap});

  @override
  State<_MoreTools> createState() => _MoreToolsState();
}

class _MoreToolsState extends State<_MoreTools> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.sectionGap - 4,
        AppSpacing.screenPadding,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            button: true,
            expanded: _open,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => setState(() => _open = !_open),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'More tools (${widget.items.length})',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    Text(
                      'For other classes',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _open
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_open) ...[
            const SizedBox(height: 8),
            _Grid(items: widget.items, onTap: widget.onTap),
          ],
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final _Tool tool;
  final VoidCallback? onTap;

  const _ToolCard({required this.tool, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      button: true,
      enabled: true,
      label: tool.title,
      child: Pressable(
        onTap: onTap,
        // Every tile reserves room for a two-line description, so a longer
        // subtitle never makes its row taller than its neighbour.
        child: Container(
          height: 144,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            // A solid bottom edge in light; dark relies on the lighter
            // surface alone.
            boxShadow: dark
                ? null
                : const [
                    BoxShadow(color: Color(0xFFD5E0D6), offset: Offset(0, 3)),
                  ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Tile(color: tool.color, icon: tool.icon, size: 44, radius: 14),
              const SizedBox(height: 10),
              Text(
                tool.title,
                style: TextStyle(
                  fontSize: AppFontSize.content,
                  fontWeight: AppFontWeight.semibold,
                  height: 1.2,
                  color: cs.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                tool.sub,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: dark ? AppColors.ink2Dark : AppColors.ink2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tool data ───────────────────────────────────────────────────────────

/// The chip a tool sits under. Every tool has exactly one.
enum _ToolCategory {
  maths('Maths'),
  science('Science'),
  language('Language'),
  coding('Coding'),
  play('Play');

  const _ToolCategory(this.label);
  final String label;
}

class _Tool {
  final String id;
  final String title;
  final String sub;
  final IconData icon;
  final Color color;
  final String route;
  final _ToolCategory category;

  const _Tool({
    required this.id,
    required this.title,
    required this.sub,
    required this.icon,
    required this.color,
    required this.category,
    this.route = '',
  });
}

List<_Tool> _tools(bool isDark) => [
  // Math is a hub for tables, drills, and formulas.
  _Tool(
    id: 'math',
    title: 'Math',
    sub: 'Formulas, tables & practice',
    icon: Icons.calculate_rounded,
    color: isDark ? AppColors.cMathHubDark : AppColors.cMathHub,
    route: '/learn/math',
    category: _ToolCategory.maths,
  ),
  _Tool(
    id: 'diagrams',
    title: 'Diagrams',
    sub: 'Interactive diagrams',
    icon: Icons.account_tree_rounded,
    color: isDark ? AppColors.cDiagramsDark : AppColors.cDiagrams,
    route: '/learn/diagrams',
    category: _ToolCategory.science,
  ),
  _Tool(
    id: 'virtual-lab',
    title: 'Laboratory',
    sub: 'Play with 6 experiments',
    icon: Icons.science_rounded,
    color: isDark ? AppColors.cScienceDark : AppColors.cScience,
    route: '/labs',
    category: _ToolCategory.science,
  ),
  _Tool(
    id: 'periodic-table',
    title: 'Periodic Table',
    sub: 'Explore the elements',
    icon: Icons.grid_view_rounded,
    color: isDark ? AppColors.cPeriodicDark : AppColors.cPeriodic,
    route: '/learn/periodic-table',
    category: _ToolCategory.science,
  ),
  _Tool(
    id: 'cosmulator',
    title: 'Cosmulator',
    sub: 'Solar system in 3D',
    icon: Icons.public_rounded,
    color: isDark ? AppColors.cCosmosDark : AppColors.cCosmos,
    route: '/learn/cosmulator',
    category: _ToolCategory.science,
  ),
  _Tool(
    id: 'quiz',
    title: 'Quizzes',
    sub: 'Test yourself by subject',
    icon: Icons.quiz_rounded,
    color: isDark ? AppColors.cEnglishDark : AppColors.cEnglish,
    route: '/learn/quiz',
    category: _ToolCategory.play,
  ),
  _Tool(
    id: 'python',
    title: 'Python',
    sub: 'Learn to code, playfully',
    icon: Icons.code_rounded,
    color: isDark ? AppColors.cPythonDark : AppColors.cPython,
    route: '/learn/python',
    category: _ToolCategory.coding,
  ),
  _Tool(
    id: 'vocabulary',
    title: 'Vocabulary',
    sub: 'Build your word power',
    icon: Icons.menu_book_outlined,
    color: isDark ? AppColors.cEnglishDark : AppColors.cEnglish,
    route: '/learn/vocabulary',
    category: _ToolCategory.language,
  ),
  _Tool(
    id: 'timeline',
    title: 'Timeline',
    sub: 'Major history events',
    icon: Icons.timeline_rounded,
    color: isDark ? AppColors.cTimelineDark : AppColors.cTimeline,
    route: '/learn/timeline',
    category: _ToolCategory.play,
  ),
];
