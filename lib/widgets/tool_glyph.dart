import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ─── Study tool glyphs ────────────────────────────────────────────────────
// Bold, filled pictures for the Home study tools, drawn on a 24-unit grid so
// they stay clear on a solid coloured tile: an open book, a question mark, a
// page, a calendar, a bookmark and a speech bubble with an "A".

enum ToolGlyph { books, quizzes, notes, timetable, bookmarks, vocabulary }

enum _Paint {
  /// A shape filled in the picture's colour.
  fill,

  /// A line in the picture's colour.
  stroke,

  /// A line in the tile's colour: detail cut out of a filled shape.
  cut,
}

typedef _Layer = (String, _Paint);

const Map<ToolGlyph, List<_Layer>> _glyphs = {
  ToolGlyph.books: [
    (
      'M3 6.5A2.5 2.5 0 0 1 5.5 4H11v15.5H5.5A2.5 2.5 0 0 0 3 21zM13 4h5.5A2.5 '
          '2.5 0 0 1 21 6.5V21a2.5 2.5 0 0 0-2.5-1.5H13z',
      _Paint.fill,
    ),
  ],
  ToolGlyph.quizzes: [
    ('M12 2.5a9.5 9.5 0 1 0 0 19 9.5 9.5 0 0 0 0-19z', _Paint.fill),
    ('M9.4 9.4a2.7 2.7 0 1 1 3.9 2.4c-.9.5-1.3 1.1-1.3 2', _Paint.cut),
    ('M12 17v.1', _Paint.cut),
  ],
  ToolGlyph.notes: [
    (
      'M6 2.5h7.5L19.5 8.5V19.5a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2v-15a2 2 0 0 1 '
          '2-2z',
      _Paint.fill,
    ),
    ('M8 12.5h8M8 16.5h5', _Paint.cut),
  ],
  ToolGlyph.timetable: [
    (
      'M5 4.5h14a2.5 2.5 0 0 1 2.5 2.5v11.5A2.5 2.5 0 0 1 19 21H5a2.5 2.5 0 0 '
          '1-2.5-2.5V7A2.5 2.5 0 0 1 5 4.5z',
      _Paint.fill,
    ),
    ('M8 2.5v3.5M16 2.5v3.5', _Paint.stroke),
    ('M2.8 10h18.4', _Paint.cut),
    ('M8 15h.1M12 15h.1M16 15h.1', _Paint.cut),
  ],
  ToolGlyph.bookmarks: [
    (
      'M7.5 2.5h9a2 2 0 0 1 2 2V21.5L12 17l-6.5 4.5V4.5a2 2 0 0 1 2-2z',
      _Paint.fill,
    ),
  ],
  ToolGlyph.vocabulary: [
    (
      'M5 3.5h14A2.5 2.5 0 0 1 21.5 6v8.5A2.5 2.5 0 0 1 19 17h-6l-4.5 '
          '4.2V17H5a2.5 2.5 0 0 1-2.5-2.5V6A2.5 2.5 0 0 1 5 3.5z',
      _Paint.fill,
    ),
    ('M9 13.5l3-7 3 7M10.2 11.5h3.6', _Paint.cut),
  ],
};

class ToolGlyphView extends StatelessWidget {
  const ToolGlyphView({
    super.key,
    required this.glyph,
    required this.color,
    required this.behind,
    this.size = 32,
  });

  final ToolGlyph glyph;
  final Color color;

  /// The tile colour, used for detail cut out of the filled shape.
  final Color behind;
  final double size;

  static String _hex(Color c) =>
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  @override
  Widget build(BuildContext context) {
    const line =
        'fill="none" stroke-width="2.2" stroke-linecap="round" '
        'stroke-linejoin="round"';
    final ink = _hex(color);
    final paths = StringBuffer();
    for (final (d, paint) in _glyphs[glyph]!) {
      paths.write(switch (paint) {
        _Paint.fill => '<path d="$d" fill="$ink"/>',
        _Paint.stroke => '<path d="$d" stroke="$ink" $line/>',
        _Paint.cut => '<path d="$d" stroke="${_hex(behind)}" $line/>',
      });
    }
    return SvgPicture.string(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">$paths</svg>',
      width: size,
      height: size,
      excludeFromSemantics: true,
    );
  }
}
