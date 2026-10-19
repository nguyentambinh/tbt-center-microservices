/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

/// Khu vực mặc định khi không biết quốc gia: Hub đặt ở Việt Nam.
const defaultRegion = 'vn';

const _asia = {
  'AF', 'AM', 'AZ', 'BD', 'BH', 'BN', 'BT', 'CN', 'CY', 'GE', 'HK', 'ID', //
  'IL', 'IN', 'IQ', 'IR', 'JO', 'JP', 'KG', 'KH', 'KP', 'KR', 'KW', 'KZ',
  'LA', 'LB', 'LK', 'MM', 'MN', 'MO', 'MV', 'MY', 'NP', 'OM', 'PH', 'PK',
  'PS', 'QA', 'SA', 'SG', 'SY', 'TH', 'TJ', 'TL', 'TM', 'TR', 'TW', 'UZ',
  'VN', 'YE', 'AE',
};

const _europe = {
  'AD', 'AL', 'AT', 'AX', 'BA', 'BE', 'BG', 'BY', 'CH', 'CZ', 'DE', 'DK', //
  'EE', 'ES', 'FI', 'FO', 'FR', 'GB', 'GG', 'GI', 'GR', 'HR', 'HU', 'IE',
  'IM', 'IS', 'IT', 'JE', 'LI', 'LT', 'LU', 'LV', 'MC', 'MD', 'ME', 'MK',
  'MT', 'NL', 'NO', 'PL', 'PT', 'RO', 'RS', 'RU', 'SE', 'SI', 'SJ', 'SK',
  'SM', 'UA', 'VA', 'XK',
};

const _northAmerica = {
  'AG', 'AI', 'AW', 'BB', 'BL', 'BM', 'BQ', 'BS', 'BZ', 'CA', 'CR', 'CU', //
  'CW', 'DM', 'DO', 'GD', 'GL', 'GP', 'GT', 'HN', 'HT', 'JM', 'KN', 'KY',
  'LC', 'MF', 'MQ', 'MS', 'MX', 'NI', 'PA', 'PM', 'PR', 'SV', 'SX', 'TC',
  'TT', 'US', 'VC', 'VG', 'VI',
};

const _southAmerica = {
  'AR', 'BO', 'BR', 'CL', 'CO', 'EC', 'FK', 'GF', 'GY', 'PE', 'PY', 'SR', //
  'UY', 'VE',
};

const _africa = {
  'AO', 'BF', 'BI', 'BJ', 'BW', 'CD', 'CF', 'CG', 'CI', 'CM', 'CV', 'DJ', //
  'DZ', 'EG', 'EH', 'ER', 'ET', 'GA', 'GH', 'GM', 'GN', 'GQ', 'GW', 'KE',
  'KM', 'LR', 'LS', 'LY', 'MA', 'MG', 'ML', 'MR', 'MU', 'MW', 'MZ', 'NA',
  'NE', 'NG', 'RE', 'RW', 'SC', 'SD', 'SH', 'SL', 'SN', 'SO', 'SS', 'ST',
  'SZ', 'TD', 'TG', 'TN', 'TZ', 'UG', 'YT', 'ZA', 'ZM', 'ZW',
};

const _oceania = {
  'AS', 'AU', 'CK', 'FJ', 'FM', 'GU', 'KI', 'MH', 'MP', 'NC', 'NF', 'NR', //
  'NU', 'NZ', 'PF', 'PG', 'PN', 'PW', 'SB', 'TK', 'TO', 'TV', 'UM', 'VU',
  'WF', 'WS',
};

/// Khu vực gần nhất theo châu lục của [country].
String regionForCountry(String? country) {
  final code = country?.toUpperCase();
  if (code == null) return defaultRegion;
  if (_europe.contains(code)) return 'de';
  if (_northAmerica.contains(code)) return 'us';
  if (_southAmerica.contains(code)) return 'br';
  if (_africa.contains(code)) return 'za';
  if (_oceania.contains(code)) return 'au';
  if (_asia.contains(code)) return 'vn';
  return defaultRegion;
}

/// Ngôn ngữ mặc định của app cho [country]: vi, de, pt hoặc en.
String languageForCountry(String? country) {
  switch (country?.toUpperCase()) {
    case 'VN':
      return 'vi';
    case 'DE' || 'AT' || 'CH' || 'LI':
      return 'de';
    case 'BR' || 'PT' || 'AO' || 'MZ':
      return 'pt';
    case null:
      return 'vi';
    default:
      return 'en';
  }
}
