/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:tbt_common/tbt_common.dart';

/// Gom thu chi theo ngày, tháng hoặc năm
const granularities = {
  'day': 'YYYY-MM-DD',
  'month': 'YYYY-MM',
  'year': 'YYYY',
};

abstract interface class AnalyticsRepository {
  /// Thu, chi vật liệu, chi lương, lợi nhuận theo từng mốc (tiền tệ khu vực)
  Future<List<Map<String, dynamic>>> series({
    required String granularity,
    required DateTime from,
    required DateTime to,
  });

  /// Dự án xếp theo lợi nhuận: doanh thu, chi vật liệu, lợi nhuận, biên lãi
  Future<List<Map<String, dynamic>>> projectRanking();

  /// Thu chi của một dự án: doanh thu theo đợt, vật liệu đã dùng
  Future<Map<String, dynamic>> project(String projectId);
}

class PostgresAnalyticsRepository implements AnalyticsRepository {
  PostgresAnalyticsRepository(this._db);

  final Database _db;

  // Doanh thu dự án ghi vào tháng nghiệm thu; lương đã chi tính vào ngày cuối
  // kỳ lương
  static const _entries = '''
select used_on as day, 'revenue' as kind, amount_original as amount
  from service_revenues
union all select accepted_on, 'revenue', amount_original
  from acceptance_revenues
union all select imported_on, 'material', amount_original from material_imports
union all select shipped_on, 'material', amount_original
  from material_shipments
union all select ((period || '-01')::date + interval '1 month - 1 day')::date,
  'payroll', coalesce(spent_amount, amount) from payroll_budgets
  where status = 'spent' ''';

  @override
  Future<List<Map<String, dynamic>>> series({
    required String granularity,
    required DateTime from,
    required DateTime to,
  }) async {
    final format = granularities[granularity] ?? 'YYYY-MM';
    final rows = await _db.query(
      'with e as ($_entries) select to_char(day, @format) as bucket, '
      "coalesce(sum(amount) filter (where kind = 'revenue'), 0)::float8 "
      'as revenue, '
      "coalesce(sum(amount) filter (where kind = 'material'), 0)::float8 "
      'as material, '
      "coalesce(sum(amount) filter (where kind = 'payroll'), 0)::float8 "
      'as payroll from e where day between @from and @to '
      'group by 1 order by 1',
      params: {'format': format, 'from': from, 'to': to},
    );
    return [
      for (final r in rows)
        {
          'bucket': r['bucket'],
          'revenue': r['revenue'],
          'material': r['material'],
          'payroll': r['payroll'],
          // Cộng trừ số thực sinh số lẻ dài, làm tròn về đơn vị tiền nhỏ nhất
          'profit':
              (((r['revenue']! as double) -
                          (r['material']! as double) -
                          (r['payroll']! as double)) *
                      100)
                  .roundToDouble() /
              100,
        },
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> projectRanking() async {
    final rows = await _db.query(
      // Đã nghiệm thu: tiền nghiệm thu; chưa: các đợt thu dự kiến
      'with plan as (select project_id, sum(amount_original) as amount '
      'from project_revenues group by 1), rev as (select '
      'coalesce(a.project_id, plan.project_id) as project_id, '
      'coalesce(a.amount_original, plan.amount) as amount from plan '
      'full join acceptance_revenues a on a.project_id = plan.project_id), '
      'cost as (select project_id, sum(amount_original) '
      'as amount from project_costs group by 1) '
      'select coalesce(rev.project_id, cost.project_id) as project_id, '
      'coalesce(rev.amount, 0)::float8 as revenue, '
      'coalesce(cost.amount, 0)::float8 as cost '
      'from rev full join cost on cost.project_id = rev.project_id',
    );
    final items =
        [
          for (final r in rows)
            {
              'projectId': r['project_id'],
              'revenue': r['revenue'],
              'cost': r['cost'],
              'profit': (r['revenue']! as double) - (r['cost']! as double),
              'margin': (r['revenue']! as double) > 0
                  ? ((r['revenue']! as double) - (r['cost']! as double)) /
                        (r['revenue']! as double)
                  : null,
            },
        ]..sort(
          (a, b) => (b['profit']! as double).compareTo(a['profit']! as double),
        );
    return [
      for (final (i, item) in items.indexed) {...item, 'rank': i + 1},
    ];
  }

  @override
  Future<Map<String, dynamic>> project(String projectId) async {
    final revenues = await _db.query(
      'select rate_date as day, amount_original::float8 as amount, '
      "'progress' as kind from project_revenues where project_id = @id "
      'union all select accepted_on, amount_original::float8, '
      "'acceptance' from acceptance_revenues where project_id = @id "
      'order by 1',
      params: {'id': projectId},
    );
    final materials = await _db.query(
      'select m.material_name, m.imported_on, s.name as supplier, '
      'c.amount_original::float8 as amount from project_costs c '
      'join material_imports m on m.id = c.import_id '
      'left join suppliers s on s.id = m.supplier_id '
      'where c.project_id = @id order by m.imported_on',
      params: {'id': projectId},
    );
    String day(Object? d) =>
        (d! as DateTime).toIso8601String().substring(0, 10);
    final revenueTotal = revenues.fold<double>(
      0,
      (s, r) => s + (r['amount']! as double),
    );
    final costTotal = materials.fold<double>(
      0,
      (s, r) => s + (r['amount']! as double),
    );
    return {
      'projectId': projectId,
      'revenue': revenueTotal,
      'cost': costTotal,
      'profit': revenueTotal - costTotal,
      'revenues': [
        for (final r in revenues)
          {'date': day(r['day']), 'amount': r['amount'], 'kind': r['kind']},
      ],
      'materials': [
        for (final m in materials)
          {
            'name': m['material_name'],
            'date': day(m['imported_on']),
            'supplier': m['supplier'],
            'amount': m['amount'],
          },
      ],
    };
  }
}
