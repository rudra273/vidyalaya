import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/theme.dart';

/// A compact conversation preview for the Home screen.
class HomeAiChat extends StatefulWidget {
  const HomeAiChat({super.key, required this.onChat});

  final VoidCallback onChat;

  @override
  State<HomeAiChat> createState() => _HomeAiChatState();
}

class _HomeAiChatState extends State<HomeAiChat>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blink = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context) ||
        !TickerMode.valuesOf(context).enabled) {
      _blink.stop();
      _blink.value = 0;
    } else if (!_blink.isAnimating) {
      _blink.repeat();
    }
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final sectionColor = dark ? AppColors.green50Dark : AppColors.green100;
    final bubbleColor = dark ? AppColors.green100Dark : Colors.white;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Leave the illustration its own space on small phones too.
        final bubbleWidth = math.min(
          220.0,
          math.max(140.0, constraints.maxWidth - 138),
        );
        return Material(
          color: sectionColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(38),
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(54),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                top: 44,
                right: 5,
                child: ExcludeSemantics(
                  child: SizedBox(
                    width: 120,
                    height: 146,
                    child: CustomPaint(painter: _TextbookArtwork(dark: dark)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ExcludeSemantics(
                          child: _RobotAvatar(blink: _blink, dark: dark),
                        ),
                        const SizedBox(width: 13),
                        Text(
                          'Q&A Assist',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: AppFontWeight.extraBold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.only(left: 9),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            top: 9,
                            left: -5,
                            child: Transform.rotate(
                              angle: math.pi / 4,
                              child: Container(
                                width: 12,
                                height: 12,
                                color: bubbleColor,
                              ),
                            ),
                          ),
                          Container(
                            width: bubbleWidth,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: bubbleColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(17),
                                bottomLeft: Radius.circular(17),
                                bottomRight: Radius.circular(17),
                              ),
                            ),
                            child: Text(
                              'Ask anything from your textbook',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: dark
                                    ? AppColors.heroInk
                                    : AppColors.green700,
                                fontWeight: AppFontWeight.semibold,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 17),
                    FilledButton(
                      onPressed: widget.onChat,
                      style: FilledButton.styleFrom(
                        backgroundColor: dark
                            ? AppColors.green500Dark
                            : AppColors.green600,
                        foregroundColor: dark
                            ? AppColors.heroDark
                            : Colors.white,
                        minimumSize: const Size(128, 48),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: const StadiumBorder(),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Chat',
                            style: TextStyle(fontWeight: AppFontWeight.bold),
                          ),
                          SizedBox(width: 18),
                          Icon(Icons.north_east_rounded, size: 19),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RobotAvatar extends StatelessWidget {
  const _RobotAvatar({required this.blink, required this.dark});

  final Animation<double> blink;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? [AppColors.green500Dark, AppColors.green700Dark]
              : [AppColors.green500, AppColors.green700],
        ),
        boxShadow: [
          BoxShadow(
            color: (dark ? AppColors.green500Dark : AppColors.green500)
                .withValues(alpha: dark ? 0.24 : 0.18),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 29,
          height: 22,
          decoration: BoxDecoration(
            color: dark ? AppColors.heroDark : AppColors.hero,
            borderRadius: BorderRadius.circular(10),
          ),
          child: AnimatedBuilder(
            animation: blink,
            builder: (context, child) {
              final phase = blink.value;
              final eyeHeight = phase < 0.90 || phase > 0.96
                  ? 7.0
                  : phase < 0.93
                  ? 7 - (phase - 0.90) / 0.03 * 6
                  : 1 + (phase - 0.93) / 0.03 * 6;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < 2; i++)
                    SizedBox(
                      width: 10,
                      height: 10,
                      child: Center(
                        child: Container(
                          width: 4,
                          height: eyeHeight,
                          decoration: BoxDecoration(
                            color: AppColors.heroInk,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Layered textbook pages with a question rising above them.
class _TextbookArtwork extends CustomPainter {
  const _TextbookArtwork({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 120, size.height / 146);
    canvas.drawCircle(
      const Offset(68, 88),
      63,
      Paint()..color = dark ? const Color(0x1736C188) : const Color(0x33B4DEC8),
    );

    void page(Rect rect, double angle, Color fill, Color line) {
      canvas.save();
      canvas.translate(rect.center.dx, rect.center.dy);
      canvas.rotate(angle);
      final local = Rect.fromCenter(
        center: Offset.zero,
        width: rect.width,
        height: rect.height,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(local, const Radius.circular(7)),
        Paint()..color = fill,
      );
      for (var i = 0; i < 3; i++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(-rect.width / 2 + 11, 4 + i * 11, rect.width - 26, 2),
            const Radius.circular(1),
          ),
          Paint()..color = line,
        );
      }
      canvas.restore();
    }

    page(
      const Rect.fromLTWH(18, 40, 76, 88),
      -0.16,
      dark ? const Color(0xFF22513D) : const Color(0xFFB8DFC9),
      dark ? const Color(0xFF3B7859) : const Color(0xFF8CC6A5),
    );
    page(
      const Rect.fromLTWH(31, 45, 76, 88),
      0.13,
      dark ? const Color(0xFF327358) : const Color(0xFF8FCBA9),
      dark ? const Color(0xFF4B9773) : const Color(0xFF70B48D),
    );
    page(
      const Rect.fromLTWH(24, 47, 76, 88),
      -0.03,
      dark ? const Color(0xFFCEE8D8) : const Color(0xFFFFFFFF),
      dark ? const Color(0xFF8CBBA1) : const Color(0xFFB2D9C1),
    );

    final badge = Rect.fromCircle(center: const Offset(87, 27), radius: 20);
    canvas.drawCircle(
      badge.center,
      20,
      Paint()..color = dark ? AppColors.green500Dark : AppColors.green600,
    );
    final mark = TextPainter(
      text: TextSpan(
        text: '?',
        style: TextStyle(
          color: dark ? AppColors.heroDark : Colors.white,
          fontSize: AppFontSize.headingLarge,
          fontWeight: AppFontWeight.extraBold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    mark.paint(
      canvas,
      Offset(
        badge.center.dx - mark.width / 2,
        badge.center.dy - mark.height / 2,
      ),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TextbookArtwork oldDelegate) =>
      oldDelegate.dark != dark;
}
