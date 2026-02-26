import 'package:flutter/material.dart';

import '../../../core/models/voice_analysis_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_strings.dart';

/// Displays the practiced sentence word-by-word with color-coded feedback:
///   🟢 Green  — perfect pronunciation
///   🟡 Yellow — understandable but heavy accent
///   🔴 Red    — missed or unrecognised
class FeedbackHeatmap extends StatelessWidget {
  const FeedbackHeatmap({
    super.key,
    required this.wordResults,
    required this.isSenior,
  });

  final List<WordResult> wordResults;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final fontSize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Word chips
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: wordResults
              .map((r) => _WordChip(result: r, fontSize: fontSize))
              .toList(),
        ),
        const SizedBox(height: 16),
        // Legend
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _LegendItem(
              color: _colorFor(WordStatus.perfect),
              label: AppStrings.analizadorPerfectLegendEs,
              fontSize: fontSize - 3,
            ),
            _LegendItem(
              color: _colorFor(WordStatus.heavy),
              label: AppStrings.analizadorHeavyLegendEs,
              fontSize: fontSize - 3,
            ),
            _LegendItem(
              color: _colorFor(WordStatus.missed),
              label: AppStrings.analizadorMissedLegendEs,
              fontSize: fontSize - 3,
            ),
          ],
        ),
      ],
    );
  }
}

// ── Word chip ──────────────────────────────────────────────────────────────────

class _WordChip extends StatelessWidget {
  const _WordChip({required this.result, required this.fontSize});

  final WordResult result;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final bg = _colorFor(result.status);
    final textColor = result.status == WordStatus.heavy
        ? AppColors.darkText
        : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        result.word,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}

// ── Legend item ────────────────────────────────────────────────────────────────

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.fontSize,
  });

  final Color color;
  final String label;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            color: AppColors.darkText.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Color helper ───────────────────────────────────────────────────────────────

Color _colorFor(WordStatus status) => switch (status) {
      WordStatus.perfect => const Color(0xFF27AE60), // green
      WordStatus.heavy => const Color(0xFFF39C12),   // amber
      WordStatus.missed => const Color(0xFFE74C3C),  // red
    };
