import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class UserMessageBubble extends StatelessWidget {
  const UserMessageBubble({
    super.key,
    required this.textEn,
    required this.feedbackEs,
    required this.isAcceptable,
    required this.isSenior,
  });

  final String textEn;
  final String feedbackEs;
  final bool isAcceptable;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final textSize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
    final feedbackSize = isSenior ? AppFontSizes.body : 16.0;

    final bubbleColor =
        isAcceptable ? AppColors.deepBlue : const Color(0xFFFF6B35);

    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width > 800
              ? 600
              : MediaQuery.of(context).size.width * 0.82,
        ),
        child: Container(
          margin: const EdgeInsets.only(left: 48, right: 12, top: 4, bottom: 8),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(4),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User spoken text
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                child: Text(
                  textEn,
                  style: TextStyle(
                    fontSize: textSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ),
              // Feedback (always shown below the bubble)
              if (feedbackEs.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                  decoration: BoxDecoration(
                    color: isAcceptable
                        ? const Color(0xFF1A5276) // darker blue
                        : const Color(0xFFB94A28), // darker orange
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    feedbackEs,
                    style: TextStyle(
                      fontSize: feedbackSize,
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      height: 1.35,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
