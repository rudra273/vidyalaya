import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/core_providers.dart';
import '../data/seed/seed_data.dart';
import '../screens/home/home_screen.dart';
import '../screens/my_books/my_books_screen.dart';
import '../screens/class_selector/class_selector_screen.dart';
import '../screens/pdf_viewer/pdf_viewer_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/privacy_policy_screen.dart';
import '../screens/profile/about_screen.dart';
import '../screens/notes/notes_screen.dart';
import '../screens/notes/subject_notes_screen.dart';
import '../screens/bookmarks/bookmarks_screen.dart';
import '../screens/downloads/manage_downloads_screen.dart';
import '../screens/timetable/timetable_screen.dart';
import '../screens/onboarding/welcome_screen.dart';
import '../widgets/app_shell.dart';
import '../screens/learn/learn_screen.dart';
import '../screens/learn/math_formulas_screen.dart';
import '../screens/learn/periodic_table_screen.dart';
import '../screens/learn/timeline_screen.dart';
import '../screens/progress/progress_screen.dart';

// ─── Navigation keys ────────────────────────────────────────────────────────

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// ─── Router ─────────────────────────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  final prefsRepo = ref.watch(userPrefsRepositoryProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final isWelcome = state.matchedLocation == '/welcome';
      final hasCompleted = prefsRepo.getHasCompletedOnboarding();
      
      if (!hasCompleted && !isWelcome) {
        return '/welcome';
      }
      return null;
    },
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
          pageBuilder: (context, state) => const NoTransitionPage(
            child: LearnScreen(),
          ),
        ),
        GoRoute(
          path: '/progress',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ProgressScreen(),
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
      path: '/privacy-policy',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
    GoRoute(
      path: '/about',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AboutScreen(),
    ),
    GoRoute(
      path: '/welcome',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/learn/math-formulas',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const MathFormulasScreen(),
    ),
    GoRoute(
      path: '/learn/periodic-table',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PeriodicTableScreen(),
    ),
    GoRoute(
      path: '/learn/timeline',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const TimelineScreen(),
    ),
    GoRoute(
      path: '/class-selector',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ClassSelectorScreen(),
    ),
    GoRoute(
      path: '/timetable',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const TimetableScreen(),
    ),
    GoRoute(
      path: '/manage-downloads',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ManageDownloadsScreen(),
    ),
    GoRoute(
      path: '/bookmarks',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const BookmarksScreen(),
    ),
    GoRoute(
      path: '/notes',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const NotesScreen(),
    ),
    GoRoute(
      path: '/notes/:subject',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final subject = state.pathParameters['subject']!;
        return SubjectNotesScreen(subject: subject);
      },
    ),
    GoRoute(
      path: '/reader/:bookId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final bookId = state.pathParameters['bookId']!;
        final book = getBookById(bookId);
        final pageStr = state.uri.queryParameters['page'];
        final initialPage = pageStr != null ? int.tryParse(pageStr) : null;
        return PdfViewerScreen(book: book!, initialPage: initialPage);
      },
    ),
  ],
);
});
