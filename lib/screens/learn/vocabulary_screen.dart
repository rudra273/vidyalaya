import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

const _kAlphabet = [
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
  'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
];

class _VocabularyScreenState extends ConsumerState<VocabularyScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _query = '';
  String? _jumpLetter;

  /// The full word list alphabetised once — the sort is stable across
  /// keystrokes, so we sort at init and only filter per query in [_filtered].
  late final List<VocabularyWord> _sortedWords = [...vocabularyWords]
    ..sort((a, b) => a.word.toLowerCase().compareTo(b.word.toLowerCase()));

  /// Index of the first word for each letter, computed once over the sorted
  /// list, so the A-Z slider can jump straight to a card without scanning.
  late final Map<String, int> _letterOffsets = _buildLetterOffsets();

  /// Card height estimate used to convert a list index into a scroll offset.
  /// Cards vary slightly with content length, so this is an approximation —
  /// good enough for a fast jump, and normal scrolling still works exactly.
  static const _estimatedCardExtent = 190.0;

  Map<String, int> _buildLetterOffsets() {
    final offsets = <String, int>{};
    for (var i = 0; i < _sortedWords.length; i++) {
      final letter = _sortedWords[i].word[0].toUpperCase();
      offsets.putIfAbsent(letter, () => i);
    }
    return offsets;
  }

  /// Letters that have at least one word, so the slider can grey out the rest.
  late final Set<String> _availableLetters = _letterOffsets.keys.toSet();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Words matching the search query (by word text or English meaning), over
  /// the pre-sorted list so the result reads like a dictionary.
  List<VocabularyWord> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _sortedWords;
    return _sortedWords
        .where((w) =>
            w.word.toLowerCase().contains(q) ||
            w.meaningEn.toLowerCase().contains(q))
        .toList();
  }

  void _jumpTo(String letter) {
    if (_query.isNotEmpty) return;
    final index = _letterOffsets[letter];
    if (index == null || !_scrollController.hasClients) return;
    final target = index * _estimatedCardExtent;
    final max = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      target.clamp(0, max),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
    HapticFeedback.selectionClick();
    setState(() => _jumpLetter = letter);
  }

  void _clearJumpLetter() {
    if (_jumpLetter == null) return;
    setState(() => _jumpLetter = null);
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(regionalLanguageProvider);
    final words = _filtered;
    final showSlider = _query.isEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Vocabulary'),
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
            child: Stack(
              children: [
                words.isEmpty
                    ? EmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'No words found',
                        subtitle: 'Try a different word or meaning.',
                      )
                    : ListView.separated(
                        controller: _scrollController,
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.screenPadding,
                          0,
                          showSlider ? 40 : AppSpacing.screenPadding,
                          24,
                        ),
                        itemCount: words.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) =>
                            _WordCard(word: words[index], lang: lang),
                      ),
                if (showSlider && words.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: _AlphabetSlider(
                      letters: _kAlphabet,
                      available: _availableLetters,
                      activeLetter: _jumpLetter,
                      onLetterChanged: _jumpTo,
                      onLetterEnd: _clearJumpLetter,
                    ),
                  ),
                if (_jumpLetter != null)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Center(
                        child: _JumpLetterBadge(letter: _jumpLetter!),
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

/// A fast-scroll index down the right edge of the list, like the Contacts app.
/// Tap or drag along the letters to jump the list to that section.
class _AlphabetSlider extends StatefulWidget {
  final List<String> letters;
  final Set<String> available;
  final String? activeLetter;
  final ValueChanged<String> onLetterChanged;
  final VoidCallback onLetterEnd;

  const _AlphabetSlider({
    required this.letters,
    required this.available,
    required this.activeLetter,
    required this.onLetterChanged,
    required this.onLetterEnd,
  });

  @override
  State<_AlphabetSlider> createState() => _AlphabetSliderState();
}

class _AlphabetSliderState extends State<_AlphabetSlider> {
  String? _lastReported;

  void _handleTouch(Offset localPosition, double itemExtent) {
    final index = (localPosition.dy / itemExtent)
        .floor()
        .clamp(0, widget.letters.length - 1);
    final letter = widget.letters[index];
    if (!widget.available.contains(letter)) return;
    if (letter != _lastReported) {
      _lastReported = letter;
      widget.onLetterChanged(letter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemExtent = constraints.maxHeight / widget.letters.length;
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onVerticalDragStart: (d) => _handleTouch(d.localPosition, itemExtent),
          onVerticalDragUpdate: (d) =>
              _handleTouch(d.localPosition, itemExtent),
          onVerticalDragEnd: (_) {
            _lastReported = null;
            widget.onLetterEnd();
          },
          onTapUp: (d) {
            _handleTouch(d.localPosition, itemExtent);
            _lastReported = null;
            widget.onLetterEnd();
          },
          child: Container(
            width: 22,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: widget.letters.map((letter) {
                final isAvailable = widget.available.contains(letter);
                final isActive = widget.activeLetter == letter;
                return Text(
                  letter,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                    color: !isAvailable
                        ? AppColors.textMuted.withValues(alpha: 0.35)
                        : isActive
                            ? cs.primary
                            : AppColors.textMuted,
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

/// Large transient letter shown while dragging the slider, mirroring the
/// iOS Contacts jump-to-letter affordance.
class _JumpLetterBadge extends StatelessWidget {
  final String letter;

  const _JumpLetterBadge({required this.letter});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 72,
      height: 72,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: (isDark ? Colors.black : AppColors.ink).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        letter,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.w700,
        ),
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
