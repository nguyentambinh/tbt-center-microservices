/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:recruitment_service/src/candidate_repository.dart';
import 'package:recruitment_service/src/interviews.dart';
import 'package:recruitment_service/src/offer.dart';
import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

import '../../routes/candidates/[id]/minutes/index.dart' as minutes_route;

Matcher _violation(String code) => throwsA(
  isA<CandidateRuleViolation>().having((e) => e.code, 'code', code),
);

void main() {
  group('luồng chỉ đi tới', () {
    test('mới nộp, AI đã đọc thì sang sàng lọc', () {
      expect(() => checkMove('submitted', 'screening'), returnsNormally);
      expect(() => checkMove('analyzed', 'screening'), returnsNormally);
    });

    test('không quay lại bước trước', () {
      expect(
        () => checkMove('interview', 'screening'),
        _violation('invalid_transition'),
      );
      expect(
        () => checkMove('interviewed', 'submitted'),
        _violation('invalid_transition'),
      );
    });

    test('phỏng vấn, biên bản, nhận việc đi qua route riêng', () {
      expect(
        () => checkMove('screening', 'interview'),
        _violation('use_interview'),
      );
      expect(
        () => checkMove('interview', 'interviewed'),
        _violation('use_minutes'),
      );
      expect(() => checkMove('interviewed', 'hired'), _violation('use_hire'));
    });

    test('từ chối được ở mọi bước trừ đã nhận việc', () {
      expect(() => checkMove('interview', 'rejected'), returnsNormally);
      expect(
        () => checkMove('hired', 'rejected'),
        _violation('invalid_transition'),
      );
    });

    test('xem xét lại quay về bước trước lần từ chối gần nhất', () {
      expect(
        statusBeforeRejection([
          'submitted',
          'rejected',
          'screening',
          'interview',
          'rejected',
        ]),
        'interview',
      );
      expect(statusBeforeRejection(['rejected']), isNull);
    });
  });

  group('hẹn phỏng vấn', () {
    test('HR hẹn, ứng viên xác nhận', () {
      expect(
        nextInterviewState('awaiting_candidate', Party.candidate, 'confirm'),
        'confirmed',
      );
    });

    test('HR đặt lại giờ khi chưa chốt', () {
      expect(
        nextInterviewState('awaiting_candidate', Party.hr, 'propose'),
        'awaiting_candidate',
      );
    });

    test('ứng viên không đề xuất giờ, HR không xác nhận thay', () {
      expect(
        () => nextInterviewState(
          'awaiting_candidate',
          Party.candidate,
          'propose',
        ),
        _violation('invalid_interview_action'),
      );
      expect(
        () => nextInterviewState('awaiting_candidate', Party.hr, 'confirm'),
        _violation('invalid_interview_action'),
      );
    });

    test('hai bên đã xác nhận thì không bên nào đề xuất lại giờ', () {
      for (final party in Party.values) {
        expect(
          () => nextInterviewState('confirmed', party, 'propose'),
          _violation('interview_locked'),
        );
      }
    });

    test('lịch đã hủy thì không trả lời được', () {
      expect(
        () => nextInterviewState('cancelled', Party.candidate, 'propose'),
        _violation('invalid_interview_action'),
      );
    });

    test('giờ hẹn phải sau hiện tại', () {
      final now = DateTime.utc(2026, 10, 25, 9);
      expect(
        () => checkFutureTime(now.subtract(const Duration(minutes: 1)), now),
        _violation('time_in_past'),
      );
      expect(
        () => checkFutureTime(now.add(const Duration(hours: 1)), now),
        returnsNormally,
      );
    });

    test('email theo ngôn ngữ và giờ địa phương của nước ứng tuyển', () {
      final at = DateTime.utc(2026, 10, 27, 2, 30);
      final vi = interviewEmail(
        'scheduled',
        country: 'VN',
        name: 'Lê Minh Thư',
        position: 'Kế toán',
        at: at,
        location: 'Tầng 5, 12 Lê Lợi',
      );
      expect(vi.subject, contains('Kế toán'));
      expect(vi.body, contains('27/10/2026 09:30 (GMT+7)'));
      expect(vi.body, contains('Tầng 5, 12 Lê Lợi'));
      final de = interviewEmail(
        'confirmed',
        country: 'DE',
        name: 'Lena',
        at: at,
      );
      expect(de.body, startsWith('Hallo Lena'));
      expect(formatRegionTime(at, 'BR'), '26/10/2026 23:30 (GMT-3)');
    });

    test('biên bản phải là tệp Word hoặc Excel thật', () {
      expect(minutes_route.looksLikeOffice([0x50, 0x4B, 3, 4]), isTrue);
      expect(minutes_route.looksLikeOffice([0xD0, 0xCF, 0x11, 0xE0]), isTrue);
      expect(minutes_route.looksLikeOffice('%PDF'.codeUnits), isFalse);
    });
  });

  group('gợi ý thỏa thuận', () {
    test('phòng có nhiều người cùng chức vụ, lương trung vị của họ', () {
      final result = OfferAdvisor.heuristic(
        [
          {'id': 'KT', 'members': 3},
          {'id': 'TC', 'members': 9},
        ],
        [
          {'id': 'A', 'departmentId': 'KT'},
          {'id': 'B', 'departmentId': 'KT'},
          {'id': 'C', 'departmentId': 'TC'},
        ],
        [
          {'baseSalary': '12000000.00', 'currency': 'VND'},
          {'baseSalary': '15000000.00', 'currency': 'VND'},
          {'baseSalary': '20000000.00', 'currency': 'VND'},
        ],
      );
      expect(result['departmentId'], 'KT');
      expect(result['baseSalary'], 15000000);
      expect(result['currency'], 'VND');
    });

    test('chưa ai cùng chức vụ thì chọn phòng đông người nhất', () {
      final result = OfferAdvisor.heuristic(
        [
          {'id': 'KT', 'members': 3},
          {'id': 'TC', 'members': 9},
        ],
        const [],
        const [],
      );
      expect(result['departmentId'], 'TC');
      expect(result['baseSalary'], isNull);
    });

    test('trung vị số chẵn lấy trung bình hai số giữa', () {
      expect(median([4, 1, 3, 2]), 2.5);
      expect(median([]), isNull);
    });
  });
}
