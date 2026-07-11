import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme.dart';

// ─── Code editor ──────────────────────────────────────────────────────────────
//
// A monospace, terminal-styled multiline field for writing/editing Python.
// Smart quotes and autocorrect are OFF — smart quotes would silently turn "..."
// into “...” and break string literals. A helper-key row above the field inserts
// the fiddly symbols (indent, colon, quotes, brackets) at the cursor, which is
// the single biggest win for typing code on a phone keyboard.

class PyEditor extends StatefulWidget {
  final TextEditingController controller;
  final int minLines;

  const PyEditor({
    super.key,
    required this.controller,
    this.minLines = 4,
  });

  @override
  State<PyEditor> createState() => _PyEditorState();
}

class _PyEditorState extends State<PyEditor> {
  final FocusNode _focus = FocusNode();

  // Symbols — the fiddly punctuation that's slow to reach on a phone keyboard.
  static const _symbols = ['⇥', ':', '( )', '[ ]', '"', "'", '=', ',', '#'];

  // Keywords — tap to drop a ready-made Python snippet at the cursor. Each
  // entry is (chip label, text to insert, where the caret lands afterwards),
  // so tapping `print` inserts `print()` with the cursor already between the
  // brackets, ready to type.
  static const _keywords = <(String, String, int)>[
    ('print', 'print()', 6),
    ('input', 'input()', 6),
    ('if', 'if :', 3),
    ('elif', 'elif :', 5),
    ('else', 'else:', 5),
    ('for', 'for i in range():', 15),
    ('while', 'while :', 6),
    ('range', 'range()', 6),
    ('len', 'len()', 4),
    ('int', 'int()', 4),
    ('str', 'str()', 4),
    ('True', 'True', 4),
    ('False', 'False', 5),
    ('and', 'and ', 4),
    ('or', 'or ', 3),
    ('not', 'not ', 4),
  ];

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _insertSymbol(String key) {
    String insert;
    int caretOffset;
    switch (key) {
      case '⇥':
        insert = '    ';
        caretOffset = 4;
      case '( )':
        insert = '()';
        caretOffset = 1;
      case '[ ]':
        insert = '[]';
        caretOffset = 1;
      default:
        insert = key;
        caretOffset = key.length;
    }
    _insert(insert, caretOffset);
  }

  /// Inserts [text] at the cursor, then places the caret [caretOffset]
  /// characters into what was inserted.
  void _insert(String text, int caretOffset) {
    final current = widget.controller.text;
    final sel = widget.controller.selection;
    final start = sel.start < 0 ? current.length : sel.start;
    final end = sel.end < 0 ? current.length : sel.end;

    final newText = current.replaceRange(start, end, text);
    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + caretOffset),
    );
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    // The field sits on a hardcoded-dark container, so the text must stay light
    // in BOTH themes. In light mode the ambient TextTheme colour is dark, and a
    // TextField merges that ambient style over `style` — so we pin the colour on
    // the resolved TextStyle rather than relying on the merge keeping it.
    const codeColor = Color(0xFFE6EDE8);
    final mono = GoogleFonts.jetBrainsMono(
      fontSize: 14,
      height: 1.5,
      color: codeColor,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0E1512),
            borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
            border: Border.all(color: const Color(0xFF25322B)),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focus,
            style: mono,
            maxLines: null,
            minLines: widget.minLines,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            autocorrect: false,
            enableSuggestions: false,
            smartQuotesType: SmartQuotesType.disabled,
            smartDashesType: SmartDashesType.disabled,
            cursorColor: const Color(0xFF6BC48A),
            decoration: const InputDecoration(
              isDense: true,
              // The light theme's InputDecorationTheme sets filled:true with a
              // light fill — that would paint a white box over our dark
              // container in light mode (dark mode's fill blends in, so only
              // light mode broke). Opt out so the dark container shows through.
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: '# write Python here',
              hintStyle: TextStyle(color: Color(0xFF5A6B62)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _RowLabel('Keywords'),
        const SizedBox(height: 6),
        _ChipStrip(
          count: _keywords.length,
          chipBuilder: (i) {
            final (label, text, caret) = _keywords[i];
            return _KeyChip(label: label, onTap: () => _insert(text, caret));
          },
        ),
        const SizedBox(height: 10),
        _RowLabel('Symbols'),
        const SizedBox(height: 6),
        _ChipStrip(
          count: _symbols.length,
          chipBuilder: (i) => _KeyChip(
            label: _symbols[i],
            onTap: () => _insertSymbol(_symbols[i]),
          ),
        ),
      ],
    );
  }
}

