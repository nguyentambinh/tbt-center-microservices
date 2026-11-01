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

/// Chấm vào sớm nhất và chấm ra muộn nhất so với giờ ca.
const clockWindow = Duration(minutes: 30);

int _minutes(String hhmm) {
  final parts = hhmm.split(':');
  return int.parse(parts[0]) * 60 + int.parse(parts[1]);
}

String _hhmm(int minutes) =>
    '${(minutes ~/ 60).toString().padLeft(2, '0')}:'
    '${(minutes % 60).toString().padLeft(2, '0')}';

/// Giờ sớm nhất được chấm vào, không lùi qua 00:00 của ngày trước
String clockInFrom(String shiftStart) {
  final from = _minutes(shiftStart) - clockWindow.inMinutes;
  return _hhmm(from < 0 ? 0 : from);
}

/// Giờ muộn nhất được chấm ra: hết ca + [clockWindow] + tăng ca đã duyệt,
/// tối đa 23:59 vì công tính trong ngày
String clockOutUntil(String shiftEnd, double approvedOvertime) {
  final until =
      _minutes(shiftEnd) +
      clockWindow.inMinutes +
      (approvedOvertime * 60).round();
  return _hhmm(until > 1439 ? 1439 : until);
}

/// Giờ dạng `HH:mm` hoặc `HH:mm:ss`, so theo phút
bool isBefore(String now, String limit) => _minutes(now) < _minutes(limit);
bool isAfter(String now, String limit) => _minutes(now) > _minutes(limit);

/// Một lượt chấm công: vào ca (lần đầu trong ngày) hay ra ca (lần thứ hai).
enum ClockAction { checkIn, checkOut }
