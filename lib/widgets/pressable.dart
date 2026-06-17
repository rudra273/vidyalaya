import 'package:flutter/material.dart';

/// Wraps any tappable widget with a subtle press-scale animation, giving
/// consistent touch affordance without needing a [Material] ancestor (unlike
/// [InkWell]). Use on bare [GestureDetector]-style surfaces — cards, tiles,
/// nav items — so a press is always *felt* visually.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  /// Scale at full press. Smaller = more pronounced. Defaults to a gentle dip.
  final double scale;

  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.97,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (widget.onTap == null) return;
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
