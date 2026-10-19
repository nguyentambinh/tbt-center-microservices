/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:finance_service/src/domain/finance_rules.dart';
import 'package:postgres/postgres.dart';
import 'package:tbt_common/tbt_common.dart';

/// Tỷ giá: 1 USD = `rate` đơn vị tiền khu vực, áp dụng từ ngày `date`.
typedef Rate = ({String rate, DateTime date});

abstract interface class FinanceRepository {
  /// Doanh thu, chi phí từng tháng của [year], kèm tháng nào đã chốt sổ.
  Future<List<Map<String, dynamic>>> monthly(int year);

  /// Nhà cung cấp kèm tổng đã mua, đã trả và còn nợ (R103, R104).
  Future<List<Map<String, dynamic>>> suppliers();

  /// Lịch sử mua và trả của một nhà cung cấp; `null` nếu không có.
  Future<Map<String, dynamic>?> supplier(String id);

  Future<Map<String, dynamic>> recordPurchase({
    required String supplierId,
    required String materialName,
    required DateTime importedOn,
    required String amount,
    required String currency,
    required Rate rate,
  });

  Future<Map<String, dynamic>> recordPayment({
    required String supplierId,
    required DateTime paidOn,
    required String amount,
    required String currency,
    required Rate rate,
    required String recordedBy,
    String? note,
  });

  /// Ghi doanh thu nghiệm thu của một dự án (project_contract gọi sang).
  /// Trả `false` nếu dự án đã được ghi từ trước (gọi lại không ghi trùng).
  Future<bool> recordAcceptance({
    required String projectId,
    required DateTime acceptedOn,
    required String amount,
    required String currency,
    required Rate rate,
  });

  /// Chốt sổ một tháng, phát `FinancePeriodClosed` cho báo cáo hợp nhất.
  Future<Map<String, dynamic>> closePeriod(
    String period, {
    required String currency,
    required String closedBy,
  });
}

class PostgresFinanceRepository implements FinanceRepository {
  PostgresFinanceRepository(this._db);

  final Database _db;

  // Mọi khoản thu, chi quy về một dạng. Doanh thu: dự án và dịch vụ;
  // chi phí: tiền mua vật liệu và tiền vận chuyển thực trả.
  static const _entries = '''
select rate_date as day, 'revenue' as kind, amount_original, amount_base
  from project_revenues
union all select used_on, 'revenue', amount_original, amount_base
  from service_revenues
union all select accepted_on, 'revenue', amount_original, amount_base
  from acceptance_revenues
union all select imported_on, 'cost', amount_original, amount_base
  from material_imports
union all select shipped_on, 'cost', amount_original, amount_base
  from material_shipments''';

  static const _totals = '''
coalesce(sum(amount_original) filter (where kind = 'revenue'), 0) as revenue,
coalesce(sum(amount_base) filter (where kind = 'revenue'), 0) as revenue_usd,
coalesce(sum(amount_original) filter (where kind = 'cost'), 0) as cost,
coalesce(sum(amount_base) filter (where kind = 'cost'), 0) as cost_usd''';

