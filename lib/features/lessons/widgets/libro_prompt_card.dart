import 'package:flutter/material.dart';

import '../../../core/models/lesson_models.dart';
import '../../../core/theme/app_theme.dart';

class LibroPromptCard extends StatefulWidget {
  const LibroPromptCard({
    super.key,
    required this.slide,
    required this.currentText,
    required this.isSenior,
    required this.onTextChanged,
  });

  final LessonSlide slide;
  final String currentText;
  final bool isSenior;
  final ValueChanged<String> onTextChanged;

  @override
  State<LibroPromptCard> createState() => _LibroPromptCardState();
}

class _LibroPromptCardState extends State<LibroPromptCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentText);
    _controller.addListener(() => widget.onTextChanged(_controller.text));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bodySize = widget.isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
    final charCount = _controller.text.trim().length;
    final isUnlocked = charCount >= 5;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          // Label
          Align(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.terracotta.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '✍️ Escribe en inglés',
                style: TextStyle(
                  fontSize: bodySize - 2,
                  color: AppColors.terracotta,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Prompt (Spanish)
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
              widget.slide.contentEs,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: bodySize,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
                height: 1.4,
              ),
            ),
          ),
          // Hint (English sample)
          if (widget.slide.contentEn.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.deepBlue.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.deepBlue.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline_rounded,
                      color: AppColors.deepBlue, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ejemplo: ${widget.slide.contentEn}',
                      style: TextStyle(
                        fontSize: bodySize - 4,
                        color: AppColors.deepBlue,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          // Text field
          TextField(
            controller: _controller,
            minLines: widget.isSenior ? 4 : 3,
            maxLines: 8,
            style: TextStyle(
              fontSize: bodySize,
              color: AppColors.darkText,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: 'Escribe tu respuesta en inglés...',
              hintStyle: TextStyle(
                fontSize: bodySize - 2,
                color: AppColors.darkText.withValues(alpha: 0.35),
              ),
              filled: true,
              fillColor: AppColors.cardBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.unselectedBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: AppColors.terracotta, width: 2),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 10),
          // Character count + unlock hint
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              isUnlocked ? '¡Listo! Toca Siguiente →' : 'Escribe al menos 5 caracteres',
              style: TextStyle(
                fontSize: bodySize - 4,
                color: isUnlocked ? Colors.green[600] : AppColors.darkText.withValues(alpha: 0.45),
                fontWeight: isUnlocked ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
