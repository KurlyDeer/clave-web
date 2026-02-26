import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/providers/libro_provider.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_strings.dart';

/// Shows a dialog explaining a grammar error with Play and Copy actions.
void showErrorExplanationPopup(
  BuildContext context, {
  required GrammarError error,
  required TtsService tts,
  required bool isSenior,
}) {
  showDialog<void>(
    context: context,
    builder: (_) => _ErrorDialog(error: error, tts: tts, isSenior: isSenior),
  );
}

class _ErrorDialog extends StatelessWidget {
  const _ErrorDialog({
    required this.error,
    required this.tts,
    required this.isSenior,
  });

  final GrammarError error;
  final TtsService tts;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
    final labelSize = bodySize - 2;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Incorrect row
            Text(
              AppStrings.libroIncorrectEs,
              style: TextStyle(
                fontSize: labelSize,
                color: AppColors.darkText.withValues(alpha: 0.55),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              error.original,
              style: TextStyle(
                fontSize: bodySize,
                color: AppColors.terracotta,
                decoration: TextDecoration.lineThrough,
                decorationColor: AppColors.terracotta,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),

            // Correct row
            Text(
              AppStrings.libroCorrectEs,
              style: TextStyle(
                fontSize: labelSize,
                color: AppColors.darkText.withValues(alpha: 0.55),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              error.corrected,
              style: TextStyle(
                fontSize: bodySize,
                color: AppColors.deepBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            // Explanation
            Text(
              error.explanationEs,
              style: TextStyle(
                fontSize: bodySize,
                color: AppColors.darkText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            // Action buttons row
            Row(
              children: [
                Expanded(
                  child: _PopupActionButton(
                    label: AppStrings.sosPlayEs,
                    onTap: () => tts.speak(error.corrected),
                    isSenior: isSenior,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PopupActionButton(
                    label: AppStrings.sosCopyEs,
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(text: error.corrected),
                      );
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppStrings.sosCopiedEs),
                          duration: const Duration(seconds: 2),
                          backgroundColor: AppColors.terracotta,
                        ),
                      );
                    },
                    isSenior: isSenior,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            AppStrings.libroCloseEs,
            style: TextStyle(
              fontSize: bodySize,
              color: AppColors.darkText,
            ),
          ),
        ),
      ],
    );
  }
}

class _PopupActionButton extends StatelessWidget {
  const _PopupActionButton({
    required this.label,
    required this.onTap,
    required this.isSenior,
  });

  final String label;
  final VoidCallback onTap;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final fontSize =
        isSenior ? AppFontSizes.body : AppFontSizes.body - 2;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.unselectedBorder),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
        ),
      ),
    );
  }
}
