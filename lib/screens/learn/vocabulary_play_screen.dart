import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/seed/vocabulary/vocabulary_practice.dart';
import '../../data/seed/vocabulary_data.dart';
import '../../providers/regional_language_provider.dart';
import '../../widgets/regional_language_switch.dart';

// ─── Flashcards and quiz ──────────────────────────────────────────────────────

Color _accent(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? AppColors.cEnglishDark
    : AppColors.cEnglish;

/// Routes to the flashcard deck or the meaning quiz from the query parameters
/// set by `openVocabPlay`.
class VocabularyPlayScreen extends StatelessWidget {
  final String source;
  final String mode;
  final VocabularyLevel? level;

  const VocabularyPlayScreen({
    super.key,
    required this.source,
    required this.mode,
    this.level,
  });

  @override
  Widget build(BuildContext context) {
    final items = vocabItemsFor(source, level: level);
    return mode == 'quiz'
        ? _VocabQuizView(items: items)
        : _FlashcardView(items: items);
  }
}

// ─── Flashcards ───────────────────────────────────────────────────────────────

class _FlashcardView extends ConsumerStatefulWidget {
  final List<VocabItem> items;
  const _FlashcardView({required this.items});

  @override
  ConsumerState<_FlashcardView> createState() => _FlashcardViewState();
}

class _FlashcardViewState extends ConsumerState<_FlashcardView> {
  late List<VocabItem> _deck;
  final _missed = <VocabItem>[];
  int _index = 0;
  int _known = 0;
  bool _flipped = false;

  @override
  void initState() {
    super.initState();
    _deck = buildFlashcardDeck(widget.items);
  }

  void _restart(List<VocabItem> deck) => setState(() {
    _deck = deck;
    _missed.clear();
    _index = 0;
    _known = 0;
    _flipped = false;
  });

  void _answer(bool known) {
    final card = _deck[_index];
    setState(() {
      if (known) {
        _known++;
      } else {
        _missed.add(card);
      }
      _index++;
      _flipped = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accent(context);
    final done = _index >= _deck.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Flashcards'),
        actions: const [RegionalLanguageSwitch()],
      ),
      body: _deck.isEmpty
          ? const Center(child: Text('No words to practise yet.'))
          : done
          ? _summary(accent)
          : _card(accent),
    );
  }

  Widget _card(Color accent) {
    final lang = ref.watch(regionalLanguageProvider);
    final card = _deck[_index];
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: _index / _deck.length,
            color: accent,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_index + 1} of ${_deck.length}',
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _flipped = !_flipped),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Container(
                  key: ValueKey('$_index-$_flipped'),
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _flipped
                        ? accent.withValues(alpha: 0.10)
                        : cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(color: accent.withValues(alpha: 0.35)),
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      child: _flipped
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  card.term,
                                  textAlign: TextAlign.center,
                                  style: textTheme.titleMedium?.copyWith(
                                    color: accent,
                                    fontWeight: AppFontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  card.meaningEn,
                                  textAlign: TextAlign.center,
                                  style: textTheme.titleMedium,
                                ),
                                if (lang != RegionalLanguage.english) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    card.regionalMeaning(lang),
                                    textAlign: TextAlign.center,
                                    style: textTheme.titleMedium?.copyWith(
                                      color: cs.onSurface.withValues(
                                        alpha: 0.85,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                Text(
                                  card.example,
                                  textAlign: TextAlign.center,
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  card.term,
                                  textAlign: TextAlign.center,
                                  style: textTheme.headlineMedium?.copyWith(
                                    color: accent,
                                    fontWeight: AppFontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  'Tap to see the meaning',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _flipped ? () => _answer(false) : null,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Again'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: accent),
                  onPressed: _flipped ? () => _answer(true) : null,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Got it'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summary(Color accent) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_rounded, size: 56, color: accent),
          const SizedBox(height: 12),
          Text(
            'You knew $_known of ${_deck.length}',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: AppFontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          if (_missed.isNotEmpty)
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: accent),
              onPressed: () => _restart([..._missed]..shuffle()),
              icon: const Icon(Icons.replay_rounded),
              label: Text('Review ${_missed.length} missed'),
            ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => _restart(buildFlashcardDeck(widget.items)),
            child: const Text('New deck'),
          ),
          TextButton(onPressed: () => context.pop(), child: const Text('Done')),
        ],
      ),
    );
  }
}

