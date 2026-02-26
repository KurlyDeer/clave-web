import 'package:flutter/material.dart';

import '../../../core/providers/community_provider.dart';
import '../../../core/theme/app_theme.dart';

class WinCard extends StatelessWidget {
  const WinCard({
    super.key,
    required this.post,
    required this.celebrationCount,
    required this.isSenior,
    required this.onCelebrate,
  });

  final CommunityPost post;
  final int celebrationCount;
  final bool isSenior;
  final VoidCallback onCelebrate;

  @override
  Widget build(BuildContext context) {
    final bodySize  = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
    final smallSize = isSenior ? AppFontSizes.body      : AppFontSizes.body - 2;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.emoji,
                style: TextStyle(fontSize: isSenior ? 40 : 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorEs,
                      style: TextStyle(
                        fontSize: bodySize,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      post.winEs,
                      style: TextStyle(
                        fontSize: smallSize,
                        color: AppColors.darkText,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                height: isSenior ? 52.0 : 48.0,
                child: ElevatedButton(
                  onPressed: onCelebrate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.terracotta,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Text(
                    '🙌 $celebrationCount',
                    style: TextStyle(
                      fontSize: bodySize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
