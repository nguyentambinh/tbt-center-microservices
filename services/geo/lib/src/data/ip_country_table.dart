/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Bảng dải IPv4 → mã quốc gia, đọc từ CSV của DB-IP Lite.
/// Mỗi dòng: `ip_dau,ip_cuoi,ma_nuoc`. Dòng IPv6 bị bỏ qua.
class IpCountryTable {
  IpCountryTable._(this._starts, this._ends, this._countries);

  /// Đọc file `.csv.gz` tải từ db-ip.com.
  factory IpCountryTable.load(String path) {
    final bytes = gzip.decode(File(path).readAsBytesSync());
    return IpCountryTable.fromCsv(utf8.decode(bytes));
  }

  /// Dựng bảng từ nội dung CSV, các dòng đã sắp tăng dần theo IP đầu.
  factory IpCountryTable.fromCsv(String csv) {
    final starts = <int>[];
    final ends = <int>[];
    final countries = <int>[];
    for (final line in const LineSplitter().convert(csv)) {
      final parts = line.split(',');
      if (parts.length < 3) continue;
      final start = parseIpv4(parts[0]);
      final end = parseIpv4(parts[1]);
      if (start == null || end == null || parts[2].length != 2) continue;
      starts.add(start);
      ends.add(end);
      countries.add(parts[2].codeUnitAt(0) << 8 | parts[2].codeUnitAt(1));
    }
    return IpCountryTable._(
      Uint32List.fromList(starts),
      Uint32List.fromList(ends),
      Uint16List.fromList(countries),
    );
  }

  final Uint32List _starts;
  final Uint32List _ends;
  final Uint16List _countries;

  /// Số dải IP trong bảng.
  int get length => _starts.length;

  /// Mã quốc gia ISO 3166-1 alpha-2 của [ip], `null` nếu không biết.
  String? countryOf(String ip) {
    final value = parseIpv4(ip);
    if (value == null) return null;

    // Tìm dải cuối cùng có IP đầu <= value.
    var low = 0;
    var high = _starts.length - 1;
    var found = -1;
    while (low <= high) {
      final mid = (low + high) >> 1;
      if (_starts[mid] <= value) {
        found = mid;
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }
    if (found < 0 || value > _ends[found]) return null;

    final code = _countries[found];
    final country = String.fromCharCodes([code >> 8, code & 0xff]);
    return country == 'ZZ' ? null : country;
  }

  /// Đổi `a.b.c.d` thành số nguyên 32 bit, `null` nếu không phải IPv4.
  static int? parseIpv4(String text) {
    final parts = text.trim().split('.');
    if (parts.length != 4) return null;
    var value = 0;
    for (final part in parts) {
      final octet = int.tryParse(part);
      if (octet == null || octet < 0 || octet > 255) return null;
      value = value << 8 | octet;
    }
    return value;
  }
}
