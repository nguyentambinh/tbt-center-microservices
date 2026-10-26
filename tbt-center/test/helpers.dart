/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbtcenter/app.dart';
import 'package:tbtcenter/core/auth/auth_controller.dart';
import 'package:tbtcenter/core/auth/auth_gateway.dart';
import 'package:tbtcenter/core/auth/session.dart';
import 'package:tbtcenter/core/locale/geo_service.dart';
import 'package:tbtcenter/core/locale/locale_providers.dart';
import 'package:tbtcenter/core/network/connection_monitor.dart';
import 'package:tbtcenter/core/push/push_service.dart';
import 'package:tbtcenter/features/notification/domain/entities/app_notification.dart';
import 'package:tbtcenter/features/notification/domain/repositories/notification_repository.dart';
import 'package:tbtcenter/features/notification/presentation/providers/notification_providers.dart';
import 'package:tbtcenter/features/hr/domain/entities/employee.dart';
import 'package:tbtcenter/features/organization/data/organization_repository.dart';
import 'package:tbtcenter/features/organization/domain/organization.dart';
import 'package:tbtcenter/features/organization/presentation/providers/organization_providers.dart';
import 'package:tbtcenter/features/profile/data/profile_repository.dart';
import 'package:tbtcenter/features/profile/domain/change_request.dart';
import 'package:tbtcenter/features/profile/presentation/providers/profile_providers.dart';

/// Tạo access token giả có cùng dạng với token Keycloak (không có chữ ký thật).
String fakeJwt({
  String username = 'hr.vn',
  List<String> roles = const ['hr', 'employee'],
  String region = 'vn',
  String givenName = 'Nhan',
  String? employeeId,
}) {
  String part(Map<String, dynamic> json) => base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  return '${part({'alg': 'RS256'})}.${part({
    'sub': 'id-$username',
    'preferred_username': username,
    'given_name': givenName,
    'region': region,
    'country_code': region.toUpperCase(),
    // Người có hồ sơ nhân viên mang employee_id như token thật
    'employee_id': employeeId ?? (roles.any({'employee', 'hr', 'finance'}.contains) ? 'TEST0001' : null),
    'realm_access': {'roles': [...roles, 'default-roles-tbt']},
  })}.chu-ky';
}

Session fakeSession({String token = '', Duration validFor = const Duration(minutes: 15), List<String>? roles}) {
  return Session(
    accessToken: token.isEmpty ? fakeJwt(roles: roles ?? const ['hr', 'employee']) : token,
    refreshToken: 'refresh',
    idToken: 'id',
    expiresAt: DateTime.now().add(validFor),
  );
}

class MemorySessionStore implements SessionStore {
  MemorySessionStore([this.session]);

  Session? session;

  @override
  Future<Session?> read() async => session;

  @override
  Future<void> write(Session value) async => session = value;

  @override
  Future<void> clear() async => session = null;
}

class FakeAuthGateway implements AuthGateway {
  Session Function() onSignIn = fakeSession;
  Session Function(Session)? onRefresh;
  int refreshCount = 0;
  bool signedOut = false;

  /// Ngôn ngữ app gửi kèm lần đăng nhập gần nhất.
  String? lastLocale;

  @override
  Future<Session> signIn({bool register = false, String? locale}) async {
    lastLocale = locale;
    return onSignIn();
  }

  int passwordChanges = 0;

  @override
  Future<Session> changePassword({String? locale}) async {
    passwordChanges++;
    return onSignIn();
  }

  @override
  Future<Session> refresh(Session session) async {
    refreshCount++;
    final handler = onRefresh;
    if (handler == null) throw const SessionExpired();
    return handler(session);
  }

  @override
  Future<void> signOut(Session session) async => signedOut = true;
}

class FakeProbe extends ConnectionProbe {
  bool internetUp = false;
  bool serverUp = false;

  @override
  Future<bool> internet() async => internetUp;

  @override
  Future<bool> server() async => serverUp;
}

/// Hộp thông báo giả; mặc định trống để màn chính không gọi mạng.
class FakeNotificationRepository implements NotificationRepository {
  FakeNotificationRepository([this.items = const []]);

  List<AppNotification> items;
  int markAllCalls = 0;

  @override
  Future<Inbox> inbox() async => Inbox(items: items, unread: items.where((n) => !n.read).length);

  final readIds = <String>[];

  @override
  Future<void> markRead(List<String> ids) async {
    readIds.addAll(ids);
    items = [
      for (final n in items) AppNotification(id: n.id, kind: n.kind, params: n.params, createdAt: n.createdAt, read: n.read || ids.contains(n.id)),
    ];
  }

  @override
  Future<void> markAllRead() async {
    markAllCalls++;
    items = [
      for (final n in items) AppNotification(id: n.id, kind: n.kind, params: n.params, createdAt: n.createdAt, read: true),
    ];
  }
}

