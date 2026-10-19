/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-16
 */

import 'dart:convert';

import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

void main() {
  final vnKey = List.filled(32, 1);
  final deKey = List.filled(32, 2);
  final hmac = List.filled(32, 9);
  final hub = FieldCipher({'vn': vnKey, 'de': deKey}, hmac);
  final vnRegion = FieldCipher({'vn': vnKey}, hmac);

  const ctx = 'vn/employees/E1/given_name';

  test('mã hóa rồi giải mã ra đúng chữ, mỗi lần mã ra bản khác nhau', () {
    final a = hub.encrypt('vn', ctx, 'Thư');
    final b = hub.encrypt('vn', ctx, 'Thư');
    expect(a, startsWith(FieldCipher.prefix));
    expect(a, isNot(b), reason: 'nonce ngẫu nhiên');
    expect(vnRegion.decrypt('vn', ctx, a), 'Thư');
  });

  test('sửa một byte của bản mã thì bị phát hiện', () {
    final value = hub.encrypt('vn', ctx, 'Thư');
    final raw = base64.decode(value.substring(FieldCipher.prefix.length));
    raw[raw.length - 1] ^= 1;
    final tampered = '${FieldCipher.prefix}${base64.encode(raw)}';
    expect(
      () => vnRegion.decrypt('vn', ctx, tampered),
      throwsA(isA<CipherTampered>()),
    );
  });

  test('chép bản mã sang bản ghi khác thì không giải mã được', () {
    final value = hub.encrypt('vn', ctx, '18.800.000');
    expect(
      () => vnRegion.decrypt('vn', 'vn/payslips/E2/net_original', value),
      throwsA(isA<CipherTampered>()),
    );
  });

  test('nước không có khóa thì không đọc được dữ liệu cá nhân nước khác', () {
    final value = hub.encrypt('de', 'de/employees/LEN/given_name', 'Lena');
    expect(vnRegion.canRead('de'), isFalse);
    expect(
      vnRegion.decrypt('de', 'de/employees/LEN/given_name', value),
      isNull,
    );
  });

  test('chữ ký HMAC không phụ thuộc thứ tự trường, đổi giá trị là khác', () {
    final a = hub.sign({'id': 'E1', 'status': 'paid'});
    final b = hub.sign({'status': 'paid', 'id': 'E1'});
    final c = hub.sign({'id': 'E1', 'status': 'draft'});
    expect(a, b);
    expect(a, isNot(c));
  });

  test('đổi giá trị Dart sang Firestore và ngược lại giữ nguyên', () {
    final value = {
      's': 'chữ',
      'i': 42,
      'd': 1.5,
      'b': true,
      'n': null,
      'm': {'x': 1},
      'l': [1, 'a'],
    };
    expect(decodeFirestoreValue(encodeFirestoreValue(value)), value);
  });
  group('bảo vệ dòng', () {
    final table = syncTable('payslips')!;
    final at = DateTime.utc(2026, 10, 16);
    const data = {
      'id': 7,
      'employee_id': 'Anh8715OP',
      'period': '2026-10',
      'net_original': 16826000.0,
      'status': 'paid',
    };

    test('mở ra đúng dữ liệu gốc, trường cá nhân không còn là chữ rõ', () {
      final secure = protectRow(
        hub,
        'vn',
        table,
        {'id': 7},
        data,
        syncedAt: at,
      );
      expect(secure.row['employee_id'], startsWith(FieldCipher.prefix));
      expect(secure.row['period'], '2026-10');
      expect(secure.docId, isNot(contains('Anh')));
      final opened = openRow(vnRegion, 'vn', table, secure.docId, secure.row);
      expect(opened.data, data);
      expect(opened.key, {'id': 7});
    });

    test('sửa trường thường (trạng thái) thì chữ ký phát hiện', () {
      final secure = protectRow(
        hub,
        'vn',
        table,
        {'id': 7},
        data,
        syncedAt: at,
      );
      final changed = {...secure.row, 'status': 'draft'};
      expect(
        () => openRow(vnRegion, 'vn', table, secure.docId, changed),
        throwsA(isA<CipherTampered>()),
      );
    });

    test('nước khác đọc được trường thường, không đọc được trường cá nhân', () {
      final deRegion = FieldCipher({'de': deKey}, hmac);
      final secure = protectRow(
        hub,
        'vn',
        table,
        {'id': 7},
        data,
        syncedAt: at,
      );
      final opened = openRow(deRegion, 'vn', table, secure.docId, secure.row);
      expect(opened.readable, isFalse);
      expect(opened.data['period'], '2026-10');
      expect(opened.data['net_original'], startsWith(FieldCipher.prefix));
      expect(opened.key, isNull);
    });
  });
}
