import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/core_providers.dart';
import '../data/seed/seed_data.dart';
import '../screens/ai/ai_hub_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/my_books/my_books_screen.dart';
import '../screens/class_selector/class_selector_screen.dart';
import '../screens/pdf_viewer/pdf_viewer_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/profile/privacy_policy_screen.dart';
import '../screens/profile/about_screen.dart';
import '../screens/profile/feedback_screen.dart';
import '../screens/progress/progress_screen.dart';
import '../screens/notes/notes_screen.dart';
import '../screens/notes/subject_notes_screen.dart';
import '../screens/notes/note_editor_screen.dart';
import '../screens/bookmarks/bookmarks_screen.dart';
import '../screens/downloads/manage_downloads_screen.dart';
import '../screens/timetable/timetable_screen.dart';
import '../screens/onboarding/welcome_screen.dart';
import '../widgets/app_shell.dart';
import '../screens/explore/explore_screen.dart';
import '../screens/learn_ai/tutor_mock_screen.dart';
import '../screens/learn/learn_ai_screen.dart';
import '../screens/learn/math_formulas_screen.dart';
import '../screens/learn/periodic_table_screen.dart';
import '../screens/learn/timeline_screen.dart';
import '../screens/learn/diagrams_screen.dart';
import '../screens/learn/diagram_viewer_screen.dart';
import '../screens/learn/cosmulator_screen.dart';
import '../screens/learn/vocabulary_screen.dart';
import '../screens/learn/python/python_home_screen.dart';
import '../screens/learn/python/python_chapter_screen.dart';
import '../screens/learn/python/python_lesson_screen.dart';
import '../screens/learn/python/python_quiz_screen.dart';
import '../screens/learn/python/python_playground_screen.dart';
import '../screens/learn/math/math_home_screen.dart';
import '../screens/learn/math/math_tables_screen.dart';
import '../screens/learn/math/math_flash_screen.dart';
import '../screens/learn/math/math_quiz_screen.dart';
import '../screens/learn/math/math_drills_screen.dart';
import '../screens/learn/math/math_number_sense_screen.dart';
import '../screens/learn/math/math_fractions_screen.dart';
import '../data/seed/diagrams_data.dart';
import '../data/models/answer_style.dart';
import '../data/models/learn_assist.dart';

// ─── Navigation keys ────────────────────────────────────────────────────────

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// ─── Router ─────────────────────────────────────────────────────────────────

// Book surfaces gated behind booksEnabledProvider: when the flag is off these
// paths redirect to Home so the feature is fully unreachable, not just hidden.
const _bookRoutePrefixes = ['/library', '/my-books', '/reader', '/bookmarks'];

