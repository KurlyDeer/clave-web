import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/lesson_repository.dart';
import '../../core/providers/audio_provider.dart';
import '../../core/providers/gamification_controller.dart';
import '../../core/providers/path_lesson_provider.dart';
import '../../core/providers/persona_provider.dart';
import '../../core/providers/smart_review_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_container.dart';
import '../../l10n/app_strings.dart';
import '../simulador/simulador_screen.dart';

class LessonDetailScreen extends ConsumerStatefulWidget {
  const LessonDetailScreen({
    super.key,
    required this.lesson,
    this.isReviewMode = false,
    this.reviewBankKeys,
  });

  final PathLesson lesson;
  final bool isReviewMode;
  final List<String>? reviewBankKeys;

  @override
  ConsumerState<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends ConsumerState<LessonDetailScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  int get _pageCount {
    if (widget.isReviewMode) return 1;
    return widget.lesson.quizzes.isNotEmpty ? 5 : 4;
  }

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

  @override
  Widget build(BuildContext context) {
    final persona = ref.watch(personaProvider);
    final isSenior = persona?.isSeniorMode ?? false;
    final progress = widget.isReviewMode
        ? null
        : ref.watch(pathLessonProgressProvider(widget.lesson.id));
    final isCompleted = progress?.completed ?? false;
    final diffColor =
        AppGlassStyles.difficultyColor(widget.lesson.difficulty);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
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
              // ── Header ───────────────────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: AppColors.glassText,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(widget.lesson.iconEmoji,
                                  style: const TextStyle(fontSize: 22)),
                              const SizedBox(width: 8),
                              if (!widget.isReviewMode)
                                _DifficultyBadge(
                                    label: widget.lesson.difficulty,
                                    color: diffColor),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.isReviewMode
                                ? AppStrings.smartReviewTitleEs
                                : widget.lesson.titleEs,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: isSenior
                                  ? AppFontSizes.titleLarge
                                  : AppFontSizes.title,
                              fontWeight: FontWeight.w800,
                              color: AppColors.glassText,
                            ),
                          ),
                          Text(
                            widget.isReviewMode
                                ? AppStrings.smartReviewTitleEn
                                : widget.lesson.titleEn,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize:
                                  isSenior ? AppFontSizes.body : 16.0,
                              color: AppColors.glassTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCompleted && !widget.isReviewMode)
                      _CompletedBadge(isSenior: isSenior),
                  ],
                ),
              ),

              // ── PageView ─────────────────────────────────────────────────
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) =>
                      setState(() => _currentPage = page),
                  children: widget.isReviewMode
                      ? [
                          // Review mode: quiz only
                          _QuizPage(
                            lesson: widget.lesson,
                            isSenior: isSenior,
                            reviewBankKeys: widget.reviewBankKeys,
                            onCorrectAnswer: (key) => ref
                                .read(smartReviewProvider.notifier)
                                .removeItem(key),
                            onReviewComplete: () {
                              ref
                                  .read(gamificationProvider.notifier)
                                  .addXp(10);
                              ref
                                  .read(gamificationProvider.notifier)
                                  .recordPractice();
                            },
                          ),
                        ]
                      : [
                          // Page 1: Intro / Goal
                          _IntroPage(
                              lesson: widget.lesson, isSenior: isSenior),
                          // Page 2: Vocabulary
                          _VocabPage(
                              lesson: widget.lesson, isSenior: isSenior),
                          // Page 3: Grammar
                          _GrammarPage(
                              lesson: widget.lesson, isSenior: isSenior),
                          // Page 4: Quiz (only when quizzes exist)
                          if (widget.lesson.quizzes.isNotEmpty)
                            _QuizPage(
                              lesson: widget.lesson,
                              isSenior: isSenior,
                              onWrongAnswer: (quiz) => ref
                                  .read(smartReviewProvider.notifier)
                                  .addFailedItem(
                                    lessonId: widget.lesson.id,
                                    quiz: quiz,
                                  ),
                            ),
                          // Page 5 (or 4): Practice
                          _PracticePage(
                            lesson: widget.lesson,
                            isSenior: isSenior,
                            isRepractice: isCompleted,
                          ),
                        ],
                ),
              ),

              // ── Dot indicator ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pageCount, (i) {
                    final isActive = i == _currentPage;
                    final size =
                        isActive ? (isSenior ? 12.0 : 10.0) : (isSenior ? 10.0 : 8.0);
                    return GestureDetector(
                      onTap: () => _pageController.animateToPage(
                        i,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: size,
                        height: size,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive
                              ? AppColors.glowTerracotta
                              : AppColors.glassBorder,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Page 1: Intro ─────────────────────────────────────────────────────────────

class _IntroPage extends StatelessWidget {
  const _IntroPage({required this.lesson, required this.isSenior});

  final PathLesson lesson;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final titleSize = isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle;
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(lesson.iconEmoji,
              style: TextStyle(fontSize: isSenior ? 64 : 56)),
          const SizedBox(height: 16),
          Text(
            AppStrings.lessonDetailIntroTitleEs,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w800,
              color: AppColors.glassText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lesson.titleEn,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: bodySize,
              color: AppColors.glassTextMuted,
            ),
          ),
          const SizedBox(height: 24),
          GlassContainer(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.lessonDetailIntroBodyEs,
                  style: TextStyle(
                    fontSize: bodySize,
                    fontWeight: FontWeight.w700,
                    color: AppColors.glowTerracotta,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  lesson.grammarRuleEs.split('\n').first,
                  style: TextStyle(
                    fontSize: bodySize,
                    color: AppColors.glassText,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${lesson.targetVocabulary.length} palabras nuevas',
                  style: TextStyle(
                    fontSize: bodySize - 2,
                    color: AppColors.glassTextMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Desliza para comenzar →',
            style: TextStyle(
              fontSize: bodySize - 2,
              color: AppColors.glassTextMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page 2: Vocabulary ────────────────────────────────────────────────────────

class _VocabPage extends StatelessWidget {
  const _VocabPage({required this.lesson, required this.isSenior});

  final PathLesson lesson;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
              title: AppStrings.lessonDetailVocabTitleEs,
              isSenior: isSenior),
          const SizedBox(height: 12),
          _VocabGrid(lesson: lesson, isSenior: isSenior),
        ],
      ),
    );
  }
}

// ── Page 3: Grammar ───────────────────────────────────────────────────────────

class _GrammarPage extends StatelessWidget {
  const _GrammarPage({required this.lesson, required this.isSenior});

  final PathLesson lesson;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
              title: AppStrings.lessonDetailGrammarTitleEs,
              isSenior: isSenior),
          const SizedBox(height: 12),
          _GrammarCard(lesson: lesson, isSenior: isSenior),
        ],
      ),
    );
  }
}

