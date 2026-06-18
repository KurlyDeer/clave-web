import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/vocab_word_model.dart';
import '../../core/providers/persona_provider.dart';
import '../../core/providers/repaso_provider.dart';
import '../../core/providers/audio_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_container.dart';
import '../../l10n/app_strings.dart';

class RepasoScreen extends ConsumerWidget {
  const RepasoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(repasoProvider);
    final persona = ref.watch(personaProvider);
    final isSenior = persona?.isSeniorMode ?? false;

    return Scaffold(
      backgroundColor: AppColors.glassGradientStart,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.glassGradientStart,
              AppColors.glassGradientMid,
              AppColors.glassGradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _RepasoHeader(state: state, isSenior: isSenior),
              if (state.words.isEmpty)
                Expanded(child: _EmptyState(isSenior: isSenior))
              else if (state.isComplete)
                Expanded(
                    child: _CompletionState(state: state, isSenior: isSenior))
              else
                Expanded(
                  child: Column(
                    children: [
                      // ── Single flashcard ──────────────────────────────────
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            transitionBuilder: (child, animation) {
                              final isIncoming =
                                  (child.key as ValueKey<int>?)?.value ==
                                      state.currentIndex;
                              final offsetTween = isIncoming
                                  ? Tween<Offset>(
                                      begin: const Offset(1, 0),
                                      end: Offset.zero)
                                  : Tween<Offset>(
                                      begin: const Offset(-1, 0),
                                      end: Offset.zero);
                              return SlideTransition(
                                position: offsetTween.animate(animation),
                                child: FadeTransition(
                                    opacity: animation, child: child),
                              );
                            },
                            child: _FlashcardWidget(
                              key: ValueKey(state.currentIndex),
                              word: state.words[state.currentIndex],
                              isSenior: isSenior,
                            ),
                          ),
                        ),
                      ),
                      // ── Action buttons (fade in when flipped) ─────────────
                      IgnorePointer(
                        ignoring: !state.isCurrentFlipped,
                        child: AnimatedOpacity(
                          opacity: state.isCurrentFlipped ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(24, 0, 24, 20),
                            child: _ActionButtons(isSenior: isSenior),
                          ),
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

// ── Header ────────────────────────────────────────────────────────────────────

class _RepasoHeader extends StatelessWidget {
  const _RepasoHeader({required this.state, required this.isSenior});

  final RepasoState state;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final titleSize =
        isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle;
    final total = state.words.length;
    final current = (state.currentIndex + 1).clamp(1, total);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new,
                color: AppColors.glassText),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  AppStrings.repasoTitleEs,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                    color: AppColors.glassText,
                  ),
                ),
                if (total > 0 && !state.isComplete) ...[
                  const SizedBox(height: 4),
                  Text(
                    '$current ${AppStrings.repasoWordsOfEs} $total',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.glassTextMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

// ── Flashcard widget (single card with 3D flip) ───────────────────────────────

class _FlashcardWidget extends ConsumerStatefulWidget {
  const _FlashcardWidget({
    required super.key,
    required this.word,
    required this.isSenior,
  });

  final VocabWord word;
  final bool isSenior;

  @override
  ConsumerState<_FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends ConsumerState<_FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flipCtrl;

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<RepasoState>(repasoProvider, (prev, next) {
      if (next.isCurrentFlipped && (prev == null || !prev.isCurrentFlipped)) {
        _flipCtrl.forward();
      }
    });

    final isFlipped = ref.watch(repasoProvider).isCurrentFlipped;
    void onSpeak() => ref.read(audioServiceProvider).speak(widget.word.wordEs);

    return GestureDetector(
      onTap: isFlipped
          ? null
          : () => ref.read(repasoProvider.notifier).flipCurrentCard(),
      child: AnimatedBuilder(
        animation: _flipCtrl,
        builder: (context, _) {
          final angle = _flipCtrl.value * pi;
          final showFront = angle <= pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(showFront ? angle : angle - pi),
            child: showFront
                ? _CardFront(
                    word: widget.word,
                    isSenior: widget.isSenior,
                  )
                : _CardBack(
                    word: widget.word,
                    isSenior: widget.isSenior,
                    onSpeak: onSpeak,
                  ),
          );
        },
      ),
    );
  }
}

// ── Card — Front (English) ────────────────────────────────────────────────────

class _CardFront extends StatelessWidget {
  const _CardFront({required this.word, required this.isSenior});

  final VocabWord word;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final wordSize =
        isSenior ? AppFontSizes.titleLarge : AppFontSizes.title;

