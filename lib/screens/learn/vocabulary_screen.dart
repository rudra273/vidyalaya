import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../data/seed/vocabulary_data.dart';
import '../../providers/regional_language_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/regional_language_switch.dart';

/// Browsable, searchable view over the full [vocabularyWords] list. The Home
/// "Word of the day" card samples one entry from the same data; this surfaces
/// the whole set as an Explore tool.
class VocabularyScreen extends ConsumerStatefulWidget {
  const VocabularyScreen({super.key});

  @override
  ConsumerState<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends ConsumerState<VocabularyScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Words matching the search query (by word text or English meaning),
  /// alphabetised so the list reads like a dictionary.
  List<VocabularyWord> get _filtered {
    final q = _query.trim().toLowerCase();
    final words = [...vocabularyWords]
      ..sort((a, b) => a.word.toLowerCase().compareTo(b.word.toLowerCase()));
    if (q.isEmpty) return words;
    return words
        .where((w) =>
            w.word.toLowerCase().contains(q) ||
            w.meaningEn.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(regionalLanguageProvider);
    final words = _filtered;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Vocabulary',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [RegionalLanguageSwitch()],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              4,
              AppSpacing.screenPadding,
              12,
            ),
            child: _SearchField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              onClear: () {
                _searchController.clear();
                setState(() => _query = '');
              },
            ),
          ),
          Expanded(
            child: words.isEmpty
                ? EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No words found',
                    subtitle: 'Try a different word or meaning.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      0,
                      AppSpacing.screenPadding,
                      24,
                    ),
                    itemCount: words.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _WordCard(word: words[index], lang: lang),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search words',
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: onClear,
              ),
        filled: true,
        fillColor: cs.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _WordCard extends StatelessWidget {
  final VocabularyWord word;
  final RegionalLanguage lang;

  const _WordCard({required this.word, required this.lang});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.cEnglishDark : AppColors.cEnglish;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? cs.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  word.word,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                word.partOfSpeech,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '/${word.pronunciation}/',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            word.meaningEn,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(height: 1.4),
          ),
          const SizedBox(height: 6),
          Text(
            word.regionalMeaning(lang),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: cs.onSurface.withValues(alpha: 0.85),
                ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: isDark ? 0.12 : 0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.format_quote_rounded, size: 15, color: accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    word.sentence,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          height: 1.4,
                          fontStyle: FontStyle.italic,
                        ),
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
