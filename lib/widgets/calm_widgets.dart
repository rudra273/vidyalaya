import 'package:flutter/material.dart';
import '../app/theme.dart';

// ─── Subject metadata ────────────────────────────────────────────────────
// Single source of truth for hue + icon + native script display.

class SubjectMeta {
  final String label;
  final IconData icon;
  final String? native;

  const SubjectMeta(this.label, this.icon, [this.native]);
}

const Map<String, SubjectMeta> kSubjects = {
  'odia': SubjectMeta('Odia', Icons.menu_book_rounded, 'ସାହିତ୍ୟସୁରଭି'),
  'english': SubjectMeta('English', Icons.menu_book_rounded, 'Jasmine'),
  'maths': SubjectMeta('Maths', Icons.functions_rounded, 'ଗଣିତ ପ୍ରକାଶ'),
  'math': SubjectMeta('Maths', Icons.functions_rounded),
  'hindi': SubjectMeta('Hindi', Icons.menu_book_rounded, 'हिंदी कलिका'),
  'sanskrit':
      SubjectMeta('Sanskrit', Icons.menu_book_rounded, 'संस्कृतकलिका'),
  'science': SubjectMeta('Science', Icons.science_rounded, 'ଜିଜ୍ଞାସା'),
  'social': SubjectMeta('Social', Icons.public_rounded, 'ସମାଜ ବିଜ୍ଞାନ'),
  'social_science':
      SubjectMeta('Social', Icons.public_rounded, 'ସମାଜ ବିଜ୍ଞାନ'),
  'skill': SubjectMeta('Skill', Icons.handyman_rounded),
  'work': SubjectMeta('Work', Icons.work_rounded),
};

SubjectMeta subjectMeta(String key) =>
    kSubjects[key.toLowerCase()] ?? const SubjectMeta('Subject', Icons.book_rounded);

// ─── Tile: a tinted square icon chip ─────────────────────────────────────

class Tile extends StatelessWidget {
  final Color color;
  final IconData icon;
  final double size;
  final double? iconSize;
  final double radius;

  const Tile({
    super.key,
    required this.color,
    required this.icon,
    this.size = 46,
    this.iconSize,
    this.radius = 13,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = Color.alphaBlend(color.withValues(alpha: 0.15), cs.surface);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: color, size: iconSize ?? size * 0.5),
    );
  }
}

// ─── BookCover: subject-tinted gradient + faint glyph + serif title ───────

class BookCover extends StatelessWidget {
  final String subjectKey;
  final String? title;
  final double radius;
  final bool big;

  const BookCover({
    super.key,
    required this.subjectKey,
    this.title,
    this.radius = 14,
    this.big = false,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final cs = Theme.of(context).colorScheme;
    final col = AppColors.subjectColor(subjectKey, brightness);
    final meta = subjectMeta(subjectKey);
    final inkColor = cs.onSurface;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // gradient background
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: const Alignment(-0.5, -1),
                end: const Alignment(1, 1),
                colors: [
                  Color.alphaBlend(col.withValues(alpha: 0.22), cs.surface),
                  Color.alphaBlend(col.withValues(alpha: 0.09), cs.surface),
                ],
              ),
              border: Border.all(
                color: col.withValues(alpha: 0.22),
              ),
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
          // faint oversized glyph
          Positioned(
            right: big ? -14 : -10,
            bottom: big ? -16 : -12,
            child: Icon(
              meta.icon,
              size: big ? 80 : 52,
              color: col.withValues(alpha: 0.13),
            ),
          ),
          // small motif chip top-left
          Positioned(
            top: big ? 12 : 9,
            left: big ? 12 : 9,
            child: Container(
              width: big ? 30 : 24,
              height: big ? 30 : 24,
              decoration: BoxDecoration(
                color: Color.alphaBlend(
                  col.withValues(alpha: 0.26),
                  cs.surface,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(meta.icon, size: big ? 17 : 14, color: col),
            ),
          ),
          // title
          if (title != null && title!.isNotEmpty)
            Positioned(
              left: big ? 13 : 10,
              right: big ? 13 : 10,
              bottom: big ? 12 : 9,
              child: Text(
                title!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontSize: big ? 15 : 12.5,
                      fontWeight: FontWeight.w600,
                      height: 1.15,
                      color: Color.alphaBlend(
                        col.withValues(alpha: 0.72),
                        inkColor,
                      ),
                    ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── SectionHead: uppercase eyebrow + optional action ─────────────────────

class SectionHead extends StatelessWidget {
  final String label;
  final String? action;
  final VoidCallback? onAction;

  const SectionHead({
    super.key,
    required this.label,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label.toUpperCase(), style: kEyebrow(context)),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}

TextStyle kEyebrow(BuildContext context) =>
    Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.ink3Dark
              : AppColors.ink3,
        ) ??
    const TextStyle();

// ─── ListRow: a settings-style row ────────────────────────────────────────

class ListRow extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String? sub;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool last;

  const ListRow({
    super.key,
    required this.color,
    required this.icon,
    required this.title,
    this.sub,
    this.trailing,
    this.onTap,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hair = isDark ? AppColors.hairline2Dark : AppColors.hairline2;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: last
              ? null
              : BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: hair, width: 1),
                  ),
                ),
          padding: EdgeInsets.only(bottom: last ? 0 : 14),
          child: Row(
            children: [
              Tile(color: color, icon: icon, size: 40, radius: 11),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                    ),
                    if (sub != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        sub!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              trailing ??
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 22,
                    color: isDark ? AppColors.ink3Dark : AppColors.ink3,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── PageTitle: large serif title with optional subtitle and trailing ────

class PageTitle extends StatelessWidget {
  final String title;
  final String? sub;
  final Widget? trailing;
  final VoidCallback? onBack;

  const PageTitle({
    super.key,
    required this.title,
    this.sub,
    this.trailing,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        14,
        AppSpacing.screenPadding,
        4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (onBack != null)
            Padding(
              padding: const EdgeInsets.only(right: 8, top: 4),
              child: InkResponse(
                onTap: onBack,
                radius: 22,
                child: Icon(Icons.arrow_back_rounded,
                    size: 24, color: cs.onSurface),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(fontSize: 24),
                ),
                if (sub != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    sub!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

// ─── IconBox: square button-style icon container ─────────────────────────

class IconBox extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;

  /// Accessibility/long-press label for the icon-only action.
  final String? tooltip;

  /// Nudges the box down to align with a top-anchored page title. Pass 0 when
  /// the box is already vertically centered by its parent.
  final double topMargin;

  const IconBox({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 42,
    this.tooltip,
    this.topMargin = 4,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final box = GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        margin: EdgeInsets.only(top: topMargin),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border.all(color: cs.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: cs.onSurface.withValues(alpha: 0.75)),
      ),
    );
    if (tooltip == null) return box;
    return Tooltip(message: tooltip!, child: box);
  }
}
