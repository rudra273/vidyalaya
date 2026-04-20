import 'package:flutter/material.dart';
import '../../../data/models/highlight.dart';

/// Semi-transparent amber — visible on white (light), inverted (dark), and sepia backgrounds.
const _highlightColor = Color(0x40FFC107);
const _highlightBorderColor = Color(0x80FFC107);
const _drawingColor = Color(0x30FFC107);
const _drawingBorderColor = Color(0x60FFC107);

/// Overlay that renders saved highlights and handles drawing new ones.
///
/// Sits on top of the PDF view. In draw mode, captures all touch events
/// so the PDF doesn't scroll. In normal mode, passes through touches
/// to the PDF via `IgnorePointer`, but remains tappable on highlight areas.
class HighlightOverlay extends StatefulWidget {
  final List<Highlight> highlights;
  final bool isDrawMode;
  final void Function(Rect fractionalRect) onHighlightCreated;
  final void Function(Highlight highlight) onHighlightTapped;

  const HighlightOverlay({
    super.key,
    required this.highlights,
    required this.isDrawMode,
    required this.onHighlightCreated,
    required this.onHighlightTapped,
  });

  @override
  State<HighlightOverlay> createState() => _HighlightOverlayState();
}

class _HighlightOverlayState extends State<HighlightOverlay> {
  Offset? _dragStart;
  Offset? _dragCurrent;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return Stack(
          children: [
            // ── Existing highlights (always visible, tappable in non-draw mode)
            ...widget.highlights.map((hl) {
              return Positioned(
                left: hl.left * w,
                top: hl.top * h,
                width: (hl.right - hl.left) * w,
                height: (hl.bottom - hl.top) * h,
                child: GestureDetector(
                  onTap: widget.isDrawMode
                      ? null
                      : () => widget.onHighlightTapped(hl),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _highlightColor,
                      border: Border.all(color: _highlightBorderColor, width: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: hl.note != null && hl.note!.isNotEmpty
                        ? Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Icon(
                                Icons.sticky_note_2,
                                size: 12,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              );
            }),

            // ── Drawing gesture layer (only active in draw mode)
            if (widget.isDrawMode)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (d) {
                    setState(() {
                      _dragStart = d.localPosition;
                      _dragCurrent = d.localPosition;
                    });
                  },
                  onPanUpdate: (d) {
                    setState(() => _dragCurrent = d.localPosition);
                  },
                  onPanEnd: (d) {
                    if (_dragStart != null && _dragCurrent != null) {
                      // Normalize so left<right, top<bottom
                      final left =
                          (_dragStart!.dx < _dragCurrent!.dx ? _dragStart!.dx : _dragCurrent!.dx) / w;
                      final top =
                          (_dragStart!.dy < _dragCurrent!.dy ? _dragStart!.dy : _dragCurrent!.dy) / h;
                      final right =
                          (_dragStart!.dx > _dragCurrent!.dx ? _dragStart!.dx : _dragCurrent!.dx) / w;
                      final bottom =
                          (_dragStart!.dy > _dragCurrent!.dy ? _dragStart!.dy : _dragCurrent!.dy) / h;

                      // Minimum size check (avoid accidental tiny taps)
                      if ((right - left) > 0.02 && (bottom - top) > 0.02) {
                        widget.onHighlightCreated(
                          Rect.fromLTRB(
                            left.clamp(0.0, 1.0),
                            top.clamp(0.0, 1.0),
                            right.clamp(0.0, 1.0),
                            bottom.clamp(0.0, 1.0),
                          ),
                        );
                      }
                    }
                    setState(() {
                      _dragStart = null;
                      _dragCurrent = null;
                    });
                  },
                  child: Stack(
                    children: [
                      // Draw hint
                      if (_dragStart == null)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Drag to highlight an area',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ),
                        ),
                      // Live drawing rectangle
                      if (_dragStart != null && _dragCurrent != null)
                        Positioned(
                          left: _dragStart!.dx < _dragCurrent!.dx
                              ? _dragStart!.dx
                              : _dragCurrent!.dx,
                          top: _dragStart!.dy < _dragCurrent!.dy
                              ? _dragStart!.dy
                              : _dragCurrent!.dy,
                          width: (_dragStart!.dx - _dragCurrent!.dx).abs(),
                          height: (_dragStart!.dy - _dragCurrent!.dy).abs(),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _drawingColor,
                              border: Border.all(
                                  color: _drawingBorderColor, width: 1.5),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
