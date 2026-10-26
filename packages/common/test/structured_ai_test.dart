/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

void main() {
  test('schema gửi Claude đóng mọi object, kể cả object lồng trong mảng', () {
    const schema = {
      'type': 'object',
      'properties': {
        'assignments': {
          'type': 'array',
          'items': {
            'type': 'object',
            'properties': {
              'employeeId': {'type': 'string'},
            },
          },
        },
        'reason': {'type': 'string'},
      },
      'required': ['assignments'],
    };
    final closed = closedSchema(schema)! as Map<String, dynamic>;
    expect(closed['additionalProperties'], isFalse);
    final items =
        ((closed['properties'] as Map)['assignments'] as Map)['items'] as Map;
    expect(items['additionalProperties'], isFalse);
    final reason = (closed['properties'] as Map)['reason'] as Map;
    expect(reason.containsKey('additionalProperties'), isFalse);
    expect(closed['required'], ['assignments']);
    // Schema gốc giữ nguyên cho Gemini
    expect(schema.containsKey('additionalProperties'), isFalse);
  });
}
