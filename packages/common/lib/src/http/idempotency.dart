/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dart_frog/dart_frog.dart';

import '../db/database.dart';
import 'claims.dart';
import 'middleware.dart';

/// Chống ghi trùng: request ghi có header `Idempotency-Key` chỉ được xử lý một lần.
/// Gửi lại cùng key (app bấm hai lần, mạng chập chờn gửi lại) thì trả đúng
/// kết quả lần đầu, không ghi thêm. Cần bảng `idempotency_keys` trong DB.
Middleware idempotency(Database db) {
  const writeMethods = {
    HttpMethod.post,
    HttpMethod.put,
    HttpMethod.patch,
    HttpMethod.delete,
  };

  return (handler) {
    return (context) async {
      final request = context.request;
      final key = request.headers['idempotency-key'];
      if (key == null || !writeMethods.contains(request.method)) {
        return handler(context);
      }

      // Gắn key với người gọi để người khác không đoán key mà lấy được kết quả.
      final subject = Claims.fromAuthorization(request.headers['authorization'])
          ?.subject;
      final scopedKey = '${subject ?? '-'}:$key';

      final claimed = await db.execute(
        'insert into idempotency_keys (key, method, path) '
        'values (@key, @method, @path) on conflict do nothing returning key',
        params: {
          'key': scopedKey,
          'method': request.method.value,
          'path': request.uri.path,
        },
      );

      if (claimed.isEmpty) {
        final saved = await db.query(
          'select status, body from idempotency_keys where key = @key',
          params: {'key': scopedKey},
          fromPrimary: true,
        );
        final status = saved.first['status'] as int?;
        if (status == null) {
          return apiError(409, 'in_progress', 'Request is being processed');
        }
        return Response(
          statusCode: status,
          body: saved.first['body'] as String?,
          headers: {
            'content-type': 'application/json',
            'idempotent-replay': 'true',
          },
        );
      }

      try {
        final response = await handler(context);
        final body = await response.body();
        if (response.statusCode >= 500) {
          await _release(db, scopedKey);
        } else {
          await db.execute(
            'update idempotency_keys set status = @status, body = @body '
            'where key = @key',
            params: {
              'status': response.statusCode,
              'body': body,
              'key': scopedKey,
            },
          );
        }
        return Response(
          statusCode: response.statusCode,
          body: body,
          headers: response.headers,
        );
      } on Object {
        // Lỗi server thì nhả key để app gửi lại được.
        await _release(db, scopedKey);
        rethrow;
      }
    };
  };
}

Future<void> _release(Database db, String key) => db.execute(
  'delete from idempotency_keys where key = @key',
  params: {'key': key},
);
