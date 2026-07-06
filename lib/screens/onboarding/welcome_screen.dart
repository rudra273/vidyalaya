import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../data/seed/seed_data.dart';
import '../../providers/ingested_books_provider.dart';
import '../../providers/user_selection_provider.dart';
import '../../providers/core_providers.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  int _selectedClass = 8; // Default to class 8 since it's populated
  String _selectedBoard = 'scert_odisha';

  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _selectedBoard = ref.read(userBoardProvider);
    final selectedClasses = ref.read(userSelectionProvider).toList()..sort();
    if (selectedClasses.isNotEmpty) {
      _selectedClass = selectedClasses.first;
    }
    _scrollController = FixedExtentScrollController(
      initialItem: _selectedClass - 1,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Builder(
        builder: (context) {
          final cs = Theme.of(context).colorScheme;
          // Classes with seeded books or AI-ingested content for this board.
          final classesForBoard = availableClassNumbersForBoard(_selectedBoard)
              .union(ref.watch(ingestedBooksProvider).classesFor(_selectedBoard));
          final isAvailable = classesForBoard.contains(_selectedClass);

          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // Header
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/icon/vicon.png',
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome to Vidyālaya',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Let's set up your learning space.",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Board Selection
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedBoard,
                      decoration: InputDecoration(
                        labelText: 'Select Board',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: cs.surface,
                      ),
                      // Every seeded board is listed; ones without books yet
                      // stay visible but disabled, so a new board only needs
                      // its seed entry + books to become pickable.
                      items: [
                        for (final board in boards)
                          DropdownMenuItem(
                            value: board.id,
                            enabled: availableBoardIds.contains(board.id),
                            child: Row(
                              children: [
                                Text(
                                  board.name,
                                  style: TextStyle(
                                    color: availableBoardIds.contains(board.id)
                                        ? null
                                        : AppColors.textMuted.withValues(
                                            alpha: 0.5,
                                          ),
                                  ),
                                ),
                                if (!availableBoardIds.contains(board.id)) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '(coming soon)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedBoard = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Scroll to select your class.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Wheel Picker
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Highlight Box behind the selected item
                        Container(
                          height: 60,
                          margin: const EdgeInsets.symmetric(horizontal: 40),
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: cs.primary.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                        ),

                        // Scroll Wheel
                        ListWheelScrollView.useDelegate(
                          controller: _scrollController,
                          itemExtent: 60,
                          perspective: 0.005,
                          diameterRatio: 1.5,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              _selectedClass = index + 1;
                            });
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: 10,
                            builder: (context, index) {
                              final classNum = index + 1;
                              final isSelected = _selectedClass == classNum;
                              final available = classesForBoard.contains(
                                classNum,
                              );

                              return Center(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: TextStyle(
                                    fontSize: isSelected ? 28 : 22,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? cs.primary
                                        : (available
                                              ? cs.onSurface
                                              : AppColors.textMuted.withValues(
                                                  alpha: 0.4,
                                                )),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('Class $classNum'),
                                      if (!available) ...[
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.lock_outline,
                                          size: 16,
                                          color: AppColors.textMuted,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Availability warning
                  SizedBox(
                    height: 40,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isAvailable ? 0.0 : 1.0,
                      child: Center(
                        child: Text(
                          'Class $_selectedClass books are coming soon!',
                          style: TextStyle(
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Continue Button at bottom
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.screenPadding),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAvailable
                              ? cs.primary
                              : cs.surfaceBright,
                          foregroundColor: isAvailable
                              ? cs.onPrimary
                              : AppColors.textMuted,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: isAvailable ? 2 : 0,
                        ),
                        onPressed: isAvailable
                            ? () {
                                // Save selection
                                ref
                                    .read(userSelectionProvider.notifier)
                                    .setClasses({_selectedClass});
                                ref
                                    .read(userBoardProvider.notifier)
                                    .setBoard(_selectedBoard);

                                // Mark onboarding as complete
                                ref
                                    .read(userPrefsRepositoryProvider)
                                    .setHasCompletedOnboarding(true);

                                // Proceed to home
                                context.go('/');
                              }
                            : null,
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
