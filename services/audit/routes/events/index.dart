/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:async';

import 'package:audit_service/src/audit_repository.dart';
import 'package:audit_service/src/event_relay.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

/// POST /events  {"events": [...]}  sync_worker gửi một lô sự kiện outbox.
/// GET  /events?limit=&region=     xem sự kiện mới nhất.
/// GET  /events?region=&after=&limit=  đọc tiếp từ sau sự kiện `after`.
Future<Response> onRequest(RequestContext context) async {
  final repository = context.read<AuditRepository>();
  switch (context.request.method) {
    case HttpMethod.post:
      final List<IncomingEvent> events;
      try {
        final body = await context.request.json() as Map<String, dynamic>;
        events = [
          for (final e in body['events'] as List)
            IncomingEvent.fromJson(e as Map<String, dynamic>),
        ];
      } on Object {
        return apiError(
          400,
          'invalid_events',
          'Body must be {"events": [...]}',
        );
      }
      final added = await repository.append(events);
      // Có sự kiện mới thì phát lên RabbitMQ ngay
      if (added > 0) unawaited(context.read<EventRelay?>()?.kick());
      return Response.json(
        body: {'received': events.length, 'added': added},
      );
    case HttpMethod.get:
      final query = context.request.uri.queryParameters;
      final limit = (int.tryParse(query['limit'] ?? '') ?? 50).clamp(1, 500);
      final after = int.tryParse(query['after'] ?? '');
      final region = query['region'];
      if (after != null) {
        if (region == null) {
          return apiError(400, 'region_required', 'after needs region');
        }
        final items = await repository.since(
          after,
          region: region,
          limit: limit,
        );
        return Response.json(body: {'items': items});
      }
      final items = await repository.latest(
        limit: limit,
        region: region,
      );
      return Response.json(body: {'items': items});
    case HttpMethod.put ||
        HttpMethod.patch ||
        HttpMethod.delete ||
        HttpMethod.head ||
        HttpMethod.options:
      return apiError(405, 'method_not_allowed', 'GET, POST only');
  }
}