final routerProvider = Provider<GoRouter>((ref) {
  final prefsRepo = ref.watch(userPrefsRepositoryProvider);
  final booksEnabled = ref.watch(booksEnabledProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final isWelcome = state.matchedLocation == '/welcome';
      final hasCompleted = prefsRepo.getHasCompletedOnboarding();

      if (!hasCompleted && !isWelcome) {
        return '/welcome';
      }

      if (!booksEnabled) {
        final path = state.matchedLocation;
        final isBookRoute =
            _bookRoutePrefixes.any((p) => path == p || path.startsWith('$p/'));
        if (isBookRoute) return '/';
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
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/ai',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: AiHubScreen()),
          ),
          GoRoute(
            path: '/explore',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ExploreScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),
      // Redirects for renamed routes, so old/deep links don't break:
      // Learn → Explore, My Books → Library, the old Learn AI hub → Q&A.
      GoRoute(path: '/learn', redirect: (_, _) => '/explore'),
      GoRoute(path: '/my-books', redirect: (_, _) => '/library'),
      GoRoute(path: '/learn-ai', redirect: (_, _) => '/learn/ai'),
      // Library lost its tab to AI: it now pushes full-screen from Home.
      GoRoute(
        path: '/library',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MyBooksScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/progress',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProgressScreen(),
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
        path: '/feedback',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FeedbackScreen(),
      ),
      GoRoute(
        path: '/welcome',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/learn/ai',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final channel =
              state.uri.queryParameters['channel'] ??
              LearnAssistChannel.learnAssist;
          final prefill = state.uri.queryParameters['prefill'];
          final autofocus = state.uri.queryParameters['focus'] == '1';
          final subject = state.uri.queryParameters['subject'];
          final openCamera = state.uri.queryParameters['camera'] == '1';
          // Arrived from a "pick up where you left off" card, so the student
          // has already said which conversation they want back.
          final resume = state.uri.queryParameters['resume'] == '1';
          // How the first answer should be pitched — set by the AI tab's hero
          // switch. Unknown/missing values fall back to a plain ask.
          final answerStyle = AnswerStyle.fromKey(
            state.uri.queryParameters['style'],
          );
          return LearnAiScreen(
            channel: channel,
            initialPrompt: prefill,
            autofocus: autofocus,
            initialSubject: subject,
            openCamera: openCamera,
            resume: resume,
            answerStyle: answerStyle,
          );
        },
      ),
      GoRoute(
        path: '/learn-ai/tutor',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TutorMockScreen(),
      ),
      GoRoute(
        path: '/learn/math-formulas',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MathFormulasScreen(),
      ),
      GoRoute(
        path: '/learn/math-formulas/category/:name',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final name = state.pathParameters['name']!;
          final category = formulaCategoryByName(name);
          if (category == null) return const MathFormulasScreen();
          return FormulaCategoryScreen(category: category);
        },
      ),
      GoRoute(
        path: '/learn/periodic-table',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PeriodicTableScreen(),
      ),
      GoRoute(
        path: '/learn/vocabulary',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const VocabularyScreen(),
      ),
      GoRoute(
        path: '/learn/timeline',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TimelineScreen(),
      ),
      GoRoute(
        path: '/learn/cosmulator',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CosmulatorScreen(),
      ),
      GoRoute(
        path: '/learn/diagrams',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DiagramsScreen(),
      ),
      GoRoute(
        path: '/learn/diagrams/category/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final category = state.extra as DiagramCategory;
          return DiagramCategoryScreen(category: category);
        },
      ),
      GoRoute(
        path: '/learn/diagrams/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final diagram = state.extra as Diagram;
          return DiagramViewerScreen(diagram: diagram);
        },
      ),
      // ── Python programming course ──
      GoRoute(
        path: '/learn/python',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PythonHomeScreen(),
      ),
      GoRoute(
        path: '/learn/python/playground',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PythonPlaygroundScreen(),
      ),
      GoRoute(
        path: '/learn/python/chapter/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            PythonChapterScreen(chapterId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/learn/python/lesson/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            PythonLessonScreen(lessonId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/learn/python/quiz/:chapterId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            PythonQuizScreen(chapterId: state.pathParameters['chapterId']!),
      ),
      // ── Math hub ──
      // Note: Formulas keeps its original /learn/math-formulas path (above) and
      // is reached from the hub, so existing deep links keep working.
      GoRoute(
        path: '/learn/math',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MathHomeScreen(),
      ),
      GoRoute(
        path: '/learn/math/tables',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MathTablesScreen(),
      ),
      GoRoute(
        path: '/learn/math/flash',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MathFlashScreen(),
      ),
      GoRoute(
        path: '/learn/math/quiz',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MathQuizScreen(),
      ),
      GoRoute(
        path: '/learn/math/drills',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MathDrillsScreen(),
      ),
      GoRoute(
        path: '/learn/math/number-sense',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MathNumberSenseScreen(),
      ),
      GoRoute(
        path: '/learn/math/fractions',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MathFractionsScreen(),
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
        path: '/note/new',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NoteEditorScreen(),
      ),
      GoRoute(
        path: '/note/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return NoteEditorScreen(noteId: id);
        },
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
