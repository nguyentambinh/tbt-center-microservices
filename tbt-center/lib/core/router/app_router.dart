/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import '../../features/organization/presentation/pages/org_tree_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/attendance/presentation/pages/attendance_page.dart';
import '../../features/attendance/presentation/pages/clock_stats_page.dart';
import '../../features/attendance/presentation/pages/work_calendar_page.dart';
import '../../features/audit/presentation/pages/audit_page.dart';
import '../../features/audit/presentation/providers/audit_providers.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/finance/presentation/pages/finance_page.dart';
import '../../features/group/group_overview_page.dart';
import '../../features/finance/presentation/pages/supplier_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/hr/presentation/pages/employee_detail_page.dart';
import '../../features/hr/presentation/pages/employee_list_page.dart';
import '../../features/knowledge/presentation/pages/knowledge_page.dart';
import '../../features/notification/presentation/pages/notifications_page.dart';
import '../../features/organization/presentation/pages/department_detail_page.dart';
import '../../features/organization/presentation/pages/departments_page.dart';
import '../../features/organization/presentation/pages/nominations_page.dart';
import '../../features/organization/presentation/pages/rankings_page.dart';
import '../../features/organization/presentation/pages/unassigned_page.dart';
import '../../features/payroll/presentation/pages/payroll_runs_page.dart';
import '../../features/profile/presentation/pages/change_requests_page.dart';
import '../../features/profile/presentation/pages/profile_edit_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/project_contract/presentation/pages/my_projects_page.dart';
import '../../features/project_contract/presentation/pages/project_detail_page.dart';
import '../../features/payroll/presentation/pages/raise_requests_page.dart';
import '../../features/project_contract/domain/entities/proposal.dart';
import '../../features/reports/presentation/report_submissions_page.dart';
import '../../features/resignations/presentation/resignations_page.dart';
import '../../features/admin/admin_console_page.dart';
import '../../features/approvals/approval_inbox_page.dart';
import '../../features/recruitment/presentation/pages/job_positions_page.dart';
import '../../features/project_contract/presentation/pages/project_charts_page.dart';
import '../../features/project_contract/presentation/pages/project_proposals_page.dart';
import '../../features/project_contract/presentation/pages/project_wizard_page.dart';
import '../../features/project_contract/presentation/pages/projects_page.dart';
import '../../features/payroll/presentation/pages/payslips_page.dart';
import '../../features/report/presentation/pages/group_report_page.dart';
import '../../features/recruitment/presentation/pages/candidate_import_page.dart';
import '../../features/recruitment/presentation/pages/candidates_page.dart';
import '../../features/recruitment/presentation/pages/my_application_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../auth/auth_controller.dart';
import '../theme/role_gem.dart';
import '../widgets/tbt_logo.dart';

abstract final class Routes {
  static const splash = '/splash';
  static const login = '/login';
  static const signup = '/signup';
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
  static const profile = '/profile';
  static const profileEdit = '/profile/edit';
  static const changeRequests = '/change-requests';
  static const departments = '/departments';
  static const unassigned = '/departments/unassigned';
  static const rankings = '/rankings';
  static const nominations = '/nominations';
  static const raiseRequests = '/raise-requests';
  static const reportSubmissions = '/report-submissions';
  static const resignations = '/resignations';
  static const approvals = '/approvals';
  static const jobPositions = '/job-positions';
  static const orgTree = '/org-tree';
  static const workCalendar = '/attendance/calendar';
  static const clockStats = '/attendance/stats';
  static const projectNew = '/projects/new';
  static const projectCharts = '/projects/charts';
  static const projectProposals = '/project-proposals';
  static const groupOverview = '/group-overview';
  static const adminConsole = '/admin';
}

/// Vai trò được xem hồ sơ nhân viên, khớp với quyền ở service hr.
const employeeViewerRoles = {'executive', 'hr', 'finance'};

/// Vai trò được xem dự án, hợp đồng; khớp với service project_contract.
const projectViewerRoles = employeeViewerRoles;

/// Vai trò được xem số liệu tài chính (R23), khớp với service finance.
const financeViewerRoles = {'executive', 'finance'};

/// Vai trò quản lý phòng ban, xếp hạng, đề cử; khớp với service hr.
const organizationRoles = {'hr', 'admin', 'executive'};

/// Duyệt, quản lý nhân sự (admin chỉ lo cấu hình, không làm nghiệp vụ)
const peopleManagerRoles = {'hr', 'executive'};

