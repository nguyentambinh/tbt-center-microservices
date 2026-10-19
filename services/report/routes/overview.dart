/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:report_service/src/doris_client.dart';
import 'package:report_service/src/projector.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /overview  số liệu hợp nhất cho dashboard lãnh đạo (R01, R02, R60):
/// chi phí lương, doanh thu và chi phí đã chốt sổ theo khu vực và kỳ (quy
/// USD), đơn nghỉ, ứng viên theo bước.
/// Đọc hoàn toàn từ Doris (phía đọc của CQRS), không gọi database khu vực.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  final doris = context.read<DorisClient>();
  try {
    // 6 câu độc lập: chạy cùng lúc, chỉ chờ bằng câu chậm nhất
    final [
      payroll,
      finance,
      work,
      leaves,
      candidates,
      checkpoint,
    ] = await Future.wait([
      doris.query(
        'select region, period, sum(employees) as employees, '
        'cast(sum(total_net_usd) as double) as total_usd '
        'from payroll_cost group by region, period order by period, region',
      ),
      doris.query(
        'select region, period, cast(revenue_usd as double) as revenue_usd, '
        'cast(cost_usd as double) as cost_usd from finance_summary '
        'order by period, region',
      ),
      doris.query(
        "select region, date_format(work_date, '%Y-%m') as period, "
        'count(distinct employee_id) as employees, '
        'cast(sum(hours) as double) as hours, '
        'cast(sum(overtime_hours) as double) as overtime_hours '
        'from work_hours group by region, period order by period, region',
      ),
      doris.query(
        'select region, status, count(*) as requests, sum(days) as days '
        'from leave_requests group by region, status order by region, status',
      ),
      doris.query(
        'select region, status, count(*) as candidates from candidates '
        'group by region, status order by region, status',
      ),
      doris.query(
        'select last_event_id, updated_at from projection_checkpoint '
        "where name = 'audit'",
      ),
    ]);
    return Response.json(
      body: {
        'payrollByRegion': payroll,
        'financeByRegion': finance,
        'workByRegion': work,
        'leavesByRegion': leaves,
        'candidatesByRegion': candidates,
        // Phía đọc đi sau phía ghi vài giây: cho app biết số liệu mới tới đâu.
        'projectedUntilEvent': checkpoint.isEmpty
            ? 0
            : checkpoint.first['last_event_id'],
        'projectedAt': checkpoint.isEmpty
            ? null
            : checkpoint.first['updated_at'],
        'inMemoryCheckpoint': context.read<Projector>().lastEventId,
      },
    );
  } on DorisException catch (e) {
    return apiError(503, 'report_unavailable', e.message);
  }
}
