import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/learn_assist_provider.dart';
import '../utils/haptics.dart';
import 'ai_robot_mark.dart';
import 'app_update_banner.dart';
import 'nav_icons.dart';
import 'pressable.dart';

/// Shell wrapper that provides the Calm Scholar bottom navigation for tab
/// routes — pill background on the active item, refined typography.
class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  /// The five tabs. Ask sits in the middle because asking a question is the
  /// app's core action: it opens the chat directly and shows the bot instead
  /// of an icon (a null icon below). Library is reached from Home.
  static const List<(String, NavIcon?, String)> _allTabs = [
    ('/', NavIcon.home, 'Home'),
    ('/ai', NavIcon.ai, 'AI'),
    ('/ask', null, 'Ask'),
    ('/explore', NavIcon.explore, 'Explore'),
    ('/profile', NavIcon.profile, 'Profile'),
  ];

  /// Below class 6 there is no AI, so its two tabs are left out entirely.
  static const List<(String, NavIcon?, String)> _tabsWithoutAi = [
    ('/', NavIcon.home, 'Home'),
    ('/explore', NavIcon.explore, 'Explore'),
    ('/profile', NavIcon.profile, 'Profile'),
  ];

  static List<(String, NavIcon?, String)> _tabsFor(AiAccess access) =>
      access == AiAccess.hidden ? _tabsWithoutAi : _allTabs;

  int _currentIndex(
    BuildContext context,
    List<(String, NavIcon?, String)> tabs,
  ) {
    final location = GoRouterState.of(context).uri.path;
    for (int i = 0; i < tabs.length; i++) {
      if (location == tabs[i].$1) return i;
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
  Future<bool> _onBack(
    BuildContext context,
    WidgetRef ref,
    List<(String, NavIcon?, String)> tabs,
  ) async {
    // primaryFocus is never null (the root FocusScopeNode always holds focus),
    // so check that an actual text input is focused before unfocusing.
    final focus = FocusManager.instance.primaryFocus;
    if (focus != null && focus is! FocusScopeNode && focus.hasPrimaryFocus) {
      focus.unfocus();
      return true;
    }

    final router = GoRouter.of(context);
    if (router.canPop()) return false;

    if (_currentIndex(context, tabs) != 0) {
      context.go('/');
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn = ref
        .watch(authStateProvider)
        .maybeWhen(data: (user) => user != null, orElse: () => false);
    if (signedIn) {
      // The shell stays mounted across all main tabs, so it is the earliest
      // stable place to hydrate the profile and both account-owned browsing
      // preferences. The cache deduplicates these calls for the session.
      Future.microtask(() {
        final account = ref.read(backendAccountCacheProvider.notifier);
        account.ensureProfile();
        account.ensureExplorePreferences();
        account.ensureLibraryPreferences();
      });
    }

    final tabs = _tabsFor(ref.watch(aiAccessProvider));
    final currentIndex = _currentIndex(context, tabs);
    // The bar is part of the page: same colour, no line above it. It steps
    // aside while the keyboard is up so the chat keeps the room.
    final keyboardUp = MediaQuery.viewInsetsOf(context).bottom > 0;

    return BackButtonListener(
      onBackButtonPressed: () => _onBack(context, ref, tabs),
      child: Scaffold(
        body: child,
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppUpdateBanner(),
            if (!keyboardUp)
              ColoredBox(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                    child: Row(
                      children: List.generate(tabs.length, (index) {
                        final isActive = index == currentIndex;
                        final tab = tabs[index];
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
          ],
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  /// Null shows the bot (the Ask tab).
  final NavIcon? icon;
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
      Theme.of(context).scaffoldBackgroundColor,
    );

    // Icons only: the active tab's icon fills in and sits in a pill; an
    // idle one is an outline. The label is kept for screen readers.
    return Semantics(
      button: true,
      selected: isActive,
      label: label,
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        scale: 0.92,
        child: SizedBox(
          height: 52,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              height: 38,
              decoration: BoxDecoration(
                color: isActive ? pill : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              alignment: Alignment.center,
              child: icon == null
                  ? const AiBot(size: 30)
                  : NavIconView(
                      icon: icon!,
                      selected: isActive,
                      color: isActive ? activeColor : inactiveColor,
                      behind: pill,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
