import 'package:flutter/material.dart';

import '../app/theme.dart';

// ─── AI robot mark ────────────────────────────────────────────────────────
// The assistant's mascot: a green gradient tile with a small robot face that
// blinks every few seconds. Used wherever the app stands in for "the AI" —
// the Home AI card and the AI tab's ask card — so the assistant has one face.

class AiRobotMark extends StatefulWidget {
  const AiRobotMark({super.key, this.size = 44});

  /// Outer tile size. Every inner measurement scales from the 44px design.
  final double size;

  @override
  State<AiRobotMark> createState() => _AiRobotMarkState();
}

class _AiRobotMarkState extends State<AiRobotMark>
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
    final dark = Theme.of(context).brightness == Brightness.dark;
    final k = widget.size / 44;

    return ExcludeSemantics(
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17 * k),
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
              blurRadius: 20 * k,
              spreadRadius: 2 * k,
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 29 * k,
            height: 22 * k,
            decoration: BoxDecoration(
              color: dark ? AppColors.heroDark : AppColors.hero,
              borderRadius: BorderRadius.circular(10 * k),
            ),
            child: AnimatedBuilder(
              animation: _blink,
              builder: (context, child) {
                final phase = _blink.value;
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
                        width: 10 * k,
                        height: 10 * k,
                        child: Center(
                          child: Container(
                            width: 4 * k,
                            height: eyeHeight * k,
                            decoration: BoxDecoration(
                              color: AppColors.heroInk,
                              borderRadius: BorderRadius.circular(3 * k),
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
      ),
    );
  }
}
