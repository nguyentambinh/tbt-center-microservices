/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:project_contract_service/src/project_rules.dart';
import 'package:project_contract_service/src/proposals.dart';
import 'package:tbt_common/tbt_common.dart';

/// Tệp đính kèm dự án lớn nhất: 10 MB
const maxProjectFileBytes = 10 * 1024 * 1024;

/// Hợp đồng (PDF, Word) và ảnh công trình trong bucket tbt-media
class ProjectFiles {
  ProjectFiles({
    required this.presigner,
    required this.publicEndpoint,
    required this.internalEndpoint,
  });

  static ProjectFiles? fromEnvironment([Map<String, String>? environment]) {
    final env = environment ?? Platform.environment;
    final key = env['S3_ACCESS_KEY_ID'] ?? '';
    final secret = env['S3_SECRET_ACCESS_KEY'] ?? '';
    if (key.isEmpty || secret.isEmpty) return null;
    return ProjectFiles(
      presigner: S3Presigner(
        accessKeyId: key,
        secretAccessKey: secret,
        bucket: env['S3_MEDIA_BUCKET'] ?? 'tbt-media',
      ),
      publicEndpoint: Uri.parse(
        env['S3_PUBLIC_ENDPOINT'] ?? 'http://localhost:3900',
      ),
      internalEndpoint: Uri.parse(
        env['S3_INTERNAL_ENDPOINT'] ?? 'http://garage:3900',
      ),
    );
  }

  final S3Presigner presigner;
  final Uri publicEndpoint;
  final Uri internalEndpoint;

  Uri uploadUrl(String key) =>
      presigner.presign('PUT', key, endpoint: publicEndpoint);

  Uri downloadUrl(String key) => presigner.presign(
    'GET',
    key,
    endpoint: publicEndpoint,
  );

  /// `null` nếu không có object; ném lỗi khi quá [maxProjectFileBytes]
  Future<Uint8List?> read(String key) async {
    final client = HttpClient();
    try {
      final url = presigner.presign('GET', key, endpoint: internalEndpoint);
      final response = await (await client.getUrl(url)).close();
      if (response.statusCode == 404) {
        await response.drain<void>();
        return null;
      }
      if (response.statusCode != 200) {
        throw HttpException('S3 GET ${response.statusCode}');
      }
      final bytes = BytesBuilder(copy: false);
      await for (final chunk in response) {
        bytes.add(chunk);
        if (bytes.length > maxProjectFileBytes) {
          throw const HttpException('file too large');
        }
      }
      return bytes.takeBytes();
    } finally {
      client.close();
    }
  }
}

/// Nhân viên của khu vực ở hr: mã, tên, chức vụ, phòng ban
typedef LoadEmployees = Future<List<Map<String, dynamic>>> Function();

LoadEmployees hrEmployees(InternalClient hr) => () async {
  final body = await hr.get('/internal/placement');
  return (body['employees'] as List).cast<Map<String, dynamic>>();
};

/// AI đọc hợp đồng thành các ô của đề xuất, gợi ý nhân viên tham gia
class ProposalAdvisor {
  ProposalAdvisor({
    required this.ai,
    required this.employees,
    StructuredAi? reader,
  }) : reader = reader ?? ai;

  /// Chọn nhân viên (Haiku)
  final StructuredAi ai;

  /// Đọc hợp đồng PDF, Word (Sonnet)
  final StructuredAi reader;
  final LoadEmployees employees;

  static const _contractSchema = {
    'type': 'object',
    'properties': {
      'name': {'type': 'string'},
      'customerName': {'type': 'string'},
      'customerType': {
        'type': 'string',
        'enum': ['company', 'individual'],
      },
      'customerContact': {'type': 'string'},
      'contractType': {'type': 'string'},
      'value': {'type': 'number'},
      'deposit': {'type': 'number'},
      'currency': {'type': 'string'},
      'startDate': {'type': 'string'},
      'endDate': {'type': 'string'},
      'acceptanceDate': {'type': 'string'},
    },
    'required': ['name', 'customerName', 'value', 'startDate', 'endDate'],
  };

  static const _system =
      'You read construction contracts and fill a project form. Dates are '
      'ISO yyyy-MM-dd, money is a plain number in the contract currency '
      '(ISO 4217 code). Leave a field empty when the contract does not say.';

