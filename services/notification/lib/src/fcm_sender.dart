/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';
import 'dart:io';

import 'package:notification_service/src/data/notification_repository.dart';
import 'package:notification_service/src/domain/notification_rules.dart';
import 'package:notification_service/src/push_messages.dart';
import 'package:notification_service/src/push_sender.dart';
import 'package:tbt_common/tbt_common.dart';

/// Khóa service account Firebase (file JSON tải từ Google)
class ServiceAccount {
  ServiceAccount(Map<String, dynamic> json)
    : projectId = json['project_id'] as String,
      email = json['client_email'] as String,
      tokenUri = Uri.parse(
        json['token_uri'] as String? ?? 'https://oauth2.googleapis.com/token',
      ),
      key = rsaPrivateKeyFromPem(json['private_key'] as String);

  final String projectId;
  final String email;
  final Uri tokenUri;
  final ({BigInt n, BigInt e, BigInt d}) key;
}

/// Kết quả một lần gọi HTTP
typedef HttpResult = ({int code, String body});

/// Gửi một yêu cầu POST; tách ra để test không cần mạng
typedef HttpPost = Future<HttpResult> Function(
  Uri url,
  Object body, {
  String? bearer,
});

/// Gửi FCM HTTP v1 tới mọi máy của người nhận
class FcmPushSender implements PushSender {
  FcmPushSender(this.account, this.devices, {HttpPost? post})
    : _post = post ?? _httpPost;

  final ServiceAccount account;
  final NotificationRepository devices;
  final HttpPost _post;
  String? _token;
  DateTime _expires = DateTime(2000);

  /// null khi chưa có file khóa (máy dev chưa cấu hình Firebase)
  static FcmPushSender? fromFile(String? path, NotificationRepository devices) {
    if (path == null || !File(path).existsSync()) return null;
    final json = jsonDecode(File(path).readAsStringSync());
    return FcmPushSender(ServiceAccount(json as Map<String, dynamic>), devices);
  }

  Uri get _sendUrl => Uri.parse(
    'https://fcm.googleapis.com/v1/projects/${account.projectId}/messages:send',
  );

  @override
  Future<void> send(NewNotification notification) async {
    final targets = await devices.devicesFor(notification.recipient);
    if (targets.isEmpty) return;
    final token = await _accessToken();
    for (final device in targets) {
      final text = pushText(notification, device.language);
      final result = await _post(_sendUrl, {
        'message': {
          'token': device.token,
          'notification': {'title': text.title, 'body': text.body},
          'data': {'kind': notification.kind},
          'android': {'priority': 'HIGH'},
        },
      }, bearer: token);
      // Máy gỡ app hoặc mã hết hạn thì xóa, lần sau khỏi gửi
      if (result.code == 404 || result.body.contains('UNREGISTERED')) {
        await devices.removeDevice(device.token);
      } else if (result.code >= 400) {
        stderr.writeln('FCM trả ${result.code}: ${result.body}');
      }
    }
  }

  /// Token Google sống 1 giờ, xin lại trước khi hết 1 phút
  Future<String> _accessToken() async {
    final now = DateTime.now();
    if (_token != null && now.isBefore(_expires)) return _token!;
    final result = await _post(
      account.tokenUri,
      'grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer'
      '&assertion=${signedAssertion(now)}',
    );
    if (result.code != 200) {
      throw HttpException('Google token ${result.code}: ${result.body}');
    }
    final json = jsonDecode(result.body) as Map<String, dynamic>;
    _token = json['access_token'] as String;
    _expires = now.add(Duration(seconds: (json['expires_in'] as int) - 60));
    return _token!;
  }

  /// JWT tự ký để đổi lấy token Google (OAuth 2.0 JWT bearer)
  String signedAssertion(DateTime now) {
    final seconds = now.millisecondsSinceEpoch ~/ 1000;
    String part(Map<String, Object> json) =>
        base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
    final header = part({'alg': 'RS256', 'typ': 'JWT'});
    final claims = part({
      'iss': account.email,
      'scope': 'https://www.googleapis.com/auth/firebase.messaging',
      'aud': account.tokenUri.toString(),
      'iat': seconds,
      'exp': seconds + 3600,
    });
    final unsigned = '$header.$claims';
    final signature = signRs256(
      account.key.n,
      account.key.d,
      utf8.encode(unsigned),
    );
    return '$unsigned.${base64Url.encode(signature).replaceAll('=', '')}';
  }
}

final _client = HttpClient()..connectionTimeout = const Duration(seconds: 10);

Future<HttpResult> _httpPost(Uri url, Object body, {String? bearer}) async {
  final request = await _client.postUrl(url);
  if (bearer != null) {
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $bearer');
  }
  if (body is String) {
    request.headers.contentType = ContentType(
      'application',
      'x-www-form-urlencoded',
    );
    request.write(body);
  } else {
    request.headers.contentType = ContentType.json;
    request.add(utf8.encode(jsonEncode(body)));
  }
  final response = await request.close().timeout(const Duration(seconds: 20));
  return (code: response.statusCode, body: await utf8.decodeStream(response));
}