// A horizontal, swipeable row of chips that makes its scrollability obvious:
// a fade on whichever edge has more chips off-screen, plus a slim scrollbar
// underneath. Without these cues the row reads as "that's all there is".
class _ChipStrip extends StatefulWidget {
  final int count;
  final Widget Function(int index) chipBuilder;
  const _ChipStrip({required this.count, required this.chipBuilder});

  @override
  State<_ChipStrip> createState() => _ChipStripState();
}

class _ChipStripState extends State<_ChipStrip> {
  final ScrollController _scroll = ScrollController();
  bool _fadeLeft = false;
  bool _fadeRight = true;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    // First frame: decide whether the right fade is even needed (short lists
    // that fit on screen shouldn't show a "there's more" hint).
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    final left = pos.pixels > 2;
    final right = pos.pixels < pos.maxScrollExtent - 2;
    if (left != _fadeLeft || right != _fadeRight) {
      setState(() {
        _fadeLeft = left;
        _fadeRight = right;
      });
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Fade the edge(s) where chips continue off-screen — the primary
        // "there's more, swipe me" cue.
        ShaderMask(
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              _fadeLeft ? Colors.transparent : Colors.white,
              Colors.white,
              Colors.white,
              _fadeRight ? Colors.transparent : Colors.white,
            ],
            stops: const [0.0, 0.06, 0.94, 1.0],
          ).createShader(rect),
          blendMode: BlendMode.dstIn,
          child: SizedBox(
            height: 38,
            child: ListView.separated(
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: widget.count,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) => widget.chipBuilder(i),
            ),
          ),
        ),
        const SizedBox(height: 6),
        // A slim progress track under the row: a second, static cue that the
        // strip scrolls, with a thumb that tracks how far along you are.
        _ScrollProgressBar(controller: _scroll, color: onSurface),
      ],
    );
  }
}

// A thin horizontal bar whose filled portion reflects the chip strip's scroll
// position and visible fraction — like a scrollbar track, but purely a hint.
class _ScrollProgressBar extends StatefulWidget {
  final ScrollController controller;
  final Color color;
  const _ScrollProgressBar({required this.controller, required this.color});

  @override
  State<_ScrollProgressBar> createState() => _ScrollProgressBarState();
}

class _ScrollProgressBarState extends State<_ScrollProgressBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_tick);
    WidgetsBinding.instance.addPostFrameCallback((_) => _tick());
  }

  void _tick() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_tick);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double fraction = 1.0; // fully filled when everything fits (nothing to scroll)
    double offset = 0.0;
    if (widget.controller.hasClients) {
      final pos = widget.controller.position;
      final total = pos.viewportDimension + pos.maxScrollExtent;
      if (total > 0) {
        fraction = (pos.viewportDimension / total).clamp(0.15, 1.0);
        final scrollable = pos.maxScrollExtent;
        final t = scrollable > 0 ? (pos.pixels / scrollable).clamp(0.0, 1.0) : 0.0;
        offset = t * (1 - fraction);
      }
    }
    return SizedBox(
      height: 4,
      child: LayoutBuilder(
        builder: (context, c) {
          return Stack(
            children: [
              // track
              Container(
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // thumb
              Positioned(
                left: c.maxWidth * offset,
                width: c.maxWidth * fraction,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RowLabel extends StatelessWidget {
  final String text;
  const _RowLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _KeyChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _KeyChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          alignment: Alignment.center,
          constraints: const BoxConstraints(minWidth: 44),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
