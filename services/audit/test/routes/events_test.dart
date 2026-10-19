/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';

import 'package:audit_service/src/audit_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../routes/events/index.dart' as events_route;
import '../../routes/verify.dart' as verify_route;

class _MockContext extends Mock implements RequestContext {}

class _MockRepository extends Mock implements AuditRepository {}

const _event = {
  'eventId': '7f1c2d3e-0000-4000-8000-000000000001',
  'region': 'vn',
  'sourceService': 'attendance',
  'outboxId': 1,
  'aggregate': 'leave_request',
  'aggregateId': 'L1',
  'eventType': 'LeaveRequested',
  'payload': {'days': 3},
  'occurredAt': '2026-10-15T00:00:00Z',
};

void main() {
  late _MockContext context;
  late _MockRepository repository;

  setUpAll(() => registerFallbackValue(<IncomingEvent>[]));

  setUp(() {
    context = _MockContext();
    repository = _MockRepository();
    when(() => context.read<AuditRepository>()).thenReturn(repository);
  });

  void request(String method, String path, {Object? body}) {
    when(() => context.request).thenReturn(
      Request(
        method,
        Uri.parse('http://localhost$path'),
        body: body == null ? null : jsonEncode(body),
      ),
    );
  }

  test('nhận lô sự kiện, báo số dòng ghi thêm', () async {
    request(
      'POST',
      '/events',
      body: {
        'events': [_event, _event],
      },
    );
    when(() => repository.append(any())).thenAnswer((_) async => 1);

    final response = await events_route.onRequest(context);
    expect(await response.json(), {'received': 2, 'added': 1});
    final sent =
        verify(() => repository.append(captureAny())).captured.single
            as List<IncomingEvent>;
    expect(sent.first.eventId, _event['eventId']);
  });

  test('đọc tiếp sự kiện của một khu vực từ sau mốc đã đọc', () async {
    request('GET', '/events?region=vn&after=20&limit=10');
    when(
      () => repository.since(20, region: 'vn', limit: 10),
    ).thenAnswer(
      (_) async => [
        {'id': 21},
      ],
    );
    final body = await (await events_route.onRequest(context)).json() as Map;
    expect(body['items'], [
      {'id': 21},
    ]);
  });

  test('đọc tiếp mà thiếu khu vực thì 400', () async {
    request('GET', '/events?after=20');
    final response = await events_route.onRequest(context);
    expect(response.statusCode, 400);
  });

  test('thân request sai dạng thì 400', () async {
    request('POST', '/events', body: {'events': 'khong-phai-list'});
    final response = await events_route.onRequest(context);
    expect(response.statusCode, 400);
  });

  test('verify báo dòng đầu tiên bị sửa', () async {
    request('GET', '/verify');
    when(
      () => repository.verify(),
    ).thenAnswer((_) async => (checked: 10, brokenAt: 4));
    final response = await verify_route.onRequest(context);
    expect(await response.json(), {
      'checked': 10,
      'intact': false,
      'brokenAt': 4,
    });
  });
}
