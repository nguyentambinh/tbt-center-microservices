/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';

import 'package:mocktail/mocktail.dart';
import 'package:notification_service/src/data/notification_repository.dart';
import 'package:notification_service/src/fcm_sender.dart';
import 'package:notification_service/src/push_messages.dart';
import 'package:test/test.dart';

class _MockRepository extends Mock implements NotificationRepository {}

// Khóa RSA tạo riêng cho test, không dùng ở đâu khác
const _pem = '''
-----BEGIN PRIVATE KEY-----
MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAKu7eTFcl3NiB+5f
YH95G/EPjwaKNn4dY05aI1TE0CtLm3CNV/91S8iQ/lyvrnMQlt/ayH4oGaFHGcC3
KM/CdAQ19QsM3x15/ACZW5xOyzEw/83DVNLpPsPfwwL0h5vYTMj8VC+PAQJM440o
4f+Mb1+zaq2vgc128zBKF3bsXd8dAgMBAAECgYA5Pgs+leNxtWp5XVdYBjF3H72H
64gQb5FLa6Y9OkE9PT15vdNoNlvlZdczY+fdONlhkpaj3o/0fzOpViQHZISw2nc7
CMTCk29UVaNXwGRgJSrkrA9Ts+iHP3GLmuhneD0hFVRbOj48R+7BZPHo1+sE1m/y
P2Tt5bmxbDx3B7CebQJBAOGg442GpvSEeu3mHhoi8uvEda80ZfKqVKQ8tHQpwr+H
L3SI0w4hv2ADDB3L926Vry1B7yAPnsswjAXc74zVdAMCQQDC2VWEhxmrhPRp/TSR
KjkqlR/pDEKYtV/kjJZhSbLisZd8aP9ytdEw7akdJDDOhsru5M09e1TU8ggB1Jst
JUZfAkEAtJcY6wMWiGmtFtLzzwmgE3M4mpY+7x7EBnyMFtoCBViHdCe7ffkm+wsV
XJgPoFRwVLIMWkYGXC2sNVkj5z5FzwJBAMHTgn9wCTgW7S+WArm4/979Mx4X5ROV
sUtgEqO6tWlOcjv/EsVgWjVK5WSowKhha/OSxRu42N1v2kk/3hFduA8CQG+z+qvr
0jmfBpZIxmfEQrn//VIzjo9+wWxT/+d+UmtlpWA4oBIXmT3QMXX1Pg/0iF87hAM5
is0Pxdh/aRl6DKs=
-----END PRIVATE KEY-----
''';

ServiceAccount _account() => ServiceAccount({
  'project_id': 'tbt-test',
  'client_email': 'push@tbt-test.iam.gserviceaccount.com',
  'token_uri': 'https://oauth2.googleapis.com/token',
  'private_key': _pem,
});

const _payroll = (
  recipient: 'role:employee',
  kind: 'payroll_paid',
  params: <String, Object?>{'period': '2026-10'},
);

void main() {
  late _MockRepository devices;
  late List<(Uri, Object, String?)> calls;
  late List<HttpResult> answers;

  setUp(() {
    devices = _MockRepository();
    calls = [];
    answers = [];
    when(() => devices.removeDevice(any())).thenAnswer((_) async {});
  });

  FcmPushSender sender() => FcmPushSender(
    _account(),
    devices,
    post: (url, body, {bearer}) async {
      calls.add((url, body, bearer));
      return answers.removeAt(0);
    },
  );

  test('bước tuyển dụng hiện tên theo ngôn ngữ, không hiện mã', () {
    const hired = (
      recipient: 'candidate:c1',
      kind: 'candidate_status',
      params: <String, Object?>{'status': 'hired'},
    );
    expect(pushText(hired, 'vi').body, contains('Đã nhận vào làm'));
    expect(pushText(hired, 'de').body, contains('Eingestellt'));
  });

  test('câu đẩy theo ngôn ngữ của máy, thay tham số', () {
    expect(pushText(_payroll, 'vi').body, 'Lương kỳ 2026-10 đã được chi');
    expect(pushText(_payroll, 'de').body, contains('2026-10'));
    expect(pushText(_payroll, 'fr').body, 'Salary for 2026-10 has been paid');
  });

  test('xin token Google một lần rồi gửi tới từng máy', () async {
    when(() => devices.devicesFor('role:employee')).thenAnswer(
      (_) async => [
        (token: 'may-1', language: 'vi'),
        (token: 'may-2', language: 'en'),
      ],
    );
    answers.addAll([
      (
        code: 200,
        body: jsonEncode({'access_token': 'g-token', 'expires_in': 3600}),
      ),
      (code: 200, body: '{}'),
      (code: 200, body: '{}'),
    ]);
    final push = sender();

    await push.send(_payroll);

    expect(calls.first.$1.host, 'oauth2.googleapis.com');
    expect(calls.first.$2 as String, contains('assertion='));
    final messages = calls.skip(1).toList();
    expect(
      messages.map((c) => c.$1.path),
      everyElement('/v1/projects/tbt-test/messages:send'),
    );
    expect(messages.map((c) => c.$3), everyElement('g-token'));
    final first = (messages.first.$2 as Map)['message'] as Map;
    expect(first['token'], 'may-1');
    expect(
      (first['notification'] as Map)['body'],
      'Lương kỳ 2026-10 đã được chi',
    );
  });

  test('máy đã gỡ app (UNREGISTERED) thì xóa mã', () async {
    when(() => devices.devicesFor(any())).thenAnswer(
      (_) async => [(token: 'cu', language: 'vi')],
    );
    answers.addAll([
      (code: 200, body: jsonEncode({'access_token': 't', 'expires_in': 3600})),
      (
        code: 404,
        body: '{"error":{"details":[{"errorCode":"UNREGISTERED"}]}}',
      ),
    ]);

    await sender().send(_payroll);

    verify(() => devices.removeDevice('cu')).called(1);
  });

  test('không có máy nào thì không xin token', () async {
    when(() => devices.devicesFor(any())).thenAnswer((_) async => []);
    await sender().send(_payroll);
    expect(calls, isEmpty);
  });

  test('JWT gửi Google có đủ 3 phần, đúng người ký và phạm vi FCM', () {
    final jwt = sender().signedAssertion(DateTime.utc(2026, 10, 15));
    final parts = jwt.split('.');
    expect(parts, hasLength(3));
    final claims = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    ) as Map<String, dynamic>;
    expect(claims['iss'], 'push@tbt-test.iam.gserviceaccount.com');
    expect(claims['scope'], contains('firebase.messaging'));
    expect((claims['exp'] as int) - (claims['iat'] as int), 3600);
  });
}
