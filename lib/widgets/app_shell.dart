import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app/theme.dart';

/// Shell wrapper that provides the Calm Scholar bottom navigation for tab
/// routes — pill background on the active item, refined typography.
class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static const _tabs = [
    ('/', Icons.home_rounded, 'Home'),
    ('/explore', Icons.explore_rounded, 'Explore'),
    ('/library', Icons.menu_book_rounded, 'Library'),
    ('/profile', Icons.person_rounded, 'Profile'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    for (int i = 0; i < _tabs.length; i++) {
      if (location == _tabs[i].$1) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hair = isDark ? AppColors.hairline2Dark : AppColors.hairline2;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(top: BorderSide(color: hair, width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
            child: Row(
              children: List.generate(_tabs.length, (index) {
                final isActive = index == currentIndex;
                final tab = _tabs[index];
                return Expanded(
                  child: _NavBarItem(
                    icon: tab.$2,
                    label: tab.$3,
                    isActive: isActive,
                    onTap: () {
                      if (index != currentIndex) context.go(tab.$1);
                    },
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = cs.primary;
    final inactiveColor = isDark ? AppColors.ink3Dark : AppColors.ink3;
    final pill = Color.alphaBlend(
      activeColor.withValues(alpha: isDark ? 0.18 : 0.14),
      cs.surface,
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 30,
              decoration: BoxDecoration(
                color: isActive ? pill : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 22,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? activeColor : inactiveColor,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
