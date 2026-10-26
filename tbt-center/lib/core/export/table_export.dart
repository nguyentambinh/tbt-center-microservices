/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../l10n/app_localizations.dart';
import '../error/error_reporter.dart';

enum ExportFormat { excel, pdf, csv, json }

/// Bảng cần xuất: tiêu đề, cột, các dòng (số giữ kiểu số để Excel cộng được)
class ExportTable {
  const ExportTable({required this.title, required this.headers, required this.rows, this.subtitle});

  final String title;
  final String? subtitle;
  final List<String> headers;
  final List<List<Object?>> rows;

  /// Tên tệp an toàn: bỏ dấu, khoảng trắng thành gạch dưới
  String get fileStem {
    const from = 'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
    const to = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';
    final lower = title.toLowerCase();
    final plain = [for (final c in lower.split('')) from.contains(c) ? to[from.indexOf(c)] : c].join();
    return plain.replaceAll(RegExp('[^a-z0-9]+'), '_').replaceAll(RegExp(r'^_|_$'), '');
  }
}

/// Excel (.xlsx) tối thiểu: một trang tính, dòng tiêu đề in đậm, chữ dạng inline
Uint8List buildXlsx(ExportTable table) {
  String esc(String s) => const HtmlEscape(HtmlEscapeMode.element).convert(s);
  String col(int i) {
    var n = i + 1;
    var s = '';
    while (n > 0) {
      final r = (n - 1) % 26;
      s = String.fromCharCode(65 + r) + s;
      n = (n - 1) ~/ 26;
    }
    return s;
  }

  String cell(int r, int c, Object? v, {bool header = false}) {
    final ref = '${col(c)}${r + 1}';
    final style = header ? ' s="1"' : '';
    if (v is num) return '<c r="$ref"$style><v>$v</v></c>';
    return '<c r="$ref" t="inlineStr"$style><is><t xml:space="preserve">${esc('${v ?? ''}')}</t></is></c>';
  }

  final sheetRows = StringBuffer();
  final all = [table.headers, ...table.rows];
  for (final (r, row) in all.indexed) {
    sheetRows.write('<row r="${r + 1}">');
    for (final (c, v) in row.indexed) {
      sheetRows.write(cell(r, c, v, header: r == 0));
    }
    sheetRows.write('</row>');
  }
  const ns = 'http://schemas.openxmlformats.org';
  final files = {
    '[Content_Types].xml': '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<Types xmlns="$ns/package/2006/content-types">'
        '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
        '<Default Extension="xml" ContentType="application/xml"/>'
        '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'
        '<Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
        '<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>'
        '</Types>',
    '_rels/.rels': '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<Relationships xmlns="$ns/package/2006/relationships">'
        '<Relationship Id="rId1" Type="$ns/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>'
        '</Relationships>',
    'xl/workbook.xml': '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<workbook xmlns="$ns/spreadsheetml/2006/main" xmlns:r="$ns/officeDocument/2006/relationships">'
        '<sheets><sheet name="${esc(table.title.length > 31 ? table.title.substring(0, 31) : table.title)}" sheetId="1" r:id="rId1"/></sheets>'
        '</workbook>',
    'xl/_rels/workbook.xml.rels': '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<Relationships xmlns="$ns/package/2006/relationships">'
        '<Relationship Id="rId1" Type="$ns/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>'
        '<Relationship Id="rId2" Type="$ns/officeDocument/2006/relationships/styles" Target="styles.xml"/>'
        '</Relationships>',
    'xl/styles.xml': '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<styleSheet xmlns="$ns/spreadsheetml/2006/main">'
        '<fonts count="2"><font><sz val="11"/><name val="Calibri"/></font><font><b/><sz val="11"/><name val="Calibri"/></font></fonts>'
        '<fills count="1"><fill><patternFill patternType="none"/></fill></fills>'
        '<borders count="1"><border/></borders>'
        '<cellStyleXfs count="1"><xf/></cellStyleXfs>'
        '<cellXfs count="2"><xf fontId="0"/><xf fontId="1" applyFont="1"/></cellXfs>'
        '</styleSheet>',
    'xl/worksheets/sheet1.xml': '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<worksheet xmlns="$ns/spreadsheetml/2006/main"><sheetData>$sheetRows</sheetData></worksheet>',
  };
  final archive = Archive();
  for (final e in files.entries) {
    archive.addFile(ArchiveFile.string(e.key, e.value));
  }
  return Uint8List.fromList(ZipEncoder().encode(archive));
}

