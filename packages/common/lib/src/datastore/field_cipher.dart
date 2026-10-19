/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-16
 */

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';

/// Bản mã bị sửa, sai chỗ hoặc sai khóa
class CipherTampered implements Exception {
  const CipherTampered(this.context);

  final String context;

  @override
  String toString() => 'Không giải mã được $context (bị sửa hoặc sai khóa)';
}

/// Mã hóa từng trường bằng AES-256-GCM, mỗi nước một khóa riêng
class FieldCipher {
  FieldCipher(Map<String, List<int>> keys, List<int> hmacKey)
    : _keys = {
        for (final e in keys.entries) e.key: Uint8List.fromList(e.value),
      },
      _hmac = Hmac(sha256, hmacKey);

  /// Hub: đọc DATA_KEY_<NƯỚC>; khu vực: chỉ DATA_KEY của chính mình
  factory FieldCipher.fromEnvironment() {
    final env = Platform.environment;
    final keys = <String, List<int>>{};
    for (final e in env.entries) {
      final m = RegExp(r'^DATA_KEY_([A-Z]{2})$').firstMatch(e.key);
      if (m != null) keys[m[1]!.toLowerCase()] = base64.decode(e.value);
    }
    final own = env['DATA_KEY'];
    if (own != null && own.isNotEmpty) {
      keys[env['REGION'] ?? 'vn'] = base64.decode(own);
    }
    return FieldCipher(keys, base64.decode(env['DATA_HMAC_KEY'] ?? ''));
  }

  static const prefix = 'enc:v1:';

  final Map<String, Uint8List> _keys;
  final Hmac _hmac;

  bool canRead(String region) => _keys.containsKey(region);

  /// Ngữ cảnh (nước/bảng/mã/trường) gắn vào bản mã, chép sang chỗ khác là hỏng
  String encrypt(String region, String context, String plain) {
    final key = _keys[region];
    if (key == null) throw StateError('Không có khóa của $region');
    final nonce = Uint8List.fromList(
      List.generate(12, (_) => Random.secure().nextInt(256)),
    );
    final out = _gcm(
      true,
      key,
      nonce,
      context,
    ).process(Uint8List.fromList(utf8.encode(plain)));
    return '$prefix${base64.encode([...nonce, ...out])}';
  }

  /// null nếu không có khóa của nước đó (dữ liệu cá nhân nước khác)
  String? decrypt(String region, String context, String value) {
    final key = _keys[region];
    if (key == null) return null;
    final raw = base64.decode(value.substring(prefix.length));
    try {
      final plain = _gcm(
        false,
        key,
        Uint8List.fromList(raw.sublist(0, 12)),
        context,
      ).process(Uint8List.fromList(raw.sublist(12)));
      return utf8.decode(plain);
    } on Object {
      throw CipherTampered(context);
    }
  }

  /// Chữ ký HMAC của cả bản ghi, khóa sắp theo thứ tự để ổn định
  String sign(Map<String, Object?> fields) =>
      _hmac.convert(utf8.encode(jsonEncode(_canonical(fields)))).toString();

  // Sắp khóa ở mọi tầng: Firestore có thể trả map theo thứ tự khác
  static Object? _canonical(Object? v) => switch (v) {
    final Map<String, Object?> m => {
      for (final k in m.keys.toList()..sort()) k: _canonical(m[k]),
    },
    final List<Object?> l => [for (final x in l) _canonical(x)],
    _ => v,
  };

  GCMBlockCipher _gcm(
    bool encrypt,
    Uint8List key,
    Uint8List nonce,
    String aad,
  ) => GCMBlockCipher(AESEngine())
    ..init(
      encrypt,
      AEADParameters(
        KeyParameter(key),
        128,
        nonce,
        Uint8List.fromList(utf8.encode(aad)),
      ),
    );
}
