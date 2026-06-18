import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/writing_prompts_data.dart';
import '../../core/models/book_page_model.dart';
import '../../core/providers/book_pages_provider.dart';
import '../../core/providers/libro_provider.dart';
import '../../core/providers/persona_provider.dart';
import '../../core/providers/audio_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_container.dart';
import '../../l10n/app_strings.dart';
import '../../shared/widgets/offline_banner.dart';
import 'widgets/error_explanation_popup.dart';
import 'widgets/grammar_rich_text.dart';

class LibroScreen extends ConsumerStatefulWidget {
  const LibroScreen({
    super.key,
    this.existingPage,
    this.prompt,
  });

  /// When editing an existing saved page.
  final BookPage? existingPage;

  /// The writing prompt to show at the top (for new pages).
  final WritingPrompt? prompt;

  @override
  ConsumerState<LibroScreen> createState() => _LibroScreenState();
}

class _LibroScreenState extends ConsumerState<LibroScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingPage != null) {
      // Schedule after first frame so the provider is initialised.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(libroProvider.notifier)
            .loadDraft(widget.existingPage!.text);
        _controller.text = widget.existingPage!.text;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  WritingPrompt? get _effectivePrompt {
    if (widget.prompt != null) return widget.prompt;
    if (widget.existingPage != null) {
      return WritingPrompt(
        promptEs: widget.existingPage!.promptEs,
        promptEn: widget.existingPage!.promptEn,
      );
    }
    return null;
  }

