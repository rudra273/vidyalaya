import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../data/seed/seed_data.dart';
import '../../providers/user_selection_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController(text: 'Student');

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedClasses = ref.watch(userSelectionProvider);
    final available = availableClassNumbers;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar & Name ──────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.tealLight,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _nameController.text.isNotEmpty
                            ? _nameController.text[0].toUpperCase()
                            : 'A',
                        style: TextStyle(
                          color: AppColors.teal,
                          fontWeight: FontWeight.w700,
                          fontSize: 32,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _nameController,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                      decoration: InputDecoration(
                        hintText: 'Your name',
                        hintStyle:
                            Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: AppColors.textMuted,
                                ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  Text(
                    'BSE Odisha · Odia Medium',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Class Selection ────────────────────────────────────
            Text(
              'Your Classes',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Select the classes whose textbooks you want to access.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            ...List.generate(10, (index) {
              final classNumber = index + 1;
              final isAvailable = available.contains(classNumber);
              final isChecked = selectedClasses.contains(classNumber);

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ClassTile(
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
                ),
              );
            }),

            const SizedBox(height: 24),

            // ── App Info ───────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Text(
                    'Vidyālaya',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 0.1.0',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ଶିକ୍ଷାର ଦ୍ୱାର',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
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
            Container(
              width: 36,
              height: 36,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isChecked ? AppColors.teal : AppColors.navy,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Class $classNumber',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color:
                              isAvailable ? AppColors.navy : AppColors.textMuted,
                        ),
                  ),
                  if (!isAvailable)
                    Text(
                      'Coming soon',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                          ),
                    ),
                ],
              ),
            ),
            if (isAvailable)
              Checkbox(
                value: isChecked,
                onChanged: (_) => onToggle?.call(),
              )
            else
              Icon(Icons.lock_outline, size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