    return GlassContainer(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Language label
          Text(
            AppStrings.repasoCardBackLabelEs, // 'INGLÉS'
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 2.0,
              fontWeight: FontWeight.w800,
              color: AppColors.glassTextMuted,
            ),
          ),
          // English word — centered in remaining space
          Expanded(
            child: Center(
              child: Text(
                word.wordEn,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: wordSize,
                  fontWeight: FontWeight.w800,
                  color: AppColors.glassText,
                  height: 1.3,
                ),
              ),
            ),
          ),
          // Bottom row: source badge + tap hint
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _SourceBadge(source: word.source),
              Text(
                AppStrings.repasoTapToRevealEs,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.glassTextMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Card — Back (Spanish) ─────────────────────────────────────────────────────

class _CardBack extends StatelessWidget {
  const _CardBack({
    required this.word,
    required this.isSenior,
    required this.onSpeak,
  });

  final VocabWord word;
  final bool isSenior;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    final wordSize =
        isSenior ? AppFontSizes.titleLarge : AppFontSizes.title;

    final bgColor = isSenior
        ? AppColors.glowTerracotta.withValues(alpha: 0.22)
        : AppColors.deepBlue.withValues(alpha: 0.22);
    final borderColor = isSenior
        ? AppColors.glowTerracotta.withValues(alpha: 0.55)
        : AppColors.deepBlue.withValues(alpha: 0.55);

    return GlassContainer(
      padding: const EdgeInsets.all(28),
      backgroundColor: bgColor,
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row + audio button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.repasoCardFrontLabelEs, // 'ESPAÑOL'
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w800,
                  color: AppColors.glassTextMuted,
                ),
              ),
              GestureDetector(
                onTap: onSpeak,
                child: Icon(
                  Icons.volume_up_rounded,
                  color: AppColors.glassText,
                  size: 26,
                ),
              ),
            ],
          ),
          // Spanish word — centered
          Expanded(
            child: Center(
              child: Text(
                word.wordEs,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: wordSize,
                  fontWeight: FontWeight.w800,
                  color: AppColors.glassText,
                  height: 1.3,
                ),
              ),
            ),
          ),
          // Spacing at bottom to balance the label row
          const SizedBox(height: 26),
        ],
      ),
    );
  }
}

// ── Action buttons (Lo sé / Repetir) ─────────────────────────────────────────

class _ActionButtons extends ConsumerWidget {
  const _ActionButtons({required this.isSenior});

  final bool isSenior;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final btnHeight = isSenior ? 72.0 : 60.0;
    final btnFontSize =
        isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle;

    return Row(
      children: [
        // Lo sé ✓
        Expanded(
          child: SizedBox(
            height: btnHeight,
            child: ElevatedButton(
              onPressed: () =>
                  ref.read(repasoProvider.notifier).markKnownAndAdvance(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27AE60),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                AppStrings.repasoLoSabeEs,
                style: TextStyle(
                  fontSize: btnFontSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Repetir 🔁
        Expanded(
          child: SizedBox(
            height: btnHeight,
            child: OutlinedButton(
              onPressed: () =>
                  ref.read(repasoProvider.notifier).scheduleRepeatAndAdvance(),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.glassBorder, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                foregroundColor: AppColors.glassText,
              ),
              child: Text(
                AppStrings.repasoRepasarEs,
                style: TextStyle(
                  fontSize: btnFontSize,
                  color: AppColors.glassText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Source badge ──────────────────────────────────────────────────────────────

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.source});
  final String source;

  @override
  Widget build(BuildContext context) {
    final label = source == 'sos' ? 'S.O.S.' : 'Libro';
    final color =
        source == 'sos' ? AppColors.glowTerracotta : AppColors.deepBlue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isSenior});
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: GlassContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology_outlined,
              color: AppColors.glassTextMuted,
              size: 64,
            ),
            const SizedBox(height: 20),
            Text(
              AppStrings.repasoEmptyEs,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: bodySize,
                color: AppColors.glassTextMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Completion state ──────────────────────────────────────────────────────────

class _CompletionState extends StatelessWidget {
  const _CompletionState({required this.state, required this.isSenior});

  final RepasoState state;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final titleSize = isSenior ? AppFontSizes.titleLarge : AppFontSizes.title;
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
    final btnHeight = isSenior ? 72.0 : 60.0;
    final btnFontSize =
        isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text('🎉', style: TextStyle(fontSize: 72)),
          const SizedBox(height: 20),
          GlassContainer(
            child: Column(
              children: [
                Text(
                  AppStrings.repasoCompleteTitleEs,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w800,
                    color: AppColors.glassText,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppStrings.repasoCompleteBodyEs,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: bodySize,
                    color: AppColors.glassTextMuted,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatChip(
                      icon: Icons.check_circle,
                      value: '${state.knownIds.length}',
                      label: AppStrings.repasoKnownCountEs,
                      color: const Color(0xFF27AE60),
                      isSenior: isSenior,
                    ),
                    _StatChip(
                      icon: Icons.schedule,
                      value: '${state.repeatIds.length}',
                      label: 'para mañana',
                      color: AppColors.deepBlue,
                      isSenior: isSenior,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  AppStrings.repasoXpEarnedEs,
                  style: TextStyle(
                    fontSize: bodySize,
                    color: AppColors.glowTerracotta,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: btnHeight,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.glowTerracotta,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      AppStrings.repasoBackToDashEs,
                      style: TextStyle(
                        fontSize: btnFontSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isSenior,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: isSenior ? 32 : 26),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isSenior ? AppFontSizes.titleLarge : AppFontSizes.title,
            fontWeight: FontWeight.w800,
            color: AppColors.glassText,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: isSenior ? AppFontSizes.body : 13,
            color: AppColors.glassTextMuted,
          ),
        ),
      ],
    );
  }
}
