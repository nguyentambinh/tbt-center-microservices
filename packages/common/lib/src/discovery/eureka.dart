/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-17
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

/// Một bản đang chạy của service, lấy từ Eureka
class ServiceInstance {
  const ServiceInstance({
    required this.id,
    required this.host,
    required this.port,
    required this.region,
  });

  final String id;
  final String host;
  final int port;
  final String region;

  Uri get baseUrl => Uri.parse('http://$host:$port/');
}

/// Đọc danh sách instance từ JSON của `GET /eureka/apps/{APP}`
List<ServiceInstance> parseInstances(Map<String, dynamic> json) {
  final app = json['application'] as Map<String, dynamic>? ?? const {};
  final raw = app['instance'];
  final list = raw is List ? raw : (raw == null ? const [] : [raw]);
  return [
    for (final i in list.cast<Map<String, dynamic>>())
      if (i['status'] == 'UP')
        ServiceInstance(
          id: i['instanceId'] as String? ?? '',
          host: i['ipAddr'] as String? ?? i['hostName'] as String? ?? '',
          port: switch (i['port']) {
            {r'$': final int p} => p,
            {r'$': final String p} => int.tryParse(p) ?? 8080,
            _ => 8080,
          },
          region:
              ((i['metadata'] as Map<String, dynamic>?)?['region']
                  as String?) ??
              '',
        ),
  ];
}

/// Sổ đăng ký service (Service Discovery) dùng Eureka:
/// service tự đăng ký khi khởi động, gửi nhịp tim 30 giây một lần, tắt thì gỡ;
/// bên gọi hỏi Eureka để biết các bản đang chạy rồi chia đều lượt gọi
class EurekaClient {
  EurekaClient(this.baseUrl, {required this.region, HttpClient? http})
    : _http =
          http ??
          (HttpClient()..connectionTimeout = const Duration(seconds: 3));

  /// null khi không cấu hình EUREKA_URL
  static EurekaClient? fromEnvironment([Map<String, String>? env]) {
    final e = env ?? Platform.environment;
    final url = e['EUREKA_URL'];
    if (url == null || url.isEmpty) return null;
    return EurekaClient(
      Uri.parse(url.endsWith('/') ? url : '$url/'),
      region: e['REGION'] ?? 'hub',
    );
  }

  static final EurekaClient? shared = fromEnvironment();

  final Uri baseUrl;
  final String region;
  final HttpClient _http;
  final _cache = <String, ({DateTime at, List<ServiceInstance> items})>{};
  final _next = <String, int>{};
  Timer? _heartbeat;

  /// Đăng ký service này; lỗi thì thử lại ở nhịp tim sau, service vẫn chạy
  Future<void> register(String app, {int port = 8080}) async {
    final ip = await _localIp();
    final host = Platform.localHostname;
    final id = '$host:$app:$port';
    final body = {
      'instance': {
        'instanceId': id,
        'hostName': ip,
        'app': app.toUpperCase(),
        'ipAddr': ip,
        'vipAddress': app,
        'status': 'UP',
        'port': {r'$': port, '@enabled': 'true'},
        'securePort': {r'$': 443, '@enabled': 'false'},
        'healthCheckUrl': 'http://$ip:$port/',
        'statusPageUrl': 'http://$ip:$port/',
        'homePageUrl': 'http://$ip:$port/',
        'dataCenterInfo': {
          '@class': r'com.netflix.appinfo.InstanceInfo$DefaultDataCenterInfo',
          'name': 'MyOwn',
        },
        'leaseInfo': {'renewalIntervalInSecs': 30, 'durationInSecs': 90},
        'metadata': {'region': region},
      },
    };
    final appPath = 'apps/${app.toUpperCase()}';
    Future<void> send() async {
      try {
        // Nhịp tim; Eureka quên mình (404) thì đăng ký lại
        final beat = await _call('PUT', '$appPath/$id');
        if (beat == 200) return;
        final status = await _call('POST', appPath, body: body);
        if (status == 204) stdout.writeln('Đã đăng ký $app với Eureka ($ip)');
      } on Object catch (e) {
        stderr.writeln('Chưa đăng ký được với Eureka: $e');
      }
    }

    await send();
    _heartbeat?.cancel();
    _heartbeat = Timer.periodic(const Duration(seconds: 30), (_) => send());
    // Tắt container thì gỡ khỏi sổ ngay, bên gọi không gọi nhầm bản đã tắt
    ProcessSignal.sigterm.watch().first.then((_) async {
      _heartbeat?.cancel();
      await _call('DELETE', '$appPath/$id').catchError((_) => 0);
      exit(0);
    });
  }

  /// Các bản đang chạy của [app] ở khu vực này; nhớ 15 giây
  Future<List<ServiceInstance>> instances(String app) async {
    final key = app.toUpperCase();
    final cached = _cache[key];
    if (cached != null &&
        DateTime.now().difference(cached.at) < const Duration(seconds: 15)) {
      return cached.items;
    }
    final request = await _http.getUrl(baseUrl.resolve('apps/$key'))
      ..headers.set('accept', 'application/json');
    final response = await request.close().timeout(const Duration(seconds: 3));
    final text = await utf8.decodeStream(response);
    final items = response.statusCode == 200
        ? [
            for (final i in parseInstances(
              jsonDecode(text) as Map<String, dynamic>,
            ))
              if (i.region == region) i,
          ]
        : <ServiceInstance>[];
    _cache[key] = (at: DateTime.now(), items: items);
    return items;
  }

  /// Chọn lần lượt từng bản (round-robin); không có bản nào thì trả null
  Future<Uri?> pick(String app) async {
    final items = await instances(app);
    if (items.isEmpty) return null;
    final n = _next.update(app, (v) => v + 1, ifAbsent: () => 0);
    return items[n % items.length].baseUrl;
  }

  Future<int> _call(String method, String path, {Object? body}) async {
    final request = await _http.openUrl(method, baseUrl.resolve(path));
    request.headers.set('accept', 'application/json');
    if (body != null) {
      request.headers.contentType = ContentType.json;
      request.add(utf8.encode(jsonEncode(body)));
    }
    final response = await request.close().timeout(const Duration(seconds: 5));
    await response.drain<void>();
    return response.statusCode;
  }

  static Future<String> _localIp() async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
    );
    for (final i in interfaces) {
      for (final a in i.addresses) {
        if (!a.isLoopback) return a.address;
      }
    }
    return Platform.localHostname;
  }
}

/// Đăng ký service với Eureka một lần khi dựng pipeline; không cấu hình thì bỏ qua
Middleware serviceRegistry(String app) {
  final client = EurekaClient.shared;
  if (client != null) unawaited(client.register(app));
  return (handler) => handler;
}
