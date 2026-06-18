import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';

class GlassAiBubble extends StatelessWidget {
  const GlassAiBubble({
    super.key,
    required this.textEn,
    required this.hintEs,
    required this.isSenior,
    required this.onReplay,
  });

  final String textEn;
  final String hintEs;
  final bool isSenior;
  final VoidCallback onReplay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 60, bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        borderRadius: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              textEn,
              style: TextStyle(
                fontSize:
                    isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body,
                color: AppColors.glassText,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (hintEs.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                '💡 $hintEs',
                style: TextStyle(
                  fontSize: isSenior ? AppFontSizes.body : 14,
                  color: AppColors.glassTextMuted,
                ),
              ),
            ],
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onReplay,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.replay_rounded,
                    size: 16,
                    color: AppColors.glowTerracotta,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Escuchar',
                    style: TextStyle(
                      fontSize: isSenior ? AppFontSizes.body - 2 : 13,
                      color: AppColors.glowTerracotta,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
