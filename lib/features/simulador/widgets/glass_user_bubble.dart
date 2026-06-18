import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class GlassUserBubble extends StatelessWidget {
  const GlassUserBubble({
    super.key,
    required this.textEn,
    required this.feedbackColor,
    required this.isSenior,
  });

  final String textEn;
  final String feedbackColor;
  final bool isSenior;

  Color get _glowColor {
    switch (feedbackColor) {
      case 'green':
        return const Color(0xFF27AE60);
      case 'red':
        return const Color(0xFFE74C3C);
      default:
        return const Color(0xFFF39C12); // amber
    }
  }

  @override
  Widget build(BuildContext context) {
    final glow = _glowColor;
    return Padding(
      padding: const EdgeInsets.only(left: 60, bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: glow.withAlpha(38), // ~15% opacity
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: glow.withAlpha(178), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: glow.withAlpha(102), // 0.4 opacity
              blurRadius: 12,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Text(
          textEn,
          style: TextStyle(
            fontSize: isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body,
            color: AppColors.glassText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
