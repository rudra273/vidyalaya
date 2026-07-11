import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../data/seed/diagrams_data.dart';
import '../../providers/regional_language_provider.dart';
import '../../widgets/regional_language_switch.dart';

class DiagramsScreen extends ConsumerWidget {
  const DiagramsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(regionalLanguageProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Diagrams'),
        actions: const [RegionalLanguageSwitch()],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.95,
        children: diagramCategories.map((category) {
          return GestureDetector(
            onTap: () {
              context.push('/learn/diagrams/category/${category.id}', extra: category);
            },
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: isDark ? cs.surface : Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                border: Border.all(color: cs.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: category.diagrams.isNotEmpty
                        ? Image.asset(
                            category.diagrams.first.imagePath,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: cs.surfaceContainerHighest,
                            child: Icon(
                              Icons.account_tree_rounded,
                              color: AppColors.textMuted.withValues(alpha: 0.4),
                              size: 40,
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.titleEn,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          lang == RegionalLanguage.hindi
                              ? category.titleHi
                              : category.titleOr,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${category.diagrams.length} diagram${category.diagrams.length == 1 ? '' : 's'}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textMuted,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class DiagramCategoryScreen extends ConsumerWidget {
  final DiagramCategory category;

  const DiagramCategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(regionalLanguageProvider);
    final isHi = lang == RegionalLanguage.hindi;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          '${category.titleEn} / ${isHi ? category.titleHi : category.titleOr}',
        ),
        actions: const [RegionalLanguageSwitch()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          ...category.diagrams.map((diagram) {
            return GestureDetector(
              onTap: () {
                context.push('/learn/diagrams/${diagram.id}', extra: diagram);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: isDark ? cs.surface : Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  border: Border.all(color: cs.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      diagram.imagePath,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${diagram.titleEn} / ${isHi ? diagram.titleHi : diagram.titleOr}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            diagram.descriptionEn,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textMuted,
                                  height: 1.5,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isHi ? diagram.descriptionHi : diagram.descriptionOr,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textMuted,
                                  height: 1.5,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          // Coming Soon Footer
          Container(
            margin: const EdgeInsets.symmetric(vertical: 24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? cs.surfaceContainerHighest.withValues(alpha: 0.5) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Column(
              children: [
                Icon(Icons.construction, color: AppColors.textMuted.withValues(alpha: 0.5), size: 40),
                const SizedBox(height: 16),
                Text(
                  'More diagrams coming soon...',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  isHi ? 'और चित्र जल्द आ रहे हैं...' : 'ଅଧିକ ଚିତ୍ର ଶୀଘ୍ର ଆସୁଛି...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
