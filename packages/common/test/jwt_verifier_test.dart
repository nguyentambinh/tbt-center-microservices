/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

class _MockContext extends Mock implements RequestContext {}

// Khóa RSA 2048 bit tạo riêng cho test bằng openssl; token ký bằng khóa đó,
// hạn tới năm 2100.
const _n =
    'yHZP5GUIFGBU4yKqKei49wMPbjWKv5MOiYZcjz0ckcUDcf2Id09riGYrC9dnO9Pj'
    'ejj0XE2xqHfs0dfQ5GsvYrZI_nyJNX6o8RqflmQrx6fPEDJXP3NAi1c2kzf0-SNB'
    'WetsxRX2sEla_Q4VoHKzgLkZZpkveCr4BJDxk3nXjdGyE4yEpXHnLS_UuhUMEbVh'
    'GCXIx0MH7jjzwKBae2m2CMjgjl733CLKbwW6HHgE9dqVynsA1wY5vPiVkZ6kcB6H'
    'ysRm0xgxhCoZ1u2J6eJOFQCSaj646vwPWSLKEcDdwmQe_dXweLPLvqgWMYIKdosc'
    'Rb1uEdYmg2V-9b6MW4XvmQ';
const _token =
    'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6InRlc3Qta2V5In0.eyJp'
    'c3MiOiJodHRwOi8vbG9jYWxob3N0OjgxODAvcmVhbG1zL3RidCIsInN1YiI6InN1'
    'Yi0xIiwiZXhwIjo0MTAyNDQ0ODAwLCJyZWdpb24iOiJ2biIsInJlYWxtX2FjY2Vz'
    'cyI6eyJyb2xlcyI6WyJociJdfX0.vA7na5gsNoVkAHDgoBTl_QjIAaDNXWI017s7'
    'L8p47_sSunECBvJmH_mQWzUAaDzUoNbwmwp8uUXlGpz5kELKbXoaEqHd7G-xvQk7'
    '_rIMqmPtLO6kxIpocmQE_JNofTiMEsEN8Y-1mYcrnUQvLlEAYz4v6fvozPLn7BLV'
    'Za7-1cYai9IcirUbxd4zgpbgR1rutOoH_rc5i1kwA0PXGSGqAlnReAmRvQLljwsT'
    'ZsUSShPzcNEShps2NSB2JUdS4VCpQruKw738qoCJ-1EbrzoXVKX0o1jXW90-d0Us'
    'jMSDgrGNPA69voVo_laJbvW2Ezf-Kk9yhH5NqlzN6QMspPC6yA';

const _issuer = 'http://localhost:8180/realms/tbt';

JwtVerifier _verifier({void Function()? onFetch}) => JwtVerifier(
  jwksUrl: Uri.parse('http://keycloak/certs'),
  issuer: _issuer,
  fetch: (_) async {
    onFetch?.call();
    return {
      'keys': [
        {'kid': 'test-key', 'kty': 'RSA', 'use': 'sig', 'n': _n, 'e': 'AQAB'},
      ],
    };
  },
);

/// Kẻ gian giải mã phần nội dung, tự đổi vai trò hr thành admin, mã hóa lại
/// và giữ chữ ký cũ.
String _tampered() {
  final parts = _token.split('.');
  final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
  final forged = base64Url
      .encode(utf8.encode(payload.replaceFirst('"hr"', '"admin"')))
      .replaceAll('=', '');
  return '${parts[0]}.$forged.${parts[2]}';
}

void main() {
  test('token ký đúng khóa của Keycloak thì hợp lệ', () async {
    expect(await _verifier().check(_token), isNull);
  });

  test('sửa nội dung token (ví dụ tự thêm vai trò) thì sai chữ ký', () async {
    expect(await _verifier().check(_tampered()), 'bad_signature');
  });

  test('token tự ký không có chữ ký thật thì bị từ chối', () async {
    final parts = _token.split('.');
    expect(
      await _verifier().check('${parts[0]}.${parts[1]}.AAAA'),
      'bad_signature',
    );
  });

  test('đã hết hạn thì bị từ chối', () async {
    final late = JwtVerifier(
      jwksUrl: Uri.parse('http://keycloak/certs'),
      issuer: _issuer,
      fetch: (_) async => {'keys': <Object>[]},
      clock: () => DateTime.utc(2101),
    );
    expect(await late.check(_token), 'expired');
  });

  test('khác người phát hành thì bị từ chối', () async {
    final other = JwtVerifier(
      jwksUrl: Uri.parse('http://keycloak/certs'),
      issuer: 'http://evil/realms/tbt',
    );
    expect(await other.check(_token), 'wrong_issuer');
  });

  test('khóa công khai được nhớ lại, không tải lại mỗi request', () async {
    var fetches = 0;
    final verifier = _verifier(onFetch: () => fetches++);
    await verifier.check(_token);
    await verifier.check(_token);
    expect(fetches, 1);
  });

  test(
    'requireClaims trả 401 khi token bị sửa, cho qua khi token đúng',
    () async {
      Future<Response> call(String token) async {
        final context = _MockContext();
        when(() => context.request).thenReturn(
          Request(
            'GET',
            Uri.parse('http://localhost/x'),
            headers: {'authorization': 'Bearer $token'},
          ),
        );
        when(() => context.provide<Claims>(any())).thenReturn(context);
        final middleware = requireClaims(
          anyRole: {'hr'},
          region: 'vn',
          verifier: _verifier(),
        );
        return middleware((_) => Response())(context);
      }

      expect((await call(_token)).statusCode, 200);
      expect((await call(_tampered())).statusCode, 401);
    },
  );
  group('signRs256', () {
    // Khóa RSA 1024 bit tạo riêng cho test, không dùng ở đâu khác
    const pem = '''
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

    test('ký xong kiểm lại bằng verifyRs256 thì đúng', () {
      final key = rsaPrivateKeyFromPem(pem);
      final message = utf8.encode('header.payload');
      final signature = signRs256(key.n, key.d, message);
      expect(verifyRs256(key.n, key.e, message, signature), isTrue);
      expect(
        verifyRs256(key.n, key.e, utf8.encode('khac'), signature),
        isFalse,
      );
    });
  });
}
