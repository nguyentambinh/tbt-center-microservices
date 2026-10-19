/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-17
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Index theo ngày, ví dụ tbt-requests-2026.10.17
String requestIndexFor(DateTime t) {
  final u = t.toUtc();
  String two(int n) => n.toString().padLeft(2, '0');
  return 'tbt-requests-${u.year}.${two(u.month)}.${two(u.day)}';
}

/// Thân lệnh `_bulk` của Elasticsearch: mỗi tài liệu hai dòng
String bulkBody(List<Map<String, dynamic>> docs) {
  final b = StringBuffer();
  for (final d in docs) {
    final at = DateTime.parse(d['@timestamp'] as String);
    b
      ..writeln(
        jsonEncode({
          'create': {'_index': requestIndexFor(at)},
        }),
      )
      ..writeln(jsonEncode(d));
  }
  return b.toString();
}

/// Log request của mọi service gom về Elasticsearch, tra theo correlation id
/// để thấy một thao tác đi qua những service nào (thay cho tracing đầy đủ)
class RequestLog {
  RequestLog(this.baseUrl, {required this.region, HttpClient? http})
    : _http =
          http ??
          (HttpClient()..connectionTimeout = const Duration(seconds: 3));

  static RequestLog? fromEnvironment([Map<String, String>? env]) {
    final e = env ?? Platform.environment;
    final url = e['ELASTICSEARCH_URL'];
    if (url == null || url.isEmpty) return null;
    return RequestLog(
      Uri.parse(url.endsWith('/') ? url : '$url/'),
      region: e['REGION'] ?? 'hub',
    );
  }

  static final RequestLog? shared = fromEnvironment();

  final Uri baseUrl;
  final String region;
  final HttpClient _http;
  final _queue = <Map<String, dynamic>>[];
  Timer? _timer;
  var _templateReady = false;

  /// Hàng đợi tối đa; Elasticsearch chết lâu thì bỏ bớt log cũ, không ăn hết RAM
  static const maxQueued = 5000;

  void add({
    required String service,
    required String method,
    required String path,
    required int status,
    required Duration took,
    String? correlationId,
    String? username,
  }) {
    if (_queue.length >= maxQueued) _queue.removeAt(0);
    _queue.add({
      '@timestamp': DateTime.now().toUtc().toIso8601String(),
      'service': service,
      'region': region,
      'host': Platform.localHostname,
      'method': method,
      'path': path,
      'status': status,
      'ms': took.inMicroseconds / 1000,
      if (correlationId != null && correlationId != '-')
        'correlation_id': correlationId,
      'user': ?username,
    });
    _timer ??= Timer(const Duration(seconds: 2), _flush);
  }

  Future<void> _flush() async {
    _timer = null;
    if (_queue.isEmpty) return;
    final batch = List<Map<String, dynamic>>.of(_queue);
    _queue.clear();
    try {
      if (!_templateReady) await _ensureTemplate();
      final status = await _send(
        'POST',
        '_bulk',
        bulkBody(batch),
        ndjson: true,
      );
      if (status >= 300) throw HttpException('bulk $status');
    } on Object catch (e) {
      // Trả lô về hàng đợi, lần sau gửi lại
      _queue.insertAll(0, batch.take(maxQueued - _queue.length));
      stderr.writeln('Gửi log sang Elasticsearch lỗi: $e');
      _timer ??= Timer(const Duration(seconds: 15), _flush);
    }
  }

  // Kiểu dữ liệu từng trường và chính sách xóa index cũ sau 7 ngày
  Future<void> _ensureTemplate() async {
    await _send(
      'PUT',
      '_ilm/policy/tbt-requests',
      jsonEncode({
        'policy': {
          'phases': {
            'delete': {
              'min_age': '7d',
              'actions': {'delete': <String, dynamic>{}},
            },
          },
        },
      }),
    );
    await _send(
      'PUT',
      '_index_template/tbt-requests',
      jsonEncode({
        'index_patterns': ['tbt-requests-*'],
        'template': {
          'settings': {
            'number_of_replicas': 0,
            'index.lifecycle.name': 'tbt-requests',
          },
          'mappings': {
            'properties': {
              '@timestamp': {'type': 'date'},
              'service': {'type': 'keyword'},
              'region': {'type': 'keyword'},
              'host': {'type': 'keyword'},
              'method': {'type': 'keyword'},
              'path': {'type': 'keyword'},
              'status': {'type': 'integer'},
              'ms': {'type': 'float'},
              'correlation_id': {'type': 'keyword'},
              'user': {'type': 'keyword'},
            },
          },
        },
      }),
    );
    _templateReady = true;
  }

  Future<int> _send(
    String method,
    String path,
    String body, {
    bool ndjson = false,
  }) async {
    final request = await _http.openUrl(method, baseUrl.resolve(path));
    request.headers.set(
      'content-type',
      ndjson ? 'application/x-ndjson' : 'application/json',
    );
    request.add(utf8.encode(body));
    final response = await request.close().timeout(const Duration(seconds: 10));
    await response.drain<void>();
    return response.statusCode;
  }
}
