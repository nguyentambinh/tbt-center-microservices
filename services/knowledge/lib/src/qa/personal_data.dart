/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'dart:convert';
import 'dart:io';

/// Lấy dữ liệu của chính người hỏi theo chủ đề; trả JSON đã rút gọn
typedef PersonalFetch = Future<String> Function(String topic);

/// Chủ đề AI được tra, ứng với API của khu vực (dùng token của người hỏi nên
/// chỉ thấy đúng dữ liệu người đó được xem)
const personalTopics = {
  'profile': '/hr/me',
  'payroll': '/payroll/payslips',
  'attendance': '/attendance/calendar',
  'leaves': '/attendance/leave-requests',
  'projects': '/project-contract/me/projects',
  'raise_requests': '/payroll/raise-requests',
  'resignation': '/hr/resignations',
};

/// Claude chọn loại dữ liệu cần tra theo câu hỏi
const topicSchema = {
  'type': 'object',
  'additionalProperties': false,
  'required': ['topics'],
  'properties': {
    'topics': {
      'type': 'array',
      'items': {
        'type': 'string',
        'enum': [
          'profile',
          'payroll',
          'attendance',
          'leaves',
          'projects',
          'raise_requests',
          'resignation',
        ],
      },
    },
  },
};

/// Rút gọn JSON để gửi AI: danh sách giữ 31 phần tử đầu, chuỗi tối đa 8000
String compactJson(Object? data) {
  Object? trim(Object? v) => switch (v) {
    final List<dynamic> list => [for (final e in list.take(31)) trim(e)],
    final Map<String, dynamic> map => {
      for (final e in map.entries)
        // Không đưa đường dẫn tệp, link ký sẵn cho AI
        if (!e.key.toLowerCase().contains('url')) e.key: trim(e.value),
    },
    _ => v,
  };
  final text = jsonEncode(trim(data));
  return text.length <= 8000 ? text : text.substring(0, 8000);
}

/// Lịch tháng: đếm sẵn ngày công, giờ làm, ngày nghỉ để AI không tự đếm sai;
/// chỉ giữ ngày có chấm công, đơn nghỉ hoặc ngày lễ
Map<String, dynamic> summarizeCalendar(Object? data, {DateTime? today}) {
  final items = [
    for (final d in (data is Map ? data['items'] as List? : null) ?? const [])
      if (d is Map<String, dynamic>) d,
  ];
  num sum(String key) =>
      items.fold<num>(0, (a, d) => a + ((d[key] as num?) ?? 0));
  final worked = [
    for (final d in items)
      if (d['checkIn'] != null) d['date'] as String,
  ];
  final leave = [
    for (final d in items)
      if (d['leave'] != null) {'date': d['date'], ...d['leave'] as Map},
  ];
  return {
    'today': ?today?.toIso8601String().substring(0, 10),
    'daysWorked': worked.length,
    'workedDates': worked,
    'workHours': sum('workHours'),
    'overtimeHours': sum('overtimeHours'),
    'leaveDays': leave,
    'holidays': [
      for (final d in items)
        if (d['holiday'] != null) {'date': d['date'], 'name': d['holiday']},
    ],
    'days': [
      for (final d in items)
        if (d['checkIn'] != null || d['leave'] != null)
          {
            'date': d['date'],
            'in': d['checkIn'],
            'out': d['checkOut'],
            'hours': d['totalHours'],
          },
    ],
  };
}

/// Gọi API khu vực thay mặt người hỏi bằng chính token của họ
class PersonalData {
  PersonalData(this.baseUrlFor, {HttpClient? http})
    : _http =
          http ??
          (HttpClient()..connectionTimeout = const Duration(seconds: 8));

  /// `DOMAIN` có thì gọi https://{khu vực}.{DOMAIN}; không thì theo
  /// `REGION_API_URL` dạng http://host:port với {region}
  factory PersonalData.fromEnvironment() {
    final env = Platform.environment;
    final domain = env['DOMAIN'] ?? '';
    final template = env['REGION_API_URL'] ?? '';
    return PersonalData(
      (region) => domain.isNotEmpty
          ? Uri.parse('https://$region.$domain')
          : template.isNotEmpty
          ? Uri.parse(template.replaceAll('{region}', region))
          : null,
    );
  }

  final Uri? Function(String region) baseUrlFor;
  final HttpClient _http;

  PersonalFetch? forUser(String region, String bearer) {
    final base = baseUrlFor(region);
    if (base == null || bearer.isEmpty) return null;
    return (topic) async {
      final path = personalTopics[topic];
      if (path == null) return '{"error":"unknown topic"}';
      final now = DateTime.now();
      String day(DateTime d) => d.toIso8601String().substring(0, 10);
      final query = topic == 'attendance'
          ? {
              'from': day(DateTime(now.year, now.month)),
              'to': day(DateTime(now.year, now.month + 1, 0)),
            }
          : null;
      try {
        final request = await _http.getUrl(
          base.resolve(path).replace(queryParameters: query),
        );
        request.headers.set(HttpHeaders.authorizationHeader, bearer);
        final response = await request.close().timeout(
          const Duration(seconds: 10),
        );
        final body = await utf8.decodeStream(response);
        if (response.statusCode != 200) {
          return '{"error":"not available (HTTP ${response.statusCode})"}';
        }
        final data = jsonDecode(body);
        return compactJson(
          topic == 'attendance' ? summarizeCalendar(data, today: now) : data,
        );
      } on Object {
        return '{"error":"service not reachable"}';
      }
    };
  }
}
