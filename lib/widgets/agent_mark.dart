import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'ai_robot_mark.dart';

// ─── Agent marks ──────────────────────────────────────────────────────────
// Faces for the AI teachers that sit beside the Learn Assist bot. They share
// its dark visor and two eyes, so they read as one family; the body's shape
// and colour say which one it is: a capped round head for the tutor, a set
// square for maths, a speech bubble for English. Each floats and blinks like
// the bot and has one small move of its own: the tutor's tassel sways, the
// maths plus sign turns, the English bubble tilts as if talking.

enum AiAgent {
  tutor(
    Color(0xFF8B76E6),
    Color(0xFF4E3AA8),
    Color(0xFF1D1640),
    Color(0xFFECE8FB),
    Color(0xFF262044),
    Color(0xFF3B2A8C),
    Color(0xFFC4B8F5),
  ),
  maths(
    Color(0xFFE8806A),
    Color(0xFFA8432B),
    Color(0xFF3A140B),
    Color(0xFFFBE8E2),
    Color(0xFF3A211B),
    Color(0xFF8A3220),
    Color(0xFFF2B3A4),
  ),
  english(
    Color(0xFF5E9BDD),
    Color(0xFF24579A),
    Color(0xFF0C2140),
    Color(0xFFE2EDF9),
    Color(0xFF1A2A40),
    Color(0xFF1F4F85),
    Color(0xFFA9CBF0),
  );

  const AiAgent(
    this.bodyLight,
    this.bodyDeep,
    this.visor,
    this._tintLight,
    this._tintDark,
    this._inkLight,
    this._inkDark,
  );

  /// The two ends of the body gradient.
  final Color bodyLight;
  final Color bodyDeep;
  final Color visor;
  final Color _tintLight;
  final Color _tintDark;
  final Color _inkLight;
  final Color _inkDark;

  /// A soft card background in the agent's colour.
  Color tint(Brightness b) => b == Brightness.dark ? _tintDark : _tintLight;

  /// Title ink that reads on [tint].
  Color ink(Brightness b) => b == Brightness.dark ? _inkDark : _inkLight;
}

class AgentMark extends StatefulWidget {
  const AgentMark({super.key, required this.agent, this.size = 56});

  final AiAgent agent;
  final double size;

  @override
  State<AgentMark> createState() => _AgentMarkState();
}

class _AgentMarkState extends State<AgentMark>
    with SingleTickerProviderStateMixin {
  // One slow clock; every loop below divides it evenly, so nothing jumps
  // when it wraps.
  static const _period = 25.2;
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 25200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Same rules as the bot: hold still for tests, reduced motion and
    // off-screen tabs.
    final still =
        AiBot.debugHoldStill ||
        MediaQuery.disableAnimationsOf(context) ||
        !TickerMode.valuesOf(context).enabled;
    if (still) {
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
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.square(widget.size),
          painter: _AgentPainter(widget.agent, _clock, _period),
        ),
      ),
    );
  }
}

class _AgentPainter extends CustomPainter {
  _AgentPainter(this.agent, this.clock, this.period) : super(repaint: clock);

  final AiAgent agent;
  final Animation<double> clock;
  final double period;

  static const _eyeInk = Color(0xFFF2F6F2);

  @override
  void paint(Canvas canvas, Size size) {
    final t = clock.value * period; // seconds
    // Staggered so three in a row don't move in step.
    final lag = agent.index * 0.7;
    final wave = math.sin(2 * math.pi * (t + lag) / 3.6);
    // A quick blink every 4.2 seconds.
    final blinkAt = ((t + lag) % 4.2) / 4.2;
    final blink = blinkAt > 0.93
        ? 1 - 0.88 * math.sin(math.pi * (blinkAt - 0.93) / 0.07)
        : 1.0;

    // Drawn on a 64-unit grid, floating a little.
    canvas.scale(size.width / 64);
    canvas.translate(0, -1.6 * wave);
    final body = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [agent.bodyLight, agent.bodyDeep],
      ).createShader(const Rect.fromLTWH(0, 0, 64, 64));
    final visor = Paint()..color = agent.visor;

    void face(double left, double top, double width, double height) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, width, height),
          const Radius.circular(8),
        ),
        visor,
      );
      final eye = Paint()..color = _eyeInk;
      final cy = top + height / 2;
      for (final cx in [32 - 5.4, 32 + 5.4]) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(cx, cy),
              width: 4.4,
              height: 8.4 * blink,
            ),
            const Radius.circular(2.2),
          ),
          eye,
        );
      }
    }

    switch (agent) {
      case AiAgent.tutor:
        canvas.drawCircle(const Offset(32, 38), 23, body);
        face(17, 30, 30, 19);
        // Mortarboard and tassel.
        canvas.drawPath(
          Path()
            ..moveTo(32, 4)
            ..lineTo(58, 14)
            ..lineTo(32, 24)
            ..lineTo(6, 14)
            ..close(),
          visor,
        );
        // The tassel hangs from the cap's corner and sways.
        final sway = 0.35 * math.sin(2 * math.pi * t / 2.8);
        final tip = Offset(52 + 11 * math.sin(sway), 16 + 11 * math.cos(sway));
        canvas.drawLine(
          const Offset(52, 16),
          tip,
          Paint()
            ..color = agent.visor
            ..strokeWidth = 2.4
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawCircle(
          tip + Offset(2 * math.sin(sway), 2 * math.cos(sway)),
          2.6,
          Paint()..color = const Color(0xFFF4C95D),
        );
      case AiAgent.maths:
        final triangle = Path()
          ..moveTo(32, 10)
          ..lineTo(56, 52)
          ..lineTo(8, 52)
          ..close();
        canvas.drawPath(triangle, body);
        // A fat same-colour outline rounds the corners.
        canvas.drawPath(
          triangle,
          Paint()
            ..shader = body.shader
            ..style = PaintingStyle.stroke
            ..strokeWidth = 10
            ..strokeJoin = StrokeJoin.round,
        );
        face(17, 33, 30, 18);
        final plus = Paint()
          ..color = _eyeInk
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round;
        // The plus makes a quarter turn every 6.3 seconds.
        final turnAt = (t % 6.3) / 6.3;
        final turn = turnAt > 0.85
            ? Curves.easeInOut.transform((turnAt - 0.85) / 0.15) * math.pi / 2
            : 0.0;
        canvas.save();
        canvas.translate(32, 17);
        canvas.rotate(turn);
        canvas.drawLine(const Offset(-3, 0), const Offset(3, 0), plus);
        canvas.drawLine(const Offset(0, -3), const Offset(0, 3), plus);
        canvas.restore();
      case AiAgent.english:
        const r = Radius.circular(14);
        // Tilts gently about its tail, like someone mid-sentence.
        canvas.translate(16, 60);
        canvas.rotate(0.045 * math.sin(2 * math.pi * t / 2.1));
        canvas.translate(-16, -60);
        canvas.drawPath(
          Path()
            ..moveTo(18, 6)
            ..lineTo(46, 6)
            ..arcToPoint(const Offset(60, 20), radius: r)
            ..lineTo(60, 36)
            ..arcToPoint(const Offset(46, 50), radius: r)
            ..lineTo(30, 50)
            ..lineTo(16, 60)
            ..lineTo(16, 49.3)
            ..arcToPoint(const Offset(4, 36), radius: r)
            ..lineTo(4, 20)
            ..arcToPoint(const Offset(18, 6), radius: r)
            ..close(),
          body,
        );
        face(15, 18, 34, 20);
    }
  }

  @override
  bool shouldRepaint(_AgentPainter old) => old.agent != agent;
}
