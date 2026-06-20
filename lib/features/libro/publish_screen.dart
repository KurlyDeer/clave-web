import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../core/models/book_page_model.dart';
import '../../core/providers/persona_provider.dart';
import '../../core/providers/gamification_controller.dart';
import '../../core/providers/user_name_provider.dart';
import '../../core/services/book_pdf_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_container.dart';
import '../../l10n/app_strings.dart';
import 'publish_success_screen.dart';

enum _PublishStatus { preview, generating, ready }

class PublishScreen extends ConsumerStatefulWidget {
  const PublishScreen({super.key, required this.pages});

  final List<BookPage> pages;

  @override
  ConsumerState<PublishScreen> createState() => _PublishScreenState();
}

class _PublishScreenState extends ConsumerState<PublishScreen> {
  _PublishStatus _status = _PublishStatus.preview;
  late final TextEditingController _titleCtrl;
  late Uint8List _pdfBytes;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(
      text: AppStrings.publishBookTitleDefaultEs,
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  int get _chapterCount => (widget.pages.length / 5).ceil();

  Future<Uint8List> _buildPdf() async {
    final authorName = ref.read(userNameProvider);
    final doc = await BookPdfService.generate(
      pages: widget.pages,
      authorName: authorName,
      bookTitle: _titleCtrl.text.trim().isNotEmpty
          ? _titleCtrl.text.trim()
          : AppStrings.publishBookTitleDefaultEs,
    );
    return doc.save();
  }

  Future<void> _openPreview() async {
    setState(() => _status = _PublishStatus.generating);
    try {
      final bytes = await _buildPdf();
      if (!mounted) return;
      setState(() {
        _pdfBytes = bytes;
        _status = _PublishStatus.ready;
      });
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } catch (_) {
      if (mounted) setState(() => _status = _PublishStatus.preview);
    }
  }

  Future<void> _download() async {
    setState(() => _status = _PublishStatus.generating);
    try {
      final bytes = _status == _PublishStatus.ready ? _pdfBytes : await _buildPdf();
      if (!mounted) return;
      setState(() {
        _pdfBytes = bytes;
        _status = _PublishStatus.ready;
      });
      await Printing.sharePdf(
        bytes: bytes,
        filename: '${_titleCtrl.text.trim().replaceAll(' ', '_')}.pdf',
      );
      if (mounted) _onSuccess();
    } catch (_) {
      if (mounted) setState(() => _status = _PublishStatus.ready);
    }
  }

  Future<void> _share() async {
    setState(() => _status = _PublishStatus.generating);
    try {
      final bytes =
          _status == _PublishStatus.ready ? _pdfBytes : await _buildPdf();
      if (!mounted) return;
      setState(() {
        _pdfBytes = bytes;
        _status = _PublishStatus.ready;
      });

      // On web and native, Printing.sharePdf() works cross-platform.
      await Printing.sharePdf(
        bytes: bytes,
        filename: '${_titleCtrl.text.trim().replaceAll(' ', '_')}.pdf',
      );
      if (mounted) _onSuccess();
    } catch (_) {
      if (mounted) setState(() => _status = _PublishStatus.ready);
    }
  }

  void _onSuccess() {
    ref.read(gamificationProvider.notifier).addXp(20);
    ref.read(gamificationProvider.notifier).recordPractice();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const PublishSuccessScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final persona = ref.watch(personaProvider);
    final isSenior = persona?.isSeniorMode ?? false;
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
    final titleSize = isSenior ? AppFontSizes.titleLarge : AppFontSizes.title;
    final buttonHeight = isSenior ? 72.0 : 60.0;

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
          child: _status == _PublishStatus.generating
              ? _GeneratingView(bodySize: bodySize)
              : Column(
                  children: [
                    // ── Top bar ────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: AppColors.glassText,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          Expanded(
                            child: Text(
                              '${AppStrings.publishTitleEs}  •  ${AppStrings.publishTitleEn}',
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
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Stats card
                            _StatsCard(
                              pageCount: widget.pages.length,
                              chapterCount: _chapterCount,
                              isSenior: isSenior,
                              bodySize: bodySize,
                            ),
                            const SizedBox(height: 24),

                            // Title field label
                            Text(
                              AppStrings.publishBookTitleLabelEs,
                              style: TextStyle(
                                fontSize: bodySize,
                                fontWeight: FontWeight.w700,
                                color: AppColors.glassText,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _titleCtrl,
                              style: TextStyle(
                                fontSize: bodySize,
                                color: AppColors.glassText,
                              ),
                              cursorColor: AppColors.glowTerracotta,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.glassSurface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.glassBorder,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.glassBorder,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.glowTerracotta,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Section title
                            Text(
                              AppStrings.publishStatsCardTitleEs,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: titleSize,
                                fontWeight: FontWeight.w800,
                                color: AppColors.glassText,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '📚',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isSenior ? 60.0 : 48.0,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Preview button
                            GestureDetector(
                              onTap: _openPreview,
                              child: GlassContainer(
                                padding: EdgeInsets.zero,
                                child: SizedBox(
                                  height: buttonHeight,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.visibility_outlined,
                                        color: AppColors.glassText,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        AppStrings.publishPreviewEs,
                                        style: TextStyle(
                                          fontSize: bodySize,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.glassText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Download button
                            GestureDetector(
                              onTap: _download,
                              child: GlassContainer(
                                backgroundColor:
                                    AppColors.deepBlue.withValues(alpha: 0.6),
                                borderColor: AppColors.deepBlue,
                                padding: EdgeInsets.zero,
                                child: SizedBox(
                                  height: buttonHeight,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.download_rounded,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        AppStrings.publishDownloadEs,
                                        style: TextStyle(
                                          fontSize: bodySize,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Share button
                            GestureDetector(
                              onTap: _share,
                              child: GlassContainer(
                                backgroundColor:
                                    AppColors.glowTerracotta.withValues(alpha: 0.7),
                                borderColor: AppColors.glowTerracotta,
                                padding: EdgeInsets.zero,
                                child: SizedBox(
                                  height: buttonHeight,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.share_rounded,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        AppStrings.publishShareEs,
                                        style: TextStyle(
                                          fontSize: bodySize,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
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
}

// ── Generating view ─────────────────────────────────────────────────────────────

class _GeneratingView extends StatelessWidget {
  const _GeneratingView({required this.bodySize});

  final double bodySize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: AppColors.glowTerracotta,
              strokeWidth: 4,
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.publishGeneratingEs,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: bodySize,
                fontWeight: FontWeight.w600,
                color: AppColors.glassText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stats card ──────────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.pageCount,
    required this.chapterCount,
    required this.isSenior,
    required this.bodySize,
  });

  final int pageCount;
  final int chapterCount;
  final bool isSenior;
  final double bodySize;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderColor: AppColors.glowTerracotta,
      child: Row(
        children: [
          _StatItem(
            emoji: '📄',
            count: pageCount,
            label: AppStrings.publishPagesCountEs,
            bodySize: bodySize,
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.glassBorder,
            margin: const EdgeInsets.symmetric(horizontal: 20),
          ),
          _StatItem(
            emoji: '📖',
            count: chapterCount,
            label: AppStrings.publishChaptersCountEs,
            bodySize: bodySize,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.emoji,
    required this.count,
    required this.label,
    required this.bodySize,
  });

  final String emoji;
  final int count;
  final String label;
  final double bodySize;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: bodySize + 4,
              fontWeight: FontWeight.w900,
              color: AppColors.glowTerracotta,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: bodySize - 2,
              color: AppColors.glassTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}
