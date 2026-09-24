import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as md;

import '../app/theme.dart';

// ─── AI answer renderer ───────────────────────────────────────────────────────
//
// One markdown renderer for every AI answer (Learn AI chat, Tutor preview), so
// the two never drift apart. On top of plain markdown it renders LaTeX math:
//
//   inline  $…$   \(…\)        → flows inside the sentence
//   display $$…$$ \[…\]        → its own line, scrolls sideways when wide
//
// `\(…\)` / `\[…\]` are normalised to dollar form first (outside code), so the
// parser only has to understand one syntax. Anything unclosed — typical while
// an answer is still streaming — simply stays plain text until it closes.

/// Markdown body for an AI answer, with LaTeX math support.
class AiMarkdown extends StatelessWidget {
  final String text;

  /// Shows the typing cursor after the text while the answer streams in.
  final bool streaming;

  const AiMarkdown({super.key, required this.text, this.streaming = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final body = theme.textTheme.bodyMedium?.copyWith(height: 1.45);

    return MarkdownBody(
      data: _withCursor(normalizeMathDelimiters(text), streaming),
      shrinkWrap: true,
      blockSyntaxes: const [_BlockMathSyntax()],
      inlineSyntaxes: [_InlineMathSyntax()],
      builders: {
        _kInlineMathTag: _InlineMathBuilder(),
        _kBlockMathTag: _BlockMathBuilder(),
      },
      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
        p: body,
        strong: body?.copyWith(fontWeight: AppFontWeight.bold),
        listBullet: body,
        blockquote: body?.copyWith(color: AppColors.textMuted),
        code: theme.textTheme.bodySmall?.copyWith(
          fontFamily: 'monospace',
          backgroundColor: cs.surfaceContainerHighest,
        ),
      ),
    );
  }

  /// A cursor glued to a closing `$$` would break the display-math line, so it
  /// drops to its own line there.
  static String _withCursor(String source, bool streaming) {
    if (!streaming) return source;
    return source.trimRight().endsWith(r'$$') ? '$source\n\n▌' : '$source ▌';
  }
}

// ─── Text helpers (also used for "Copy answer") ───────────────────────────────

const _kInlineMathTag = 'math';
const _kBlockMathTag = 'mathblock';

/// Fenced blocks (closed or still streaming) and inline code spans: math
/// delimiters inside these are left alone.
final _codePattern = RegExp(r'```[\s\S]*?(?:```|$)|`[^`\n]*`');

/// `$$…$$` — may span lines.
final _displayMathPattern = RegExp(r'\$\$((?:\\.|[^\\$]|\$(?!\$))+?)\$\$');

/// `$…$` on one line. The opening `$` can't be followed by a space, the closing
/// one can't follow a space or be followed by a digit, so prices such as
/// "$5 and $10" stay text.
final _inlineMathPattern = RegExp(
  r'\$(?![\s$])((?:\\.|[^\\$\n])*?)(?<![\s\\])\$(?!\d)',
);

/// Rewrites `\(…\)` → `$…$` and `\[…\]` → `$$…$$` everywhere except in code.
String normalizeMathDelimiters(String source) => _mapOutsideCode(
  source,
  (s) => s
      .replaceAllMapped(RegExp(r'\\\[([\s\S]+?)\\\]'), (m) => '\$\$${m[1]}\$\$')
      .replaceAllMapped(RegExp(r'\\\((.+?)\\\)'), (m) => '\$${m[1]!.trim()}\$'),
);

/// Plain text for the clipboard: math keeps its TeX but loses the delimiters,
/// so `$\frac{1}{2}$` pastes as `\frac{1}{2}`.
String aiAnswerPlainText(String source) => _mapOutsideCode(
  normalizeMathDelimiters(source),
  (s) => s
      .replaceAllMapped(_displayMathPattern, (m) => m[1]!.trim())
      .replaceAllMapped(_inlineMathPattern, (m) => m[1]!),
);

