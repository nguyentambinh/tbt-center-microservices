/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-19
 */

// Chuyển lương thật qua giao diện: vài người, cả công ty, cả tập đoàn.
// Mỗi bước chạy riêng bằng --plain-name; kênh payOS bật thì chi tiền thật.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tbtcenter/core/network/api_client.dart';
import 'package:tbtcenter/features/payroll/data/repositories/payroll_run_repository_impl.dart';
import 'package:tbtcenter/core/config/env.dart';
import 'package:tbtcenter/features/payroll/domain/entities/payout.dart';
import 'package:tbtcenter/features/payroll/domain/entities/payroll_run.dart';
import 'package:tbtcenter/features/payroll/domain/repositories/payroll_run_repository.dart';
import 'package:tbtcenter/features/payroll/presentation/providers/payroll_run_providers.dart';

import 'e2e_helpers.dart';

/// Bơm khung hình tới khi thấy [finder] hoặc hết giờ
Future<bool> waitFor(WidgetTester tester, Finder finder, {Duration timeout = const Duration(seconds: 30)}) async {
  final watch = Stopwatch()..start();
  while (watch.elapsed < timeout) {
    await tester.pump(const Duration(milliseconds: 200));
    if (finder.evaluate().isNotEmpty) return true;
  }
  return false;
}

Future<void> idle(WidgetTester tester, Duration duration) async {
  final watch = Stopwatch()..start();
  while (watch.elapsed < duration) {
    await tester.pump(const Duration(milliseconds: 500));
  }
}

