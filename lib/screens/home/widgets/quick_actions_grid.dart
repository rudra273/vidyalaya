import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.bookmark_rounded,
                iconColor: Colors.green.shade800,
                emojiBg: const Color(0xFFE8F5E9),
                title: 'Bookmarks',
                subtitle: 'Saved pages',
                onTap: () => context.push('/bookmarks'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                icon: Icons.calendar_month_rounded,
                iconColor: Colors.blue.shade800,
                emojiBg: const Color(0xFFE3F2FD), // Light blue
                title: 'Timetable',
                subtitle: 'My classes',
                onTap: () => context.push('/timetable'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.edit_note_rounded,
                iconColor: Colors.amber.shade900,
                emojiBg: const Color(0xFFFFF8E1),
                title: 'Notes',
                subtitle: 'My highlights',
                onTap: () => context.push('/notes'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                icon: Icons.assignment_rounded,
                iconColor: Colors.deepOrange.shade800,
                emojiBg: const Color(0xFFFFF3E0),
                title: 'Assignment',
                subtitle: 'Coming soon',
                isDisabled: true,
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionCard extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final Color emojiBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDisabled;

  const _ActionCard({
    required this.icon,
    required this.iconColor,
    required this.emojiBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDisabled = false,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: widget.isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: widget.isDisabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: widget.isDisabled ? null : () => setState(() => _isPressed = false),
      onTap: widget.isDisabled ? null : widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Opacity(
          opacity: widget.isDisabled ? 0.55 : 1.0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(color: cs.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.emojiBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      widget.icon,
                      color: widget.iconColor,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