String _mapOutsideCode(String source, String Function(String) transform) {
  final out = StringBuffer();
  var last = 0;
  for (final code in _codePattern.allMatches(source)) {
    out
      ..write(transform(source.substring(last, code.start)))
      ..write(code[0]);
    last = code.end;
  }
  out.write(transform(source.substring(last)));
  return out.toString();
}

// ─── Markdown syntaxes ────────────────────────────────────────────────────────

/// Inline `$…$`, plus `$$…$$` that sits inside a sentence.
class _InlineMathSyntax extends md.InlineSyntax {
  _InlineMathSyntax()
    : super(
        '${_displayMathPattern.pattern}|${_inlineMathPattern.pattern}',
        startCharacter: r'$'.codeUnitAt(0),
      );

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final display = match[1] != null;
    final tex = (display ? match[1]! : match[2]!).trim();
    parser.addNode(
      md.Element.text(_kInlineMathTag, tex)
        ..attributes['display'] = display.toString(),
    );
    return true;
  }
}

/// A paragraph that starts with `$$` and closes with `$$`, on one line or many.
/// Unclosed (still streaming) blocks are not claimed, so they read as text.
class _BlockMathSyntax extends md.BlockSyntax {
  const _BlockMathSyntax();

  @override
  RegExp get pattern => RegExp(r'^\s*\$\$');

  @override
  bool canParse(md.BlockParser parser) =>
      pattern.hasMatch(parser.current.content) && _closingLine(parser) != null;

  /// Index (relative to the current line) of the line that closes the block.
  int? _closingLine(md.BlockParser parser) {
    final first = parser.current.content.trim().substring(2);
    if (first.contains(r'$$')) {
      // Single line: only a block if nothing follows the closing `$$`.
      return first.endsWith(r'$$') && first.indexOf(r'$$') == first.length - 2
          ? 0
          : null;
    }
    for (var i = 1; parser.peek(i) != null; i++) {
      final line = parser.peek(i)!.content.trim();
      if (line.contains(r'$$')) return line.endsWith(r'$$') ? i : null;
      if (line.isEmpty) return null;
    }
    return null;
  }

  @override
  md.Node parse(md.BlockParser parser) {
    final end = _closingLine(parser)!;
    final lines = <String>[];
    for (var i = 0; i <= end; i++) {
      lines.add(parser.current.content);
      parser.advance();
    }
    var tex = lines.join('\n').trim();
    tex = tex.substring(2, tex.length - 2).trim();
    // TeX rides in an attribute: a text child would be left dangling as an
    // inline by flutter_markdown's block handling.
    return md.Element(_kBlockMathTag, [])..attributes['tex'] = tex;
  }
}

// ─── Builders ─────────────────────────────────────────────────────────────────

class _InlineMathBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final style = parentStyle ?? preferredStyle;
    final display = element.attributes['display'] == 'true';
    // Returned as Text.rich so flutter_markdown merges it into the paragraph
    // and the equation flows with the words around it.
    return Text.rich(
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _MathView(
            tex: element.textContent,
            display: display,
            style: style,
          ),
        ),
      ),
    );
  }
}

class _BlockMathBuilder extends MarkdownElementBuilder {
  @override
  bool isBlockElement() => true;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: _MathView(
          tex: element.attributes['tex'] ?? '',
          display: true,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

/// Renders TeX; anything the engine can't parse falls back to the raw source
/// in monospace instead of an error box.
class _MathView extends StatelessWidget {
  final String tex;
  final bool display;
  final TextStyle? style;

  const _MathView({required this.tex, required this.display, this.style});

  @override
  Widget build(BuildContext context) {
    final color = style?.color ?? Theme.of(context).colorScheme.onSurface;
    return Math.tex(
      tex,
      mathStyle: display ? MathStyle.display : MathStyle.text,
      textStyle: TextStyle(fontSize: style?.fontSize, color: color),
      onErrorFallback: (_) => Text(
        tex,
        style: style?.copyWith(fontFamily: 'monospace', color: color),
      ),
    );
  }
}
