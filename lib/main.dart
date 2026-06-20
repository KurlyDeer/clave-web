import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

import 'app.dart';
import 'core/data/curriculum_structure.dart';
import 'core/models/book_page_model.dart';
import 'core/models/lesson_models.dart';
import 'core/models/streak_model.dart';
import 'core/models/vocab_word_model.dart';
import 'core/providers/book_pages_provider.dart';
import 'core/providers/gamification_controller.dart';
import 'core/providers/persona_provider.dart';
import 'core/providers/lesson_progress_provider.dart';
import 'core/providers/shared_preferences_provider.dart';
import 'core/providers/streak_provider.dart';
import 'core/providers/vocab_provider.dart';
import 'core/services/audio_service.dart';
import 'core/services/notification_service.dart';

/// Set to true once you have run `flutterfire configure` and added
/// GoogleService-Info.plist to ios/Runner/. Until then, Firebase and
/// Crashlytics are fully skipped so the app can run in dev/simulator.
const bool _kFirebaseConfigured = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // iOS audio session — must run before any playback.
  // Skipped on web: AudioSession is a native-only plugin.
  if (!kIsWeb) {
    await AudioService.init();
  }

  // Firebase + Crashlytics — only runs when real credentials are present.
  // Flip _kFirebaseConfigured to true after running `flutterfire configure`.
  if (_kFirebaseConfigured) {
    try {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);

      // Web: explicitly set local auth persistence to survive browser refreshes.
      if (kIsWeb) {
        await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
      }

      // Crashlytics is not supported on web.
      if (!kIsWeb) {
        FlutterError.onError =
            FirebaseCrashlytics.instance.recordFlutterFatalError;
        PlatformDispatcher.instance.onError = (error, stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };
      }
    } catch (e) {
      debugPrint('[Firebase] Init failed: $e');
    }
  } else {
    debugPrint('[Firebase] Skipped — set _kFirebaseConfigured=true after running flutterfire configure.');
  }

  // SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Hive
  await Hive.initFlutter();
  Hive.registerAdapter(LessonProgressAdapter());
  Hive.registerAdapter(StreakDataAdapter());
  Hive.registerAdapter(BookPageAdapter());
  Hive.registerAdapter(VocabWordAdapter());
  final lessonBox = await Hive.openBox<LessonProgress>('lesson_progress');
  final streakBox = await Hive.openBox<StreakData>('streak_data');
  final bookPagesBox = await Hive.openBox<BookPage>('book_pages');
  final vocabBox = await Hive.openBox<VocabWord>('vocab_words');
  final gamificationBox = await Hive.openBox<dynamic>('gamification');

  // ── One-time migration: int lesson keys → String lesson keys ─────────────
  for (final entry in CurriculumStructure.legacyIdMap.entries) {
    final oldKey = entry.key;   // int (1–10)
    final newKey = entry.value; // String
    if (lessonBox.containsKey(oldKey) && !lessonBox.containsKey(newKey)) {
      final progress = lessonBox.get(oldKey);
      if (progress != null) {
        await lessonBox.put(newKey, progress);
        await lessonBox.delete(oldKey);
      }
    }
  }

  // Notifications — flutter_local_notifications is not supported on web.
  if (!kIsWeb) {
    await NotificationService.instance.initialize();

    // Re-schedule daily reminder if user has one configured
    final reminderHour = prefs.getInt('reminder_hour');
    final reminderMinute = prefs.getInt('reminder_minute');
    final personaName = prefs.getString('persona');

    if (reminderHour != null && personaName != null) {
      final persona = Persona.values.byName(personaName);
      await NotificationService.instance.scheduleDailyReminder(
        persona: persona,
        hour: reminderHour,
        minute: reminderMinute ?? 0,
      );
    }
  }

  // Navigation is now handled by AuthGate inside EnglishBridgeApp —
  // no need to determine `home` here.

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        lessonProgressBoxProvider.overrideWithValue(lessonBox),
        streakBoxProvider.overrideWithValue(streakBox),
        bookPagesBoxProvider.overrideWithValue(bookPagesBox),
        vocabBoxProvider.overrideWithValue(vocabBox),
        gamificationBoxProvider.overrideWithValue(gamificationBox),
      ],
      child: const EnglishBridgeApp(),
    ),
  );
}