  /// Đọc PDF hoặc chữ trong Word; AI không dùng được thì trả rỗng để nhập tay
  Future<Map<String, dynamic>> readContract(
    Uint8List bytes, {
    required String fileName,
  }) async {
    const manual = {'fields': <String, dynamic>{}, 'source': 'manual'};
    if (!reader.configured) return manual;
    final isPdf =
        bytes.length > 4 && String.fromCharCodes(bytes.take(4)) == '%PDF';
    String? text;
    if (!isPdf) {
      try {
        text = docxText(bytes);
      } on Object {
        return manual;
      }
      if (text.trim().isEmpty) return manual;
    }
    final excerpt = text != null && text.length > 20000
        ? text.substring(0, 20000)
        : text;
    final result = await reader.generate(
      system: _system,
      user: isPdf
          ? 'Read the attached contract "$fileName".'
          : 'Contract "$fileName":\n\n$excerpt',
      schema: _contractSchema,
      pdf: isPdf ? bytes : null,
    );
    if (result == null) return manual;
    final fields = ProposalData.fromJson(result).json
      ..remove('memberIds')
      ..removeWhere((_, v) => v == null);
    return {'fields': fields, 'source': reader.lastProvider ?? 'ai'};
  }

  /// Chọn đủ số người tối thiểu của cấp dự án: AI chọn theo chức vụ và số dự
  /// án đang làm; lỗi thì lấy người ít việc nhất, xen kẽ các chức vụ
  Future<Map<String, dynamic>> suggestMembers({
    required String? projectName,
    required double valueUsd,
    required Map<String, int> load,
    required String language,
  }) async {
    final people = await employees();
    final tier = projectTier(valueUsd);
    final need = tierMinMembers[tier]! + (tier >= 3 ? 2 : 1);
    final rules = pickByLoad(people, load, need);
    final list = [
      for (final p in people)
        {
          'id': p['id'],
          'name': p['name'],
          'position': p['position'],
          'department': p['departmentId'],
          'activeProjects': load[p['id']] ?? 0,
        },
    ];
    Map<String, dynamic> answer(
      List<String> ids,
      String source,
      String? reason,
    ) => {
      'tier': tier,
      'minMembers': tierMinMembers[tier],
      'memberIds': ids,
      'reason': reason,
      'source': source,
      'employees': list,
    };
    if (!ai.configured || people.isEmpty) {
      return answer(rules, 'rules', null);
    }
    final result = await ai.generate(
      system:
          'You staff construction projects. Pick employees with suitable and '
          'varied positions, preferring people with fewer active projects. '
          'Reply in $language.',
      user: jsonEncode({
        'project': projectName,
        'tier': tier,
        'pick': need,
        'employees': list.take(300).toList(),
      }),
      schema: const {
        'type': 'object',
        'properties': {
          'memberIds': {
            'type': 'array',
            'items': {'type': 'string'},
          },
          'reason': {'type': 'string'},
        },
        'required': ['memberIds', 'reason'],
      },
    );
    final known = {for (final p in people) p['id']};
    final ids = {
      for (final id in result?['memberIds'] as List? ?? const [])
        if (known.contains(id)) id as String,
    }.toList();
    if (ids.length < tierMinMembers[tier]!) return answer(rules, 'rules', null);
    return answer(ids, ai.lastProvider ?? 'ai', result!['reason'] as String?);
  }

  /// Người ít dự án nhất trước, lần lượt từng chức vụ để nhóm đủ vai trò
  static List<String> pickByLoad(
    List<Map<String, dynamic>> people,
    Map<String, int> load,
    int need,
  ) {
    final byPosition = <String, List<Map<String, dynamic>>>{};
    for (final p in people) {
      (byPosition[p['position'] as String? ?? ''] ??= []).add(p);
    }
    for (final group in byPosition.values) {
      group.sort(
        (a, b) => (load[a['id']] ?? 0).compareTo(load[b['id']] ?? 0),
      );
    }
    final picked = <String>[];
    var round = 0;
    while (picked.length < need) {
      var added = false;
      for (final group in byPosition.values) {
        if (round < group.length && picked.length < need) {
          picked.add(group[round]['id'] as String);
          added = true;
        }
      }
      if (!added) break;
      round++;
    }
    return picked;
  }
}
