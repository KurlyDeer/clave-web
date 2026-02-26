import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/book_page_model.dart';
import '../../l10n/app_strings.dart';

/// Generates a bilingual PDF book from a list of [BookPage] entries.
class BookPdfService {
  BookPdfService._();

  static const PdfColor _terracotta = PdfColor.fromInt(0xFFD35400);
  static const PdfColor _deepBlue = PdfColor.fromInt(0xFF2E86C1);
  static const PdfColor _cream = PdfColor.fromInt(0xFFFDF6EC);
  static const PdfColor _darkText = PdfColor.fromInt(0xFF1A1A1A);
  static const PdfColor _lightText = PdfColor.fromInt(0xFFFFFFFF);

  static const int _chapterSize = 5;

  static Future<pw.Document> generate({
    required List<BookPage> pages,
    required String authorName,
    required String bookTitle,
  }) async {
    final doc = pw.Document();

    final now = DateTime.now();
    final dateStr =
        '${now.day}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    final chapterCount = (pages.length / _chapterSize).ceil();

    // Cover page
    doc.addPage(_buildCoverPage(
      bookTitle: bookTitle,
      authorName: authorName.isNotEmpty ? authorName : 'Estudiante',
      date: dateStr,
    ));

    // Chapter sections
    for (int chapter = 0; chapter < chapterCount; chapter++) {
      final start = chapter * _chapterSize;
      final end = (start + _chapterSize).clamp(0, pages.length);
      final chapterPages = pages.sublist(start, end);

      // Chapter divider
      doc.addPage(_buildChapterDivider(chapter + 1));

      // Content pages
      for (int i = 0; i < chapterPages.length; i++) {
        doc.addPage(
          _buildContentPage(
            page: chapterPages[i],
            pageNumber: start + i + 1,
            totalPages: pages.length,
          ),
        );
      }
    }

    return doc;
  }

  // ── Cover page ──────────────────────────────────────────────────────────────

  static pw.Page _buildCoverPage({
    required String bookTitle,
    required String authorName,
    required String date,
  }) {
    return pw.Page(
      pageFormat: PdfPageFormat.letter,
      build: (ctx) => pw.Container(
        color: _cream,
        child: pw.Stack(
          children: [
            // Top accent bar
            pw.Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: pw.Container(height: 12, color: _terracotta),
            ),
            // Bottom accent bar
            pw.Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: pw.Container(height: 12, color: _deepBlue),
            ),
            // Main content
            pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'English Bridge',
                    style: pw.TextStyle(
                      font: pw.Font.helveticaBold(),
                      fontSize: 14,
                      color: _terracotta,
                      letterSpacing: 3,
                    ),
                  ),
                  pw.SizedBox(height: 40),
                  pw.Text(
                    bookTitle,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      font: pw.Font.timesBold(),
                      fontSize: 36,
                      color: _darkText,
                    ),
                  ),
                  pw.SizedBox(height: 30),
                  pw.Container(
                    width: 80,
                    height: 2,
                    color: _terracotta,
                  ),
                  pw.SizedBox(height: 30),
                  // Seal circle
                  pw.Container(
                    width: 120,
                    height: 120,
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      border: pw.Border.all(color: _terracotta, width: 3),
                      color: PdfColors.white,
                    ),
                    child: pw.Center(
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text(
                            AppStrings.publishSealText,
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              font: pw.Font.helveticaBold(),
                              fontSize: 9,
                              color: _terracotta,
                              letterSpacing: 1,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Container(
                            width: 60,
                            height: 1,
                            color: _terracotta,
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'English Bridge',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              font: pw.Font.helvetica(),
                              fontSize: 8,
                              color: _deepBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 40),
                  pw.Text(
                    '${AppStrings.publishAutorLabelEs}: $authorName',
                    style: pw.TextStyle(
                      font: pw.Font.timesItalic(),
                      fontSize: 18,
                      color: _darkText,
                    ),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Text(
                    date,
                    style: pw.TextStyle(
                      font: pw.Font.helvetica(),
                      fontSize: 12,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Chapter divider ─────────────────────────────────────────────────────────

  static pw.Page _buildChapterDivider(int chapterNumber) {
    return pw.Page(
      pageFormat: PdfPageFormat.letter,
      build: (ctx) => pw.Container(
        color: _cream,
        child: pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Container(
                width: double.infinity,
                height: 3,
                color: _terracotta,
                margin: const pw.EdgeInsets.symmetric(horizontal: 60),
              ),
              pw.SizedBox(height: 24),
              pw.Text(
                '${AppStrings.publishChapterLabelEs} $chapterNumber',
                style: pw.TextStyle(
                  font: pw.Font.timesBold(),
                  fontSize: 42,
                  color: _terracotta,
                ),
              ),
              pw.SizedBox(height: 24),
              pw.Container(
                width: double.infinity,
                height: 3,
                color: _deepBlue,
                margin: const pw.EdgeInsets.symmetric(horizontal: 60),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Content page ────────────────────────────────────────────────────────────

  static pw.Page _buildContentPage({
    required BookPage page,
    required int pageNumber,
    required int totalPages,
  }) {
    return pw.Page(
      pageFormat: PdfPageFormat.letter,
      margin: const pw.EdgeInsets.all(48),
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          // Header bar
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: pw.BoxDecoration(
              color: _terracotta,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              page.promptEn,
              style: pw.TextStyle(
                font: pw.Font.helveticaBold(),
                fontSize: 10,
                color: _lightText,
              ),
              maxLines: 1,
            ),
          ),
          pw.SizedBox(height: 20),
          // Two-column layout
          pw.Expanded(
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Left column — English text
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.only(bottom: 6),
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(
                              color: _deepBlue,
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: pw.Text(
                          'In English',
                          style: pw.TextStyle(
                            font: pw.Font.helveticaBold(),
                            fontSize: 11,
                            color: _deepBlue,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      pw.Text(
                        page.text,
                        style: pw.TextStyle(
                          font: pw.Font.times(),
                          fontSize: 13,
                          color: _darkText,
                          lineSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),
                // Divider
                pw.Container(
                  width: 1,
                  margin: const pw.EdgeInsets.symmetric(horizontal: 16),
                  color: PdfColors.grey300,
                ),
                // Right column — Spanish prompt
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.only(bottom: 6),
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(
                              color: _terracotta,
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: pw.Text(
                          'Mi Pensamiento Original',
                          style: pw.TextStyle(
                            font: pw.Font.helveticaBold(),
                            fontSize: 11,
                            color: _terracotta,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      pw.Text(
                        page.promptEs,
                        style: pw.TextStyle(
                          font: pw.Font.timesItalic(),
                          fontSize: 12,
                          color: PdfColors.grey700,
                          lineSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Footer with page number
          pw.Container(
            padding: const pw.EdgeInsets.only(top: 12),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: PdfColors.grey300),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  '— $pageNumber —',
                  style: pw.TextStyle(
                    font: pw.Font.helvetica(),
                    fontSize: 10,
                    color: PdfColors.grey500,
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
