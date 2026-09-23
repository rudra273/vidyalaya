import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../data/seed/vocabulary_data.dart';
import '../../providers/regional_language_provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/regional_language_switch.dart';

/// Browsable, searchable view over the full [vocabularyWords] list. The Home
/// "Word of the day" card samples one entry from the same data; this surfaces
/// the whole set as an Explore tool.
///
/// The list is split into one sliver section per letter so the A-Z slider can
/// jump to a measured offset rather than an estimated one — see [_jumpToLetter].
class VocabularyScreen extends ConsumerStatefulWidget {
  const VocabularyScreen({super.key});

  @override
  ConsumerState<VocabularyScreen> createState() => _VocabularyScreenState();
}

const _kAlphabet = [
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
  'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
];

/// Height of a sticky letter header. Mirrored by `_kLetterHeaderExtent` in
/// [vocabularyIndexProvider], which uses it to estimate section offsets.
const _kLetterHeaderExtent = 40.0;

/// Extra pre-built area above and below the viewport. The default (250) is
/// barely one card tall, so fast scrolls build cards just-in-time.
const _kCacheExtent = 600.0;

/// How many re-aim passes a jump may take before giving up.
///
/// A hit lands in one or two passes. A miss bisects the scroll range, which
/// needs about log2(extent / section height) passes — ~24 for this list — so
/// the cap is set above that with headroom, and only bounds a pathological
/// case that would otherwise loop.
const _kMaxJumpCorrections = 32;

/// Offset changes below this are treated as arrived, so correcting stops
/// instead of oscillating on sub-pixel differences.
const _kJumpEpsilon = 0.5;

