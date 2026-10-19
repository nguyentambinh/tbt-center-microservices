/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dio/dio.dart';

import '../../../../core/error/app_failure.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._dio, {required String baseUrl}) : _root = '$baseUrl/notification/notifications';

  final Dio _dio;
  final String _root;

  @override
  Future<Inbox> inbox() async {
    final d = await _call(() => _dio.get<Map<String, dynamic>>(_root));
    return Inbox(
      unread: (d['unread'] as num?)?.toInt() ?? 0,
      items: [
        for (final n in d['items'] as List)
          AppNotification(
            id: (n as Map<String, dynamic>)['id'] as String,
            kind: n['kind'] as String,
            params: n['params'] as Map<String, dynamic>? ?? const {},
            createdAt: DateTime.parse(n['createdAt'] as String).toLocal(),
            read: n['read'] == true,
          ),
      ],
    );
  }

  @override
  Future<void> markAllRead() => _call(() => _dio.post<Map<String, dynamic>>('$_root/read', data: const {}));

  Future<Map<String, dynamic>> _call(Future<Response<Map<String, dynamic>>> Function() request) async {
    try {
      return (await request()).data ?? const {};
    } on DioException catch (e) {
      throw e.error is AppFailure ? e.error! : AppFailure.fromDio(e);
    }
  }
}
