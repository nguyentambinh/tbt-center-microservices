/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

/// Một dòng ứng viên nháp đọc từ tệp, chưa ghi vào hồ sơ thật.
class DraftRow {
  const DraftRow({
    required this.rowNumber,
    required this.fullName,
    this.email,
    this.phone,
    this.appliedPosition,
    this.error,
  });

  /// Số dòng trong tệp (dòng tiêu đề là 1) để HR đối chiếu.
  final int rowNumber;
  final String fullName;
  final String? email;
  final String? phone;
  final String? appliedPosition;

  /// Mã lỗi nếu thiếu thông tin bắt buộc; dòng lỗi không được xác nhận.
  final String? error;

  Map<String, Object?> toData() => {
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'appliedPosition': appliedPosition,
  };
}

/// Tên cột chấp nhận được (viết thường, bỏ dấu cách thừa) cho từng trường,
/// gồm tiếng Việt, tiếng Anh, tiếng Đức, tiếng Bồ Đào Nha.
const _aliases = {
  'fullName': {
    'họ tên', 'họ và tên', 'tên', 'full name', 'name', 'fullname', //
    'name, vorname', 'vollständiger name', 'nome', 'nome completo',
  },
  'email': {'email', 'e-mail', 'thư điện tử', 'mail'},
  'phone': {
    'số điện thoại', 'điện thoại', 'sđt', 'phone', 'phone number', //
    'telefon', 'telefone', 'celular',
  },
  'appliedPosition': {
    'vị trí', 'vị trí ứng tuyển', 'position', 'applied position', //
    'stelle', 'position (stelle)', 'cargo', 'vaga',
  },
};

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Dòng tiêu đề không có cột họ tên.
class MissingNameColumn implements Exception {
  const MissingNameColumn();
}

/// Đọc dòng tiêu đề để biết cột nào là trường nào, rồi đổi các dòng sau thành
/// ứng viên nháp. Cần họ tên và ít nhất một trong email, số điện thoại.
List<DraftRow> draftRows(List<List<String>> rows) {
  if (rows.isEmpty) return const [];
  final header = [for (final h in rows.first) h.toLowerCase().trim()];
  int? column(String field) {
    final index = header.indexWhere(_aliases[field]!.contains);
    return index < 0 ? null : index;
  }

  final nameAt = column('fullName');
  if (nameAt == null) throw const MissingNameColumn();
  final emailAt = column('email');
  final phoneAt = column('phone');
  final positionAt = column('appliedPosition');

  String? cell(List<String> row, int? at) {
    if (at == null || at >= row.length) return null;
    final value = row[at].trim();
    return value.isEmpty ? null : value;
  }

  return [
    for (var i = 1; i < rows.length; i++)
      _validate(
        rowNumber: i + 1,
        fullName: cell(rows[i], nameAt) ?? '',
        email: cell(rows[i], emailAt)?.toLowerCase(),
        phone: cell(rows[i], phoneAt),
        appliedPosition: cell(rows[i], positionAt),
      ),
  ];
}

DraftRow _validate({
  required int rowNumber,
  required String fullName,
  String? email,
  String? phone,
  String? appliedPosition,
}) {
  String? error;
  if (fullName.isEmpty) {
    error = 'missing_name';
  } else if (email == null && phone == null) {
    error = 'missing_contact';
  } else if (email != null && !_emailPattern.hasMatch(email)) {
    error = 'invalid_email';
  }
  return DraftRow(
    rowNumber: rowNumber,
    fullName: fullName,
    email: email,
    phone: phone,
    appliedPosition: appliedPosition,
    error: error,
  );
}
