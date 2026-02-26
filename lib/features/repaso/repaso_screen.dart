import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/vocab_word_model.dart';
import '../../core/providers/persona_provider.dart';
import '../../core/providers/repaso_provider.dart';
import '../../core/providers/tts_provider.dart';
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
        decoration: const BoxDecoration(
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
                Expanded(child: _CompletionState(state: state, isSenior: isSenior))
              else
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.62,
                    ),
                    itemCount: state.words.length,
                    itemBuilder: (context, index) {
                      final word = state.words[index];
                      return _VocabTile(
                        key: ValueKey(word.id),
                        word: word,
                        isFlipped: state.flippedIds.contains(word.id),
                        isKnown: state.knownIds.contains(word.id),
                        isRepeating: state.repeatIds.contains(word.id),
                        isSenior: isSenior,
                        onTap: () =>
                            ref.read(repasoProvider.notifier).flipCard(word.id),
                        onKnown: () =>
                            ref.read(repasoProvider.notifier).markKnown(word.id),
                        onRepeat: () =>
                            ref.read(repasoProvider.notifier).scheduleRepeat(word.id),
                        onSpeak: () =>
                            ref.read(ttsServiceProvider).speak(word.wordEn),
                      );
                    },
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
    final acted = state.knownIds.length + state.repeatIds.length;
    final total = state.words.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
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
                    '$acted ${AppStrings.repasoWordsOfEs} $total',
                    style: const TextStyle(
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

// ── Vocab Tile with 3D flip ───────────────────────────────────────────────────

class _VocabTile extends StatefulWidget {
  const _VocabTile({
    required super.key,
    required this.word,
    required this.isFlipped,
    required this.isKnown,
    required this.isRepeating,
    required this.isSenior,
    required this.onTap,
    required this.onKnown,
    required this.onRepeat,
    required this.onSpeak,
  });

  final VocabWord word;
  final bool isFlipped;
  final bool isKnown;
  final bool isRepeating;
  final bool isSenior;
  final VoidCallback onTap;
  final VoidCallback onKnown;
  final VoidCallback onRepeat;
  final VoidCallback onSpeak;

  @override
  State<_VocabTile> createState() => _VocabTileState();
}

class _VocabTileState extends State<_VocabTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
  }

  @override
  void didUpdateWidget(_VocabTile old) {
    super.didUpdateWidget(old);
    if (widget.isFlipped && !old.isFlipped) {
      _ctrl.forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Acted tiles: show a static overlay instead of animated card.
    if (widget.isKnown || widget.isRepeating) {
      return _ActedTile(
        word: widget.word,
        isKnown: widget.isKnown,
        isSenior: widget.isSenior,
      );
    }

    return GestureDetector(
      onTap: widget.isFlipped ? null : widget.onTap,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          final angle = _ctrl.value * pi;
          final showFront = angle <= pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(showFront ? angle : angle - pi),
            child: showFront
                ? _TileFront(word: widget.word, isSenior: widget.isSenior)
                : _TileBack(
                    word: widget.word,
                    isSenior: widget.isSenior,
                    onKnown: widget.onKnown,
                    onRepeat: widget.onRepeat,
                    onSpeak: widget.onSpeak,
                  ),
          );
        },
      ),
    );
  }
}

// ── Tile — Front (Spanish word) ───────────────────────────────────────────────

class _TileFront extends StatelessWidget {
  const _TileFront({required this.word, required this.isSenior});

  final VocabWord word;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final wordSize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;

    return GlassContainer(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            AppStrings.repasoCardFrontLabelEs,
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: 1.8,
              fontWeight: FontWeight.w800,
              color: AppColors.glassTextMuted,
            ),
          ),
          const SizedBox(height: 10),
          // Spanish word — fills available space
          Expanded(
            child: Center(
              child: Text(
                word.wordEs,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: wordSize,
                  fontWeight: FontWeight.w700,
                  color: AppColors.glassText,
                  height: 1.35,
                ),
              ),
            ),
          ),
          // Source badge
          Align(
            alignment: Alignment.bottomRight,
            child: _SourceBadge(source: word.source),
          ),
          const SizedBox(height: 4),
          // Tap hint
          Center(
            child: Text(
              AppStrings.repasoTapToRevealEs,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.glassTextMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tile — Back (English + actions) ──────────────────────────────────────────

class _TileBack extends StatelessWidget {
  const _TileBack({
    required this.word,
    required this.isSenior,
    required this.onKnown,
    required this.onRepeat,
    required this.onSpeak,
  });

  final VocabWord word;
  final bool isSenior;
  final VoidCallback onKnown;
  final VoidCallback onRepeat;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    final wordSize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
    final btnHeight = isSenior ? 52.0 : 44.0;
    final btnFontSize = isSenior ? AppFontSizes.body : 15.0;

    // Back card: terracotta tint for Abuelo, deep-blue tint otherwise.
    final bgColor = isSenior
        ? AppColors.glowTerracotta.withValues(alpha: 0.25)
        : AppColors.deepBlue.withValues(alpha: 0.25);
    final borderColor = isSenior
        ? AppColors.glowTerracotta.withValues(alpha: 0.6)
        : AppColors.deepBlue.withValues(alpha: 0.6);

    return GlassContainer(
      padding: const EdgeInsets.all(12),
      backgroundColor: bgColor,
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Label row + audio
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.repasoCardBackLabelEs,
                style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w800,
                  color: AppColors.glassTextMuted,
                ),
              ),
              GestureDetector(
                onTap: onSpeak,
                child: const Icon(
                  Icons.volume_up,
                  color: AppColors.glassText,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // English translation
          Expanded(
            child: Center(
              child: Text(
                word.wordEn,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: wordSize,
                  fontWeight: FontWeight.w700,
                  color: AppColors.glassText,
                  height: 1.35,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Lo sé button
          SizedBox(
            height: btnHeight,
            child: ElevatedButton(
              onPressed: onKnown,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27AE60),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                padding: EdgeInsets.zero,
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
          const SizedBox(height: 6),
          // Repasar button
          SizedBox(
            height: btnHeight,
            child: OutlinedButton(
              onPressed: onRepeat,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.glassBorder, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.zero,
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
        ],
      ),
    );
  }
}

// ── Acted tile (after Lo sé or Repasar) ──────────────────────────────────────

class _ActedTile extends StatelessWidget {
  const _ActedTile({
    required this.word,
    required this.isKnown,
    required this.isSenior,
  });

  final VocabWord word;
  final bool isKnown;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final label =
        isKnown ? AppStrings.repasoLearnedEs : AppStrings.repasoScheduledEs;
    final icon = isKnown ? Icons.check_circle : Icons.schedule;
    final color = isKnown
        ? const Color(0xFF27AE60)
        : AppColors.deepBlue;

    return GlassContainer(
      backgroundColor: color.withValues(alpha: 0.15),
      borderColor: color.withValues(alpha: 0.4),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSenior ? AppFontSizes.body : 14.0,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            word.wordEs,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isSenior ? 14.0 : 12.0,
              color: AppColors.glassTextMuted,
            ),
          ),
        ],
      ),
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
    final color = source == 'sos'
        ? AppColors.glowTerracotta
        : AppColors.deepBlue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
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
            const Icon(
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
                // Stats row
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