  Future<void> _savePage(LibroState state, {bool isReviewed = false}) async {
    final text = state.draftText.trim();
    if (text.isEmpty) return;

    final now = DateTime.now().toIso8601String();
    final prompt = _effectivePrompt;
    final promptEs = prompt?.promptEs ?? '';
    final promptEn = prompt?.promptEn ?? '';

    final pagesNotifier = ref.read(bookPagesProvider.notifier);

    if (widget.existingPage != null) {
      final updated = widget.existingPage!.copyWith(
        text: text,
        updatedAt: now,
        isReviewed: isReviewed || widget.existingPage!.isReviewed,
      );
      await pagesNotifier.updatePage(updated);
    } else {
      final page = BookPage(
        id: now,
        promptEs: promptEs,
        promptEn: promptEn,
        text: text,
        createdAt: now,
        updatedAt: now,
        isReviewed: isReviewed,
      );
      // Only save once — guard with pageCount check done via id uniqueness.
      await pagesNotifier.savePage(page);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.libroPageSavedEs),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.deepBlue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(libroProvider);
    final persona = ref.watch(personaProvider);
    final isSenior = persona?.isSeniorMode ?? false;
    final notifier = ref.read(libroProvider.notifier);
    final tts = ref.read(audioServiceProvider);

    // Sync controller text when user resets to editing.
    if (state.status == LibroStatus.editing &&
        _controller.text != state.draftText) {
      _controller.text = state.draftText;
    }

    // Auto-save after review completes.
    ref.listen<LibroState>(libroProvider, (prev, next) {
      if (prev?.status == LibroStatus.reviewing &&
          (next.status == LibroStatus.reviewed ||
              next.status == LibroStatus.noErrors)) {
        _savePage(next, isReviewed: true);
      }
    });

    return Scaffold(
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
          bottom: false,
          child: Column(
            children: [
              const OfflineBanner(),
              // ── Top bar ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.glassText,
                      ),
                      onPressed: () {
                        tts.stop();
                        Navigator.of(context).pop();
                      },
                    ),
                    Expanded(
                      child: Text(
                        '${AppStrings.libroGalleryTitleEs}  •  ${AppStrings.libroGalleryTitleEn}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: isSenior
                              ? AppFontSizes.subtitleLarge
                              : AppFontSizes.body,
                          fontWeight: FontWeight.w700,
                          color: AppColors.glassText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_effectivePrompt != null) ...[
                        _InspirationCard(
                          prompt: _effectivePrompt!,
                          isSenior: isSenior,
                        ),
                        const SizedBox(height: 16),
                      ],
                      _buildDraftArea(state, notifier, isSenior, tts),
                      if (state.status == LibroStatus.reviewed &&
                          state.errors.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _ErrorSummaryBanner(
                          count: state.errors.length,
                          isSenior: isSenior,
                        ),
                      ],
                      if (state.status == LibroStatus.reviewed ||
                          state.status == LibroStatus.noErrors) ...[
                        const SizedBox(height: 12),
                        _FeedbackCard(
                          feedback: state.overallFeedbackEs,
                          isSenior: isSenior,
                        ),
                      ],
                      const SizedBox(height: 16),
                      _buildActions(state, notifier, isSenior),
                      if (state.status == LibroStatus.offlineError) ...[
                        const SizedBox(height: 16),
                        _SpanishErrorCard(
                          message: AppStrings.libroOfflineEs,
                          isSenior: isSenior,
                        ),
                      ],
                      if (state.status == LibroStatus.apiError) ...[
                        const SizedBox(height: 16),
                        _SpanishErrorCard(
                          message: state.errorMessage.isNotEmpty
                              ? state.errorMessage
                              : AppStrings.libroApiErrorEs,
                          isSenior: isSenior,
                        ),
                      ],
                      // Bottom safe-area padding (accounts for home indicator)
                      SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDraftArea(
    LibroState state,
    LibroNotifier notifier,
    bool isSenior,
    dynamic tts,
  ) {
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;

    Widget card;

    if (state.status == LibroStatus.editing ||
        state.status == LibroStatus.reviewing ||
        state.status == LibroStatus.offlineError ||
        state.status == LibroStatus.apiError) {
      card = GlassContainer(
        padding: EdgeInsets.zero,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: AppColors.glowTerracotta.withValues(alpha: 0.5),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  minLines: 8,
                  enabled: state.status != LibroStatus.reviewing,
                  onChanged: notifier.updateDraft,
                  style: TextStyle(
                    fontSize: bodySize,
                    color: AppColors.glassText,
                    height: 1.6,
                  ),
                  cursorColor: AppColors.glowTerracotta,
                  decoration: InputDecoration(
                    hintText: AppStrings.libroHintEs,
                    hintStyle: TextStyle(
                      fontSize: bodySize,
                      color: AppColors.glassTextMuted,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // reviewed / noErrors — show GrammarRichText in same glass card style.
      card = GlassContainer(
        padding: EdgeInsets.zero,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: AppColors.glowTerracotta.withValues(alpha: 0.5),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GrammarRichText(
                    text: state.draftText,
                    errors: state.errors,
                    isSenior: isSenior,
                    onErrorTapped: (error) {
                      showErrorExplanationPopup(
                        context,
                        error: error,
                        tts: tts,
                        isSenior: isSenior,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return card;
  }

  Widget _buildActions(
    LibroState state,
    LibroNotifier notifier,
    bool isSenior,
  ) {
    final height = isSenior ? 72.0 : 60.0;
    final textSize =
        isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle;
    final smallTextSize =
        isSenior ? AppFontSizes.body : AppFontSizes.body - 1;

    switch (state.status) {
      case LibroStatus.editing:
      case LibroStatus.offlineError:
      case LibroStatus.apiError:
        final hasText = state.draftText.trim().isNotEmpty;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Save button
            GestureDetector(
              onTap: hasText ? () => _savePage(state) : null,
              child: GlassContainer(
                padding: EdgeInsets.zero,
                child: SizedBox(
                  height: height,
                  child: Center(
                    child: Text(
                      '${AppStrings.libroSavePageEs}  •  ${AppStrings.libroSavePageEn}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: smallTextSize,
                        color: hasText
                            ? AppColors.glassText
                            : AppColors.glassTextMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Review button
            GestureDetector(
              onTap: hasText ? notifier.review : null,
              child: GlassContainer(
                backgroundColor: hasText
                    ? AppColors.glowTerracotta.withValues(alpha: 0.8)
                    : AppColors.glassSurface,
                borderColor: hasText
                    ? AppColors.glowTerracotta
                    : AppColors.glassBorder,
                padding: EdgeInsets.zero,
                child: SizedBox(
                  height: height,
                  child: Center(
                    child: Text(
                      AppStrings.libroRevisarPaginaEs,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: textSize,
                        fontWeight: FontWeight.w700,
                        color: hasText
                            ? Colors.white
                            : AppColors.glassTextMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );

      case LibroStatus.reviewing:
        return GlassContainer(
          padding: EdgeInsets.zero,
          child: SizedBox(
            height: height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.glowTerracotta),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  AppStrings.libroReviewingEs,
                  style: TextStyle(
                    fontSize: textSize,
                    fontWeight: FontWeight.w700,
                    color: AppColors.glassText,
                  ),
                ),
              ],
            ),
          ),
        );

      case LibroStatus.reviewed:
      case LibroStatus.noErrors:
        return Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _controller.text = state.draftText;
                  notifier.resetToEditing();
                },
                child: GlassContainer(
                  padding: EdgeInsets.zero,
                  child: SizedBox(
                    height: height,
                    child: Center(
                      child: Text(
                        AppStrings.libroEditarEs,
                        style: TextStyle(
                          fontSize: smallTextSize,
                          color: AppColors.glassText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: state.draftText),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppStrings.sosCopiedEs),
                      duration: const Duration(seconds: 2),
                      backgroundColor: AppColors.deepBlue,
                    ),
                  );
                },
                child: GlassContainer(
                  backgroundColor:
                      AppColors.glowTerracotta.withValues(alpha: 0.25),
                  borderColor: AppColors.glowTerracotta,
                  padding: EdgeInsets.zero,
                  child: SizedBox(
                    height: height,
                    child: Center(
                      child: Text(
                        AppStrings.libroCopyAllEs,
                        style: TextStyle(
                          fontSize: smallTextSize,
                          fontWeight: FontWeight.w700,
                          color: AppColors.glassText,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
    }
  }
}

// ── Inspiración card ──────────────────────────────────────────────────────────

class _InspirationCard extends StatelessWidget {
  const _InspirationCard({required this.prompt, required this.isSenior});

  final WritingPrompt prompt;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final titleSize = isSenior ? AppFontSizes.body : AppFontSizes.body - 2;
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderColor: AppColors.glowTerracotta,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.libroInspirationLabel,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w700,
              color: AppColors.glowTerracotta,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            prompt.promptEs,
            style: TextStyle(
              fontSize: bodySize,
              color: AppColors.glassText,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            prompt.promptEn,
            style: TextStyle(
              fontSize: bodySize - 2,
              color: AppColors.glassTextMuted,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _ErrorSummaryBanner extends StatelessWidget {
  const _ErrorSummaryBanner({required this.count, required this.isSenior});

  final int count;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderColor: AppColors.glowTerracotta,
      child: Text(
        '$count ${AppStrings.libroErrorCountEs}',
        style: TextStyle(
          fontSize: bodySize,
          fontWeight: FontWeight.w700,
          color: AppColors.glowTerracotta,
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.feedback, required this.isSenior});

  final String feedback;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.libroFeedbackTitleEs,
            style: TextStyle(
              fontSize: bodySize - 2,
              fontWeight: FontWeight.w700,
              color: AppColors.glowTerracotta,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            feedback,
            style: TextStyle(
              fontSize: bodySize,
              color: AppColors.glassText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpanishErrorCard extends StatelessWidget {
  const _SpanishErrorCard({required this.message, required this.isSenior});

  final String message;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderColor: Colors.red.withValues(alpha: 0.5),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: bodySize,
          color: Colors.red[300],
          height: 1.5,
        ),
      ),
    );
  }
}
