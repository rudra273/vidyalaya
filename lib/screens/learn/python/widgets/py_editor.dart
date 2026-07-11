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

  static const _keys = ['⇥', ':', '( )', '[ ]', '"', "'", '=', '#', '+', '*'];

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _insert(String key) {
    final text = widget.controller.text;
    final sel = widget.controller.selection;
    final start = sel.start < 0 ? text.length : sel.start;
    final end = sel.end < 0 ? text.length : sel.end;

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

    final newText = text.replaceRange(start, end, insert);
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
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _keys.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) => _KeyChip(
              label: _keys[i],
              onTap: () => _insert(_keys[i]),
            ),
          ),
        ),
      ],
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
