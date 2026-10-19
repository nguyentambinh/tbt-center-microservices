/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:bank_mock_service/src/bank.dart';
import 'package:test/test.dart';

const _salary = TransferRequest(
  reference: 'PAY-2026-09-E1',
  account: 'VN00112233',
  amount: 11000000,
  currency: 'VND',
);

void main() {
  late MockBank bank;

  setUp(() => bank = MockBank());

  test('chuyển tiền thành công, có mã giao dịch của ngân hàng', () async {
    final transfer = await bank.transfer(_salary);
    expect(transfer.bankReference, startsWith('BNK'));
    expect(bank.find('PAY-2026-09-E1'), isNotNull);
  });

  test('gửi lại cùng mã tham chiếu thì không chuyển lần hai', () async {
    final first = await bank.transfer(_salary);
    final again = await bank.transfer(_salary);
    expect(again.bankReference, first.bankReference);
    expect(bank.transferCount, 1);
  });

  test('chế độ lỗi thì từ chối, không ghi giao dịch', () async {
    bank.mode = BankMode.failing;
    await expectLater(
      bank.transfer(_salary),
      throwsA(isA<BankUnavailable>()),
    );
    expect(bank.transferCount, 0);
  });

  test('chế độ chậm thì trả lời trễ', () async {
    bank
      ..mode = BankMode.slow
      ..slowDelay = const Duration(milliseconds: 200);
    final watch = Stopwatch()..start();
    await bank.transfer(_salary);
    expect(watch.elapsedMilliseconds, greaterThanOrEqualTo(200));
  });
}
