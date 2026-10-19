/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-16
 */

import 'dart:convert';
import 'dart:io';

import '../http/jwt_verifier.dart';

typedef FirestoreDoc = ({String path, Map<String, Object?> fields});

/// Gọi Firestore REST bằng tài khoản dịch vụ (quyền do IAM quyết định)
class FirestoreClient {
  FirestoreClient(Map<String, dynamic> serviceAccount)
    : projectId = serviceAccount['project_id'] as String,
      _email = serviceAccount['client_email'] as String,
      _key = rsaPrivateKeyFromPem(serviceAccount['private_key'] as String);

  /// null nếu chưa có file khóa
  static FirestoreClient? fromFile(String? path) {
    if (path == null || !File(path).existsSync()) return null;
    return FirestoreClient(
      jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>,
    );
  }

  final String projectId;
  final String _email;
  final ({BigInt n, BigInt e, BigInt d}) _key;
  final _http = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  String? _token;
  DateTime _expires = DateTime(2000);

  String get _root =>
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents';

  /// Ghi nhiều tài liệu trong một lần (tối đa 500)
  Future<void> commit(List<FirestoreDoc> docs) async {
    if (docs.isEmpty) return;
    final base = 'projects/$projectId/databases/(default)/documents';
    await _request('POST', Uri.parse('$_root:commit'), {
      'writes': [
        for (final d in docs)
          {
            'update': {
              'name': '$base/${d.path}',
              'fields': _encodeMap(d.fields),
            },
          },
      ],
    });
  }

  /// Ghi từng dòng vào ngăn bằng updateMask: chỉ sửa đúng mục đổi, không cần đọc trước
  Future<void> mergeBuckets(
    List<
      ({
        String path,
        Map<String, Map<String, Object?>> rows,
        Map<String, Object?> top,
      })
    >
    buckets,
  ) async {
    if (buckets.isEmpty) return;
    final base = 'projects/$projectId/databases/(default)/documents';
    await _request('POST', Uri.parse('$_root:commit'), {
      'writes': [
        for (final b in buckets)
          {
            'update': {
              'name': '$base/${b.path}',
              'fields': _encodeMap(_nest(b.top, b.rows)),
            },
            'updateMask': {
              'fieldPaths': [
                ...b.top.keys,
                for (final id in b.rows.keys) 'rows.`$id`',
              ],
            },
          },
      ],
    });
  }

  /// Đọc một tài liệu; null nếu chưa có
  Future<Map<String, Object?>?> get(String path) async {
    final json = await _request('GET', Uri.parse('$_root/$path'));
    final fields = json['fields'] as Map<String, dynamic>?;
    return fields == null ? null : _decodeMap(fields);
  }

  /// Các tài liệu trong collection có _syncedAt mới hơn [after]
  Future<List<FirestoreDoc>> changedSince(
    String parent,
    String collection,
    String after,
  ) async {
    final json = await _requestList(Uri.parse('$_root/$parent:runQuery'), {
      'structuredQuery': {
        'from': [
          {'collectionId': collection},
        ],
        'where': {
          'fieldFilter': {
            'field': {'fieldPath': '_syncedAt'},
            'op': 'GREATER_THAN',
            'value': {'stringValue': after},
          },
        },
      },
    });
    return [
      for (final r in json)
        if ((r as Map<String, dynamic>)['document']
            case final Map<String, dynamic> d)
          (
            path: (d['name'] as String).substring(
              (d['name'] as String).indexOf('/documents/') + 11,
            ),
            fields: _decodeMap(d['fields'] as Map<String, dynamic>? ?? {}),
          ),
    ];
  }

  /// Đọc mọi tài liệu của một collection, theo trang
  Future<List<FirestoreDoc>> list(String collection) async {
    final docs = <FirestoreDoc>[];
    String? page;
    do {
      final url = Uri.parse('$_root/$collection')
          .replace(queryParameters: {'pageSize': '300', 'pageToken': ?page});
      final json = await _request('GET', url);
      for (final d in json['documents'] as List? ?? const []) {
        final doc = d as Map<String, dynamic>;
        final name = doc['name'] as String;
        docs.add((
          path: name.substring(name.indexOf('/documents/') + 11),
          fields: _decodeMap(doc['fields'] as Map<String, dynamic>? ?? {}),
        ));
      }
      page = json['nextPageToken'] as String?;
    } while (page != null);
    return docs;
  }

  Future<List<dynamic>> _requestList(Uri url, Object body) async {
    final request = await _http.postUrl(url);
    request.headers
      ..set(HttpHeaders.authorizationHeader, 'Bearer ${await _accessToken()}')
      ..contentType = ContentType.json;
    request.add(utf8.encode(jsonEncode(body)));
    final response = await request.close().timeout(const Duration(seconds: 30));
    final text = await utf8.decodeStream(response);
    if (response.statusCode >= 300) {
      throw HttpException('Firestore ${response.statusCode}: $text', uri: url);
    }
    return jsonDecode(text) as List<dynamic>;
  }

