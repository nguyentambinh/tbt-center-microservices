/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:recruitment_service/src/candidate_repository.dart';
import 'package:recruitment_service/src/dependencies.dart';
import 'package:recruitment_service/src/identity/hiring.dart';
import 'package:recruitment_service/src/imports/import_repository.dart';
import 'package:recruitment_service/src/storage/cv_storage.dart';
import 'package:tbt_common/tbt_common.dart';

/// Ứng viên chỉ vào `/me`; HR, quản lý vào `/candidates`.
/// Kiểm vai trò ở từng route. `/internal/...` chỉ cho service khác trong
/// khu vực, cần `X-Internal-Token`.
Handler middleware(Handler handler) {
  ServiceMetrics.instance
    ..watch(claudeBreaker)
    ..watch(geminiBreaker);
  final internal = handler.use(requireInternalToken());
  final protected = handler
      .use(idempotency(database))
      .use(
        requireClaims(
          region: Platform.environment['REGION'],
          allowNoRegion: true,
        ),
      );

  return ((RequestContext context) {
        final uri = context.request.uri;
        if (uri.path == '/') return handler(context);
        if (isInternalPath(uri)) return internal(context);
        return protected(context);
      })
      .use(provider<CandidateRepository>((_) => candidateRepository))
      .use(provider<ImportRepository>((_) => importRepository))
      .use(provider<CvStorage>((_) => cvStorage))
      .use(provider<Hiring>((_) => hiring))
      .use(correlationAndErrors())
      .use(metrics('recruitment'))
      .use(serviceRegistry('recruitment'));
}
