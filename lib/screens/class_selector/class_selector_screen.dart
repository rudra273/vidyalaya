import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../data/seed/seed_data.dart';
import '../../providers/user_selection_provider.dart';

class ClassSelectorScreen extends ConsumerWidget {
  const ClassSelectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedClasses = ref.watch(userSelectionProvider);
    final available = availableClassNumbers;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Select Your Class',
          style: Theme.of(context).textTheme.headlineMedium,
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
              AppSpacing.screenPadding, 8, AppSpacing.screenPadding, 16,
            ),
            child: Text(
              'Select the classes whose textbooks you want to access. '
              'More classes will be added soon!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
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
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Save & Go Back'),
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
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isChecked ? AppColors.tealLight : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isChecked
                ? AppColors.teal.withValues(alpha: 0.3)
                : AppColors.border,
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
                    ? AppColors.teal.withValues(alpha: 0.1)
                    : AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$classNumber',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isChecked ? AppColors.teal : AppColors.navy,
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
                          color: isAvailable
                              ? AppColors.navy
                              : AppColors.textMuted,
                        ),
                  ),
                  if (!isAvailable)
                    Text(
                      'Coming soon',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                    ),
                ],
              ),
            ),

            // Checkbox
            if (isAvailable)
              Checkbox(
                value: isChecked,
                onChanged: (_) => onToggle?.call(),
              )
            else
              Icon(Icons.lock_outline, size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