  Future<Map<String, dynamic>> _request(
    String method,
    Uri url, [
    Object? body,
  ]) async {
    final request = await _http.openUrl(method, url);
    request.headers
      ..set(HttpHeaders.authorizationHeader, 'Bearer ${await _accessToken()}')
      ..contentType = ContentType.json;
    if (body != null) request.add(utf8.encode(jsonEncode(body)));
    final response = await request.close().timeout(const Duration(seconds: 30));
    final text = await utf8.decodeStream(response);
    if (response.statusCode == 404 && method == 'GET') return const {};
    if (response.statusCode >= 300) {
      throw HttpException('Firestore ${response.statusCode}: $text', uri: url);
    }
    return text.isEmpty ? {} : jsonDecode(text) as Map<String, dynamic>;
  }

  /// Token Google sống 1 giờ, xin lại trước khi hết 1 phút
  Future<String> _accessToken() async {
    final now = DateTime.now();
    if (_token != null && now.isBefore(_expires)) return _token!;
    final seconds = now.millisecondsSinceEpoch ~/ 1000;
    String part(Map<String, Object> json) =>
        base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
    final unsigned =
        '${part({'alg': 'RS256', 'typ': 'JWT'})}.${part({'iss': _email, 'scope': 'https://www.googleapis.com/auth/datastore', 'aud': 'https://oauth2.googleapis.com/token', 'iat': seconds, 'exp': seconds + 3600})}';
    final signature = signRs256(_key.n, _key.d, utf8.encode(unsigned));
    final jwt = '$unsigned.${base64Url.encode(signature).replaceAll('=', '')}';
    final request = await _http.postUrl(
      Uri.parse('https://oauth2.googleapis.com/token'),
    );
    request.headers.contentType = ContentType(
      'application',
      'x-www-form-urlencoded',
    );
    request.write(
      'grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer'
      '&assertion=$jwt',
    );
    final response = await request.close();
    final json =
        jsonDecode(await utf8.decodeStream(response)) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw HttpException('Google token ${response.statusCode}: $json');
    }
    _token = json['access_token'] as String;
    _expires = now.add(Duration(seconds: (json['expires_in'] as int) - 60));
    return _token!;
  }
}

/// Khóa có dấu chấm (tables.employees) thành map lồng như Firestore cần
Map<String, Object?> _nest(
  Map<String, Object?> top,
  Map<String, Map<String, Object?>> rows,
) {
  final out = <String, Object?>{if (rows.isNotEmpty) 'rows': rows};
  for (final e in top.entries) {
    final parts = e.key.split('.');
    var node = out;
    for (final p in parts.take(parts.length - 1)) {
      node = (node[p] ??= <String, Object?>{}) as Map<String, Object?>;
    }
    node[parts.last] = e.value;
  }
  return out;
}

Map<String, Object?> _encodeMap(Map<String, Object?> map) => {
  for (final e in map.entries) e.key: encodeFirestoreValue(e.value),
};

Map<String, Object?> _decodeMap(Map<String, dynamic> fields) => {
  for (final e in fields.entries)
    e.key: decodeFirestoreValue(e.value as Map<String, dynamic>),
};

/// Giá trị Dart → dạng Value của Firestore REST
Map<String, Object?> encodeFirestoreValue(Object? v) => switch (v) {
  null => {'nullValue': null},
  final bool b => {'booleanValue': b},
  final int i => {'integerValue': '$i'},
  final double d => {'doubleValue': d},
  final String s => {'stringValue': s},
  final Map<String, Object?> m => {
    'mapValue': {'fields': _encodeMap(m)},
  },
  final List<Object?> l => {
    'arrayValue': {
      'values': [for (final x in l) encodeFirestoreValue(x)],
    },
  },
  _ => {'stringValue': '$v'},
};

/// Value của Firestore REST → giá trị Dart
Object? decodeFirestoreValue(Map<String, dynamic> v) {
  if (v.containsKey('stringValue')) return v['stringValue'];
  if (v.containsKey('integerValue')) return int.parse('${v['integerValue']}');
  if (v.containsKey('doubleValue')) return (v['doubleValue'] as num).toDouble();
  if (v.containsKey('booleanValue')) return v['booleanValue'];
  if (v.containsKey('mapValue')) {
    return _decodeMap(
      (v['mapValue'] as Map<String, dynamic>)['fields']
              as Map<String, dynamic>? ??
          {},
    );
  }
  if (v.containsKey('arrayValue')) {
    return [
      for (final x
          in (v['arrayValue'] as Map<String, dynamic>)['values'] as List? ??
              const [])
        decodeFirestoreValue(x as Map<String, dynamic>),
    ];
  }
  return null;
}
