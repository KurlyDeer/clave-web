import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/data/writing_prompts_data.dart';
import '../../core/models/book_page_model.dart';
import '../../core/providers/book_pages_provider.dart';
import '../../core/providers/persona_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_strings.dart';
import 'libro_screen.dart';
import 'publish_screen.dart';

class BookGalleryScreen extends ConsumerWidget {
  const BookGalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pages = ref.watch(bookPagesProvider);
    final persona = ref.watch(personaProvider);
    final isSenior = persona?.isSeniorMode ?? false;

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: pages.isEmpty
          ? _EmptyState(isSenior: isSenior)
          : _PageList(pages: pages, isSenior: isSenior),
      floatingActionButton: pages.isEmpty
          ? null
          : _NewPageFab(pageCount: pages.length, isSenior: isSenior),
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
    final buttonHeight = isSenior ? 72.0 : 60.0;
    final textSize =
        isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📖', style: TextStyle(fontSize: 72)),
          const SizedBox(height: 24),
          Text(
            AppStrings.libroEmptyStateEs,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: bodySize,
              color: AppColors.darkText,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: buttonHeight,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _openNewPage(context, 0),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.terracotta,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: Text(
                AppStrings.libroEmptyStateCTAEs,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: textSize,
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

void _openNewPage(BuildContext context, int pageCount) {
  final prompt = WritingPromptsData.forPageCount(pageCount);
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => LibroScreen(prompt: prompt),
    ),
  );
}

// ── Page list ─────────────────────────────────────────────────────────────────

class _PageList extends ConsumerWidget {
  const _PageList({required this.pages, required this.isSenior});

  final List<BookPage> pages;
  final bool isSenior;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
    final smallSize = isSenior ? AppFontSizes.body : AppFontSizes.body - 2;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: pages.length + 2, // +1 count header, +1 publish button
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              '${pages.length} ${AppStrings.libroPagesCountEs}',
              style: TextStyle(
                fontSize: smallSize,
                color: AppColors.darkText.withValues(alpha: 0.55),
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }

        if (index == 1) {
          if (pages.length < 3) return const SizedBox.shrink();
          final buttonHeight = isSenior ? 72.0 : 60.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: SizedBox(
              height: buttonHeight,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PublishScreen(pages: pages),
                  ),
                ),
                icon: const Icon(Icons.menu_book_rounded),
                label: Text(
                  AppStrings.publishTitleEs,
                  style: TextStyle(
                    fontSize: isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.terracotta,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
              ),
            ),
          );
        }

        final page = pages[index - 2];
        return _PageCard(
          page: page,
          isSenior: isSenior,
          bodySize: bodySize,
          smallSize: smallSize,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => LibroScreen(existingPage: page),
            ),
          ),
          onDelete: () => _confirmDelete(context, ref, page),
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    BookPage page,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          AppStrings.libroDeleteConfirmTitleEs,
          style: TextStyle(
            fontSize: isSenior ? AppFontSizes.subtitle : AppFontSizes.body,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          AppStrings.libroDeleteConfirmBodyEs,
          style: TextStyle(
            fontSize: isSenior ? AppFontSizes.body : AppFontSizes.body - 2,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppStrings.libroDeleteConfirmNoEs),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppStrings.libroDeleteConfirmYesEs),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(bookPagesProvider.notifier).deletePage(page.id);
    }
  }
}

class _PageCard extends StatelessWidget {
  const _PageCard({
    required this.page,
    required this.isSenior,
    required this.bodySize,
    required this.smallSize,
    required this.onTap,
    required this.onDelete,
  });

  final BookPage page;
  final bool isSenior;
  final double bodySize;
  final double smallSize;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final preview = page.text.length > 80
        ? '${page.text.substring(0, 80)}…'
        : page.text;
    final promptPreview = page.promptEs.length > 60
        ? '${page.promptEs.substring(0, 60)}…'
        : page.promptEs;

    String formattedDate;
    try {
      final dt = DateTime.parse(page.createdAt).toLocal();
      formattedDate =
          '${dt.day}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      formattedDate = page.createdAt.length >= 10
          ? page.createdAt.substring(0, 10)
          : page.createdAt;
    }

    return Dismissible(
      key: ValueKey(page.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onDelete();
        return false; // deletion handled in onDelete with confirmation
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Prompt preview
              Row(
                children: [
                  const Text('✨', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      promptPreview,
                      style: TextStyle(
                        fontSize: smallSize,
                        color: AppColors.terracotta,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (page.isReviewed)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green[300]!,
                        ),
                      ),
                      child: Text(
                        AppStrings.libroRevisadaBadgeEs,
                        style: TextStyle(
                          fontSize: smallSize - 2,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Text preview
              Text(
                preview,
                style: TextStyle(
                  fontSize: bodySize,
                  color: AppColors.darkText,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              // Date
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: smallSize,
                  color: AppColors.darkText.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── FAB ───────────────────────────────────────────────────────────────────────

class _NewPageFab extends StatelessWidget {
  const _NewPageFab({required this.pageCount, required this.isSenior});

  final int pageCount;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final textSize = isSenior ? AppFontSizes.body : AppFontSizes.body - 1;

    return FloatingActionButton.extended(
      onPressed: () => _openNewPage(context, pageCount),
      backgroundColor: AppColors.terracotta,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.edit_note),
      label: Text(
        AppStrings.libroNewPageEs,
        style: TextStyle(
          fontSize: textSize,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
