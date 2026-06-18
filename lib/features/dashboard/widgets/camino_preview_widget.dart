import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/lesson_repository.dart';
import '../../../core/providers/lesson_progress_provider.dart';
import '../../../core/providers/path_lesson_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../l10n/app_strings.dart';
import '../../camino/camino_screen.dart';

/// Compact Camino preview shown on the home tab.
/// Displays lesson-based progress and navigates to CaminoScreen.
class CaminoPreviewWidget extends ConsumerWidget {
  const CaminoPreviewWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<PathLesson> lessons = ref.watch(pathLessonsProvider);
    final Set<String> completedIds = ref.watch(completedLessonIdsProvider);
    final int completedCount = ref.watch(completedPathLessonCountProvider);
    final int total = lessons.length;

    final double progress =
        total > 0 ? (completedCount / total).clamp(0.0, 1.0) : 0.0;
    final bool allDone = completedCount >= total && total > 0;

    PathLesson? nextLesson;
    for (final l in lessons) {
      if (!completedIds.contains(l.id)) {
        nextLesson = l;
        break;
      }
    }

    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const CaminoScreen()),
        ),
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            // Progress icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.glowTerracotta.withValues(alpha: 0.2),
                border: Border.all(
                  color: AppColors.glowTerracotta.withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  allDone ? '🏆' : (nextLesson?.iconEmoji ?? '🗺'),
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.caminoPreviewLabelEs,
                    style: TextStyle(
                      color: AppColors.glassTextMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    allDone
                        ? AppStrings.caminoAllCompleteEs
                        : (nextLesson?.titleEs ?? AppStrings.caminoTitleEs),
                    style: TextStyle(
                      color: AppColors.glassText,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.glassBorder,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.glowTerracotta),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$completedCount de $total ${AppStrings.caminoProgressEs}',
                    style: TextStyle(
                      color: AppColors.glassTextMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Chevron
            Text(
              AppStrings.caminoViewEs,
              style: TextStyle(
                color: AppColors.glowTerracotta,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
