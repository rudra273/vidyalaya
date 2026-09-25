import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../app/theme.dart';
import '../../data/lab/lab_catalog.dart';
import '../../data/lab/lab_rules.dart';
import '../../data/models/regional_language.dart';

// ─── Lab kit ──────────────────────────────────────────────────────────────────
//
// The shared pieces every experiment rig paints with: a palette drawn from the
// app theme, a scene (controls + clock + result) and small drawing helpers.
// Each rig is one CustomPainter-style `paint` that is a pure function of its
// scene, so the same rig draws the full bench and the hub thumbnails.

// ─── Palette ──────────────────────────────────────────────────────────────────

class LabPalette {
  final bool dark;

  const LabPalette(this.dark);

  factory LabPalette.of(BuildContext context) =>
      LabPalette(Theme.of(context).brightness == Brightness.dark);

  Color get ink => dark ? AppColors.inkDark : AppColors.ink;
  Color get ink2 => dark ? AppColors.ink2Dark : AppColors.ink2;
  Color get ink3 => dark ? AppColors.ink3Dark : AppColors.ink3;
  Color get surface => dark ? AppColors.surfaceDark : AppColors.surface;
  Color get surface2 => dark ? AppColors.surface2Dark : AppColors.surface2;
  Color get surface3 => dark ? AppColors.surface3Dark : AppColors.surface3;
  Color get hairline => dark ? AppColors.hairlineDark : AppColors.hairline;

  Color get green => dark ? AppColors.green500Dark : AppColors.green500;
  Color get gold => dark ? AppColors.cSocialDark : AppColors.cSocial;
  Color get coral => dark ? AppColors.cMathsDark : AppColors.cMaths;
  Color get amber => dark ? AppColors.cOdiaDark : AppColors.cOdia;
  Color get violet => dark ? AppColors.cTutorDark : AppColors.cTutor;
  Color get blue => dark ? AppColors.cEnglishDark : AppColors.cEnglish;
  Color get sky => dark ? AppColors.cCosmosDark : AppColors.cCosmos;
  Color get teal => dark ? AppColors.cScienceDark : AppColors.cScience;
  Color get pink => dark ? AppColors.cHindiDark : AppColors.cHindi;
  Color get plum => dark ? AppColors.cPeriodicDark : AppColors.cPeriodic;

  /// Warm light from a glowing bulb — the theme gold, lifted.
  Color get glow => Color.lerp(gold, Colors.white, dark ? 0.25 : 0.35)!;

  /// Glass outlines.
  Color get glass => ink2.withValues(alpha: dark ? 0.55 : 0.45);
  Color get glassFill => (dark ? Colors.white : AppColors.green50).withValues(
    alpha: dark ? 0.05 : 0.35,
  );

  Color get water => blue.withValues(alpha: dark ? 0.38 : 0.28);
  Color get metal => dark ? const Color(0xFF8E9A93) : const Color(0xFF6F7A73);

  Color get physics => sky;
  Color get chemistry => plum;

  /// The universal-indicator colour for an outcome key.
  Color indicator(String key) => switch (key) {
    'red' => coral,
    'orange' => gold,
    'green' => green,
    'blue' => blue,
    'violet' => violet,
    _ => ink3,
  };

  /// Accent for each experiment.
  Color accent(String labId) => switch (labId) {
    'circuit' => gold,
    'pendulum' => violet,
    'mirror' => sky,
    'float' => teal,
    'indicator' => pink,
    'fizz' => coral,
    _ => green,
  };

  Color subject(LabSubject subject) =>
      subject == LabSubject.physics ? physics : chemistry;
}

// ─── Scene ────────────────────────────────────────────────────────────────────

class LabScene {
  final Map<String, Object> controls;

  /// Controls as they were before the most recent change.
  final Map<String, Object> previous;

  /// Seconds since the most recent control change.
  final double sinceChange;

  /// Set once the student presses run.
  final LabObservation? result;

  /// Ambient seconds, for idle motion.
  final double t;

  /// Seconds since the run started; 0 before a run.
  final double runT;

  final LabPalette p;

  /// Drawn as a small hub thumbnail: skip fine detail and numbers.
  final bool preview;

  const LabScene({
    required this.controls,
    required this.previous,
    required this.sinceChange,
    required this.result,
    required this.t,
    required this.runT,
    required this.p,
    this.preview = false,
  });

  bool get ran => result != null;

  T c<T>(String key) => controls[key] as T;

  /// 0→1 over [from]…[to] seconds of the run, clamped.
  double seg(double from, double to) =>
      ran ? ((runT - from) / (to - from)).clamp(0.0, 1.0) : 0.0;

  /// 0→1 over [duration] seconds after a control change, eased.
  double changed(double duration) =>
      Curves.easeOutCubic.transform((sinceChange / duration).clamp(0.0, 1.0));

