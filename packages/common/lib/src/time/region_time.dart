/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

/// Giờ chuẩn từng nước của tập đoàn (giờ mùa đông, không tính giờ mùa hè)
const regionUtcOffsets = {
  'VN': 7,
  'DE': 1,
  'BR': -3,
  'ZA': 2,
  'AU': 10,
  'US': -5,
};

/// `dd/MM/yyyy HH:mm (GMT+7)` theo giờ của nước [country]
String formatRegionTime(DateTime at, String country) {
  final offset = regionUtcOffsets[country.toUpperCase()] ?? 0;
  final t = at.toUtc().add(Duration(hours: offset));
  String two(int v) => v.toString().padLeft(2, '0');
  final sign = offset < 0 ? '-' : '+';
  return '${two(t.day)}/${two(t.month)}/${t.year} '
      '${two(t.hour)}:${two(t.minute)} (GMT$sign${offset.abs()})';
}
