import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/models/book_page_model.dart';
import 'core/models/lesson_models.dart';
import 'core/models/streak_model.dart';
import 'core/models/vocab_word_model.dart';
import 'core/providers/book_pages_provider.dart';
import 'core/providers/lesson_progress_provider.dart';
import 'core/providers/shared_preferences_provider.dart';
import 'core/providers/streak_provider.dart';
import 'core/providers/vocab_provider.dart';
import 'core/services/notification_service.dart';
import 'features/dashboard/main_shell_screen.dart';
import 'features/placement/placement_screen.dart';
import 'features/welcome/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  // Notifications
  await NotificationService.instance.initialize();

  final personaName = prefs.getString('persona');
  final placementDone = prefs.getBool('placement_complete') ?? false;

  final Widget home;
  if (personaName == null) {
    home = const WelcomeScreen();
  } else if (!placementDone) {
    home = const PlacementScreen();
  } else {
    home = const MainShellScreen();
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        lessonProgressBoxProvider.overrideWithValue(lessonBox),
        streakBoxProvider.overrideWithValue(streakBox),
        bookPagesBoxProvider.overrideWithValue(bookPagesBox),
        vocabBoxProvider.overrideWithValue(vocabBox),
      ],
      child: EnglishBridgeApp(home: home),
    ),
  );
}
