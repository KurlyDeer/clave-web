import 'package:flutter/material.dart';

import '../../../core/models/lesson_models.dart';
import '../../../core/theme/app_theme.dart';

class GrammarFlipCard extends StatefulWidget {
  const GrammarFlipCard({
    super.key,
    required this.slide,
    required this.currentOrder,
    required this.flipCorrect,
    required this.isSenior,
    required this.onOrderChanged,
    required this.onCheck,
    required this.onReset,
  });

  final LessonSlide slide;
  final List<String> currentOrder;
  final bool? flipCorrect;
  final bool isSenior;
  final ValueChanged<List<String>> onOrderChanged;
  final VoidCallback onCheck;
  final VoidCallback onReset;

  @override
  State<GrammarFlipCard> createState() => _GrammarFlipCardState();
}

class _GrammarFlipCardState extends State<GrammarFlipCard> {
  // All available words from options
  List<String> get _pool => widget.slide.options ?? [];

  // Which words have been placed by the user (selected)
  List<String> get _placed => widget.currentOrder;

  // Words still in pool (available to tap)
  List<String> get _available {
    final placed = List<String>.from(_placed);
    final avail = <String>[];
    for (final w in _pool) {
      final idx = placed.indexOf(w);
      if (idx >= 0) {
        placed.removeAt(idx); // consume one occurrence
      } else {
        avail.add(w);
      }
    }
    return avail;
  }

  void _addWord(String word) {
    if (widget.flipCorrect == true) return;
    final newOrder = [..._placed, word];
    widget.onOrderChanged(newOrder);
  }

  void _removeWord(int index) {
    if (widget.flipCorrect == true) return;
    final newOrder = List<String>.from(_placed)..removeAt(index);
    widget.onOrderChanged(newOrder);
  }

  @override
  Widget build(BuildContext context) {
    final bodySize = widget.isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
    final chipSize = widget.isSenior ? bodySize : bodySize - 2;
    final isCorrect = widget.flipCorrect == true;
    final isWrong = widget.flipCorrect == false;

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
                '🔀 Ordena las palabras',
                style: TextStyle(
                  fontSize: bodySize - 2,
                  color: AppColors.terracotta,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Translation hint
          Text(
            widget.slide.contentEs,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: bodySize,
              color: AppColors.darkText.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 20),
          // Sentence builder area
          Container(
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCorrect
                  ? Colors.green[50]
                  : isWrong
                      ? Colors.red[50]
                      : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCorrect
                    ? Colors.green[400]!
                    : isWrong
                        ? Colors.red[300]!
                        : AppColors.unselectedBorder,
                width: 2,
              ),
            ),
            child: _placed.isEmpty
                ? Center(
                    child: Text(
                      'Toca las palabras de abajo',
                      style: TextStyle(
                        fontSize: chipSize,
                        color: AppColors.darkText.withValues(alpha: 0.35),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _placed.asMap().entries.map((e) {
                      return GestureDetector(
                        onTap: () => _removeWord(e.key),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isCorrect
                                ? Colors.green[100]
                                : isWrong
                                    ? Colors.red[100]
                                    : AppColors.deepBlue,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            e.value,
                            style: TextStyle(
                              fontSize: chipSize,
                              fontWeight: FontWeight.w600,
                              color: isCorrect || isWrong
                                  ? AppColors.darkText
                                  : Colors.white,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 8),
          // Feedback
          if (isCorrect)
            _feedbackRow(
              '¡Correcto! 🎉',
              Colors.green[700]!,
              Colors.green[50]!,
            )
          else if (isWrong)
            _feedbackRow(
              'No es correcto, inténtalo de nuevo.',
              Colors.red[700]!,
              Colors.red[50]!,
            ),
          if (isWrong) ...[
            const SizedBox(height: 8),
            Align(
              child: TextButton.icon(
                onPressed: widget.onReset,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Reintentar'),
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.terracotta),
              ),
            ),
          ],
          const SizedBox(height: 20),
          // Available word chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _available.map((word) {
              return GestureDetector(
                onTap: () => _addWord(word),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.deepBlue.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    word,
                    style: TextStyle(
                      fontSize: chipSize,
                      fontWeight: FontWeight.w600,
                      color: AppColors.deepBlue,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          // Check button (only when all words placed and not yet correct)
          if (!isCorrect && _placed.length == _pool.length)
            SizedBox(
              height: widget.isSenior ? 64 : 52,
              child: ElevatedButton(
                onPressed: widget.onCheck,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.terracotta,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Verificar',
                  style: TextStyle(
                    fontSize: bodySize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _feedbackRow(String msg, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: widget.isSenior ? AppFontSizes.bodyLarge - 2 : AppFontSizes.body - 2,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
