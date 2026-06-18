import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/providers/libro_provider.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../l10n/app_strings.dart';

/// Shows a glass dialog explaining a grammar error with Play and Copy actions.
void showErrorExplanationPopup(
  BuildContext context, {
  required GrammarError error,
  required AudioService tts,
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
  final AudioService tts;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
    final labelSize = bodySize - 2;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        backgroundColor: AppColors.glassGradientMid.withValues(alpha: 0.95),
        borderColor: AppColors.glassBorder,
        borderRadius: 20,
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Incorrect row
              Text(
                AppStrings.libroIncorrectEs,
                style: TextStyle(
                  fontSize: labelSize,
                  color: AppColors.glassTextMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                error.original,
                style: TextStyle(
                  fontSize: bodySize,
                  color: AppColors.glowTerracotta,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: AppColors.glowTerracotta,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),

              // Correct row
              Text(
                AppStrings.libroCorrectEs,
                style: TextStyle(
                  fontSize: labelSize,
                  color: AppColors.glassTextMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                error.corrected,
                style: TextStyle(
                  fontSize: bodySize,
                  color: const Color(0xFF69F0AE),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              // Explanation
              Text(
                error.explanationEs,
                style: TextStyle(
                  fontSize: bodySize,
                  color: AppColors.glassText,
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
                            backgroundColor: AppColors.glowTerracotta,
                          ),
                        );
                      },
                      isSenior: isSenior,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Close
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text(
                    AppStrings.libroCloseEs,
                    style: TextStyle(
                      fontSize: bodySize,
                      color: AppColors.glassTextMuted,
                    ),
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
    final fontSize = isSenior ? AppFontSizes.body : AppFontSizes.body - 2;

    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        borderRadius: 10,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 28),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: AppColors.glassText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
