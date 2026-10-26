/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'dart:io';
import 'dart:math';

import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

final _random = Random.secure();

const _extensions = {'docx', 'pdf', 'jpg', 'jpeg', 'png'};

/// POST /resignations/letter-url  {fileName}: URL ký sẵn để nhân viên tải bản
/// đơn thôi việc (Word, PDF, ảnh) thẳng lên kho của khu vực trước khi gửi đơn
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(HttpStatus.methodNotAllowed, 'method_not_allowed', 'POST');
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
  final suffix = List.generate(
    16,
    (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
  final key = 'resignations/$employee/$suffix.$ext';
  return Response.json(
    body: {
      'uploadUrl': store.uploadUrl(key).toString(),
      'objectKey': key,
      'maxBytes': 10 << 20,
    },
  );
}
