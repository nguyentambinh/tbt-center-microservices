/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-17
 */

import 'package:audit_service/src/audit_repository.dart';
import 'package:audit_service/src/event_relay.dart';
import 'package:tbt_common/tbt_common.dart';

final database = Database.fromEnvironment();
final auditRepository = PostgresAuditRepository(database);

/// Không cấu hình RabbitMQ thì không phát, bên nhận vẫn đọc định kỳ
final EventRelay? eventRelay = switch (RabbitEventBus.fromEnvironment()) {
  final bus? => EventRelay(PostgresRelayStore(database), bus),
  null => null,
};