  /// Lerps a numeric control from its previous value.
  double lerpControl(String key, double duration) {
    final to = (controls[key] as num).toDouble();
    final from = ((previous[key] ?? controls[key]) as num).toDouble();
    return from + (to - from) * changed(duration);
  }
}

// ─── Rig ──────────────────────────────────────────────────────────────────────

/// A control strip on the bench: which key it sets and how its tokens look.
class LabControl {
  final String key;
  final IconData icon;

  /// A short caption under a token — a number or a word.
  final String Function(Object value, RegionalLanguage lang) caption;

  /// Draws a token's glyph into a square.
  final void Function(Canvas canvas, Size size, Object value, LabPalette p)
  glyph;

  const LabControl({
    required this.key,
    required this.icon,
    required this.caption,
    required this.glyph,
  });
}

/// One number or word in the result strip.
class LabStat {
  final IconData icon;
  final String value;

  const LabStat(this.icon, this.value);
}

abstract class LabRig {
  const LabRig();

  String get id;
  LabExperiment get lab => labById(id)!;
  IconData get icon;

  /// How long the run animation plays before the result is revealed.
  double get runSeconds;

  List<LabControl> get controls;

  void paint(Canvas canvas, Size size, LabScene s);

  /// Draws a prediction option; [controls] lets it match the current setup.
  void paintOutcome(
    Canvas canvas,
    Size size,
    String outcome,
    Map<String, Object> controls,
    LabPalette p,
  );

  List<LabStat> stats(LabObservation obs, RegionalLanguage lang);

  /// Controls the hub thumbnail plays on its [cycle]th loop.
  Map<String, Object> previewControls(int cycle) => lab.defaultControls;

  /// The spoken description of the stage.
  String describe(LabScene s);

  /// A tap on the stage; return new controls to change them.
  Map<String, Object>? onStageTap(
    Offset local,
    Size size,
    Map<String, Object> controls,
  ) => null;
}

// ─── Clock ────────────────────────────────────────────────────────────────────

/// Drives a [ValueNotifier] of elapsed seconds from a ticker. Stays at 0 when
/// the platform asks for reduced motion.
mixin LabClockMixin<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin<T> {
  final clock = ValueNotifier<double>(0);
  Ticker? _ticker;
  bool still = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    still = MediaQuery.disableAnimationsOf(context);
    _ticker ??= createTicker(
      (elapsed) => clock.value = elapsed.inMicroseconds / 1e6,
    );
    if (still && _ticker!.isActive) _ticker!.stop();
    if (!still && !_ticker!.isActive) _ticker!.start();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    clock.dispose();
    super.dispose();
  }
}

// ─── Painters ─────────────────────────────────────────────────────────────────

class LabStagePainter extends CustomPainter {
  final LabRig rig;
  final ValueListenable<double> clock;
  final Map<String, Object> controls;
  final Map<String, Object> previous;
  final double changedAt;
  final double? runStartedAt;
  final LabObservation? result;
  final LabPalette p;
  final bool still;
  final bool preview;

  LabStagePainter({
    required this.rig,
    required this.clock,
    required this.controls,
    required this.previous,
    required this.changedAt,
    required this.runStartedAt,
    required this.result,
    required this.p,
    required this.still,
    this.preview = false,
  }) : super(repaint: clock);

  LabScene get scene {
    final t = clock.value;
    return LabScene(
      controls: controls,
      previous: previous,
      sinceChange: still ? 99 : t - changedAt,
      result: result,
      t: t,
      runT: result == null
          ? 0
          : still
          ? rig.runSeconds + 60
          : t - (runStartedAt ?? t),
      p: p,
      preview: preview,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    rig.paint(canvas, size, scene);
    canvas.restore();
  }

  @override
  bool shouldRepaint(LabStagePainter old) =>
      old.rig != rig ||
      old.controls != controls ||
      old.result != result ||
      old.runStartedAt != runStartedAt ||
      old.p.dark != p.dark ||
      old.still != still;
}

/// Loops a rig's run on the hub: run, hold, repeat, cycling preview controls.
class LabPreviewPainter extends CustomPainter {
  final LabRig rig;
  final ValueListenable<double> clock;
  final LabPalette p;
  final double offset;

  LabPreviewPainter({
    required this.rig,
    required this.clock,
    required this.p,
    this.offset = 0,
  }) : super(repaint: clock);

