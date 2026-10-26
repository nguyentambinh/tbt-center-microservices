/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'dart:math';

import 'package:attendance_service/src/access.dart';
import 'package:attendance_service/src/domain/leave_request.dart';
import 'package:attendance_service/src/leave_files.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

final _random = Random.secure();

const _extensions = {'docx', 'pdf', 'jpg', 'jpeg', 'png'};

/// POST /leave-requests/{id}/files/upload-url  {fileName}: URL ký sẵn để
/// người gửi đơn tải minh chứng (Word, PDF, ảnh) thẳng lên kho của khu vực
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  final employee = context.read<Claims>().employeeId;
  final store = context.read<ObjectStore?>();
  if (employee == null) {
    return apiError(403, 'no_employee', 'Account is not linked to an employee');
  }
  if (store == null) {
    return apiError(503, 'storage_unavailable', 'S3 is not configured');
  }
  final Object? name;
  try {
    name = (await context.request.json() as Map<String, dynamic>)['fileName'];
  } on Object {
    return apiError(400, 'invalid_json', 'Body must be {"fileName": "..."}');
  }
  final ext = name is String && name.contains('.')
      ? name.split('.').last.toLowerCase()
      : '';
  if (!_extensions.contains(ext)) {
    return apiError(400, 'invalid_file', 'Word, PDF, JPG or PNG only');
  }
  try {
    await context.read<LeaveFileRepository>().checkOwnPending(id, employee);
  } on LeaveRuleViolation catch (e) {
    return e.code == 'not_found'
        ? apiError(404, e.code, e.message)
        : ruleError(e);
  }
  final suffix = List.generate(
    16,
    (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
  final key = 'leaves/$id/$suffix.$ext';
  return Response.json(
    body: {
      'uploadUrl': store.uploadUrl(key).toString(),
      'objectKey': key,
      'maxBytes': 10 << 20,
    },
  );
}
