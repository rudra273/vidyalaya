import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/theme.dart';

// ─── AI bot ───────────────────────────────────────────────────────────────
// The assistant's mascot: a green tile with a small robot face. It has six
// moods so the same face can react to what the student is doing — idle on
// Home, listening while they type, thinking before an answer, answering while
// it streams, cheering on a win and resting when the day's questions run out.
// Every inner measurement scales from the 44px design.

enum BotMood {
  /// Breathes, blinks and glances around. The default everywhere.
  idle,

  /// Leans in with wide eyes and a soft pulse ring: the student is typing.
  listening,

  /// Three bouncing dots and a light sweep: an answer is being prepared.
  thinking,

  /// Eyes pulse in rhythm: the answer is streaming in.
  answering,

  /// Hops with happy eyes and sparkles: a quiz passed, a request approved.
  cheering,

  /// Sleepy eyes, dimmed, floating z's: no questions left, or late at night.
  resting,
}

class AiBot extends StatefulWidget {
  const AiBot({super.key, this.size = 44, this.mood = BotMood.idle});

  /// Outer tile size.
  final double size;
  final BotMood mood;

  /// Holds every bot still, as if reduced motion were on. Widget tests set
  /// this (test/flutter_test_config.dart) so `pumpAndSettle` can settle while
  /// a looping bot is on screen.
  static bool debugHoldStill = false;

  @override
  State<AiBot> createState() => _AiBotState();
}

/// The bot in its idle mood. Kept so existing call sites read unchanged.
class AiRobotMark extends StatelessWidget {
  const AiRobotMark({super.key, this.size = 44, this.mood = BotMood.idle});

  final double size;
  final BotMood mood;

  @override
  Widget build(BuildContext context) => AiBot(size: size, mood: mood);
}