  @override
  void paint(Canvas canvas, Size size) {
    final t = clock.value + offset;
    final loop = rig.runSeconds + 2.4;
    final cycle = (t / loop).floor();
    final controls = rig.previewControls(cycle);
    final still = clock.value == 0;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    rig.paint(
      canvas,
      size,
      LabScene(
        controls: controls,
        previous: controls,
        sinceChange: 99,
        result: evaluateLab(rig.id, controls),
        t: t,
        runT: still ? rig.runSeconds + 60 : t - cycle * loop,
        p: p,
        preview: true,
      ),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(LabPreviewPainter old) =>
      old.rig != rig || old.p.dark != p.dark;
}

/// Paints a token glyph through a plain function.
class LabGlyphPainter extends CustomPainter {
  final void Function(Canvas canvas, Size size) draw;
  final Object signature;

  const LabGlyphPainter(this.draw, this.signature);

  @override
  void paint(Canvas canvas, Size size) => draw(canvas, size);

  @override
  bool shouldRepaint(LabGlyphPainter old) => old.signature != signature;
}

// ─── Drawing helpers ──────────────────────────────────────────────────────────

/// Stable pseudo-random 0…1 for particle [i] (no state, same every frame).
double labNoise(int i, [int salt = 0]) {
  final x = math.sin((i + 1) * 12.9898 + salt * 78.233) * 43758.5453;
  return x - x.floorToDouble();
}

double easeOut(double x) => Curves.easeOutCubic.transform(x.clamp(0.0, 1.0));
double easeInOut(double x) =>
    Curves.easeInOutCubic.transform(x.clamp(0.0, 1.0));
double elastic(double x) => Curves.elasticOut.transform(x.clamp(0.0, 1.0));

Paint fillPaint(Color color) => Paint()..color = color;

Paint strokePaint(Color color, double width) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

/// A soft radial glow.
void drawGlow(
  Canvas canvas,
  Offset center,
  double radius,
  Color color,
  double strength,
) {
  if (strength <= 0 || radius <= 0) return;
  canvas.drawCircle(
    center,
    radius,
    Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.75 * strength.clamp(0.0, 1.0)),
          color.withValues(alpha: 0.25 * strength.clamp(0.0, 1.0)),
          color.withValues(alpha: 0),
        ],
        stops: const [0, 0.45, 1],
      ).createShader(Rect.fromCircle(center: center, radius: radius)),
  );
}

/// A shaded ball with a highlight.
void drawBall(Canvas canvas, Offset center, double r, Color color) {
  canvas.drawCircle(
    center,
    r,
    Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.4),
        colors: [
          Color.lerp(color, Colors.white, 0.45)!,
          color,
          Color.lerp(color, Colors.black, 0.35)!,
        ],
        stops: const [0, 0.55, 1],
      ).createShader(Rect.fromCircle(center: center, radius: r)),
  );
}

/// A five-point star.
Path starPath(Offset c, double r, [double inner = 0.45, double spin = 0]) {
  final path = Path();
  for (var i = 0; i < 10; i++) {
    final radius = i.isEven ? r : r * inner;
    final a = -math.pi / 2 + spin + i * math.pi / 5;
    final point = c + Offset(math.cos(a), math.sin(a)) * radius;
    i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
  }
  return path..close();
}

/// A dashed straight line.
void drawDashed(
  Canvas canvas,
  Offset a,
  Offset b,
  Paint paint, {
  double dash = 6,
  double gap = 5,
  double phase = 0,
}) {
  final length = (b - a).distance;
  if (length == 0) return;
  final dir = (b - a) / length;
  var d = -(phase % (dash + gap));
  while (d < length) {
    final s = math.max(d, 0.0);
    final e = math.min(d + dash, length);
    if (e > s) canvas.drawLine(a + dir * s, a + dir * e, paint);
    d += dash + gap;
  }
}

/// Numbers and symbols drawn on the stage (never sentences).
void drawTag(
  Canvas canvas,
  String text,
  Offset center,
  Color color, {
  double size = 12,
  Color? background,
  FontWeight weight = FontWeight.w800,
}) {
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: weight,
        height: 1,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  if (background != null) {
    final rect = Rect.fromCenter(
      center: center,
      width: tp.width + size * 1.1,
      height: tp.height + size * 0.7,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(rect.height / 2)),
      fillPaint(background),
    );
  }
  tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
}

/// Rising bubbles inside [area], looping on [t].
void drawBubbles(
  Canvas canvas,
  Rect area,
  double t,
  Color color, {
  int count = 8,
  double speed = 1,
  double size = 1,
  int salt = 0,
}) {
  final stroke = strokePaint(color, 1.2 * size);
  final fill = fillPaint(color.withValues(alpha: 0.18));
  for (var i = 0; i < count; i++) {
    final life = (t * speed * (0.5 + labNoise(i, salt)) + labNoise(i, salt + 1))
        .remainder(1.0);
    final x =
        area.left +
        area.width * labNoise(i, salt + 2) +
        math.sin(t * 3 + i) * 3 * size;
    final y = area.bottom - area.height * life;
    final r = (1.5 + 2.5 * labNoise(i, salt + 3)) * size * (0.6 + life * 0.5);
    canvas.drawCircle(Offset(x, y), r, fill);
    canvas.drawCircle(Offset(x, y), r, stroke);
  }
}
