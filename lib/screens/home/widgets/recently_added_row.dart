import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../data/models/book.dart';

class RecentlyAddedRow extends StatelessWidget {
  final List<Book> books;

  const RecentlyAddedRow({super.key, required this.books});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
        itemCount: books.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final book = books[index];
          return _MiniBookCard(book: book);
        },
      ),
    );
  }
}

class _MiniBookCard extends StatefulWidget {
  final Book book;

  const _MiniBookCard({required this.book});

  @override
  State<_MiniBookCard> createState() => _MiniBookCardState();
}

class _MiniBookCardState extends State<_MiniBookCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final (subjectBg, subjectText) =
        AppColors.getSubjectColor(widget.book.subject);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () => context.push('/reader/${widget.book.id}'),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 120,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: subjectBg,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.book.coverEmoji,
                style: const TextStyle(fontSize: 32),
              ),
              const Spacer(),
              Text(
                widget.book.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: subjectText,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                widget.book.subject[0].toUpperCase() +
                    widget.book.subject.substring(1),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: subjectText.withValues(alpha: 0.7),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
