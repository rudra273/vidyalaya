import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../providers/books_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/core_providers.dart';
import '../../providers/user_selection_provider.dart';
import '../../data/services/backend_auth_service.dart';
import '../../data/models/book.dart';
import '../../data/seed/seed_data.dart'
    show availableClassNumbersForBoard, boardLabel;
import '../../widgets/empty_state.dart';
import '../../widgets/calm_widgets.dart';
import 'widgets/filter_chips_bar.dart';
import 'widgets/book_grid_card.dart';

class MyBooksScreen extends ConsumerStatefulWidget {
  const MyBooksScreen({super.key});

  @override
  ConsumerState<MyBooksScreen> createState() => _MyBooksScreenState();
}

class _MyBooksScreenState extends ConsumerState<MyBooksScreen> {
  final _searchController = TextEditingController();
  bool _searchActive = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searchActive = !_searchActive;
      if (!_searchActive) _searchController.clear();
    });
  }

  void _showLibraryFilter() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _LibraryClassFilterSheet(),
    );
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  /// Title/subject match against the typed query (case-insensitive).
  List<Book> _applySearch(List<Book> books) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return books;
    return books.where((book) {
      final subjectLabel = subjectMeta(book.subject).label.toLowerCase();
      return book.title.toLowerCase().contains(query) ||
          book.subject.toLowerCase().contains(query) ||
          subjectLabel.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = ref
        .watch(authStateProvider)
        .maybeWhen(data: (user) => user != null, orElse: () => false);
    final account = ref.watch(backendAccountCacheProvider);
    if (signedIn && !account.libraryPreferencesLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(backendAccountCacheProvider.notifier)
              .ensureLibraryPreferences();
        }
      });
    }
    final selectedClasses = ref.watch(libraryClassSelectionProvider);
    final selectedBoard = ref.watch(userBoardProvider);
    final filteredBooks = _applySearch(ref.watch(filteredBooksProvider));
    final allSelectedBooks = ref.watch(selectedBooksProvider);

    final hasSelection = selectedClasses.isNotEmpty;
    final isSearching = _searchController.text.trim().isNotEmpty;

    final booksByClass = <int, List<Book>>{};
    for (final book in filteredBooks) {
      booksByClass.putIfAbsent(book.classNumber, () => []).add(book);
    }
    final sortedClasses = booksByClass.keys.toList()..sort();

    final sub = hasSelection
        ? '${selectedClasses.map((c) => "Class $c").join(", ")} · ${boardLabel(selectedBoard)} · ${allSelectedBooks.length} books'
        : 'No class selected';

    // Pushed full-screen from Home (it no longer has a tab), so it owns its
    // own Scaffold — the back button's ink needs a Material ancestor.
    final canPop = context.canPop();
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/');
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageTitle(
                title: 'Library',
                sub: sub,
                // Pushed from Home rather than a tab, so it carries its own back.
                onBack: _goBack,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconBox(
                      icon: Icons.filter_list_rounded,
                      tooltip: 'Filter library classes',
                      onTap: _showLibraryFilter,
                    ),
                    const SizedBox(width: 8),
                    IconBox(
                      icon: _searchActive
                          ? Icons.close_rounded
                          : Icons.search_rounded,
                      tooltip: _searchActive ? 'Close search' : 'Search books',
                      onTap: _toggleSearch,
                    ),
                  ],
                ),
              ),

              if (_searchActive) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search books or subjects…',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      isDense: true,
                      suffixIcon: isSearching
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () =>
                                  setState(() => _searchController.clear()),
                            )
                          : null,
                    ),
                  ),
                ),
              ],

              if (hasSelection && !_searchActive) ...[
                const SizedBox(height: 14),
                const FilterChipsBar(),
              ],

              const SizedBox(height: AppSpacing.stackGap),

              Expanded(
                child: !hasSelection
                    ? EmptyState(
                        icon: Icons.menu_book_rounded,
                        title: 'No class selected',
                        subtitle:
                            'Select your class to get started with your textbooks.',
                        ctaLabel: 'Select Class',
                        onCtaTap: _showLibraryFilter,
                      )
                    : filteredBooks.isEmpty
                    ? EmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'No books found',
                        subtitle: isSearching
                            ? 'No matches for "${_searchController.text.trim()}". Try another word.'
                            : 'Try a different subject filter.',
                      )
                    : CustomScrollView(
                        slivers: [
                          for (final classNum in sortedClasses) ...[
                            if (selectedClasses.length > 1)
                              SliverPadding(
                                padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.screenPadding,
                                  16,
                                  AppSpacing.screenPadding,
                                  12,
                                ),
                                sliver: SliverToBoxAdapter(
                                  child: Text(
                                    'Class $classNum',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall,
                                  ),
                                ),
                              ),
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.screenPadding,
                              ),
                              sliver: SliverGrid(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 14,
                                      crossAxisSpacing: 14,
                                      childAspectRatio: 0.62,
                                    ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => BookGridCard(
                                    book: booksByClass[classNum]![index],
                                  ),
                                  childCount: booksByClass[classNum]!.length,
                                ),
                              ),
                            ),
                          ],
                          if (!isSearching)
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.screenPadding,
                                vertical: 24,
                              ),
                              sliver: SliverToBoxAdapter(
                                child: _AddClassBanner(
                                  onTap: _showLibraryFilter,
                                ),
                              ),
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

class _LibraryClassFilterSheet extends ConsumerStatefulWidget {
  const _LibraryClassFilterSheet();

  @override
  ConsumerState<_LibraryClassFilterSheet> createState() =>
      _LibraryClassFilterSheetState();
}

class _LibraryClassFilterSheetState
    extends ConsumerState<_LibraryClassFilterSheet> {
  bool _isSaving = false;
  late String _selectionMode;
  late Set<int> _draftClasses;

  @override
  void initState() {
    super.initState();
    _draftClasses = Set<int>.from(ref.read(libraryClassSelectionProvider));
    final backendPreferences = ref
        .read(backendAccountCacheProvider)
        .libraryPreferences
        .maybeWhen(data: (value) => value, orElse: () => null);
    _selectionMode =
        backendPreferences?.selectionMode ??
        ref
            .read(userPrefsRepositoryProvider)
            .getLibrarySelectionMode(uid: ref.read(accountUidProvider));
  }

  void _selectMode(String mode, Set<int> available, int primaryClass) {
    setState(() {
      _selectionMode = mode;
      if (mode == 'all') {
        _draftClasses = Set<int>.from(available);
      } else if (mode == 'primary') {
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
          .read(libraryClassSelectionProvider.notifier)
          .setClasses(selectedClasses);
      await ref
          .read(userPrefsRepositoryProvider)
          .setLibrarySelectionMode(_selectionMode);
      ref.read(subjectFilterProvider.notifier).setFilter(null);
      if (mounted) Navigator.of(context).pop();
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref
          .read(backendAccountCacheProvider.notifier)
          .saveLibraryPreferences(
            LibraryPreferences(
              selectionMode: _selectionMode,
              selectedClasses: _selectionMode == 'selected'
                  ? (selectedClasses.toList()..sort())
                  : const [],
            ),
          );
      ref.read(subjectFilterProvider.notifier).setFilter(null);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Couldn\'t save Library filter. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final board = ref.watch(userBoardProvider);
    final available = availableClassNumbersForBoard(board).toList()..sort();
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
                        'Filter Library',
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
              'Classes with books',
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

class _AddClassBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _AddClassBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
            color: cs.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 20, color: cs.primary),
            const SizedBox(width: 8),
            Text(
              'Add another class',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: cs.primary,
                fontWeight: AppFontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
