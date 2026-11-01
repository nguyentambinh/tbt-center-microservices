/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-11-01
 */

import 'dart:io';

import 'package:admin_service/src/accounts.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

/// POST /users/{id}/impersonate  phiên ngắn của tài khoản cấp dưới, ghi sổ
/// kiểm toán ai vào tài khoản nào
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(HttpStatus.methodNotAllowed, 'method_not_allowed', 'POST');
  }
  final claims = context.read<Claims>();
  final keycloak = context.read<KeycloakUsers>();
  try {
    final target = await keycloak.user(id);
    final refusal = impersonationRefusal(
      actor: claims,
      target: target,
      targetRoles: await keycloak.roles(id),
      serviceRegion: context.read<String>(),
    );
    if (refusal != null) {
      return apiError(HttpStatus.forbidden, refusal, 'Not allowed');
    }
    final session = await keycloak.impersonate(id);
    await context.read<Database>().transaction(
      (tx) => addOutboxEvent(
        tx,
        aggregate: 'account',
        aggregateId: id,
        eventType: 'AccountImpersonated',
        payload: {'username': target.username, 'by': claims.username},
      ),
    );
    return Response.json(
      body: {
        'accessToken': session.accessToken,
        'expiresIn': session.expiresIn,
        'by': claims.username,
      },
    );
  } on KeycloakException catch (e) {
    if (e.status == HttpStatus.notFound) {
      return apiError(HttpStatus.notFound, 'not_found', 'No account $id');
    }
    return apiError(
      HttpStatus.badGateway,
      'identity_unavailable',
      'Keycloak is not reachable',
    );
  }
}
