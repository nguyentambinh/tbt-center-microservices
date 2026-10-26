/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

/// Quê quán: mã lưu trong CSDL → tên hiện cho người dùng, theo nước.
/// VN dùng mã tỉnh theo biển số xe; nước khác dùng mã bưu chính của thành phố
const hometownNames = <String, Map<String, String>>{
  'VN': {
    '11': 'Cao Bằng',
    '12': 'Lạng Sơn',
    '14': 'Quảng Ninh',
    '15': 'Hải Phòng',
    '16': 'Hải Phòng',
    '17': 'Thái Bình',
    '18': 'Nam Định',
    '19': 'Phú Thọ',
    '20': 'Thái Nguyên',
    '21': 'Yên Bái',
    '22': 'Tuyên Quang',
    '23': 'Hà Giang',
    '24': 'Lào Cai',
    '25': 'Lai Châu',
    '26': 'Sơn La',
    '27': 'Điện Biên',
    '28': 'Hòa Bình',
    '29': 'Hà Nội',
    '30': 'Hà Nội',
    '31': 'Hà Nội',
    '32': 'Hà Nội',
    '33': 'Hà Nội',
    '34': 'Hải Dương',
    '35': 'Ninh Bình',
    '36': 'Thanh Hóa',
    '37': 'Nghệ An',
    '38': 'Hà Tĩnh',
    '39': 'Đà Nẵng',
    '40': 'Quảng Nam',
    '41': 'Quảng Ngãi',
    '42': 'Bình Định',
    '43': 'Khánh Hòa',
    '44': 'Ninh Thuận',
    '45': 'Bình Thuận',
    '46': 'TP Hồ Chí Minh',
    '47': 'Đắk Lắk',
    '48': 'Đắk Nông',
    '49': 'Lâm Đồng',
    '50': 'TP Hồ Chí Minh',
    '51': 'TP Hồ Chí Minh',
    '52': 'TP Hồ Chí Minh',
    '53': 'TP Hồ Chí Minh',
    '54': 'TP Hồ Chí Minh',
    '55': 'Đồng Nai',
    '56': 'Bình Dương',
    '57': 'Long An',
    '58': 'Tiền Giang',
    '59': 'Vĩnh Long',
    '60': 'Cần Thơ',
    '61': 'Đồng Tháp',
    '62': 'An Giang',
    '63': 'Kiên Giang',
    '64': 'Cà Mau',
    '65': 'Tây Ninh',
    '66': 'Bến Tre',
    '67': 'Vũng Tàu',
    '68': 'Quảng Bình',
    '69': 'Quảng Trị',
    '70': 'Huế',
    '71': 'Quảng Ngãi',
    '72': 'Bình Định',
    '73': 'Phú Yên',
    '74': 'Nha Trang',
    '75': 'Gia Lai',
    '76': 'Kon Tum',
    '77': 'Sóc Trăng',
    '78': 'Trà Vinh',
    '79': 'Ninh Thuận',
    '80': 'Bình Thuận',
    '81': 'Vĩnh Phúc',
    '82': 'Hưng Yên',
    '83': 'Hà Nam',
    '84': 'Quảng Nam',
    '85': 'Bình Phước',
    '86': 'Bạc Liêu',
    '87': 'Hậu Giang',
    '88': 'Bắc Cạn',
    '89': 'Bắc Giang',
    '90': 'Bắc Ninh',
  },
  'DE': {
    '10115': 'Berlin',
    '80331': 'München',
    '20095': 'Hamburg',
    '50667': 'Köln',
    '60311': 'Frankfurt am Main',
  },
  'US': {
    'NY 10001': 'New York',
    'IL 60601': 'Chicago',
    'CA 90012': 'Los Angeles',
    'TX 77002': 'Houston',
    'WA 98101': 'Seattle',
  },
  'BR': {
    '01000-000': 'São Paulo – SP',
    '20000-000': 'Rio de Janeiro – RJ',
    '30100-000': 'Belo Horizonte – MG',
    '80000-000': 'Curitiba – PR',
    '40000-000': 'Salvador – BA',
  },
  'ZA': {
    '2001': 'Johannesburg',
    '8001': 'Cape Town',
    '4001': 'Durban',
    '0002': 'Pretoria',
    '6001': 'Gqeberha',
  },
  'AU': {
    'NSW 2000': 'Sydney',
    'VIC 3000': 'Melbourne',
    'QLD 4000': 'Brisbane',
    'WA 6000': 'Perth',
    'SA 5000': 'Adelaide',
  },
};

/// Tên quê quán theo mã (mã của các nước khác dạng nhau nên tra được trên mọi nước); mã lạ thì hiện nguyên mã
String? hometownName(Object? code) {
  if (code == null || '$code'.isEmpty) return null;
  for (final names in hometownNames.values) {
    if (names['$code'] case final name?) return name;
  }
  return '$code';
}

/// Lựa chọn trong ô sổ xuống: mỗi tên một lần (nhiều mã biển số chung một tỉnh)
List<({String code, String name})> hometownOptions(String? country) {
  final seen = <String>{};
  return [
    for (final e in (hometownNames[country] ?? const <String, String>{}).entries)
      if (seen.add(e.value)) (code: e.key, name: e.value),
  ]..sort((a, b) => a.name.compareTo(b.name));
}
