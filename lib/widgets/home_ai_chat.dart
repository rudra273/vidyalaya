import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/theme.dart';
import 'ai_robot_mark.dart';
import 'pressable.dart';

/// A compact conversation preview for the Home screen.
///
/// When the student has asked something recently, the speech bubble turns
/// into a "Continue" prompt for that question, so Home picks up where they
/// left off instead of always showing the same static line.
class HomeAiChat extends StatelessWidget {
  const HomeAiChat({
    super.key,
    required this.onChat,
    this.resumeText,
    this.onResume,
  });

  final VoidCallback onChat;

  /// The last question asked, shown in the bubble as a resume prompt.
  final String? resumeText;

  /// Reopens the conversation [resumeText] was asked in.
  final VoidCallback? onResume;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final sectionColor = dark ? AppColors.green50Dark : AppColors.green100;
    final bubbleColor = dark ? AppColors.green100Dark : Colors.white;
    final bubbleInk = dark ? AppColors.heroInk : AppColors.green700;
    final resume = resumeText?.trim();
    final canResume = resume != null && resume.isNotEmpty && onResume != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        // The bubble starts 29px in (card padding + tail inset) and runs over
        // the left edge of the page stack, stopping 70px from the right so the
        // "?" badge — the part that says "questions" — stays fully visible.
        final bubbleWidth = math.max(140.0, constraints.maxWidth - 99);

        final bubbleText = canResume
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history_rounded, size: 13, color: bubbleInk),
                      const SizedBox(width: 4),
                      Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: AppFontSize.small,
                          fontWeight: AppFontWeight.bold,
                          color: bubbleInk.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    resume,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: bubbleInk,
                      fontWeight: AppFontWeight.semibold,
                      height: 1.35,
                    ),
                  ),
                ],
              )
            : Text(
                'Ask anything from your textbook',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: bubbleInk,
                  fontWeight: AppFontWeight.semibold,
                  height: 1.35,
                ),
              );

        final bubble = Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 9,
              left: -5,
              child: Transform.rotate(
                angle: math.pi / 4,
                child: Container(width: 12, height: 12, color: bubbleColor),
              ),
            ),
            Container(
              width: bubbleWidth,
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(17),
                  bottomLeft: Radius.circular(17),
                  bottomRight: Radius.circular(17),
                ),
                // Lifts the bubble off the pages it now overlaps — in light
                // mode both are white and would otherwise merge.
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: dark ? 0.28 : 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: bubbleText,
            ),
          ],
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
                        const AiRobotMark(),
                        const SizedBox(width: 13),
                        Text(
                          'AI Learning',
                          style: theme.textTheme.headlineSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.only(left: 9),
                      child: canResume
                          ? Semantics(
                              button: true,
                              label: 'Continue: $resume',
                              excludeSemantics: true,
                              child: Pressable(onTap: onResume, child: bubble),
                            )
                          : bubble,
                    ),
                    const SizedBox(height: 17),
                    FilledButton(
                      onPressed: onChat,
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
                            'Ask a question',
                            style: TextStyle(fontWeight: AppFontWeight.bold),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward_rounded, size: 19),
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
      // Mid-tone in dark: a near-white page glared on the dark card.
      dark ? const Color(0xFF8FB9A2) : const Color(0xFFFFFFFF),
      dark ? const Color(0xFF5E8C74) : const Color(0xFFB2D9C1),
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
