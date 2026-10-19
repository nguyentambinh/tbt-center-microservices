/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:geo_service/src/data/ip_country_table.dart';

// Biến top-level của Dart chỉ khởi tạo ở lần đọc đầu tiên,
// nên bảng IP được nạp một lần khi có request đầu.
final _table = IpCountryTable.load(
  Platform.environment['GEO_DB_PATH'] ??
      '../../deploy/geo/data/dbip-country-lite.csv.gz',
);

Handler middleware(Handler handler) {
  return handler.use(provider<IpCountryTable>((_) => _table));
}
