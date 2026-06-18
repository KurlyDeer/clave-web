import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/curriculum_structure.dart';
import '../data/writing_prompts_data.dart';
import '../models/lesson_models.dart';
import 'book_pages_provider.dart';
import 'lesson_progress_provider.dart';
import 'repaso_provider.dart';
import 'study_plan_provider.dart';
import 'vocab_provider.dart';

// ── Types ─────────────────────────────────────────────────────────────────────

enum NextStepType { vocabReview, lesson, bookPrompt, allDone }

class NextStep {
  const NextStep({
    required this.type,
    required this.contextMessageEs,
    this.lessonData,
    this.bookPrompt,
    this.tierTitleEs,
    this.categoryTitleEs,
    this.studyPlan,
    this.secondarySuggestion,
  });

  final NextStepType type;
  final LessonData? lessonData;
  final WritingPrompt? bookPrompt;
  final String contextMessageEs;
  final String? tierTitleEs;          // tier name for context display
  final String? categoryTitleEs;      // category name for context display
  final StudyPlanDuration? studyPlan; // active study plan
  final String? secondarySuggestion;  // shown on deep-mode cards
}

// ── Provider ──────────────────────────────────────────────────────────────────

/// Computes what the user should do next.
/// Priority: vocab review → (quick: repaso if vocab exists) → lesson → book prompt.
final nextStepProvider = Provider<NextStep>((ref) {
  final studyPlan = ref.watch(studyPlanProvider);

  // 1. Scheduled vocab review is always first.
  final dueWords = ref.watch(repasoDueWordsProvider);
  if (dueWords.isNotEmpty) {
    final count = dueWords.length;
    return NextStep(
      type: NextStepType.vocabReview,
      studyPlan: studyPlan,
      contextMessageEs:
          'Tienes $count palabra${count == 1 ? '' : 's'} programada${count == 1 ? '' : 's'} para repasar hoy',
    );
  }

  // 2. Quick mode: if vocab words exist (not scheduled today but still to learn),
  //    surface a repaso session as the next micro-task.
  if (studyPlan == StudyPlanDuration.quick) {
    final vocabStats = ref.watch(vocabStatsProvider);
    if (vocabStats.total > 0) {
      return NextStep(
        type: NextStepType.vocabReview,
        studyPlan: studyPlan,
        contextMessageEs:
            'Tienes ${vocabStats.total} palabras en tu vocabulario — repasa rápido',
      );
    }
  }

  // 3. Scan tiers in order; find first incomplete non-placeholder lesson.
  final completedIds = ref.watch(completedLessonIdsProvider);
  LessonData? nextLesson;
  String? nextTierTitleEs;
  String? nextCategoryTitleEs;

  for (final tier in CurriculumStructure.tiers) {
    final unlocked = CurriculumStructure.isTierUnlocked(tier.id, completedIds);
    if (!unlocked) continue;

    for (final category in tier.categories) {
      for (final lesson in category.lessons) {
        if (lesson.isPlaceholder) continue;
        final progress = ref.watch(lessonProgressProvider(lesson.id));
        if (progress == null || !progress.completed) {
          nextLesson = lesson;
          nextTierTitleEs = tier.titleEs;
          nextCategoryTitleEs = category.titleEs;
          break;
        }
      }
      if (nextLesson != null) break;
    }
    if (nextLesson != null) break;
  }

  if (nextLesson != null) {
    final allReal = CurriculumStructure.allLessons
        .where((l) => !l.isPlaceholder)
        .toList();
    final total = allReal.length;
    final completed =
        allReal.where((l) => completedIds.contains(l.id)).length;
    final remaining = total - completed;
    final msg = remaining == 1
        ? 'Te falta 1 lección para completar el curso'
        : 'Te faltan $remaining lecciones para completar el curso';

    // Deep mode: suggest a follow-up activity
    String? secondary;
    if (studyPlan == StudyPlanDuration.deep) {
      secondary = 'Después: 🎤 Analizador de Pronunciación';
    }

    return NextStep(
      type: NextStepType.lesson,
      lessonData: nextLesson,
      tierTitleEs: nextTierTitleEs,
      categoryTitleEs: nextCategoryTitleEs,
      studyPlan: studyPlan,
      contextMessageEs: msg,
      secondarySuggestion: secondary,
    );
  }

  // All real lessons done → suggest a book page
  final bookCount = ref.watch(bookPageCountProvider);
  final prompt = WritingPromptsData.forPageCount(bookCount);
  final msg = bookCount == 0
      ? '¡Completaste todas las lecciones! Empieza a escribir tu libro.'
      : '¡Excelente! Tienes $bookCount página${bookCount == 1 ? '' : 's'} en tu libro.';

  return NextStep(
    type: NextStepType.bookPrompt,
    bookPrompt: prompt,
    studyPlan: studyPlan,
    contextMessageEs: msg,
  );
});
