/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

/// Giờ hiện tại theo múi giờ khu vực; container chạy UTC nên hỏi Postgres
/// (có sẵn dữ liệu múi giờ, kể cả giờ mùa hè)
class RegionClock {
  RegionClock(this._db, {required this.timeZone});

  final Database _db;
  final String timeZone;

  Future<DateTime> now() async {
    final rows = await _db.query(
      'select to_char(now() at time zone @tz, '
      '\'YYYY-MM-DD"T"HH24:MI:SS\') as local',
      params: {'tz': timeZone},
    );
    return DateTime.parse(rows.first['local'] as String);
  }
}

/// Ngày giờ "hôm nay" của khu vực cho các giá trị mặc định của route
Future<DateTime> regionNow(RequestContext context) async =>
    await context.read<RegionClock?>()?.now() ?? DateTime.now();
