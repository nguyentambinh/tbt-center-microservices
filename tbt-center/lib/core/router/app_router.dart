/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/attendance/presentation/pages/attendance_page.dart';
import '../../features/audit/presentation/pages/audit_page.dart';
import '../../features/audit/presentation/providers/audit_providers.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/finance/presentation/pages/finance_page.dart';
import '../../features/finance/presentation/pages/supplier_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/hr/presentation/pages/employee_detail_page.dart';
import '../../features/hr/presentation/pages/employee_list_page.dart';
import '../../features/knowledge/presentation/pages/knowledge_page.dart';
import '../../features/notification/presentation/pages/notifications_page.dart';
import '../../features/payroll/presentation/pages/payroll_runs_page.dart';
import '../../features/project_contract/presentation/pages/my_projects_page.dart';
import '../../features/project_contract/presentation/pages/project_detail_page.dart';
import '../../features/project_contract/presentation/pages/projects_page.dart';
import '../../features/payroll/presentation/pages/payslips_page.dart';
import '../../features/report/presentation/pages/group_report_page.dart';
import '../../features/recruitment/presentation/pages/candidate_import_page.dart';
import '../../features/recruitment/presentation/pages/candidates_page.dart';
import '../../features/recruitment/presentation/pages/my_application_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../auth/auth_controller.dart';
import '../auth/session.dart';
import '../theme/role_gem.dart';
import '../widgets/tbt_logo.dart';

abstract final class Routes {
  static const splash = '/splash';
  static const login = '/login';
  static const home = '/';
  static const settings = '/settings';
  static const employees = '/employees';
  static const attendance = '/attendance';
  static const myApplication = '/my-application';
  static const candidates = '/candidates';
  static const payslips = '/payslips';
  static const payrollRuns = '/payroll-runs';
  static const groupReport = '/group-report';
  static const projects = '/projects';
  static const myProjects = '/my-projects';
  static const finance = '/finance';
  static const suppliers = '/suppliers';
  static const notifications = '/notifications';
  static const auditLog = '/audit-log';
  static const knowledge = '/knowledge';
}

/// Vai trò được xem hồ sơ nhân viên, khớp với quyền ở service hr.
const employeeViewerRoles = {'executive', 'admin', 'hr', 'finance'};

/// Vai trò được xem dự án, hợp đồng; khớp với service project_contract.
const projectViewerRoles = employeeViewerRoles;

/// Vai trò được xem số liệu tài chính (R23), khớp với service finance.
const financeViewerRoles = {'executive', 'admin', 'finance'};

/// Màn nào xem được khi chưa đăng nhập.
const _publicRoutes = {Routes.login, Routes.settings};

final appRouterProvider = Provider<GoRouter>((ref) {
  // Báo cho router tính lại redirect mỗi khi trạng thái đăng nhập đổi.
  final authChanged = ValueNotifier<int>(0);
  ref.listen(authControllerProvider, (_, _) => authChanged.value++);
  ref.onDispose(authChanged.dispose);

  return GoRouter(
    initialLocation: Routes.home,
    refreshListenable: authChanged,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final location = state.matchedLocation;
      if (auth.isLoading && !auth.hasValue) return location == Routes.splash ? null : Routes.splash;

      final signedIn = auth.value != null;
      if (!signedIn && !_publicRoutes.contains(location)) return Routes.login;
      if (signedIn && (location == Routes.login || location == Routes.splash)) return Routes.home;
      // Nhân viên thường, ứng viên gõ thẳng đường dẫn cũng không vào được màn nhân sự.
      final roles = auth.value?.roles ?? const <String>[];
      if (location.startsWith(Routes.employees) && !roles.any(employeeViewerRoles.contains)) return Routes.home;
      // Ứng viên, kiểm toán độc lập không phải nhân viên nên không có chấm công.
      final notStaff = !roles.any(staffRoles.contains);
      final employeeOnly = location.startsWith(Routes.attendance) ||
          location.startsWith(Routes.knowledge) ||
          location.startsWith(Routes.payslips) ||
          location.startsWith(Routes.myProjects);
      if (employeeOnly && notStaff) {
        return Routes.home;
      }
      const managementRoles = {'finance', 'admin', 'executive'};
      final managementOnly = location.startsWith(Routes.payrollRuns) || location.startsWith(Routes.groupReport);
      if (managementOnly && !roles.any(managementRoles.contains)) return Routes.home;
      if (location.startsWith(Routes.auditLog) && !roles.any(auditReaderRoles.contains)) return Routes.home;
      if (location.startsWith(Routes.projects) && !roles.any(projectViewerRoles.contains)) return Routes.home;
      final financeOnly = location.startsWith(Routes.finance) || location.startsWith(Routes.suppliers);
      if (financeOnly && !roles.any(financeViewerRoles.contains)) return Routes.home;
      if (location.startsWith(Routes.candidates) && !roles.any({'hr', 'admin', 'executive'}.contains)) {
        return Routes.home;
      }
      return null;
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const _SplashPage()),
      GoRoute(path: Routes.login, builder: (_, _) => const LoginPage()),
      GoRoute(path: Routes.home, builder: (_, _) => const HomePage()),
      GoRoute(path: Routes.settings, builder: (_, _) => const SettingsPage()),
      GoRoute(path: Routes.attendance, builder: (_, _) => const AttendancePage()),
      GoRoute(path: Routes.myApplication, builder: (_, _) => const MyApplicationPage()),
      GoRoute(
        path: Routes.candidates,
        builder: (_, _) => const CandidatesPage(),
        routes: [
          GoRoute(
            path: 'imports/:id',
            builder: (_, state) => CandidateImportPage(importId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(path: Routes.payslips, builder: (_, _) => const PayslipsPage()),
      GoRoute(path: Routes.payrollRuns, builder: (_, _) => const PayrollRunsPage()),
      GoRoute(path: Routes.groupReport, builder: (_, _) => const GroupReportPage()),
      GoRoute(path: Routes.auditLog, builder: (_, _) => const AuditPage()),
      GoRoute(path: Routes.notifications, builder: (_, _) => const NotificationsPage()),
      GoRoute(path: Routes.knowledge, builder: (_, _) => const KnowledgePage()),
      GoRoute(path: Routes.myProjects, builder: (_, _) => const MyProjectsPage()),
      GoRoute(path: Routes.finance, builder: (_, _) => const FinancePage()),
      GoRoute(
        path: '${Routes.suppliers}/:id',
        builder: (_, state) => SupplierPage(supplierId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: Routes.projects,
        builder: (_, _) => const ProjectsPage(),
        routes: [
          GoRoute(path: ':id', builder: (_, state) => ProjectDetailPage(projectId: state.pathParameters['id']!)),
        ],
      ),
      GoRoute(
        path: Routes.employees,
        builder: (_, _) => const EmployeeListPage(),
        routes: [
          GoRoute(path: ':id', builder: (_, state) => EmployeeDetailPage(employeeId: state.pathParameters['id']!)),
        ],
      ),
    ],
  );
});

class _SplashPage extends StatelessWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: TbtLogo(gem: RoleGem.gold, height: 130)));
  }
}
