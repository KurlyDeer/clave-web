import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/onboarding_controller.dart';
import '../../../core/providers/path_lesson_provider.dart';
import '../../../core/providers/shared_preferences_provider.dart';
import '../../../core/services/ai_content_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../l10n/app_strings.dart';
import '../../lessons/lesson_detail_screen.dart';

class AiDailyLessonCard extends ConsumerStatefulWidget {
  const AiDailyLessonCard({super.key});

  @override
  ConsumerState<AiDailyLessonCard> createState() => _AiDailyLessonCardState();
}

class _AiDailyLessonCardState extends ConsumerState<AiDailyLessonCard> {
  bool _isLoading = false;

  Future<void> _onTap() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      // Determine goal string
      final track = ref.read(learningTrackProvider);
      String goal;
      if (track == LearningTrack.citizenship) {
        goal = 'citizenship';
      } else {
        final userGoal = ref.read(userGoalProvider);
        switch (userGoal) {
          case UserGoal.citizenship:
            goal = 'citizenship';
          case UserGoal.career:
            goal = 'career';
          case UserGoal.travel:
            goal = 'travel';
          case null:
            goal = 'general';
        }
      }

      // Map placement level to CEFR
      final prefs = ref.read(sharedPreferencesProvider);
      final levelName = prefs.getString('placement_level');
      String cefr;
      switch (levelName) {
        case 'advanced':
          cefr = 'B1';
        case 'intermediate':
          cefr = 'A2';
        default:
          cefr = 'A1';
      }

      final lesson = await ref
          .read(aiContentServiceProvider)
          .generateCustomLesson(userGoal: goal, userLevel: cefr);

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => LessonDetailScreen(lesson: lesson),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.aiDailyLessonErrorEs),
          backgroundColor: AppColors.glowTerracotta,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFD4AF37).withOpacity(0.7),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.glowTerracotta.withOpacity(0.18),
              blurRadius: 14,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: const Color(0xFFD4AF37).withOpacity(0.12),
              blurRadius: 20,
              spreadRadius: 4,
            ),
          ],
        ),
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              _isLoading
                  ? SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.glowTerracotta,
                      ),
                    )
                  : const Text('⭐', style: TextStyle(fontSize: 26)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isLoading
                          ? AppStrings.aiDailyLessonLoadingEs
                          : AppStrings.aiDailyLessonTitleEs,
                      style: TextStyle(
                        fontSize: AppFontSizes.subtitle,
                        fontWeight: FontWeight.w700,
                        color: AppColors.glassText,
                      ),
                    ),
                    if (!_isLoading)
                      Text(
                        AppStrings.aiDailyLessonSubtitleEs,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.glassTextMuted,
                        ),
                      ),
                  ],
                ),
              ),
              if (!_isLoading)
                Icon(Icons.chevron_right,
                    color: const Color(0xFFD4AF37), size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
