import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/book_page_model.dart';
import '../../core/models/lesson_models.dart';
import '../../core/providers/book_pages_provider.dart';
import '../../core/providers/lesson_progress_provider.dart';
import '../../core/providers/persona_provider.dart';
import '../../core/providers/gamification_controller.dart';
import '../../core/providers/audio_provider.dart';
import '../../core/services/audio_service.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_strings.dart';
import 'widgets/glass_card.dart';

// ── Shell ──────────────────────────────────────────────────────────────────────

class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({super.key, required this.lesson});

  final LessonData lesson;

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  // Total steps in the new lesson flow:
  // 0 Hook · 1 Vocab · 2 Grammar · 3 Voice · 4 Summary
  static const int _totalPages = 5;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    if (page < 0 || page >= _totalPages) return;
    setState(() => _currentPage = page);
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final persona = ref.watch(personaProvider);
    final isSenior = persona?.isSeniorMode ?? false;
    final personaKey = persona?.name ?? 'adulto';
    final content = widget.lesson.forPersona(personaKey);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const _GradientBackground(),
          SafeArea(
            child: Column(
              children: [
                _TopBar(
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                  onBack: () {
                    if (_currentPage > 0) {
                      _goToPage(_currentPage - 1);
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // ── Screen 1: Hook ──────────────────────────────────
                      _HookPage(
                        content: content,
                        isSenior: isSenior,
                        onStart: () => _goToPage(1),
                      ),

                      // ── Screen 2: Vocabulary ────────────────────────────
                      if (content.slides.isNotEmpty)
                        _VocabPage(
                          slide: content.slides[0],
                          isSenior: isSenior,
                          tts: ref.read(audioServiceProvider),
                          onNext: () => _goToPage(2),
                        )
                      else
                        const _PlaceholderPage(label: 'Vocabulario'),

                      // ── Screen 3: Grammar Flip ──────────────────────────
                      _GrammarPage(
                        isSenior: isSenior,
                        onNext: () => _goToPage(3),
                      ),

                      // ── Screen 4: Voice Challenge ───────────────────────
                      _VoiceChallengePage(
                        isSenior: isSenior,
                        onFinish: () => _goToPage(4),
                      ),

                      // ── Screen 5: El Borrador ───────────────────────────
                      _DraftPage(
                        isSenior: isSenior,
                        lessonId: widget.lesson.id,
                      ),
                    ],
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

// ── Gradient Background ────────────────────────────────────────────────────────

class _GradientBackground extends StatelessWidget {
  const _GradientBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.glassGradientStart, // 0xFF0D1B3E deep navy
            AppColors.glassGradientMid,   // 0xFF1A1045 deep indigo
            AppColors.glassGradientEnd,   // 0xFF2D1B69 deep purple
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

// ── Top Bar ────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.currentPage,
    required this.totalPages,
    required this.onBack,
  });

  final int currentPage;
  final int totalPages;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Glass back / up button
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0x26FFFFFF),
                    border: Border.all(color: const Color(0x40FFFFFF)),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${AppStrings.lessonStepEs} ${currentPage + 1} '
                '${AppStrings.lessonSlideOfEs} $totalPages',
                style: TextStyle(
                  color: AppColors.glassTextMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _LiquidProgressBar(currentPage: currentPage, totalPages: totalPages),
        ],
      ),
    );
  }
}

// ── Liquid Progress Bar ────────────────────────────────────────────────────────

