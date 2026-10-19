/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:recruitment_service/src/candidate_repository.dart';
import 'package:recruitment_service/src/imports/draft_rows.dart';
import 'package:recruitment_service/src/imports/import_repository.dart';
import 'package:recruitment_service/src/imports/sheet_reader.dart';
import 'package:tbt_common/tbt_common.dart';

/// Tệp nhập tối đa 2 MB (khoảng vài chục nghìn dòng), đủ cho một đợt tuyển.
const maxImportBytes = 2 * 1024 * 1024;

/// POST /candidate-imports {"fileName": "ung-vien.xlsx", "content": base64}
/// Đọc tệp thành danh sách nháp, chưa ghi hồ sơ nào (R84).
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  final claims = context.read<Claims>();
  if (!claims.hasAnyRole(recruiterRoles)) {
    return apiError(403, 'forbidden', 'HR only');
  }

  final String fileName;
  final List<int> bytes;
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    fileName = (body['fileName'] as String).trim();
    bytes = base64Decode(body['content'] as String);
  } on Object {
    return apiError(
      400,
      'invalid_json',
      'Body must be {"fileName": ..., "content": base64}',
    );
  }
  if (bytes.length > maxImportBytes) {
    return apiError(413, 'file_too_large', 'At most 2 MB per import');
  }

  final List<DraftRow> rows;
  try {
    rows = draftRows(readSheet(fileName, bytes));
  } on SheetFormatException catch (e) {
    return apiError(400, 'unsupported_file', e.message);
  } on MissingNameColumn {
    return apiError(400, 'missing_name_column', 'No full name column');
  } on FormatException {
    return apiError(400, 'unsupported_file', 'File is not UTF-8 text');
  }
  if (rows.isEmpty) return apiError(400, 'empty_file', 'No rows to import');

  final draft = await context.read<ImportRepository>().createDraft(
    sourceType: fileName.toLowerCase().endsWith('.csv') ? 'csv' : 'xlsx',
    sourceRef: fileName,
    importedBy: claims.username,
    rows: rows,
  );
  return Response.json(statusCode: 201, body: draft);
}
