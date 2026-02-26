import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../core/providers/libro_provider.dart';
import '../../../core/theme/app_theme.dart';

/// Renders the draft text with wavy terracotta underlines on grammar errors.
/// Tap an error span to trigger [onErrorTapped].
class GrammarRichText extends StatelessWidget {
  const GrammarRichText({
    super.key,
    required this.text,
    required this.errors,
    required this.isSenior,
    required this.onErrorTapped,
  });

  final String text;
  final List<GrammarError> errors;
  final bool isSenior;
  final void Function(GrammarError error) onErrorTapped;

  @override
  Widget build(BuildContext context) {
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
    final spans = _buildSpans(bodySize);

    return SelectableText.rich(
      TextSpan(children: spans),
      style: TextStyle(
        fontSize: bodySize,
        color: AppColors.darkText,
        height: 1.6,
      ),
    );
  }

  List<InlineSpan> _buildSpans(double bodySize) {
    // Sort errors by startIndex ascending (provider already sorts, but be safe).
    final sorted = List<GrammarError>.from(errors)
      ..sort((a, b) => a.startIndex.compareTo(b.startIndex));

    final spans = <InlineSpan>[];
    int cursor = 0;

    for (final error in sorted) {
      // Guard: skip overlapping/out-of-bounds errors.
      if (error.startIndex < cursor || error.endIndex > text.length) continue;

      // Plain text before this error.
      if (cursor < error.startIndex) {
        spans.add(TextSpan(text: text.substring(cursor, error.startIndex)));
      }

      // Error span with wavy underline.
      final recognizer = TapGestureRecognizer()
        ..onTap = () => onErrorTapped(error);

      spans.add(TextSpan(
        text: text.substring(error.startIndex, error.endIndex),
        style: TextStyle(
          backgroundColor: AppColors.terracotta.withValues(alpha: 0.15),
          color: AppColors.terracotta,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.wavy,
          decorationColor: AppColors.terracotta,
        ),
        recognizer: recognizer,
      ));

      cursor = error.endIndex;
    }

    // Remaining plain text after last error.
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }

    return spans;
  }
}
