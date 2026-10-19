/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:bank_mock_service/src/bank.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

final _bank = MockBank();

Handler middleware(Handler handler) {
  return handler
      .use(provider<MockBank>((_) => _bank))
      .use(correlationAndErrors())
      .use(metrics('bank_mock'));
}
