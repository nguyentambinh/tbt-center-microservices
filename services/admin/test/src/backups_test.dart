/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-11-01
 */

import 'dart:convert';
import 'dart:io';

import 'package:admin_service/src/backups.dart';
import 'package:test/test.dart';

List<int> _file(Map<String, dynamic> content) =>
    gzip.encode(utf8.encode(jsonEncode(content)));

void main() {
  test('đọc bản sao lưu, giữ nguyên chuỗi JSON của từng bảng', () {
    final tables = decodeBackup(
      _file({
        'format': 2,
        'region': 'vn',
        'databases': {
          'hr_db': {'employees': '[{"salary":12345678901234.56}]'},
        },
      }),
      region: 'vn',
    );
    expect(tables['hr_db']!['employees'], '[{"salary":12345678901234.56}]');
  });

  test('bản định dạng cũ lưu danh sách vẫn đọc được', () {
    final tables = decodeBackup(
      _file({
        'region': 'vn',
        'databases': {
          'hr_db': {
            'employees': [
              {'id': 'E1'},
            ],
          },
        },
      }),
      region: 'vn',
    );
    expect(jsonDecode(tables['hr_db']!['employees']!), [
      {'id': 'E1'},
    ]);
  });

  test('bản của nước khác không khôi phục được', () {
    expect(
      () => decodeBackup(
        _file({'region': 'de', 'databases': <String, dynamic>{}}),
        region: 'vn',
      ),
      throwsA(
        isA<BackupViolation>().having((e) => e.code, 'code', 'wrong_region'),
      ),
    );
  });

  test('tệp hỏng báo không đọc được', () {
    expect(
      () => decodeBackup([1, 2, 3], region: 'vn'),
      throwsA(
        isA<BackupViolation>().having((e) => e.code, 'code', 'invalid_backup'),
      ),
    );
  });
}
