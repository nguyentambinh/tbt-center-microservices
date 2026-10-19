// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'TBT Center';

  @override
  String get tagline => 'TẬP ĐOÀN ĐA QUỐC GIA';

  @override
  String gemPalette(String gem) {
    return 'Bộ màu $gem';
  }

  @override
  String get gemGold => 'Vàng kim';

  @override
  String get gemPlatinum => 'Bạch kim';

  @override
  String get gemEmerald => 'Lục bảo';

  @override
  String get gemRuby => 'Hồng ngọc';

  @override
  String get gemSapphire => 'Lam ngọc';

  @override
  String get gemDiamond => 'Kim cương';

  @override
  String get samplePayslipTitle => 'Bảng lương tháng 10';

  @override
  String get viewDetails => 'Xem chi tiết';

  @override
  String get downloadPdf => 'Tải PDF';

  @override
  String get settings => 'Cài đặt';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get languageAuto => 'Tự động theo vị trí';

  @override
  String get dataRegion => 'Khu vực lưu dữ liệu';

  @override
  String get detecting => 'Đang xác định vị trí…';

  @override
  String get locationUnknown =>
      'Chưa xác định được vị trí, dùng khu vực mặc định';

  @override
  String detectedCountry(String country) {
    return 'Quốc gia: $country';
  }

  @override
  String get refreshLocation => 'Xác định lại';

  @override
  String get simulateLocation => 'Giả lập vị trí';

  @override
  String get simulateHint =>
      'Chỉ có ở bản debug, dùng để test như đang ở nước khác';

  @override
  String get simulateIp => 'Địa chỉ IP';

  @override
  String get simulateCountry => 'Hoặc mã nước (VD: DE)';

  @override
  String get apply => 'Áp dụng';

  @override
  String get clearSimulation => 'Bỏ giả lập';

  @override
  String get regionVn => 'Việt Nam';

  @override
  String get regionDe => 'Đức';

  @override
  String get regionUs => 'Hoa Kỳ';

  @override
  String get regionBr => 'Brazil';

  @override
  String get regionZa => 'Nam Phi';

  @override
  String get regionAu => 'Úc';

  @override
  String get bannerOffline => 'Không có kết nối mạng · đang xem dữ liệu đã lưu';

  @override
  String get bannerServerDown =>
      'Không kết nối được máy chủ · đang xem dữ liệu đã lưu';

  @override
  String get bannerUnstable => 'Kết nối mạng không ổn định';

  @override
  String get bannerRecovered => 'Đã kết nối lại';

  @override
  String get reconnect => 'Kết nối lại';

  @override
  String get errorNetwork =>
      'Không có kết nối mạng. Kiểm tra Wi-Fi hoặc dữ liệu di động.';

  @override
  String get errorTimeout => 'Máy chủ phản hồi quá lâu, vui lòng thử lại.';

  @override
  String get errorServer => 'Máy chủ đang gặp sự cố, vui lòng thử lại sau.';

  @override
  String get errorUnauthorized =>
      'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.';

  @override
  String get errorForbidden => 'Bạn không có quyền thực hiện thao tác này.';

  @override
  String get errorNotFound => 'Không tìm thấy dữ liệu yêu cầu.';

  @override
  String get errorValidation => 'Dữ liệu chưa hợp lệ, vui lòng kiểm tra lại.';

  @override
  String get errorOfflineWrite =>
      'Cần có mạng để lưu thay đổi. Dữ liệu bạn nhập vẫn được giữ lại.';

  @override
  String get errorUnknown => 'Đã xảy ra lỗi không mong muốn, vui lòng thử lại.';

  @override
  String get signIn => 'Đăng nhập';

  @override
  String get applyAsCandidate => 'Ứng tuyển · tạo tài khoản';

  @override
  String get signOut => 'Đăng xuất';

  @override
  String welcome(String name) {
    return 'Xin chào, $name';
  }

  @override
  String dataStoredIn(String region) {
    return 'Dữ liệu của bạn được lưu tại khu vực $region';
  }

  @override
  String get signInFailed =>
      'Không mở được trang đăng nhập. Kiểm tra kết nối tới máy chủ rồi thử lại.';

  @override
  String get roleExecutive => 'Văn phòng quản lý';

  @override
  String get roleAdmin => 'Quản trị hệ thống';

  @override
  String get roleHr => 'Nhân sự';

  @override
  String get roleFinance => 'Tài chính';

  @override
  String get roleEmployee => 'Nhân viên';

  @override
  String get roleCandidate => 'Ứng viên';

  @override
  String get regionCheckTitle => 'Kết nối khu vực';

  @override
  String get regionCheckHint =>
      'Gọi thử máy chủ của khu vực bạn qua Kong, có kèm token đăng nhập.';

  @override
  String get regionCheckButton => 'Kiểm tra';

  @override
  String regionCheckOk(String service) {
    return 'Máy chủ $service trả lời bình thường';
  }

  @override
  String get savedDataNote => 'Đang hiển thị dữ liệu đã lưu';

  @override
  String get themePreview => 'Xem các bộ màu đá quý';

  @override
  String get employees => 'Hồ sơ nhân viên';

  @override
  String get employeesHint =>
      'Danh sách và hồ sơ nhân viên trong khu vực của bạn';

  @override
  String get open => 'Mở';

  @override
  String get searchEmployees => 'Tìm theo tên, mã hoặc email';

  @override
  String employeeCount(int count) {
    return '$count nhân viên';
  }

  @override
  String get noEmployees => 'Không tìm thấy nhân viên nào';

  @override
  String get loadMore => 'Tải thêm';

  @override
  String get retry => 'Thử lại';

  @override
  String get sectionWork => 'Công việc';

  @override
  String get sectionContact => 'Liên hệ';

  @override
  String get sectionRelatives => 'Người thân';

  @override
  String get sectionHealth => 'Sức khỏe';

  @override
  String get sectionInsurance => 'Bảo hiểm';

  @override
  String get fieldId => 'Mã nhân viên';

  @override
  String get fieldCompany => 'Đơn vị';

  @override
  String get fieldDepartment => 'Phòng ban';

  @override
  String get fieldPosition => 'Chức vụ';

  @override
  String get fieldBirthYear => 'Năm sinh';

  @override
  String get fieldGender => 'Giới tính';

  @override
  String get genderMale => 'Nam';

  @override
  String get genderFemale => 'Nữ';

  @override
  String get fieldHiredOn => 'Ngày vào làm';

  @override
  String get fieldLaborContract => 'Hợp đồng lao động';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldPhone => 'Điện thoại';

  @override
  String get fieldAddress => 'Địa chỉ';

  @override
  String get fieldHometown => 'Quê quán';

  @override
  String get fieldHeight => 'Chiều cao';

  @override
  String get fieldWeight => 'Cân nặng';

  @override
  String get fieldVision => 'Thị lực';

  @override
  String get fieldMedicalHistory => 'Tiền sử bệnh';

  @override
  String get fieldUpdatedOn => 'Cập nhật';

  @override
  String get fieldInsuranceType => 'Loại bảo hiểm';

  @override
  String get fieldInsuranceNumber => 'Số bảo hiểm';

  @override
  String get fieldExpiresOn => 'Hết hạn';

  @override
  String get noData => 'Chưa có dữ liệu';

  @override
  String get attendance => 'Chấm công & nghỉ phép';

  @override
  String get attendanceHint => 'Giờ làm của bạn, đơn nghỉ và duyệt đơn';

  @override
  String get tabTimesheet => 'Chấm công';

  @override
  String get tabLeave => 'Nghỉ phép';

  @override
  String get tabApprovals => 'Duyệt đơn';

  @override
  String totalHours(String hours, int days) {
    return 'Tổng $hours giờ trong $days ngày';
  }

  @override
  String checkInOut(String checkIn, String checkOut) {
    return 'Vào $checkIn · Ra $checkOut';
  }

  @override
  String overtimeHours(String hours) {
    return 'Tăng ca $hours giờ';
  }

  @override
  String get newLeave => 'Xin nghỉ';

  @override
  String get leaveType => 'Loại nghỉ';

  @override
  String get leaveAnnual => 'Nghỉ phép năm';

  @override
  String get leaveSick => 'Nghỉ ốm';

  @override
  String get leaveUnpaid => 'Nghỉ không lương';

  @override
  String get leavePersonal => 'Việc riêng';

  @override
  String get leaveDates => 'Thời gian nghỉ';

  @override
  String get pickDates => 'Chọn ngày';

  @override
  String get reason => 'Lý do';

  @override
  String get submitLeave => 'Gửi đơn';

  @override
  String get leaveSubmitted => 'Đã gửi đơn nghỉ';

  @override
  String get statusPending => 'Chờ duyệt';

  @override
  String get statusApproved => 'Đã duyệt';

  @override
  String get statusRejected => 'Từ chối';

  @override
  String get approve => 'Duyệt';

  @override
  String get reject => 'Từ chối';

  @override
  String leaveDays(int days) {
    return '$days ngày';
  }

  @override
  String get noLeaves => 'Chưa có đơn nghỉ nào';

  @override
  String get noPending => 'Không có đơn nào chờ duyệt';

  @override
  String get noTimesheets => 'Chưa có dữ liệu chấm công';

  @override
  String get leaveDecided => 'Đã cập nhật đơn';

  @override
  String get errOverlap => 'Khoảng thời gian này trùng với một đơn nghỉ khác';

  @override
  String get errTooLong => 'Mỗi đơn nghỉ tối đa 30 ngày';

  @override
  String get errInvalidDates => 'Ngày kết thúc phải sau ngày bắt đầu';

  @override
  String get errAlreadyDecided => 'Đơn này đã được xử lý trước đó';

  @override
  String get errSelfApproval => 'Bạn không thể tự duyệt đơn của mình';

  @override
  String get errRegionMismatch =>
      'Dữ liệu thuộc khu vực khác, bạn không có quyền xem';

  @override
  String get errNoEmployee => 'Tài khoản chưa được gắn với hồ sơ nhân viên';

  @override
  String get myApplication => 'Hồ sơ ứng tuyển của tôi';

  @override
  String get myApplicationHint => 'Nộp hồ sơ, xem tiến trình tuyển dụng';

  @override
  String get candidates => 'Ứng viên';

  @override
  String get candidatesHint => 'Danh sách hồ sơ ứng tuyển và chuyển bước';

  @override
  String get applyNow => 'Nộp hồ sơ';

  @override
  String get editProfile => 'Sửa hồ sơ';

  @override
  String get saveProfile => 'Lưu hồ sơ';

  @override
  String get fullName => 'Họ và tên';

  @override
  String get appliedPosition => 'Vị trí ứng tuyển';

  @override
  String get consentAi => 'Đồng ý cho AI đọc và tóm tắt CV của tôi';

  @override
  String get notAppliedYet => 'Bạn chưa nộp hồ sơ nào';

  @override
  String get progress => 'Tiến trình';

  @override
  String get profileSaved => 'Đã lưu hồ sơ';

  @override
  String get profileLockedHint =>
      'Hồ sơ đã vào vòng phỏng vấn nên không sửa được nữa';

  @override
  String get moveTo => 'Chuyển sang';

  @override
  String get statusChanged => 'Đã chuyển bước';

  @override
  String get noCandidates => 'Chưa có ứng viên';

  @override
  String get allStatuses => 'Tất cả';

  @override
  String get note => 'Ghi chú';

  @override
  String get stageSubmitted => 'Đã nộp';

  @override
  String get stageAnalyzed => 'AI đã tóm tắt';

  @override
  String get stageScreening => 'Đang sàng lọc';

  @override
  String get stageInterview => 'Phỏng vấn';

  @override
  String get stageOffered => 'Mời nhận việc';

  @override
  String get stageRejected => 'Chưa phù hợp';

  @override
  String get errProfileLocked =>
      'Hồ sơ đã vào vòng phỏng vấn nên không sửa được nữa';

  @override
  String get cvSection => 'CV';

  @override
  String get cvNone => 'Chưa có CV';

  @override
  String get cvAttached => 'Đã có CV';

  @override
  String get uploadCv => 'Tải CV lên (PDF)';

  @override
  String get replaceCv => 'Thay CV khác';

  @override
  String get cvUploaded => 'Đã tải CV lên';

  @override
  String get cvWaitingAi => 'AI đang đọc CV, kết quả sẽ có sau ít phút';

  @override
  String get openCv => 'Mở CV';

  @override
  String get aiSummary => 'Tóm tắt của AI';

  @override
  String get aiDisclaimer =>
      'Bản tóm tắt do AI tạo, hãy đối chiếu với CV gốc trước khi quyết định.';

  @override
  String yearsExperience(String years) {
    return '$years năm kinh nghiệm';
  }

  @override
  String get skills => 'Kỹ năng';

  @override
  String get suitablePositions => 'Vị trí phù hợp';

  @override
  String get strengths => 'Điểm mạnh';

  @override
  String get interviewQuestions => 'Nên hỏi thêm khi phỏng vấn';

  @override
  String get errCvNotPdf => 'File CV phải là PDF';

  @override
  String get errCvTooLarge => 'CV tối đa 10 MB';

  @override
  String get payslips => 'Phiếu lương';

  @override
  String get payslipsHint => 'Lương từng kỳ, thưởng và phạt';

  @override
  String get baseSalary => 'Lương cơ bản';

  @override
  String get grossPay => 'Tổng thu nhập';

  @override
  String get netPay => 'Thực nhận';

  @override
  String netUsd(String amount) {
    return '≈ $amount quy đổi theo tỷ giá ngày trả';
  }

  @override
  String paidOn(String date) {
    return 'Trả ngày $date';
  }

  @override
  String get bonusesPenalties => 'Thưởng / phạt';

  @override
  String get bonus => 'Thưởng';

  @override
  String get penalty => 'Phạt';

  @override
  String get noPayslips => 'Chưa có phiếu lương';

  @override
  String get payrollRuns => 'Chốt lương';

  @override
  String get payrollRunsHint => 'Tính và chi lương cả khu vực theo kỳ';

  @override
  String startPayrollRun(String period) {
    return 'Chốt lương kỳ $period';
  }

  @override
  String get runRunning => 'Đang chạy';

  @override
  String get runCompleted => 'Hoàn tất';

  @override
  String get runFailed => 'Lỗi, đã hoàn tác';

  @override
  String get retryRun => 'Chạy lại';

  @override
  String get sagaSteps => 'Các bước';

  @override
  String get stepCollectHours => 'Lấy giờ công';

  @override
  String get stepFetchRate => 'Lấy tỷ giá';

  @override
  String get stepCalculate => 'Tính phiếu lương';

  @override
  String get stepPay => 'Chi lương qua ngân hàng';

  @override
  String get stepComplete => 'Hoàn tất';

  @override
  String get stepCompensate => 'Hoàn tác phần chưa chi';

  @override
  String get stepRetry => 'Chạy lại';

  @override
  String get stepResume => 'Chạy tiếp sau khi khởi động lại';

  @override
  String paidSummary(int count, String amount) {
    return '$count phiếu đã chi · $amount';
  }

  @override
  String get noRuns => 'Chưa chốt kỳ nào';

  @override
  String get errRunExists => 'Kỳ này đã chốt rồi';

  @override
  String get errRunFailed => 'Kỳ này đã chốt nhưng lỗi, hãy chạy lại';

  @override
  String get groupReport => 'Báo cáo tập đoàn';

  @override
  String get groupReportHint => 'Số liệu hợp nhất mọi khu vực, quy về USD';

  @override
  String get payrollCostByRegion => 'Chi phí lương theo khu vực';

  @override
  String get leavesByRegion => 'Đơn nghỉ theo khu vực';

  @override
  String get candidatesByRegion => 'Ứng viên theo khu vực';

  @override
  String get groupTotal => 'Toàn tập đoàn';

  @override
  String dataAsOf(String id) {
    return 'Số liệu tới sự kiện #$id';
  }

  @override
  String get noReportData => 'Chưa có số liệu';

  @override
  String employeesCount(int count) {
    return '$count người';
  }

  @override
  String get projects => 'Dự án và hợp đồng';

  @override
  String get projectsHint => 'Dự án, khách hàng, nhân sự tham gia';

  @override
  String get searchProjects => 'Tìm mã dự án, hợp đồng, khách hàng';

  @override
  String get noProjects => 'Không có dự án';

  @override
  String get projectMoney => 'Giá trị dự án';

  @override
  String get deposit => 'Tiền cọc';

  @override
  String get expectedAcceptance => 'Nghiệm thu dự kiến';

  @override
  String get customer => 'Khách hàng';

  @override
  String get customerContactHidden =>
      'Liên hệ của khách hàng chỉ bộ phận tài chính xem được';

  @override
  String get contracts => 'Hợp đồng';

  @override
  String get projectMembers => 'Nhân sự tham gia';

  @override
  String get myProjects => 'Dự án của tôi';

  @override
  String get myProjectsHint => 'Dự án đang tham gia và số giờ đã làm';

  @override
  String get noMyProjects => 'Bạn chưa tham gia dự án nào';

  @override
  String get finance => 'Tài chính';

  @override
  String get financeHint => 'Thu chi theo tháng, nhà cung cấp, chốt sổ';

  @override
  String get incomeExpense => 'Thu chi';

  @override
  String get suppliers => 'Nhà cung cấp';

  @override
  String get revenue => 'Doanh thu';

  @override
  String get cost => 'Chi phí';

  @override
  String get profit => 'Lợi nhuận';

  @override
  String get periodClosed => 'Đã chốt sổ';

  @override
  String get closePeriod => 'Chốt sổ';

  @override
  String get noFinanceData => 'Năm này chưa có số liệu';

  @override
  String get purchased => 'Đã mua';

  @override
  String get paid => 'Đã trả';

  @override
  String get balance => 'Còn nợ';

  @override
  String get recordPurchase => 'Ghi mua';

  @override
  String get recordPayment => 'Trả tiền';

  @override
  String get materialName => 'Tên vật liệu';

  @override
  String get amount => 'Số tiền';

  @override
  String get purchaseHistory => 'Lịch sử mua';

  @override
  String get paymentHistory => 'Lịch sử trả';

  @override
  String get financeByRegion => 'Doanh thu, chi phí đã chốt sổ';

  @override
  String get cancel => 'Hủy';

  @override
  String get save => 'Lưu';

  @override
  String get errPeriodClosed => 'Tháng này đã chốt sổ, không ghi thêm được';

  @override
  String get errPeriodNotEnded => 'Tháng này chưa kết thúc, chưa chốt sổ được';

  @override
  String get errOverpaid => 'Số tiền trả lớn hơn số còn nợ';

  @override
  String get errInvalidAmount => 'Số tiền không hợp lệ';

  @override
  String closePeriodConfirm(String period) {
    return 'Chốt sổ tháng $period? Sau khi chốt không ghi thêm chứng từ vào tháng này.';
  }

  @override
  String hoursValue(String hours) {
    return '$hours giờ';
  }

  @override
  String get clockToday => 'Chấm công hôm nay';

  @override
  String get noShiftToday =>
      'Hôm nay bạn không có ca làm việc, không chấm công được';

  @override
  String get clockIn => 'Vào ca';

  @override
  String get clockOut => 'Ra ca';

  @override
  String get shiftDone => 'Đã xong ca hôm nay';

  @override
  String get holidayShift => 'Ngày lễ';

  @override
  String get sundayShift => 'Chủ nhật';

  @override
  String get tabOvertime => 'Tăng ca';

  @override
  String get newOvertime => 'Xin tăng ca';

  @override
  String get noOvertime => 'Chưa có đơn tăng ca';

  @override
  String get submitOvertime => 'Gửi đơn';

  @override
  String get errNoShift => 'Hôm nay bạn không có ca làm việc';

  @override
  String get errAlreadyClockedOut => 'Bạn đã ra ca hôm nay rồi';

  @override
  String get errTooSoon => 'Vừa vào ca, chờ ít nhất 5 phút mới ra ca được';

  @override
  String get errInvalidHours => 'Số giờ tăng ca phải từ 0,5 đến 12';

  @override
  String clockedIn(String time) {
    return 'Đã vào ca lúc $time';
  }

  @override
  String clockedOut(String time, String hours) {
    return 'Đã ra ca lúc $time, làm $hours giờ';
  }

  @override
  String totalHoursToday(String hours) {
    return 'Hôm nay làm $hours giờ';
  }

  @override
  String get notifications => 'Thông báo';

  @override
  String get noNotifications => 'Chưa có thông báo';

  @override
  String get markAllRead => 'Đọc hết';

  @override
  String get nGeneric => 'Bạn có thông báo mới';

  @override
  String nLeaveRequested(String employee, String days, String date) {
    return '$employee xin nghỉ $days ngày từ $date';
  }

  @override
  String nLeaveApproved(String date) {
    return 'Đơn nghỉ từ $date đã được duyệt';
  }

  @override
  String nLeaveRejected(String date) {
    return 'Đơn nghỉ từ $date bị từ chối';
  }

  @override
  String nOvertimeRequested(String employee, String hours, String date) {
    return '$employee xin tăng ca $hours giờ ngày $date';
  }

  @override
  String nOvertimeApproved(String date) {
    return 'Đơn tăng ca ngày $date đã được duyệt';
  }

  @override
  String nOvertimeRejected(String date) {
    return 'Đơn tăng ca ngày $date bị từ chối';
  }

  @override
  String nCandidateApplied(String position) {
    return 'Có hồ sơ ứng tuyển mới: $position';
  }

  @override
  String nCandidateStatus(String stage) {
    return 'Hồ sơ của bạn đã chuyển sang bước: $stage';
  }

  @override
  String nPayrollPaid(String period) {
    return 'Lương kỳ $period đã được chi';
  }

  @override
  String nPayrollFailed(String period) {
    return 'Chốt lương kỳ $period bị lỗi, cần chạy lại';
  }

  @override
  String nFinanceClosed(String period) {
    return 'Đã chốt sổ tài chính tháng $period';
  }

  @override
  String get importCandidates => 'Nhập ứng viên từ tệp';

  @override
  String get confirmAll => 'Xác nhận tất cả';

  @override
  String get importRowNew => 'Thêm mới';

  @override
  String get importRowUpdate => 'Cập nhật';

  @override
  String get importRowAccepted => 'Đã ghi';

  @override
  String get importErrMissingName => 'Thiếu họ tên';

  @override
  String get importErrMissingContact => 'Thiếu email và số điện thoại';

  @override
  String get importErrInvalidEmail => 'Email sai định dạng';

  @override
  String get errUnsupportedFile => 'Chỉ nhận tệp .csv hoặc .xlsx';

  @override
  String get errMissingNameColumn => 'Tệp không có cột họ tên ở dòng đầu';

  @override
  String get errEmptyFile => 'Tệp không có dòng ứng viên nào';

  @override
  String get errFileTooLarge => 'Tệp lớn hơn 2 MB';

  @override
  String confirmSelected(int count) {
    return 'Xác nhận đã chọn ($count)';
  }

  @override
  String importAccepted(int count) {
    return 'Đã ghi $count hồ sơ';
  }

  @override
  String importSummary(int total, int pending) {
    return '$total dòng, còn $pending dòng chờ xác nhận';
  }

  @override
  String importRowNumber(int n) {
    return 'Dòng $n';
  }

  @override
  String get roleAuditor => 'Kiểm toán';

  @override
  String get gemAmethyst => 'Thạch anh tím';

  @override
  String get auditLog => 'Sổ kiểm toán';

  @override
  String get auditLogHint =>
      'Sự kiện mọi khu vực, kiểm chuỗi băm, xuất cho kiểm toán';

  @override
  String get auditEvents => 'Sự kiện';

  @override
  String get accessLog => 'Ai đã truy cập';

  @override
  String get verifyChain => 'Kiểm chuỗi băm';

  @override
  String get exportAudit => 'Xuất cho kiểm toán';

  @override
  String get auditSearch => 'Tra cứu';

  @override
  String get chainIntact => 'Sổ còn nguyên vẹn, không dòng nào bị sửa';

  @override
  String get exportChecksumHint =>
      'Mã SHA-256 của tệp xuất. Bên kiểm toán tính lại mã của tệp nhận được, khác mã này là tệp đã bị sửa.';

  @override
  String get copyChecksum => 'Chép mã';

  @override
  String get close => 'Đóng';

  @override
  String get allRegions => 'Mọi khu vực';

  @override
  String get errAccessExpired => 'Quyền kiểm toán của bạn đã hết hạn';

  @override
  String chainBroken(String id) {
    return 'Chuỗi băm sai từ dòng #$id';
  }

  @override
  String chainChecked(int count) {
    return 'Đã kiểm $count dòng';
  }

  @override
  String exportDone(int count) {
    return 'Đã xuất $count dòng';
  }

  @override
  String rowsCount(int count) {
    return '$count dòng';
  }

  @override
  String supplierPurchases(int count) {
    return '$count lần mua';
  }

  @override
  String supplierPaidPercent(String percent) {
    return 'đã trả $percent%';
  }

  @override
  String get acceptProject => 'Nghiệm thu';

  @override
  String get projectInProgress => 'Đang thi công';

  @override
  String get errAlreadyAccepted => 'Dự án này đã nghiệm thu rồi';

  @override
  String get errFinanceUnavailable =>
      'Chưa ghi được doanh thu ở tài chính, dự án chưa đổi trạng thái. Thử lại sau.';

  @override
  String acceptProjectConfirm(String amount) {
    return 'Nghiệm thu dự án và ghi doanh thu $amount vào tài chính?';
  }

  @override
  String projectAcceptedOn(String date) {
    return 'Đã nghiệm thu $date';
  }

  @override
  String nProjectAccepted(String project) {
    return 'Dự án $project đã nghiệm thu, doanh thu đã ghi vào tài chính';
  }

  @override
  String get workConditions => 'Điều kiện làm việc';

  @override
  String workHoursSummary(String hours, String overtime) {
    return '$hours giờ · tăng ca $overtime giờ';
  }

  @override
  String get noticeQueued => 'đang chờ gửi';

  @override
  String get noticeSent => 'đã gửi';

  @override
  String customerNotice(String channel, String status) {
    return 'Xác nhận cho khách hàng qua $channel: $status';
  }

  @override
  String get attachCv => 'Đính kèm CV (PDF, tối đa 10 MB)';

  @override
  String cvSelected(String name) {
    return 'CV: $name';
  }

  @override
  String get stageHired => 'Đã nhận vào làm';

  @override
  String get hireCandidate => 'Nhận vào làm';

  @override
  String get hiredKeepPassword =>
      'Mật khẩu: giữ nguyên mật khẩu người này đang dùng.';

  @override
  String get hiredRelogin =>
      'Người này đăng xuất rồi đăng nhập lại để vào với vai trò Nhân viên.';

  @override
  String hireConfirm(String name, String email) {
    return 'Nhận $name vào làm? Email $email sẽ là tên đăng nhập của nhân viên mới.';
  }

  @override
  String hiredTitle(String id) {
    return 'Đã tạo nhân viên $id';
  }

  @override
  String hiredLogin(String login) {
    return 'Tên đăng nhập: $login';
  }

  @override
  String hiredTempPassword(String password) {
    return 'Mật khẩu tạm: $password (chỉ hiện một lần, đổi ở lần đăng nhập đầu)';
  }

  @override
  String get home => 'Trang chủ';

  @override
  String get sectionMyWork => 'Công việc của tôi';

  @override
  String get sectionManage => 'Quản lý';

  @override
  String get sectionFinance => 'Tài chính';

  @override
  String get sectionAudit => 'Kiểm toán';

  @override
  String nPayslipIssued(String period) {
    return 'Phiếu lương kỳ $period của bạn đã có';
  }

  @override
  String nPayrollNeedsAttention(String period) {
    return 'Chốt lương kỳ $period cần xử lý tay';
  }

  @override
  String get errPeriodLocked =>
      'Kỳ này đang chốt lương, tạm chưa duyệt được. Thử lại sau ít phút';

  @override
  String get runNeedsAttention => 'Cần xử lý tay';

  @override
  String get stepLockPeriod => 'Khóa kỳ ở chấm công';

  @override
  String get stepReserveBudget => 'Giữ ngân sách lương';

  @override
  String get stepReleaseBudget => 'Nhả ngân sách (bù trừ)';

  @override
  String get stepRecordExpense => 'Ghi chi phí lương sang tài chính';

  @override
  String get stepIssuePayslips => 'Gửi phiếu lương cho nhân viên';

  @override
  String get stepUnlockPeriod => 'Mở khóa kỳ';

  @override
  String get stepNeedsAttention => 'Chờ xử lý tay';

  @override
  String get knowledge => 'Kho tri thức';

  @override
  String get knowledgeHint => 'Quy định lương, nghỉ phép, tăng ca, quy trình';

  @override
  String get knowledgeSearchHint => 'Tìm, ví dụ: tăng ca, chốt lương';

  @override
  String get knowledgeEmpty => 'Không tìm thấy bài phù hợp';

  @override
  String get sectionKnowledge => 'Tri thức';

  @override
  String get knowledgeTabAsk => 'Hỏi AI';

  @override
  String get knowledgeTabSearch => 'Tìm bài';

  @override
  String get knowledgeTabGraph => 'Đồ thị';

  @override
  String get askHint => 'Hỏi về lương, nghỉ phép, chấm công…';

  @override
  String get askIntro =>
      'Trợ lý trả lời dựa trên kho tri thức và đồ thị tri thức của công ty, kèm nguồn để bạn tự kiểm tra.';

  @override
  String get askExample1 => 'Làm thêm giờ được trả bao nhiêu?';

  @override
  String get askExample2 => 'Ai duyệt đơn nghỉ phép của tôi?';

  @override
  String get askExample3 => 'Vì sao không duyệt được đơn khi đang chốt lương?';

  @override
  String get askExample4 => 'Dữ liệu cá nhân của tôi được bảo vệ thế nào?';

  @override
  String get askThinking => 'Đang tìm trong kho tri thức…';

  @override
  String get askSources => 'Nguồn';

  @override
  String get askGraphFacts => 'Dựa trên đồ thị tri thức';

  @override
  String askAnsweredBy(String model) {
    return 'Trả lời bởi $model';
  }

  @override
  String get askNoAi => 'Không dùng AI, trích trực tiếp từ kho';

  @override
  String get askCached => 'đã lưu sẵn';

  @override
  String get askHelpful => 'Hữu ích';

  @override
  String get askNotHelpful => 'Chưa đúng';

  @override
  String get askThanks => 'Cảm ơn góp ý của bạn';

  @override
  String get askFailed => 'Chưa gửi được câu hỏi';

  @override
  String get askNewChat => 'Cuộc trò chuyện mới';

  @override
  String get askSend => 'Gửi';

  @override
  String get askViaKeyword => 'từ khóa';

  @override
  String get askViaSemantic => 'theo nghĩa';

  @override
  String get askViaGraph => 'đồ thị';

  @override
  String get graphSearchHint => 'Tìm khái niệm, ví dụ: tăng ca';

  @override
  String get graphRelated => 'Liên kết';

  @override
  String get graphReadArticle => 'Đọc bài';

  @override
  String get graphAskAbout => 'Hỏi AI về mục này';

  @override
  String graphAskTemplate(String topic) {
    return 'Giải thích giúp tôi về $topic';
  }

  @override
  String get graphTypeConcept => 'Khái niệm';

  @override
  String get graphTypeProcess => 'Quy trình';

  @override
  String get graphTypeStep => 'Bước';

  @override
  String get graphTypeRule => 'Quy tắc';

  @override
  String get graphTypeRole => 'Vai trò';

  @override
  String get graphTypeService => 'Service';

  @override
  String get graphTypeRegion => 'Quốc gia';

  @override
  String get graphTypeDocument => 'Bài viết';

  @override
  String get knowledgeMore => 'Thêm';

  @override
  String get ontologyTitle => 'Bản thể học';

  @override
  String get ontologyClasses => 'Cây lớp';

  @override
  String get ontologyRelations => 'Quan hệ';

  @override
  String get ontologyRules => 'Luật suy luận';

  @override
  String ontologyTotals(int nodes, int asserted, int extracted, int inferred) {
    return '$nodes nút · $asserted cạnh có sẵn · $extracted cạnh AI trích · $inferred cạnh suy ra';
  }

  @override
  String ontologyReasoning(int count, int ms) {
    return 'Lần suy luận gần nhất: $count cạnh mới trong $ms ms';
  }

  @override
  String get ontologyRerun => 'Chạy lại suy luận';

  @override
  String get ontologyTransitive => 'bắc cầu';

  @override
  String get ontologySymmetric => 'đối xứng';

  @override
  String ontologyInverse(String name) {
    return 'ngược của $name';
  }

  @override
  String ontologySubProperty(String name) {
    return 'kéo theo $name';
  }

  @override
  String get ontologyDerived => 'chỉ do suy luận';

  @override
  String ontologyEdgeCount(int count) {
    return '$count cạnh';
  }

  @override
  String get ontologyExport =>
      'Xuất RDF/OWL dạng Turtle tại /knowledge/ontology?format=turtle, mở được bằng Protégé.';

  @override
  String get sparqlTitle => 'Truy vấn SPARQL';

  @override
  String get sparqlHint => 'Viết câu SELECT hoặc chọn câu mẫu';

  @override
  String get sparqlRun => 'Chạy';

  @override
  String get sparqlIncludeInferred => 'Tính cả cạnh suy luận';

  @override
  String get sparqlNoRows => 'Không có kết quả';

  @override
  String sparqlRows(int count, int ms) {
    return '$count dòng · $ms ms';
  }

  @override
  String sparqlError(String message) {
    return 'Câu truy vấn lỗi: $message';
  }

  @override
  String get sparqlSampleInvolves => 'Chốt lương cần service nào';

  @override
  String get sparqlSampleViewers => 'Ai được xem lương thực nhận';

  @override
  String get sparqlSampleBefore => 'Bước nào trước bước chi ngân hàng';

  @override
  String get sparqlSampleRabbit => 'Service nào dùng RabbitMQ';

  @override
  String get sparqlSampleCount => 'Đếm service mỗi nơi';

  @override
  String get proposalsTitle => 'Đề xuất từ AI';

  @override
  String get proposalsRun => 'Cho AI đọc bài mới';

  @override
  String get proposalsRunning => 'AI đang đọc bài viết…';

  @override
  String proposalsQueued(int count) {
    return 'AI sẽ đọc $count bài';
  }

  @override
  String get proposalsNoAi => 'Chưa cấu hình AI cho việc trích xuất';

  @override
  String get proposalsPending => 'Chờ duyệt';

  @override
  String get proposalsInvalid => 'Không hợp lệ';

  @override
  String get proposalsApproved => 'Đã duyệt';

  @override
  String get proposalsRejected => 'Đã bỏ';

  @override
  String get proposalsEmpty => 'Không có đề xuất';

  @override
  String get proposalNewNode => 'Nút mới';

  @override
  String proposalFrom(String article) {
    return 'Trích từ bài $article';
  }

  @override
  String get proposalApprove => 'Duyệt';

  @override
  String get proposalReject => 'Bỏ';

  @override
  String get proposalApproved => 'Đã thêm vào đồ thị, máy đang suy luận lại';

  @override
  String get proposalRejected => 'Đã bỏ đề xuất';

  @override
  String proposalConfidence(int percent) {
    return 'Độ tin cậy $percent%';
  }

  @override
  String get proposalReasonEvidence => 'Câu trích không có trong bài';

  @override
  String get proposalReasonConfidence => 'AI không chắc chắn';

  @override
  String proposalReasonOntology(String code) {
    return 'Sai miền hoặc phạm vi của quan hệ ($code)';
  }

  @override
  String get proposalReasonUnused => 'Nút không dùng trong cạnh hợp lệ nào';

  @override
  String proposalReasonOther(String code) {
    return 'Lý do: $code';
  }

  @override
  String get graphInferred => 'Suy ra';

  @override
  String graphInferredBy(String rule) {
    return 'Máy suy ra bằng luật: $rule';
  }

  @override
  String get graphBecause => 'Vì';

  @override
  String get graphEvidence => 'AI trích từ bài viết, HR đã duyệt:';

  @override
  String get graphGoTo => 'Mở nút này';

  @override
  String get graphPathTo => 'Nối tới…';

  @override
  String graphPathTitle(String from, String to) {
    return 'Từ $from tới $to';
  }

  @override
  String get graphPathNone => 'Không nối được trong 6 bước';

  @override
  String get graphPathPick => 'Chọn khái niệm cần nối tới';

  @override
  String get graphTypeTechnology => 'Công nghệ';

  @override
  String get graphTypePattern => 'Mẫu kiến trúc';

  @override
  String get todoTitle => 'Việc cần xử lý';

  @override
  String todoLeaves(int count) {
    return '$count đơn nghỉ chờ duyệt';
  }

  @override
  String todoOvertime(int count) {
    return '$count đơn tăng ca chờ duyệt';
  }

  @override
  String todoCandidates(int count) {
    return '$count hồ sơ ứng viên mới';
  }

  @override
  String get todoNone => 'Không có việc nào đang chờ';

  @override
  String get signOutConfirm => 'Đăng xuất khỏi TBT Center?';

  @override
  String get stepErrorTimeout =>
      'Ngân hàng không phản hồi kịp; hệ thống đối soát theo mã tham chiếu trước khi chi lại';

  @override
  String get stepErrorGeneric =>
      'Bước này không chạy được; bấm Chạy lại hoặc báo bộ phận kỹ thuật';

  @override
  String get errSparqlSyntax =>
      'Câu truy vấn chưa đúng cú pháp. Kiểm tra lại dấu ngoặc, dấu chấm cuối mỗi điều kiện và tên tiền tố (kg:, kgo:).';
}
