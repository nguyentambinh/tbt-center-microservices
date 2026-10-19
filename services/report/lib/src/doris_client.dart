/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

class DorisException implements Exception {
  const DorisException(this.message);

  final String message;

  @override
  String toString() => 'Doris: $message';
}

/// Nói chuyện với Doris qua HTTP, không cần thư viện MySQL:
/// - đọc bằng SQL API của FE (`/api/query/...`);
/// - ghi bằng Stream Load của BE, mỗi lô có nhãn riêng. Doris từ chối nhãn
///   đã dùng, nên nạp lại cùng một lô sự kiện không bị ghi trùng.
class DorisClient {
  DorisClient({
    required this.feUrl,
    required this.beUrl,
    this.user = 'root',
    this.password = '',
    this.maxConcurrent = 2,
  });

  final Uri feUrl;
  final Uri beUrl;
  final String user;
  final String password;

  /// SQL API của FE chỉ có 2 luồng, gửi nhiều câu hơn cùng lúc thì bị từ chối
  final int maxConcurrent;
  final _http = HttpClient()..connectionTimeout = const Duration(seconds: 5);
  var _active = 0;
  final _waiting = Queue<Completer<void>>();

  Future<T> _slot<T>(Future<T> Function() body) async {
    if (_active >= maxConcurrent) {
      final turn = Completer<void>();
      _waiting.add(turn);
      await turn.future;
    }
    _active++;
    try {
      return await body();
    } finally {
      _active--;
      if (_waiting.isNotEmpty) _waiting.removeFirst().complete();
    }
  }

  String get _auth => 'Basic ${base64Encode(utf8.encode('$user:$password'))}';

  /// Chạy một câu SQL, trả các dòng dạng map tên cột → giá trị.
  Future<List<Map<String, dynamic>>> query(
    String sql, {
    String database = 'tbt_report',
  }) => _slot(() => _query(sql, database));

  Future<List<Map<String, dynamic>>> _query(String sql, String database) async {
    final request = await _http.postUrl(
      feUrl.resolve('/api/query/default_cluster/$database'),
    );
    request.headers
      ..set('authorization', _auth)
      ..contentType = ContentType.json;
    request.add(utf8.encode(jsonEncode({'stmt': sql})));
    final response = await request.close();
    final json =
        jsonDecode(await utf8.decodeStream(response)) as Map<String, dynamic>;
    if (json['code'] != 0) {
      throw DorisException('${json['msg']}: ${json['data']}');
    }
    final data = json['data'];
    if (data is! Map || data['type'] != 'result_set') return const [];
    final columns = [
      for (final c in data['meta'] as List) (c as Map)['name'] as String,
    ];
    return [
      for (final row in data['data'] as List)
        {
          for (var i = 0; i < columns.length; i++) columns[i]: (row as List)[i],
        },
    ];
  }

  /// Nạp các dòng JSON vào bảng. Trả `false` nếu nhãn đã được nạp trước đó.
  Future<bool> load(
    String table,
    List<Map<String, Object?>> rows, {
    required String label,
    String database = 'tbt_report',
  }) async {
    if (rows.isEmpty) return true;
    final request = await _http.putUrl(
      beUrl.resolve('/api/$database/$table/_stream_load'),
    );
    request.headers
      ..set('authorization', _auth)
      ..set('label', label)
      ..set('format', 'json')
      ..set('strip_outer_array', 'true')
      ..contentType = ContentType.json;
    request.add(utf8.encode(jsonEncode(rows)));
    final response = await request.close();
    final json =
        jsonDecode(await utf8.decodeStream(response)) as Map<String, dynamic>;
    switch (json['Status']) {
      case 'Success' || 'Publish Timeout':
        return true;
      case 'Label Already Exists':
        return false;
      default:
        throw DorisException('${json['Status']}: ${json['Message']}');
    }
  }
}
