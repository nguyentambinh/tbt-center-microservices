/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

/// Ngưỡng phân cấp theo giá trị nghiệm thu quy ra USD: dưới 100 nghìn là
/// cấp 1, dưới 300 nghìn cấp 2, dưới 800 nghìn cấp 3, còn lại cấp 4
const tierThresholdsUsd = [100000, 300000, 800000];

int projectTier(double valueUsd) {
  for (var i = 0; i < tierThresholdsUsd.length; i++) {
    if (valueUsd < tierThresholdsUsd[i]) return i + 1;
  }
  return tierThresholdsUsd.length + 1;
}

/// Ràng buộc từng cấp: thời gian làm tối đa (tháng), số người tối thiểu
const tierMaxMonths = {1: 12, 2: 24, 3: 36, 4: 60};
const tierMinMembers = {1: 2, 2: 3, 3: 5, 4: 8};

/// Nghiệm thu chậm nhất sau ngày kết thúc
const acceptanceGraceDays = 90;

/// Mức cảnh báo: đã nghiệm thu, chưa bắt đầu, còn ≤ 1 tháng (đỏ, kể cả trễ
/// hạn), ≤ 6 tháng (cam), ≤ 12 tháng (vàng), còn lâu
String warningLevel({
  required DateTime? start,
  required DateTime? end,
  required String status,
  required DateTime today,
}) {
  if (status == 'accepted') return 'accepted';
  if (start != null && start.isAfter(today)) return 'not_started';
  if (end == null) return 'normal';
  final left = end.difference(today).inDays;
  if (left <= 31) return 'red';
  if (left <= 183) return 'orange';
  if (left <= 366) return 'yellow';
  return 'normal';
}

/// Tiến độ 0..1: đã nghiệm thu là 1; có % khối lượng thực tế thì dùng số đó;
/// chưa có thì ước theo thời gian nhưng chưa nghiệm thu không bao giờ đủ 100%
double progressOf({
  required DateTime? start,
  required DateTime? end,
  required String status,
  required DateTime today,
  int? actualPercent,
}) {
  if (status == 'accepted') return 1;
  if (actualPercent != null) return (actualPercent.clamp(0, 99)) / 100;
  if (start == null || end == null || !end.isAfter(start)) return 0;
  final done = today.difference(start).inHours / end.difference(start).inHours;
  return done.clamp(0, 0.95).toDouble();
}

int _months(DateTime a, DateTime b) =>
    (b.year - a.year) * 12 + b.month - a.month + (b.day > a.day ? 1 : 0);

/// Kiểm đề xuất dự án; trả danh sách mã lỗi, rỗng là hợp lệ
List<String> checkProposal({
  required double? value,
  required double? deposit,
  required double rateToUsd,
  required DateTime? start,
  required DateTime? end,
  required DateTime? acceptance,
  required int members,
  required DateTime today,
}) {
  final errors = <String>[];
  if (value == null || value <= 0) errors.add('invalid_value');
  if (deposit != null && (deposit < 0 || (value != null && deposit > value))) {
    errors.add('invalid_deposit');
  }
  if (start == null || end == null) {
    errors.add('dates_required');
    return errors;
  }
  if (start.isBefore(DateTime(today.year, today.month, today.day))) {
    errors.add('start_in_past');
  }
  if (!end.isAfter(start)) errors.add('end_before_start');
  if (acceptance != null &&
      (acceptance.isBefore(end) ||
          acceptance.difference(end).inDays > acceptanceGraceDays)) {
    errors.add('acceptance_out_of_range');
  }
  if (value != null && value > 0) {
    final tier = projectTier(value / rateToUsd);
    if (_months(start, end) > tierMaxMonths[tier]!) {
      errors.add('too_long_for_tier');
    }
    if (members < tierMinMembers[tier]!) errors.add('too_few_members');
  }
  return errors;
}
