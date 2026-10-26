/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hr_service/src/data/change_request_repository.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /change-requests?status=pending  đề xuất sửa thông tin của nhân viên.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(
      HttpStatus.methodNotAllowed,
      'method_not_allowed',
      'GET only',
    );
  }
  final status = context.request.uri.queryParameters['status'];
  final items = await context.read<ChangeRequestRepository>().list(
    status: status,
  );
  return Response.json(body: {'items': items});
}
