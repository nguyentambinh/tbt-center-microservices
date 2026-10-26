/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'dart:async';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hr_service/src/data/resignation_repository.dart';
import 'package:hr_service/src/resignation_analyst.dart';
import 'package:tbt_common/tbt_common.dart';

/// Ai xử lý đơn xin thôi việc
const resignationHandlerRoles = {'hr', 'executive'};

/// GET /resignations?status=: nhân viên xem đơn của mình, HR xem cả khu vực.
/// POST {lastDay, reason}: nhân viên gửi, báo trước ít nhất 30 ngày
Future<Response> onRequest(RequestContext context) async {
  final claims = context.read<Claims>();
  final repository = context.read<ResignationRepository>();
  final handler = claims.hasAnyRole(resignationHandlerRoles);
  switch (context.request.method) {
    case HttpMethod.get:
      if (!handler && claims.employeeId == null) {
        return apiError(403, 'no_employee', 'Account is not an employee');
      }
      final items = await repository.list(
        employeeId: handler ? null : claims.employeeId,
        status: context.request.uri.queryParameters['status'],
      );
      // Phân tích của AI chỉ dành cho cấp trên, người gửi không thấy
      return Response.json(
        body: {
          'items': [
            for (final r in items)
              if (handler && r['employeeId'] != claims.employeeId)
                r
              else
                {...r, 'aiAnalysis': null, 'aiSource': null},
          ],
        },
      );
    case HttpMethod.post:
      final employee = claims.employeeId;
      if (employee == null) {
        return apiError(403, 'no_employee', 'Account is not an employee');
      }
      final Map<String, dynamic> body;
      try {
        body = await context.request.json() as Map<String, dynamic>;
      } on Object {
        return apiError(400, 'invalid_json', 'Body must be a JSON object');
      }
      final lastDay = DateTime.tryParse('${body['lastDay']}');
      final reason = (body['reason'] as String?)?.trim() ?? '';
      if (lastDay == null || reason.isEmpty) {
        return apiError(400, 'invalid_resignation', 'lastDay, reason needed');
      }
      // Bắt buộc nộp bản đơn (Word, PDF, ảnh) đã tải lên kho của khu vực
      final key = body['letterKey'];
      final name = body['letterName'];
      final store = context.read<ObjectStore?>();
      if (key is! String ||
          !key.startsWith('resignations/$employee/') ||
          name is! String) {
        return apiError(400, 'letter_required', 'Attach the letter');
      }
      if (store == null) {
        return apiError(503, 'storage_unavailable', 'S3 is not configured');
      }
      final List<int>? bytes;
      try {
        bytes = await store.read(key);
      } on Exception {
        return apiError(413, 'file_too_large', 'Files must be at most 10 MB');
      }
      if (bytes == null) {
        return apiError(400, 'letter_required', 'Letter was not uploaded');
      }
      final mime = sniffMimeType(bytes);
      if (mime == null || !resignationLetterTypes.contains(mime)) {
        return apiError(415, 'invalid_file', 'Word, PDF, JPG or PNG only');
      }
      try {
        final created = await repository.create(
          employee,
          lastDay: lastDay,
          reason: reason,
          letter: (key: key, name: name.trim(), mime: mime),
        );
        // AI đọc đơn sau khi trả kết quả, người gửi không phải chờ
        final analyst = context.read<ResignationAnalyst>();
        if (analyst.configured) {
          unawaited(
            _analyze(
              analyst,
              repository,
              created,
              (mime: mime, bytes: bytes, name: name),
              '${body['language'] ?? 'vi'}',
            ),
          );
        }
        return Response.json(statusCode: 201, body: created);
      } on ResignationViolation catch (e) {
        return apiError(
          e.code == 'notice_too_short' ? 400 : 409,
          e.code,
          e.message,
        );
      }
    case HttpMethod.put ||
        HttpMethod.patch ||
        HttpMethod.delete ||
        HttpMethod.head ||
        HttpMethod.options:
      return apiError(405, 'method_not_allowed', 'GET, POST only');
  }
}

Future<void> _analyze(
  ResignationAnalyst analyst,
  ResignationRepository repository,
  Map<String, dynamic> resignation,
  ({String mime, List<int> bytes, String name}) letter,
  String language,
) async {
  try {
    final result = await analyst.analyze(
      statedReason: resignation['reason'] as String,
      lastDay: resignation['lastDay'] as String,
      letter: letter,
      language: switch (language) {
        'en' => 'English',
        'de' => 'German',
        'pt' => 'Portuguese',
        _ => 'Vietnamese',
      },
    );
    if (result != null) {
      await repository.saveAnalysis(
        resignation['id'] as int,
        result.analysis,
        source: result.source,
      );
    }
  } on Object catch (e) {
    stderr.writeln('AI chưa đọc được đơn thôi việc: $e');
  }
}
