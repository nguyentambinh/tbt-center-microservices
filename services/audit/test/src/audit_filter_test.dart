/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:audit_service/src/audit_reader.dart';
import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

void main() {
  test('người đọc một nước chỉ xem nước mình, tập đoàn xem mọi nước', () {
    Claims who(List<String> roles) => Claims({
      'region': 'vn',
      'realm_access': {'roles': roles},
    });
    expect(readerRegion(who(['admin'])), 'vn');
    expect(readerRegion(who(['executive', 'group'])), isNull);
    expect(readerRegion(who(['auditor'])), isNull);
    expect(filterFrom({'region': 'de'}, region: 'vn')!.region, 'vn');
  });

  test('lọc theo ngày thì tính tới hết ngày cuối', () {
    final f = filterFrom({'from': '2026-10-01', 'to': '2026-10-25'})!;
    expect(f.exactTime, isFalse);
    expect(f.toExclusive, DateTime(2026, 10, 26));
  });

  test('lọc theo giờ phút thì đúng thời điểm', () {
    final f = filterFrom({
      'from': '2026-10-25T08:00',
      'to': '2026-10-25T17:30',
      'service': 'payroll',
      'anomaly': 'after_hours',
    })!;
    expect(f.exactTime, isTrue);
    expect(f.toExclusive, DateTime(2026, 10, 25, 17, 30));
    expect(f.toJson(), containsPair('service', 'payroll'));
  });

  test('loại bất thường lạ thì từ chối bộ lọc', () {
    expect(filterFrom({'anomaly': 'weekend'}), isNull);
    expect(filterFrom({'anomaly': 'any'}), isNotNull);
  });
}
