/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:report_service/src/dependencies.dart';
import 'package:report_service/src/doris_client.dart';
import 'package:report_service/src/projector.dart';
import 'package:tbt_common/tbt_common.dart';

/// Báo cáo hợp nhất toàn tập đoàn: chỉ ban lãnh đạo, quản trị, tài chính.
/// App gọi qua Kong của khu vực (route /report), Kong đã kiểm token.
/// Không giới hạn khu vực vì đây là số liệu tổng hợp của mọi nước.
Handler middleware(Handler handler) {
  final protected = handler
      .use(
        cachedGet(cache, namespace: 'report', ttl: const Duration(minutes: 5)),
      )
      .use(requireClaims(anyRole: const {'executive', 'admin', 'finance'}));
  return ((RequestContext context) {
        if (context.request.uri.path == '/') return handler(context);
        return protected(context);
      })
      .use(provider<DorisClient>((_) => doris))
      .use(provider<Projector>((_) => projector))
      .use(correlationAndErrors())
      .use(metrics('report'))
      .use(serviceRegistry('report'));
}
