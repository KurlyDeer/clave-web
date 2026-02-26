import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/curriculum_data.dart';
import '../data/writing_prompts_data.dart';
import '../models/lesson_models.dart';
import 'book_pages_provider.dart';
import 'lesson_progress_provider.dart';
import 'repaso_provider.dart';

// ── Types ─────────────────────────────────────────────────────────────────────

enum NextStepType { vocabReview, lesson, bookPrompt, allDone }

class NextStep {
  const NextStep({
    required this.type,
    required this.contextMessageEs,
    this.lessonData,
    this.lessonNumber,
    this.bookPrompt,
  });

  final NextStepType type;
  final LessonData? lessonData;
  final int? lessonNumber;
  final WritingPrompt? bookPrompt;
  final String contextMessageEs;
}

// ── Provider ──────────────────────────────────────────────────────────────────

/// Computes what the user should do next.
/// Priority: vocab review due today → first incomplete lesson → next book prompt.
final nextStepProvider = Provider<NextStep>((ref) {
  // 1. Surface scheduled vocab words before anything else.
  final dueWords = ref.watch(repasoDueWordsProvider);
  if (dueWords.isNotEmpty) {
    final count = dueWords.length;
    return NextStep(
      type: NextStepType.vocabReview,
      contextMessageEs:
          'Tienes $count palabra${count == 1 ? '' : 's'} programada${count == 1 ? '' : 's'} para repasar hoy',
    );
  }

  // 2. Scan all 10 lessons
  LessonData? nextLesson;
  int completedCount = 0;

  for (final lesson in CurriculumData.all) {
    final progress = ref.watch(lessonProgressProvider(lesson.id));
    if (progress != null && progress.completed) {
      completedCount++;
    } else {
      nextLesson ??= lesson;
    }
  }

  if (nextLesson != null) {
    final remaining = 10 - completedCount;
    final msg = remaining == 1
        ? 'Te falta 1 lección para completar el curso'
        : 'Te faltan $remaining lecciones para completar el curso';
    return NextStep(
      type: NextStepType.lesson,
      lessonData: nextLesson,
      lessonNumber: nextLesson.id,
      contextMessageEs: msg,
    );
  }

  // All 10 lessons done → suggest a book page
  final bookCount = ref.watch(bookPageCountProvider);
  final prompt = WritingPromptsData.forPageCount(bookCount);
  final msg = bookCount == 0
      ? '¡Completaste todas las lecciones! Empieza a escribir tu libro.'
      : '¡Excelente! Tienes $bookCount página${bookCount == 1 ? '' : 's'} en tu libro.';

  return NextStep(
    type: NextStepType.bookPrompt,
    bookPrompt: prompt,
    contextMessageEs: msg,
  );
});
