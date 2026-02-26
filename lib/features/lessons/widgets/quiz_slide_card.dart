import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_strings.dart';
import '../../../core/models/lesson_models.dart';

class QuizSlideCard extends StatelessWidget {
  const QuizSlideCard({
    super.key,
    required this.slide,
    required this.selectedAnswer,
    required this.quizCorrect,
    required this.isSenior,
    required this.onSelectAnswer,
  });

  final LessonSlide slide;
  final int? selectedAnswer;
  final bool? quizCorrect;
  final bool isSenior;
  final ValueChanged<int> onSelectAnswer;

  @override
  Widget build(BuildContext context) {
    final titleSize = isSenior ? AppFontSizes.titleLarge : AppFontSizes.title;
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
    final options = slide.options ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          // Question label
          Align(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.deepBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '❓ Pregunta',
                style: TextStyle(
                  fontSize: bodySize - 2,
                  color: AppColors.deepBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Question text
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Text(
              slide.contentEs,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: titleSize - 4,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Answer options
          ...options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = selectedAnswer == index;
            final isCorrect = slide.correctIndex == index;
            final answered = selectedAnswer != null;

            Color bgColor = AppColors.cardBackground;
            Color borderColor = AppColors.unselectedBorder;
            Color textColor = AppColors.darkText;
            Widget? trailingIcon;

            if (isSelected) {
              if (quizCorrect == true) {
                bgColor = Colors.green[50]!;
                borderColor = Colors.green[400]!;
                textColor = Colors.green[800]!;
                trailingIcon = const Icon(Icons.check_circle_rounded,
                    color: Colors.green, size: 22);
              } else {
                bgColor = Colors.red[50]!;
                borderColor = Colors.red[300]!;
                textColor = Colors.red[800]!;
                trailingIcon =
                    const Icon(Icons.cancel_rounded, color: Colors.red, size: 22);
              }
            } else if (answered && isCorrect && quizCorrect == true) {
              // highlight correct after wrong answer (not applicable here since
              // wrong keeps locked, but included for completeness)
              bgColor = Colors.green[50]!;
              borderColor = Colors.green[400]!;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: answered && quizCorrect == true ? null : () => onSelectAnswer(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: isSenior ? 20 : 16,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: bodySize,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      ),
                      ?trailingIcon,
                    ],
                  ),
                ),
              ),
            );
          }),
          // Feedback message
          if (selectedAnswer != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: quizCorrect == true ? Colors.green[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                quizCorrect == true
                    ? AppStrings.lessonQuizCorrectEs
                    : AppStrings.lessonQuizWrongEs,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: bodySize - 2,
                  fontWeight: FontWeight.w600,
                  color: quizCorrect == true
                      ? Colors.green[700]
                      : Colors.red[700],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
