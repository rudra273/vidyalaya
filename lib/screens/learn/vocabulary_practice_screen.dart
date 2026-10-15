import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/seed/vocabulary/vocabulary_practice.dart';
import '../../data/seed/vocabulary/vocabulary_sets.dart';
import '../../data/seed/vocabulary_data.dart';
import '../../providers/regional_language_provider.dart';
import '../../widgets/regional_language_switch.dart';

// ─── Vocabulary practice hub ──────────────────────────────────────────────────
//
// Where flashcards and the meaning quiz start: over the A–Z dictionary (by
// difficulty) or over a phrase set. Each set also has its own browse page.

Color _accent(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? AppColors.cEnglishDark
    : AppColors.cEnglish;

/// Opens flashcards or the quiz for [source] (see [kVocabWordsSource]).
void openVocabPlay(
  BuildContext context, {
  required String source,
  required String mode,
  VocabularyLevel? level,
}) {
  final query = {
    'source': source,
    'mode': mode,
    if (level != null) 'level': level.name,
  };
  context.push(
    Uri(path: '/learn/vocabulary/play', queryParameters: query).toString(),
  );
}

class VocabularyPracticeScreen extends StatefulWidget {
  const VocabularyPracticeScreen({super.key});

  @override
  State<VocabularyPracticeScreen> createState() =>
      _VocabularyPracticeScreenState();
}

class _VocabularyPracticeScreenState extends State<VocabularyPracticeScreen> {
  VocabularyLevel? _level;

  @override
  Widget build(BuildContext context) {
    final accent = _accent(context);
    final textTheme = Theme.of(context).textTheme;
    final count = vocabItemsFor(kVocabWordsSource, level: _level).length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Practise Words'),
        actions: const [RegionalLanguageSwitch()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          Text(
            'Dictionary words',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: AppFontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All levels'),
                selected: _level == null,
                onSelected: (_) => setState(() => _level = null),
              ),
              for (final level in VocabularyLevel.values)
                ChoiceChip(
                  label: Text('${level.label} · ${level.classes}'),
                  selected: _level == level,
                  onSelected: (_) => setState(() => _level = level),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$count words',
            style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          _PlayButtons(
            accent: accent,
            enabled: count >= 4,
            onCards: () => openVocabPlay(
              context,
              source: kVocabWordsSource,
              mode: 'cards',
              level: _level,
            ),
            onQuiz: () => openVocabPlay(
              context,
              source: kVocabWordsSource,
              mode: 'quiz',
              level: _level,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Word sets',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: AppFontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          for (final set in vocabularySets) _SetTile(set: set, accent: accent),
        ],
      ),
    );
  }
}

class _PlayButtons extends StatelessWidget {
  final Color accent;
  final bool enabled;
  final VoidCallback onCards;
  final VoidCallback onQuiz;

  const _PlayButtons({
    required this.accent,
    required this.enabled,
    required this.onCards,
    required this.onQuiz,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: accent),
            onPressed: enabled ? onCards : null,
            icon: const Icon(Icons.style_rounded),
            label: const Text('Flashcards'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: enabled ? onQuiz : null,
            icon: const Icon(Icons.quiz_rounded),
            label: const Text('Quiz'),
          ),
        ),
      ],
    );
  }
}

class _SetTile extends StatelessWidget {
  final VocabSet set;
  final Color accent;

  const _SetTile({required this.set, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
          onTap: () => context.push('/learn/vocabulary/sets/${set.id}'),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(set.icon, color: accent),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        set.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: AppFontWeight.bold,
                        ),
                      ),
                      Text(
                        '${set.subtitle}  ·  ${set.entries.length}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── One set ──────────────────────────────────────────────────────────────────

class VocabularySetScreen extends ConsumerWidget {
  final String setId;

  const VocabularySetScreen({super.key, required this.setId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final set = vocabSetById(setId);
    if (set == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Word set')),
        body: const Center(child: Text('This set does not exist.')),
      );
    }
    final lang = ref.watch(regionalLanguageProvider);
    final accent = _accent(context);
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(set.title),
        actions: const [RegionalLanguageSwitch()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          _PlayButtons(
            accent: accent,
            enabled: set.entries.length >= 4,
            onCards: () =>
                openVocabPlay(context, source: set.id, mode: 'cards'),
            onQuiz: () => openVocabPlay(context, source: set.id, mode: 'quiz'),
          ),
          const SizedBox(height: 16),
          for (final e in set.entries)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.term,
                    style: textTheme.titleMedium?.copyWith(
                      color: accent,
                      fontWeight: AppFontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(e.meaningEn, style: textTheme.bodyMedium),
                  if (lang != RegionalLanguage.english) ...[
                    const SizedBox(height: 4),
                    Text(
                      e.regionalMeaning(lang),
                      style: textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    e.example,
                    style: textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
