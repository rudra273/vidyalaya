import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../data/seed/seed_data.dart';
import '../../providers/user_selection_provider.dart';
import '../../providers/core_providers.dart';
import '../../providers/regional_language_provider.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  int _selectedClass = 8; // Default to class 8 since it's populated
  String _selectedBoard = 'scert_odisha';
  String _preferredLanguage = 'en';

  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _selectedBoard = ref.read(userBoardProvider);
    _selectedClass = ref.read(primaryClassProvider);
    _preferredLanguage =
        ref.read(userPrefsRepositoryProvider).getPreferredLanguage() ?? 'en';
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
          // Onboarding is for the Library, so availability comes from readable
          // books—not from the separate AI ingestion catalog.
          final classesForBoard = availableClassNumbersForBoard(_selectedBoard);
          final isAvailable = classesForBoard.contains(_selectedClass);

          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 32),

                    // Header
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/icon/vmark.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome to Vidya AI',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: AppFontWeight.bold),
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
                    const SizedBox(height: 20),

                    // Board Selection
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
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
                              child: Text(
                                availableBoardIds.contains(board.id)
                                    ? board.name
                                    : '${board.name} (coming soon)',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: availableBoardIds.contains(board.id)
                                      ? null
                                      : AppColors.textMuted.withValues(
                                          alpha: 0.5,
                                        ),
                                ),
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
                    const SizedBox(height: 12),

                    // Preferred language
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _preferredLanguage,
                        decoration: InputDecoration(
                          labelText: 'Preferred language',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: cs.surface,
                        ),
                        items: [
                          for (final language in RegionalLanguage.values)
                            DropdownMenuItem(
                              value: language.code,
                              child: Text(language.labelEn),
                            ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _preferredLanguage = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

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
                    const SizedBox(height: 8),

                    // Wheel Picker
                    SizedBox(
                      height: 132,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Highlight Box behind the selected item
                          Container(
                            height: 52,
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
                            itemExtent: 52,
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
                                      fontSize: isSelected
                                          ? AppFontSize.displaySmall
                                          : AppFontSize.heading,
                                      fontWeight: isSelected
                                          ? AppFontWeight.bold
                                          : AppFontWeight.medium,
                                      color: isSelected
                                          ? cs.primary
                                          : (available
                                                ? cs.onSurface
                                                : AppColors.textMuted
                                                      .withValues(alpha: 0.4)),
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
                              fontWeight: AppFontWeight.semibold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

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
                                      .read(primaryClassProvider.notifier)
                                      .setClass(_selectedClass);
                                  ref
                                      .read(
                                        exploreClassSelectionProvider.notifier,
                                      )
                                      .setClasses({_selectedClass});
                                  ref
                                      .read(
                                        libraryClassSelectionProvider.notifier,
                                      )
                                      .setClasses({_selectedClass});
                                  ref
                                      .read(userBoardProvider.notifier)
                                      .setBoard(_selectedBoard);
                                  ref
                                      .read(userPrefsRepositoryProvider)
                                      .setPreferredLanguage(_preferredLanguage);

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
                              fontSize: AppFontSize.title,
                              fontWeight: AppFontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
