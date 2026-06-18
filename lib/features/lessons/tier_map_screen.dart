import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/curriculum_structure.dart';
import '../../core/models/curriculum_models.dart';
import '../../core/models/lesson_models.dart';
import '../../core/providers/lesson_progress_provider.dart';
import '../../core/providers/persona_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_container.dart';
import '../../l10n/app_strings.dart';
import 'lesson_player_screen.dart';

/// Hierarchical browser showing all 4 tiers → categories → lessons.
class TierMapScreen extends ConsumerStatefulWidget {
  const TierMapScreen({super.key});

  @override
  ConsumerState<TierMapScreen> createState() => _TierMapScreenState();
}

class _TierMapScreenState extends ConsumerState<TierMapScreen> {
  // Track which tiers are expanded
  final Set<String> _expanded = {'fundamentos', 'principiante'};

  @override
  Widget build(BuildContext context) {
    final persona = ref.watch(personaProvider);
    final isSenior = persona?.isSeniorMode ?? false;
    final completedIds = ref.watch(completedLessonIdsProvider);

    return Scaffold(
      backgroundColor: AppColors.glassGradientStart,
      appBar: AppBar(
        backgroundColor: AppColors.glassGradientStart,
        foregroundColor: AppColors.glassText,
        elevation: 0,
        title: Text(
          AppStrings.tierMapTitleEs,
          style: TextStyle(
            fontSize: isSenior ? AppFontSizes.titleLarge : AppFontSizes.title,
            fontWeight: FontWeight.w800,
            color: AppColors.glassText,
          ),
        ),
      ),
      body: Container(
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: CurriculumStructure.tiers.map((tier) {
            final isUnlocked = CurriculumStructure.isTierUnlocked(tier.id, completedIds);
            final progress = ref.watch(tierProgressProvider(tier.id));
            return _TierSection(
              tier: tier,
              isUnlocked: isUnlocked,
              completedCount: progress.$1,
              totalCount: progress.$2,
              completedIds: completedIds,
              isSenior: isSenior,
              isExpanded: _expanded.contains(tier.id),
              onToggle: () => setState(() {
                if (_expanded.contains(tier.id)) {
                  _expanded.remove(tier.id);
                } else {
                  _expanded.add(tier.id);
                }
              }),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Tier Section ──────────────────────────────────────────────────────────────

class _TierSection extends ConsumerWidget {
  const _TierSection({
    required this.tier,
    required this.isUnlocked,
    required this.completedCount,
    required this.totalCount,
    required this.completedIds,
    required this.isSenior,
    required this.isExpanded,
    required this.onToggle,
  });

  final TierData tier;
  final bool isUnlocked;
  final int completedCount;
  final int totalCount;
  final Set<String> completedIds;
  final bool isSenior;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleSize = isSenior ? AppFontSizes.titleLarge : AppFontSizes.title;
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
    final fillFraction =
        totalCount == 0 ? 0.0 : (completedCount / totalCount).clamp(0.0, 1.0);

    // Gate description
    String? gateMsg;
    if (!isUnlocked && tier.requiredTierId != null) {
      final reqTier = CurriculumStructure.tiers
          .firstWhere((t) => t.id == tier.requiredTierId!);
      gateMsg = '${AppStrings.tierLockedEs} ${reqTier.titleEs}';
    }

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          InkWell(
            onTap: isUnlocked ? onToggle : null,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isUnlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                        color: isUnlocked
                            ? AppColors.glowTerracotta
                            : AppColors.glassTextMuted,
                        size: isSenior ? 28 : 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tier.titleEs,
                              style: TextStyle(
                                fontSize: titleSize,
                                fontWeight: FontWeight.w800,
                                color: isUnlocked
                                    ? AppColors.glassText
                                    : AppColors.glassTextMuted,
                              ),
                            ),
                            Text(
                              tier.titleEn,
                              style: TextStyle(
                                fontSize: bodySize - 2,
                                color: AppColors.glassTextMuted,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isUnlocked)
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: AppColors.glassTextMuted,
                        ),
                    ],
                  ),
                  // Progress bar (only for unlocked tiers)
                  if (isUnlocked && totalCount > 0) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        height: 6,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Container(color: AppColors.glassHighlight),
                            FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: fillFraction,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.glowTerracotta,
                                      AppColors.terracotta,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$completedCount / $totalCount ${AppStrings.glassProgressLessonsEs}',
                      style: TextStyle(
                        fontSize: bodySize - 2,
                        color: AppColors.glassTextMuted,
                      ),
                    ),
                  ],
                  // Lock message
                  if (!isUnlocked && gateMsg != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      gateMsg,
                      style: TextStyle(
                        fontSize: bodySize - 2,
                        color: AppColors.glassTextMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // ── Category list (expanded) ─────────────────────────────────────
          if (isUnlocked && isExpanded)
            ...tier.categories.map((cat) => _CategorySection(
                  category: cat,
                  completedIds: completedIds,
                  isSenior: isSenior,
                )),
        ],
      ),
    );
  }
}

// ── Category Section ──────────────────────────────────────────────────────────

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.completedIds,
    required this.isSenior,
  });

  final CategoryData category;
  final Set<String> completedIds;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header
        Container(
          color: AppColors.glassHighlight,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.folder_open_rounded,
                  color: AppColors.glassTextMuted, size: 18),
              const SizedBox(width: 8),
              Text(
                category.titleEs,
                style: TextStyle(
                  fontSize: bodySize - 2,
                  fontWeight: FontWeight.w700,
                  color: AppColors.glassTextMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        // Lesson rows
        ...category.lessons.map((lesson) => _LessonRow(
              lesson: lesson,
              isCompleted: completedIds.contains(lesson.id),
              isSenior: isSenior,
            )),
      ],
    );
  }
}

// ── Lesson Row ────────────────────────────────────────────────────────────────

class _LessonRow extends ConsumerWidget {
  const _LessonRow({
    required this.lesson,
    required this.isCompleted,
    required this.isSenior,
  });

  final LessonData lesson;
  final bool isCompleted;
  final bool isSenior;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
    final persona = ref.watch(personaProvider);
    final personaKey = persona?.name ?? 'adulto';
    final content = lesson.forPersona(personaKey);

    return InkWell(
      onTap: lesson.isPlaceholder
          ? null
          : () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => LessonPlayerScreen(lesson: lesson),
              )),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.glassBorder, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Order badge
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green.withValues(alpha: 0.15)
                    : lesson.isPlaceholder
                        ? AppColors.glassHighlight
                        : AppColors.glowTerracotta.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  isCompleted
                      ? Icons.check_rounded
                      : lesson.isPlaceholder
                          ? Icons.hourglass_empty_rounded
                          : Icons.play_arrow_rounded,
                  size: 18,
                  color: isCompleted
                      ? Colors.green[600]
                      : lesson.isPlaceholder
                          ? AppColors.glassTextMuted
                          : AppColors.glowTerracotta,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.isPlaceholder ? content.titleEs : content.titleEs,
                    style: TextStyle(
                      fontSize: bodySize,
                      fontWeight: FontWeight.w600,
                      color: lesson.isPlaceholder
                          ? AppColors.glassTextMuted
                          : AppColors.glassText,
                    ),
                  ),
                  if (lesson.isPlaceholder)
                    Text(
                      AppStrings.tierComingSoonEs,
                      style: TextStyle(
                        fontSize: bodySize - 4,
                        color: AppColors.glassTextMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            if (!lesson.isPlaceholder)
              Icon(
                Icons.chevron_right,
                color: AppColors.glassTextMuted,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