  @override
  Future<List<Map<String, dynamic>>> monthly(int year) async {
    final rows = await _db.query(
      'with e as ($_entries), m as ( '
      "select to_char(day, 'YYYY-MM') as period, $_totals "
      'from e where extract(year from day) = @year group by 1) '
      'select m.period, m.revenue::text, m.revenue_usd::text, m.cost::text, '
      'm.cost_usd::text, c.closed_at from m '
      'left join period_closings c on c.period = m.period order by m.period',
      params: {'year': year},
    );
    return [
      for (final r in rows)
        {
          'period': r['period'],
          'revenue': '${r['revenue']}',
          'revenueUsd': '${r['revenue_usd']}',
          'cost': '${r['cost']}',
          'costUsd': '${r['cost_usd']}',
          'closedAt': (r['closed_at'] as DateTime?)?.toIso8601String(),
        },
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> suppliers() async {
    final rows = await _db.query('''
select s.id, s.name, s.contact, s.address,
  coalesce(i.total, 0)::text as purchased, coalesce(p.total, 0)::text as paid,
  (coalesce(i.total, 0) - coalesce(p.total, 0))::text as balance,
  i.last_import, coalesce(i.n, 0)::int as purchases,
  case when coalesce(i.total, 0) = 0 then null
       else round(coalesce(p.total, 0) / i.total * 100, 1)::float8 end
    as paid_percent
from suppliers s
left join (select supplier_id, sum(amount_original) as total, count(*) as n,
                  max(imported_on) as last_import
             from material_imports group by supplier_id) i
  on i.supplier_id = s.id
left join (select supplier_id, sum(amount_original) as total
             from supplier_payments group by supplier_id) p
  on p.supplier_id = s.id
-- Xếp hạng theo lịch sử giao dịch (R105): mua nhiều tiền nhất lên đầu.
order by coalesce(i.total, 0) desc, s.id''');
    return [for (final r in rows) _supplierJson(r)];
  }

  @override
  Future<Map<String, dynamic>?> supplier(String id) async {
    final all = await suppliers();
    final found = all.where((s) => s['id'] == id).firstOrNull;
    if (found == null) return null;

    final imports = await _db.query(
      'select id, material_name, imported_on, amount_original::text as amount, '
      'currency_original, amount_base::text as usd from material_imports '
      'where supplier_id = @id order by imported_on desc, id desc',
      params: {'id': id},
    );
    final payments = await _db.query(
      'select id::text, paid_on, amount_original::text as amount, '
      'currency_original, amount_base::text as usd, note, recorded_by '
      'from supplier_payments where supplier_id = @id '
      'order by paid_on desc, created_at desc',
      params: {'id': id},
    );
    return {
      ...found,
      'imports': [
        for (final r in imports)
          {
            'id': r['id'],
            'materialName': r['material_name'],
            'date': _day(r['imported_on']),
            'amount': r['amount'],
            'currency': r['currency_original'],
            'amountUsd': r['usd'],
          },
      ],
      'payments': [
        for (final r in payments)
          {
            'id': r['id'],
            'date': _day(r['paid_on']),
            'amount': r['amount'],
            'currency': r['currency_original'],
            'amountUsd': r['usd'],
            'note': r['note'],
            'recordedBy': r['recorded_by'],
          },
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> recordPurchase({
    required String supplierId,
    required String materialName,
    required DateTime importedOn,
    required String amount,
    required String currency,
    required Rate rate,
  }) {
    return _db.transaction((tx) async {
      await _lockSupplier(tx, supplierId);
      await _ensureOpen(tx, importedOn);
      final rows = await tx.execute(
        Sql.named(
          'insert into material_imports (id, supplier_id, material_name, '
          'imported_on, amount_original, currency_original, rate_applied, '
          'rate_date, amount_base) values (gen_random_uuid()::text, @supplier, '
          '@name, @day, @amount::numeric, @currency, @rate::numeric, '
          '@rateDate, round(@amount::numeric / @rate::numeric, 2)) '
          'returning id, amount_base::text as usd',
        ),
        parameters: {
          'supplier': supplierId,
          'name': materialName,
          'day': importedOn,
          'amount': amount,
          'currency': currency,
          'rate': rate.rate,
          'rateDate': rate.date,
        },
      );
      final row = rows.first.toColumnMap();
      final result = {
        'id': row['id'],
        'supplierId': supplierId,
        'materialName': materialName,
        'date': _day(importedOn),
        'amount': amount,
        'currency': currency,
        'amountUsd': row['usd'],
      };
      await addOutboxEvent(
        tx,
        aggregate: 'material_import',
        aggregateId: row['id'] as String,
        eventType: 'MaterialPurchased',
        payload: result,
      );
      return result;
    });
  }

  @override
  Future<Map<String, dynamic>> recordPayment({
    required String supplierId,
    required DateTime paidOn,
    required String amount,
    required String currency,
    required Rate rate,
    required String recordedBy,
    String? note,
  }) {
    return _db.transaction((tx) async {
      // Khóa nhà cung cấp để hai lần trả song song không cùng vượt số nợ.
      await _lockSupplier(tx, supplierId);
      await _ensureOpen(tx, paidOn);
      final balance = await tx.execute(
        Sql.named(
          'select (select coalesce(sum(amount_original), 0) from '
          'material_imports where supplier_id = @id) - (select '
          'coalesce(sum(amount_original), 0) from supplier_payments where '
          'supplier_id = @id) - @amount::numeric < 0 as over',
        ),
        parameters: {'id': supplierId, 'amount': amount},
      );
      if (balance.first.toColumnMap()['over'] == true) {
        throw const FinanceRuleViolation(
          'overpaid',
          'Payment is larger than the amount owed',
        );
      }

      final rows = await tx.execute(
        Sql.named(
          'insert into supplier_payments (supplier_id, paid_on, '
          'amount_original, currency_original, rate_applied, rate_date, '
          'amount_base, note, recorded_by) values (@id, @day, '
          '@amount::numeric, @currency, @rate::numeric, @rateDate, '
          'round(@amount::numeric / @rate::numeric, 2), @note, @by) '
          'returning id::text, amount_base::text as usd',
        ),
        parameters: {
          'id': supplierId,
          'day': paidOn,
          'amount': amount,
          'currency': currency,
          'rate': rate.rate,
          'rateDate': rate.date,
          'note': note,
          'by': recordedBy,
        },
      );
      final row = rows.first.toColumnMap();
      final result = {
        'id': row['id'],
        'supplierId': supplierId,
        'date': _day(paidOn),
        'amount': amount,
        'currency': currency,
        'amountUsd': row['usd'],
        'note': note,
        'recordedBy': recordedBy,
      };
      await addOutboxEvent(
        tx,
        aggregate: 'supplier_payment',
        aggregateId: row['id'] as String,
        eventType: 'SupplierPaid',
        payload: result,
      );
      return result;
    });
  }

  @override
  Future<bool> recordAcceptance({
    required String projectId,
    required DateTime acceptedOn,
    required String amount,
    required String currency,
    required Rate rate,
  }) {
    return _db.transaction((tx) async {
      await _ensureOpen(tx, acceptedOn);
      final rows = await tx.execute(
        Sql.named(
          'insert into acceptance_revenues (project_id, accepted_on, '
          'amount_original, currency_original, rate_applied, rate_date, '
          'amount_base) values (@project, @day, @amount::numeric, @currency, '
          '@rate::numeric, @rateDate, round(@amount::numeric / '
          '@rate::numeric, 2)) on conflict (project_id) do nothing '
          'returning amount_base::text as usd',
        ),
        parameters: {
          'project': projectId,
          'day': acceptedOn,
          'amount': amount,
          'currency': currency,
          'rate': rate.rate,
          'rateDate': rate.date,
        },
      );
      if (rows.isEmpty) return false;
      await addOutboxEvent(
        tx,
        aggregate: 'acceptance_revenue',
        aggregateId: projectId,
        eventType: 'AcceptanceRevenueRecorded',
        payload: {
          'projectId': projectId,
          'date': _day(acceptedOn),
          'amount': amount,
          'currency': currency,
          'amountUsd': rows.first.toColumnMap()['usd'],
        },
      );
      return true;
    });
  }

  @override
  Future<Map<String, dynamic>> closePeriod(
    String period, {
    required String currency,
    required String closedBy,
  }) {
    return _db.transaction((tx) async {
      final rows = await tx.execute(
        Sql.named(
          'with e as ($_entries) '
          'insert into period_closings (period, currency, revenue, '
          'revenue_usd, cost, cost_usd, closed_by) '
          'select @period::text, @currency, $_totals, @by from e '
          "where to_char(day, 'YYYY-MM') = @period::text "
          'on conflict (period) do nothing '
          'returning revenue::text, revenue_usd::text, cost::text, '
          'cost_usd::text, closed_at',
        ),
        parameters: {'period': period, 'currency': currency, 'by': closedBy},
      );
      if (rows.isEmpty) {
        throw FinanceRuleViolation('period_closed', '$period is closed');
      }
      final row = rows.first.toColumnMap();
      final result = {
        'period': period,
        'currency': currency,
        'revenue': row['revenue'],
        'revenueUsd': row['revenue_usd'],
        'cost': row['cost'],
        'costUsd': row['cost_usd'],
        'closedBy': closedBy,
        'closedAt': (row['closed_at'] as DateTime).toIso8601String(),
      };
      // Chỉ số tổng của tháng lên Hub, chứng từ chi tiết ở lại khu vực.
      await addOutboxEvent(
        tx,
        aggregate: 'finance_period',
        aggregateId: period,
        eventType: 'FinancePeriodClosed',
        payload: result,
      );
      return result;
    });
  }

  Future<void> _lockSupplier(TxSession tx, String id) async {
    final rows = await tx.execute(
      Sql.named('select id from suppliers where id = @id for update'),
      parameters: {'id': id},
    );
    if (rows.isEmpty) {
      throw FinanceRuleViolation('unknown_supplier', 'No supplier $id');
    }
  }

  Future<void> _ensureOpen(TxSession tx, DateTime day) async {
    final rows = await tx.execute(
      Sql.named('select 1 from period_closings where period = @period'),
      parameters: {'period': periodOf(day)},
    );
    if (rows.isNotEmpty) {
      throw FinanceRuleViolation(
        'period_closed',
        '${periodOf(day)} is closed',
      );
    }
  }

  Map<String, dynamic> _supplierJson(Map<String, dynamic> r) => {
    'id': r['id'],
    'name': r['name'],
    'contact': r['contact'],
    'address': r['address'],
    'purchased': r['purchased'],
    'paid': r['paid'],
    'balance': r['balance'],
    'lastImport': _day(r['last_import']),
    'purchases': r['purchases'],
    'paidPercent': r['paid_percent'],
  };

  String? _day(Object? value) =>
      value is DateTime ? value.toIso8601String().substring(0, 10) : null;
}
