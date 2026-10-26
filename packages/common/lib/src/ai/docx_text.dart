/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'dart:convert';

import 'package:archive/archive.dart';

/// Chữ trong tệp Word (.docx): ghép các đoạn `w:t`, mỗi `w:p` một dòng
String docxText(List<int> bytes) {
  final archive = ZipDecoder().decodeBytes(bytes);
  final file = archive.findFile('word/document.xml');
  if (file == null) return '';
  final xml = utf8.decode(file.content as List<int>, allowMalformed: true);
  final lines = <String>[];
  for (final p in RegExp('<w:p[ >].*?</w:p>', dotAll: true).allMatches(xml)) {
    final text = RegExp(
      '<w:t[^>]*>([^<]*)</w:t>',
    ).allMatches(p.group(0)!).map((m) => m.group(1)!).join();
    if (text.trim().isNotEmpty) lines.add(_unescape(text.trim()));
  }
  return lines.join('\n');
}

String _unescape(String s) => s
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&apos;', "'")
    .replaceAll('&amp;', '&');
