/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:mocktail/mocktail.dart';
import 'package:notification_service/src/data/notification_repository.dart';
import 'package:notification_service/src/domain/notification_rules.dart';
import 'package:notification_service/src/event_consumer.dart';
import 'package:notification_service/src/push_messages.dart';
import 'package:notification_service/src/push_sender.dart';
import 'package:notification_service/src/recipients.dart';
import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

class _MockRepository extends Mock implements NotificationRepository {}

class _MockPush extends Mock implements PushSender {}

HubEvent _event(int id, String type, Map<String, dynamic> payload) => HubEvent(
  id: id,
  eventId: '00000000-0000-4000-8000-00000000000$id',
  eventType: type,
  payload: payload,
);

void main() {
  group('sự kiện nào báo cho ai', () {
    test('đơn nghỉ được duyệt thì báo đúng người xin nghỉ', () {
      final n = notificationsFor(
        _event(1, 'LeaveApproved', {
          'employeeId': 'Anh8715OP',
          'fromDate': '2026-12-28',
          'days': 3,
        }),
      ).single;
      expect(n.recipient, 'employee:Anh8715OP');
      expect(n.kind, 'leave_approved');
      expect(n.params['days'], 3);
    });

    test('làm thẳng đổi lương: báo nhân viên, quản trị nhận nhật ký mới', () {
      final list = notificationsFor(
        _event(9, 'SalaryChanged', {
          'employeeId': 'E2',
          'baseSalary': '18000000.00',
          'currency': 'VND',
          'changedBy': 'EX1',
        }),
      );
      expect(
        [for (final n in list) n.recipient],
        ['employee:E2', 'role:admin'],
      );
      expect(list.last.kind, 'audit_log');
      expect(list.last.params['by'], 'EX1');
    });

    test('quản trị không nhận việc cần duyệt', () {
      final list = notificationsFor(
        _event(8, 'LeaveRequested', {'employeeId': 'E2', 'days': 1}),
      );
      expect(list.any((n) => n.recipient == 'role:admin'), isFalse);
    });

    test('đơn mới thì báo cho mọi HR trong khu vực', () {
      final n = notificationsFor(
        _event(2, 'OvertimeRequested', {'employeeId': 'E1', 'hours': 2}),
      ).single;
      expect(n.recipient, 'role:hr');
    });

    test('hồ sơ ứng viên đổi bước thì báo cho chính ứng viên (R97)', () {
      final n = notificationsFor(
        _event(3, 'CandidateStatusChanged', {
          'candidateId': 'C1',
          'status': 'interview',
        }),
      ).single;
      expect(n.recipient, 'candidate:C1');
      expect(n.params['status'], 'interview');
    });

    test('dự án được nghiệm thu thì báo cho bộ phận tài chính', () {
      final n = notificationsFor(
        _event(6, 'ProjectAccepted', {'projectId': 'P1'}),
      ).single;
      expect(n.recipient, 'role:finance');
      expect(n.kind, 'project_accepted');
    });

    test('đề xuất sửa hồ sơ: gửi thì báo HR, duyệt thì báo nhân viên', () {
      final asked = notificationsFor(
        _event(7, 'ProfileChangeRequested', {'employeeId': 'E1'}),
      ).single;
      expect(asked.recipient, 'role:hr');
      expect(asked.kind, 'profile_change_requested');

      final rejected = notificationsFor(
        _event(8, 'ProfileChangeRejected', {'employeeId': 'E1', 'note': 'Sai'}),
      ).single;
      expect(rejected.recipient, 'employee:E1');
      expect(rejected.kind, 'profile_change_rejected');
      expect(rejected.params['note'], 'Sai');
    });

    test('đề cử thăng chức tới lãnh đạo, kết quả tới nhân viên và HR', () {
      final nominated = notificationsFor(
        _event(9, 'PromotionNominated', {
          'employeeId': 'E1',
          'proposedPosition': 'Trưởng nhóm',
        }),
      ).single;
      expect(nominated.recipient, 'role:executive');
      expect(nominated.kind, 'promotion_nominated');

      final approved = notificationsFor(
        _event(10, 'PromotionApproved', {
          'employeeId': 'E1',
          'proposedPosition': 'Trưởng nhóm',
        }),
      );
      expect(approved.map((n) => n.recipient), ['employee:E1', 'role:hr']);
      expect(approved.first.kind, 'promotion_approved');

      final moved = notificationsFor(
        _event(11, 'EmployeeTransferred', {
          'employeeId': 'E1',
          'toDepartment': 'PB1',
        }),
      ).single;
      expect(moved.kind, 'employee_transferred');
      expect(moved.params['departmentId'], 'PB1');
    });

    test('lịch phỏng vấn: hẹn tới ứng viên, đề xuất lại tới HR', () {
      const payload = {
        'candidateId': 'C1',
        'countryCode': 'VN',
        'appliedPosition': 'Kế toán',
        'scheduledAt': '2026-10-27T02:30:00.000Z',
      };
      final scheduled = notificationsFor(
        _event(12, 'InterviewScheduled', payload),
      ).single;
      expect(scheduled.recipient, 'candidate:C1');
      expect(
        pushText(scheduled, 'vi').body,
        'Lịch phỏng vấn Kế toán lúc 27/10/2026 09:30 (GMT+7), mở app để xác '
        'nhận',
      );
      final proposed = notificationsFor(
        _event(13, 'InterviewProposed', payload),
      ).single;
      expect(proposed.recipient, 'role:hr');
      final confirmed = notificationsFor(
        _event(14, 'InterviewConfirmed', payload),
      );
      expect(confirmed.map((n) => n.recipient), ['candidate:C1', 'role:hr']);
    });

    test('đề xuất dự án tới lãnh đạo, kết quả tới HR và tài chính', () {
      final proposed = notificationsFor(
        _event(15, 'ProjectProposed', {
          'proposalId': 3,
          'name': 'Cầu Rạch Chiếc',
        }),
      ).single;
      expect(proposed.recipient, 'role:executive');
      expect(
        pushText(proposed, 'vi').body,
        'Đề xuất dự án mới cần duyệt: Cầu Rạch Chiếc',
      );
      final approved = notificationsFor(
        _event(16, 'ProjectProposalApproved', {
          'name': 'Cầu',
          'projectId': 'DA1',
        }),
      );
      expect(approved.map((n) => n.recipient), ['role:hr', 'role:finance']);
      expect(approved.first.kind, 'project_approved');
    });

    test('tăng lương, báo cáo: tới đúng người theo từng bước', () {
      final forwarded = notificationsFor(
        _event(17, 'RaiseForwarded', {'requestId': 1, 'employeeId': 'E1'}),
      );
      expect(forwarded.map((n) => n.recipient), ['role:executive']);
      final approved = notificationsFor(
        _event(18, 'RaiseApproved', {'requestId': 1, 'employeeId': 'E1'}),
      ).single;
      expect(approved.recipient, 'employee:E1');
      final submitted = notificationsFor(
        _event(19, 'ReportSubmitted', {'kind': 'finance', 'period': '2026-09'}),
      ).single;
      expect(submitted.recipient, 'role:executive');
      expect(
        pushText(submitted, 'vi').body,
        'Có báo cáo tài chính kỳ 2026-09 gửi lên cần xác nhận',
      );
      final returned = notificationsFor(
        _event(20, 'ReportReturned', {'kind': 'hr', 'period': '2026-09'}),
      ).single;
      expect(returned.recipient, 'role:hr');
    });

    test('xin thôi việc báo HR, kết quả báo người xin', () {
      final requested = notificationsFor(
        _event(21, 'ResignationRequested', {
          'resignationId': 1,
          'employeeId': 'E1',
          'lastDay': '2026-12-01',
        }),
      ).single;
      expect(requested.recipient, 'role:hr');
      expect(
        pushText(requested, 'vi').body,
        'E1 xin thôi việc, ngày làm cuối 2026-12-01',
      );
      final approved = notificationsFor(
        _event(22, 'ResignationApproved', {
          'resignationId': 1,
          'employeeId': 'E1',
          'lastDay': '2026-12-01',
        }),
      ).single;
      expect(approved.recipient, 'employee:E1');
      expect(approved.kind, 'resignation_approved');
    });

    test('sự kiện không liên quan người dùng thì không báo', () {
      expect(notificationsFor(_event(4, 'ClockedIn', {})), isEmpty);
      expect(notificationsFor(_event(5, 'LeaveApproved', {})), isEmpty);
    });
  });

  group('đọc dòng sự kiện', () {
    late _MockRepository repository;
    late _MockPush push;

    setUpAll(() {
      registerFallbackValue(
        (recipient: '', kind: '', params: <String, Object?>{}),
      );
    });

    setUp(() {
      repository = _MockRepository();
      push = _MockPush();
      when(() => push.send(any())).thenAnswer((_) async {});
    });

    test(
      'đọc tiếp từ mốc cũ, ghi thông báo và dời mốc tới sự kiện cuối',
      () async {
        when(() => repository.checkpoint()).thenAnswer((_) async => 10);
        when(
          () => repository.saveBatch(
            any(),
            lastEventId: any(named: 'lastEventId'),
          ),
        ).thenAnswer(
          (inv) async => [
            for (final i
                in inv.positionalArguments.first
                    as List<
                      ({
                        String eventId,
                        DateTime? at,
                        NewNotification notification,
                      })
                    >)
              i.notification,
          ],
        );
        int? askedAfter;
        final consumer = EventConsumer(
          repository: repository,
          push: push,
          read: (after) async {
            askedAfter = after;
            return [
              _event(11, 'LeaveRequested', {'employeeId': 'E1'}),
              _event(12, 'ClockedIn', {}),
            ];
          },
        );

        expect(await consumer.consumeOnce(), 2);
        expect(askedAfter, 10);
        final saved =
            verify(
                  () => repository.saveBatch(captureAny(), lastEventId: 12),
                ).captured.single
                as List;
        expect(saved, hasLength(1));
        verify(() => push.send(any())).called(1);
      },
    );

    test('gửi đẩy lỗi không làm hỏng lượt đọc', () async {
      when(() => repository.checkpoint()).thenAnswer((_) async => 0);
      when(
        () =>
            repository.saveBatch(any(), lastEventId: any(named: 'lastEventId')),
      ).thenAnswer(
        (_) async => [(recipient: 'role:hr', kind: 'x', params: {})],
      );
      when(() => push.send(any())).thenThrow(Exception('FCM down'));
      final consumer = EventConsumer(
        repository: repository,
        push: push,
        read: (_) async => [_event(1, 'LeaveRequested', {})],
      );
      expect(await consumer.consumeOnce(), 1);
    });
  });

  test('người nhận gồm vai trò, mã nhân viên và hồ sơ ứng viên', () async {
    var lookups = 0;
    final resolver = RecipientResolver((sub) async {
      lookups++;
      return sub == 'sub-1' ? 'C1' : null;
    });
    final employee = Claims({
      'sub': 'sub-2',
      'employee_id': 'E1',
      'realm_access': {
        'roles': ['employee', 'hr'],
      },
    });
    final candidate = Claims({
      'sub': 'sub-1',
      'realm_access': {
        'roles': ['candidate'],
      },
    });

    expect(
      await resolver.of(employee),
      unorderedEquals(['role:employee', 'role:hr', 'employee:E1']),
    );
    expect(await resolver.of(candidate), contains('candidate:C1'));
    await resolver.of(candidate);
    expect(lookups, 1);
  });
}
