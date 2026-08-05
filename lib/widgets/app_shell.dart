import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/theme.dart';
import '../utils/haptics.dart';
import 'pressable.dart';

/// Shell wrapper that provides the Calm Scholar bottom navigation for tab
/// routes — pill background on the active item, refined typography.
class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  /// The four tabs. AI sits second because asking a question is the app's
  /// core action; Library is reached from Home instead of holding a tab.
  static const _tabs = [
    ('/', Icons.home_rounded, 'Home'),
    ('/ai', Icons.auto_awesome_rounded, 'AI'),
    ('/explore', Icons.explore_rounded, 'Explore'),
    ('/profile', Icons.person_rounded, 'Profile'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    for (int i = 0; i < _tabs.length; i++) {
      if (location == _tabs[i].$1) return i;
    }
    return 0;
  }

  /// Handles the Android system back gesture/button for the tab shell, in
  /// priority order:
  ///   1. A text field has focus → unfocus it (drop the cursor / dismiss the
  ///      keyboard) and consume the event.
  ///   2. A route is pushed on top of the tab → let GoRouter pop it normally.
  ///   3. On a non-Home tab → go to the Home tab and consume the event.
  ///   4. On the Home tab → let the system handle it (exit the app).
  Future<bool> _onBack(BuildContext context, WidgetRef ref) async {
    // primaryFocus is never null (the root FocusScopeNode always holds focus),
    // so check that an actual text input is focused before unfocusing.
    final focus = FocusManager.instance.primaryFocus;
    if (focus != null && focus is! FocusScopeNode && focus.hasPrimaryFocus) {
      focus.unfocus();
      return true;
    }

    final router = GoRouter.of(context);
    if (router.canPop()) return false;

    if (_currentIndex(context) != 0) {
      context.go('/');
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _currentIndex(context);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hair = isDark ? AppColors.hairline2Dark : AppColors.hairline2;

    return BackButtonListener(
      onBackButtonPressed: () => _onBack(context, ref),
      child: Scaffold(
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
                        if (index != currentIndex) {
                          Haptics.selection(ref);
                          context.go(tab.$1);
                        }
                      },
                    ),
                  );
                }),
              ),
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

    return Pressable(
      onTap: onTap,
      scale: 0.92,
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
