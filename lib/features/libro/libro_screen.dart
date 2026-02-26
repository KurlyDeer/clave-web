import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/writing_prompts_data.dart';
import '../../core/models/book_page_model.dart';
import '../../core/providers/book_pages_provider.dart';
import '../../core/providers/libro_provider.dart';
import '../../core/providers/persona_provider.dart';
import '../../core/providers/tts_provider.dart';
import '../../core/theme/app_theme.dart';
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
    final tts = ref.read(ttsServiceProvider);

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
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.deepBlue,
        foregroundColor: Colors.white,
        title: Text(
          '${AppStrings.libroGalleryTitleEs}  •  ${AppStrings.libroGalleryTitleEn}',
          style: TextStyle(
            fontSize: isSenior ? AppFontSizes.subtitle : AppFontSizes.body,
            fontWeight: FontWeight.w700,
          ),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            tts.stop();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                ],
              ),
            ),
          ),
        ],
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

    // Book-page card with a left decorative line.
    final cardDecoration = BoxDecoration(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(
          color: AppColors.shadow,
          blurRadius: 8,
          offset: Offset(0, 3),
        ),
      ],
    );

    Widget card;

    if (state.status == LibroStatus.editing ||
        state.status == LibroStatus.reviewing ||
        state.status == LibroStatus.offlineError ||
        state.status == LibroStatus.apiError) {
      card = Container(
        decoration: cardDecoration,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: AppColors.terracotta.withValues(alpha: 0.5),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
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
                    color: AppColors.darkText,
                    height: 1.6,
                  ),
                  decoration: InputDecoration(
                    hintText: AppStrings.libroHintEs,
                    hintStyle: TextStyle(
                      fontSize: bodySize,
                      color: AppColors.darkText.withValues(alpha: 0.35),
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
      // reviewed / noErrors — show GrammarRichText in same card style.
      card = Container(
        padding: const EdgeInsets.only(left: 4),
        decoration: cardDecoration,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: AppColors.terracotta.withValues(alpha: 0.5),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Save button (deepBlue outline)
            SizedBox(
              height: height,
              child: OutlinedButton(
                onPressed: state.draftText.trim().isNotEmpty
                    ? () => _savePage(state)
                    : null,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.deepBlue, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  '${AppStrings.libroSavePageEs}  •  ${AppStrings.libroSavePageEn}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: smallTextSize,
                    color: AppColors.deepBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Review button (terracotta)
            SizedBox(
              height: height,
              child: ElevatedButton(
                onPressed: state.draftText.trim().isNotEmpty
                    ? notifier.review
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.terracotta,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppColors.terracotta.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  AppStrings.libroRevisarPaginaEs,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: textSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        );

      case LibroStatus.reviewing:
        return SizedBox(
          height: height,
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.terracotta.withValues(alpha: 0.6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  AppStrings.libroReviewingEs,
                  style: TextStyle(
                    fontSize: textSize,
                    fontWeight: FontWeight.w700,
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
              child: SizedBox(
                height: height,
                child: OutlinedButton(
                  onPressed: () {
                    _controller.text = state.draftText;
                    notifier.resetToEditing();
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.deepBlue, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    AppStrings.libroEditarEs,
                    style: TextStyle(
                      fontSize: smallTextSize,
                      color: AppColors.deepBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: height,
                child: ElevatedButton(
                  onPressed: () {
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    AppStrings.libroCopyAllEs,
                    style: TextStyle(
                      fontSize: smallTextSize,
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.terracotta.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.terracotta.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.libroInspirationLabel,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w700,
              color: AppColors.terracotta,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            prompt.promptEs,
            style: TextStyle(
              fontSize: bodySize,
              color: AppColors.darkText,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            prompt.promptEn,
            style: TextStyle(
              fontSize: bodySize - 2,
              color: AppColors.darkText.withValues(alpha: 0.55),
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.terracotta.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.terracotta.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$count ${AppStrings.libroErrorCountEs}',
        style: TextStyle(
          fontSize: bodySize,
          fontWeight: FontWeight.w700,
          color: AppColors.terracotta,
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.deepBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.deepBlue.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.libroFeedbackTitleEs,
            style: TextStyle(
              fontSize: bodySize - 2,
              fontWeight: FontWeight.w700,
              color: AppColors.deepBlue,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            feedback,
            style: TextStyle(
              fontSize: bodySize,
              color: AppColors.darkText,
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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: bodySize,
          color: Colors.red[800],
          height: 1.5,
        ),
      ),
    );
  }
}
