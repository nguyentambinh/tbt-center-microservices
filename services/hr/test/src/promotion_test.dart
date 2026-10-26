/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'package:hr_service/src/data/organization_repository.dart';
import 'package:test/test.dart';

Matcher _code(String code) => throwsA(
  isA<OrganizationViolation>().having((e) => e.code, 'code', code),
);

void main() {
  test('chỉ thăng lên chức vụ cấp cao hơn, có trong danh mục', () {
    expect(
      () => checkPromotion(currentLevel: 2, targetLevel: 4),
      returnsNormally,
    );
    expect(
      () => checkPromotion(currentLevel: 3, targetLevel: 3),
      _code('not_higher_position'),
    );
    expect(
      () => checkPromotion(currentLevel: 4, targetLevel: 2),
      _code('not_higher_position'),
    );
    expect(
      () => checkPromotion(currentLevel: 1, targetLevel: null),
      _code('unknown_position'),
    );
  });
}
