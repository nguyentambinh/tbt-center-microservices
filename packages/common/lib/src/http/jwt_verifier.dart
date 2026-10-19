/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

/// Lấy bộ khóa công khai (JWKS) của Keycloak.
typedef JwksFetcher = Future<Map<String, dynamic>> Function(Uri url);

/// Service tự kiểm token lần hai, không chỉ tin Kong (R41, R43): chữ ký RS256
/// theo khóa công khai của Keycloak, người phát hành, thời hạn. Lỡ có ai vào
/// được mạng nội bộ và gọi thẳng service, token tự chế vẫn bị từ chối.
class JwtVerifier {
  JwtVerifier({
    required this.jwksUrl,
    required this.issuer,
    JwksFetcher? fetch,
    DateTime Function()? clock,
  }) : _fetch = fetch ?? _httpFetch,
       _now = clock ?? DateTime.now;

  /// Cấu hình qua `JWT_JWKS_URL`, `JWT_ISSUER`. Không có thì trả `null`:
  /// service chạy riêng lúc dev, test vẫn đọc token như trước.
  static JwtVerifier? fromEnvironment() {
    final env = Platform.environment;
    final url = env['JWT_JWKS_URL'];
    final issuer = env['JWT_ISSUER'];
    if (url == null || url.isEmpty || issuer == null) return null;
    return JwtVerifier(jwksUrl: Uri.parse(url), issuer: issuer);
  }

  final Uri jwksUrl;
  final String issuer;
  final JwksFetcher _fetch;
  final DateTime Function() _now;

  final _keys = <String, ({BigInt n, BigInt e})>{};
  DateTime? _fetchedAt;

  /// Keycloak đổi khóa thì token mới mang `kid` lạ: tải lại bộ khóa, nhưng
  /// không quá một lần mỗi 30 giây để token rác không làm dội tải Keycloak.
  static const _refetchAfter = Duration(seconds: 30);

  /// Lý do từ chối, `null` nếu token hợp lệ.
  Future<String?> check(String token) async {
    final parts = token.split('.');
    if (parts.length != 3) return 'malformed';
    final Map<String, dynamic> header;
    final Map<String, dynamic> payload;
    final List<int> signature;
    try {
      header = _json(parts[0]);
      payload = _json(parts[1]);
      signature = base64Url.decode(base64Url.normalize(parts[2]));
    } on FormatException {
      return 'malformed';
    }

    if (header['alg'] != 'RS256') return 'unsupported_alg';
    if (payload['iss'] != issuer) return 'wrong_issuer';
    final exp = payload['exp'];
    final nowSeconds = _now().millisecondsSinceEpoch ~/ 1000;
    if (exp is! int || exp <= nowSeconds) return 'expired';

    final key = await _key(header['kid'] as String?);
    if (key == null) return 'unknown_key';
    final signed = ascii.encode('${parts[0]}.${parts[1]}');
    return verifyRs256(key.n, key.e, signed, signature)
        ? null
        : 'bad_signature';
  }

  Future<({BigInt n, BigInt e})?> _key(String? kid) async {
    if (kid == null) return null;
    final cached = _keys[kid];
    if (cached != null) return cached;
    final last = _fetchedAt;
    if (last != null && _now().difference(last) < _refetchAfter) return null;

    _fetchedAt = _now();
    final jwks = await _fetch(jwksUrl);
    _keys.clear();
    for (final k in jwks['keys'] as List) {
      final key = k as Map<String, dynamic>;
      if (key['kty'] != 'RSA' || key['use'] == 'enc') continue;
      _keys[key['kid'] as String] = (
        n: _bigInt(key['n'] as String),
        e: _bigInt(key['e'] as String),
      );
    }
    return _keys[kid];
  }

  static Map<String, dynamic> _json(String part) =>
      jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(part))))
          as Map<String, dynamic>;

  static BigInt _bigInt(String base64UrlValue) =>
      bytesToBigInt(base64Url.decode(base64Url.normalize(base64UrlValue)));

  static Future<Map<String, dynamic>> _httpFetch(Uri url) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);
    try {
      final response = await (await client.getUrl(url)).close();
      if (response.statusCode != 200) {
        throw HttpException('JWKS trả ${response.statusCode}', uri: url);
      }
      return jsonDecode(await utf8.decodeStream(response))
          as Map<String, dynamic>;
    } finally {
      client.close();
    }
  }
}

