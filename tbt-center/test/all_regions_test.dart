/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-11-01
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:tbtcenter/core/network/all_regions.dart';

void main() {
  test('danh sách gộp lại, mỗi dòng ghi nước, tổng cộng dồn', () {
    final merged = mergeRegions({
      'vn': {
        'items': [
          {'id': 'A'},
        ],
        'total': 1,
        'page': 1,
      },
      'de': {
        'items': [
          {'id': 'B'},
          {'id': 'C'},
        ],
        'total': 2,
        'page': 1,
      },
    })!;
    expect((merged['items'] as List).map((e) => (e as Map)['region']), ['vn', 'de', 'de']);
    expect(merged['total'], 3);
  });

  test('bản ghi chỉ có ở một nước thì trả nguyên', () {
    expect(mergeRegions({'de': {'id': 'B'}}), {'id': 'B'});
  });

  test('số liệu riêng từng nước không cộng gộp', () {
    expect(mergeRegions({'vn': {'revenue': 1}, 'de': {'revenue': 2}}), isNull);
  });
}
