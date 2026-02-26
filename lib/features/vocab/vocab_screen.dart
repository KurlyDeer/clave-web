import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/vocab_word_model.dart';
import '../../core/providers/persona_provider.dart';
import '../../core/providers/tts_provider.dart';
import '../../core/providers/vocab_provider.dart';
import '../../core/services/tts_service.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_strings.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class VocabScreen extends ConsumerStatefulWidget {
  const VocabScreen({super.key});

  @override
  ConsumerState<VocabScreen> createState() => _VocabScreenState();
}

class _VocabScreenState extends ConsumerState<VocabScreen> {
  // Local session queue — built once in initState; not re-built on provider changes.
  late List<VocabWord> _studyQueue;
  int _currentIndex = 0;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _buildQueue();
  }

  void _buildQueue() {
    final words = ref.read(vocabProvider);
    _studyQueue = words.where((w) => !w.isKnown).toList();
    _currentIndex = 0;
    _isFlipped = false;
  }

  VocabWord? get _currentWord =>
      _studyQueue.isEmpty ? null : _studyQueue[_currentIndex];

  void _onFlipped() => setState(() => _isFlipped = true);

  Future<void> _markKnown() async {
    final word = _currentWord;
    if (word == null) return;
    await ref.read(vocabProvider.notifier).markKnown(word.id);
    setState(() {
      _studyQueue.removeAt(_currentIndex);
      _isFlipped = false;
      if (_studyQueue.isNotEmpty && _currentIndex >= _studyQueue.length) {
        _currentIndex = 0;
      }
    });
  }

  void _markRepeat() {
    final word = _currentWord;
    if (word == null) return;
    setState(() {
      _studyQueue.removeAt(_currentIndex);
      _studyQueue.add(word); // put at end of session queue
      _isFlipped = false;
      if (_currentIndex >= _studyQueue.length) {
        _currentIndex = 0;
      }
    });
  }

  Future<void> _resetAll() async {
    await ref.read(vocabProvider.notifier).resetAll();
    setState(_buildQueue);
  }

  @override
  Widget build(BuildContext context) {
    final persona = ref.watch(personaProvider);
    final isSenior = persona?.isSeniorMode ?? false;
    final allWords = ref.watch(vocabProvider);
    final stats = ref.watch(vocabStatsProvider);
    final tts = ref.read(ttsServiceProvider);

    Widget body;
    if (allWords.isEmpty) {
      body = _EmptyState(isSenior: isSenior);
    } else if (_studyQueue.isEmpty) {
      body = _CelebrationState(
        stats: stats,
        isSenior: isSenior,
        onReset: _resetAll,
      );
    } else {
      body = _StudyView(
        word: _studyQueue[_currentIndex],
        queueRemaining: _studyQueue.length,
        stats: stats,
        isSenior: isSenior,
        isFlipped: _isFlipped,
        tts: tts,
        onFlipped: _onFlipped,
        onKnow: _markKnown,
        onRepeat: _markRepeat,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.deepBlue,
        foregroundColor: Colors.white,
        title: Text(
          '${AppStrings.vocabTitleEs}  •  ${AppStrings.vocabTitleEn}',
          style: TextStyle(
            fontSize: isSenior ? AppFontSizes.subtitle : AppFontSizes.body,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: body,
    );
  }
}

// ── Study view ────────────────────────────────────────────────────────────────

class _StudyView extends StatelessWidget {
  const _StudyView({
    required this.word,
    required this.queueRemaining,
    required this.stats,
    required this.isSenior,
    required this.isFlipped,
    required this.tts,
    required this.onFlipped,
    required this.onKnow,
    required this.onRepeat,
  });

  final VocabWord word;
  final int queueRemaining;
  final ({int known, int total}) stats;
  final bool isSenior;
  final bool isFlipped;
  final TtsService tts;
  final VoidCallback onFlipped;
  final VoidCallback onKnow;
  final VoidCallback onRepeat;

  @override
  Widget build(BuildContext context) {
    final smallSize = isSenior ? AppFontSizes.body : AppFontSizes.body - 2;
    final buttonHeight = isSenior ? 72.0 : 60.0;
    final btnTextSize =
        isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          // ── Progress header ──────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$queueRemaining ${AppStrings.vocabWordsToStudyEs}',
                style: TextStyle(
                  fontSize: smallSize,
                  color: AppColors.terracotta,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${stats.known} ${AppStrings.vocabOfEs} ${stats.total} ${AppStrings.vocabWordsKnownOfEs}',
                style: TextStyle(
                  fontSize: smallSize,
                  color: AppColors.darkText.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: stats.total == 0
                  ? 0
                  : stats.known / stats.total,
              minHeight: isSenior ? 8 : 6,
              backgroundColor: AppColors.terracotta.withValues(alpha: 0.15),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.terracotta),
            ),
          ),
          const SizedBox(height: 28),

          // ── Flashcard ────────────────────────────────────────────────────
          Expanded(
            child: _FlashCard(
              key: ValueKey('${word.id}-card'),
              word: word,
              isSenior: isSenior,
              tts: tts,
              onFlipped: onFlipped,
            ),
          ),

          const SizedBox(height: 20),

          // ── Hint (only before flip) ───────────────────────────────────────
          AnimatedOpacity(
            opacity: isFlipped ? 0 : 1,
            duration: const Duration(milliseconds: 250),
            child: Text(
              AppStrings.vocabTapToFlipEs,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: smallSize,
                color: AppColors.darkText.withValues(alpha: 0.4),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Action buttons (visible after flip) ──────────────────────────
          AnimatedOpacity(
            opacity: isFlipped ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            child: IgnorePointer(
              ignoring: !isFlipped,
              child: Row(
                children: [
                  // Repeat
                  Expanded(
                    child: SizedBox(
                      height: buttonHeight,
                      child: OutlinedButton(
                        onPressed: onRepeat,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: AppColors.terracotta, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          AppStrings.vocabRepeatEs,
                          style: TextStyle(
                            fontSize: btnTextSize,
                            color: AppColors.terracotta,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Know it
                  Expanded(
                    child: SizedBox(
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: onKnow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF27AE60),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          AppStrings.vocabKnowItEs,
                          style: TextStyle(
                            fontSize: btnTextSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Flashcard widget with flip animation ──────────────────────────────────────

class _FlashCard extends StatefulWidget {
  const _FlashCard({
    required super.key,
    required this.word,
    required this.isSenior,
    required this.tts,
    required this.onFlipped,
  });

  final VocabWord word;
  final bool isSenior;
  final TtsService tts;
  final VoidCallback onFlipped;

  @override
  State<_FlashCard> createState() => _FlashCardState();
}

class _FlashCardState extends State<_FlashCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (_showBack) return; // already flipped — don't flip back during session
    _ctrl.forward();
    setState(() => _showBack = true);
    widget.onFlipped();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final angle = _ctrl.value * pi;
          final showFront = angle <= pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(showFront ? angle : angle - pi),
            child: showFront
                ? _CardFace.front(
                    word: widget.word,
                    isSenior: widget.isSenior,
                  )
                : _CardFace.back(
                    word: widget.word,
                    isSenior: widget.isSenior,
                    tts: widget.tts,
                  ),
          );
        },
      ),
    );
  }
}

// ── Card faces ────────────────────────────────────────────────────────────────

class _CardFace extends StatelessWidget {
  const _CardFace._({
    required this.isFront,
    required this.word,
    required this.isSenior,
    this.tts,
  });

  factory _CardFace.front({
    required VocabWord word,
    required bool isSenior,
  }) =>
      _CardFace._(isFront: true, word: word, isSenior: isSenior);

  factory _CardFace.back({
    required VocabWord word,
    required bool isSenior,
    required TtsService tts,
  }) =>
      _CardFace._(isFront: false, word: word, isSenior: isSenior, tts: tts);

  final bool isFront;
  final VocabWord word;
  final bool isSenior;
  final TtsService? tts;

  // Abuelo: high-contrast terracotta back; default: deepBlue back.
  Color get _backColor =>
      isSenior ? AppColors.terracotta : AppColors.deepBlue;

  double get _wordSize {
    if (isSenior) return 32.0; // per spec: Abuelo 32pt bold
    return AppFontSizes.title;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
      decoration: BoxDecoration(
        color: isFront ? Colors.white : _backColor,
        borderRadius: BorderRadius.circular(24),
        border: isFront
            ? Border.all(
                color: AppColors.deepBlue.withValues(alpha: 0.18), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: (isFront ? AppColors.deepBlue : _backColor)
                .withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: isFront ? _frontChildren() : _backChildren(),
      ),
    );
  }

  List<Widget> _frontChildren() {
    final labelColor = AppColors.deepBlue;
    final wordColor =
        isSenior ? AppColors.darkText : AppColors.darkText;

    return [
      // Source badge
      _SourceBadge(source: word.source, isSenior: isSenior),
      const SizedBox(height: 16),
      // INGLÉS label
      Text(
        AppStrings.vocabFrontLabelEs,
        style: TextStyle(
          fontSize: 11,
          letterSpacing: 2,
          fontWeight: FontWeight.w800,
          color: labelColor.withValues(alpha: 0.6),
        ),
      ),
      const SizedBox(height: 20),
      // English word — large
      Text(
        word.wordEn,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: _wordSize,
          fontWeight: FontWeight.w800,
          color: wordColor,
          height: 1.3,
        ),
      ),
    ];
  }

  List<Widget> _backChildren() {
    return [
      // ESPAÑOL label
      Text(
        AppStrings.vocabBackLabelEs,
        style: const TextStyle(
          fontSize: 11,
          letterSpacing: 2,
          fontWeight: FontWeight.w800,
          color: Colors.white70,
        ),
      ),
      const SizedBox(height: 20),
      // Spanish translation — large
      Text(
        word.wordEs,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: _wordSize,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          height: 1.3,
        ),
      ),
      const SizedBox(height: 28),
      // Audio button
      ElevatedButton.icon(
        onPressed: () => tts?.speak(word.wordEs),
        icon: const Icon(Icons.volume_up_rounded, size: 20),
        label: Text(
          AppStrings.vocabSpeakEs,
          style: TextStyle(
            fontSize: isSenior ? AppFontSizes.body : 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: _backColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isSenior ? 28 : 20,
            vertical: isSenior ? 16 : 10,
          ),
        ),
      ),
    ];
  }
}

// ── Source badge ──────────────────────────────────────────────────────────────

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.source, required this.isSenior});

  final String source;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final isSos = source == 'sos';
    final label = isSos
        ? AppStrings.vocabSourceSosEs
        : AppStrings.vocabSourceLibroEs;
    final bg = isSos
        ? AppColors.terracotta.withValues(alpha: 0.12)
        : AppColors.deepBlue.withValues(alpha: 0.10);
    final fg = isSos ? AppColors.terracotta : AppColors.deepBlue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: isSenior ? 14 : 11,
          fontWeight: FontWeight.w700,
          color: fg,
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
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📚', style: TextStyle(fontSize: 72)),
          const SizedBox(height: 24),
          Text(
            AppStrings.vocabEmptyStateEs,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: bodySize,
              color: AppColors.darkText,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Celebration state ─────────────────────────────────────────────────────────

class _CelebrationState extends StatelessWidget {
  const _CelebrationState({
    required this.stats,
    required this.isSenior,
    required this.onReset,
  });

  final ({int known, int total}) stats;
  final bool isSenior;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final headlineSize =
        isSenior ? AppFontSizes.headlineLarge : AppFontSizes.headline;
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
    final buttonHeight = isSenior ? 72.0 : 60.0;
    final btnTextSize =
        isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 24),
          Text(
            AppStrings.vocabCelebrationTitleEs,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: headlineSize,
              fontWeight: FontWeight.w800,
              color: AppColors.terracotta,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.vocabCelebrationBodyEs,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: bodySize,
              color: AppColors.darkText,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${stats.known} ${AppStrings.vocabOfEs} ${stats.total} ${AppStrings.vocabWordsKnownOfEs}',
            style: TextStyle(
              fontSize: bodySize,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF27AE60),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: buttonHeight,
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onReset,
              style: OutlinedButton.styleFrom(
                side:
                    const BorderSide(color: AppColors.deepBlue, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                AppStrings.vocabReviewAllEs,
                style: TextStyle(
                  fontSize: btnTextSize,
                  color: AppColors.deepBlue,
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
