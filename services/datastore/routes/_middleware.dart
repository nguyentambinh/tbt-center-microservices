/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-16
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:datastore_service/src/dependencies.dart';
import 'package:datastore_service/src/ingestor.dart';
import 'package:tbt_common/tbt_common.dart';

/// Nước gửi dữ liệu, suy ra từ token (không tin trường region trong body)
typedef SourceRegion = String;

Handler middleware(Handler handler) {
  final internal = handler.use(_regionToken());
  return ((RequestContext context) {
        if (context.request.uri.path == '/') return handler(context);
        if (isInternalPath(context.request.uri)) return internal(context);
        return apiError(404, 'not_found', 'Not found');
      })
      .use(provider<Ingestor>((_) => ingestor))
      .use(correlationAndErrors())
      .use(metrics('datastore'))
      .use(serviceRegistry('datastore'));
}

Middleware _regionToken() =>
    (handler) => (context) {
      final given = context.request.headers['x-datastore-token'] ?? '';
      for (final e in regionTokens.entries) {
        if (sameSecret(given, e.key)) {
          return handler(context.provide<SourceRegion>(() => e.value));
        }
      }
      return apiError(401, 'unauthorized', 'Datastore token required');
    };
