import 'package:flutter/material.dart';

import '../app/theme.dart';
import 'pressable.dart';

// ─── Ask card: dark green gradient + a real button ──────────────────────
// The AI entry point, shared by the AI tab's hero and Home's banner. The
// action is a filled button, never a text-field lookalike — students were
// not recognising the faux input bar this replaced.

class AskCard extends StatelessWidget {
  final String headline;
  final String sub;

  /// Small "Q&A" eyebrow above the headline — on for the AI tab's hero, off
  /// for the more compact Home card.
  final bool showEyebrow;

  final VoidCallback onAsk;
  final VoidCallback onCamera;

  const AskCard({
    super.key,
    required this.headline,
    required this.sub,
    required this.onAsk,
    required this.onCamera,
    this.showEyebrow = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final heroColor = isDark ? AppColors.heroDark : AppColors.hero;
    final hero2 = isDark ? AppColors.hero2Dark : AppColors.hero2;
    final accent = isDark ? AppColors.green500Dark : AppColors.green500;
    const inkLight = AppColors.heroInk;
    final inkMuted = AppColors.heroInk.withValues(alpha: 0.62);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPad - 2),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0.95, -0.8),
          radius: 1.3,
          colors: [hero2, heroColor],
        ),
        border: Border.all(
          color: isDark ? AppColors.heroLineDark : AppColors.heroLine,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showEyebrow) ...[
            Row(
              children: [
                Icon(Icons.auto_awesome_rounded, size: 15, color: accent),
                const SizedBox(width: 7),
                Text(
                  'Q&A',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: inkMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          Text(
            headline,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: inkLight),
          ),
          const SizedBox(height: 5),
          Text(
            sub,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: inkMuted),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _AskButton(onTap: onAsk)),
              const SizedBox(width: 10),
              _HeroIconButton(
                icon: Icons.photo_camera_rounded,
                tooltip: 'Snap a photo of a question',
                onTap: onCamera,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The primary call to action — a solid, obviously-tappable button.
class _AskButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AskButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.97,
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.green600,
          borderRadius: BorderRadius.circular(13),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Ask a question',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 7),
            Icon(Icons.arrow_forward_rounded, size: 17, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

/// Secondary square action on the hero (camera), tinted for the dark card.
class _HeroIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _HeroIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Pressable(
        onTap: onTap,
        scale: 0.94,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, size: 20, color: AppColors.heroInk),
        ),
      ),
    );
  }
}
