import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../data/seed/diagrams_data.dart';

class DiagramsScreen extends StatelessWidget {
  const DiagramsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Science Diagrams',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          ...diagramCategories.map((category) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  child: Text(
                    '${category.titleEn} / ${category.titleOr}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
                        ),
                  ),
                ),
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
                        borderRadius: BorderRadius.circular(16),
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
                                  '${diagram.titleEn} / ${diagram.titleOr}',
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
                                  diagram.descriptionOr,
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
                const SizedBox(height: 16),
              ],
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
                  'ଅଧିକ ଚିତ୍ର ଶୀଘ୍ର ଆସୁଛି...',
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
