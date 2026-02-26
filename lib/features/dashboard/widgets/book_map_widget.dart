import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/progress_provider.dart';
import '../../../core/providers/xp_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_strings.dart';
import 'xp_level_widget.dart';

class BookMapWidget extends ConsumerStatefulWidget {
  const BookMapWidget({super.key, required this.isSenior});

  final bool isSenior;

  @override
  ConsumerState<BookMapWidget> createState() => _BookMapWidgetState();
}

class _BookMapWidgetState extends ConsumerState<BookMapWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(progressProvider);
    final xpState = ref.watch(xpProvider);
    final isSenior = widget.isSenior;
    final titleSize = isSenior ? AppFontSizes.titleLarge : AppFontSizes.title;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.bookMapTitleEs,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16),
          XpLevelWidget(xpState: xpState, isSenior: isSenior),
          const SizedBox(height: 20),
          ...AppStrings.roadmapStages.asMap().entries.map((entry) {
            final idx = entry.key;
            final label = entry.value;
            final isCompleted = idx < progress.stageIndex;
            final isCurrent = idx == progress.stageIndex;
            final isLocked = idx > progress.stageIndex;

            return _ChapterCard(
              index: idx,
              label: label,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              isLocked: isLocked,
              isSenior: isSenior,
              pulseAnim: _pulseAnim,
            );
          }),
        ],
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  const _ChapterCard({
    required this.index,
    required this.label,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLocked,
    required this.isSenior,
    required this.pulseAnim,
  });

  final int index;
  final String label;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLocked;
  final bool isSenior;
  final Animation<double> pulseAnim;

  @override
  Widget build(BuildContext context) {
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;

    Widget card = Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green[50]
            : isCurrent
                ? AppColors.terracotta.withValues(alpha: 0.07)
                : AppColors.cream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCompleted
              ? Colors.green[400]!
              : isCurrent
                  ? AppColors.terracotta
                  : AppColors.unselectedBorder,
          width: isCurrent ? 2.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCompleted
                ? Icons.menu_book_rounded
                : isCurrent
                    ? Icons.auto_stories_rounded
                    : Icons.lock_outline_rounded,
            color: isCompleted
                ? Colors.green[600]
                : isCurrent
                    ? AppColors.terracotta
                    : AppColors.darkText.withValues(alpha: 0.28),
            size: isSenior ? 26 : 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: bodySize,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                color: isLocked
                    ? AppColors.darkText.withValues(alpha: 0.35)
                    : AppColors.darkText,
              ),
            ),
          ),
          if (isCompleted)
            Icon(Icons.check_circle_rounded,
                color: Colors.green[600], size: 20)
          else if (isCurrent)
            Text(
              AppStrings.bookMapCurrentChapterEs,
              style: TextStyle(
                fontSize: bodySize - 4,
                color: AppColors.terracotta,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            Text(
              AppStrings.bookMapLockedEs,
              style: TextStyle(
                fontSize: bodySize - 4,
                color: AppColors.darkText.withValues(alpha: 0.35),
              ),
            ),
        ],
      ),
    );

    if (isCurrent) {
      card = AnimatedBuilder(
        animation: pulseAnim,
        builder: (context, child) =>
            Transform.scale(scale: pulseAnim.value, child: child),
        child: card,
      );
    }

    return card;
  }
}