// ── Page 4: Quiz ──────────────────────────────────────────────────────────────

class _QuizPage extends StatefulWidget {
  const _QuizPage({
    required this.lesson,
    required this.isSenior,
    this.onWrongAnswer,
    this.onCorrectAnswer,
    this.reviewBankKeys,
    this.onReviewComplete,
  });

  final PathLesson lesson;
  final bool isSenior;
  final void Function(QuizItem quiz)? onWrongAnswer;
  final void Function(String bankKey)? onCorrectAnswer;
  final List<String>? reviewBankKeys;
  final VoidCallback? onReviewComplete;

  @override
  State<_QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<_QuizPage> {
  int _questionIndex = 0;
  int? _selectedAnswer;
  int _score = 0;
  bool _showSummary = false;

  void _selectAnswer(int index) {
    if (_selectedAnswer != null) return; // already answered
    final quiz = widget.lesson.quizzes[_questionIndex];
    final isCorrect = index == quiz.correctIndex;
    setState(() {
      _selectedAnswer = index;
      if (isCorrect) {
        _score++;
        if (widget.reviewBankKeys != null) {
          widget.onCorrectAnswer
              ?.call(widget.reviewBankKeys![_questionIndex]);
        }
      } else {
        widget.onWrongAnswer?.call(quiz);
      }
    });
  }

  void _next() {
    final nextIndex = _questionIndex + 1;
    if (nextIndex >= widget.lesson.quizzes.length) {
      widget.onReviewComplete?.call();
      setState(() => _showSummary = true);
    } else {
      setState(() {
        _questionIndex = nextIndex;
        _selectedAnswer = null;
      });
    }
  }

  void _restart() {
    setState(() {
      _questionIndex = 0;
      _selectedAnswer = null;
      _score = 0;
      _showSummary = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
              title: AppStrings.lessonDetailQuizTitleEs,
              isSenior: widget.isSenior),
          const SizedBox(height: 16),
          if (_showSummary)
            _QuizSummary(
              score: _score,
              total: widget.lesson.quizzes.length,
              isSenior: widget.isSenior,
              onRestart: _restart,
              isReviewMode: widget.reviewBankKeys != null,
              onBack: () => Navigator.of(context).pop(),
            )
          else
            _QuizQuestion(
              quiz: widget.lesson.quizzes[_questionIndex],
              questionNumber: _questionIndex + 1,
              total: widget.lesson.quizzes.length,
              selectedAnswer: _selectedAnswer,
              isSenior: widget.isSenior,
              onSelect: _selectAnswer,
              onNext: _next,
            ),
        ],
      ),
    );
  }
}

class _QuizQuestion extends StatelessWidget {
  const _QuizQuestion({
    required this.quiz,
    required this.questionNumber,
    required this.total,
    required this.selectedAnswer,
    required this.isSenior,
    required this.onSelect,
    required this.onNext,
  });

