/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:hr_service/src/cache.dart';
import 'package:hr_service/src/data/organization_repository.dart';
import 'package:hr_service/src/responses.dart';
import 'package:tbt_common/tbt_common.dart';

/// POST /departments/{id}/dissolve  {reasonCode, note, mergeInto}
/// Còn người thì phải chọn phòng nhận lại (mergeInto)
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return methodNotAllowed('POST only');
  }
  final body = await jsonBody(context);
  try {
    final result = await context.read<OrganizationRepository>().dissolve(
      id,
      reasonCode: body['reasonCode'] as String? ?? '',
      dissolvedBy: actor(context),
      note: body['note'] as String?,
      mergeInto: body['mergeInto'] as String?,
    );
    await invalidateCache(cache, employeesCache);
    return Response.json(body: result);
  } on OrganizationViolation catch (e) {
    return violationResponse(e);
  }
}
