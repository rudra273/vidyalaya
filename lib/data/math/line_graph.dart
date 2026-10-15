// ─── Line graph maths ─────────────────────────────────────────────────────────
//
// Pure helpers for the graph plotter: a line y = mx + c, its intercepts, and
// where two lines meet. Kept out of the screen so it is testable.

class GraphLine {
  final double m;
  final double c;

  const GraphLine(this.m, this.c);

  double at(double x) => m * x + c;

  /// Where the line crosses the x-axis, or `null` when it never does (m = 0,
  /// c ≠ 0) or lies on it (m = 0, c = 0).
  double? get xIntercept => m == 0 ? null : -c / m;

  /// "y = 2x + 3", "y = −x", "y = 4".
  String get equation {
    final slope = m == 0
        ? ''
        : m == 1
        ? 'x'
        : m == -1
        ? '−x'
        : '${_n(m)}x';
    if (m == 0) return 'y = ${_n(c)}';
    if (c == 0) return 'y = $slope';
    return 'y = $slope ${c < 0 ? '−' : '+'} ${_n(c.abs())}';
  }
}

/// Result of intersecting two lines.
sealed class LineMeeting {
  const LineMeeting();
}

class LinesCross extends LineMeeting {
  final double x;
  final double y;
  const LinesCross(this.x, this.y);
}

class LinesParallel extends LineMeeting {
  const LinesParallel();
}

class LinesCoincide extends LineMeeting {
  const LinesCoincide();
}

LineMeeting meet(GraphLine a, GraphLine b) {
  if (a.m == b.m) {
    return a.c == b.c ? const LinesCoincide() : const LinesParallel();
  }
  final x = (b.c - a.c) / (a.m - b.m);
  return LinesCross(x, a.at(x));
}

/// 2 → "2", 2.5 → "2.5", 1/3 → "0.33". Uses a real minus sign.
String _n(double v) {
  final s = v.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  return s.startsWith('-') ? '−${s.substring(1)}' : s;
}

/// Formats a coordinate for display (shared with the screen).
String graphNumber(double v) => _n(v);
