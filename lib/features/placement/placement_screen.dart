import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/persona_provider.dart';
import '../../core/providers/placement_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_strings.dart';
import '../dashboard/dashboard_screen.dart';

class PlacementScreen extends ConsumerStatefulWidget {
  const PlacementScreen({super.key});

  @override
  ConsumerState<PlacementScreen> createState() => _PlacementScreenState();
}

class _PlacementScreenState extends ConsumerState<PlacementScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _goToDashboard() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(placementProvider);
    final isSenior = ref.watch(personaProvider)?.isSeniorMode ?? false;

    // Auto-scroll whenever messages update.
    if (state.messages.isNotEmpty) {
      _scrollToBottom();
    }

    final questionIndex = state.currentQuestionIndex;
    final showStepIndicator = !state.isComplete;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.deepBlue,
        foregroundColor: AppColors.lightText,
        automaticallyImplyLeading: false,
        title: Text(
          AppStrings.placementTitle,
          style: TextStyle(
            fontSize: isSenior ? AppFontSizes.titleLarge : AppFontSizes.title,
            fontWeight: FontWeight.w700,
            color: AppColors.lightText,
          ),
        ),
        actions: [
          if (showStepIndicator)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Chip(
                  backgroundColor: AppColors.terracotta,
                  label: Text(
                    '${AppStrings.placementQuestionOf} ${questionIndex + 1} ${AppStrings.placementQuestionOfTotal}',
                    style: TextStyle(
                      color: AppColors.lightText,
                      fontSize: isSenior
                          ? AppFontSizes.bodyLarge - 2
                          : AppFontSizes.body - 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: state.messages.length + (state.isWaiting ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.messages.length && state.isWaiting) {
                  return const _TypingIndicator();
                }
                final message = state.messages[index];
                return TweenAnimationBuilder<double>(
                  key: ValueKey(index),
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, value, child) => Opacity(
                    opacity: value,
                    child: child,
                  ),
                  child: _ChatBubble(
                    message: message,
                    isSenior: isSenior,
                  ),
                );
              },
            ),
          ),
          if (!state.isComplete && !state.isWaiting && state.messages.isNotEmpty)
            _AnswerButtons(
              questionIndex: state.currentQuestionIndex,
              isSenior: isSenior,
              onSelect: (i) =>
                  ref.read(placementProvider.notifier).selectAnswer(i),
            ),
          if (state.isComplete)
            _CompletionButton(isSenior: isSenior, onTap: _goToDashboard),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Chat Bubble ────────────────────────────────────────────────────────────────

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message, required this.isSenior});

  final ChatMessage message;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final isApp = message.isFromApp;
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;

    return Align(
      alignment: isApp ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(
          top: 6,
          bottom: 6,
          left: isApp ? 0 : 48,
          right: isApp ? 48 : 0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isApp ? AppColors.deepBlue : AppColors.terracotta,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isApp ? 4 : 18),
            bottomRight: Radius.circular(isApp ? 18 : 4),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            fontSize: bodySize,
            color: AppColors.lightText,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

// ── Typing Indicator ───────────────────────────────────────────────────────────

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 6, bottom: 6, right: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.deepBlue,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final delay = i * 0.25;
                final opacity =
                    ((_controller.value - delay).clamp(0.0, 1.0) * 2)
                        .clamp(0.0, 1.0);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Opacity(
                    opacity: opacity < 0.3 ? 0.3 : opacity,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.lightText,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

// ── Answer Buttons ─────────────────────────────────────────────────────────────

const _questions = [
  ['Hello', 'Goodbye', 'Thank you', 'Please'],
  [
    'Where is the bathroom?',
    'What time is it?',
    'How much does it cost?',
    'Can I have the menu?'
  ],
  ['Conocimiento', 'Habilidad', 'Sabiduría', 'Experiencia'],
];

class _AnswerButtons extends StatelessWidget {
  const _AnswerButtons({
    required this.questionIndex,
    required this.isSenior,
    required this.onSelect,
  });

  final int questionIndex;
  final bool isSenior;
  final void Function(int) onSelect;

  @override
  Widget build(BuildContext context) {
    if (questionIndex >= _questions.length) return const SizedBox.shrink();
    final options = _questions[questionIndex];
    final buttonHeight = isSenior ? 60.0 : 52.0;
    final textSize =
        isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: options.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              height: buttonHeight,
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => onSelect(entry.key),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: AppColors.deepBlue,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  foregroundColor: AppColors.deepBlue,
                ),
                child: Text(
                  entry.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: textSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Completion Button ──────────────────────────────────────────────────────────

class _CompletionButton extends StatelessWidget {
  const _CompletionButton({required this.isSenior, required this.onTap});

  final bool isSenior;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final buttonHeight = isSenior ? 72.0 : 60.0;
    final textSize =
        isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: SizedBox(
        height: buttonHeight,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.terracotta,
            foregroundColor: AppColors.lightText,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
          ),
          child: Text(
            '${AppStrings.placementGoToDashboardEs}  •  ${AppStrings.placementGoToDashboardEn}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: textSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
