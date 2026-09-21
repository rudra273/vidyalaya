import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../data/seed/seed_data.dart';
import '../../data/services/backend_auth_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_selection_provider.dart';

class ClassSelectorScreen extends ConsumerStatefulWidget {
  const ClassSelectorScreen({super.key});

  @override
  ConsumerState<ClassSelectorScreen> createState() =>
      _ClassSelectorScreenState();
}

class _ClassSelectorScreenState extends ConsumerState<ClassSelectorScreen> {
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      ref.read(backendAccountCacheProvider.notifier).ensureExplorePreferences();
    });
  }

  Future<void> _save(Set<int> selectedClasses) async {
    if (selectedClasses.isEmpty || _isSaving) return;
    final signedIn = ref
        .read(authStateProvider)
        .maybeWhen(data: (user) => user != null, orElse: () => false);
    if (!signedIn) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _isSaving = true);
    try {
      await ref
          .read(backendAccountCacheProvider.notifier)
          .saveExplorePreferences(
            ExplorePreferences(
              selectionMode: 'selected',
              selectedClasses: selectedClasses.toList()..sort(),
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
    final selectedClasses = ref.watch(userSelectionProvider);
    final board = ref.watch(userBoardProvider);
    // Library availability is separate from AI ingestion. A class must have
    // readable books for the selected board before it can be chosen here.
    final available = availableClassNumbersForBoard(board);

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
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              itemCount: 10,
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
                          ref
                              .read(userSelectionProvider.notifier)
                              .toggleClass(classNumber);
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
