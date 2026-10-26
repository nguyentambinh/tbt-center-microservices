/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

/// Giờ công chuẩn một ngày; làm quá thì phần dư tính là tăng ca.
const standardHours = 8.0;

/// Ca dài từ 6 tiếng trở lên thì trừ 1 tiếng nghỉ trưa.
const lunchBreakFrom = Duration(hours: 6);
const lunchBreak = Duration(hours: 1);

/// Bấm lại trong vòng 5 phút sau khi vào ca coi như bấm nhầm, không ra ca.
const minShift = Duration(minutes: 5);

class ClockRuleViolation implements Exception {
  const ClockRuleViolation(this.code, this.message);

  final String code;
  final String message;
}

typedef ShiftHours = ({double work, double overtime, double total});

/// Chia thời gian từ lúc vào tới lúc ra thành giờ công và giờ tăng ca (R33).
/// Tăng ca chỉ tính tới số giờ của đơn tăng ca đã duyệt trong ngày; không có
/// đơn duyệt thì phần làm quá giờ chuẩn không được tính.
ShiftHours splitHours(Duration span, {double approvedOvertime = 0}) {
  final worked = span >= lunchBreakFrom ? span - lunchBreak : span;
  final actual = _round(worked.inMinutes / 60);
  final work = actual < standardHours ? actual : standardHours;
  final extra = _round(actual - work);
  final overtime = extra < approvedOvertime ? extra : _round(approvedOvertime);
  return (work: work, overtime: overtime, total: _round(work + overtime));
}

/// Làm tròn 2 số lẻ, khớp cột numeric(4, 2).
double _round(double hours) => (hours * 100).round() / 100;

/// Vào ca được tới hết giờ kết thúc ca; ra ca trễ thì vẫn được.
/// Giờ dạng `HH:mm:ss` nên so chuỗi là so giờ.
bool canCheckIn(String now, String shiftEnd) => now.compareTo(shiftEnd) <= 0;

/// Một lượt chấm công: vào ca (lần đầu trong ngày) hay ra ca (lần thứ hai).
enum ClockAction { checkIn, checkOut }
