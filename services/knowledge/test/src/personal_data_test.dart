/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'dart:convert';

import 'package:knowledge_service/src/qa/personal_data.dart';
import 'package:test/test.dart';

void main() {
  test('dữ liệu gửi AI: bỏ link tệp, danh sách giữ 31 phần tử', () {
    final text = compactJson({
      'payslips': [for (var i = 0; i < 40; i++) {'period': '2026-$i'}],
      'photoUrl': 'https://s3/anh.jpg',
      'salary': {'baseSalary': 15000000},
    });
    final data = jsonDecode(text) as Map<String, dynamic>;
    expect(data['payslips'], hasLength(31));
    expect(data, isNot(contains('photoUrl')));
    expect(data['salary'], {'baseSalary': 15000000});
  });

  test('lịch tháng đếm sẵn ngày công, giờ làm, ngày nghỉ', () {
    final days = [
      for (var d = 1; d <= 31; d++)
        {
          'date': '2026-10-${d.toString().padLeft(2, '0')}',
          'checkIn': d <= 20 && d.isEven ? '08:00' : null,
          'checkOut': d <= 20 && d.isEven ? '17:00' : null,
          'workHours': d <= 20 && d.isEven ? 8 : null,
          'overtimeHours': d == 2 ? 1.5 : null,
          'totalHours': d <= 20 && d.isEven ? 8 : null,
          'holiday': d == 20 ? 'Ngày Phụ nữ' : null,
          'leave': d == 21 ? {'type': 'annual', 'status': 'approved'} : null,
        },
    ];
    final s = summarizeCalendar({'items': days});
    expect(s['daysWorked'], 10);
    expect(s['workedDates'], contains('2026-10-20'));
    expect(s['workHours'], 80);
    expect(s['overtimeHours'], 1.5);
    expect(s['leaveDays'], hasLength(1));
    expect(s['holidays'], hasLength(1));
    expect(s['days'], hasLength(11));
  });

  test('không có địa chỉ khu vực hoặc token thì không tra dữ liệu', () {
    final none = PersonalData((_) => null);
    expect(none.forUser('vn', 'Bearer x'), isNull);
    final vps = PersonalData((r) => Uri.parse('https://$r.example'));
    expect(vps.forUser('vn', ''), isNull);
    expect(vps.forUser('vn', 'Bearer x'), isNotNull);
    expect(personalTopics.keys, contains('payroll'));
  });
}