class _VocabularyScreenState extends ConsumerState<VocabularyScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  /// Letter currently highlighted on the slider. Held as a notifier so
  /// dragging repaints only the slider and the badge — not the whole list.
  final _activeLetter = ValueNotifier<String?>(null);

  /// Anchors used to measure each section's true scroll offset.
  final _sectionKeys = <String, GlobalKey>{};

  /// Letter the in-flight jump is converging on. Outlives the slider touch,
  /// so corrections keep running after the finger lifts.
  String? _pendingJump;

  /// Scroll range still under consideration by the in-flight jump's bisection.
  double? _jumpLow;
  double? _jumpHigh;

  String _query = '';

  /// Current search results. Recomputed only when the query changes, so
  /// unrelated rebuilds (slider drags, theme changes) don't re-scan the list.
  List<IndexedWord> _results = const [];

  /// Last normalised query. The leading space is a sentinel — `trim()` means a
  /// real query can never equal it, so the first search always runs.
  String _lastQuery = ' ';

  /// Words already shown in the shuffle card, oldest first. Stepping back walks
  /// this history rather than re-rolling, so "previous" returns the word the
  /// student actually just saw.
  final _shuffleHistory = <IndexedWord>[];

  /// Position within [_shuffleHistory]. Advancing past the end appends a fresh
  /// random pick.
  int _shuffleCursor = -1;

  final _random = Random();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _activeLetter.dispose();
    super.dispose();
  }

  // ─── Search ───

  void _onQueryChanged(String value, VocabularyIndex index) {
    final q = value.trim().toLowerCase();
    if (q == _lastQuery) {
      // Whitespace-only edits ("cat" -> "cat ") can't change the result set.
      if (_query != value) setState(() => _query = value);
      return;
    }

    // Matches shrink monotonically as the query grows, so extending a query
    // only needs to re-filter the previous results. Ranks may change, but a
    // word that failed to match a shorter query can't match a longer one.
    final base = (_lastQuery.isNotEmpty && q.startsWith(_lastQuery))
        ? _results
        : index.words;
    _lastQuery = q;

    setState(() {
      _query = value;
      _results = q.isEmpty ? index.words : _rankedMatches(base, q);
    });
  }

  /// Words matching [query], best matches first.
  ///
  /// Bucketing rather than sorting: [base] is already alphabetical, so
  /// appending in order keeps each tier alphabetical. `List.sort` is not
  /// stable in Dart, so sorting by rank alone would scramble ties.
  List<IndexedWord> _rankedMatches(List<IndexedWord> base, String query) {
    final startsWith = <IndexedWord>[];
    final inWord = <IndexedWord>[];
    final inMeaning = <IndexedWord>[];

    for (final w in base) {
      switch (w.rank(query)) {
        case 0:
          startsWith.add(w);
        case 1:
          inWord.add(w);
        case 2:
          inMeaning.add(w);
      }
    }

    return [...startsWith, ...inWord, ...inMeaning];
  }

  void _clearQuery(VocabularyIndex index) {
    _searchController.clear();
    _lastQuery = '';
    setState(() {
      _query = '';
      _results = index.words;
    });
  }

  // ─── Shuffle card ───

  /// Word currently on the shuffle card, seeding the history on first build.
  IndexedWord? _shuffleWord(VocabularyIndex index) {
    if (index.words.isEmpty) return null;
    if (_shuffleHistory.isEmpty) {
      _shuffleHistory.add(index.words[_random.nextInt(index.words.length)]);
      _shuffleCursor = 0;
    }
    return _shuffleHistory[_shuffleCursor];
  }

  /// Steps forward, appending a fresh random word once the history runs out.
  void _shuffleNext(VocabularyIndex index) {
    if (index.words.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      if (_shuffleCursor < _shuffleHistory.length - 1) {
        _shuffleCursor++;
        return;
      }
      // Re-roll on a repeat so the card visibly changes. One retry is enough:
      // with ~900 words a second collision is vanishingly unlikely, and the
      // guard keeps this bounded rather than looping on a one-word list.
      final current = _shuffleHistory.isEmpty ? null : _shuffleHistory.last;
      var next = index.words[_random.nextInt(index.words.length)];
      if (identical(next, current) && index.words.length > 1) {
        next = index.words[_random.nextInt(index.words.length)];
      }
      _shuffleHistory.add(next);
      _shuffleCursor = _shuffleHistory.length - 1;
    });
  }

  void _shufflePrevious() {
    if (_shuffleCursor <= 0) return;
    HapticFeedback.selectionClick();
    setState(() => _shuffleCursor--);
  }

  // ─── A-Z jumping ───

  /// Jumps to [letter] by hopping to an estimate, then converging on the
  /// section's real offset.
  ///
  /// Every hop is an un-animated [ScrollController.jumpTo]. Animating instead
  /// would drag the scroll position through every intermediate offset, and a
  /// sliver list can only build children in order — so a jump across the
  /// alphabet would build hundreds of cards along the way, which is what made
  /// the slider feel like it hung. A jump lands in one frame and builds only
  /// what is visible.
  ///
  /// A single hop isn't enough on its own: card heights vary with how the
  /// meanings wrap, and a lazy list's `maxScrollExtent` is itself an estimate
  /// that sharpens only as content is laid out. So the first hop just gets
  /// close, and [_convergeOn] then walks in until the section is built — at
  /// which point it can be measured exactly.
  void _jumpToLetter(String letter, VocabularyIndex index) {
    if (_query.isNotEmpty) return;
    if (_sectionKeys[letter] == null || !_scrollController.hasClients) return;

    HapticFeedback.selectionClick();
    _activeLetter.value = letter;
    _pendingJump = letter;
    _jumpLow = null;
    _jumpHigh = null;

    _scrollController.jumpTo(
      (index.sectionOffsetEstimate[letter] ?? 0.0)
          .clamp(0.0, _scrollController.position.maxScrollExtent),
    );
    _convergeOn(letter, index, remaining: _kMaxJumpCorrections);
  }

  /// Steps toward [letter]'s section each frame until it has been built, then
  /// measures it exactly and stops. [remaining] bounds the walk so a target
  /// that never materialises can't loop forever.
  void _convergeOn(String letter, VocabularyIndex index, {required int remaining}) {
    if (remaining <= 0) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      // Bail out if a newer jump has superseded this one, so two quick taps
      // don't leave stale corrections fighting over the position. Tracked
      // separately from the badge, which is cleared as soon as the touch ends.
      if (_pendingJump != letter) return;

      final position = _scrollController.position;
      final box = _sectionKeys[letter]?.currentContext?.findRenderObject();

      if (box != null) {
        // The target is laid out, so this measurement is exact — take it and
        // stop. Re-measuring afterwards would chase the extent estimate as it
        // keeps settling, which oscillates between neighbouring sections
        // instead of converging.
        final exact =
            (RenderAbstractViewport.of(box).getOffsetToReveal(box, 0).offset -
                    _kLetterHeaderExtent)
                .clamp(0.0, position.maxScrollExtent);
        _pendingJump = null;
        if ((exact - position.pixels).abs() < _kJumpEpsilon) return;
        _scrollController.jumpTo(exact);
        return;
      }

      // Still off-screen — step toward it and look again.
      final next = _retargetFromVisible(letter, index, position);
      if (next == null) return;
      if ((next - position.pixels).abs() < _kJumpEpsilon) return;
      _scrollController.jumpTo(next);
      _convergeOn(letter, index, remaining: remaining - 1);
    });
  }

  /// Re-aims when [letter]'s section is still off-screen.
  ///
  /// Sections are in alphabetical order, so whichever one is currently on
  /// screen says which side of the target we are on. That turns the search into
  /// a bisection over the scroll range: each pass halves the interval, so it
  /// converges in a bounded number of frames no matter how wrong the initial
  /// height estimate was. Scaling by an estimate ratio was tried first and
  /// diverged — a lazy list's extent is itself an estimate, so the ratio can
  /// point the wrong way.
  double? _retargetFromVisible(
    String letter,
    VocabularyIndex index,
    ScrollPosition position,
  ) {
    final targetRank = index.letters.indexOf(letter);
    if (targetRank < 0) return null;

    // The closest laid-out section tells us which direction to move.
    int? visibleRank;
    for (final entry in _sectionKeys.entries) {
      if (entry.value.currentContext?.findRenderObject() == null) continue;
      final rank = index.letters.indexOf(entry.key);
      if (rank < 0) continue;
      if (visibleRank == null || (rank - targetRank).abs() < (visibleRank - targetRank).abs()) {
        visibleRank = rank;
      }
    }
    if (visibleRank == null) return null;
    if (visibleRank == targetRank) return null; // already there

    final pixels = position.pixels;
    if (visibleRank < targetRank) {
      // We're above the target: search the range below us.
      _jumpLow = pixels;
      final high = _jumpHigh ?? position.maxScrollExtent;
      _jumpHigh = high;
      return (pixels + high) / 2;
    }
    // We're below the target: search the range above us.
    _jumpHigh = pixels;
    final low = _jumpLow ?? 0.0;
    return (low + pixels) / 2;
  }

  void _clearActiveLetter() => _activeLetter.value = null;

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(regionalLanguageProvider);
    final index = ref.watch(vocabularyIndexProvider);

    // First build: show everything.
    if (_lastQuery == ' ') {
      _lastQuery = '';
      _results = index.words;
    }

    final searching = _query.trim().isNotEmpty;
    final showSlider = !searching;
    final styles = _WordCardStyles.of(context);
    // Hidden while searching — the student is looking for a specific word, so
    // a random one above the results is just noise.
    final shuffled = searching ? null : _shuffleWord(index);

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
              onChanged: (v) => _onQueryChanged(v, index),
              onClear: () => _clearQuery(index),
            ),
          ),
          if (shuffled != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                0,
                AppSpacing.screenPadding,
                12,
              ),
              child: _ShuffleCard(
                word: shuffled.word,
                lang: lang,
                styles: styles,
                canGoBack: _shuffleCursor > 0,
                onPrevious: _shufflePrevious,
                onNext: () => _shuffleNext(index),
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                if (_results.isEmpty)
                  const EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No words found',
                    subtitle: 'Try a different word or meaning.',
                  )
                else
                  CustomScrollView(
                    controller: _scrollController,
                    cacheExtent: _kCacheExtent,
                    slivers: searching
                        ? _buildFlatSlivers(_results, lang, styles)
                        : _buildSectionedSlivers(index, lang, styles),
                  ),
                if (showSlider && _results.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: _AlphabetSlider(
                      letters: _kAlphabet,
                      available: index.byLetter.keys.toSet(),
                      activeLetter: _activeLetter,
                      onLetterChanged: (l) => _jumpToLetter(l, index),
                      onLetterEnd: _clearActiveLetter,
                    ),
                  ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: ValueListenableBuilder<String?>(
                      valueListenable: _activeLetter,
                      builder: (context, letter, _) => letter == null
                          ? const SizedBox.shrink()
                          : Center(child: _JumpLetterBadge(letter: letter)),
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

  EdgeInsets _listPadding({required bool reserveSlider}) => EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        0,
        reserveSlider ? 40 : AppSpacing.screenPadding,
        0,
      );

  /// Flat result list, used while searching (results span many letters, so
  /// section headers would be noise).
  List<Widget> _buildFlatSlivers(
    List<IndexedWord> words,
    RegionalLanguage lang,
    _WordCardStyles styles,
  ) {
    return [
      SliverPadding(
        padding: _listPadding(reserveSlider: false).copyWith(bottom: 24),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => Padding(
              padding: EdgeInsets.only(bottom: i < words.length - 1 ? 12 : 0),
              child: _WordCard(
                word: words[i].word,
                lang: lang,
                styles: styles,
              ),
            ),
            childCount: words.length,
          ),
        ),
      ),
    ];
  }

  /// One sticky header + one sliver per letter. The per-section [GlobalKey] is
  /// what lets [_jumpToLetter] measure a real offset instead of guessing.
  List<Widget> _buildSectionedSlivers(
    VocabularyIndex index,
    RegionalLanguage lang,
    _WordCardStyles styles,
  ) {
    final slivers = <Widget>[];
    for (final letter in index.letters) {
      final words = index.byLetter[letter]!;
      final key = _sectionKeys.putIfAbsent(letter, GlobalKey.new);

      // Grouping the header with its own section scopes the pinning to that
      // section. Pinned headers that are direct children of the scroll view
      // all stick at once, stacking into a wall that hides the list.
      slivers.add(
        SliverMainAxisGroup(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate:
                  _LetterHeaderDelegate(letter: letter, count: words.length),
            ),
            SliverPadding(
              padding: _listPadding(reserveSlider: true).copyWith(
                top: 4,
                bottom: letter == index.letters.last ? 24 : 16,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    // The anchor is the section's first card. A pinned header
                    // reports its stuck-to-the-top position and a padded sliver
                    // reports the edge above it, so neither measures where the
                    // words actually begin.
                    key: i == 0 ? key : null,
                    padding:
                        EdgeInsets.only(bottom: i < words.length - 1 ? 12 : 0),
                    child: _WordCard(
                      word: words[i].word,
                      lang: lang,
                      styles: styles,
                    ),
                  ),
                  childCount: words.length,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return slivers;
  }
}

/// Pinned letter divider between sections, so the current letter stays visible
/// while scrolling through a long one like S.
class _LetterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String letter;
  final int count;

  const _LetterHeaderDelegate({required this.letter, required this.count});

  @override
  double get minExtent => _kLetterHeaderExtent;

  @override
  double get maxExtent => _kLetterHeaderExtent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.cEnglishDark : AppColors.cEnglish;

    return Container(
      height: _kLetterHeaderExtent,
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 0, 40, 0),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Text(
            letter,
            style: theme.textTheme.titleMedium?.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Divider(
              color: theme.colorScheme.outlineVariant,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_LetterHeaderDelegate old) =>
      old.letter != letter || old.count != count;
}

/// A fast-scroll index down the right edge of the list, like the Contacts app.
/// Tap or drag along the letters to jump the list to that section.
class _AlphabetSlider extends StatefulWidget {
  final List<String> letters;
  final Set<String> available;
  final ValueListenable<String?> activeLetter;
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
            // Only the letters repaint as the drag moves; the list is untouched.
            child: ValueListenableBuilder<String?>(
              valueListenable: widget.activeLetter,
              builder: (context, active, _) => Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: widget.letters.map((letter) {
                  final isAvailable = widget.available.contains(letter);
                  final isActive = active == letter;
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
        // Listens to the controller directly so the clear button appears
        // without the field itself being rebuilt by its parent.
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: onClear,
                ),
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

/// Text styles for [_WordCard], resolved once per screen build.
///
/// The card is on the hot scroll path and its styles depend only on the theme,
/// so resolving them per card meant re-allocating the same `TextStyle`s for
/// every row that scrolled past.
class _WordCardStyles {
  final Color accent;
  final Color surface;
  final Color border;
  final Color quoteBackground;
  final TextStyle? word;
  final TextStyle? partOfSpeech;
  final TextStyle? pronunciation;
  final TextStyle? meaningEn;
  final TextStyle? meaningRegional;
  final TextStyle? sentence;

  const _WordCardStyles({
    required this.accent,
    required this.surface,
    required this.border,
    required this.quoteBackground,
    required this.word,
    required this.partOfSpeech,
    required this.pronunciation,
    required this.meaningEn,
    required this.meaningRegional,
    required this.sentence,
  });

  factory _WordCardStyles.of(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.cEnglishDark : AppColors.cEnglish;

    return _WordCardStyles(
      accent: accent,
      surface: isDark ? cs.surface : Colors.white,
      border: cs.outlineVariant,
      quoteBackground: accent.withValues(alpha: isDark ? 0.12 : 0.07),
      word: tt.headlineMedium?.copyWith(
        color: accent,
        fontWeight: FontWeight.w700,
      ),
      partOfSpeech: tt.labelSmall?.copyWith(
        color: AppColors.textMuted,
        fontStyle: FontStyle.italic,
      ),
      pronunciation: tt.bodySmall?.copyWith(color: AppColors.textMuted),
      meaningEn: tt.bodyMedium?.copyWith(height: 1.4),
      meaningRegional: tt.bodyMedium?.copyWith(
        height: 1.5,
        color: cs.onSurface.withValues(alpha: 0.85),
      ),
      sentence: tt.bodySmall?.copyWith(
        height: 1.4,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

/// Random-word card pinned above the list, with arrows to walk through picks.
///
/// Deliberately more compact than [_WordCard] — it sits above the whole list,
/// so a full-height card would push the alphabet out of view on small phones.
class _ShuffleCard extends StatelessWidget {
  final VocabularyWord word;
  final RegionalLanguage lang;
  final _WordCardStyles styles;
  final bool canGoBack;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _ShuffleCard({
    required this.word,
    required this.lang,
    required this.styles,
    required this.canGoBack,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tt = theme.textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
      decoration: BoxDecoration(
        color: styles.quoteBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: styles.accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          _ShuffleArrow(
            icon: Icons.chevron_left_rounded,
            tooltip: 'Previous word',
            color: styles.accent,
            onPressed: canGoBack ? onPrevious : null,
          ),
          Expanded(
            // Keyed on the word so the fade replays on every step.
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Column(
                key: ValueKey(word.word),
                children: [
                  Text(
                    word.word,
                    textAlign: TextAlign.center,
                    style: tt.titleLarge?.copyWith(
                      color: styles.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '/${word.pronunciation}/ · ${word.partOfSpeech}',
                    textAlign: TextAlign.center,
                    style: styles.pronunciation,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    word.meaningEn,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: styles.meaningEn,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    word.regionalMeaning(lang),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: styles.meaningRegional,
                  ),
                ],
              ),
            ),
          ),
          _ShuffleArrow(
            icon: Icons.chevron_right_rounded,
            tooltip: 'Next word',
            color: styles.accent,
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _ShuffleArrow extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback? onPressed;

  const _ShuffleArrow({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      icon: Icon(icon, size: 26),
      color: color,
      disabledColor: AppColors.textMuted.withValues(alpha: 0.35),
    );
  }
}

class _WordCard extends StatelessWidget {
  final VocabularyWord word;
  final RegionalLanguage lang;
  final _WordCardStyles styles;

  const _WordCard({
    required this.word,
    required this.lang,
    required this.styles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: styles.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: styles.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(word.word, style: styles.word),
              ),
              const SizedBox(width: 10),
              Text(word.partOfSpeech, style: styles.partOfSpeech),
            ],
          ),
          const SizedBox(height: 2),
          Text('/${word.pronunciation}/', style: styles.pronunciation),
          const SizedBox(height: 10),
          Text(word.meaningEn, style: styles.meaningEn),
          const SizedBox(height: 6),
          Text(word.regionalMeaning(lang), style: styles.meaningRegional),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: styles.quoteBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.format_quote_rounded, size: 15, color: styles.accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(word.sentence, style: styles.sentence),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
