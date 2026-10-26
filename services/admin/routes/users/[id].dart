/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'dart:io';

import 'package:admin_service/src/accounts.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

/// PATCH /users/{id}  {enabled, addRoles, removeRoles}  khóa, mở tài khoản,
/// gán, gỡ vai trò; ghi sổ kiểm toán
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.patch) {
    return apiError(HttpStatus.methodNotAllowed, 'method_not_allowed', 'PATCH');
  }
  final Map<String, dynamic> body;
  try {
    body = await context.request.json() as Map<String, dynamic>;
  } on Object {
    return apiError(HttpStatus.badRequest, 'invalid_body', 'JSON object');
  }
  Set<String> names(String key) => {
    for (final r in body[key] as List? ?? const []) '$r',
  };
  final add = names('addRoles');
  final remove = names('removeRoles');
  final enabled = body['enabled'];
  final claims = context.read<Claims>();
  final keycloak = context.read<KeycloakUsers>();
  try {
    final target = await keycloak.user(id);
    final refusal = accountChangeRefusal(
      actor: claims,
      target: target,
      serviceRegion: context.read<String>(),
      add: add,
      remove: remove,
    );
    if (refusal != null) {
      return apiError(HttpStatus.forbidden, refusal, 'Change not allowed');
    }
    if (enabled is bool) await keycloak.setEnabled(id, enabled: enabled);
    await keycloak.addRoles(id, add);
    await keycloak.removeRoles(id, remove);
    await context.read<Database>().transaction(
      (tx) => addOutboxEvent(
        tx,
        aggregate: 'account',
        aggregateId: id,
        eventType: 'AccountChanged',
        payload: {
          'username': target.username,
          'enabled': enabled,
          'addRoles': add.toList(),
          'removeRoles': remove.toList(),
          'by': claims.username,
        },
      ),
    );
    return Response.json(
      body: {
        ...(await keycloak.user(id)).toJson(),
        'roles': await keycloak.roles(id),
      },
    );
  } on KeycloakException catch (e) {
    return e.status == HttpStatus.notFound
        ? apiError(HttpStatus.notFound, 'not_found', 'No such account')
        : apiError(
            HttpStatus.badGateway,
            'identity_unavailable',
            'Account service is not reachable',
          );
  }
}
