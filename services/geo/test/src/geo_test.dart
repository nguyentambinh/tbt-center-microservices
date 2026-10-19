/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:geo_service/src/data/ip_country_table.dart';
import 'package:geo_service/src/domain/region_policy.dart';
import 'package:test/test.dart';

const _csv = '''
0.0.0.0,0.255.255.255,ZZ
1.0.0.0,1.0.0.255,AU
1.0.1.0,1.0.3.255,CN
14.160.0.0,14.191.255.255,VN
2001:200::,2001:200:ffff:ffff:ffff:ffff:ffff:ffff,JP
''';

void main() {
  final table = IpCountryTable.fromCsv(_csv);

  group('IpCountryTable', () {
    test('bỏ qua dòng IPv6', () => expect(table.length, 4));

    test('tra đúng dải', () {
      expect(table.countryOf('1.0.0.7'), 'AU');
      expect(table.countryOf('1.0.2.1'), 'CN');
      expect(table.countryOf('14.170.10.1'), 'VN');
    });

    test('không biết thì trả null', () {
      expect(table.countryOf('0.1.2.3'), isNull);
      expect(table.countryOf('9.9.9.9'), isNull);
      expect(table.countryOf('khong-phai-ip'), isNull);
    });
  });

  group('region_policy', () {
    test('quốc gia về khu vực gần nhất', () {
      expect(regionForCountry('FR'), 'de');
      expect(regionForCountry('CA'), 'us');
      expect(regionForCountry('AR'), 'br');
      expect(regionForCountry('NG'), 'za');
      expect(regionForCountry('NZ'), 'au');
      expect(regionForCountry('JP'), 'vn');
      expect(regionForCountry(null), 'vn');
    });

    test('ngôn ngữ mặc định', () {
      expect(languageForCountry('AT'), 'de');
      expect(languageForCountry('BR'), 'pt');
      expect(languageForCountry('ZA'), 'en');
      expect(languageForCountry('VN'), 'vi');
    });
  });
}
