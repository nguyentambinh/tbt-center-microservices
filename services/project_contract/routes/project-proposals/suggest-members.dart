/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:project_contract_service/src/project_view.dart';
import 'package:project_contract_service/src/proposal_ai.dart';
import 'package:project_contract_service/src/proposal_http.dart';
import 'package:project_contract_service/src/proposals.dart';
import 'package:tbt_common/tbt_common.dart';

/// POST /project-proposals/suggest-members  {data, language}: AI chọn nhân
/// viên đủ số tối thiểu của cấp dự án, chia đều theo số dự án đang làm
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  if (sideOf(context.read<Claims>()) == null) {
    return apiError(403, 'forbidden', 'Not allowed');
  }
  final body = await jsonObject(context) ?? const {};
  final data = ProposalData.fromJson(
    body['data'] as Map<String, dynamic>? ?? const {},
  );
  final currency = data.currency ?? Platform.environment['CURRENCY'] ?? 'USD';
  final rate = await context.read<RateLookup>()(currency);
  final language = switch (body['language']) {
    'de' => 'German',
    'pt' => 'Brazilian Portuguese',
    'en' => 'English',
    _ => 'Vietnamese',
  };
  try {
    return Response.json(
      body: await context.read<ProposalAdvisor>().suggestMembers(
        projectName: data.json['name'] as String?,
        valueUsd: (data.json['value'] as double? ?? 0) / rate,
        load: await context.read<ProposalRepository>().activeLoad(),
        language: language,
      ),
    );
  } on InternalCallException catch (e) {
    return apiError(502, 'hr_unavailable', e.message);
  }
}
