/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:recruitment_service/src/candidate_repository.dart';
import 'package:recruitment_service/src/positions.dart';
import 'package:tbt_common/tbt_common.dart';

/// HR, quản trị khu vực mở và sửa vị trí tuyển dụng
const positionManagerRoles = {'hr'};

/// Đọc thân yêu cầu thêm, sửa vị trí; `null` nếu sai dạng
Future<PositionInput?> positionInputFrom(RequestContext context) async {
  final Object? body;
  try {
    body = await context.request.json();
  } on Object {
    return null;
  }
  if (body is! Map<String, dynamic>) return null;
  final headcount = body['headcount'];
  if (body['title'] is! String || headcount is! num) return null;
  return PositionInput(
    title: body['title'] as String,
    headcount: headcount.toInt(),
    department: body['department'] as String?,
    description: body['description'] as String? ?? '',
    requirements: body['requirements'] as String? ?? '',
    status: body['status'] as String? ?? 'open',
  );
}

Response positionViolation(CandidateRuleViolation e) => apiError(
  e.code == 'title_exists' || e.code == 'headcount_below_hired' ? 409 : 400,
  e.code,
  e.message,
);
