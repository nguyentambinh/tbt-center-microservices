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
