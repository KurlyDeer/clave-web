import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_strings.dart';

class AiMessageBubble extends StatelessWidget {
  const AiMessageBubble({
    super.key,
    required this.textEn,
    required this.hintEs,
    required this.isSenior,
    this.onReplay,
  });

  final String textEn;
  final String hintEs;
  final bool isSenior;
  final VoidCallback? onReplay;

  @override
  Widget build(BuildContext context) {
    final textSize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
    final hintSize = isSenior ? AppFontSizes.body : 16.0;

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width > 800
              ? 600
              : MediaQuery.of(context).size.width * 0.82,
        ),
        child: Container(
          margin: const EdgeInsets.only(left: 12, right: 48, top: 8, bottom: 4),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(16),
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
              // English text + replay button
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        textEn,
                        style: TextStyle(
                          fontSize: textSize,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                          height: 1.4,
                        ),
                      ),
                    ),
                    if (onReplay != null) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: onReplay,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            Icons.volume_up_rounded,
                            size: isSenior ? 28 : 22,
                            color: AppColors.deepBlue,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Hint section
              if (hintEs.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1), // cream yellow
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: hintSize,
                        color: const Color(0xFFE67E22),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.simuladorHintLabelEs,
                              style: TextStyle(
                                fontSize: hintSize - 2,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFE67E22),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              hintEs,
                              style: TextStyle(
                                fontSize: hintSize,
                                color: Colors.grey[700],
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