  final QuizItem quiz;
  final int questionNumber;
  final int total;
  final int? selectedAnswer;
  final bool isSenior;
  final ValueChanged<int> onSelect;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
    final answered = selectedAnswer != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress indicator
        Text(
          '$questionNumber / $total',
          style: TextStyle(
            fontSize: isSenior ? 16 : 13.0,
            color: AppColors.glassTextMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Text(
            quiz.question,
            style: TextStyle(
              fontSize: bodySize,
              fontWeight: FontWeight.w700,
              color: AppColors.glassText,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 14),
        ...List.generate(quiz.options.length, (i) {
          final isCorrect = i == quiz.correctIndex;
          final isSelected = i == selectedAnswer;

          Color borderColor = AppColors.glassBorder;
          Color bgColor = Colors.transparent;
          if (answered) {
            if (isCorrect) {
              borderColor = AppColors.successGreen;
              bgColor = AppColors.successGreen.withOpacity(0.12);
            } else if (isSelected) {
              borderColor = Colors.redAccent;
              bgColor = Colors.redAccent.withOpacity(0.10);
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        quiz.options[i],
                        style: TextStyle(
                          fontSize: bodySize,
                          color: AppColors.glassText,
                          fontWeight: isSelected || (answered && isCorrect)
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (answered && isCorrect)
                      Icon(Icons.check_circle,
                          color: AppColors.successGreen, size: 20),
                    if (answered && isSelected && !isCorrect)
                      const Icon(Icons.cancel,
                          color: Colors.redAccent, size: 20),
                  ],
                ),
              ),
            ),
          );
        }),
        if (answered) ...[
          const SizedBox(height: 4),
          Text(
            selectedAnswer == quiz.correctIndex
                ? AppStrings.lessonQuizCorrectEs
                : AppStrings.lessonQuizWrongEs,
            style: TextStyle(
              fontSize: bodySize,
              fontWeight: FontWeight.w700,
              color: selectedAnswer == quiz.correctIndex
                  ? AppColors.successGreen
                  : Colors.redAccent,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: isSenior ? 64.0 : 54.0,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.glowTerracotta,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                questionNumber < total
                    ? AppStrings.lessonDetailQuizNextEs
                    : AppStrings.lessonDetailQuizFinishEs,
                style: TextStyle(
                  fontSize: isSenior
                      ? AppFontSizes.subtitleLarge
                      : AppFontSizes.subtitle,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _QuizSummary extends StatelessWidget {
  const _QuizSummary({
    required this.score,
    required this.total,
    required this.isSenior,
    required this.onRestart,
    this.isReviewMode = false,
    this.onBack,
  });

  final int score;
  final int total;
  final bool isSenior;
  final VoidCallback onRestart;
  final bool isReviewMode;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
    final pct = total > 0 ? (score / total * 100).round() : 0;
    final emoji = pct >= 80 ? '🏆' : pct >= 60 ? '👍' : '💪';

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          Text(
            isReviewMode
                ? AppStrings.smartReviewCompleteTitleEs
                : AppStrings.lessonDetailQuizResultEs,
            style: TextStyle(
              fontSize: bodySize,
              fontWeight: isReviewMode ? FontWeight.w700 : FontWeight.w400,
              color: isReviewMode
                  ? AppColors.glassText
                  : AppColors.glassTextMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$score / $total ($pct%)',
            style: TextStyle(
              fontSize: isSenior ? AppFontSizes.titleLarge : AppFontSizes.title,
              fontWeight: FontWeight.w900,
              color: pct >= 80
                  ? AppColors.successGreen
                  : AppColors.glowTerracotta,
            ),
          ),
          if (isReviewMode) ...[
            const SizedBox(height: 8),
            Text(
              AppStrings.smartReviewCompleteBodyEs,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: bodySize - 2,
                color: AppColors.glassTextMuted,
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: isSenior ? 64.0 : 54.0,
            child: isReviewMode
                ? ElevatedButton(
                    onPressed: onBack,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.glowTerracotta,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      AppStrings.smartReviewBackEs,
                      style: TextStyle(
                        fontSize: isSenior
                            ? AppFontSizes.subtitleLarge
                            : AppFontSizes.subtitle,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : OutlinedButton(
                    onPressed: onRestart,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.glassText,
                      side: BorderSide(color: AppColors.glassBorder),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      'Intentar de nuevo',
                      style: TextStyle(
                        fontSize: isSenior
                            ? AppFontSizes.subtitleLarge
                            : AppFontSizes.subtitle,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),
          if (!isReviewMode) ...[
            const SizedBox(height: 12),
            Text(
              AppStrings.lessonDetailQuizContinueEs,
              style: TextStyle(
                fontSize: bodySize - 2,
                color: AppColors.glassTextMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Page 4 (original): Practice ───────────────────────────────────────────────
// (Now Page 5 when quizzes are present)

// ── Page 4: Practice ──────────────────────────────────────────────────────────

class _PracticePage extends StatelessWidget {
  const _PracticePage({
    required this.lesson,
    required this.isSenior,
    required this.isRepractice,
  });

  final PathLesson lesson;
  final bool isSenior;
  final bool isRepractice;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎤', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            AppStrings.lessonDetailReadyEs,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle,
              fontWeight: FontWeight.w800,
              color: AppColors.glassText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Practica lo que aprendiste en una conversación real.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSenior ? AppFontSizes.body : 15.0,
              color: AppColors.glassTextMuted,
            ),
          ),
          const SizedBox(height: 32),
          _PracticeButton(
              lesson: lesson,
              isSenior: isSenior,
              isRepractice: isRepractice),
        ],
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.isSenior});

  final String title;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle,
          fontWeight: FontWeight.w700,
          color: AppColors.glassText,
        ),
      ),
    );
  }
}

// ── Difficulty Badge ──────────────────────────────────────────────────────────

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(label, style: AppTextStyles.difficultyBadge(color)),
    );
  }
}

// ── Completed Badge ───────────────────────────────────────────────────────────

class _CompletedBadge extends StatelessWidget {
  const _CompletedBadge({required this.isSenior});

  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.successGreen.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: AppColors.successGreen.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle,
              color: AppColors.successGreen, size: 16),
          const SizedBox(width: 4),
          Text(
            AppStrings.lessonCompleteLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.successGreen,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Vocab Grid ────────────────────────────────────────────────────────────────

class _VocabGrid extends ConsumerWidget {
  const _VocabGrid({required this.lesson, required this.isSenior});

  final PathLesson lesson;
  final bool isSenior;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final cardWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: lesson.targetVocabulary
              .map((v) => SizedBox(
                    width: cardWidth,
                    child: _VocabCard(item: v, isSenior: isSenior),
                  ))
              .toList(),
        );
      },
    );
  }
}

class _VocabCard extends ConsumerWidget {
  const _VocabCard({required this.item, required this.isSenior});

