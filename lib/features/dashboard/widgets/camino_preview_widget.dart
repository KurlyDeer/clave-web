import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/milestone_data.dart';
import '../../../core/providers/xp_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../l10n/app_strings.dart';
import '../../camino/camino_screen.dart';

/// Compact Camino preview shown on the home tab.
/// Displays current milestone + progress bar to next, and navigates to CaminoScreen.
class CaminoPreviewWidget extends ConsumerWidget {
  const CaminoPreviewWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalXp = ref.watch(xpProvider).totalXp;

    // Find the highest unlocked milestone index
    int currentIndex = 0;
    for (int i = kMilestones.length - 1; i >= 0; i--) {
      if (totalXp >= kMilestones[i].xpRequired) {
        currentIndex = i;
        break;
      }
    }

    final current = kMilestones[currentIndex];
    final hasNext = currentIndex < kMilestones.length - 1;
    final next = hasNext ? kMilestones[currentIndex + 1] : null;

    double progress = 1.0;
    if (next != null) {
      final span = next.xpRequired - current.xpRequired;
      final earned = totalXp - current.xpRequired;
      progress = span > 0 ? (earned / span).clamp(0.0, 1.0) : 1.0;
    }

    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const CaminoScreen(),
          ),
        ),
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            // Milestone icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.glowTerracotta.withValues(alpha:0.2),
                border: Border.all(
                    color: AppColors.glowTerracotta.withValues(alpha:0.6),
                    width: 1.5),
              ),
              child: Center(
                child: Icon(
                  current.icon,
                  color: AppColors.glowTerracotta,
                  size: 24,
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
                    style: const TextStyle(
                      color: AppColors.glassTextMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    current.titleEs,
                    style: const TextStyle(
                      color: AppColors.glassText,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (next != null) ...[
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
                      '$totalXp / ${next.xpRequired} XP → ${next.titleEs}',
                      style: const TextStyle(
                        color: AppColors.glassTextMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Chevron
            Text(
              AppStrings.caminoViewEs,
              style: const TextStyle(
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
