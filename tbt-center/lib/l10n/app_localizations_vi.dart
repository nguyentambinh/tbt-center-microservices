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
  String get stepPay => 'Chi lương qua kênh thanh toán';

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
      'Kênh thanh toán không phản hồi kịp; hệ thống đối soát theo mã tham chiếu trước khi chi lại';

  @override
  String get stepErrorGeneric =>
      'Bước này không chạy được; bấm Chạy lại hoặc báo bộ phận kỹ thuật';

  @override
  String get errSparqlSyntax =>
      'Câu truy vấn chưa đúng cú pháp. Kiểm tra lại dấu ngoặc, dấu chấm cuối mỗi điều kiện và tên tiền tố (kg:, kgo:).';

  @override
  String get appearance => 'Giao diện';

  @override
  String get themeSystem => 'Theo điện thoại';

  @override
  String get themeLight => 'Sáng';

  @override
  String get themeDark => 'Tối';

  @override
  String get payoutCompany => 'Công ty';

  @override
  String payoutPayRegion(String region) {
    return 'Chuyển lương $region';
  }

  @override
  String get payoutPayGroup => 'Chuyển cả tập đoàn';

  @override
  String payoutPaySelected(int count) {
    return 'Chuyển cho $count người';
  }

  @override
  String payoutConfirmTitle(String period) {
    return 'Chuyển lương kỳ $period?';
  }

  @override
  String payoutConfirmRegion(String region) {
    return 'Chuyển cho nhân viên công ty $region. Ai đã nhận rồi sẽ được hỏi lại trước khi chuyển.';
  }

  @override
  String payoutConfirmGroup(int count) {
    return 'Chuyển cho nhân viên của cả $count công ty. Ai đã nhận rồi sẽ được hỏi lại trước khi chuyển.';
  }

  @override
  String payoutConfirmPeople(int count, String region) {
    return 'Chuyển cho $count người đã chọn ở công ty $region.';
  }

  @override
  String get payoutConfirm => 'Chuyển';

  @override
  String get payoutDuplicateTitle => 'Có người đã nhận lương kỳ này';

  @override
  String get payoutDuplicateBody =>
      'Chuyển lại sẽ chi thêm một lần nữa cho những người này. Lựa chọn nào cũng được ghi vào nhật ký.';

  @override
  String payoutDuplicateRegion(String region, int count) {
    return '$region: $count người đã nhận';
  }

  @override
  String payoutDuplicatePerson(String employee, int count) {
    return '$employee · đã nhận $count lần';
  }

  @override
  String get payoutSkipPaid => 'Bỏ qua người đã nhận';

  @override
  String get payoutResend => 'Chuyển lại';

  @override
  String get payoutTabPeople => 'Nhân viên';

  @override
  String get payoutTabRuns => 'Các đợt';

  @override
  String get payoutTabLog => 'Nhật ký';

  @override
  String get payoutUnpaid => 'Chưa chuyển';

  @override
  String payoutPaidTimes(int count) {
    return 'Đã chuyển $count lần';
  }

  @override
  String get payoutNotCalculated =>
      'Kỳ này chưa chốt lương. Hãy chuyển cho cả công ty trước.';

  @override
  String get payoutResultTitle => 'Kết quả chuyển lương';

  @override
  String payoutResultSummary(int paid, int resent, int skipped) {
    return 'Chuyển $paid · chuyển lại $resent · bỏ qua $skipped';
  }

  @override
  String payoutResultFailed(int count) {
    return '$count khoản chưa chuyển được, hãy thử lại sau';
  }

  @override
  String payoutResultMissing(int count) {
    return '$count người chưa có phiếu lương kỳ này';
  }

  @override
  String get payoutStarted => 'Đã bắt đầu chốt kỳ và chuyển lương';

  @override
  String get payoutRetried => 'Đang chuyển nốt phần chưa chuyển';

  @override
  String get payoutBusy =>
      'Kỳ này đang chốt hoặc đang chuyển, chờ xong rồi thử lại';

  @override
  String get payoutUnreachable => 'Không kết nối được máy chủ công ty này';

  @override
  String get payoutNothing => 'Không có khoản nào phải chuyển';

  @override
  String get payoutAmountHidden => 'Số tiền chỉ xem được trong công ty đó';

  @override
  String get payoutLogPaid => 'Đã chuyển';

  @override
  String get payoutLogResent => 'Chuyển lại';

  @override
  String get payoutLogSkipped => 'Bỏ qua vì đã nhận';

  @override
  String get payoutLogWarned => 'Cảnh báo chuyển trùng';

  @override
  String get payoutLogFailed => 'Chuyển không được';

  @override
  String get payoutLogSaga => 'Chốt lương tự động';

  @override
  String payoutLogLine(String actor, String time) {
    return '$actor · $time';
  }

  @override
  String get noPayoutLog => 'Chưa có lần chuyển nào';

  @override
  String get errPayoutFailed =>
      'Chuyển lương bị gián đoạn. Khoản đã chuyển vẫn được ghi lại, hãy thử lại sau.';

  @override
  String payoutAccepted(int count) {
    return 'Đang chuyển $count khoản, xem tiến độ ở tab Nhật ký';
  }

  @override
  String get payoutLogInDoubt => 'Chưa rõ, cần đối soát';

  @override
  String get manualIpButton => 'Change Manual IP';

  @override
  String get manualIpTitle => 'Đổi IP thủ công';

  @override
  String get manualIpHint =>
      'Nhập IP công khai để giả lập đang ở nước đó: app dò khu vực lưu hồ sơ và ngôn ngữ theo IP này. Để trống để dùng IP thật.';

  @override
  String manualIpCurrent(String region) {
    return 'Khu vực đang nhận: $region';
  }

  @override
  String get manualIpInvalid => 'IP không hợp lệ';

  @override
  String manualIpSaved(String ip) {
    return 'Đang giả lập IP $ip';
  }

  @override
  String get manualIpCleared => 'Đã dùng lại IP thật';

  @override
  String get manualIpReset => 'Dùng IP thật';

  @override
  String moreNotifications(int count) {
    return 'và $count thông báo khác';
  }

  @override
  String get filterAll => 'Tất cả';

  @override
  String get filterStatus => 'Trạng thái';

  @override
  String get filterType => 'Loại';

  @override
  String get filterRead => 'Đã đọc';

  @override
  String get filterUnread => 'Chưa đọc';

  @override
  String get profileTab => 'Cá nhân';

  @override
  String get myProfile => 'Thông tin cá nhân';

  @override
  String get proposeChange => 'Đề xuất sửa thông tin';

  @override
  String get proposeChangeHint =>
      'Chỉ sửa ô cần đổi. HR duyệt xong thông tin mới được cập nhật.';

  @override
  String get changeReason => 'Lý do (không bắt buộc)';

  @override
  String get sendRequest => 'Gửi đề xuất';

  @override
  String get changeRequestSent => 'Đã gửi đề xuất, chờ HR duyệt';

  @override
  String get changeRequestPending => 'Bạn đang có một đề xuất chờ HR duyệt';

  @override
  String get changeRequestNoChange => 'Bạn chưa sửa ô nào';

  @override
  String get changeHistory => 'Lịch sử đề xuất';

  @override
  String get changeRequests => 'Đề xuất sửa hồ sơ';

  @override
  String get changeRequestsHint => 'Nhân viên đề xuất sửa thông tin cá nhân';

  @override
  String pendingChangeRequests(int count) {
    return '$count đề xuất sửa hồ sơ';
  }

  @override
  String get noChangeRequests => 'Không có đề xuất nào';

  @override
  String get oldValue => 'Cũ';

  @override
  String get newValue => 'Mới';

  @override
  String get decisionNote => 'Ghi chú cho nhân viên (không bắt buộc)';

  @override
  String get fieldFacebook => 'Facebook';

  @override
  String get fieldXHandle => 'Tài khoản X';

  @override
  String get accountInfo => 'Tài khoản';

  @override
  String nProfileChangeRequested(String employee) {
    return '$employee đề xuất sửa thông tin cá nhân';
  }

  @override
  String get nProfileChangeApproved =>
      'HR đã duyệt đề xuất sửa thông tin của bạn';

  @override
  String nProfileChangeRejected(String note) {
    return 'HR từ chối đề xuất sửa thông tin: $note';
  }

  @override
  String get invalidAmount => 'Giá trị không hợp lệ';

  @override
  String get invalidEmail => 'Email không hợp lệ';

  @override
  String todoProfileChanges(int count) {
    return '$count đề xuất sửa hồ sơ';
  }

  @override
  String get departments => 'Phòng ban';

  @override
  String get departmentsHint => 'Điều chuyển, trưởng phòng, giải thể';

  @override
  String get departmentAdd => 'Thêm phòng ban';

  @override
  String get departmentName => 'Tên phòng ban';

  @override
  String get departmentNameTaken => 'Công ty này đã có phòng ban cùng tên';

  @override
  String departmentCreated(String name) {
    return 'Đã thêm phòng $name';
  }

  @override
  String get departmentEmpty => 'Phòng ban chưa có ai';

  @override
  String get departmentHead => 'Trưởng phòng';

  @override
  String departmentHeadIs(String name) {
    return 'Trưởng phòng: $name';
  }

  @override
  String departmentMembers(int count) {
    return '$count người';
  }

  @override
  String get noHead => 'Chưa có trưởng phòng';

  @override
  String get noDepartments => 'Chưa có phòng ban nào';

  @override
  String get sortedByHours =>
      'Trưởng phòng đứng đầu, còn lại theo tổng giờ làm';

  @override
  String get setHead => 'Giao làm trưởng phòng';

  @override
  String headAssigned(String name) {
    return '$name đã làm trưởng phòng';
  }

  @override
  String get moveToDepartment => 'Điều chuyển sang phòng khác';

  @override
  String get moveHere => 'Chuyển vào phòng';

  @override
  String transferDone(String name) {
    return 'Đã chuyển sang $name';
  }

  @override
  String get addMembers => 'Thêm người vào phòng';

  @override
  String get addMembersFrom => 'Lấy người từ phòng nào?';

  @override
  String addMembersTitle(String name) {
    return 'Chuyển vào $name';
  }

  @override
  String membersMoved(int count) {
    return 'Đã chuyển $count người';
  }

  @override
  String membersMovedPartly(int moved, int failed) {
    return 'Đã chuyển $moved người, $failed người không chuyển được';
  }

  @override
  String get dissolveDepartment => 'Giải thể phòng ban';

  @override
  String dissolveTitle(String name) {
    return 'Giải thể $name?';
  }

  @override
  String get dissolveReason => 'Lý do giải thể';

  @override
  String get dissolveNoLongerNeeded => 'Không còn nhu cầu';

  @override
  String get dissolveRestructured => 'Cơ cấu lại hoặc sáp nhập';

  @override
  String get dissolveUnderperforming => 'Hoạt động kém hiệu quả';

  @override
  String get dissolveOutsourced => 'Chuyển sang thuê ngoài';

  @override
  String get dissolveBusinessClosed => 'Thu hẹp hoặc đóng cửa mảng kinh doanh';

  @override
  String dissolveMembersMove(int count) {
    return 'Phòng còn $count người, chọn phòng nhận lại họ';
  }

  @override
  String get chooseReceivingDepartment => 'Chọn phòng nhận';

  @override
  String get dissolveConfirm => 'Giải thể';

  @override
  String dissolveDone(String name) {
    return 'Đã giải thể $name';
  }

  @override
  String get unassignedStaff => 'Người mới chưa có phòng';

  @override
  String unassignedCount(int count) {
    return '$count người mới chưa có phòng ban';
  }

  @override
  String get unassignedHint => 'Để AI gợi ý xếp phòng hoặc lập phòng mới';

  @override
  String get noUnassigned => 'Ai cũng đã có phòng ban';

  @override
  String get aiSuggestPlacement => 'AI gợi ý xếp phòng';

  @override
  String get aiThinking => 'AI đang xem xét...';

  @override
  String get suggestionByAi => 'Gợi ý do AI đưa ra, HR quyết định cuối cùng';

  @override
  String get suggestionByRules =>
      'AI đang bận, gợi ý theo chức vụ trùng nhiều nhất';

  @override
  String suggestedDepartment(String name) {
    return 'Gợi ý: $name';
  }

  @override
  String get acceptSuggestion => 'Đồng ý';

  @override
  String get chooseOther => 'Chọn phòng khác';

  @override
  String get chooseDepartment => 'Chọn phòng ban';

  @override
  String get newDepartmentProposals => 'Đề xuất lập phòng mới';

  @override
  String get createDepartmentAndMove => 'Lập phòng và chuyển người';

  @override
  String get rankings => 'Nhân viên xuất sắc';

  @override
  String get rankingsHint => 'Xếp hạng theo giờ làm, đề cử thăng chức';

  @override
  String get rankingFormula =>
      'Điểm = giờ thường + 1,5 × giờ tăng ca + 2 × số ngày công';

  @override
  String rankingDetail(String work, String overtime, int days) {
    return '$work giờ · $overtime giờ tăng ca · $days ngày';
  }

  @override
  String get points => 'điểm';

  @override
  String get noRankings => 'Chưa có dữ liệu chấm công trong khoảng này';

  @override
  String lastMonths(int count) {
    return '$count tháng gần nhất';
  }

  @override
  String get filterPeriod => 'Khoảng thời gian';

  @override
  String get filterDepartment => 'Phòng ban';

  @override
  String get filterPosition => 'Chức vụ';

  @override
  String get filterCompany => 'Công ty';

  @override
  String get filterRegion => 'Khu vực';

  @override
  String get statusWorking => 'Đang làm';

  @override
  String get statusArchived => 'Đã bảo lưu';

  @override
  String get viewProfile => 'Xem hồ sơ';

  @override
  String get nominatePromotion => 'Đề cử thăng chức';

  @override
  String nominateTitle(String name) {
    return 'Đề cử $name';
  }

  @override
  String get proposedPosition => 'Chức vụ đề xuất';

  @override
  String get raisePercent => 'Mức tăng lương';

  @override
  String get raisePercentInvalid => 'Nhập từ 0,1 đến 100';

  @override
  String get nominationReason => 'Lý do đề cử';

  @override
  String get sendToExecutives => 'Gửi Ban lãnh đạo';

  @override
  String get nominationSent => 'Đã gửi đề cử lên Ban lãnh đạo';

  @override
  String get nominations => 'Đề cử thăng chức';

  @override
  String get nominationsHint => 'Ban lãnh đạo duyệt, tăng chức và lương';

  @override
  String get noNominations => 'Không có đề cử nào';

  @override
  String raiseBy(String percent) {
    return 'Tăng lương $percent%';
  }

  @override
  String get approvePromotion => 'Duyệt thăng chức';

  @override
  String approvePromotionHint(String name, String position, String percent) {
    return '$name sẽ lên $position và được tăng $percent% lương cơ bản.';
  }

  @override
  String get promotionApproved => 'Đã duyệt: đổi chức vụ và tăng lương';

  @override
  String get promotionApprovedNoRaise =>
      'Đã đổi chức vụ, tăng lương chưa xong, thử lại ở Lương';

  @override
  String get promotionRejected => 'Đã từ chối đề cử';

  @override
  String todoNominations(int count) {
    return '$count đề cử thăng chức chờ duyệt';
  }

  @override
  String get archiveProfile => 'Bảo lưu hồ sơ';

  @override
  String archiveTitle(String name) {
    return 'Bảo lưu hồ sơ $name?';
  }

  @override
  String archiveProjectsWarning(int count) {
    return 'Người này đang ở $count dự án. Bảo lưu sẽ rút khỏi tất cả:';
  }

  @override
  String get archiveNoProjects => 'Người này không ở dự án nào.';

  @override
  String get archiveKeepsPersonal =>
      'Thông tin cá nhân vẫn được giữ, có thể khôi phục sau.';

  @override
  String get archiveReason => 'Lý do bảo lưu';

  @override
  String get archiveConfirm => 'Bảo lưu';

  @override
  String archiveDone(int count) {
    return 'Đã bảo lưu, rút khỏi $count dự án';
  }

  @override
  String profileArchivedBanner(String reason) {
    return 'Hồ sơ đang bảo lưu. Lý do: $reason';
  }

  @override
  String get restoreProfile => 'Khôi phục';

  @override
  String get restoreDone => 'Đã khôi phục hồ sơ';

  @override
  String get fieldRequired => 'Không được để trống';

  @override
  String get errIsHead =>
      'Trưởng phòng phải giao lại cho người khác trước khi chuyển đi';

  @override
  String get errLastMember => 'Phòng ban phải còn ít nhất một người';

  @override
  String get errSameDepartment => 'Nhân viên đã ở phòng này rồi';

  @override
  String get errArchived => 'Hồ sơ đang bảo lưu, khôi phục trước đã';

  @override
  String get errNotArchived => 'Hồ sơ này không bảo lưu';

  @override
  String get errMembersRemaining => 'Phòng còn người, chọn phòng nhận lại họ';

  @override
  String get errNotMember => 'Người này không thuộc phòng ban';

  @override
  String get errPendingExists => 'Đã có một yêu cầu đang chờ duyệt';

  @override
  String get errServiceUnavailable =>
      'Một phần hệ thống đang bận, thử lại sau ít phút';

  @override
  String nPromotionNominated(String employee, String position) {
    return '$employee được đề cử lên $position, chờ duyệt';
  }

  @override
  String nPromotionApproved(String position) {
    return 'Chúc mừng! Bạn được thăng chức lên $position';
  }

  @override
  String nPromotionRejected(String position) {
    return 'Đề cử lên $position chưa được duyệt';
  }

  @override
  String nPromotionApprovedHr(String employee) {
    return 'Ban lãnh đạo đã duyệt thăng chức cho $employee';
  }

  @override
  String nPromotionRejectedHr(String employee) {
    return 'Ban lãnh đạo không duyệt thăng chức cho $employee';
  }

  @override
  String get nEmployeeTransferred =>
      'Bạn đã được điều chuyển sang phòng ban mới';

  @override
  String get nDepartmentHeadAssigned => 'Bạn được giao làm trưởng phòng';

  @override
  String memberHours(String hours) {
    return '$hours giờ';
  }

  @override
  String get stageInterviewed => 'Đã phỏng vấn';

  @override
  String get interviewAwaitingCandidate => 'Chờ ứng viên xác nhận';

  @override
  String get interviewAwaitingHr => 'Chờ HR xác nhận lại';

  @override
  String get interviewConfirmed => 'Đã xác nhận';

  @override
  String get interviewCancelled => 'Đã hủy';

  @override
  String get interviewSchedule => 'Lịch phỏng vấn';

  @override
  String minutesAttached(String name) {
    return 'Biên bản: $name';
  }

  @override
  String get chooseInterviewTime => 'Chọn ngày giờ';

  @override
  String get errTimeInPast => 'Giờ phỏng vấn phải sau thời điểm hiện tại';

  @override
  String get interviewLocation => 'Địa điểm hoặc link họp';

  @override
  String get send => 'Gửi';

  @override
  String get rejectCandidate => 'Từ chối';

  @override
  String rejectCandidateHint(String name) {
    return 'Từ chối hồ sơ $name? Sau này vẫn xem xét lại được.';
  }

  @override
  String get scheduleInterview => 'Hẹn phỏng vấn';

  @override
  String get scheduleAgain => 'Hẹn lại phỏng vấn';

  @override
  String get interviewSent => 'Đã gửi lịch, đang chờ bên kia xác nhận';

  @override
  String get proposeOtherTime => 'Đề xuất giờ khác';

  @override
  String get confirmTime => 'Xác nhận giờ này';

  @override
  String get interviewConfirmedDone => 'Đã xác nhận lịch phỏng vấn';

  @override
  String get uploadMinutes => 'Tải biên bản phỏng vấn';

  @override
  String get minutesUploaded =>
      'Đã lưu biên bản, hồ sơ chuyển sang đã phỏng vấn';

  @override
  String get minutesAfterInterview =>
      'Qua giờ phỏng vấn mới tải được biên bản (Word, Excel)';

  @override
  String get openMinutes => 'Mở biên bản';

  @override
  String get moveToScreening => 'Chuyển sang sàng lọc';

  @override
  String get reconsider => 'Xem xét lại';

  @override
  String get reconsidered => 'Hồ sơ đã quay về bước trước lúc từ chối';

  @override
  String get waitingCandidateReply =>
      'Đang chờ ứng viên xác nhận hoặc đề xuất giờ khác';

  @override
  String get waitingHrReply => 'Đang chờ HR xác nhận giờ bạn đề xuất';

  @override
  String get hiredSalaryPending =>
      'Chưa lưu được lương thỏa thuận, cần nhập lại ở màn Lương';

  @override
  String get offerFromAi => 'AI gợi ý';

  @override
  String get offerFromRules => 'Gợi ý theo dữ liệu';

  @override
  String get offerPeerMedian =>
      'Lương ở giữa của những người cùng chức vụ, phòng có nhiều người cùng chức vụ nhất';

  @override
  String get offerRegionMedian =>
      'Chưa có ai cùng chức vụ: lương ở giữa của khu vực, phòng đông người nhất';

  @override
  String get agreedSalary => 'Lương cơ bản thỏa thuận';

  @override
  String get currency => 'Tiền tệ';

  @override
  String get errInvalidStep =>
      'Hồ sơ không thể chuyển như vậy ở bước hiện tại, tải lại để xem bước mới nhất';

  @override
  String get errNotScreened => 'Cần sàng lọc hồ sơ trước khi hẹn phỏng vấn';

  @override
  String get errInterviewNotConfirmed => 'Lịch phỏng vấn chưa được xác nhận';

  @override
  String get errNotInterviewed =>
      'Cần tải biên bản phỏng vấn trước khi nhận việc';

  @override
  String get errNotRejected => 'Hồ sơ này chưa bị từ chối';

  @override
  String get errInvalidOffer =>
      'Lương thỏa thuận phải lớn hơn 0 và có mã tiền tệ';

  @override
  String get errMinutesFile => 'Biên bản phải là tệp Word hoặc Excel';

  @override
  String nInterviewScheduled(String position, String time) {
    return 'Lịch phỏng vấn $position lúc $time, mở để xác nhận';
  }

  @override
  String nInterviewConfirmed(String time) {
    return 'Lịch phỏng vấn lúc $time đã được xác nhận';
  }

  @override
  String nInterviewConfirmedHr(String position, String time) {
    return 'Ứng viên $position đã chốt lịch phỏng vấn lúc $time';
  }

  @override
  String nInterviewProposed(String position, String time) {
    return 'Ứng viên $position đề xuất phỏng vấn lúc $time';
  }

  @override
  String get projectTier => 'Phân cấp';

  @override
  String get tierSmall => 'Cấp 1 · Nhỏ';

  @override
  String get tierMedium => 'Cấp 2 · Vừa';

  @override
  String get tierLarge => 'Cấp 3 · Lớn';

  @override
  String get tierStrategic => 'Cấp 4 · Trọng điểm';

  @override
  String tierRule(int months, int members) {
    return 'Tối đa $months tháng, ít nhất $members người';
  }

  @override
  String get warnRed => 'Còn ≤ 1 tháng';

  @override
  String get warnOrange => 'Còn ≤ 6 tháng';

  @override
  String get warnYellow => 'Còn ≤ 12 tháng';

  @override
  String get warnNotStarted => 'Chưa bắt đầu';

  @override
  String get warnAccepted => 'Đã nghiệm thu';

  @override
  String get warnNormal => 'Còn hơn 12 tháng';

  @override
  String get projectCharts => 'Biểu đồ dự án';

  @override
  String get chart2d => '2D';

  @override
  String get chart3d => '3D';

  @override
  String get chartTimeline => 'Thời gian';

  @override
  String get chartProgress => 'Tiến độ';

  @override
  String get chartMembers => 'Số người';

  @override
  String get chartValue => 'Giá trị';

  @override
  String get thousandUsd => 'nghìn USD';

  @override
  String get projectProposals => 'Đề xuất dự án';

  @override
  String get projectNew => 'Tạo dự án';

  @override
  String get wizardFiles => 'Hợp đồng và ảnh';

  @override
  String get wizardFilesHint =>
      'Tải hợp đồng theo mẫu (PDF hoặc Word), AI sẽ đọc và điền sẵn thông tin; không có hợp đồng thì nhập tay ở bước sau.';

  @override
  String get wizardInfo => 'Thông tin dự án';

  @override
  String get wizardMembers => 'Nhân viên tham gia';

  @override
  String get wizardSend => 'Gửi Ban lãnh đạo';

  @override
  String get downloadContractTemplate => 'Tải mẫu hợp đồng';

  @override
  String get uploadContract => 'Tải hợp đồng lên';

  @override
  String get uploadProjectImage => 'Tải ảnh công trình';

  @override
  String get contractReadByAi =>
      'AI đã đọc hợp đồng và điền sẵn, kiểm lại ở bước sau';

  @override
  String get contractReadManual =>
      'Chưa đọc được hợp đồng tự động, vui lòng nhập tay ở bước sau';

  @override
  String get projectName => 'Tên dự án';

  @override
  String get customerName => 'Khách hàng';

  @override
  String get customerCompany => 'Doanh nghiệp';

  @override
  String get customerIndividual => 'Cá nhân';

  @override
  String get customerContact => 'Liên hệ khách hàng (email hoặc điện thoại)';

  @override
  String get contractType => 'Loại hợp đồng';

  @override
  String get contractValue => 'Giá trị hợp đồng';

  @override
  String get depositAmount => 'Tạm ứng';

  @override
  String get startDate => 'Bắt đầu';

  @override
  String get endDate => 'Kết thúc';

  @override
  String get acceptanceDate => 'Nghiệm thu';

  @override
  String get propErrName => 'Cần tên dự án';

  @override
  String get propErrCustomer => 'Cần tên khách hàng';

  @override
  String get propErrValue => 'Giá trị hợp đồng phải lớn hơn 0';

  @override
  String get propErrDeposit =>
      'Tạm ứng không được âm hay lớn hơn giá trị hợp đồng';

  @override
  String get propErrDates => 'Cần ngày bắt đầu và ngày kết thúc';

  @override
  String get propErrStartPast => 'Ngày bắt đầu không được trước hôm nay';

  @override
  String get propErrEndBeforeStart => 'Ngày kết thúc phải sau ngày bắt đầu';

  @override
  String get propErrAcceptance =>
      'Nghiệm thu phải từ ngày kết thúc tới 90 ngày sau';

  @override
  String get propErrTooLong => 'Dự án cấp này làm quá thời gian tối đa';

  @override
  String get propErrFewMembers => 'Chưa đủ số người tối thiểu của cấp này';

  @override
  String membersNeeded(int min, int picked) {
    return 'Cần ít nhất $min người · đã chọn $picked';
  }

  @override
  String get suggestMembers => 'AI gợi ý nhân viên';

  @override
  String activeProjects(int count) {
    return '$count dự án đang làm';
  }

  @override
  String get next => 'Tiếp';

  @override
  String get back => 'Quay lại';

  @override
  String get sendToExecutive => 'Gửi duyệt';

  @override
  String get proposalSent => 'Đã gửi đề xuất, chờ Ban lãnh đạo duyệt';

  @override
  String get noProposals => 'Chưa có đề xuất dự án';

  @override
  String proposalVersion(int version) {
    return 'Bản $version';
  }

  @override
  String get propAwaitingExecutive => 'Chờ Ban lãnh đạo';

  @override
  String get propAwaitingProposer => 'Chờ bên lập xác nhận';

  @override
  String get propApproved => 'Đã duyệt';

  @override
  String get propRejected => 'Đã từ chối';

  @override
  String get proposalEdit => 'Sửa đề xuất';

  @override
  String get proposalNoteHint => 'Lý do hoặc điều cần sửa';

  @override
  String proposalApprovedDone(String id) {
    return 'Đã duyệt, dự án $id đã được tạo';
  }

  @override
  String get acceptEdits => 'Đồng ý bản sửa';

  @override
  String get withdrawProposal => 'Rút đề xuất';

  @override
  String get waitingOtherSide => 'Đang chờ bên kia trả lời';

  @override
  String get openContract => 'Mở hợp đồng';

  @override
  String get openImage => 'Mở ảnh';

  @override
  String get openProject => 'Mở dự án';

  @override
  String get propActSubmitted => 'Gửi đề xuất';

  @override
  String get propActCounter => 'Sửa lại đề xuất';

  @override
  String get propActApprove => 'Đồng ý';

  @override
  String get propActReject => 'Từ chối';

  @override
  String get propActWithdraw => 'Rút đề xuất';

  @override
  String todoProposals(int count) {
    return '$count đề xuất dự án chờ duyệt';
  }

  @override
  String nProjectProposed(String name) {
    return 'Đề xuất dự án mới cần duyệt: $name';
  }

  @override
  String nProjectCountered(String name) {
    return 'Ban lãnh đạo đã sửa đề xuất $name, cần bạn xác nhận';
  }

  @override
  String nProjectApproved(String name) {
    return 'Dự án $name đã được duyệt và tạo';
  }

  @override
  String nProjectRejected(String name) {
    return 'Đề xuất dự án $name bị từ chối';
  }

  @override
  String get workCalendar => 'Lịch làm việc';

  @override
  String get clockStats => 'Biểu đồ chấm công';

  @override
  String shiftHours(String start, String end) {
    return 'Ca $start–$end';
  }

  @override
  String get errShiftEnded =>
      'Đã qua giờ kết thúc ca nên không chấm vào được nữa';

  @override
  String get errTooManyFiles => 'Mỗi đơn chỉ đính kèm tối đa 5 tệp';

  @override
  String get errFileType =>
      'Loại tệp không được nhận, hãy chọn đúng loại tệp yêu cầu';

  @override
  String get addEvidence => 'Thêm minh chứng';

  @override
  String viewOriginalLeave(int count) {
    return 'Xem đơn gốc ($count)';
  }

  @override
  String get evidenceUploaded => 'Đã thêm minh chứng, AI đang tóm tắt cho HR';

  @override
  String get noEvidence => 'Chưa có minh chứng';

  @override
  String get aiLeaveSummary => 'AI tóm tắt minh chứng';

  @override
  String get evidenceMatches => 'Khớp lý do nghỉ';

  @override
  String get evidenceCheck => 'Cần xem kỹ';

  @override
  String get calWorked => 'Đã làm';

  @override
  String get calLeave => 'Nghỉ phép';

  @override
  String get calHoliday => 'Ngày lễ';

  @override
  String get calAbsent => 'Vắng không phép';

  @override
  String get calScheduled => 'Có ca';

  @override
  String calLeaveOfType(String type) {
    return 'Nghỉ: $type';
  }

  @override
  String get noShiftThisDay => 'Không có ca ngày này';

  @override
  String estimatedDayPay(String amount) {
    return 'Tiền ước tính hôm nay: $amount';
  }

  @override
  String estimatedMonthPay(String amount) {
    return 'Tiền ước tính theo giờ làm: $amount';
  }

  @override
  String get payEstimateHint =>
      'Tính theo lương cơ bản, 26 ngày công, tăng ca 150%; chưa trừ bảo hiểm, thuế';

  @override
  String get projectsThisDay => 'Dự án đang tham gia';

  @override
  String get statsScopeRegion => 'Cả khu vực';

  @override
  String get statsScopeMine => 'Của tôi';

  @override
  String get statsDays => 'Ngày đã chấm công';

  @override
  String get statsLate => 'Vào trễ';

  @override
  String get statsByWeekday => 'Theo thứ trong tuần';

  @override
  String get statsByHour => 'Giờ vào ca';

  @override
  String get statsByMonth => 'Ngày công và số lần trễ theo tháng';

  @override
  String get errPayrollTooEarly =>
      'Kỳ lương này chưa tới hạn: lương tháng M chốt từ ngày 10 tháng M+1';

  @override
  String get errAmountLowered =>
      'Mức đề xuất chỉ được giữ nguyên hoặc tăng, không được hạ';

  @override
  String get errNotHigher => 'Mức đề xuất phải cao hơn lương hiện tại';

  @override
  String get errNoSalary => 'Chưa có lương cơ bản trong hệ thống';

  @override
  String get errAwaitingAck =>
      'Báo cáo trước đang chờ cấp trên xác nhận, chưa gửi bản mới được';

  @override
  String get acknowledge => 'Xác nhận';

  @override
  String get byDay => 'Ngày';

  @override
  String get byMonth => 'Tháng';

  @override
  String get byYear => 'Năm';

  @override
  String get costs => 'Chi phí';

  @override
  String get export => 'Xuất tệp';

  @override
  String get exportExcel => 'Xuất Excel';

  @override
  String get exportPdf => 'Xuất PDF';

  @override
  String exportedAt(String time) {
    return 'Xuất lúc $time';
  }

  @override
  String get exportId => 'Mã';

  @override
  String get exportPeriod => 'Kỳ';

  @override
  String get exportRank => 'Hạng';

  @override
  String get exportMargin => 'Biên lãi';

  @override
  String get exportCurrency => 'Tiền tệ';

  @override
  String get exportRevenueUsd => 'Doanh thu (USD)';

  @override
  String get exportCostUsd => 'Chi phí (USD)';

  @override
  String exportFinanceTitle(int year) {
    return 'Thu chi năm $year';
  }

  @override
  String get financeAnalytics => 'Phân tích';

  @override
  String get materialCost => 'Chi vật liệu';

  @override
  String get payrollCost => 'Chi lương';

  @override
  String get materialsUsed => 'Vật liệu đã dùng';

  @override
  String get revenueByStage => 'Doanh thu theo đợt';

  @override
  String get projectProfitRanking => 'Xếp hạng dự án theo lợi nhuận';

  @override
  String get projectSalaryShares => 'Lương dự án chia cho từng người';

  @override
  String get overtimePay => 'Tăng ca';

  @override
  String get insuranceDeduction => 'Bảo hiểm';

  @override
  String get incomeTax => 'Thuế thu nhập';

  @override
  String get salaryGrowth => 'Lương qua các kỳ';

  @override
  String salaryGrowthRate(String rate, int count) {
    return 'Thực nhận $rate sau $count kỳ';
  }

  @override
  String payrollOpensOn(String period, String date) {
    return 'Kỳ $period mở chốt lương từ $date';
  }

  @override
  String get raiseRequests => 'Đề xuất tăng lương';

  @override
  String get raiseRequestsHint => 'Gửi, chuyển lên, duyệt tăng lương';

  @override
  String get newRaiseRequest => 'Đề xuất tăng lương';

  @override
  String get noRaiseRequests => 'Chưa có đề xuất tăng lương';

  @override
  String get proposedSalary => 'Lương cơ bản đề xuất';

  @override
  String raiseMinimum(String amount) {
    return 'Không thấp hơn $amount';
  }

  @override
  String get raiseReason => 'Lý do (thành tích, trách nhiệm mới...)';

  @override
  String get raiseActionTitle => 'Mức lương và ghi chú';

  @override
  String get raiseSent => 'Đã gửi đề xuất tăng lương';

  @override
  String get raiseForwarded => 'Đã chuyển lên cấp duyệt';

  @override
  String get raiseApprovedDone => 'Đã duyệt, lương cơ bản đã tăng';

  @override
  String get raiseForward => 'Chuyển lên duyệt';

  @override
  String get raiseReturn => 'Trả lại';

  @override
  String get raiseEdit => 'Sửa mức đề xuất';

  @override
  String get raiseAwaitingHr => 'Chờ HR xem';

  @override
  String get raiseAwaitingApprover => 'Chờ cấp trên duyệt';

  @override
  String get raiseAwaitingEmployee => 'Trả lại cho nhân viên';

  @override
  String get raiseWithdrawn => 'Đã rút';

  @override
  String raiseRequestedFirst(String amount) {
    return 'Ban đầu đề xuất $amount';
  }

  @override
  String get reportSubmissions => 'Báo cáo gửi cấp trên';

  @override
  String get reportSubmissionsHint =>
      'Báo cáo nhân sự, tài chính theo kỳ, chờ cấp trên xác nhận';

  @override
  String get reportHr => 'Nhân sự';

  @override
  String get reportFinance => 'Tài chính';

  @override
  String get noReports => 'Chưa gửi báo cáo nào';

  @override
  String get submitReport => 'Gửi báo cáo';

  @override
  String submitReportTitle(String period) {
    return 'Gửi báo cáo kỳ $period';
  }

  @override
  String get reportWaitingAck => 'Đang chờ xác nhận';

  @override
  String get reportSent => 'Đã gửi báo cáo lên cấp trên';

  @override
  String get reportAcknowledged => 'Đã xác nhận báo cáo';

  @override
  String get returnReport => 'Trả lại báo cáo';

  @override
  String get reportStatusSubmitted => 'Chờ xác nhận';

  @override
  String get reportStatusAcknowledged => 'Đã xác nhận';

  @override
  String get reportStatusReturned => 'Bị trả lại';

  @override
  String reportPeriod(String period) {
    return 'Báo cáo kỳ $period';
  }

  @override
  String reportHeadcount(int people, int departments) {
    return '$people nhân viên, $departments phòng ban';
  }

  @override
  String reportUnassigned(int count) {
    return '$count người chưa có phòng ban';
  }

  @override
  String reportNominations(int pending, int approved) {
    return 'Đề cử thăng chức: $pending chờ, $approved đã duyệt';
  }

  @override
  String get resignations => 'Xin thôi việc';

  @override
  String get resignationsHint => 'Gửi đơn nghỉ việc, theo dõi duyệt';

  @override
  String get newResignation => 'Gửi đơn';

  @override
  String get resignationLastDay => 'Ngày làm cuối';

  @override
  String resignationLastDayOn(String date) {
    return 'Ngày làm cuối: $date';
  }

  @override
  String get resignationReason => 'Lý do nghỉ việc';

  @override
  String resignationNotice(int days) {
    return 'Báo trước ít nhất $days ngày';
  }

  @override
  String get resignationSent => 'Đã gửi đơn thôi việc cho HR';

  @override
  String get noResignations => 'Chưa có đơn thôi việc nào';

  @override
  String get resignationPending => 'Chờ HR duyệt';

  @override
  String get resignationApproved => 'Đã duyệt, chờ ngày nghỉ';

  @override
  String get resignationCompleted => 'Đã nghỉ việc';

  @override
  String get resignationWithdrawn => 'Đã rút đơn';

  @override
  String get resignationWithdraw => 'Rút đơn';

  @override
  String get resignationComplete => 'Hoàn tất nghỉ việc';

  @override
  String resignationCompleteConfirm(String name) {
    return 'Hồ sơ $name sẽ được bảo lưu và rút khỏi mọi dự án. Tiếp tục?';
  }

  @override
  String get resignationCompletedDone =>
      'Đã hoàn tất nghỉ việc, hồ sơ chuyển vào lưu trữ';

  @override
  String get errNoticeTooShort =>
      'Ngày làm cuối phải cách hôm nay ít nhất 30 ngày';

  @override
  String get errBeforeLastDay => 'Chưa tới ngày làm cuối, chưa hoàn tất được';

  @override
  String get exportCsv => 'Xuất CSV';

  @override
  String get exportJson => 'Xuất JSON';

  @override
  String get auditCharts => 'Biểu đồ';

  @override
  String get auditFilter => 'Lọc chi tiết';

  @override
  String get auditService => 'Dịch vụ';

  @override
  String get auditEventType => 'Loại sự kiện';

  @override
  String get auditTime => 'Thời điểm';

  @override
  String get auditFromTime => 'Từ lúc';

  @override
  String get auditToTime => 'Đến lúc';

  @override
  String get anyTime => 'Bất kỳ';

  @override
  String get anomalyAny => 'Bất thường';

  @override
  String get anomalyAfterHours => 'Ngoài giờ (22h–6h)';

  @override
  String get anomalyFailure => 'Thất bại, từ chối';

  @override
  String get auditTotal => 'Tổng sự kiện';

  @override
  String get auditByRegion => 'Theo khu vực';

  @override
  String get auditByHour => 'Theo giờ địa phương (đỏ là ngoài giờ)';

  @override
  String get auditByDay => 'Theo ngày';

  @override
  String get auditByType => 'Loại sự kiện nhiều nhất';

  @override
  String get auditByService => 'Theo dịch vụ';

  @override
  String get clearFilters => 'Xóa bộ lọc';

  @override
  String get auditSignedExport => 'Xuất CSV có mã SHA-256';

  @override
  String get approvalInbox => 'Hộp duyệt chung';

  @override
  String get approvalInboxHint =>
      'Dự án, thăng chức, tăng lương chờ duyệt ở 6 khu vực';

  @override
  String get approvalKindProject => 'Dự án';

  @override
  String get approvalKindPromotion => 'Thăng chức';

  @override
  String get approvalKindRaise => 'Tăng lương';

  @override
  String get noApprovals => 'Không còn đề xuất nào chờ duyệt';

  @override
  String approvalWaiting(int count) {
    return '$count đề xuất chờ duyệt';
  }

  @override
  String approvalRegionsDown(String regions) {
    return 'Chưa lấy được dữ liệu của: $regions';
  }

  @override
  String get approvalByRegion => 'Chờ duyệt theo khu vực';

  @override
  String approvalPromotionLine(String position, String percent) {
    return 'Lên $position, tăng $percent% lương';
  }

  @override
  String get approvalDone => 'Đã ghi quyết định';

  @override
  String approvalConfirm(String title) {
    return 'Duyệt $title?';
  }

  @override
  String approvalRejectConfirm(String title) {
    return 'Từ chối $title?';
  }

  @override
  String get approvalColKind => 'Loại';

  @override
  String get approvalColTitle => 'Nội dung';

  @override
  String get approvalColDetail => 'Chi tiết';

  @override
  String get approvalColUpdated => 'Cập nhật';

  @override
  String get jobPositions => 'Vị trí tuyển dụng';

  @override
  String get jobPositionsHint =>
      'Mở vị trí, số người cần tuyển, xem ứng viên theo điểm AI';

  @override
  String get newJobPosition => 'Mở vị trí';

  @override
  String get editJobPosition => 'Sửa vị trí';

  @override
  String get noJobPositions => 'Chưa mở vị trí tuyển dụng nào';

  @override
  String get positionTitle => 'Tên vị trí';

  @override
  String get positionDepartment => 'Phòng ban';

  @override
  String get positionHeadcount => 'Số người cần tuyển';

  @override
  String get positionDescription => 'Mô tả công việc';

  @override
  String get positionRequirements => 'Yêu cầu';

  @override
  String get positionRequirementsHint =>
      'AI dựa vào phần này để chấm mức phù hợp của CV';

  @override
  String get positionOpen => 'Đang tuyển';

  @override
  String get positionFilled => 'Đã đủ người';

  @override
  String get positionClosed => 'Đã đóng';

  @override
  String get closePosition => 'Đóng vị trí';

  @override
  String get reopenPosition => 'Mở lại';

  @override
  String get positionSaved => 'Đã lưu vị trí tuyển dụng';

  @override
  String get positionApplicants => 'Ứng viên (điểm AI cao trước)';

  @override
  String positionProgress(int hired, int headcount, int applicants) {
    return 'Đã tuyển $hired/$headcount · $applicants ứng viên';
  }

  @override
  String positionSlotsLeft(int count) {
    return 'Còn $count chỗ';
  }

  @override
  String get choosePositions => 'Chọn vị trí ứng tuyển';

  @override
  String get choosePositionsHint => 'Bấm để chọn';

  @override
  String choosePositionsHelper(int max) {
    return 'Chọn một hoặc nhiều vị trí, tối đa $max';
  }

  @override
  String positionsChosen(int count) {
    return 'Xong ($count vị trí)';
  }

  @override
  String get positionMatchTitle => 'Mức phù hợp với vị trí (AI)';

  @override
  String get positionMatchPending => 'AI đang so khớp';

  @override
  String get positionMatchNone => 'Chưa so khớp';

  @override
  String get positionMatchStrengths => 'Đáp ứng';

  @override
  String get positionMatchGaps => 'Còn thiếu';

  @override
  String bestMatch(int score) {
    return 'Phù hợp $score%';
  }

  @override
  String get errNoPosition => 'Chọn ít nhất một vị trí ứng tuyển';

  @override
  String get errTooManyPositions => 'Chỉ chọn tối đa 5 vị trí';

  @override
  String get errPositionUnavailable =>
      'Vị trí này đã đóng hoặc đã đủ người, chọn vị trí khác';

  @override
  String get errPositionTitleExists => 'Đã có vị trí đang tuyển cùng tên';

  @override
  String get errInvalidHeadcount => 'Số người cần tuyển từ 1 đến 500';

  @override
  String errHeadcountBelowHired(int hired) {
    return 'Đã tuyển $hired người, không thể đặt thấp hơn';
  }

  @override
  String get errInvalidPosition => 'Nhập tên vị trí và số người cần tuyển';

  @override
  String nRaiseRequested(String employee) {
    return '$employee gửi đề xuất tăng lương';
  }

  @override
  String nRaiseForwarded(String employee) {
    return 'HR chuyển đề xuất tăng lương của $employee, cần bạn duyệt';
  }

  @override
  String get nRaiseApproved => 'Đề xuất tăng lương của bạn đã được duyệt';

  @override
  String get nRaiseRejected => 'Đề xuất tăng lương của bạn bị từ chối';

  @override
  String get nRaiseReturned =>
      'Đề xuất tăng lương được trả lại, mời bạn xem và sửa';

  @override
  String nReportSubmitted(String report, String period) {
    return 'Có báo cáo $report kỳ $period gửi lên cần xác nhận';
  }

  @override
  String nReportAcknowledged(String report, String period) {
    return 'Báo cáo $report kỳ $period đã được xác nhận';
  }

  @override
  String nReportReturned(String report, String period) {
    return 'Báo cáo $report kỳ $period bị trả lại, xem ghi chú';
  }

  @override
  String nResignationRequested(String employee, String date) {
    return '$employee xin thôi việc, ngày làm cuối $date';
  }

  @override
  String nResignationApproved(String date) {
    return 'Đơn thôi việc của bạn đã được duyệt, ngày làm cuối $date';
  }

  @override
  String get nResignationRejected => 'Đơn thôi việc của bạn không được duyệt';

  @override
  String nResignationWithdrawn(String employee) {
    return '$employee đã rút đơn thôi việc';
  }

  @override
  String get reportKindHr => 'nhân sự';

  @override
  String get reportKindFinance => 'tài chính';

  @override
  String get openFullPage => 'Mở màn đầy đủ';

  @override
  String get requestAlreadyHandled => 'Đơn này đã được xử lý';

  @override
  String get requestFrom => 'Người gửi';

  @override
  String get waitingSuperior => 'Chờ cấp trên duyệt';

  @override
  String get signupTitle => 'Đăng ký tài khoản ứng viên';

  @override
  String get signupHint =>
      'Nhập thông tin thật của bạn. Mã xác nhận 6 số sẽ gửi về email này.';

  @override
  String get sendCode => 'Gửi mã xác nhận';

  @override
  String codeSentTo(String email) {
    return 'Đã gửi mã tới $email, kiểm tra cả thư mục Spam';
  }

  @override
  String get verificationCode => 'Mã xác nhận (6 số)';

  @override
  String get newPassword => 'Mật khẩu';

  @override
  String get passwordRule => 'Ít nhất 8 ký tự, có cả chữ và số';

  @override
  String get confirmPassword => 'Nhập lại mật khẩu';

  @override
  String get createAccount => 'Xác nhận và tạo tài khoản';

  @override
  String get resendCode => 'Gửi lại mã';

  @override
  String resendIn(int seconds) {
    return 'Gửi lại mã sau $seconds giây';
  }

  @override
  String get editDetails => 'Sửa họ tên, email, số điện thoại';

  @override
  String get signupDone => 'Đã tạo tài khoản, mời bạn đăng nhập';

  @override
  String get changePassword => 'Đổi mật khẩu';

  @override
  String get passwordChanged => 'Đã đổi mật khẩu';

  @override
  String get profileViewed => 'Hồ sơ của bạn đã được xem';

  @override
  String get profileViewedHint =>
      'HR đã mở xem hồ sơ nên bạn không sửa thông tin, đổi CV được nữa';

  @override
  String get cvRequired => 'Đính kèm CV (PDF) để lưu hồ sơ';

  @override
  String get accountDetails => 'Thông tin từ tài khoản đăng ký';

  @override
  String get errInvalidEmail => 'Email không hợp lệ';

  @override
  String get errInvalidName => 'Họ tên từ 2 đến 80 ký tự';

  @override
  String get errInvalidPhone => 'Số điện thoại không hợp lệ';

  @override
  String get errWeakPassword => 'Mật khẩu cần ít nhất 8 ký tự, có cả chữ và số';

  @override
  String get errEmailTaken => 'Email này đã có tài khoản, hãy đăng nhập';

  @override
  String get errCodeTooSoon => 'Vừa gửi mã, chờ 60 giây rồi gửi lại';

  @override
  String get errCodeExpired =>
      'Mã đã hết hạn hoặc nhập sai quá nhiều lần, hãy gửi lại mã';

  @override
  String get errWrongCode => 'Mã xác nhận không đúng';

  @override
  String get errSignupUnavailable =>
      'Chưa gửi được email lúc này, thử lại sau ít phút';

  @override
  String get projectTime => 'Thời gian';

  @override
  String get me => 'Tôi';

  @override
  String myProjectPay(String amount) {
    return 'Tiền dự án của tôi: $amount';
  }

  @override
  String get mySchedule => 'Lịch làm việc của tôi';

  @override
  String myScheduleHint(int days) {
    return 'Tháng này đã đi làm $days buổi trong thời gian dự án';
  }

  @override
  String myScheduleEarned(String amount) {
    return 'Tiền ước tính theo các buổi đi làm: $amount';
  }

  @override
  String get notCheckedIn => 'Chưa chấm công';

  @override
  String get contractRequired =>
      'Bắt buộc tải hợp đồng (PDF, Word) để AI đọc ra thông tin dự án';

  @override
  String get attachedBonuses => 'Thưởng phạt 12 tháng qua (gửi kèm đề xuất)';

  @override
  String bonusNet(String amount) {
    return 'Cộng dồn: $amount';
  }

  @override
  String moreItems(int count) {
    return 'và $count khoản khác';
  }

  @override
  String get orgTree => 'Sơ đồ tổ chức';

  @override
  String get orgTreeSearch => 'Tìm người, chức vụ (gõ không dấu cũng được)';

  @override
  String orgTreeSummary(int departments, int people) {
    return '$departments phòng ban · $people người';
  }

  @override
  String get orgTreeToggle => 'Thu gọn hoặc mở tất cả';

  @override
  String get level1 => 'Nhân viên';

  @override
  String get level2 => 'Chuyên viên, kỹ sư';

  @override
  String get level3 => 'Chỉ huy, phó phòng';

  @override
  String get level4 => 'Trưởng phòng, quản lý';

  @override
  String get level5 => 'Giám đốc khối';

  @override
  String get level6 => 'Ban lãnh đạo';

  @override
  String get noHigherPosition =>
      'Người này đã ở cấp cao nhất trong cây chức vụ';

  @override
  String get errNotHigherPosition =>
      'Chỉ đề cử lên chức vụ cấp cao hơn hiện tại';

  @override
  String get errUnknownPosition => 'Chọn chức vụ trong danh sách';

  @override
  String overtimeApprovedToday(String hours, String until) {
    return 'Tăng ca đã duyệt $hours giờ: làm tới $until vẫn được tính';
  }

  @override
  String overtimePendingToday(String hours) {
    return 'Đơn tăng ca $hours giờ đang chờ duyệt: chưa được tính cho tới khi duyệt';
  }

  @override
  String get overtimeNoneToday =>
      'Chưa có đơn tăng ca được duyệt: làm quá giờ ca sẽ không được tính';

  @override
  String get viewZoomIn => 'Phóng to';

  @override
  String get viewZoomOut => 'Thu nhỏ';

  @override
  String get viewFromTop => 'Nhìn từ trên xuống';

  @override
  String get viewFromBottom => 'Nhìn từ dưới lên';

  @override
  String get viewRotateLeft => 'Xoay trái';

  @override
  String get viewRotateRight => 'Xoay phải';

  @override
  String get viewReset => 'Về góc nhìn ban đầu';

  @override
  String get sectionGroup => 'Tập đoàn';

  @override
  String get sectionAdmin => 'Quản trị';

  @override
  String get roleGroup => 'Cấp tập đoàn';

  @override
  String get groupOverview => 'Tổng quan tập đoàn';

  @override
  String get groupOverviewHint =>
      'Số liệu từng nước, bấm vào một nước để xem chi tiết';

  @override
  String get adminConsole => 'Quản trị dữ liệu';

  @override
  String get adminConsoleHint =>
      'Tài khoản, lịch làm việc, chức vụ, thống kê, sao lưu, SQL';

  @override
  String viewingRegion(String region) {
    return 'Đang xem: $region';
  }

  @override
  String get chooseRegion => 'Chọn khu vực cần xem';

  @override
  String get approvalKindLeave => 'Đơn nghỉ';

  @override
  String get approvalKindOvertime => 'Tăng ca';

  @override
  String get approvalKindProfile => 'Sửa hồ sơ';

  @override
  String get approvalKindResignation => 'Thôi việc';

  @override
  String get groupTotals => 'Toàn tập đoàn';

  @override
  String get groupEmployees => 'Nhân viên';

  @override
  String get groupRevenueYtd => 'Doanh thu năm nay (USD)';

  @override
  String get groupCostYtd => 'Chi phí năm nay (USD)';

  @override
  String get groupRegionDown =>
      'Chưa lấy được số liệu của nước này, kéo xuống để thử lại';

  @override
  String get execActions => 'Làm thẳng';

  @override
  String get execChangePosition => 'Thăng chức, đổi chức vụ';

  @override
  String get execPromote => 'Thăng chức';

  @override
  String get execChangeOnly => 'Đổi chức vụ';

  @override
  String get execNewPosition => 'Chức vụ mới';

  @override
  String get execNoHigherPosition => 'Không còn chức vụ cấp cao hơn để thăng';

  @override
  String get execReason => 'Lý do (ghi vào sổ kiểm toán)';

  @override
  String get execReasonRequired => 'Lý do (bắt buộc)';

  @override
  String get execSalary => 'Đổi lương cơ bản';

  @override
  String execCurrentSalary(String amount) {
    return 'Lương cơ bản hiện tại: $amount';
  }

  @override
  String get execNewSalary => 'Lương cơ bản mới';

  @override
  String get execBonus => 'Thưởng, phạt';

  @override
  String get execBonusKind => 'Thưởng';

  @override
  String get execPenaltyKind => 'Phạt';

  @override
  String get execAmount => 'Số tiền (theo tiền lương của nhân viên)';

  @override
  String get execApply => 'Áp dụng ngay';

  @override
  String get execAuditNote =>
      'Có hiệu lực ngay, không qua ai duyệt; ghi vào sổ kiểm toán kèm tên người thực hiện.';

  @override
  String get execApplied => 'Đã áp dụng và ghi vào sổ kiểm toán';

  @override
  String get nominationScope => 'Phạm vi';

  @override
  String get nominationScopeRegion => 'Thăng chức trong nước';

  @override
  String get nominationScopeGroupHr => 'Lên Nhân sự tập đoàn';

  @override
  String get nominationScopeGroupFinance => 'Lên Tài chính tập đoàn';

  @override
  String get nominationGroupNote =>
      'Văn phòng quản lý tập đoàn duyệt; duyệt xong người này làm việc được ở mọi khu vực.';

  @override
  String get nominationToGroup => 'Lên cấp tập đoàn';

  @override
  String get adminTabOverview => 'Tổng quan';

  @override
  String get adminTabAccounts => 'Tài khoản';

  @override
  String get adminTabCalendar => 'Lịch làm việc';

  @override
  String get adminTabPositions => 'Chức vụ';

  @override
  String get adminTabData => 'Dữ liệu';

  @override
  String get adminAccountsByRole => 'Tài khoản theo vai trò';

  @override
  String adminAccountsTotal(int n) {
    return '$n tài khoản';
  }

  @override
  String get adminDatabases => 'Cơ sở dữ liệu';

  @override
  String adminDbLine(int tables, String rows, String size) {
    return '$tables bảng · $rows dòng · $size';
  }

  @override
  String get adminActivity => 'Hoạt động 14 ngày qua (số sự kiện)';

  @override
  String get adminRowsByDb => 'Số dòng theo cơ sở dữ liệu';

  @override
  String get adminDbUnavailable => 'Chưa đọc được cơ sở dữ liệu này';

  @override
  String get adminSearchAccounts => 'Tìm tên, email, tên đăng nhập';

  @override
  String get adminAccountDisabled => 'Đã khóa';

  @override
  String adminEditAccount(String name) {
    return 'Sửa tài khoản $name';
  }

  @override
  String get adminAccountEnabled => 'Cho phép đăng nhập';

  @override
  String get adminRoles => 'Vai trò';

  @override
  String get adminSaved => 'Đã lưu và ghi vào sổ kiểm toán';

  @override
  String get adminHolidays => 'Ngày lễ';

  @override
  String get adminAddHoliday => 'Thêm ngày lễ';

  @override
  String get adminHolidayName => 'Tên ngày lễ';

  @override
  String adminHolidayRemove(String name) {
    return 'Bỏ ngày lễ $name?';
  }

  @override
  String get adminNoHolidays => 'Năm này chưa có ngày lễ nào';

  @override
  String get adminShift => 'Giờ ca làm';

  @override
  String get adminShiftHint =>
      'Đổi giờ vào, giờ ra cho mọi ca trong khoảng ngày (chỉ từ hôm nay trở đi, công đã chấm giữ nguyên)';

  @override
  String get adminShiftChange => 'Đổi giờ ca';

  @override
  String get adminShiftStart => 'Giờ vào';

  @override
  String get adminShiftEnd => 'Giờ ra';

  @override
  String get adminShiftRange => 'Khoảng ngày';

  @override
  String adminShiftDone(int n) {
    return 'Đã đổi giờ cho $n ca làm';
  }

  @override
  String get adminAddPosition => 'Thêm chức vụ';

  @override
  String get adminEditPosition => 'Sửa chức vụ';

  @override
  String get adminPositionName => 'Tên chức vụ';

  @override
  String get adminPositionLevel => 'Cấp';

  @override
  String get adminCoefficient => 'Hệ số lương';

  @override
  String adminHolders(int n) {
    return '$n người đang giữ';
  }

  @override
  String get adminDeletePosition => 'Xóa chức vụ';

  @override
  String get adminSql => 'Truy vấn SQL';

  @override
  String get adminSqlHint =>
      'Mặc định chỉ đọc; mỗi lần chạy đều được ghi vào sổ kiểm toán';

  @override
  String get adminSqlWrite => 'Cho phép ghi (INSERT, UPDATE, DELETE)';

  @override
  String get adminSqlWriteConfirm =>
      'Câu lệnh sẽ sửa dữ liệu thật và được ghi vào sổ kiểm toán. Chạy?';

  @override
  String get adminSqlRun => 'Chạy';

  @override
  String adminSqlRows(int n) {
    return '$n dòng';
  }

  @override
  String adminSqlAffected(int n) {
    return 'Đã tác động $n dòng';
  }

  @override
  String get adminSqlTruncated => 'Chỉ hiện 500 dòng đầu';

  @override
  String get adminTechnical => 'Chi tiết kỹ thuật';

  @override
  String get adminBackups => 'Sao lưu';

  @override
  String get adminBackupNow => 'Sao lưu ngay';

  @override
  String get adminBackupDone => 'Đã sao lưu toàn bộ dữ liệu khu vực';

  @override
  String get adminBackupNone => 'Chưa có bản sao lưu';

  @override
  String get adminDownload => 'Tải về';

  @override
  String get errGroupOnly =>
      'Chỉ văn phòng quản lý tập đoàn duyệt được đề cử này';

  @override
  String get errSamePosition => 'Nhân viên đang giữ chức vụ này rồi';

  @override
  String get errInUse => 'Còn người giữ chức vụ này nên chưa xóa được';

  @override
  String get errReadOnly =>
      'Câu lệnh có ghi dữ liệu; bật Cho phép ghi nếu thật sự muốn sửa';

  @override
  String get errSqlError =>
      'Câu lệnh không chạy được, xem chi tiết kỹ thuật bên dưới';

  @override
  String get errUnknownDatabase => 'Chọn cơ sở dữ liệu trong danh sách';

  @override
  String get errEmptySql => 'Nhập câu lệnh SQL';

  @override
  String get errStorageUnavailable => 'Kho lưu trữ chưa sẵn sàng, thử lại sau';

  @override
  String get errIdentityUnavailable =>
      'Chưa kết nối được dịch vụ tài khoản, thử lại sau';

  @override
  String get errOtherRegion => 'Tài khoản này thuộc khu vực khác';

  @override
  String get errRoleNotAllowed => 'Bạn không được gán hoặc gỡ vai trò này';

  @override
  String get errSelfChange => 'Không tự sửa tài khoản của chính mình';

  @override
  String get errInvalidShift => 'Giờ ca không hợp lệ: giờ ra phải sau giờ vào';

  @override
  String get errInvalidRange => 'Khoảng ngày không hợp lệ (tối đa một năm)';

  @override
  String get adminRemove => 'Bỏ';

  @override
  String get evClockedIn => 'Chấm công vào ca';

  @override
  String get evClockedOut => 'Chấm công ra ca';

  @override
  String get evLeaveRequested => 'Gửi đơn nghỉ phép';

  @override
  String get evLeaveApproved => 'Duyệt đơn nghỉ phép';

  @override
  String get evLeaveRejected => 'Từ chối đơn nghỉ phép';

  @override
  String get evOvertimeRequested => 'Gửi đơn tăng ca';

  @override
  String get evOvertimeApproved => 'Duyệt đơn tăng ca';

  @override
  String get evOvertimeRejected => 'Từ chối đơn tăng ca';

  @override
  String get evHolidayAdded => 'Thêm ngày lễ';

  @override
  String get evHolidayRemoved => 'Bỏ ngày lễ';

  @override
  String get evShiftChanged => 'Đổi giờ ca làm';

  @override
  String get evCandidateApplied => 'Ứng viên nộp hồ sơ';

  @override
  String get evCandidateAnalyzed => 'AI đã đọc CV ứng viên';

  @override
  String get evCandidateCvUploaded => 'Ứng viên tải CV lên';

  @override
  String get evCandidateProfileUpdated => 'Ứng viên sửa hồ sơ';

  @override
  String get evCandidateStatusChanged => 'Chuyển bước hồ sơ ứng viên';

  @override
  String get evCandidateHired => 'Nhận ứng viên vào làm';

  @override
  String get evInterviewScheduled => 'Hẹn lịch phỏng vấn';

  @override
  String get evInterviewConfirmed => 'Ứng viên xác nhận lịch phỏng vấn';

  @override
  String get evInterviewProposed => 'Ứng viên đề xuất giờ phỏng vấn khác';

  @override
  String get evPayslipIssued => 'Phát phiếu lương';

  @override
  String get evPayrollRunCompleted => 'Chốt lương xong';

  @override
  String get evPayrollRunFailed => 'Chốt lương lỗi';

  @override
  String get evPayrollRunNeedsAttention => 'Chốt lương cần xử lý';

  @override
  String get evPayrollExpenseRecorded => 'Ghi chi phí lương vào sổ tài chính';

  @override
  String get evPayoutLogged => 'Ghi nhận chuyển lương';

  @override
  String get evSalaryAgreed => 'Chốt mức lương nhận việc';

  @override
  String get evSalaryRaised => 'Tăng lương';

  @override
  String get evSalaryChanged => 'Văn phòng quản lý đổi lương cơ bản';

  @override
  String get evBonusGranted => 'Thưởng';

  @override
  String get evPenaltyApplied => 'Phạt';

  @override
  String get evRaiseRequested => 'Gửi đề xuất tăng lương';

  @override
  String get evRaiseForwarded => 'HR chuyển đề xuất tăng lương lên';

  @override
  String get evRaiseApproved => 'Duyệt tăng lương';

  @override
  String get evRaiseRejected => 'Từ chối tăng lương';

  @override
  String get evRaiseReturned => 'Trả lại đề xuất tăng lương';

  @override
  String get evRaiseWithdrawn => 'Rút đề xuất tăng lương';

  @override
  String get evPromotionNominated => 'Đề cử thăng chức';

  @override
  String get evPromotionApproved => 'Duyệt thăng chức';

  @override
  String get evPromotionRejected => 'Từ chối thăng chức';

  @override
  String get evEmployeePromoted => 'Văn phòng quản lý thăng chức';

  @override
  String get evPositionChanged => 'Văn phòng quản lý đổi chức vụ';

  @override
  String get evPositionCreated => 'Thêm chức vụ';

  @override
  String get evPositionUpdated => 'Sửa chức vụ';

  @override
  String get evPositionDeleted => 'Xóa chức vụ';

  @override
  String get evEmployeeHired => 'Thêm nhân viên mới';

  @override
  String get evEmployeeTransferred => 'Điều chuyển phòng ban';

  @override
  String get evEmployeeArchived => 'Bảo lưu hồ sơ nhân viên';

  @override
  String get evEmployeeRestored => 'Mở lại hồ sơ nhân viên';

  @override
  String get evDepartmentCreated => 'Thành lập phòng ban';

  @override
  String get evDepartmentDissolved => 'Giải thể phòng ban';

  @override
  String get evDepartmentHeadChanged => 'Đổi trưởng phòng';

  @override
  String get evProfileChangeRequested => 'Đề xuất sửa hồ sơ';

  @override
  String get evProfileChangeApproved => 'Duyệt sửa hồ sơ';

  @override
  String get evProfileChangeRejected => 'Từ chối sửa hồ sơ';

  @override
  String get evResignationRequested => 'Gửi đơn thôi việc';

  @override
  String get evResignationApproved => 'Duyệt đơn thôi việc';

  @override
  String get evResignationRejected => 'Từ chối đơn thôi việc';

  @override
  String get evResignationWithdrawn => 'Rút đơn thôi việc';

  @override
  String get evResignationCompleted => 'Hoàn tất thôi việc';

  @override
  String get evReportSubmitted => 'Gửi báo cáo lên cấp trên';

  @override
  String get evReportAcknowledged => 'Cấp trên xác nhận báo cáo';

  @override
  String get evReportReturned => 'Cấp trên trả lại báo cáo';

  @override
  String get evProjectCreated => 'Tạo dự án';

  @override
  String get evProjectProposed => 'Gửi đề xuất dự án';

  @override
  String get evProjectProposalApproved => 'Duyệt đề xuất dự án';

  @override
  String get evProjectProposalRejected => 'Từ chối đề xuất dự án';

  @override
  String get evProjectProposalCountered => 'Đề xuất dự án được sửa qua lại';

  @override
  String get evProjectAccepted => 'Nghiệm thu dự án';

  @override
  String get evProjectMembersRemoved => 'Rút nhân viên khỏi dự án';

  @override
  String get evAcceptanceRevenueRecorded => 'Ghi doanh thu nghiệm thu';

  @override
  String get evMaterialPurchased => 'Mua vật liệu';

  @override
  String get evSupplierPaid => 'Trả tiền nhà cung cấp';

  @override
  String get evFinancePeriodClosed => 'Chốt sổ tài chính tháng';

  @override
  String get evAdminSqlRead => 'Quản trị chạy truy vấn SQL (chỉ đọc)';

  @override
  String get evAdminSqlWrite => 'Quản trị sửa dữ liệu bằng SQL';

  @override
  String get evBackupCreated => 'Sao lưu dữ liệu';

  @override
  String get evAccountChanged => 'Đổi tài khoản, vai trò';

  @override
  String nAuditLog(String event, String by) {
    return 'Nhật ký mới: $event$by';
  }

  @override
  String nAuditLogBy(String by) {
    return ' (bởi $by)';
  }

  @override
  String nPositionChanged(String position) {
    return 'Chức vụ của bạn đã đổi thành $position';
  }

  @override
  String nSalaryChanged(String amount) {
    return 'Lương cơ bản mới của bạn: $amount';
  }

  @override
  String nBonusGranted(String amount, String reason) {
    return 'Bạn được thưởng $amount: $reason';
  }

  @override
  String nPenaltyApplied(String amount, String reason) {
    return 'Bạn bị phạt $amount: $reason';
  }

  @override
  String get errProtectedDatabase =>
      'Cơ sở dữ liệu nhật ký quản trị không được truy vấn ở đây';

  @override
  String get errPastDate =>
      'Chỉ xin nghỉ cho ngày tương lai (từ ngày mai trở đi)';

  @override
  String get leaveAttach => 'Đính kèm minh chứng (Word, PDF, ảnh)';

  @override
  String approvalsOthers(int n) {
    return 'Đơn của nhân viên chờ bạn duyệt ($n)';
  }

  @override
  String approvalsMine(int n) {
    return 'Đơn của bạn đang chờ cấp trên ($n)';
  }

  @override
  String get requestMineTag => 'Đơn của bạn';

  @override
  String get projectOverdue => 'Trễ hạn';

  @override
  String get reportMonth => 'Tháng báo cáo';

  @override
  String get reportMonthDone => 'đã được xác nhận';

  @override
  String get errFuturePeriod =>
      'Chỉ báo cáo tháng hiện tại hoặc các tháng trước';

  @override
  String get errPeriodAcknowledged =>
      'Báo cáo tháng này đã được cấp trên xác nhận, không gửi lại';

  @override
  String get resignationAttachLetter => 'Đính kèm đơn thôi việc';

  @override
  String get resignationLetterHint =>
      'Bắt buộc: ảnh chụp đơn, file Word hoặc PDF (tối đa 10 MB)';

  @override
  String resignationOpenLetter(String name) {
    return 'Mở đơn: $name';
  }

  @override
  String get resignationAiTitle => 'AI phân tích đơn';

  @override
  String get resignationAiRetention => 'Gợi ý giữ chân';

  @override
  String get resignationAiConcerns => 'Cần lưu ý';

  @override
  String get resignationAiNote =>
      'AI chỉ tóm tắt để tham khảo, người duyệt quyết định';

  @override
  String get errLetterRequired =>
      'Cần đính kèm đơn thôi việc (ảnh, Word hoặc PDF)';

  @override
  String get rcCareer => 'Phát triển sự nghiệp';

  @override
  String get rcSalary => 'Lương, đãi ngộ';

  @override
  String get rcWorkload => 'Áp lực công việc';

  @override
  String get rcManagement => 'Quản lý trực tiếp';

  @override
  String get rcEnvironment => 'Môi trường làm việc';

  @override
  String get rcPersonal => 'Lý do cá nhân';

  @override
  String get rcHealth => 'Sức khỏe';

  @override
  String get rcRelocation => 'Chuyển nơi ở';

  @override
  String get rcOther => 'Khác';

  @override
  String get auditExportNow => 'Xuất báo cáo';

  @override
  String get auditRecord => 'Đối tượng';

  @override
  String get auditActor => 'Người thực hiện';

  @override
  String get auditData => 'Dữ liệu của sự kiện';

  @override
  String get auditWhyFlagged => 'Vì sao bị đánh dấu bất thường';

  @override
  String get anomalyAfterHoursWhy =>
      'Thao tác lúc 22h–6h theo giờ của nước đó, ngoài giờ làm việc thông thường';

  @override
  String get anomalyFailureWhy =>
      'Sự kiện thất bại, bị từ chối, phải bù trừ hoặc cần xử lý tay';

  @override
  String get auditAskAi => 'AI phân tích điểm bất thường';

  @override
  String get auditAiTitle => 'AI phân tích';

  @override
  String get auditChecks => 'Cần kiểm tra';

  @override
  String get auditLikelyBenign => 'Có thể là bình thường nếu';

  @override
  String get riskHigh => 'Rủi ro cao';

  @override
  String get riskMedium => 'Rủi ro vừa';

  @override
  String get riskLow => 'Rủi ro thấp';

  @override
  String get interviewTimePassed => 'Đã qua giờ hẹn, hãy đề xuất giờ khác';
}
