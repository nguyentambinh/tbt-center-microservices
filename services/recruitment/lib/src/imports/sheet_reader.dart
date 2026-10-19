/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

/// Tệp không phải CSV hay Excel đọc được.
class SheetFormatException implements Exception {
  const SheetFormatException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Đọc bảng tính thành các dòng chữ. Hỗ trợ `.csv` (UTF-8, dấu `,` hoặc `;`)
/// và `.xlsx` (sheet đầu tiên).
List<List<String>> readSheet(String fileName, List<int> bytes) {
  final name = fileName.toLowerCase();
  if (name.endsWith('.csv')) return readCsv(utf8.decode(bytes));
  if (name.endsWith('.xlsx')) return readXlsx(bytes);
  throw const SheetFormatException('Only .csv and .xlsx files are supported');
}

List<List<String>> readCsv(String text) {
  // Excel ở máy cài tiếng Việt, tiếng Đức hay lưu CSV bằng dấu chấm phẩy.
  final firstLine = text.split('\n').first;
  final separator = firstLine.split(';').length > firstLine.split(',').length
      ? ';'
      : ',';
  final rows = <List<String>>[];
  var row = <String>[];
  final cell = StringBuffer();
  var quoted = false;
  final content = text.startsWith('﻿') ? text.substring(1) : text;

  for (var i = 0; i < content.length; i++) {
    final c = content[i];
    if (quoted) {
      if (c == '"' && i + 1 < content.length && content[i + 1] == '"') {
        cell.write('"');
        i++;
      } else if (c == '"') {
        quoted = false;
      } else {
        cell.write(c);
      }
    } else if (c == '"') {
      quoted = true;
    } else if (c == separator) {
      row.add(cell.toString().trim());
      cell.clear();
    } else if (c == '\n' || c == '\r') {
      if (c == '\r' && i + 1 < content.length && content[i + 1] == '\n') i++;
      row.add(cell.toString().trim());
      cell.clear();
      rows.add(row);
      row = <String>[];
    } else {
      cell.write(c);
    }
  }
  if (cell.isNotEmpty || row.isNotEmpty) {
    row.add(cell.toString().trim());
    rows.add(row);
  }
  return rows.where((r) => r.any((c) => c.isNotEmpty)).toList();
}

/// `.xlsx` là tệp zip chứa XML: chữ dùng chung ở `sharedStrings.xml`, ô của
/// sheet đầu ở `worksheets/sheet1.xml`.
List<List<String>> readXlsx(List<int> bytes) {
  final Archive zip;
  try {
    zip = ZipDecoder().decodeBytes(bytes);
  } on Object {
    throw const SheetFormatException('File is not a valid .xlsx');
  }
  String? text(String path) {
    final file = zip.findFile(path);
    return file == null ? null : utf8.decode(file.content);
  }

  final sheet = text('xl/worksheets/sheet1.xml');
  if (sheet == null) {
    throw const SheetFormatException('The workbook has no first sheet');
  }
  final shared = [
    for (final si in XmlDocument.parse(
      text('xl/sharedStrings.xml') ?? '<sst/>',
    ).findAllElements('si'))
      si.findAllElements('t').map((t) => t.innerText).join(),
  ];

  final rows = <List<String>>[];
  for (final r in XmlDocument.parse(sheet).findAllElements('row')) {
    final row = <String>[];
    for (final c in r.findElements('c')) {
      final column = _column(c.getAttribute('r') ?? '');
      while (row.length < column) {
        row.add('');
      }
      final value = switch (c.getAttribute('t')) {
        's' => shared[int.parse(c.getElement('v')?.innerText ?? '0')],
        'inlineStr' => c.findAllElements('t').map((t) => t.innerText).join(),
        _ => c.getElement('v')?.innerText ?? '',
      };
      row.add(value.trim());
    }
    if (row.any((v) => v.isNotEmpty)) rows.add(row);
  }
  return rows;
}

/// `C7` → 2 (cột thứ ba, đếm từ 0).
int _column(String ref) {
  var n = 0;
  for (final unit in ref.codeUnits) {
    if (unit < 65 || unit > 90) break;
    n = n * 26 + unit - 64;
  }
  return n == 0 ? 0 : n - 1;
}
