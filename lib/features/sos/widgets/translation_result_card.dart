import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/providers/sos_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_strings.dart';

class TranslationResultCard extends StatelessWidget {
  const TranslationResultCard({
    super.key,
    required this.option,
    required this.isSenior,
    required this.onPlay,
  });

  final TranslationOption option;
  final bool isSenior;
  final VoidCallback onPlay;

  Color get _chipColor {
    switch (option.tone) {
      case 'Formal':
        return AppColors.deepBlue;
      case 'Urgente':
        return Colors.red[700]!;
      default:
        return AppColors.terracotta;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Chip(
            backgroundColor: _chipColor,
            label: Text(
              option.toneEs,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(height: 10),
          Text(
            option.text,
            style: TextStyle(
              fontSize: bodySize,
              color: AppColors.darkText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ActionButton(
                label: AppStrings.sosPlayEs,
                onTap: onPlay,
                isSenior: isSenior,
              ),
              const SizedBox(width: 12),
              _ActionButton(
                label: AppStrings.sosCopyEs,
                onTap: () => _copyText(context),
                isSenior: isSenior,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _copyText(BuildContext context) {
    Clipboard.setData(ClipboardData(text: option.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.sosCopiedEs),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.terracotta,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.unselectedBorder),
          borderRadius: BorderRadius.circular(8),
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