class _AiBotState extends State<AiBot> with SingleTickerProviderStateMixin {
  // One slow clock drives every mood; each reads its own rhythm from the
  // elapsed seconds, so switching mood never restarts or jumps the timeline.
  static const _period = 25.2; // common multiple of every loop below
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 25200),
  );
  bool _still = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still =
        AiBot.debugHoldStill ||
        MediaQuery.disableAnimationsOf(context) ||
        !TickerMode.valuesOf(context).enabled;
    if (_still) {
      _clock.stop();
      _clock.value = 0;
    } else if (!_clock.isAnimating) {
      _clock.repeat();
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final k = widget.size / 44;
    final mood = widget.mood;

    return ExcludeSemantics(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _clock,
          builder: (context, _) {
            final s = _clock.value * _period;
            final pose = _Pose.of(mood, s, still: _still);
            return Stack(
              clipBehavior: Clip.none,
              children: [
                if (mood == BotMood.listening && !_still)
                  Positioned.fill(
                    child: _PulseRing(t: (s % 1.6) / 1.6, k: k),
                  ),
                Transform.translate(
                  offset: Offset(0, pose.lift * k),
                  child: Transform.rotate(
                    angle: pose.tilt,
                    child: Transform.scale(
                      scaleX: pose.squashX,
                      scaleY: pose.squashY,
                      alignment: Alignment.bottomCenter,
                      child: _Body(
                        size: widget.size,
                        k: k,
                        dark: dark,
                        dim: mood == BotMood.resting,
                        glow:
                            mood == BotMood.thinking ||
                            mood == BotMood.answering,
                        child: CustomPaint(
                          size: Size(29 * k, 22 * k),
                          painter: _VisorPainter(
                            mood: mood,
                            seconds: s,
                            still: _still,
                            glance: pose.glance,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (mood == BotMood.cheering) ..._sparkles(s, k, still: _still),
                if (mood == BotMood.resting) ..._zzz(s, k, dark, still: _still),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _sparkles(double s, double k, {required bool still}) {
    const spots = [
      (dx: 38.0, dy: -6.0, size: 7.0, delay: 0.0),
      (dx: -8.0, dy: 8.0, size: 5.0, delay: 0.25),
      (dx: 6.0, dy: -9.0, size: 4.5, delay: 0.5),
    ];
    return [
      for (final p in spots)
        Positioned(
          left: p.dx * k,
          top: p.dy * k,
          child: Opacity(
            opacity: still ? 1 : _wave((s / 1.1) - p.delay),
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: p.size * k,
                height: p.size * k,
                decoration: BoxDecoration(
                  color: const Color(0xFFF6D36B),
                  borderRadius: BorderRadius.circular(1.2 * k),
                ),
              ),
            ),
          ),
        ),
    ];
  }

  List<Widget> _zzz(double s, double k, bool dark, {required bool still}) {
    final color = dark ? AppColors.ink2Dark : AppColors.ink2;
    return [
      for (var i = 0; i < 2; i++)
        Builder(
          builder: (context) {
            final t = still ? 0.4 : ((s / 3) + i * 0.5) % 1;
            return Positioned(
              right: (-4 - 8 * t) * k,
              top: (2 - 12 * t) * k,
              child: Opacity(
                opacity: t < 0.25 ? t * 4 : 1 - t,
                child: Text(
                  'z',
                  style: TextStyle(
                    fontSize: (i == 0 ? 11 : 8) * k,
                    fontWeight: AppFontWeight.bold,
                    color: color,
                    height: 1,
                  ),
                ),
              ),
            );
          },
        ),
    ];
  }
}

/// 0→1→0 over one unit of [x], smooth at both ends.
double _wave(double x) => 0.5 - 0.5 * math.cos((x % 1) * 2 * math.pi);

// ─── Pose: the body's transform for a mood at a moment ───────────────────

class _Pose {
  const _Pose({
    this.lift = 0,
    this.tilt = 0,
    this.squashX = 1,
    this.squashY = 1,
    this.glance = 0,
  });

  /// Vertical offset in 44px-design units (negative = up).
  final double lift;
  final double tilt;
  final double squashX;
  final double squashY;

  /// Eye shift, −1 (left) … 1 (right).
  final double glance;

  static _Pose of(BotMood mood, double s, {required bool still}) {
    if (still) {
      return mood == BotMood.listening
          ? const _Pose(tilt: -0.08)
          : const _Pose();
    }
    switch (mood) {
      case BotMood.idle:
        // Float every 3.6s; a glance right then left every 7s.
        final g = s % 7;
        final glance = g < 4.3
            ? 0.0
            : g < 5.2
            ? 1.0
            : g < 6.3
            ? -1.0
            : 0.0;
        return _Pose(lift: -2 * _wave(s / 3.6), glance: glance);
      case BotMood.listening:
        return _Pose(tilt: -0.08, lift: -1 * _wave(s / 2.4));
      case BotMood.thinking:
        return _Pose(lift: -1 * _wave(s / 1.8), tilt: 0.03 * math.sin(s * 2));
      case BotMood.answering:
        return _Pose(lift: -2 * _wave(s / 1.8));
      case BotMood.cheering:
        // Squash, jump, land, settle — once every 1.1s.
        final t = (s % 1.1) / 1.1;
        if (t < 0.18) {
          final q = t / 0.18;
          return _Pose(squashX: 1 + 0.06 * q, squashY: 1 - 0.08 * q);
        }
        if (t < 0.72) {
          final q = (t - 0.18) / 0.54;
          return _Pose(
            lift: -7 * math.sin(q * math.pi),
            squashX: 0.98,
            squashY: 1.03,
          );
        }
        final q = (t - 0.72) / 0.28;
        return _Pose(squashX: 1 + 0.04 * (1 - q), squashY: 1 - 0.05 * (1 - q));
      case BotMood.resting:
        return _Pose(lift: -1.5 * _wave(s / 5.6));
    }
  }
}

// ─── Body: the green tile and its dark visor ─────────────────────────────

class _Body extends StatelessWidget {
  const _Body({
    required this.size,
    required this.k,
    required this.dark,
    required this.dim,
    required this.glow,
    required this.child,
  });

  final double size;
  final double k;
  final bool dark;
  final bool dim;
  final bool glow;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    var top = dark ? AppColors.green500Dark : AppColors.green500;
    var bottom = dark ? AppColors.green700Dark : AppColors.green700;
    if (dim) {
      // Rested look: same hue, less saturated.
      top = Color.lerp(top, const Color(0xFF7F8F86), 0.45)!;
      bottom = Color.lerp(bottom, const Color(0xFF55625B), 0.45)!;
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17 * k),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [top, bottom],
        ),
        boxShadow: [
          BoxShadow(
            color: top.withValues(
              alpha: dim ? 0.08 : (glow ? 0.38 : (dark ? 0.24 : 0.18)),
            ),
            blurRadius: (glow ? 26 : 20) * k,
            spreadRadius: 2 * k,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Container(
        width: 29 * k,
        height: 22 * k,
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF0B1F17) : AppColors.hero,
          borderRadius: BorderRadius.circular(10 * k),
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}

// ─── Visor: the eyes, drawn per mood ──────────────────────────────────────

class _VisorPainter extends CustomPainter {
  _VisorPainter({
    required this.mood,
    required this.seconds,
    required this.still,
    required this.glance,
  });

  final BotMood mood;
  final double seconds;
  final bool still;
  final double glance;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 29;
    final ink = Paint()..color = AppColors.heroInk;
    final cy = size.height / 2;
    final gap = 10 * k; // centre-to-centre spacing of the two eyes
    final cx = size.width / 2 + glance * 2.5 * k;
    final left = cx - gap / 2;
    final right = cx + gap / 2;

    void bar(double x, double w, double h) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, cy), width: w, height: h),
          Radius.circular(math.min(w, h) / 2),
        ),
        ink,
      );
    }

    switch (mood) {
      case BotMood.idle:
        // Double blink every 4.2s.
        final b = seconds % 4.2;
        var h = 7.0;
        if (!still) {
          if (b > 3.78 && b < 3.9) h = 1.2;
          if (b > 4.03 && b < 4.12) h = 1.2;
        }
        bar(left, 4 * k, h * k);
        bar(right, 4 * k, h * k);
      case BotMood.listening:
        bar(left, 4.4 * k, 10 * k);
        bar(right, 4.4 * k, 10 * k);
      case BotMood.thinking:
        for (var i = 0; i < 3; i++) {
          final t = still ? 0.0 : _wave(seconds / 1.1 - i * 0.15);
          canvas.drawCircle(
            Offset(cx + (i - 1) * 6 * k, cy - 3 * t * k),
            2 * k,
            Paint()
              ..color = AppColors.heroInk.withValues(alpha: 0.55 + 0.45 * t),
          );
        }
        if (!still) {
          // A soft light sweeping across the visor.
          final x =
              ((seconds % 1.8) / 1.8) * (size.width * 1.6) - size.width * 0.3;
          final rect = Rect.fromLTWH(x - 6 * k, 0, 12 * k, size.height);
          canvas.drawRect(
            rect,
            Paint()
              ..shader = LinearGradient(
                colors: [
                  const Color(0x0036C188),
                  const Color(0x5536C188),
                  const Color(0x0036C188),
                ],
              ).createShader(rect),
          );
        }
      case BotMood.answering:
        final a = still ? 1.0 : 0.45 + 0.7 * _wave(seconds / 0.84);
        final b = still ? 1.0 : 0.45 + 0.7 * _wave(seconds / 0.84 - 0.33);
        bar(left, 4 * k, 7 * k * a);
        bar(right, 4 * k, 7 * k * b);
      case BotMood.cheering:
        // Upturned arcs: happy closed eyes.
        final stroke = Paint()
          ..color = AppColors.heroInk
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8 * k
          ..strokeCap = StrokeCap.round;
        for (final x in [left, right]) {
          canvas.drawArc(
            Rect.fromCenter(
              center: Offset(x, cy + 1.5 * k),
              width: 6 * k,
              height: 6 * k,
            ),
            math.pi,
            math.pi,
            false,
            stroke,
          );
        }
      case BotMood.resting:
        bar(left, 6 * k, 1.6 * k);
        bar(right, 6 * k, 1.6 * k);
    }
  }

  @override
  bool shouldRepaint(covariant _VisorPainter old) =>
      old.mood != mood ||
      old.seconds != seconds ||
      old.glance != glance ||
      old.still != still;
}

/// Soft ring that grows and fades around the bot while it listens.
class _PulseRing extends StatelessWidget {
  const _PulseRing({required this.t, required this.k});

  final double t;
  final double k;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Transform.scale(
      scale: 1 + 0.28 * t,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(19 * k),
          border: Border.all(
            color: (dark ? AppColors.green500Dark : AppColors.green500)
                .withValues(alpha: 0.8 * (1 - t)),
            width: 1.5 * k,
          ),
        ),
      ),
    );
  }
}