  final VocabItem item;
  final bool isSenior;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordSize =
        isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle;
    final labelSize = isSenior ? AppFontSizes.body : 15.0;
    final exampleSize = isSenior ? 18.0 : 13.0;

    return GestureDetector(
      onTap: () => ref.read(audioServiceProvider).speak(item.wordEn),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.wordEn,
                    style: TextStyle(
                      fontSize: wordSize,
                      fontWeight: FontWeight.w800,
                      color: AppColors.glassText,
                    ),
                  ),
                ),
                Icon(Icons.volume_up,
                    color: AppColors.glowTerracotta, size: 18),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              item.wordEs,
              style: TextStyle(
                fontSize: labelSize,
                fontWeight: FontWeight.w600,
                color: AppColors.glassTextMuted,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.exampleEn,
              style: TextStyle(
                fontSize: exampleSize,
                color: AppColors.glassTextMuted,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Grammar Card ──────────────────────────────────────────────────────────────

class _GrammarCard extends StatelessWidget {
  const _GrammarCard({required this.lesson, required this.isSenior});

  final PathLesson lesson;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;

    return GlassContainer(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lesson.grammarRuleEs,
            style: TextStyle(
              fontSize: bodySize,
              color: AppColors.glassText,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.glowTerracotta.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppColors.glowTerracotta.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.lessonDetailExampleLabelEs,
                  style: TextStyle(
                    fontSize: isSenior ? 16 : 13.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.glowTerracotta,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lesson.grammarExample,
                  style: TextStyle(
                    fontSize: bodySize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.glassText,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
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

// ── Practice Button ───────────────────────────────────────────────────────────

class _PracticeButton extends StatelessWidget {
  const _PracticeButton({
    required this.lesson,
    required this.isSenior,
    required this.isRepractice,
  });

  final PathLesson lesson;
  final bool isSenior;
  final bool isRepractice;

  @override
  Widget build(BuildContext context) {
    final btnHeight = isSenior ? 72.0 : 60.0;
    final label = isRepractice
        ? AppStrings.lessonDetailRepracticeEs
        : AppStrings.lessonDetailPracticeEs;

    return SizedBox(
      height: btnHeight,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                SimuladorScreen(scenario: lesson.toScenarioData()),
          ),
        ),
        icon: Icon(Icons.mic_rounded, size: 22),
        label: Text(
          label,
          style: TextStyle(
            fontSize:
                isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.glowTerracotta,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: AppColors.glowTerracotta.withOpacity(0.5),
        ),
      ),
    );
  }
}