/// PDF khổ A4 ngang, chữ Noto Sans để hiện đủ tiếng Việt, Đức, Bồ Đào Nha
Future<Uint8List> buildPdf(ExportTable table, {required String generatedAt}) async {
  final regular = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
  final bold = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'));
  String text(Object? v) => v is double ? v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2) : '${v ?? ''}';
  final doc = pw.Document(theme: pw.ThemeData.withFont(base: regular, bold: bold));
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(28),
      header: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('TBT Center · ${table.title}', style: pw.TextStyle(font: bold, fontSize: 16)),
          if (table.subtitle != null) pw.Text(table.subtitle!, style: const pw.TextStyle(fontSize: 10)),
          pw.Text(generatedAt, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          pw.SizedBox(height: 8),
        ],
      ),
      footer: (ctx) => pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text('${ctx.pageNumber}/${ctx.pagesCount}', style: const pw.TextStyle(fontSize: 9))),
      build: (_) => [
        pw.TableHelper.fromTextArray(
          headers: table.headers,
          data: [for (final row in table.rows) [for (final v in row) text(v)]],
          headerStyle: pw.TextStyle(font: bold, fontSize: 9),
          cellStyle: const pw.TextStyle(fontSize: 9),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          cellAlignments: {
            for (final (i, v) in (table.rows.isEmpty ? <Object?>[] : table.rows.first).indexed)
              if (v is num) i: pw.Alignment.centerRight,
          },
        ),
      ],
    ),
  );
  return doc.save();
}

/// CSV có BOM để Excel đọc đúng tiếng Việt
Uint8List buildCsv(ExportTable table) {
  String cell(Object? v) {
    final text = v?.toString() ?? '';
    return RegExp('[",\r\n]').hasMatch(text) ? '"${text.replaceAll('"', '""')}"' : text;
  }

  final lines = [for (final row in [table.headers, ...table.rows]) row.map(cell).join(',')];
  return Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode('${lines.join('\r\n')}\r\n')]);
}

/// JSON: mỗi dòng một đối tượng theo tên cột
Uint8List buildJson(ExportTable table) => Uint8List.fromList(utf8.encode(const JsonEncoder.withIndent('  ').convert({
      'title': table.title,
      'subtitle': ?table.subtitle,
      'rows': [for (final row in table.rows) {for (final (i, h) in table.headers.indexed) h: i < row.length ? row[i] : null}],
    })));

/// Tạo tệp rồi mở bảng chia sẻ của máy (lưu vào Tệp, gửi Gmail, Zalo...)
Future<void> exportTable(BuildContext context, ExportTable table, ExportFormat format) async {
  final l10n = AppLocalizations.of(context);
  final generatedAt = l10n.exportedAt(DateTime.now().toString().substring(0, 16));
  try {
    final (bytes, mime, ext) = switch (format) {
      ExportFormat.excel => (buildXlsx(table), 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'xlsx'),
      ExportFormat.pdf => (await buildPdf(table, generatedAt: generatedAt), 'application/pdf', 'pdf'),
      ExportFormat.csv => (buildCsv(table), 'text/csv', 'csv'),
      ExportFormat.json => (buildJson(table), 'application/json', 'json'),
    };
    final name = '${table.fileStem}.$ext';
    await SharePlus.instance.share(ShareParams(
      files: [XFile.fromData(bytes, mimeType: mime, name: name)],
      fileNameOverrides: [name],
      subject: table.title,
    ));
  } on Object catch (e) {
    reportFailure(e);
  }
}

/// Nút xuất Excel, PDF trên thanh tiêu đề
class ExportMenuButton extends StatelessWidget {
  const ExportMenuButton({super.key, required this.table, this.formats = const {ExportFormat.excel, ExportFormat.pdf}});

  /// Dựng bảng lúc bấm, để lấy dữ liệu mới nhất trên màn hình
  final ExportTable? Function() table;

  /// Excel, PDF luôn có; thêm CSV, JSON khi cần dữ liệu thô
  final Set<ExportFormat> formats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton<ExportFormat>(
      tooltip: l10n.export,
      icon: const Icon(Icons.ios_share),
      onSelected: (format) {
        final data = table();
        if (data == null) return;
        exportTable(context, data, format);
      },
      itemBuilder: (_) => [
        PopupMenuItem(value: ExportFormat.excel, child: ListTile(leading: const Icon(Icons.table_chart_outlined), title: Text(l10n.exportExcel))),
        PopupMenuItem(value: ExportFormat.pdf, child: ListTile(leading: const Icon(Icons.picture_as_pdf_outlined), title: Text(l10n.exportPdf))),
        if (formats.contains(ExportFormat.csv)) PopupMenuItem(value: ExportFormat.csv, child: ListTile(leading: const Icon(Icons.grid_on_outlined), title: Text(l10n.exportCsv))),
        if (formats.contains(ExportFormat.json)) PopupMenuItem(value: ExportFormat.json, child: ListTile(leading: const Icon(Icons.data_object), title: Text(l10n.exportJson))),
      ],
    );
  }
}
