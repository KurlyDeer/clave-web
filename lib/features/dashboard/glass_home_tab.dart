import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/path_lesson_provider.dart';
import '../../core/providers/repaso_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/smart_review_provider.dart';
import '../../core/providers/vocab_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_container.dart';
import '../../l10n/app_strings.dart';
import '../lessons/lesson_detail_screen.dart';
import '../repaso/repaso_screen.dart';
import 'widgets/ai_daily_lesson_card.dart';
import 'widgets/path_lesson_card.dart';
import 'widgets/premium_modal.dart';
import 'widgets/welcome_hero_widget.dart';

/// The main "Home" tab — shows the learning path.
class GlassHomeTab extends ConsumerWidget {
  const GlassHomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(pathLessonsAsyncProvider);
    final lessons = lessonsAsync.valueOrNull ?? const [];
    final completedCount = ref.watch(completedPathLessonCountProvider);
    final track = ref.watch(learningTrackProvider);
    final isPremium = ref.watch(settingsProvider).isPremium;
    final vocabStats = ref.watch(vocabStatsProvider);
    final repasoDue = ref.watch(repasoDueWordsProvider);
    final showRepaso = repasoDue.isNotEmpty || vocabStats.total > 0;
    final smartReviewCount = ref.watch(smartReviewCountProvider);

    // Index of the first incomplete lesson — that card gets a glow border.
    final nextIndex = lessons.indexWhere((l) {
      final progress = ref.watch(pathLessonProgressProvider(l.id));
      return !(progress?.completed ?? false);
    });

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.glassGradientStart,
            AppColors.glassGradientMid,
            AppColors.glassGradientEnd,
          ],
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Welcome hero ──────────────────────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 24, bottom: 12),
                child: WelcomeHeroWidget(),
              ),
            ),

            // ── AI Daily Lesson card ──────────────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 4),
                child: AiDailyLessonCard(),
              ),
            ),

            // ── Learning track toggle ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    _TrackButton(
                      label: '🌎 ${AppStrings.trackGeneralEs}',
                      isActive: track == LearningTrack.general,
                      onTap: () => ref
                          .read(learningTrackProvider.notifier)
                          .setTrack(LearningTrack.general),
                    ),
                    const SizedBox(width: 10),
                    _TrackButton(
                      label: '🇺🇸 ${AppStrings.trackCitizenshipEs}',
                      isActive: track == LearningTrack.citizenship,
                      showProBadge: !isPremium,
                      onTap: () {
                        if (isPremium) {
                          ref
                              .read(learningTrackProvider.notifier)
                              .setTrack(LearningTrack.citizenship);
                        } else {
                          showPremiumModal(context, ref);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ── Repaso card (shown when vocab exists) ─────────────────────
            if (showRepaso)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const RepasoScreen(),
                      ),
                    ),
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      child: Row(
                        children: [
                          Text('🧠',
                              style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.repasoTitleEs,
                                  style: TextStyle(
                                    fontSize: AppFontSizes.subtitle,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.glassText,
                                  ),
                                ),
                                if (repasoDue.isNotEmpty)
                                  Text(
                                    '${repasoDue.length} palabras para hoy',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.glassTextMuted,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right,
                              color: AppColors.glassTextMuted, size: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // ── Smart Review card (shown when >= 3 failed questions) ──────
            if (smartReviewCount >= 3)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                  child: GestureDetector(
                    onTap: () {
                      final notifier =
                          ref.read(smartReviewProvider.notifier);
                      final entries = notifier.pickReviewItems();
                      final result =
                          SmartReviewService.buildReviewLesson(entries);
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => LessonDetailScreen(
                            lesson: result.lesson,
                            isReviewMode: true,
                            reviewBankKeys: result.bankKeys,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              AppColors.glowTerracotta.withOpacity(0.6),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.glowTerracotta.withOpacity(0.15),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: GlassContainer(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        child: Row(
                          children: [
                            const Text('🧠',
                                style: TextStyle(fontSize: 24)),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.smartReviewTitleEs,
                                    style: TextStyle(
                                      fontSize: AppFontSizes.subtitle,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.glassText,
                                    ),
                                  ),
                                  Text(
                                    '$smartReviewCount${AppStrings.smartReviewCardSubtitleEs}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.glassTextMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right,
                                color: AppColors.glowTerracotta, size: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // ── Section header ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        AppStrings.pathTitleEs,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: AppFontSizes.title,
                          fontWeight: FontWeight.w800,
                          color: AppColors.glassText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$completedCount ${AppStrings.pathCompletedOfEs} ${lessons.length}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.glassTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Lesson cards ──────────────────────────────────────────────
            if (lessonsAsync.isLoading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.glowTerracotta,
                    ),
                  ),
                ),
              )
            else if (lessonsAsync.hasError)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Error al cargar las lecciones',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.glassTextMuted,
                      fontSize: AppFontSizes.body,
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final lesson = lessons[index];
                    final isCompleted =
                        ref.watch(pathLessonProgressProvider(lesson.id))?.completed ??
                            false;
                    final isCitizenshipLocked =
                        track == LearningTrack.citizenship && !isPremium;
                    final isNext = !isCitizenshipLocked && index == nextIndex;
                    final isLocked = isCitizenshipLocked ||
                        (!isCompleted && index != nextIndex && nextIndex != -1);
                    return PathLessonCard(
                      lesson: lesson,
                      isNextAvailable: isNext,
                      isLocked: isLocked,
                      onLockedTap: isCitizenshipLocked
                          ? () => showPremiumModal(context, ref)
                          : null,
                    );
                  },
                  childCount: lessons.length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

// ── Track button ──────────────────────────────────────────────────────────────

class _TrackButton extends StatelessWidget {
  const _TrackButton({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.showProBadge = false,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool showProBadge;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.glowTerracotta.withOpacity(0.15)
                : AppColors.glassSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? AppColors.glowTerracotta
                  : AppColors.glassBorder,
              width: isActive ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w700,
                    color: isActive
                        ? AppColors.glowTerracotta
                        : AppColors.glassTextMuted,
                  ),
                ),
              ),
              if (showProBadge) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.premiumGold,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    AppStrings.premiumBadgeEs,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