/// Phần đầu cố định của chữ ký PKCS#1 v1.5 với SHA-256 (RFC 8017, mục 9.2).
const _sha256DigestInfo = [
  0x30, 0x31, 0x30, 0x0d, 0x06, 0x09, 0x60, 0x86, 0x48, 0x01, 0x65, 0x03, //
  0x04, 0x02, 0x01, 0x05, 0x00, 0x04, 0x20,
];

/// Kiểm chữ ký RS256: giải chữ ký bằng khóa công khai (s^e mod n) rồi so với
/// khối mong đợi `00 01 FF..FF 00 DigestInfo SHA-256(message)`.
/// Chỉ cần khóa công khai, không có bí mật nào trong phép tính này.
bool verifyRs256(BigInt n, BigInt e, List<int> message, List<int> signature) {
  final length = (n.bitLength + 7) ~/ 8;
  if (signature.length != length) return false;
  final s = bytesToBigInt(signature);
  if (s >= n) return false;
  final decoded = bigIntToBytes(s.modPow(e, n), length);

  final hash = sha256.convert(message).bytes;
  final padding = length - 3 - _sha256DigestInfo.length - hash.length;
  if (padding < 8) return false;
  final expected = [
    0x00,
    0x01,
    ...List.filled(padding, 0xff),
    0x00,
    ..._sha256DigestInfo,
    ...hash,
  ];
  var diff = 0;
  for (var i = 0; i < length; i++) {
    diff |= decoded[i] ^ expected[i];
  }
  return diff == 0;
}

BigInt bytesToBigInt(List<int> bytes) {
  var result = BigInt.zero;
  for (final b in bytes) {
    result = (result << 8) | BigInt.from(b);
  }
  return result;
}

List<int> bigIntToBytes(BigInt value, int length) {
  final bytes = List<int>.filled(length, 0);
  var v = value;
  for (var i = length - 1; i >= 0; i--) {
    bytes[i] = (v & BigInt.from(0xff)).toInt();
    v >>= 8;
  }
  return bytes;
}

/// Ký RS256 bằng khóa bí mật (m^d mod n), dùng khi service tự xin token Google
List<int> signRs256(BigInt n, BigInt d, List<int> message) {
  final length = (n.bitLength + 7) ~/ 8;
  final hash = sha256.convert(message).bytes;
  final padding = length - 3 - _sha256DigestInfo.length - hash.length;
  final block = [
    0x00,
    0x01,
    ...List.filled(padding, 0xff),
    0x00,
    ..._sha256DigestInfo,
    ...hash,
  ];
  return bigIntToBytes(bytesToBigInt(block).modPow(d, n), length);
}

/// Đọc n, e, d từ khóa PEM PKCS#8 ("BEGIN PRIVATE KEY")
({BigInt n, BigInt e, BigInt d}) rsaPrivateKeyFromPem(String pem) {
  final body = pem
      .replaceAll(RegExp('-----[A-Z ]+-----'), '')
      .replaceAll(RegExp(r'\s'), '');
  final der = base64.decode(body);
  // PrivateKeyInfo: SEQ { version, algorithm, OCTET STRING { RSAPrivateKey } }
  final info = _Der(der)..enter();
  info
    ..skip()
    ..skip();
  final rsa = _Der(info.octets())..enter();
  rsa.skip();
  return (n: rsa.integer(), e: rsa.integer(), d: rsa.integer());
}

// Đọc DER tối giản, chỉ đủ cho khóa RSA
class _Der {
  _Der(this._bytes);

  final List<int> _bytes;
  var _pos = 0;

  int _length() {
    final first = _bytes[_pos++];
    if (first < 0x80) return first;
    var length = 0;
    for (var i = 0; i < (first & 0x7f); i++) {
      length = (length << 8) | _bytes[_pos++];
    }
    return length;
  }

  void enter() {
    _pos++;
    _length();
  }

  void skip() {
    _pos++;
    final length = _length();
    _pos += length;
  }

  List<int> octets() {
    _pos++;
    final length = _length();
    return _bytes.sublist(_pos, _pos += length);
  }

  BigInt integer() => bytesToBigInt(octets());
}
