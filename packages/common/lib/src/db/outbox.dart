/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';

import 'package:postgres/postgres.dart';

/// Ghi sự kiện vào bảng `outbox` trong cùng giao dịch với dữ liệu nghiệp vụ.
/// Giao dịch thành công thì chắc chắn có sự kiện, thất bại thì cả hai cùng
/// không có; `sync_worker` đọc bảng này đẩy lên Hub sau.
Future<void> addOutboxEvent(
  TxSession tx, {
  required String aggregate,
  required String aggregateId,
  required String eventType,
  required Map<String, Object?> payload,
}) async {
  await tx.execute(
    Sql.named(
      'insert into outbox (aggregate, aggregate_id, event_type, payload) '
      'values (@aggregate, @id, @type, @payload::jsonb)',
    ),
    parameters: {
      'aggregate': aggregate,
      'id': aggregateId,
      'type': eventType,
      'payload': jsonEncode(payload),
    },
  );
}
