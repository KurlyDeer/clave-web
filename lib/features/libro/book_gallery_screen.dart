import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/data/writing_prompts_data.dart';
import '../../core/models/book_page_model.dart';
import '../../core/providers/book_pages_provider.dart';
import '../../core/providers/persona_provider.dart';
import '../../core/providers/audio_provider.dart';
import '../../core/services/audio_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_container.dart';
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
      backgroundColor: AppColors.glassGradientStart,
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
          child: pages.isEmpty
              ? _GlassEmptyState(isSenior: isSenior)
              : _GlassPageList(pages: pages, isSenior: isSenior),
        ),
      ),
      floatingActionButton: pages.isEmpty
          ? null
          : _GlassNewPageFab(pageCount: pages.length, isSenior: isSenior),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _GlassEmptyState extends StatelessWidget {
  const _GlassEmptyState({required this.isSenior});

  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
    final textSize = isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle;
    final buttonHeight = isSenior ? 72.0 : 60.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Back button
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.glassText),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: GlassContainer(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('📖', style: TextStyle(fontSize: 72)),
                    const SizedBox(height: 24),
                    Text(
                      AppStrings.libroGalleryTitleEs,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: textSize,
                        color: AppColors.glassText,
                        fontWeight: FontWeight.w800,
                        shadows: [
                          Shadow(
                            color: AppColors.glowTerracotta.withValues(alpha: 0.6),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppStrings.libroGlassEmptyEs,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: bodySize,
                        color: AppColors.glassTextMuted,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: buttonHeight,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.glowTerracotta,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          AppStrings.libroGlassGoToLessonEs,
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

// ── Page list ──────────────────────────────────────────────────────────────────

class _GlassPageList extends ConsumerStatefulWidget {
  const _GlassPageList({required this.pages, required this.isSenior});

  final List<BookPage> pages;
  final bool isSenior;

  @override
  ConsumerState<_GlassPageList> createState() => _GlassPageListState();
}

class _GlassPageListState extends ConsumerState<_GlassPageList> {
  @override
  Widget build(BuildContext context) {
    final AudioService tts = ref.read(audioServiceProvider);
    final isSenior = widget.isSenior;
    final pages = widget.pages;
    final headlineSize = isSenior ? AppFontSizes.titleLarge : AppFontSizes.subtitle;
    final smallSize = isSenior ? AppFontSizes.body : AppFontSizes.body - 2;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: pages.length + 2, // +1 header, +1 publish button
      itemBuilder: (context, index) {
        // ── Header ──
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24, top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: AppColors.glassText),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        AppStrings.libroGalleryTitleEs,
                        style: TextStyle(
                          fontSize: headlineSize,
                          color: AppColors.glassText,
                          fontWeight: FontWeight.w800,
                          shadows: [
                            Shadow(
                              color: AppColors.glowTerracotta.withValues(alpha: 0.6),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    '${AppStrings.libroGlassSubtitleEs} ${pages.length} ${AppStrings.libroPagesCountEs}.',
                    style: TextStyle(
                      fontSize: smallSize,
                      color: AppColors.glassTextMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // ── Publish button ──
        if (index == 1) {
          if (pages.length < 3) return const SizedBox.shrink();
          final buttonHeight = isSenior ? 72.0 : 60.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: GlassContainer(
              padding: EdgeInsets.zero,
              borderColor: AppColors.glowTerracotta.withValues(alpha: 0.5),
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
                    backgroundColor: AppColors.glowTerracotta,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          );
        }

        // ── Page card ──
        final page = pages[index - 2];
        return _GlassPageCard(
          page: page,
          isSenior: isSenior,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => LibroScreen(existingPage: page),
            ),
          ),
          onDelete: () => _confirmDelete(context, page),
          onPlay: () => tts.speak(page.text),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, BookPage page) async {
    final isSenior = widget.isSenior;
    final buttonHeight = isSenior ? 72.0 : 48.0;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.libroDeleteConfirmTitleEs,
                style: TextStyle(
                  fontSize: isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle,
                  fontWeight: FontWeight.w700,
                  color: AppColors.glassText,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.libroDeleteConfirmBodyEs,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body,
                  color: AppColors.glassTextMuted,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.glassText,
                        side: BorderSide(color: AppColors.glassBorder),
                        minimumSize: Size(0, buttonHeight),
                      ),
                      child: Text(AppStrings.libroDeleteConfirmNoEs),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        minimumSize: Size(0, buttonHeight),
                      ),
                      child: Text(AppStrings.libroDeleteConfirmYesEs),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      await ref.read(bookPagesProvider.notifier).deletePage(page.id);
    }
  }
}

// ── Glass page card ────────────────────────────────────────────────────────────

class _GlassPageCard extends StatelessWidget {
  const _GlassPageCard({
    required this.page,
    required this.isSenior,
    required this.onTap,
    required this.onDelete,
    required this.onPlay,
  });

  final BookPage page;
  final bool isSenior;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final textSize = isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle;
    final promptSize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
    final smallSize = isSenior ? AppFontSizes.body : AppFontSizes.body - 2;

    String formattedDate;
    try {
      final dt = DateTime.parse(page.createdAt).toLocal();
      formattedDate = '${dt.day}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
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
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red[700],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: GlassContainer(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // English text row: play icon + text
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: onPlay,
                    icon: const Icon(
                      Icons.volume_up_rounded,
                      color: AppColors.glowTerracotta,
                    ),
                    tooltip: AppStrings.libroGlassPlayEs,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    iconSize: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      page.text,
                      style: TextStyle(
                        fontSize: textSize,
                        fontFamily: 'Georgia',
                        color: AppColors.glassText,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Spanish prompt (italic, muted)
              Text(
                page.promptEs,
                style: TextStyle(
                  fontSize: promptSize,
                  color: AppColors.glassTextMuted,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              // Bottom row: date + reviewed badge + edit icon
              Row(
                children: [
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: smallSize,
                      color: AppColors.glassTextMuted,
                    ),
                  ),
                  const Spacer(),
                  if (page.isReviewed) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.greenAccent.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        AppStrings.libroRevisadaBadgeEs,
                        style: TextStyle(
                          fontSize: smallSize,
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: AppColors.glassTextMuted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── FAB ────────────────────────────────────────────────────────────────────────

class _GlassNewPageFab extends StatelessWidget {
  const _GlassNewPageFab({required this.pageCount, required this.isSenior});

  final int pageCount;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final textSize = isSenior ? AppFontSizes.body : AppFontSizes.body - 1;

    return FloatingActionButton.extended(
      onPressed: () => _openNewPage(context, pageCount),
      backgroundColor: AppColors.glowTerracotta,
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
