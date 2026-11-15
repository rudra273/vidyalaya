import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../data/models/answer_style.dart';
import 'ai_robot_mark.dart';

// AI tab entry card with answer-style switch.

// ═══════════════════════════════════════════════════════════════════════════
// AI tab — compact light hero with an answer-style switch
// ═══════════════════════════════════════════════════════════════════════════

class AiAskHero extends StatefulWidget {
  final String headline;
  final String sub;

  /// Called with the answer style selected on the switch, so the chat can pitch
  /// its first reply accordingly.
  final ValueChanged<AnswerStyle> onAsk;
  final VoidCallback onCamera;

  /// The bot's mood (resting once the day's questions are used up).
  final BotMood mood;

  const AiAskHero({
    super.key,
    required this.headline,
    required this.sub,
    required this.onAsk,
    required this.onCamera,
    this.mood = BotMood.idle,
  });

  @override
  State<AiAskHero> createState() => _AiAskHeroState();
}

class _AiAskHeroState extends State<AiAskHero> {
  AnswerStyle _style = AnswerStyle.ask;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.ink2Dark : AppColors.ink2;
    final fieldEdge = isDark ? AppColors.surface3Dark : const Color(0xFFC6D5C9);

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark
            ? null
            : const [BoxShadow(color: Color(0xFFD5E0D6), offset: Offset(0, 3))],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              AiBot(size: 52, mood: widget.mood),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.headline,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.sub,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Question field (opens the chat in the chosen style) ──
          Semantics(
            button: true,
            label: _askLabel(_style),
            child: Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              shape: StadiumBorder(
                side: BorderSide(color: fieldEdge, width: 2),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => widget.onAsk(_style),
                child: SizedBox(
                  height: 54,
                  child: Row(
                    children: [
                      const SizedBox(width: 18),
                      Expanded(
                        child: Text(
                          _askLabel(_style),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(color: muted),
                        ),
                      ),
                      IconButton(
                        onPressed: widget.onCamera,
                        tooltip: 'Snap a photo of a question',
                        icon: Icon(
                          Icons.photo_camera_outlined,
                          color: cs.onSurface,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: ExcludeSemantics(
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: cs.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_upward_rounded,
                              size: 21,
                              color: cs.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _StyleSwitch(
            selected: _style,
            onChanged: (style) => setState(() => _style = style),
          ),
        ],
      ),
    );
  }
}

/// The button label restates the chosen style, so the switch has a visible
/// consequence before the student even taps through.
String _askLabel(AnswerStyle style) {
  return switch (style) {
    AnswerStyle.ask => 'Ask a question',
    AnswerStyle.simple => 'Ask, explain simply',
    AnswerStyle.steps => 'Ask, step by step',
  };
}

/// Ask / Explain simply / Step by step — sets how the next answer is pitched.
class _StyleSwitch extends StatelessWidget {
  final AnswerStyle selected;
  final ValueChanged<AnswerStyle> onChanged;

  const _StyleSwitch({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textStyle = Theme.of(context).textTheme.labelMedium;
    const icons = {
      AnswerStyle.ask: Icons.chat_bubble_outline_rounded,
      AnswerStyle.simple: Icons.lightbulb_outline_rounded,
      AnswerStyle.steps: Icons.format_list_numbered_rounded,
    };

    return Semantics(
      label: 'Answer style',
      container: true,
      child: Material(
        color: isDark ? AppColors.paperDark : AppColors.surface2,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              for (final style in AnswerStyle.values)
                Expanded(
                  child: Semantics(
                    selected: style == selected,
                    button: true,
                    child: Material(
                      color: style == selected
                          ? (isDark ? AppColors.surface3Dark : cs.surface)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => onChanged(style),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 9,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                icons[style],
                                size: 17,
                                color: style == selected
                                    ? cs.primary
                                    : cs.onSurfaceVariant,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                style.label,
                                textAlign: TextAlign.center,
                                style: textStyle?.copyWith(
                                  color: style == selected
                                      ? cs.onSurface
                                      : cs.onSurfaceVariant,
                                  fontWeight: style == selected
                                      ? AppFontWeight.bold
                                      : AppFontWeight.medium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