/// Hồ sơ và đề xuất sửa thông tin giả: ghi lại đề xuất gửi lên, HR duyệt được
class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({List<ChangeRequest>? items}) : items = items ?? [];

  final List<ChangeRequest> items;
  final submitted = <Map<String, Object?>>[];
  final decided = <(int, bool)>[];

  @override
  Future<EmployeeDetail> me() async => EmployeeDetail(
        summary: const EmployeeSummary(id: 'Anh8715OP', familyName: 'Nguyễn', givenName: 'Anh', email: 'anh@vn.tbt.local', position: 'Kỹ sư'),
        contact: const {'phone': '0901234567', 'address': 'Thủ Dầu Một'},
        health: const {'heightCm': 170, 'weightKg': 65},
      );

  @override
  Future<List<ChangeRequest>> myRequests() async => items;

  @override
  Future<ChangeRequest> submit(Map<String, Object?> changes, {String? reason}) async {
    submitted.add(changes);
    final r = ChangeRequest(id: items.length + 1, employeeId: 'Anh8715OP', employeeName: 'Nguyễn Anh', changes: changes, status: 'pending', requestedAt: DateTime.now(), reason: reason);
    items.add(r);
    return r;
  }

  @override
  Future<List<ChangeRequest>> requests({String? status}) async => [for (final r in items) if (status == null || r.status == status) r];

  @override
  Future<ChangeRequest> decide(int id, {required bool approve, String? note}) async {
    decided.add((id, approve));
    final i = items.indexWhere((r) => r.id == id);
    final r = items[i];
    items[i] = ChangeRequest(id: r.id, employeeId: r.employeeId, employeeName: r.employeeName, changes: r.changes, status: approve ? 'approved' : 'rejected', requestedAt: r.requestedAt, note: note);
    return items[i];
  }
}

/// Phòng ban giả: PB1 có trưởng phòng A và hai thành viên, một người mới chưa có phòng
class FakeOrganizationRepository implements OrganizationRepository {
  @override
  Future<OrgTree> orgTree() async => OrgTree(departments: [
        TreeDepartment(id: 'PB01', name: 'Phòng Kỹ thuật', company: 'TBT Center', people: const [
          TreePerson(id: 'NV001', name: 'Trần Văn An', level: 4, position: 'Trưởng phòng', isHead: true, departmentId: 'PB01', departmentName: 'Phòng Kỹ thuật'),
          TreePerson(id: 'NV002', name: 'Lê Minh Thư', level: 2, position: 'Kỹ sư kết cấu', departmentId: 'PB01', departmentName: 'Phòng Kỹ thuật'),
        ]),
        TreeDepartment(id: 'PB02', name: 'Phòng Tài chính', company: 'TBT Center', people: const [
          TreePerson(id: 'NV003', name: 'Phạm Quốc Huy', level: 1, position: 'Kế toán', departmentId: 'PB02', departmentName: 'Phòng Tài chính'),
        ]),
      ]);

  @override
  Future<List<({String id, String name, int level})>> positionsAbove(String employeeId) async => const [
        (id: 'LV3-DEPUTY', name: 'Phó phòng', level: 3),
        (id: 'LV4-HEAD', name: 'Trưởng phòng', level: 4),
      ];

  final transfers = <(String, List<String>)>[];
  final archived = <String>[];
  final decisions = <(int, bool)>[];

  static const _members = [
    OrgPerson(id: 'E1', name: 'Nguyễn Văn A', position: 'Kỹ sư', isHead: true, totalHours: 120),
    OrgPerson(id: 'E2', name: 'Trần Thị B', position: 'Kỹ sư', totalHours: 300),
    OrgPerson(id: 'E3', name: 'Lê Văn C', position: 'Thợ hàn', totalHours: 80),
  ];

  @override
  Future<List<Department>> departments() async => const [
        Department(id: 'PB1', name: 'Phòng Kỹ thuật', companyId: 'C1', company: 'TBT Việt Nam', headId: 'E1', headName: 'Nguyễn Văn A', members: 3),
        Department(id: 'PB2', name: 'Phòng Thi công', companyId: 'C1', company: 'TBT Việt Nam', members: 1),
      ];

  @override
  Future<DepartmentDetail> department(String id) async =>
      DepartmentDetail(department: (await departments()).firstWhere((d) => d.id == id), members: id == 'PB1' ? _members : const [OrgPerson(id: 'E9', name: 'Phạm D')]);

  @override
  Future<Department> createDepartment(String name, String companyId) async => Department(id: 'PB9', name: name, companyId: companyId);

  @override
  Future<void> dissolve(String id, {required String reasonCode, String? note, String? mergeInto}) async {}

