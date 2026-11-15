import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/theme.dart';
import 'app/router.dart';
import 'data/cache/cache_store.dart';
import 'data/repositories/user_prefs_repository.dart';
import 'data/services/ai_image_recovery.dart';
import 'data/models/ingested_books.dart';
import 'data/services/crash_reporting.dart';
import 'providers/app_usage_provider.dart';
import 'providers/core_providers.dart';
import 'providers/ingested_books_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/phone_reminders_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemStatusBarContrastEnforced: false,
      systemNavigationBarContrastEnforced: false,
    ),
  );
  // Firebase is required (auth, backend tokens). If it cannot start, show a
  // plain error screen instead of hanging on the splash forever.
  try {
    await Firebase.initializeApp();
  } catch (error, stack) {
    debugPrint('Firebase failed to start: $error\n$stack');
    runApp(const _StartupErrorApp());
    return;
  }
  // Everything below is optional: a failure falls back so the app still opens.
  try {
    await initCrashReporting();
  } catch (error) {
    debugPrint('Crash reporting unavailable: $error');
  }
  final prefs = await SharedPreferences.getInstance();
  final imageRecovery = AiImageRecovery(UserPrefsRepository(prefs));
  try {
    await imageRecovery.recover(FirebaseAuth.instance.currentUser?.uid);
  } catch (error) {
    debugPrint('Image recovery skipped: $error');
  }
  final cacheStore = CacheStore(await _openCacheBox());
  var ingestedBooks = const IngestedBooks.empty();
  try {
    ingestedBooks = IngestedBooks.fromJson(
      jsonDecode(await rootBundle.loadString('assets/data/ingested_books.json'))
          as Map<String, dynamic>,
    );
  } catch (error) {
    debugPrint('Ingested books list unavailable: $error');
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        aiImageRecoveryProvider.overrideWithValue(imageRecovery),
        cacheStoreProvider.overrideWithValue(cacheStore),
        ingestedBooksProvider.overrideWithValue(ingestedBooks),
      ],
      child: const VidyalayaApp(),
    ),
  );
}

/// Opens the backend-data cache. The cache is disposable, so a box that will
/// not open (corrupt file, full disk) is deleted and reopened, and as a last
/// resort an in-memory box is used for this run.
Future<Box<String>> _openCacheBox() async {
  try {
    await Hive.initFlutter();
    return await Hive.openBox<String>(CacheStore.boxName);
  } catch (error) {
    debugPrint('Cache box failed to open, resetting: $error');
  }
  try {
    await Hive.deleteBoxFromDisk(CacheStore.boxName);
    return await Hive.openBox<String>(CacheStore.boxName);
  } catch (error) {
    debugPrint('Cache box reset failed, using memory: $error');
  }
  return Hive.openBox<String>(
    '${CacheStore.boxName}_memory',
    bytes: Uint8List(0),
  );
}

// ─── Startup error ───

class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vidyakalp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Vidyakalp could not start. Please close the app and open it '
                'again. If this keeps happening, update the app from the '
                'Play Store.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VidyalayaApp extends ConsumerWidget {
  const VidyalayaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    final router = ref.watch(routerProvider);
    ref.watch(phoneReminderNavigationProvider);
    // Keeps the app-use timer running for the whole session.
    ref.watch(appUsageProvider.notifier);
    return MaterialApp.router(
      title: 'Vidyakalp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

final phoneReminderNavigationProvider = Provider<void>((ref) {
  final router = ref.watch(routerProvider);
  ref.watch(phoneRemindersProvider.notifier);
  final subscription = ref
      .read(phoneRemindersProvider.notifier)
      .destinations
      .listen((route) {
        router.push<void>(route);
      });
  ref.onDispose(() => unawaited(subscription.cancel()));
});
