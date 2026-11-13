import 'package:flutter/material.dart';

import '../app/theme.dart';

// ─── Chunky button ────────────────────────────────────────────────────────
// The app's main call to action: a pill with a darker solid edge underneath
// that presses down into it, so a tap feels physical. Use one per screen for
// the primary action; [ChunkyStyle.secondary] for the quieter partner. The
// press itself is the feedback; callers add haptics where they want them.

enum ChunkyStyle { primary, secondary }

class ChunkyButton extends StatefulWidget {
  const ChunkyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = ChunkyStyle.primary,
    this.leading,
    this.trailing,
    this.height = 56,
    this.expand = true,
  });

  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final ChunkyStyle style;
  final Widget? leading;
  final Widget? trailing;
  final double height;

  /// Fill the available width.
  final bool expand;

  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  static const _edge = 4.0;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final enabled = widget.onPressed != null;
    final primary = widget.style == ChunkyStyle.primary;

    final Color face;
    final Color edge;
    final Color ink;
    Color? border;
    if (!enabled) {
      face = dark ? AppColors.surface2Dark : const Color(0xFFD5DDD6);
      edge = face;
      ink = dark ? AppColors.ink3Dark : AppColors.ink2;
    } else if (primary) {
      face = dark ? AppColors.green500Dark : AppColors.green600;
      edge = dark ? const Color(0xFF1C7D55) : const Color(0xFF0A4C34);
      ink = dark ? AppColors.onGreenDark : Colors.white;
    } else {
      face = dark ? AppColors.surface3Dark : AppColors.surface;
      edge = dark ? const Color(0xFF0A0C0B) : const Color(0xFFB9C9BC);
      ink = dark ? AppColors.inkDark : AppColors.ink;
      border = dark ? null : const Color(0xFFB9C9BC);
    }

    final pressed = _down && enabled;
    final drop = enabled ? (pressed ? 0.0 : _edge) : 0.0;

    final content = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.leading != null) ...[
          widget.leading!,
          const SizedBox(width: 12),
        ],
        Flexible(
          child: Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppFontSize.content,
              fontWeight: AppFontWeight.bold,
              color: ink,
            ),
          ),
        ),
        if (widget.trailing != null) ...[
          const SizedBox(width: 10),
          IconTheme(
            data: IconThemeData(color: ink, size: 20),
            child: widget.trailing!,
          ),
        ],
      ],
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: enabled ? () => setState(() => _down = false) : null,
        onTapUp: enabled
            ? (_) {
                setState(() => _down = false);
                widget.onPressed!();
              }
            : null,
        child: SizedBox(
          height: widget.height + _edge,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 70),
            margin: EdgeInsets.only(top: _edge - drop),
            height: widget.height,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: face,
              borderRadius: BorderRadius.circular(999),
              border: border == null
                  ? null
                  : Border.all(color: border, width: 2),
              boxShadow: drop == 0
                  ? null
                  : [BoxShadow(color: edge, offset: Offset(0, drop))],
            ),
            alignment: Alignment.center,
            child: content,
          ),
        ),
      ),
    );
  }
}
