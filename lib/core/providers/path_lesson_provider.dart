import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/lesson_repository.dart';
import '../models/lesson_models.dart';
import 'lesson_progress_provider.dart';
import 'shared_preferences_provider.dart';

// ── Learning Track ─────────────────────────────────────────────────────────────

enum LearningTrack { general, citizenship }

class LearningTrackNotifier extends StateNotifier<LearningTrack> {
  LearningTrackNotifier(SharedPreferences prefs)
      : _prefs = prefs,
        super(_fromString(prefs.getString('learning_track')));

  final SharedPreferences _prefs;

  static LearningTrack _fromString(String? value) {
    if (value == LearningTrack.citizenship.name) {
      return LearningTrack.citizenship;
    }
    return LearningTrack.general;
  }

  Future<void> setTrack(LearningTrack track) async {
    await _prefs.setString('learning_track', track.name);
    state = track;
  }
}

final learningTrackProvider =
    StateNotifierProvider<LearningTrackNotifier, LearningTrack>((ref) {
  return LearningTrackNotifier(ref.read(sharedPreferencesProvider));
});

// ── Async JSON-backed lesson loaders ──────────────────────────────────────────

final _englishLessonsFutureProvider = FutureProvider<List<PathLesson>>((ref) async {
  final jsonString =
      await rootBundle.loadString('assets/data/english_lessons.json');
  return LessonRepository.parseLessons(jsonString);
});

final _citizenshipLessonsFutureProvider =
    FutureProvider<List<PathLesson>>((ref) async {
  final jsonString =
      await rootBundle.loadString('assets/data/citizenship_lessons.json');
  // CitizenshipRepository uses the same PathLesson model; reuse parseLessons.
  return LessonRepository.parseLessons(jsonString);
});

/// AsyncValue wrapper — switch between tracks.
final pathLessonsAsyncProvider = Provider<AsyncValue<List<PathLesson>>>((ref) {
  final track = ref.watch(learningTrackProvider);
  return track == LearningTrack.citizenship
      ? ref.watch(_citizenshipLessonsFutureProvider)
      : ref.watch(_englishLessonsFutureProvider);
});

// ── Path lessons (track-aware) ─────────────────────────────────────────────────

/// Synchronous accessor — returns empty list while JSON is loading.
/// Backward-compatible with all providers that already watch [pathLessonsProvider].
final pathLessonsProvider = Provider<List<PathLesson>>((ref) {
  return ref.watch(pathLessonsAsyncProvider).valueOrNull ?? const [];
});

/// Progress for a specific PathLesson by id — reuses the existing Hive box.
final pathLessonProgressProvider =
    Provider.family<LessonProgress?, String>((ref, id) {
  return ref.watch(lessonProgressProvider(id));
});

/// Count of completed PathLessons (track-aware).
final completedPathLessonCountProvider = Provider<int>((ref) {
  final lessons = ref.watch(pathLessonsProvider);
  final completedIds = ref.watch(completedLessonIdsProvider);
  return lessons.where((l) => completedIds.contains(l.id)).length;
});
