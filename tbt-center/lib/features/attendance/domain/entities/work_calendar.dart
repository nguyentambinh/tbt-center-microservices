/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

/// Một ngày trên lịch làm việc: ca, giờ vào ra, ngày lễ, đơn nghỉ
class CalendarDay {
  const CalendarDay({
    required this.date,
    this.shiftStart,
    this.shiftEnd,
    this.coefficient = 1,
    this.isSunday = false,
    this.isHoliday = false,
    this.note,
    this.holiday,
    this.checkIn,
    this.checkOut,
    this.workHours = 0,
    this.overtimeHours = 0,
    this.totalHours = 0,
    this.leaveType,
    this.leaveStatus,
  });

  final DateTime date;
  final String? shiftStart;
  final String? shiftEnd;
  final double coefficient;
  final bool isSunday;
  final bool isHoliday;
  final String? note;
  final String? holiday;
  final String? checkIn;
  final String? checkOut;
  final double workHours;
  final double overtimeHours;
  final double totalHours;
  final String? leaveType;
  final String? leaveStatus;

  bool get hasShift => shiftStart != null;
  bool get worked => checkIn != null;
  bool get onLeave => leaveType != null && leaveStatus != 'rejected';

  /// Có ca, ngày đã qua, không chấm công, không nghỉ phép
  bool absent(DateTime today) => hasShift && !worked && !onLeave && date.isBefore(DateTime(today.year, today.month, today.day));
}

/// Ngày công chuẩn trong tháng để quy lương tháng ra lương ngày
const standardWorkDays = 26;

/// Tăng ca trả 150% giờ thường
const overtimeRate = 1.5;

/// Tiền ước tính của một ngày theo lương cơ bản: giờ thường + tăng ca, nhân hệ số ngày
double estimatedDayPay(CalendarDay day, double baseSalary) {
  final hourly = baseSalary / standardWorkDays / 8;
  return (day.workHours * hourly + day.overtimeHours * hourly * overtimeRate) * day.coefficient;
}

/// Tần suất chấm công: theo thứ (thứ Hai là 0), theo giờ vào ca, theo tháng
class ClockStats {
  const ClockStats({required this.byWeekday, required this.byCheckInHour, required this.byMonth, this.totalDays = 0, this.lateDays = 0});

  final List<int> byWeekday;
  final List<int> byCheckInHour;
  final List<({String month, int days, double hours, int late})> byMonth;
  final int totalDays;
  final int lateDays;
}

/// Tệp minh chứng của đơn nghỉ; [url] mở bản gốc trong vài phút
class LeaveFile {
  const LeaveFile({required this.id, required this.fileName, required this.mimeType, this.url});

  final String id;
  final String fileName;
  final String mimeType;
  final String? url;

  bool get isImage => mimeType.startsWith('image/');
}
