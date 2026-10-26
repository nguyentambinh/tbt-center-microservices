/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /users?q=  tài khoản của khu vực (tìm theo tên, email), kèm vai trò
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(HttpStatus.methodNotAllowed, 'method_not_allowed', 'GET');
  }
  final keycloak = context.read<KeycloakUsers>();
  final region = context.read<String>();
  final text = context.request.uri.queryParameters['q']?.trim();
  try {
    final users = await keycloak.search(
      text: text,
      attributes: text == null || text.isEmpty ? {'region': region} : const {},
      max: 60,
    );
    final inRegion = [
      for (final u in users)
        if (u.region == region || u.region == null) u,
    ];
    return Response.json(
      body: {
        'items': [
          for (final u in inRegion)
            {...u.toJson(), 'roles': await keycloak.roles(u.id)},
        ],
      },
    );
  } on KeycloakException {
    return apiError(
      HttpStatus.badGateway,
      'identity_unavailable',
      'Account service is not reachable',
    );
  }
}
