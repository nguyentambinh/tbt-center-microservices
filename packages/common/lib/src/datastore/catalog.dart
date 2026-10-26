/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-16
 */

/// Một bảng được đưa lên kho tổng: khóa chính và các trường cá nhân phải mã hóa
class SyncTable {
  const SyncTable(this.db, this.table, this.key, [this.pii = const {}]);

  final String db;
  final String table;
  final List<String> key;
  final Set<String> pii;
}

// Mã nhân viên có chữ của tên nên cũng coi là dữ liệu cá nhân
const _emp = 'employee_id';

/// Danh mục bảng của kho tổng; bảng không có ở đây thì Hub từ chối
const syncCatalog = [
  SyncTable('hr_db', 'companies', ['id']),
  SyncTable('hr_db', 'departments', ['id'], {'manager_id'}),
  SyncTable('hr_db', 'positions', ['id']),
  SyncTable('hr_db', 'specialties', ['id']),
  SyncTable('hr_db', 'skills', ['id']),
  SyncTable('hr_db', 'degrees', ['id']),
  SyncTable('hr_db', 'languages', ['id']),
  SyncTable(
    'hr_db',
    'employees',
    ['id'],
    {
      'id', 'family_name', 'given_name', 'birth_year', 'gender', 'email', //
      'photo_url', 'labor_contract',
    },
  ),
  SyncTable(
    'hr_db',
    'contacts',
    [_emp],
    {_emp, 'phone', 'address', 'facebook', 'x_handle', 'hometown_code'},
  ),
  SyncTable(
    'hr_db',
    'relatives',
    [_emp, 'full_name'],
    {_emp, 'full_name', 'phone', 'address', 'relationship'},
  ),
  SyncTable(
    'hr_db',
    'health_records',
    [_emp],
    {_emp, 'height_cm', 'weight_kg', 'medical_history', 'vision_score'},
  ),
  SyncTable(
    'hr_db',
    'insurances',
    [_emp],
    {_emp, 'insurance_type', 'insurance_number', 'expires_on'},
  ),
  SyncTable('attendance_db', 'holidays', ['country_code', 'holiday_date']),
  SyncTable(
    'attendance_db',
    'leave_requests',
    ['id'],
    {_emp, 'reason', 'approved_by'},
  ),
  SyncTable(
    'attendance_db',
    'overtime_requests',
    ['id'],
    {_emp, 'reason', 'decided_by'},
  ),
  SyncTable('attendance_db', 'timesheets', [_emp, 'work_date'], {_emp}),
  SyncTable(
    'attendance_db',
    'work_schedules',
    [_emp, 'work_date'],
    {_emp, 'note'},
  ),
  SyncTable('payroll_db', 'salaries', [_emp], {_emp, 'base_salary'}),
  SyncTable(
    'payroll_db',
    'payslips',
    ['id'],
    {_emp, 'gross_original', 'net_original', 'amount_base', 'bank_reference'},
  ),
  SyncTable(
    'payroll_db',
    'bonuses_penalties',
    ['id'],
    {_emp, 'amount_original', 'total_original', 'amount_base'},
  ),
  SyncTable('payroll_db', 'coefficients', ['id']),
  SyncTable('payroll_db', 'payroll_runs', ['id'], {'started_by'}),
  SyncTable('finance_db', 'suppliers', ['id'], {'contact', 'address'}),
  SyncTable('finance_db', 'supplier_payments', ['id'], {'note', 'recorded_by'}),
  SyncTable('finance_db', 'period_closings', ['period'], {'closed_by'}),
  SyncTable('finance_db', 'payroll_budgets', ['period']),
  SyncTable('finance_db', 'service_revenues', ['id']),
  SyncTable('finance_db', 'material_imports', ['id']),
  SyncTable('finance_db', 'acceptance_revenues', ['project_id']),
  SyncTable(
    'recruitment_db',
    'candidates',
    ['id'],
    {
      'keycloak_sub', 'full_name', 'email', 'phone', 'cv_object_key', //
      'cv_sha256', 'ai_last_error', _emp,
    },
  ),
  SyncTable(
    'recruitment_db',
    'candidate_status_history',
    ['id'],
    {'note', 'changed_by'},
  ),
  SyncTable('recruitment_db', 'cv_summaries', ['candidate_id'], {'summary'}),
  SyncTable('project_contract_db', 'projects', ['id']),
  SyncTable('project_contract_db', 'contracts', ['id']),
  SyncTable('project_contract_db', 'project_contracts', ['id']),
  SyncTable(
    'project_contract_db',
    'customers',
    ['id'],
    {'name', 'contact', 'address'},
  ),
  SyncTable(
    'project_contract_db',
    'project_members',
    ['project_contract_id', _emp],
    {_emp, 'project_salary'},
  ),
];

SyncTable? syncTable(String name) {
  for (final t in syncCatalog) {
    if (t.table == name) return t;
  }
  return null;
}