class _LiquidProgressBar extends StatelessWidget {
  const _LiquidProgressBar({
    required this.currentPage,
    required this.totalPages,
  });

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalPages, (i) {
        final isActive = i <= currentPage;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < totalPages - 1 ? 6 : 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: isActive
                    ? AppColors.glowTerracotta
                    : const Color(0x33FFFFFF),
                boxShadow: [
                  BoxShadow(
                    color: isActive
                        ? AppColors.glowTerracotta.withValues(alpha: 0.55)
                        : Colors.transparent,
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Screen 1 · Hook ────────────────────────────────────────────────────────────

class _HookPage extends StatelessWidget {
  const _HookPage({
    required this.content,
    required this.isSenior,
    required this.onStart,
  });

  final PersonaContent content;
  final bool isSenior;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final titleSize = isSenior ? AppFontSizes.titleLarge : AppFontSizes.title;
    final bodySize  = isSenior ? AppFontSizes.bodyLarge  : AppFontSizes.body;
    final btnHeight = isSenior ? 72.0 : 60.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 32),

          // Accent orb
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0x26FFFFFF),
              border: Border.all(color: const Color(0x40FFFFFF)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.glowTerracotta.withValues(alpha: 0.30),
                  blurRadius: 32,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Icon(
              Icons.lightbulb_outline_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),

          // Lesson title
          Text(
            content.titleEs,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w800,
              color: AppColors.glassText,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content.titleEn,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: bodySize - 2,
              color: AppColors.glassTextMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 32),

          // Scenario GlassCard
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🎯', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.lessonHookLabelEs,
                      style: TextStyle(
                        fontSize: bodySize - 2,
                        color: AppColors.glassTextMuted,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  content.topicEs,
                  style: TextStyle(
                    fontSize: bodySize,
                    color: AppColors.glassText,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Glowing Empezar button
          _GlowButton(
            label: AppStrings.lessonStartEs,
            height: btnHeight,
            fontSize: bodySize,
            onPressed: onStart,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Screen 2 · Vocabulary ──────────────────────────────────────────────────────

class _VocabPage extends StatefulWidget {
  const _VocabPage({
    required this.slide,
    required this.isSenior,
    required this.tts,
    required this.onNext,
  });

  final LessonSlide slide;
  final bool isSenior;
  final AudioService tts;
  final VoidCallback onNext;

  @override
  State<_VocabPage> createState() => _VocabPageState();
}

class _VocabPageState extends State<_VocabPage> {
  @override
  Widget build(BuildContext context) {
    final slide    = widget.slide;
    final isSenior = widget.isSenior;
    final onNext   = widget.onNext;
    final wordSize    = isSenior ? 84.0 : 72.0;
    final spanishSize = isSenior ? AppFontSizes.titleLarge : AppFontSizes.title;
    final labelSize   = isSenior ? 15.0 : 13.0;
    final bodySize    = isSenior ? AppFontSizes.bodyLarge  : AppFontSizes.body;
    final btnHeight   = isSenior ? 72.0 : 60.0;
    final audioSize   = isSenior ? 72.0 : 60.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(),

          // Split GlassCard
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                // ── Top half · English ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                  child: Column(
                    children: [
                      Text(
                        AppStrings.vocabFrontLabelEs, // 'INGLÉS'
                        style: TextStyle(
                          fontSize: labelSize,
                          letterSpacing: 2.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.glassTextMuted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        slide.contentEn,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: wordSize,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.1,
                          shadows: [
                            Shadow(
                              color:
                                  AppColors.glowTerracotta.withValues(alpha: 0.45),
                              blurRadius: 28,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Divider ─────────────────────────────────────────────
                Container(height: 1, color: const Color(0x40FFFFFF)),

                // ── Bottom half · Spanish ────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                  child: Column(
                    children: [
                      Text(
                        AppStrings.vocabBackLabelEs, // 'ESPAÑOL'
                        style: TextStyle(
                          fontSize: labelSize,
                          letterSpacing: 2.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.glassTextMuted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        slide.contentEs,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: spanishSize,
                          fontWeight: FontWeight.w700,
                          color: AppColors.glassText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Placeholder audio button
          GestureDetector(
            onTap: () => widget.tts.speak(widget.slide.contentEn),
            child: Container(
              width: audioSize,
              height: audioSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0x26FFFFFF),
                border: Border.all(
                  color: const Color(0x59FFFFFF),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.deepBlue.withValues(alpha: 0.40),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: isSenior ? 36 : 30,
              ),
            ),
          ),

          const Spacer(),

          // Siguiente button
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: _GlowButton(
              label: AppStrings.lessonNextEs,
              height: btnHeight,
              fontSize: bodySize,
              onPressed: onNext,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Screen 3 · Grammar Flip ────────────────────────────────────────────────────

class _GrammarPage extends StatefulWidget {
  const _GrammarPage({required this.isSenior, required this.onNext});

  final bool isSenior;
  final VoidCallback onNext;

  @override
  State<_GrammarPage> createState() => _GrammarPageState();
}

class _GrammarPageState extends State<_GrammarPage> {
  // Hardcoded for now; will be driven by LessonData in a future task
  static const String _targetSpanish = 'La casa blanca';
  static const List<String> _correctOrder = ['White', 'House'];

  late List<String> _chips;
  final List<String> _answer = [];
  bool? _isCorrect; // null = unchecked

  @override
  void initState() {
    super.initState();
    _chips = List.from(_correctOrder)..shuffle();
  }

  void _onChipTap(String word) {
    setState(() {
      _isCorrect = null;
      _chips.remove(word);
      _answer.add(word);
    });
  }

  void _onAnswerWordTap(String word) {
    setState(() {
      _isCorrect = null;
      _answer.remove(word);
      _chips.add(word);
    });
  }

  void _check() {
    final correct = _answer.length == _correctOrder.length &&
        List.generate(_answer.length, (i) => _answer[i] == _correctOrder[i])
            .every((ok) => ok);
    setState(() => _isCorrect = correct);
  }

  @override
  Widget build(BuildContext context) {
    final bodySize  = widget.isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
    final chipSize  = widget.isSenior ? 22.0 : 18.0;
    final btnHeight = widget.isSenior ? 72.0 : 60.0;
    final canCheck  = _answer.isNotEmpty && _isCorrect == null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),

          // Section title
          Text(
            AppStrings.lessonGrammarTitleEs,
            style: TextStyle(
              fontSize: bodySize - 2,
              fontWeight: FontWeight.w700,
              color: AppColors.glassTextMuted,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),

          // Target Spanish sentence
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.lessonGrammarSpanishLabelEs,
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.glassTextMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _targetSpanish,
                  style: TextStyle(
                    fontSize: widget.isSenior ? 32.0 : 28.0,
                    fontWeight: FontWeight.w800,
                    color: AppColors.glassText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Answer drop zone
          _AnswerArea(
            words: _answer,
            isCorrect: _isCorrect,
            isSenior: widget.isSenior,
            onWordTap: _onAnswerWordTap,
          ),
          const SizedBox(height: 12),

          // Feedback banner (animates in/out)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isCorrect == null
                ? const SizedBox.shrink(key: ValueKey('none'))
                : _FeedbackBanner(
                    key: ValueKey(_isCorrect),
                    message: _isCorrect!
                        ? AppStrings.lessonGrammarCorrectFeedbackEs
                        : AppStrings.lessonGrammarWrongHintEs,
                    isCorrect: _isCorrect!,
                    isSenior: widget.isSenior,
                  ),
          ),
          const SizedBox(height: 20),

          // Word chip pool
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _chips
                .map(
                  (word) => _WordChip(
                    word: word,
                    fontSize: chipSize,
                    isSenior: widget.isSenior,
                    onTap: () => _onChipTap(word),
                  ),
                )
                .toList(),
          ),

          const Spacer(),

          // Action button: Comprobar → Siguiente
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: _isCorrect == true
                ? _GlowButton(
                    label: AppStrings.lessonGrammarNextEs,
                    height: btnHeight,
                    fontSize: bodySize,
                    onPressed: widget.onNext,
                  )
                : _GlowButton(
                    label: AppStrings.lessonGrammarCheckEs,
                    height: btnHeight,
                    fontSize: bodySize,
                    onPressed: canCheck ? _check : null,
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Answer Drop Zone ───────────────────────────────────────────────────────────

class _AnswerArea extends StatelessWidget {
  const _AnswerArea({
    required this.words,
    required this.isCorrect,
    required this.isSenior,
    required this.onWordTap,
  });

  final List<String> words;
  final bool? isCorrect;
  final bool isSenior;
  final void Function(String) onWordTap;

  @override
  Widget build(BuildContext context) {
    final Color borderColor;
    final Color glowColor;

    if (isCorrect == true) {
      borderColor = const Color(0xFF27AE60);
      glowColor   = const Color(0xFF27AE60);
    } else if (isCorrect == false) {
      borderColor = AppColors.glowTerracotta;
      glowColor   = AppColors.glowTerracotta;
    } else {
      borderColor = const Color(0x59FFFFFF);
      glowColor   = Colors.transparent;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 72),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0x1AFFFFFF),
        border: Border.all(color: borderColor, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.30),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: words.isEmpty
          ? Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppStrings.lessonGrammarAnswerHintEs,
                style: TextStyle(
                  fontSize: isSenior ? 16.0 : 14.0,
                  color: AppColors.glassTextMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: words
                  .map(
                    (w) => _WordChip(
                      word: w,
                      fontSize: isSenior ? 22.0 : 18.0,
                      isSenior: isSenior,
                      onTap: () => onWordTap(w),
                      isInAnswer: true,
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

// ── Word Chip ──────────────────────────────────────────────────────────────────

class _WordChip extends StatelessWidget {
  const _WordChip({
    required this.word,
    required this.fontSize,
    required this.isSenior,
    required this.onTap,
    this.isInAnswer = false,
  });

  final String word;
  final double fontSize;
  final bool isSenior;
  final VoidCallback onTap;
  final bool isInAnswer;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSenior ? 20.0 : 16.0,
          vertical: isSenior ? 14.0 : 12.0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isInAnswer
              ? AppColors.deepBlue.withValues(alpha: 0.45)
              : const Color(0x40FFFFFF),
          border: Border.all(
            color: isInAnswer
                ? AppColors.deepBlue.withValues(alpha: 0.80)
                : const Color(0x66FFFFFF),
            width: 1.2,
          ),
        ),
        child: Text(
          word,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ── Feedback Banner ────────────────────────────────────────────────────────────

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({
    super.key,
    required this.message,
    required this.isCorrect,
    required this.isSenior,
  });

  final String message;
  final bool isCorrect;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final color =
        isCorrect ? const Color(0xFF27AE60) : AppColors.glowTerracotta;
    final textColor =
        isCorrect ? const Color(0xFF2ECC71) : AppColors.glowTerracotta;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.55), width: 1.2),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

// ── Screen 4 · Voice Challenge ─────────────────────────────────────────────────

class _VoiceChallengePage extends StatefulWidget {
  const _VoiceChallengePage({required this.isSenior, required this.onFinish});

  final bool isSenior;
  final VoidCallback onFinish;

  @override
  State<_VoiceChallengePage> createState() => _VoiceChallengePageState();
}

class _VoiceChallengePageState extends State<_VoiceChallengePage>
    with TickerProviderStateMixin {
  bool _micTapped = false;
  bool _isRecording = false;

  late final AnimationController _pulseCtrl;
  late final AnimationController _levelCtrl;
  late final Animation<double> _pulseAnim;
  late final Animation<double> _levelAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _levelCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _levelAnim = Tween<double>(begin: 0.05, end: 0.92).animate(
      CurvedAnimation(parent: _levelCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _levelCtrl.dispose();
    super.dispose();
  }

  void _onMicTap() {
    final wasRecording = _isRecording;
    setState(() {
      _micTapped = true;
      _isRecording = !wasRecording;
    });

    if (!wasRecording) {
      _pulseCtrl.repeat(reverse: true);
      _levelCtrl.repeat(reverse: true);
    } else {
      _pulseCtrl.stop();
      _pulseCtrl.value = 0.0;
      _levelCtrl.stop();
      _levelCtrl.value = 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bodySize  = widget.isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
    final btnHeight = widget.isSenior ? 72.0 : 60.0;
    final micSize   = widget.isSenior ? 108.0 : 92.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),

          // Section title
          Text(
            AppStrings.retoTitleEs,
            style: TextStyle(
              fontSize: bodySize - 2,
              fontWeight: FontWeight.w700,
              color: AppColors.glassTextMuted,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 20),

          // Target sentence card
          GlassCard(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              children: [
                Text(
                  AppStrings.retoInstructionEs,
                  style: TextStyle(
                    fontSize: bodySize - 2,
                    color: AppColors.glassTextMuted,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'I want a raise.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: widget.isSenior ? 30.0 : 26.0,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: AppColors.glowTerracotta.withValues(alpha: 0.50),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Mic button (centered)
          Center(
            child: ScaleTransition(
              scale: _pulseAnim,
              child: GestureDetector(
                onTap: _onMicTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: micSize,
                  height: micSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: _isRecording
                          ? [
                              AppColors.glowTerracotta.withValues(alpha: 0.90),
                              AppColors.glowTerracotta.withValues(alpha: 0.45),
                            ]
                          : [
                              const Color(0xFF3A2080),
                              const Color(0xFF1A1045),
                            ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_isRecording
                                ? AppColors.glowTerracotta
                                : AppColors.deepBlue)
                            .withValues(alpha: _isRecording ? 0.65 : 0.45),
                        blurRadius: _isRecording ? 44 : 24,
                        spreadRadius: _isRecording ? 8 : 2,
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0x59FFFFFF),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    _isRecording
                        ? Icons.mic_rounded
                        : Icons.mic_none_rounded,
                    color: Colors.white,
                    size: widget.isSenior ? 54 : 46,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Recording status label
          Center(
            child: Text(
              _isRecording
                  ? AppStrings.retoListeningEs
                  : (_micTapped
                      ? AppStrings.lessonVoiceTapRepeatEs
                      : AppStrings.lessonVoiceHoldMicEs),
              style: TextStyle(
                fontSize: bodySize - 4,
                color: _isRecording
                    ? AppColors.glowTerracotta
                    : AppColors.glassTextMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Liquid level bar
          _LevelBar(animation: _levelAnim, isSenior: widget.isSenior),

          const Spacer(),

          // Terminar button — only visible after mic tapped
          AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            opacity: _micTapped ? 1.0 : 0.0,
            child: IgnorePointer(
              ignoring: !_micTapped,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: _GlowButton(
                  label: AppStrings.lessonVoiceTerminarEs,
                  height: btnHeight,
                  fontSize: bodySize,
                  onPressed: widget.onFinish,
                ),
              ),
            ),
          ),

          if (!_micTapped) SizedBox(height: btnHeight + 32),
        ],
      ),
    );
  }
}

// ── Liquid Level Bar ───────────────────────────────────────────────────────────

class _LevelBar extends StatelessWidget {
  const _LevelBar({required this.animation, required this.isSenior});

  final Animation<double> animation;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.lessonVoiceLevelLabelEs,
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 2.5,
              fontWeight: FontWeight.w700,
              color: AppColors.glassTextMuted,
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, _) {
                  final fillWidth = constraints.maxWidth * animation.value;
                  return Stack(
                    children: [
                      // Track
                      Container(
                        height: 14,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          color: const Color(0x33FFFFFF),
                        ),
                      ),
                      // Fill
                      Container(
                        height: 14,
                        width: fillWidth.clamp(0.0, constraints.maxWidth),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.deepBlue,
                              AppColors.glowTerracotta,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.glowTerracotta.withValues(alpha: 0.55),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Screen 5 · El Borrador ────────────────────────────────────────────────────

class _DraftPage extends ConsumerStatefulWidget {
  const _DraftPage({required this.isSenior, required this.lessonId});

  final bool isSenior;
  final String lessonId;

  @override
  ConsumerState<_DraftPage> createState() => _DraftPageState();
}

class _DraftPageState extends ConsumerState<_DraftPage> {
  final _controller = TextEditingController();
  bool _saved = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    FocusScope.of(context).unfocus();
    final input = _controller.text.trim().toLowerCase();
    if (input != 'i want a raise') return;

    final now = DateTime.now().toIso8601String();
    final page = BookPage(
      id: 'lesson_${widget.lessonId}_draft',
      promptEs: AppStrings.lessonDraftTargetEs,
      promptEn: 'I want a raise.',
      text: _controller.text.trim(),
      createdAt: now,
      updatedAt: now,
    );

    await ref.read(bookPagesProvider.notifier).savePage(page);

    // Save lesson progress
    final box = ref.read(lessonProgressBoxProvider);
    await box.put(
      widget.lessonId,
      LessonProgress(
        completed: true,
        voiceScore: 0,
        feedbackEs: '',
      ),
    );
    ref.invalidate(completedLessonIdsProvider);
    ref.invalidate(completedLessonCountProvider);
    ref.invalidate(lessonProgressProvider(widget.lessonId));

    // Award XP and streak
    ref.read(gamificationProvider.notifier).addXp(10);
    ref.read(gamificationProvider.notifier).recordPractice();

    setState(() => _saved = true);
  }

  @override
  Widget build(BuildContext context) {
    final bodySize = widget.isSenior ? AppFontSizes.bodyLarge : 18.0;
    final subtitleSize = widget.isSenior ? AppFontSizes.subtitleLarge : 22.0;
    final btnHeight = widget.isSenior ? 72.0 : 60.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Instruction
          Text(
            AppStrings.lessonDraftInstructionEs,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.glassTextMuted,
              fontSize: bodySize,
            ),
          ),
          const SizedBox(height: 16),

          // Target sentence (gold/terracotta highlight)
          GlassCard(
            child: Text(
              AppStrings.lessonDraftTargetEs,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.glowTerracotta,
                fontSize: subtitleSize,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Input card with animated gold border on save
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _saved
                    ? const Color(0xFFFFD700)
                    : AppColors.glassBorder,
                width: _saved ? 2.5 : 1.5,
              ),
              boxShadow: _saved
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
              color: AppColors.glassSurface,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _controller,
              readOnly: _saved,
              onChanged: (_) => setState(() {}),
              style: TextStyle(
                color: AppColors.glassText,
                fontSize: bodySize,
              ),
              cursorColor: AppColors.glowTerracotta,
              decoration: InputDecoration(
                hintText: AppStrings.lessonDraftHintEs,
                hintStyle: TextStyle(
                  color: AppColors.glassTextMuted,
                  fontSize: bodySize,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Success message (fades in when saved)
          AnimatedOpacity(
            opacity: _saved ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 400),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                AppStrings.lessonDraftSavedEs,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFFFFD700),
                  fontSize: bodySize,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          // Save / Home button
          _GlowButton(
            label: _saved
                ? AppStrings.lessonDraftHomeEs
                : AppStrings.lessonDraftSaveEs,
            height: btnHeight,
            fontSize: bodySize,
            onPressed: _saved
                ? () => Navigator.of(context).pop()
                : (_controller.text.trim().isEmpty ? null : _onSave),
          ),
        ],
      ),
    );
  }
}

// ── Placeholder Page ───────────────────────────────────────────────────────────

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassCard(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.glassTextMuted,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Glow Button ───────────────────────────────────────────────────────────────

class _GlowButton extends StatelessWidget {
  const _GlowButton({
    required this.label,
    required this.height,
    required this.fontSize,
    required this.onPressed,
  });

  final String label;
  final double height;
  final double fontSize;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (isEnabled)
            BoxShadow(
              color: AppColors.glowTerracotta.withValues(alpha: 0.55),
              blurRadius: 28,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? AppColors.glowTerracotta
              : const Color(0x40FFFFFF),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: isEnabled ? Colors.white : AppColors.glassTextMuted,
          ),
        ),
      ),
    );
  }
}
