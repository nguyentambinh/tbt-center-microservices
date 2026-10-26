/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'dart:math';

import 'package:dart_frog/dart_frog.dart';
import 'package:recruitment_service/src/candidate_repository.dart';
import 'package:recruitment_service/src/interviews.dart';
import 'package:recruitment_service/src/responses.dart';
import 'package:recruitment_service/src/storage/cv_storage.dart';
import 'package:tbt_common/tbt_common.dart';

final _random = Random.secure();

/// POST /candidates/{id}/minutes/upload-url  {fileName}: URL ký sẵn để HR tải
/// biên bản phỏng vấn (Word, Excel) thẳng lên kho của khu vực
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  final claims = context.read<Claims>();
  if (!claims.hasAnyRole(recruiterRoles)) {
    return apiError(403, 'forbidden', 'HR only');
  }
  final name = (await jsonObject(context))?['fileName'];
  final ext = name is String && name.contains('.')
      ? name.split('.').last.toLowerCase()
      : '';
  if (!minutesExtensions.contains(ext)) {
    return apiError(400, 'invalid_file', 'Minutes must be Word or Excel');
  }
  final suffix = List.generate(
    16,
    (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
  final key = 'minutes/$id/$suffix.$ext';
  return Response.json(
    body: {
      'uploadUrl': context.read<CvStorage>().uploadUrl(key).toString(),
      'objectKey': key,
      'maxBytes': maxCvBytes,
    },
  );
}
