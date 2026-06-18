import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/lesson_repository.dart';
import '../../../core/providers/path_lesson_provider.dart';
import '../../../core/providers/persona_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../lessons/lesson_detail_screen.dart';

class PathLessonCard extends ConsumerWidget {
  const PathLessonCard({
    super.key,
    required this.lesson,
    required this.isNextAvailable,
    this.isLocked = false,
    this.onLockedTap,
  });

  final PathLesson lesson;

  /// True when this is the next lesson the user should tackle —
  /// renders a glowing terracotta border to draw attention.
  final bool isNextAvailable;

  /// True when this lesson is not yet unlocked — dims the card and disables tap.
  final bool isLocked;

  /// If provided and [isLocked] is true, tapping the card calls this instead
  /// of navigating (e.g. to show the premium modal).
  final VoidCallback? onLockedTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final persona = ref.watch(personaProvider);
    final isSenior = persona?.isSeniorMode ?? false;
    final progress = ref.watch(pathLessonProgressProvider(lesson.id));
    final isCompleted = progress?.completed ?? false;
    final diffColor = AppGlassStyles.difficultyColor(lesson.difficulty);

    final titleSize =
        isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle;
    final subtitleSize = isSenior ? 20.0 : 16.0;

    BoxDecoration cardDecoration;
    if (isCompleted) {
      cardDecoration = AppGlassStyles.glowBorder(AppColors.successGreen);
    } else if (isNextAvailable) {
      cardDecoration = AppGlassStyles.glowBorder(AppColors.glowTerracotta);
    } else {
      cardDecoration = AppGlassStyles.cardDecoration;
    }

    final cardContent = Container(
      decoration: cardDecoration,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Emoji
          Text(lesson.iconEmoji,
              style: TextStyle(fontSize: isSenior ? 36 : 30)),
          const SizedBox(width: 16),

          // Title + subtitle + badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DifficultyBadge(label: lesson.difficulty, color: diffColor),
                const SizedBox(height: 6),
                Text(
                  lesson.titleEs,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                    color: AppColors.glassText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  lesson.titleEn,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: subtitleSize,
                    color: AppColors.glassTextMuted,
                  ),
                ),
                if (isCompleted) ...[
                  const SizedBox(height: 4),
                  Text(
                    '✓ Completada',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.successGreen,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Completion indicator
          if (isCompleted)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.successGreen.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.successGreen, width: 2),
              ),
              child: Icon(Icons.check, color: AppColors.successGreen, size: 18),
            )
          else if (isLocked)
            Icon(Icons.lock_rounded, color: AppColors.glassTextMuted, size: 22)
          else
            Icon(Icons.chevron_right,
                color: AppColors.glassTextMuted, size: 24),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: isLocked
          ? (onLockedTap != null
              ? GestureDetector(
                  onTap: onLockedTap,
                  child: Opacity(opacity: 0.45, child: cardContent),
                )
              : Opacity(opacity: 0.45, child: cardContent))
          : GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => LessonDetailScreen(lesson: lesson),
                ),
              ),
              child: cardContent,
            ),
    );
  }
}

// ── Difficulty Badge ──────────────────────────────────────────────────────

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: AppTextStyles.difficultyBadge(color),
      ),
    );
  }
}
