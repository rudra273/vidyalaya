import 'package:flutter/material.dart';

import '../app/theme.dart';
import 'ai_robot_mark.dart';
import 'pressable.dart';

// ─── Home AI card ─────────────────────────────────────────────────────────
// The Home entry into AI chat: the bot, a short invitation, a question field
// that opens the chat (with a camera shortcut), and — when the student asked
// something this week — a "Continue" row that reopens that conversation.

class HomeAiChat extends StatelessWidget {
  const HomeAiChat({
    super.key,
    required this.onChat,
    required this.onCamera,
    this.resumeText,
    this.onResume,
    this.mood = BotMood.idle,
  });

  final VoidCallback onChat;
  final VoidCallback onCamera;

  /// The last question asked, shown as a resume row.
  final String? resumeText;

  /// Reopens the conversation [resumeText] was asked in.
  final VoidCallback? onResume;

  /// The bot's mood on the card (resting late at night or with no questions
  /// left; idle otherwise).
  final BotMood mood;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final ink = AppColors.heroInk;
    final ink2 = const Color(0xFFB9D6C8);
    final field = dark ? const Color(0xFF0A1A13) : const Color(0xFF0A2018);
    final accent = AppColors.green500Dark;
    final resume = resumeText?.trim();
    final canResume = resume != null && resume.isNotEmpty && onResume != null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [Color(0xFF173B2C), Color(0xFF0F2A1F)]
              : const [Color(0xFF184634), AppColors.hero],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AiBot(size: 52, mood: mood),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stuck on something?',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ask me from any of your books.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: ink2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Question field (opens the chat) ──
          Semantics(
            button: true,
            label: 'Ask a question',
            child: Material(
              color: field,
              shape: const StadiumBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onChat,
                child: SizedBox(
                  height: 52,
                  child: Row(
                    children: [
                      const SizedBox(width: 18),
                      Expanded(
                        child: Text(
                          'Type your question',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: ink2,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: onCamera,
                        tooltip: 'Ask with a photo',
                        icon: Icon(Icons.photo_camera_outlined, color: ink),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ExcludeSemantics(
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_upward_rounded,
                              size: 21,
                              color: AppColors.onGreenDark,
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

          // ── Continue the last conversation ──
          if (canResume)
            Semantics(
              button: true,
              label: 'Continue: $resume',
              excludeSemantics: true,
              child: Pressable(
                onTap: onResume,
                child: SizedBox(
                  height: 46,
                  child: Row(
                    children: [
                      Icon(Icons.history_rounded, size: 18, color: accent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Continue: $resume',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: ink,
                            fontWeight: AppFontWeight.medium,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, size: 20, color: ink2),
                    ],
                  ),
                ),
              ),
            )
          else
            const SizedBox(height: 8),
        ],
      ),
    );
  }
}
