/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'dart:math';

import 'package:dart_frog/dart_frog.dart';
import 'package:project_contract_service/src/proposal_ai.dart';
import 'package:project_contract_service/src/proposal_http.dart';
import 'package:project_contract_service/src/proposals.dart';
import 'package:tbt_common/tbt_common.dart';

final _random = Random.secure();

const _extensions = {
  'contract': {'pdf', 'docx'},
  'image': {'jpg', 'jpeg', 'png'},
};

/// POST /project-files/upload-url  {fileName, kind: contract|image}: URL ký
/// sẵn để app tải thẳng hợp đồng, ảnh công trình lên kho của khu vực
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  if (sideOf(context.read<Claims>()) != ProposalSide.proposer) {
    return apiError(403, 'forbidden', 'HR, finance or admin only');
  }
  final files = context.read<ProjectFiles?>();
  if (files == null) {
    return apiError(503, 'storage_unavailable', 'S3 is not configured');
  }
  final body = await jsonObject(context);
  final kind = body?['kind'];
  final name = body?['fileName'];
  final ext = name is String && name.contains('.')
      ? name.split('.').last.toLowerCase()
      : '';
  if (kind is! String || !(_extensions[kind]?.contains(ext) ?? false)) {
    return apiError(400, 'invalid_file', 'Contract PDF/Word or JPG/PNG image');
  }
  final suffix = List.generate(
    16,
    (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
  final key = 'proposals/$kind/$suffix.$ext';
  return Response.json(
    body: {
      'uploadUrl': files.uploadUrl(key).toString(),
      'objectKey': key,
      'maxBytes': maxProjectFileBytes,
    },
  );
}
