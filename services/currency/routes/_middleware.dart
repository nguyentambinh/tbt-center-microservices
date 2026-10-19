/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

final _db = Database.fromEnvironment();
final _cache = RedisCache.fromEnvironment();

/// Tỷ giá chỉ cấp cho service khác trong khu vực (tính lương, tài chính).
Handler middleware(Handler handler) {
  final internal = handler
      .use(
        cachedGet(
          _cache,
          namespace: 'currency',
          ttl: const Duration(minutes: 5),
        ),
      )
      .use(requireInternalToken());
  return ((RequestContext context) {
        if (context.request.uri.path == '/') return handler(context);
        return internal(context);
      })
      .use(provider<Database>((_) => _db))
      .use(correlationAndErrors())
      .use(metrics('currency'))
      .use(serviceRegistry('currency'));
}
