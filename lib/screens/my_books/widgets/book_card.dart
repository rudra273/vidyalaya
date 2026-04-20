import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../data/models/book.dart';

class BookCard extends StatefulWidget {
  final Book book;

  const BookCard({super.key, required this.book});

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final cs = Theme.of(context).colorScheme;
    final (subjectBg, subjectText) =
        AppColors.getSubjectColorFor(widget.book.subject, brightness);
    final subjectLabel = widget.book.subject[0].toUpperCase() +
        widget.book.subject.substring(1);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () => context.push('/reader/${widget.book.id}'),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: cs.outline),
          ),
          child: Row(
            children: [
              // Emoji cover
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: subjectBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    widget.book.coverEmoji,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title + subject tag
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.book.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: subjectBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        subjectLabel,
                        style: TextStyle(
                          color: subjectText,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Arrow
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: cs.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.outline),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
