/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tbtcenter/core/widgets/input_rules.dart';

/// Gõ [text] vào ô có [rules], trả về nội dung ô giữ lại
String typed(List<TextInputFormatter> rules, String text) {
  var value = TextEditingValue.empty;
  for (final f in rules) {
    value = f.formatEditUpdate(TextEditingValue.empty, value.copyWith(text: value.text.isEmpty ? text : value.text));
  }
  return value.text;
}

void main() {
  test('ô chữ chặn emoji nhưng giữ tiếng Việt, tiếng Đức', () {
    expect(typed(InputRules.note, 'Nghỉ ốm 😷 vì sốt 🤒'), 'Nghỉ ốm  vì sốt ');
    expect(typed(InputRules.shortText, 'Größe ✅'), 'Größe ');
  });

  test('họ tên chỉ nhận chữ, số và ký hiệu bị bỏ', () {
    expect(typed(InputRules.name, "Nguyễn Văn A123 @#"), 'Nguyễn Văn A ');
    expect(typed(InputRules.name, "O'Brien-Smith"), "O'Brien-Smith");
  });

  test('số điện thoại, số tiền, mã nước chỉ nhận đúng ký tự', () {
    expect(typed(InputRules.phone, '+84 909 abc 123'), '+84 909  123');
    expect(typed(InputRules.digits, '12a.5-0'), '1250');
    expect(typed(InputRules.decimal, '1.5x'), '1.5');
    expect(typed(InputRules.currency, 'VND1'), 'VND');
  });

  test('độ dài tối đa: tìm kiếm 100, ghi chú 1000 ký tự', () {
    expect(typed(InputRules.search, 'a' * 500).length, 100);
    expect(typed(InputRules.note, 'b' * 5000).length, 1000);
  });

  test('trường hồ sơ chọn luật theo khóa', () {
    expect(typed(InputRules.profileField('heightCm'), '17x5cm'), '175');
    expect(typed(InputRules.profileField('email'), 'an 😀@tbt.vn'), 'an@tbt.vn');
  });
}
