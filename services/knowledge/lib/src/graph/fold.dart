/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-18
 */

const _groups = {
  'a': 'àáạảãâầấậẩẫăằắặẳẵäå',
  'e': 'èéẹẻẽêềếệểễë',
  'i': 'ìíịỉĩîï',
  'o': 'òóọỏõôồốộổỗơờớợởỡö',
  'u': 'ùúụủũưừứựửữûü',
  'y': 'ỳýỵỷỹÿ',
  'd': 'đ',
  'c': 'ç',
  'n': 'ñ',
};

final _map = {
  for (final g in _groups.entries)
    for (final ch in g.value.split('')) ch: g.key,
};

/// Chữ thường, bỏ dấu, gộp khoảng trắng, giống kb_unaccent trong CSDL
String fold(String text) {
  final b = StringBuffer();
  for (final ch in text.toLowerCase().split('')) {
    b.write(ch == 'ß' ? 'ss' : (_map[ch] ?? ch));
  }
  return b.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
}