  @override
  Future<({List<String> moved, List<String> failed})> transfer(String departmentId, List<String> employeeIds) async {
    transfers.add((departmentId, employeeIds));
    return (moved: employeeIds, failed: <String>[]);
  }

  @override
  Future<void> setHead(String departmentId, String employeeId) async {}

  @override
  Future<List<OrgPerson>> unassigned() async => const [OrgPerson(id: 'N1', name: 'Võ Mới', position: 'Kỹ sư')];

  @override
  Future<PlacementSuggestion> suggest({required String language}) async => const PlacementSuggestion(
        assignments: [(employeeId: 'N1', departmentId: 'PB1', reason: 'Cùng chức vụ Kỹ sư')],
        newDepartments: [],
        source: 'gemini',
      );

  @override
  Future<List<OrgPerson>> rankings({int months = 3, String? departmentId}) async => const [
        OrgPerson(id: 'E2', name: 'Trần Thị B', workHours: 300, days: 40, score: 380, rank: 1),
        OrgPerson(id: 'E1', name: 'Nguyễn Văn A', workHours: 120, days: 15, score: 150, rank: 2),
      ];

  @override
  Future<EmployeeFilters> filters() async => const EmployeeFilters(
        departments: [(id: 'PB1', name: 'Phòng Kỹ thuật')],
        positions: [(id: 'CV1', name: 'Kỹ sư')],
        companies: [(id: 'C1', name: 'TBT Việt Nam')],
      );

  @override
  Future<List<Map<String, dynamic>>> projectsOf(String employeeId) async => [
        {'projectId': 'DA1', 'name': 'Cầu Thủ Thiêm 4'},
      ];

  @override
  Future<int> archive(String employeeId, String reason) async {
    archived.add(employeeId);
    return 1;
  }

  @override
  Future<void> restore(String employeeId) async {}

  @override
  Future<List<Nomination>> nominations({String? status}) async => [
        if (status == null || status == 'pending')
          const Nomination(id: 1, employeeId: 'E2', employeeName: 'Trần Thị B', currentPosition: 'Kỹ sư', proposedPosition: 'Trưởng nhóm', raisePercent: 10, reason: 'Giờ làm cao nhất', status: 'pending'),
      ];

  @override
  Future<void> nominate({required String employeeId, required String proposedPosition, required double raisePercent, required String reason, String? groupRole}) async {}

  @override
  Future<bool> decideNomination(int id, {required bool approve, String? note}) async {
    decisions.add((id, approve));
    return true;
  }
}

/// Các override để app chạy trong test mà không gọi mạng, không cần plugin Android.
Future<List<Override>> testOverrides({
  String? language,
  GeoResult? geo,
  SessionStore? store,
  AuthGateway? gateway,
  ConnectionProbe? probe,
  NotificationRepository? notifications,
  ProfileRepository? profile,
  OrganizationRepository? organization,
}) async {
  SharedPreferences.setMockInitialValues({'language': ?language});
  final prefs = await SharedPreferences.getInstance();
  return [
    sharedPreferencesProvider.overrideWithValue(prefs),
    geoProvider.overrideWith((ref) async => geo),
    sessionStoreProvider.overrideWithValue(store ?? MemorySessionStore()),
    authGatewayProvider.overrideWithValue(gateway ?? FakeAuthGateway()),
    connectionProbeProvider.overrideWithValue(probe ?? FakeProbe()),
    notificationRepositoryProvider.overrideWithValue(notifications ?? FakeNotificationRepository()),
    pushServiceProvider.overrideWithValue(const NoPushService()),
    profileRepositoryProvider.overrideWithValue(profile ?? FakeProfileRepository()),
    organizationRepositoryProvider.overrideWithValue(organization ?? FakeOrganizationRepository()),
    regionOrganizationProvider.overrideWith((ref, _) => organization ?? FakeOrganizationRepository()),
  ];
}

Future<void> pumpApp(
  WidgetTester tester, {
  String? language,
  GeoResult? geo,
  SessionStore? store,
  AuthGateway? gateway,
  ConnectionProbe? probe,
  List<Override> extraOverrides = const [],
}) async {
  final overrides = await testOverrides(
      language: language, geo: geo, store: store, gateway: gateway, probe: probe);
  await tester.pumpWidget(ProviderScope(overrides: [...overrides, ...extraOverrides], child: const TbtApp()));
  await tester.pumpAndSettle();
}

/// Bấm một thẻ ở màn chính; cuộn tới thẻ trước vì danh sách thẻ dài hơn màn hình test.
Future<void> openHomeCard(WidgetTester tester, String title) async {
  final card = find.widgetWithText(ListTile, title);
  await tester.scrollUntilVisible(card, 200, scrollable: find.byType(Scrollable).first);
  await tester.ensureVisible(card);
  await tester.pumpAndSettle();
  await tester.tap(card);
  await tester.pumpAndSettle();
}
