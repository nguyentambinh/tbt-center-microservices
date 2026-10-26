/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:attendance_service/src/access.dart';
import 'package:attendance_service/src/domain/leave_request.dart';
import 'package:attendance_service/src/leave_files.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET: minh chứng của đơn kèm URL tạm để xem bản gốc (người gửi, quản lý).
/// POST {objectKey, fileName}: báo đã tải xong; AI đọc lại mọi minh chứng
/// và tóm ý chính cho HR
Future<Response> onRequest(RequestContext context, String id) async {
  final claims = context.read<Claims>();
  final repository = context.read<LeaveFileRepository>();
  final store = context.read<ObjectStore?>();
  final leave = await repository.leave(id);
  if (leave == null) return apiError(404, 'not_found', 'No leave request $id');
  final own = leave['employeeId'] == claims.employeeId;
  if (!own && !claims.hasAnyRole(managerRoles)) {
    return apiError(403, 'forbidden', 'Not your leave request');
  }

  if (context.request.method == HttpMethod.get) {
    return Response.json(body: {'items': await _files(repository, store, id)});
  }
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'GET or POST');
  }
  if (!own) return apiError(403, 'forbidden', 'Only the requester adds files');
  if (store == null) {
    return apiError(503, 'storage_unavailable', 'S3 is not configured');
  }

  final Map<String, dynamic> body;
  try {
    body = await context.request.json() as Map<String, dynamic>;
  } on Object {
    return apiError(400, 'invalid_json', 'Body must be a JSON object');
  }
  final key = body['objectKey'];
  final name = body['fileName'];
  if (key is! String || !key.startsWith('leaves/$id/') || name is! String) {
    return apiError(400, 'invalid_object', 'Unknown file object');
  }
  final List<int>? bytes;
  try {
    bytes = await store.read(key);
  } on Exception {
    return apiError(413, 'file_too_large', 'Files must be at most 10 MB');
  }
  if (bytes == null) return apiError(400, 'file_missing', 'File not uploaded');
  final mime = sniffMimeType(bytes);
  if (mime == null || !leaveFileTypes.contains(mime)) {
    return apiError(415, 'invalid_file', 'Word, PDF, JPG or PNG only');
  }
  try {
    await repository.checkOwnPending(id, claims.employeeId!);
    await repository.attach(
      id,
      mimeType: mime,
      objectKey: key,
      fileName: name.trim(),
    );
  } on LeaveRuleViolation catch (e) {
    return ruleError(e);
  }

  final all = <({String mimeType, List<int> bytes, String name})>[];
  for (final f in await repository.files(id)) {
    final content = f.objectKey == key ? bytes : await store.read(f.objectKey);
    if (content != null) {
      all.add((mimeType: f.mimeType, bytes: content, name: f.fileName));
    }
  }
  final language = switch (context.request.uri.queryParameters['language']) {
    'de' => 'German',
    'pt' => 'Brazilian Portuguese',
    'en' => 'English',
    _ => 'Vietnamese',
  };
  final summary = await context.read<LeaveSummarizer>().summarize(
    leave: leave,
    files: all,
    language: language,
  );
  if (summary != null) {
    await repository.saveSummary(
      id,
      summary.summary,
      source: summary.source,
    );
  }
  return Response.json(
    statusCode: 201,
    body: {
      'items': await _files(repository, store, id),
      'aiSummary': summary?.summary,
      'aiSource': summary?.source,
    },
  );
}

Future<List<Map<String, dynamic>>> _files(
  LeaveFileRepository repository,
  ObjectStore? store,
  String id,
) async => [
  for (final f in await repository.files(id))
    {
      'id': f.id,
      'fileName': f.fileName,
      'mimeType': f.mimeType,
      'uploadedAt': f.uploadedAt.toUtc().toIso8601String(),
      'url': ?store?.downloadUrl(f.objectKey).toString(),
    },
];
