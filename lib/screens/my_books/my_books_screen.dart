import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../providers/books_provider.dart';
import '../../providers/user_selection_provider.dart';
import '../../data/models/book.dart';
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
    final selectedClasses = ref.watch(userSelectionProvider);
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
        ? '${selectedClasses.map((c) => "Class $c").join(", ")} · ${_boardLabel(selectedBoard)} · ${allSelectedBooks.length} books'
        : 'No class selected';

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitle(
            title: 'Library',
            sub: sub,
            trailing: IconBox(
              icon: _searchActive ? Icons.close_rounded : Icons.search_rounded,
              onTap: _toggleSearch,
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
                    onCtaTap: () => context.push('/class-selector'),
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
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
                                  onTap: () =>
                                      context.push('/class-selector'),
                                ),
                              ),
                            ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  static String _boardLabel(String? board) {
    if (board == null) return '';
    if (board == 'scert_odisha') return 'SCERT Odisha';
    return board;
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
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
