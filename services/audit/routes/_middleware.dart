/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:io';

import 'package:audit_service/src/audit_access.dart';
import 'package:audit_service/src/audit_repository.dart';
import 'package:audit_service/src/dependencies.dart';
import 'package:audit_service/src/event_relay.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

final _syncToken = Platform.environment['SYNC_TOKEN'] ?? '';

/// - `/audit-log/...`: người dùng đọc sổ qua Kong khu vực, cần token
///   Keycloak (lãnh đạo, quản trị, kiểm toán).
/// - còn lại: chỉ `sync_worker`, notification và công cụ vận hành có
///   `X-Sync-Token` mới gọi được, trừ GET / để kiểm tra sống.
Handler middleware(Handler handler) {
  final readers = handler.use(requireClaims(anyRole: auditReaderRoles));
  return ((RequestContext context) {
        final path = context.request.uri.path;
        if (path == '/') return handler(context);
        if (path == '/audit-log' || path.startsWith('/audit-log/')) {
          return readers(context);
        }
        final token = context.request.headers['x-sync-token'] ?? '';
        if (_syncToken.isEmpty || !_sameSecret(token, _syncToken)) {
          return apiError(401, 'unauthorized', 'Missing or invalid sync token');
        }
        return handler(context);
      })
      .use(provider<AuditRepository>((_) => auditRepository))
      .use(provider<EventRelay?>((_) => eventRelay))
      .use(correlationAndErrors())
      .use(metrics('audit'))
      .use(serviceRegistry('audit'));
}

/// So sánh không dừng sớm ở ký tự sai đầu tiên, để không đoán dần được token
/// qua thời gian phản hồi.
bool _sameSecret(String a, String b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return diff == 0;
}
