import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/models/book_page_model.dart';
import '../../core/providers/persona_provider.dart';
import '../../core/providers/streak_provider.dart';
import '../../core/providers/user_name_provider.dart';
import '../../core/providers/xp_provider.dart';
import '../../core/services/book_pdf_service.dart';
import '../../core/theme/app_theme.dart';
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

      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/${_titleCtrl.text.trim().replaceAll(' ', '_')}.pdf',
      );
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: _titleCtrl.text.trim(),
      );
      if (mounted) _onSuccess();
    } catch (_) {
      if (mounted) setState(() => _status = _PublishStatus.ready);
    }
  }

  void _onSuccess() {
    ref.read(xpProvider.notifier).addXp(20);
    ref.read(streakProvider.notifier).recordPractice();
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
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.deepBlue,
        foregroundColor: Colors.white,
        title: Text(
          '${AppStrings.publishTitleEs}  •  ${AppStrings.publishTitleEn}',
          style: TextStyle(
            fontSize: isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.body,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _status == _PublishStatus.generating
          ? _GeneratingView(bodySize: bodySize)
          : SingleChildScrollView(
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

                  // Title field
                  Text(
                    AppStrings.publishBookTitleLabelEs,
                    style: TextStyle(
                      fontSize: bodySize,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _titleCtrl,
                    style: TextStyle(
                      fontSize: bodySize,
                      color: AppColors.darkText,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.unselectedBorder,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.deepBlue,
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

                  // Title
                  Text(
                    AppStrings.publishStatsCardTitleEs,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
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
                  SizedBox(
                    height: buttonHeight,
                    child: OutlinedButton.icon(
                      onPressed: _openPreview,
                      icon: const Icon(Icons.visibility_outlined),
                      label: Text(
                        AppStrings.publishPreviewEs,
                        style: TextStyle(
                          fontSize: bodySize,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.deepBlue,
                        side: const BorderSide(
                          color: AppColors.deepBlue,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Download button
                  SizedBox(
                    height: buttonHeight,
                    child: ElevatedButton.icon(
                      onPressed: _download,
                      icon: const Icon(Icons.download_rounded),
                      label: Text(
                        AppStrings.publishDownloadEs,
                        style: TextStyle(
                          fontSize: bodySize,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.deepBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Share button
                  SizedBox(
                    height: buttonHeight,
                    child: ElevatedButton.icon(
                      onPressed: _share,
                      icon: const Icon(Icons.share_rounded),
                      label: Text(
                        AppStrings.publishShareEs,
                        style: TextStyle(
                          fontSize: bodySize,
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
                  const SizedBox(height: 32),
                ],
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
              color: AppColors.terracotta,
              strokeWidth: 4,
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.publishGeneratingEs,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: bodySize,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.terracotta.withValues(alpha: 0.4)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
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
            color: AppColors.unselectedBorder,
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
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: bodySize + 4,
              fontWeight: FontWeight.w900,
              color: AppColors.terracotta,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: bodySize - 2,
              color: AppColors.darkText.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
