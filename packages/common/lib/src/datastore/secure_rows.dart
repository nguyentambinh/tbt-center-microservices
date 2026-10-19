/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-16
 */

import 'dart:convert';

import 'catalog.dart';
import 'field_cipher.dart';

/// Một dòng đã bảo vệ, sẵn sàng ghi vào ngăn (bucket) trên Firestore
typedef SecureRow = ({String docId, String bucket, Map<String, Object?> row});

/// Dòng đọc về và đã kiểm chữ ký
typedef OpenedRow = ({
  String docId,
  Map<String, Object?>? key,
  Map<String, Object?> data,
  bool deleted,
  bool readable,
});

/// Bảo vệ một dòng trước khi rời Hub: mã hóa trường cá nhân, ký HMAC
SecureRow protectRow(
  FieldCipher cipher,
  String region,
  SyncTable table,
  Map<String, Object?> key,
  Map<String, Object?>? data, {
  required DateTime syncedAt,
}) {
  // Mã tài liệu là HMAC của khóa chính, đường dẫn không lộ mã nhân viên
  final docId = cipher
      .sign({'region': region, 'table': table.table, 'key': key})
      .substring(0, 32);
  String ctx(String field) => '$region/${table.table}/$docId/$field';
  final row = <String, Object?>{
    '_key': cipher.encrypt(region, ctx('_key'), jsonEncode(key)),
    '_syncedAt': syncedAt.toUtc().toIso8601String(),
    '_deleted': data == null,
  };
  for (final e in (data ?? const <String, Object?>{}).entries) {
    row[e.key] = table.pii.contains(e.key) && e.value != null
        ? cipher.encrypt(region, ctx(e.key), jsonEncode(e.value))
        : e.value;
  }
  row['_hmac'] = cipher.sign({'path': '$region/${table.table}/$docId', ...row});
  return (docId: docId, bucket: 'b${docId[0]}', row: row);
}

/// Mở một dòng đọc từ Firestore: kiểm chữ ký, giải mã nếu có khóa của nước đó
OpenedRow openRow(
  FieldCipher cipher,
  String region,
  SyncTable table,
  String docId,
  Map<String, Object?> stored,
) {
  final unsigned = Map.of(stored)..remove('_hmac');
  final expected = cipher.sign({
    'path': '$region/${table.table}/$docId',
    ...unsigned,
  });
  if (expected != stored['_hmac']) {
    throw CipherTampered('$region/${table.table}/$docId');
  }
  String ctx(String field) => '$region/${table.table}/$docId/$field';
  final readable = cipher.canRead(region);
  final data = <String, Object?>{};
  for (final e in unsigned.entries) {
    if (e.key.startsWith('_')) continue;
    final v = e.value;
    if (v is String && v.startsWith(FieldCipher.prefix)) {
      final plain = cipher.decrypt(region, ctx(e.key), v);
      data[e.key] = plain == null ? v : jsonDecode(plain);
    } else {
      data[e.key] = v;
    }
  }
  final keyText = cipher.decrypt(
    region,
    ctx('_key'),
    stored['_key']! as String,
  );
  return (
    docId: docId,
    key: keyText == null ? null : jsonDecode(keyText) as Map<String, Object?>,
    data: data,
    deleted: stored['_deleted'] == true,
    readable: readable,
  );
}
