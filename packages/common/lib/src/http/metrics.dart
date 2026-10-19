/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dart_frog/dart_frog.dart';

import '../observability/request_log.dart';
import '../resilience/circuit_breaker.dart';
import 'claims.dart';

/// Số liệu của một service cho Prometheus (R45, R69): số request theo nhóm
/// đường dẫn và mã trả về, thời gian xử lý, trạng thái các Circuit Breaker.
/// Giữ trong bộ nhớ, khởi động lại thì đếm lại từ 0 (Prometheus tự hiểu).
class ServiceMetrics {
  ServiceMetrics._();

  static final instance = ServiceMetrics._();

  /// Mốc thời gian xử lý (giây) của histogram.
  static const buckets = [0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0];

  final _requests = <String, int>{};
  final _cache = <String, int>{};

  /// Đếm cache trúng (hit) hay trượt (miss) theo nhóm
  void cacheResult(String namespace, {required bool hit}) {
    final key = 'namespace="$namespace",result="${hit ? 'hit' : 'miss'}"';
    _cache[key] = (_cache[key] ?? 0) + 1;
  }

  final _bucketCounts = List<int>.filled(buckets.length, 0);
  var _durationSum = 0.0;
  var _durationCount = 0;
  final _breakers = <String, CircuitBreaker>{};

  // Đổi giá trị nghĩa là service vừa khởi động lại
  final _startedAt = DateTime.now();

  void watch(CircuitBreaker breaker) => _breakers[breaker.name] = breaker;

  void record({
    required String method,
    required String route,
    required int status,
    required Duration took,
  }) {
    final key = 'method="$method",route="$route",status="$status"';
    _requests[key] = (_requests[key] ?? 0) + 1;
    final seconds = took.inMicroseconds / 1e6;
    for (var i = 0; i < buckets.length; i++) {
      if (seconds <= buckets[i]) _bucketCounts[i]++;
    }
    _durationSum += seconds;
    _durationCount++;
  }

  /// Định dạng text của Prometheus.
  String render(String service) {
    final s = 'service="$service"';
    final out = StringBuffer()
      ..writeln('# HELP tbt_process_start_time_seconds Lúc tiến trình bắt đầu.')
      ..writeln('# TYPE tbt_process_start_time_seconds gauge')
      ..writeln(
        'tbt_process_start_time_seconds{$s} '
        '${_startedAt.millisecondsSinceEpoch ~/ 1000}',
      )
      ..writeln('# HELP tbt_http_requests_total Requests theo nhóm đường dẫn.')
      ..writeln('# TYPE tbt_http_requests_total counter');
    for (final e in _requests.entries) {
      out.writeln('tbt_http_requests_total{$s,${e.key}} ${e.value}');
    }
    out
      ..writeln('# HELP tbt_http_request_seconds Thời gian xử lý request.')
      ..writeln('# TYPE tbt_http_request_seconds histogram');
    for (var i = 0; i < buckets.length; i++) {
      out.writeln(
        'tbt_http_request_seconds_bucket{$s,le="${buckets[i]}"} '
        '${_bucketCounts[i]}',
      );
    }
    out
      ..writeln('tbt_http_request_seconds_bucket{$s,le="+Inf"} $_durationCount')
      ..writeln('tbt_http_request_seconds_sum{$s} $_durationSum')
      ..writeln('tbt_http_request_seconds_count{$s} $_durationCount')
      ..writeln('# HELP tbt_circuit_state 0 đóng, 1 thử lại, 2 đang ngắt.')
      ..writeln('# TYPE tbt_circuit_state gauge');
    for (final b in _breakers.values) {
      final value = switch (b.state) {
        CircuitState.closed => 0,
        CircuitState.halfOpen => 1,
        CircuitState.open => 2,
      };
      out.writeln('tbt_circuit_state{$s,name="${b.name}"} $value');
    }
    out
      ..writeln(
        '# HELP tbt_cache_requests_total Đọc cache Redis: hit hoặc miss.',
      )
      ..writeln('# TYPE tbt_cache_requests_total counter');
    for (final e in _cache.entries) {
      out.writeln('tbt_cache_requests_total{$s,${e.key}} ${e.value}');
    }
    return out.toString();
  }

  /// Chỉ dùng trong test.
  void reset() {
    _requests.clear();
    _bucketCounts.fillRange(0, buckets.length, 0);
    _durationSum = 0;
    _durationCount = 0;
    _breakers.clear();
  }
}

/// Đo mọi request và mở `GET /metrics` cho Prometheus. Đặt ngoài cùng để đo
/// được cả request bị chặn vì thiếu token. `/metrics` chỉ gọi được trong mạng
/// nội bộ: Kong chặn mọi đường `.../metrics` từ ngoài vào.
Middleware metrics(String service) {
  return (handler) {
    return (context) async {
      final uri = context.request.uri;
      if (uri.path == '/metrics') {
        return Response(
          body: ServiceMetrics.instance.render(service),
          headers: {'content-type': 'text/plain; version=0.0.4'},
        );
      }
      final started = DateTime.now();
      final response = await handler(context);
      final took = DateTime.now().difference(started);
      ServiceMetrics.instance.record(
        method: context.request.method.value,
        // Chỉ lấy đoạn đầu đường dẫn để số nhãn không tăng theo id.
        route: uri.pathSegments.isEmpty ? '/' : '/${uri.pathSegments.first}',
        status: response.statusCode,
        took: took,
      );
      // Health check gọi `/` liên tục, không ghi log
      if (uri.path != '/') {
        final headers = context.request.headers;
        RequestLog.shared?.add(
          service: service,
          method: context.request.method.value,
          path: uri.path,
          status: response.statusCode,
          took: took,
          // Lấy từ câu trả lời: request không có id thì middleware vừa sinh
          correlationId:
              response.headers['x-correlation-id'] ??
              headers['x-correlation-id'],
          username: Claims.fromAuthorization(headers['authorization'])
              ?.username,
        );
      }
      return response;
    };
  };
}
