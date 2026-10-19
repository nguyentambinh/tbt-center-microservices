/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-18
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:knowledge_service/src/graph/rdf.dart';
import 'package:knowledge_service/src/graph/reasoning_service.dart';
import 'package:knowledge_service/src/graph/sparql.dart';
import 'package:tbt_common/tbt_common.dart';

/// POST /sparql {"query": "SELECT ...", "inferred": true, "lang": "vi"}
/// Truy vấn đồ thị bằng SPARQL (chỉ đọc); GET ?query=... cũng được
Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  final String? text;
  var inferred = true;
  var lang = 'en';
  if (request.method == HttpMethod.get) {
    final q = request.uri.queryParameters;
    text = q['query'];
    inferred = q['inferred'] != 'false';
    lang = q['lang'] ?? lang;
  } else if (request.method == HttpMethod.post) {
    final body = await request.json();
    if (body is! Map<String, dynamic>) {
      return apiError(400, 'invalid_json', 'Body must be a JSON object');
    }
    text = body['query'] as String?;
    inferred = body['inferred'] as bool? ?? true;
    lang = body['lang'] as String? ?? lang;
  } else {
    return apiError(405, 'method_not_allowed', 'GET or POST only');
  }
  if (text == null || text.trim().isEmpty) {
    return apiError(400, 'missing_query', 'query is required');
  }
  if (text.length > 4000) {
    return apiError(400, 'query_too_long', 'At most 4000 chars');
  }
  final service = context.read<GraphReasoningService>();
  final watch = Stopwatch()..start();
  try {
    final result = await service.sparql(text, includeInferred: inferred);
    final g = await service.snapshot();
    return Response.json(
      body: {
        'vars': result.vars,
        'rows': [
          for (final row in result.rows)
            {
              for (final e in row.entries)
                e.key: switch (e.value) {
                  Iri() && final iri => {
                    'type': 'iri',
                    'value': iri.compact,
                    'label': ?g.labelOf(iri, lang),
                  },
                  Lit(:final value, lang: final tag) => {
                    'type': 'literal',
                    'value': value,
                    'lang': ?tag,
                  },
                },
            },
        ],
        'truncated': result.truncated,
        'ms': watch.elapsedMilliseconds,
      },
    );
  } on SparqlError catch (e) {
    return apiError(400, 'bad_query', e.message);
  }
}
