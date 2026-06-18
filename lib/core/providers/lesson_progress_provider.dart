import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../data/curriculum_structure.dart';
import '../models/lesson_models.dart';

/// Overridden in main.dart before runApp with the opened Hive box.
final lessonProgressBoxProvider = Provider<Box<LessonProgress>>(
  (_) => throw UnimplementedError('lessonProgressBoxProvider not overridden'),
);

/// Per-lesson progress — keyed by lesson id (String).
/// Not reactive on its own; call ref.invalidate(lessonProgressProvider(id)) after writes.
final lessonProgressProvider = Provider.family<LessonProgress?, String>((ref, id) {
  final box = ref.watch(lessonProgressBoxProvider);
  return box.get(id);
});

/// Set of all completed lesson IDs. Invalidated after each lesson completion.
final completedLessonIdsProvider = Provider<Set<String>>((ref) {
  final box = ref.watch(lessonProgressBoxProvider);
  final result = <String>{};
  for (final key in box.keys) {
    final progress = box.get(key);
    if (progress != null && progress.completed) {
      result.add(key.toString());
    }
  }
  return result;
});

/// Total number of completed lessons.
final completedLessonCountProvider = Provider<int>((ref) {
  return ref.watch(completedLessonIdsProvider).length;
});

/// (completed, total) lesson count for a specific tier.
final tierProgressProvider = Provider.family<(int, int), String>((ref, tierId) {
  final completedIds = ref.watch(completedLessonIdsProvider);
  final tier = CurriculumStructure.tiers.firstWhere(
    (t) => t.id == tierId,
    orElse: () => CurriculumStructure.tiers.first,
  );
  final lessons = tier.categories
      .expand((c) => c.lessons)
      .where((l) => !l.isPlaceholder)
      .toList();
  final completed = lessons.where((l) => completedIds.contains(l.id)).length;
  return (completed, lessons.length);
});

/// Whether a tier is unlocked (its prerequisite tier is fully complete).
final isTierUnlockedProvider = Provider.family<bool, String>((ref, tierId) {
  final completedIds = ref.watch(completedLessonIdsProvider);
  return CurriculumStructure.isTierUnlocked(tierId, completedIds);
});