// ─── Quiz ─────────────────────────────────────────────────────────────────────

class _VocabQuizView extends ConsumerStatefulWidget {
  final List<VocabItem> items;
  const _VocabQuizView({required this.items});

  @override
  ConsumerState<_VocabQuizView> createState() => _VocabQuizViewState();
}

class _VocabQuizViewState extends ConsumerState<_VocabQuizView> {
  late List<VocabQuizQuestion> _questions;
  int _index = 0;
  int? _selected;
  int _correct = 0;

  @override
  void initState() {
    super.initState();
    _questions = buildVocabQuiz(widget.items);
  }

  void _retry() => setState(() {
    _questions = buildVocabQuiz(widget.items);
    _index = 0;
    _selected = null;
    _correct = 0;
  });

  @override
  Widget build(BuildContext context) {
    final accent = _accent(context);
    final finished = _index >= _questions.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Word Quiz'),
        actions: const [RegionalLanguageSwitch()],
      ),
      body: _questions.isEmpty
          ? const Center(child: Text('Not enough words for a quiz yet.'))
          : finished
          ? _score(accent)
          : _question(accent),
    );
  }

  Widget _question(Color accent) {
    final lang = ref.watch(regionalLanguageProvider);
    final q = _questions[_index];
    final answered = _selected != null;
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        Text(
          '${_index + 1} of ${_questions.length}  ·  Score $_correct',
          style: textTheme.labelMedium?.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: 14),
        Text('What does this mean?', style: textTheme.bodyMedium),
        const SizedBox(height: 6),
        Text(
          q.item.term,
          style: textTheme.headlineSmall?.copyWith(
            color: accent,
            fontWeight: AppFontWeight.bold,
          ),
        ),
        const SizedBox(height: 18),
        for (var i = 0; i < q.choices.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _OptionTile(
              text: q.choices[i].regionalMeaning(lang),
              state: !answered
                  ? _OptionState.idle
                  : i == q.correctIndex
                  ? _OptionState.correct
                  : i == _selected
                  ? _OptionState.wrong
                  : _OptionState.dim,
              onTap: answered
                  ? null
                  : () => setState(() {
                      _selected = i;
                      if (i == q.correctIndex) _correct++;
                    }),
            ),
          ),
        if (answered) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
            ),
            child: Text(
              q.item.example,
              style: textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: accent),
            onPressed: () => setState(() {
              _index++;
              _selected = null;
            }),
            icon: Icon(
              _index == _questions.length - 1
                  ? Icons.emoji_events_rounded
                  : Icons.arrow_forward_rounded,
            ),
            label: Text(
              _index == _questions.length - 1 ? 'See results' : 'Next',
            ),
          ),
        ],
      ],
    );
  }

  Widget _score(Color accent) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_rounded, size: 56, color: accent),
          const SizedBox(height: 12),
          Text(
            '$_correct of ${_questions.length} correct',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: AppFontWeight.bold),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: accent),
            onPressed: _retry,
            icon: const Icon(Icons.replay_rounded),
            label: const Text('Try again'),
          ),
          TextButton(onPressed: () => context.pop(), child: const Text('Done')),
        ],
      ),
    );
  }
}

enum _OptionState { idle, correct, wrong, dim }

class _OptionTile extends StatelessWidget {
  final String text;
  final _OptionState state;
  final VoidCallback? onTap;

  const _OptionTile({
    required this.text,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF3E8E5A);
    const red = Color(0xFFD64545);
    final cs = Theme.of(context).colorScheme;
    final (Color border, Color fill) = switch (state) {
      _OptionState.correct => (green, green.withValues(alpha: 0.15)),
      _OptionState.wrong => (red, red.withValues(alpha: 0.12)),
      _OptionState.dim => (
        cs.outlineVariant,
        cs.surfaceContainerHighest.withValues(alpha: 0.4),
      ),
      _OptionState.idle => (cs.outlineVariant, cs.surfaceContainerHighest),
    };
    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
            border: Border.all(color: border),
          ),
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ),
    );
  }
}