/// Màn nào xem được khi chưa đăng nhập.
const _publicRoutes = {Routes.login, Routes.signup, Routes.settings};

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
      // Việc cá nhân chỉ cho người có hồ sơ nhân viên; văn phòng quản lý, quản trị không có
      final session = auth.value;
      if (session == null) return null;
      final employeeOnly = location.startsWith(Routes.attendance) || location.startsWith(Routes.payslips) || location.startsWith(Routes.myProjects);
      if (employeeOnly && !session.isEmployee) return Routes.home;
      if (location.startsWith(Routes.knowledge) && !session.isEmployee && !roles.contains('executive')) return Routes.home;
      if (location.startsWith(Routes.payrollRuns) && !roles.any({'finance', 'executive'}.contains)) return Routes.home;
      if (location.startsWith(Routes.groupReport) && !(session.isGroup && roles.any({'finance', 'executive'}.contains))) return Routes.home;
      if (location.startsWith(Routes.groupOverview) && !(session.isGroup && roles.any({'hr', 'finance', 'executive'}.contains))) return Routes.home;
      if (location.startsWith(Routes.adminConsole) && !roles.contains('admin')) return Routes.home;
      if (location.startsWith(Routes.auditLog) && !roles.any(auditReaderRoles.contains)) return Routes.home;
      if (location.startsWith(Routes.projects) && !roles.any(projectViewerRoles.contains)) return Routes.home;
      if (location.startsWith(Routes.projectNew) && !roles.any(proposerRoles.contains)) return Routes.projects;
      if (location.startsWith(Routes.projectProposals) && !roles.any({...proposerRoles, 'executive'}.contains)) return Routes.home;
      if (location.startsWith(Routes.reportSubmissions) && !roles.any({'hr', 'finance', 'executive'}.contains)) return Routes.home;
      if (location.startsWith(Routes.raiseRequests) && !session.isEmployee && !roles.contains('executive')) return Routes.home;
      if (location.startsWith(Routes.resignations) && !session.isEmployee && !roles.contains('executive')) return Routes.home;
      if (location.startsWith(Routes.approvals) && !roles.contains('executive')) return Routes.home;
      if (location.startsWith(Routes.jobPositions) && !roles.any(peopleManagerRoles.contains)) return Routes.home;
      if (location.startsWith(Routes.orgTree) && !roles.any({'hr', 'finance', 'admin', 'executive'}.contains)) return Routes.home;
      final financeOnly = location.startsWith(Routes.finance) || location.startsWith(Routes.suppliers);
      if (financeOnly && !roles.any(financeViewerRoles.contains)) return Routes.home;
      if (location.startsWith(Routes.changeRequests) && !roles.any(peopleManagerRoles.contains)) return Routes.home;
      if (location.startsWith(Routes.departments) && !roles.any(organizationRoles.contains)) return Routes.home;
      final organizationOnly = location.startsWith(Routes.rankings) || location.startsWith(Routes.nominations);
      if (organizationOnly && !roles.any(peopleManagerRoles.contains)) return Routes.home;
      if (location.startsWith(Routes.candidates) && !roles.any(peopleManagerRoles.contains)) {
        return Routes.home;
      }
      return null;
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const _SplashPage()),
      GoRoute(path: Routes.login, builder: (_, _) => const LoginPage()),
      GoRoute(path: Routes.signup, builder: (_, _) => const SignupPage()),
      GoRoute(path: Routes.home, builder: (_, _) => const HomePage()),
      GoRoute(path: Routes.settings, builder: (_, _) => const SettingsPage()),
      GoRoute(
        path: Routes.attendance,
        builder: (_, state) => AttendancePage(openApprovals: state.uri.queryParameters['tab'] == 'approvals'),
        routes: [
          GoRoute(path: 'calendar', builder: (_, _) => const WorkCalendarPage()),
          GoRoute(path: 'stats', builder: (_, _) => const ClockStatsPage()),
        ],
      ),
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
      GoRoute(path: Routes.profile, builder: (_, _) => const ProfilePage()),
      GoRoute(path: Routes.profileEdit, builder: (_, _) => const ProfileEditPage()),
      GoRoute(path: Routes.changeRequests, builder: (_, _) => const ChangeRequestsPage()),
      GoRoute(path: Routes.unassigned, builder: (_, _) => const UnassignedPage()),
      GoRoute(
        path: Routes.departments,
        builder: (_, _) => const DepartmentsPage(),
        routes: [
          GoRoute(path: ':id', builder: (_, state) => DepartmentDetailPage(departmentId: state.pathParameters['id']!)),
        ],
      ),
      GoRoute(path: Routes.rankings, builder: (_, _) => const RankingsPage()),
      GoRoute(path: Routes.nominations, builder: (_, _) => const NominationsPage()),
      GoRoute(
        path: Routes.myProjects,
        builder: (_, _) => const MyProjectsPage(),
        routes: [
          // Nhân viên xem dự án mình tham gia (server kiểm thành viên)
          GoRoute(path: ':id', builder: (_, state) => ProjectDetailPage(projectId: state.pathParameters['id']!)),
        ],
      ),
      GoRoute(path: Routes.finance, builder: (_, _) => const FinancePage()),
      GoRoute(
        path: '${Routes.suppliers}/:id',
        builder: (_, state) => SupplierPage(supplierId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: Routes.projects,
        builder: (_, _) => const ProjectsPage(),
        routes: [
          // Đường tĩnh đặt trước ':id' để không bị hiểu là mã dự án
          GoRoute(path: 'new', builder: (_, _) => const ProjectWizardPage()),
          GoRoute(path: 'charts', builder: (_, _) => const ProjectChartsPage()),
          GoRoute(path: ':id', builder: (_, state) => ProjectDetailPage(projectId: state.pathParameters['id']!)),
        ],
      ),
      GoRoute(path: Routes.projectProposals, builder: (_, _) => const ProjectProposalsPage()),
      GoRoute(path: Routes.raiseRequests, builder: (_, _) => const RaiseRequestsPage()),
      GoRoute(path: Routes.reportSubmissions, builder: (_, _) => const ReportSubmissionsPage()),
      GoRoute(path: Routes.resignations, builder: (_, _) => const ResignationsPage()),
      GoRoute(path: Routes.approvals, builder: (_, _) => const ApprovalInboxPage()),
      GoRoute(path: Routes.groupOverview, builder: (_, _) => const GroupOverviewPage()),
      GoRoute(path: Routes.adminConsole, builder: (_, _) => const AdminConsolePage()),
      GoRoute(path: Routes.jobPositions, builder: (_, _) => const JobPositionsPage()),
      GoRoute(path: Routes.orgTree, builder: (_, _) => const OrgTreePage()),
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
