import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/seed/seed_data.dart';
import '../screens/home/home_screen.dart';
import '../screens/my_books/my_books_screen.dart';
import '../screens/class_selector/class_selector_screen.dart';
import '../screens/pdf_viewer/pdf_viewer_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../widgets/app_shell.dart';

// ─── Navigation keys ────────────────────────────────────────────────────────

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// ─── Router ─────────────────────────────────────────────────────────────────

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/my-books',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: MyBooksScreen(),
          ),
        ),
        GoRoute(
          path: '/learn',
          pageBuilder: (context, state) => NoTransitionPage(
            child: Scaffold(
              body: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🎓', style: TextStyle(fontSize: 56)),
                        const SizedBox(height: 20),
                        Text(
                          'Learn',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Video lessons, chapter summaries, and interactive quizzes — all coming soon!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF6B7080),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE1F5EE),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Coming Soon',
                            style: TextStyle(
                              color: Color(0xFF1D9E75),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/progress',
          pageBuilder: (context, state) => NoTransitionPage(
            child: Scaffold(
              body: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('📊', style: TextStyle(fontSize: 56)),
                        const SizedBox(height: 20),
                        Text(
                          'Progress',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Track your reading streak, study time per subject, and books completed — coming soon!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF6B7080),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE1F5EE),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Coming Soon',
                            style: TextStyle(
                              color: Color(0xFF1D9E75),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/profile',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/class-selector',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ClassSelectorScreen(),
    ),
    GoRoute(
      path: '/reader/:bookId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final bookId = state.pathParameters['bookId']!;
        final book = getBookById(bookId);
        return PdfViewerScreen(book: book!);
      },
    ),
  ],
);
