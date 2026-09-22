import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../data/seed/seed_data.dart';
import '../../data/services/backend_auth_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ingested_books_provider.dart';
import '../../providers/user_selection_provider.dart';

class ClassSelectorScreen extends ConsumerStatefulWidget {
  const ClassSelectorScreen({super.key});

  @override
  ConsumerState<ClassSelectorScreen> createState() =>
      _ClassSelectorScreenState();
}

class _ClassSelectorScreenState extends ConsumerState<ClassSelectorScreen> {
  bool _isSaving = false;
  bool _isDirty = false;
  String _selectionMode = 'selected';
  Set<int> _draftClasses = {};

  @override
  void initState() {
    super.initState();
    _draftClasses = Set<int>.from(ref.read(userSelectionProvider));
    final preferences = ref
        .read(backendAccountCacheProvider)
        .explorePreferences
        .maybeWhen(data: (value) => value, orElse: () => null);
    if (preferences != null) _selectionMode = preferences.selectionMode;
    Future.microtask(() {
      if (!mounted) return;
      ref.read(backendAccountCacheProvider.notifier).ensureExplorePreferences();
    });
  }

  void _selectMode(String mode, Set<int> available, int? primaryClass) {
    setState(() {
      _selectionMode = mode;
      _isDirty = true;
      if (mode == 'all') {
        _draftClasses = Set<int>.from(available);
      } else if (mode == 'primary' && primaryClass != null) {
        _draftClasses = {primaryClass};
      }
    });
  }

  Future<void> _save(Set<int> selectedClasses) async {
    if (selectedClasses.isEmpty || _isSaving) return;
    final signedIn = ref
        .read(authStateProvider)
        .maybeWhen(data: (user) => user != null, orElse: () => false);
    if (!signedIn) {
      ref.read(userSelectionProvider.notifier).setClasses(selectedClasses);
      if (!mounted) return;
      Navigator.of(context).pop();
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
    ref.listen(backendAccountCacheProvider, (previous, next) {
      final preferences = next.explorePreferences.maybeWhen(
        data: (value) => value,
        orElse: () => null,
      );
      if (_isDirty || preferences == null) return;
      if (previous?.explorePreferences == next.explorePreferences) return;
      final board = ref.read(userBoardProvider);
      final available = {
        ...availableClassNumbersForBoard(board),
        ...ref.read(activeIngestedBooksProvider).classesFor(board),
      };
      setState(() {
        _selectionMode = preferences.selectionMode;
        _draftClasses = preferences.selectionMode == 'all'
            ? available
            : preferences.selectedClasses.toSet();
      });
    });
    final account = ref.watch(backendAccountCacheProvider);
    final board = ref.watch(userBoardProvider);
    // A class is available when it has a readable book or an AI textbook.
    final available = {
      ...availableClassNumbersForBoard(board),
      ...ref.watch(activeIngestedBooksProvider).classesFor(board),
    };
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
    final selectedClasses = _draftClasses.intersection(available.toSet());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Your Class',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              8,
              AppSpacing.screenPadding,
              16,
            ),
            child: Text(
              'Select the classes whose textbooks you want to access. '
              'More classes will be added soon!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            child: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('My class'),
                  selected: _selectionMode == 'primary',
                  onSelected:
                      primaryClass != null && available.contains(primaryClass)
                      ? (_) => _selectMode(
                          'primary',
                          available.toSet(),
                          primaryClass,
                        )
                      : null,
                ),
                ChoiceChip(
                  label: const Text('All available'),
                  selected: _selectionMode == 'all',
                  onSelected: (_) =>
                      _selectMode('all', available.toSet(), primaryClass),
                ),
                ChoiceChip(
                  label: const Text('Choose classes'),
                  selected: _selectionMode == 'selected',
                  onSelected: (_) =>
                      _selectMode('selected', available.toSet(), primaryClass),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              itemCount: 12,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final classNumber = index + 1;
                final isAvailable = available.contains(classNumber);
                final isChecked = selectedClasses.contains(classNumber);

                return _ClassTile(
                  classNumber: classNumber,
                  isAvailable: isAvailable,
                  isChecked: isChecked,
                  onToggle: isAvailable
                      ? () {
                          setState(() {
                            _selectionMode = 'selected';
                            _isDirty = true;
                            if (!_draftClasses.add(classNumber)) {
                              _draftClasses.remove(classNumber);
                            }
                          });
                        }
                      : null,
                );
              },
            ),
          ),

          // ── Save button ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedClasses.isEmpty || _isSaving
                    ? null
                    : () => _save(selectedClasses),
                child: Text(_isSaving ? 'Saving…' : 'Save & Go Back'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassTile extends StatelessWidget {
  final int classNumber;
  final bool isAvailable;
  final bool isChecked;
  final VoidCallback? onToggle;

  const _ClassTile({
    required this.classNumber,
    required this.isAvailable,
    required this.isChecked,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final mutedColor =
        Theme.of(context).textTheme.bodySmall?.color ??
        cs.onSurface.withValues(alpha: 0.5);

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isChecked ? cs.secondary : cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isChecked ? cs.primary.withValues(alpha: 0.3) : cs.outline,
          ),
        ),
        child: Row(
          children: [
            // Class number circle
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isChecked
                    ? cs.primary.withValues(alpha: 0.1)
                    : cs.surface,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$classNumber',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isChecked ? cs.primary : cs.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Class $classNumber',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isAvailable ? cs.onSurface : mutedColor,
                    ),
                  ),
                  if (!isAvailable)
                    Text(
                      'Coming soon',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: mutedColor,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),

            // Checkbox
            if (isAvailable)
              Checkbox(value: isChecked, onChanged: (_) => onToggle?.call())
            else
              Icon(Icons.lock_outline, size: 18, color: mutedColor),
          ],
        ),
      ),
    );
  }
}
