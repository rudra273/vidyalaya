import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../data/models/book.dart';
import '../../../widgets/calm_widgets.dart';

class BookGridCard extends StatefulWidget {
  final Book book;

  /// Set for books the student added themselves; shows a remove menu.
  final VoidCallback? onRemove;

  const BookGridCard({super.key, required this.book, this.onRemove});

  @override
  State<BookGridCard> createState() => _BookGridCardState();
}

class _BookGridCardState extends State<BookGridCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final col = AppColors.subjectColor(widget.book.subject, brightness);
    final meta = subjectMeta(widget.book.subject);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () => context.push('/reader/${widget.book.id}'),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 0.74,
              child: BookCover(
                subjectKey: widget.book.subject,
                title: widget.book.title,
                big: true,
                radius: 16,
              ),
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(color: col, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  meta.label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontSize: AppFontSize.small,
                    fontWeight: AppFontWeight.semibold,
                    color: col,
                  ),
                ),
                if (widget.onRemove != null) ...[
                  const Spacer(),
                  InkResponse(
                    onTap: widget.onRemove,
                    radius: 18,
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        semanticLabel: 'Remove book',
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
