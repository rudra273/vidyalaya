import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../data/math/line_graph.dart';
import 'math_home_screen.dart';

// ─── Graph plotter ────────────────────────────────────────────────────────────
//
// Drag the sliders to change the slope m and intercept c of y = mx + c. Turn on
// a second line to see where two linear equations meet — the picture behind
// "pair of linear equations" in Classes 9–10.

const _range = 10.0; // the grid shows −10…10 on both axes

class MathGraphScreen extends StatefulWidget {
  const MathGraphScreen({super.key});

  @override
  State<MathGraphScreen> createState() => _MathGraphScreenState();
}

class _MathGraphScreenState extends State<MathGraphScreen> {
  double _m1 = 1, _c1 = 0;
  double _m2 = -1, _c2 = 4;
  bool _second = false;

  @override
  Widget build(BuildContext context) {
    final accent = MathHomeScreen.accentOf(context);
    const second = Color(0xFFE0762B);
    final cs = Theme.of(context).colorScheme;
    final a = GraphLine(_m1, _c1), b = GraphLine(_m2, _c2);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Graph Plotter')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
                child: CustomPaint(
                  painter: _GraphPainter(
                    lines: [(a, accent), if (_second) (b, second)],
                    meeting: _second ? meet(a, b) : null,
                    ink: cs.onSurface,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _LineControls(
            color: accent,
            line: a,
            onM: (v) => setState(() => _m1 = v),
            onC: (v) => setState(() => _c1 = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Add a second line'),
            subtitle: const Text('See where two equations meet'),
            value: _second,
            onChanged: (v) => setState(() => _second = v),
          ),
          if (_second) ...[
            _LineControls(
              color: second,
              line: b,
              onM: (v) => setState(() => _m2 = v),
              onC: (v) => setState(() => _c2 = v),
            ),
            const SizedBox(height: 8),
            _MeetingNote(meeting: meet(a, b)),
          ],
        ],
      ),
    );
  }
}

class _LineControls extends StatelessWidget {
  final Color color;
  final GraphLine line;
  final ValueChanged<double> onM;
  final ValueChanged<double> onC;

  const _LineControls({
    required this.color,
    required this.line,
    required this.onM,
    required this.onC,
  });

  @override
  Widget build(BuildContext context) {
    final x = line.xIntercept;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPad),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            line.equation,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: AppFontWeight.bold,
            ),
          ),
          Text(
            'Slope ${graphNumber(line.m)}  ·  y-intercept ${graphNumber(line.c)}'
            '${x == null ? '' : '  ·  x-intercept ${graphNumber(x)}'}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
          _slider(context, 'm', line.m, -5, 5, onM),
          _slider(context, 'c', line.c, -10, 10, onC),
        ],
      ),
    );
  }

  Widget _slider(
    BuildContext context,
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Row(
      children: [
        SizedBox(width: 20, child: Text(label)),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) * 2).round(),
            activeColor: color,
            label: graphNumber(value),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _MeetingNote extends StatelessWidget {
  final LineMeeting meeting;
  const _MeetingNote({required this.meeting});

  @override
  Widget build(BuildContext context) {
    final text = switch (meeting) {
      LinesCross(:final x, :final y) =>
        'The lines meet at (${graphNumber(x)}, ${graphNumber(y)}): '
            'one solution, so the pair is consistent.',
      LinesParallel() =>
        'The lines are parallel and never meet: no solution, so the pair is '
            'inconsistent.',
      LinesCoincide() =>
        'Both equations draw the same line: infinitely many solutions.',
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
      ),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

class _GraphPainter extends CustomPainter {
  final List<(GraphLine, Color)> lines;
  final LineMeeting? meeting;
  final Color ink;

  const _GraphPainter({
    required this.lines,
    required this.meeting,
    required this.ink,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / (2 * _range);
    Offset toPx(double x, double y) =>
        Offset((x + _range) * unit, (_range - y) * unit);

    final grid = Paint()
      ..color = ink.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    for (var i = -_range.toInt(); i <= _range.toInt(); i++) {
      canvas.drawLine(
        toPx(i.toDouble(), -_range),
        toPx(i.toDouble(), _range),
        grid,
      );
      canvas.drawLine(
        toPx(-_range, i.toDouble()),
        toPx(_range, i.toDouble()),
        grid,
      );
    }
    final axis = Paint()
      ..color = ink.withValues(alpha: 0.7)
      ..strokeWidth = 2;
    canvas.drawLine(toPx(-_range, 0), toPx(_range, 0), axis);
    canvas.drawLine(toPx(0, -_range), toPx(0, _range), axis);

    for (var i = -_range.toInt(); i <= _range.toInt(); i += 2) {
      if (i == 0) continue;
      _label(canvas, '$i', toPx(i.toDouble(), 0) + const Offset(-4, 3));
      _label(canvas, '$i', toPx(0, i.toDouble()) + const Offset(4, -6));
    }

    canvas.save();
    canvas.clipRect(Offset.zero & size);
    for (final (line, color) in lines) {
      canvas.drawLine(
        toPx(-_range, line.at(-_range)),
        toPx(_range, line.at(_range)),
        Paint()
          ..color = color
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.restore();

    final cross = meeting;
    if (cross is LinesCross &&
        cross.x.abs() <= _range &&
        cross.y.abs() <= _range) {
      final p = toPx(cross.x, cross.y);
      canvas.drawCircle(p, 7, Paint()..color = ink);
      canvas.drawCircle(p, 4, Paint()..color = Colors.white);
    }
  }

  void _label(Canvas canvas, String text, Offset at) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: ink.withValues(alpha: 0.6), fontSize: 9),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at);
  }

  @override
  bool shouldRepaint(_GraphPainter old) =>
      old.lines != lines || old.meeting != meeting || old.ink != ink;
}
