import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/seed/interactive_diagrams_data.dart';
import '../../providers/regional_language_provider.dart';
import '../../widgets/regional_language_switch.dart';

class DiagramsScreen extends ConsumerWidget {
  const DiagramsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLanguage = ref.watch(regionalLanguageProvider);
    final language = _diagramLanguage(selectedLanguage);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_screenTitle.inLanguage(language)),
        actions: const [RegionalLanguageSwitch()],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.screenPadding),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.screenPadding,
              AppSpacing.screenPadding,
              8,
            ),
            child: Text(
              _screenDescription.inLanguage(language),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
            ),
          ),
          for (final section in DiagramSection.values)
            _DiagramSectionRail(section: section, language: language),
        ],
      ),
    );
  }
}

class _DiagramSectionRail extends StatelessWidget {
  const _DiagramSectionRail({required this.section, required this.language});

  final DiagramSection section;
  final DiagramLanguage language;

  @override
  Widget build(BuildContext context) {
    final diagrams = interactiveDiagrams
        .where((diagram) => diagram.section == section)
        .toList(growable: false);
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
            height: 224,
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
      width: 228,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      diagram.title.inLanguage(language),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: AppFontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _labelCount(diagram.labels.length, language),
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
};

String _labelCount(int count, DiagramLanguage language) => switch (language) {
  DiagramLanguage.english => '$count interactive labels',
  DiagramLanguage.hindi => '$count इंटरैक्टिव लेबल',
  DiagramLanguage.odia => '$count ଟି ଇଣ୍ଟରାକ୍ଟିଭ୍ ଲେବଲ୍',
};

const _screenTitle = DiagramText(en: 'Diagrams', hi: 'आरेख', or: 'ଚିତ୍ର');

const _screenDescription = DiagramText(
  en: 'Swipe through each subject and tap a diagram to explore it.',
  hi: 'हर विषय में स्वाइप करें और समझने के लिए किसी आरेख पर टैप करें।',
  or: 'ପ୍ରତ୍ୟେକ ବିଷୟରେ ସ୍ୱାଇପ୍ କରନ୍ତୁ ଏବଂ ଜାଣିବା ପାଇଁ ଚିତ୍ରକୁ ଟ୍ୟାପ୍ କରନ୍ତୁ।',
);
