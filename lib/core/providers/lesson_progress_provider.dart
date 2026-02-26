import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/lesson_models.dart';

/// Overridden in main.dart before runApp with the opened Hive box.
final lessonProgressBoxProvider = Provider<Box<LessonProgress>>(
  (_) => throw UnimplementedError('lessonProgressBoxProvider not overridden'),
);

/// Per-lesson progress — keyed by lesson id (1–10).
/// Not reactive on its own; call ref.invalidate(lessonProgressProvider(id)) after writes.
final lessonProgressProvider = Provider.family<LessonProgress?, int>((ref, id) {
  final box = ref.watch(lessonProgressBoxProvider);
  return box.get(id);
});

/// Total number of completed lessons — invalidated by LessonNotifier after each completion.
final completedLessonCountProvider = Provider<int>((ref) {
  final box = ref.watch(lessonProgressBoxProvider);
  return box.values.where((p) => p.completed).length;
});
