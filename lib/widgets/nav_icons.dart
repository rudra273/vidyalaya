import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ─── Navbar icons ─────────────────────────────────────────────────────────
// The app's own tab icons, drawn on a 24-unit grid: a soft house whose door
// is one short line (like the bot's eye), two sparks with inward-curving
// sides, rounded tool tiles, and a head over capsule shoulders. Each is an
// outline when its tab is idle and filled when it is selected.

enum NavIcon { home, ai, explore, profile }

// A layer is a path plus how to paint it.
enum _Paint {
  /// Stroke in the icon colour.
  stroke,

  /// Fill in the icon colour.
  fill,

  /// Stroke in the colour behind the icon: a line cut out of a filled shape.
  cut,
}

typedef _Layer = (String, _Paint);

const _home =
    'M12 3.6c.4 0 .8.15 1.1.42l6.3 5.5c.38.33.6.81.6 1.32V18.5a2 2 0 0 1-2 '
    '2H6a2 2 0 0 1-2-2v-7.66c0-.51.22-.99.6-1.32l6.3-5.5c.3-.27.7-.42 '
    '1.1-.42z';
const _door = 'M12 13.2v3.6';
const _spark =
    'M10.5 3c.7 4.2 3.3 6.8 7.5 7.5-4.2.7-6.8 3.3-7.5 7.5-.7-4.2-3.3-6.8-7.5'
    '-7.5 4.2-.7 6.8-3.3 7.5-7.5z';
const _sparkSmall =
    'M18.5 14.2c.3 1.8 1.4 2.9 3.3 3.3-1.9.4-3 1.5-3.3 3.3-.3-1.8-1.4-2.9-3.3'
    '-3.3 1.9-.4 3-1.5 3.3-3.3z';
const _tiles =
    'M5.5 4.5h3a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1h-3a1 1 0 0 1-1-1v-3a1 1 0 0 1 '
    '1-1zM15.5 4.5h3a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1h-3a1 1 0 0 1-1-1v-3a1 1 0 '
    '0 1 1-1zM5.5 14.5h3a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1h-3a1 1 0 0 1-1-1v-3a1 '
    '1 0 0 1 1-1zM17 14.2a2.8 2.8 0 1 0 0 5.6 2.8 2.8 0 0 0 0-5.6z';
const _head = 'M12 3.5a4 4 0 1 0 0 8 4 4 0 0 0 0-8z';
const _shoulders =
    'M12 14c-4.2 0-7.5 2-7.5 4.6 0 1.1.9 1.9 2 1.9h11c1.1 0 2-.8 2-1.9 0-2.6'
    '-3.3-4.6-7.5-4.6z';

const Map<NavIcon, List<_Layer>> _outline = {
  NavIcon.home: [(_home, _Paint.stroke), (_door, _Paint.stroke)],
  NavIcon.ai: [(_spark, _Paint.stroke), (_sparkSmall, _Paint.stroke)],
  NavIcon.explore: [(_tiles, _Paint.stroke)],
  NavIcon.profile: [(_head, _Paint.stroke), (_shoulders, _Paint.stroke)],
};

// Filled shapes keep their stroke so they are exactly as large as the outline.
const Map<NavIcon, List<_Layer>> _filled = {
  NavIcon.home: [
    (_home, _Paint.fill),
    (_home, _Paint.stroke),
    (_door, _Paint.cut),
  ],
  NavIcon.ai: [
    (_spark, _Paint.fill),
    (_spark, _Paint.stroke),
    (_sparkSmall, _Paint.fill),
    (_sparkSmall, _Paint.stroke),
  ],
  NavIcon.explore: [(_tiles, _Paint.fill), (_tiles, _Paint.stroke)],
  NavIcon.profile: [
    (_head, _Paint.fill),
    (_head, _Paint.stroke),
    (_shoulders, _Paint.fill),
    (_shoulders, _Paint.stroke),
  ],
};

class NavIconView extends StatelessWidget {
  const NavIconView({
    super.key,
    required this.icon,
    required this.selected,
    required this.color,
    required this.behind,
    this.size = 26,
  });

  final NavIcon icon;
  final bool selected;
  final Color color;

  /// The colour the icon sits on, used for lines cut out of a filled shape.
  final Color behind;
  final double size;

  static String _hex(Color c) =>
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  @override
  Widget build(BuildContext context) {
    const stroke =
        'stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"';
    final ink = _hex(color);
    final paths = StringBuffer();
    for (final (d, paint) in (selected ? _filled : _outline)[icon]!) {
      paths.write(switch (paint) {
        _Paint.stroke => '<path d="$d" fill="none" stroke="$ink" $stroke/>',
        _Paint.fill => '<path d="$d" fill="$ink"/>',
        _Paint.cut =>
          '<path d="$d" fill="none" stroke="${_hex(behind)}" $stroke/>',
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
