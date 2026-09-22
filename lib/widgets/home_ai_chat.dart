import 'package:flutter/material.dart';

import '../app/theme.dart';

/// A conversational entry to Q&A, placed directly on the Home background.
class HomeAiChat extends StatelessWidget {
  const HomeAiChat({super.key, required this.onChat});

  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(17),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: dark
                          ? [AppColors.green500Dark, AppColors.green700Dark]
                          : [AppColors.green500, AppColors.green700],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (dark ? AppColors.green500Dark : AppColors.green500)
                                .withValues(alpha: dark ? 0.24 : 0.18),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 29,
                      height: 22,
                      decoration: BoxDecoration(
                        color: dark ? AppColors.heroDark : AppColors.hero,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var i = 0; i < 2; i++)
                            Container(
                              width: 4,
                              height: 7,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                color: AppColors.heroInk,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  'Q&A AI',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Ask anything from your textbook',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: onChat,
            style: FilledButton.styleFrom(
              backgroundColor: dark
                  ? AppColors.green500Dark
                  : AppColors.green600,
              foregroundColor: dark ? AppColors.heroDark : Colors.white,
              minimumSize: const Size(128, 48),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: const StadiumBorder(),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Chat', style: TextStyle(fontWeight: FontWeight.w700)),
                SizedBox(width: 18),
                Icon(Icons.north_east_rounded, size: 19),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
