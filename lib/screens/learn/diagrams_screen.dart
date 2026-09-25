import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/models/class_range.dart';
import '../../data/seed/interactive_diagrams_data.dart';
import '../../providers/regional_language_provider.dart';
import '../../providers/user_selection_provider.dart';
import '../../widgets/class_scope_toggle.dart';
import '../../widgets/regional_language_switch.dart';

class DiagramsScreen extends ConsumerStatefulWidget {
  const DiagramsScreen({super.key});

  @override
  ConsumerState<DiagramsScreen> createState() => _DiagramsScreenState();
}

class _DiagramsScreenState extends ConsumerState<DiagramsScreen> {
  bool _mine = true;

  @override
  Widget build(BuildContext context) {
    final selectedLanguage = ref.watch(regionalLanguageProvider);
    final language = _diagramLanguage(selectedLanguage);
    final classes = ref.watch(exploreClassSelectionProvider);
    final forClasses = interactiveDiagrams
        .where(
          (d) => (diagramClassRanges[d.id] ?? ClassRange.all).fitsAny(classes),
        )
        .toList(growable: false);
    // "My classes" with no matches (e.g. Class 1) falls back to everything.
    final fallback = _mine && forClasses.isEmpty;
    final visible = _mine && !fallback ? forClasses : interactiveDiagrams;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Diagrams'),
        actions: const [RegionalLanguageSwitch()],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.screenPadding),
        children: [
          ClassScopeToggle(
            mine: _mine,
            showingAllAsFallback: fallback,
            onChanged: (v) => setState(() => _mine = v),
          ),
          for (final section in DiagramSection.values)
            if (visible.any((d) => d.section == section))
              _DiagramSectionRail(
                section: section,
                diagrams: [
                  for (final d in visible)
                    if (d.section == section) d,
                ],
                language: language,
              ),
        ],
      ),
    );
  }
}

class _DiagramSectionRail extends StatelessWidget {
  const _DiagramSectionRail({
    required this.section,
    required this.diagrams,
    required this.language,
  });

  final DiagramSection section;
  final List<InteractiveDiagram> diagrams;
  final DiagramLanguage language;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            child: Text(
              _sectionTitle(section).inLanguage(language),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: AppFontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 188,
            child: ListView.separated(
              key: PageStorageKey('diagram-${section.name}-rail'),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              itemCount: diagrams.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  _DiagramCard(diagram: diagrams[index], language: language),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagramCard extends StatelessWidget {
  const _DiagramCard({required this.diagram, required this.language});

  final InteractiveDiagram diagram;
  final DiagramLanguage language;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: 184,
      child: Card(
        margin: EdgeInsets.zero,
        color: isDark ? cs.surface : Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: BorderSide(color: cs.outlineVariant),
        ),
        child: InkWell(
          onTap: () => context.push('/learn/diagrams/${diagram.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ColoredBox(
                  color: cs.surfaceContainerLowest,
                  child: Image.asset(
                    diagram.imagePath,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  diagram.title.inLanguage(language),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: AppFontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

DiagramLanguage _diagramLanguage(RegionalLanguage language) =>
    switch (language) {
      RegionalLanguage.english => DiagramLanguage.english,
      RegionalLanguage.hindi => DiagramLanguage.hindi,
      RegionalLanguage.odia => DiagramLanguage.odia,
    };

DiagramText _sectionTitle(DiagramSection section) => switch (section) {
  DiagramSection.biology => const DiagramText(
    en: 'Biology',
    hi: 'जीव विज्ञान',
    or: 'ଜୀବବିଜ୍ଞାନ',
  ),
  DiagramSection.geography => const DiagramText(
    en: 'Geography',
    hi: 'भूगोल',
    or: 'ଭୂଗୋଳ',
  ),
  DiagramSection.science => const DiagramText(
    en: 'Science',
    hi: 'विज्ञान',
    or: 'ବିଜ୍ଞାନ',
  ),
  DiagramSection.math => const DiagramText(
    en: 'Mathematics',
    hi: 'गणित',
    or: 'ଗଣିତ',
  ),
};