/// Bấm Chuyển ở hộp xác nhận, gặp cảnh báo trùng thì chọn Chuyển lại
Future<void> confirmAndResend(WidgetTester tester, String label) async {
  await tester.pump(const Duration(milliseconds: 500));
  await tester.tap(find.widgetWithText(FilledButton, 'Chuyển'));
  if (await waitFor(tester, find.text('Có người đã nhận lương kỳ này'), timeout: const Duration(seconds: 40))) {
    dumpTexts(tester, '$label: cảnh báo trùng');
    debugPrint('SHOT:${label}_canh_bao');
    await idle(tester, const Duration(seconds: 2));
    await tester.tap(find.text('Chuyển lại'));
  }
  expect(await waitFor(tester, find.text('Kết quả chuyển lương'), timeout: const Duration(seconds: 60)), isTrue);
  await idle(tester, const Duration(seconds: 1));
  dumpTexts(tester, '$label: kết quả');
  debugPrint('SHOT:${label}_ket_qua');
  await idle(tester, const Duration(seconds: 2));
  Navigator.of(tester.element(find.text('Kết quả chuyển lương'))).pop();
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> showLog(WidgetTester tester, String label, Duration wait) async {
  await tester.tap(find.text('Nhật ký'));
  await idle(tester, wait);
  dumpTexts(tester, '$label: nhật ký');
  debugPrint('SHOT:${label}_nhat_ky');
  await idle(tester, const Duration(seconds: 2));
}

const _region = String.fromEnvironment('PAY_REGION', defaultValue: 'vn');
const _count = int.fromEnvironment('PAY_COUNT', defaultValue: 3);
const _user = String.fromEnvironment('PAY_USER', defaultValue: 'anonymous1606');
const _perRegion = int.fromEnvironment('PAY_PER_REGION', defaultValue: 1);
const _names = {'vn': 'Việt Nam', 'de': 'Đức', 'us': 'Hoa Kỳ', 'br': 'Brazil', 'za': 'Nam Phi', 'au': 'Úc'};

/// Lệnh "cả công ty" chỉ chuyển cho [perRegion] người đầu danh sách: thử luồng cả tập đoàn mà ít tốn tiền
class SampleRepository implements PayrollRunRepository {
  SampleRepository(this.inner, this.perRegion);

  final PayrollRunRepository inner;
  final int perRegion;

  @override
  Future<List<PayrollRun>> runs() => inner.runs();
  @override
  Future<PayrollRun> run(String id) => inner.run(id);
  @override
  Future<PayrollRun> start(String period) => inner.start(period);
  @override
  Future<PayrollRun> retry(String id) => inner.retry(id);
  @override
  Future<PayoutBoard> payouts(String period) => inner.payouts(period);
  @override
  Future<List<PayoutLogItem>> payoutLog(String period) => inner.payoutLog(period);

  @override
  Future<PayoutResult> transfer(
    String period, {
    List<String>? employeeIds,
    DuplicateMode duplicates = DuplicateMode.ask,
  }) async {
    final ids = employeeIds ?? [for (final l in (await inner.payouts(period)).lines.take(perRegion)) l.employeeId];
    return inner.transfer(period, employeeIds: ids, duplicates: duplicates);
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('chuyen 2 nguoi', (tester) async {
    await pumpAs(tester, 'anonymous1606');
    await openHomeCard(tester, 'Chốt lương');
    expect(await waitFor(tester, find.byType(CheckboxListTile)), isTrue);
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.byType(CheckboxListTile).at(i));
      await tester.pump(const Duration(milliseconds: 300));
    }
    dumpTexts(tester, 'chọn 2 người');
    debugPrint('SHOT:nguoi_chon');
    await tester.tap(find.text('Chuyển cho 2 người'));
    await confirmAndResend(tester, 'nguoi');
    await showLog(tester, 'nguoi', const Duration(seconds: 15));
  });

  testWidgets('chuyen khu vuc', (tester) async {
    await pumpAs(tester, 'anonymous1606');
    await openHomeCard(tester, 'Chốt lương');
    await tester.tap(find.text('Chuyển lương Việt Nam'));
    await confirmAndResend(tester, 'khu_vuc');
    await showLog(tester, 'khu_vuc', const Duration(seconds: 90));
  });

  testWidgets('chuyen tap doan', (tester) async {
    await pumpAs(tester, 'anonymous1606');
    await openHomeCard(tester, 'Chốt lương');
    await tester.tap(find.text('Chuyển cả tập đoàn'));
    await confirmAndResend(tester, 'tap_doan');
    await showLog(tester, 'tap_doan', const Duration(seconds: 150));
  });

  testWidgets('chuyen dai dien khu vuc', (tester) async {
    await pumpAs(tester, _user);
    await openHomeCard(tester, 'Chốt lương');
    final name = _names[_region]!;
    // Tài chính khu vực chỉ thấy công ty của mình, không có ô chọn công ty
    if (_region != 'vn' && _user == 'anonymous1606') {
      final chip = find.widgetWithText(ChoiceChip, name);
      await tester.ensureVisible(chip);
      await tester.tap(chip);
    }
    await idle(tester, const Duration(seconds: 3));
    expect(await waitFor(tester, find.byType(CheckboxListTile)), isTrue);
    for (var i = 0; i < _count; i++) {
      await tester.tap(find.byType(CheckboxListTile).at(i));
      await tester.pump(const Duration(milliseconds: 300));
    }
    dumpTexts(tester, '$_region: chọn $_count người');
    debugPrint('SHOT:${_region}_chon');
    await tester.tap(find.text('Chuyển cho $_count người'));
    await confirmAndResend(tester, _region);
    await showLog(tester, _region, const Duration(seconds: 20));
  });

  testWidgets('chuyen tap doan dai dien', (tester) async {
    await pumpAs(
      tester,
      'anonymous1606',
      extraOverrides: [
        payrollRunRepositoryForRegionProvider.overrideWith((ref) {
          final dio = ref.watch(apiClientProvider);
          return (region) => SampleRepository(PayrollRunRepositoryImpl(dio, baseUrl: Env.kongUrl(region)), _perRegion);
        }),
      ],
    );
    await openHomeCard(tester, 'Chốt lương');
    debugPrint('SHOT:tap_doan_0_man_chot_luong');
    await tester.tap(find.text('Chuyển cả tập đoàn'));
    await tester.pump(const Duration(milliseconds: 500));
    debugPrint('SHOT:tap_doan_1_xac_nhan');
    await idle(tester, const Duration(seconds: 1));
    await confirmAndResend(tester, 'tap_doan');
    // Mỗi công ty chuyển ở nền, từng khoản vài giây
    await showLog(tester, 'tap_doan', const Duration(seconds: 90));
    for (final MapEntry(key: code, value: name) in _names.entries) {
      final chip = find.widgetWithText(ChoiceChip, name);
      await tester.ensureVisible(chip);
      await tester.tap(chip);
      await idle(tester, const Duration(seconds: 6));
      dumpTexts(tester, 'nhật ký $code');
      debugPrint('SHOT:tap_doan_nhat_ky_$code');
      await idle(tester, const Duration(seconds: 2));
    }
  });
}
