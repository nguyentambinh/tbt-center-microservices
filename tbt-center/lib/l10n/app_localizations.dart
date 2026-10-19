import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('pt'),
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In vi, this message translates to:
  /// **'TBT Center'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In vi, this message translates to:
  /// **'TẬP ĐOÀN ĐA QUỐC GIA'**
  String get tagline;

  /// No description provided for @gemPalette.
  ///
  /// In vi, this message translates to:
  /// **'Bộ màu {gem}'**
  String gemPalette(String gem);

  /// No description provided for @gemGold.
  ///
  /// In vi, this message translates to:
  /// **'Vàng kim'**
  String get gemGold;

  /// No description provided for @gemPlatinum.
  ///
  /// In vi, this message translates to:
  /// **'Bạch kim'**
  String get gemPlatinum;

  /// No description provided for @gemEmerald.
  ///
  /// In vi, this message translates to:
  /// **'Lục bảo'**
  String get gemEmerald;

  /// No description provided for @gemRuby.
  ///
  /// In vi, this message translates to:
  /// **'Hồng ngọc'**
  String get gemRuby;

  /// No description provided for @gemSapphire.
  ///
  /// In vi, this message translates to:
  /// **'Lam ngọc'**
  String get gemSapphire;

  /// No description provided for @gemDiamond.
  ///
  /// In vi, this message translates to:
  /// **'Kim cương'**
  String get gemDiamond;

  /// No description provided for @samplePayslipTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bảng lương tháng 10'**
  String get samplePayslipTitle;

  /// No description provided for @viewDetails.
  ///
  /// In vi, this message translates to:
  /// **'Xem chi tiết'**
  String get viewDetails;

  /// No description provided for @downloadPdf.
  ///
  /// In vi, this message translates to:
  /// **'Tải PDF'**
  String get downloadPdf;

  /// No description provided for @settings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get language;

  /// No description provided for @languageAuto.
  ///
  /// In vi, this message translates to:
  /// **'Tự động theo vị trí'**
  String get languageAuto;

  /// No description provided for @dataRegion.
  ///
  /// In vi, this message translates to:
  /// **'Khu vực lưu dữ liệu'**
  String get dataRegion;

  /// No description provided for @detecting.
  ///
  /// In vi, this message translates to:
  /// **'Đang xác định vị trí…'**
  String get detecting;

  /// No description provided for @locationUnknown.
  ///
  /// In vi, this message translates to:
  /// **'Chưa xác định được vị trí, dùng khu vực mặc định'**
  String get locationUnknown;

  /// No description provided for @detectedCountry.
  ///
  /// In vi, this message translates to:
  /// **'Quốc gia: {country}'**
  String detectedCountry(String country);

  /// No description provided for @refreshLocation.
  ///
  /// In vi, this message translates to:
  /// **'Xác định lại'**
  String get refreshLocation;

  /// No description provided for @simulateLocation.
  ///
  /// In vi, this message translates to:
  /// **'Giả lập vị trí'**
  String get simulateLocation;

  /// No description provided for @simulateHint.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ có ở bản debug, dùng để test như đang ở nước khác'**
  String get simulateHint;

  /// No description provided for @simulateIp.
  ///
  /// In vi, this message translates to:
  /// **'Địa chỉ IP'**
  String get simulateIp;

  /// No description provided for @simulateCountry.
  ///
  /// In vi, this message translates to:
  /// **'Hoặc mã nước (VD: DE)'**
  String get simulateCountry;

  /// No description provided for @apply.
  ///
  /// In vi, this message translates to:
  /// **'Áp dụng'**
  String get apply;

  /// No description provided for @clearSimulation.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ giả lập'**
  String get clearSimulation;

  /// No description provided for @regionVn.
  ///
  /// In vi, this message translates to:
  /// **'Việt Nam'**
  String get regionVn;

  /// No description provided for @regionDe.
  ///
  /// In vi, this message translates to:
  /// **'Đức'**
  String get regionDe;

  /// No description provided for @regionUs.
  ///
  /// In vi, this message translates to:
  /// **'Hoa Kỳ'**
  String get regionUs;

  /// No description provided for @regionBr.
  ///
  /// In vi, this message translates to:
  /// **'Brazil'**
  String get regionBr;

  /// No description provided for @regionZa.
  ///
  /// In vi, this message translates to:
  /// **'Nam Phi'**
  String get regionZa;

  /// No description provided for @regionAu.
  ///
  /// In vi, this message translates to:
  /// **'Úc'**
  String get regionAu;

  /// No description provided for @bannerOffline.
  ///
  /// In vi, this message translates to:
  /// **'Không có kết nối mạng · đang xem dữ liệu đã lưu'**
  String get bannerOffline;

  /// No description provided for @bannerServerDown.
  ///
  /// In vi, this message translates to:
  /// **'Không kết nối được máy chủ · đang xem dữ liệu đã lưu'**
  String get bannerServerDown;

  /// No description provided for @bannerUnstable.
  ///
  /// In vi, this message translates to:
  /// **'Kết nối mạng không ổn định'**
  String get bannerUnstable;

  /// No description provided for @bannerRecovered.
  ///
  /// In vi, this message translates to:
  /// **'Đã kết nối lại'**
  String get bannerRecovered;

  /// No description provided for @reconnect.
  ///
  /// In vi, this message translates to:
  /// **'Kết nối lại'**
  String get reconnect;

  /// No description provided for @errorNetwork.
  ///
  /// In vi, this message translates to:
  /// **'Không có kết nối mạng. Kiểm tra Wi-Fi hoặc dữ liệu di động.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In vi, this message translates to:
  /// **'Máy chủ phản hồi quá lâu, vui lòng thử lại.'**
  String get errorTimeout;

  /// No description provided for @errorServer.
  ///
  /// In vi, this message translates to:
  /// **'Máy chủ đang gặp sự cố, vui lòng thử lại sau.'**
  String get errorServer;

  /// No description provided for @errorUnauthorized.
  ///
  /// In vi, this message translates to:
  /// **'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.'**
  String get errorUnauthorized;

  /// No description provided for @errorForbidden.
  ///
  /// In vi, this message translates to:
  /// **'Bạn không có quyền thực hiện thao tác này.'**
  String get errorForbidden;

  /// No description provided for @errorNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy dữ liệu yêu cầu.'**
  String get errorNotFound;

  /// No description provided for @errorValidation.
  ///
  /// In vi, this message translates to:
  /// **'Dữ liệu chưa hợp lệ, vui lòng kiểm tra lại.'**
  String get errorValidation;

  /// No description provided for @errorOfflineWrite.
  ///
  /// In vi, this message translates to:
  /// **'Cần có mạng để lưu thay đổi. Dữ liệu bạn nhập vẫn được giữ lại.'**
  String get errorOfflineWrite;

  /// No description provided for @errorUnknown.
  ///
  /// In vi, this message translates to:
  /// **'Đã xảy ra lỗi không mong muốn, vui lòng thử lại.'**
  String get errorUnknown;

  /// No description provided for @signIn.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get signIn;

  /// No description provided for @applyAsCandidate.
  ///
  /// In vi, this message translates to:
  /// **'Ứng tuyển · tạo tài khoản'**
  String get applyAsCandidate;

  /// No description provided for @signOut.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get signOut;

  /// No description provided for @welcome.
  ///
  /// In vi, this message translates to:
  /// **'Xin chào, {name}'**
  String welcome(String name);

  /// No description provided for @dataStoredIn.
  ///
  /// In vi, this message translates to:
  /// **'Dữ liệu của bạn được lưu tại khu vực {region}'**
  String dataStoredIn(String region);

  /// No description provided for @signInFailed.
  ///
  /// In vi, this message translates to:
  /// **'Không mở được trang đăng nhập. Kiểm tra kết nối tới máy chủ rồi thử lại.'**
  String get signInFailed;

  /// No description provided for @roleExecutive.
  ///
  /// In vi, this message translates to:
  /// **'Văn phòng quản lý'**
  String get roleExecutive;

  /// No description provided for @roleAdmin.
  ///
  /// In vi, this message translates to:
  /// **'Quản trị hệ thống'**
  String get roleAdmin;

  /// No description provided for @roleHr.
  ///
  /// In vi, this message translates to:
  /// **'Nhân sự'**
  String get roleHr;

  /// No description provided for @roleFinance.
  ///
  /// In vi, this message translates to:
  /// **'Tài chính'**
  String get roleFinance;

  /// No description provided for @roleEmployee.
  ///
  /// In vi, this message translates to:
  /// **'Nhân viên'**
  String get roleEmployee;

  /// No description provided for @roleCandidate.
  ///
  /// In vi, this message translates to:
  /// **'Ứng viên'**
  String get roleCandidate;

  /// No description provided for @regionCheckTitle.
  ///
  /// In vi, this message translates to:
  /// **'Kết nối khu vực'**
  String get regionCheckTitle;

  /// No description provided for @regionCheckHint.
  ///
  /// In vi, this message translates to:
  /// **'Gọi thử máy chủ của khu vực bạn qua Kong, có kèm token đăng nhập.'**
  String get regionCheckHint;

  /// No description provided for @regionCheckButton.
  ///
  /// In vi, this message translates to:
  /// **'Kiểm tra'**
  String get regionCheckButton;

  /// No description provided for @regionCheckOk.
  ///
  /// In vi, this message translates to:
  /// **'Máy chủ {service} trả lời bình thường'**
  String regionCheckOk(String service);

  /// No description provided for @savedDataNote.
  ///
  /// In vi, this message translates to:
  /// **'Đang hiển thị dữ liệu đã lưu'**
  String get savedDataNote;

  /// No description provided for @themePreview.
  ///
  /// In vi, this message translates to:
  /// **'Xem các bộ màu đá quý'**
  String get themePreview;

  /// No description provided for @employees.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ nhân viên'**
  String get employees;

  /// No description provided for @employeesHint.
  ///
  /// In vi, this message translates to:
  /// **'Danh sách và hồ sơ nhân viên trong khu vực của bạn'**
  String get employeesHint;

  /// No description provided for @open.
  ///
  /// In vi, this message translates to:
  /// **'Mở'**
  String get open;

  /// No description provided for @searchEmployees.
  ///
  /// In vi, this message translates to:
  /// **'Tìm theo tên, mã hoặc email'**
  String get searchEmployees;

  /// No description provided for @employeeCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} nhân viên'**
  String employeeCount(int count);

  /// No description provided for @noEmployees.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy nhân viên nào'**
  String get noEmployees;

  /// No description provided for @loadMore.
  ///
  /// In vi, this message translates to:
  /// **'Tải thêm'**
  String get loadMore;

  /// No description provided for @retry.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get retry;

  /// No description provided for @sectionWork.
  ///
  /// In vi, this message translates to:
  /// **'Công việc'**
  String get sectionWork;

  /// No description provided for @sectionContact.
  ///
  /// In vi, this message translates to:
  /// **'Liên hệ'**
  String get sectionContact;

  /// No description provided for @sectionRelatives.
  ///
  /// In vi, this message translates to:
  /// **'Người thân'**
  String get sectionRelatives;

  /// No description provided for @sectionHealth.
  ///
  /// In vi, this message translates to:
  /// **'Sức khỏe'**
  String get sectionHealth;

  /// No description provided for @sectionInsurance.
  ///
  /// In vi, this message translates to:
  /// **'Bảo hiểm'**
  String get sectionInsurance;

  /// No description provided for @fieldId.
  ///
  /// In vi, this message translates to:
  /// **'Mã nhân viên'**
  String get fieldId;

  /// No description provided for @fieldCompany.
  ///
  /// In vi, this message translates to:
  /// **'Đơn vị'**
  String get fieldCompany;

  /// No description provided for @fieldDepartment.
  ///
  /// In vi, this message translates to:
  /// **'Phòng ban'**
  String get fieldDepartment;

  /// No description provided for @fieldPosition.
  ///
  /// In vi, this message translates to:
  /// **'Chức vụ'**
  String get fieldPosition;

  /// No description provided for @fieldBirthYear.
  ///
  /// In vi, this message translates to:
  /// **'Năm sinh'**
  String get fieldBirthYear;

  /// No description provided for @fieldGender.
  ///
  /// In vi, this message translates to:
  /// **'Giới tính'**
  String get fieldGender;

  /// No description provided for @genderMale.
  ///
  /// In vi, this message translates to:
  /// **'Nam'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In vi, this message translates to:
  /// **'Nữ'**
  String get genderFemale;

  /// No description provided for @fieldHiredOn.
  ///
  /// In vi, this message translates to:
  /// **'Ngày vào làm'**
  String get fieldHiredOn;

  /// No description provided for @fieldLaborContract.
  ///
  /// In vi, this message translates to:
  /// **'Hợp đồng lao động'**
  String get fieldLaborContract;

  /// No description provided for @fieldEmail.
  ///
  /// In vi, this message translates to:
  /// **'Email'**
  String get fieldEmail;

  /// No description provided for @fieldPhone.
  ///
  /// In vi, this message translates to:
  /// **'Điện thoại'**
  String get fieldPhone;

  /// No description provided for @fieldAddress.
  ///
  /// In vi, this message translates to:
  /// **'Địa chỉ'**
  String get fieldAddress;

  /// No description provided for @fieldHometown.
  ///
  /// In vi, this message translates to:
  /// **'Quê quán'**
  String get fieldHometown;

  /// No description provided for @fieldHeight.
  ///
  /// In vi, this message translates to:
  /// **'Chiều cao'**
  String get fieldHeight;

  /// No description provided for @fieldWeight.
  ///
  /// In vi, this message translates to:
  /// **'Cân nặng'**
  String get fieldWeight;

  /// No description provided for @fieldVision.
  ///
  /// In vi, this message translates to:
  /// **'Thị lực'**
  String get fieldVision;

  /// No description provided for @fieldMedicalHistory.
  ///
  /// In vi, this message translates to:
  /// **'Tiền sử bệnh'**
  String get fieldMedicalHistory;

  /// No description provided for @fieldUpdatedOn.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật'**
  String get fieldUpdatedOn;

  /// No description provided for @fieldInsuranceType.
  ///
  /// In vi, this message translates to:
  /// **'Loại bảo hiểm'**
  String get fieldInsuranceType;

  /// No description provided for @fieldInsuranceNumber.
  ///
  /// In vi, this message translates to:
  /// **'Số bảo hiểm'**
  String get fieldInsuranceNumber;

  /// No description provided for @fieldExpiresOn.
  ///
  /// In vi, this message translates to:
  /// **'Hết hạn'**
  String get fieldExpiresOn;

  /// No description provided for @noData.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có dữ liệu'**
  String get noData;

  /// No description provided for @attendance.
  ///
  /// In vi, this message translates to:
  /// **'Chấm công & nghỉ phép'**
  String get attendance;

  /// No description provided for @attendanceHint.
  ///
  /// In vi, this message translates to:
  /// **'Giờ làm của bạn, đơn nghỉ và duyệt đơn'**
  String get attendanceHint;

  /// No description provided for @tabTimesheet.
  ///
  /// In vi, this message translates to:
  /// **'Chấm công'**
  String get tabTimesheet;

  /// No description provided for @tabLeave.
  ///
  /// In vi, this message translates to:
  /// **'Nghỉ phép'**
  String get tabLeave;

  /// No description provided for @tabApprovals.
  ///
  /// In vi, this message translates to:
  /// **'Duyệt đơn'**
  String get tabApprovals;

  /// No description provided for @totalHours.
  ///
  /// In vi, this message translates to:
  /// **'Tổng {hours} giờ trong {days} ngày'**
  String totalHours(String hours, int days);

  /// No description provided for @checkInOut.
  ///
  /// In vi, this message translates to:
  /// **'Vào {checkIn} · Ra {checkOut}'**
  String checkInOut(String checkIn, String checkOut);

  /// No description provided for @overtimeHours.
  ///
  /// In vi, this message translates to:
  /// **'Tăng ca {hours} giờ'**
  String overtimeHours(String hours);

  /// No description provided for @newLeave.
  ///
  /// In vi, this message translates to:
  /// **'Xin nghỉ'**
  String get newLeave;

  /// No description provided for @leaveType.
  ///
  /// In vi, this message translates to:
  /// **'Loại nghỉ'**
  String get leaveType;

  /// No description provided for @leaveAnnual.
  ///
  /// In vi, this message translates to:
  /// **'Nghỉ phép năm'**
  String get leaveAnnual;

  /// No description provided for @leaveSick.
  ///
  /// In vi, this message translates to:
  /// **'Nghỉ ốm'**
  String get leaveSick;

  /// No description provided for @leaveUnpaid.
  ///
  /// In vi, this message translates to:
  /// **'Nghỉ không lương'**
  String get leaveUnpaid;

  /// No description provided for @leavePersonal.
  ///
  /// In vi, this message translates to:
  /// **'Việc riêng'**
  String get leavePersonal;

  /// No description provided for @leaveDates.
  ///
  /// In vi, this message translates to:
  /// **'Thời gian nghỉ'**
  String get leaveDates;

  /// No description provided for @pickDates.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ngày'**
  String get pickDates;

  /// No description provided for @reason.
  ///
  /// In vi, this message translates to:
  /// **'Lý do'**
  String get reason;

  /// No description provided for @submitLeave.
  ///
  /// In vi, this message translates to:
  /// **'Gửi đơn'**
  String get submitLeave;

  /// No description provided for @leaveSubmitted.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi đơn nghỉ'**
  String get leaveSubmitted;

  /// No description provided for @statusPending.
  ///
  /// In vi, this message translates to:
  /// **'Chờ duyệt'**
  String get statusPending;

  /// No description provided for @statusApproved.
  ///
  /// In vi, this message translates to:
  /// **'Đã duyệt'**
  String get statusApproved;

  /// No description provided for @statusRejected.
  ///
  /// In vi, this message translates to:
  /// **'Từ chối'**
  String get statusRejected;

  /// No description provided for @approve.
  ///
  /// In vi, this message translates to:
  /// **'Duyệt'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In vi, this message translates to:
  /// **'Từ chối'**
  String get reject;

  /// No description provided for @leaveDays.
  ///
  /// In vi, this message translates to:
  /// **'{days} ngày'**
  String leaveDays(int days);

  /// No description provided for @noLeaves.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có đơn nghỉ nào'**
  String get noLeaves;

  /// No description provided for @noPending.
  ///
  /// In vi, this message translates to:
  /// **'Không có đơn nào chờ duyệt'**
  String get noPending;

  /// No description provided for @noTimesheets.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có dữ liệu chấm công'**
  String get noTimesheets;

  /// No description provided for @leaveDecided.
  ///
  /// In vi, this message translates to:
  /// **'Đã cập nhật đơn'**
  String get leaveDecided;

  /// No description provided for @errOverlap.
  ///
  /// In vi, this message translates to:
  /// **'Khoảng thời gian này trùng với một đơn nghỉ khác'**
  String get errOverlap;

  /// No description provided for @errTooLong.
  ///
  /// In vi, this message translates to:
  /// **'Mỗi đơn nghỉ tối đa 30 ngày'**
  String get errTooLong;

  /// No description provided for @errInvalidDates.
  ///
  /// In vi, this message translates to:
  /// **'Ngày kết thúc phải sau ngày bắt đầu'**
  String get errInvalidDates;

  /// No description provided for @errAlreadyDecided.
  ///
  /// In vi, this message translates to:
  /// **'Đơn này đã được xử lý trước đó'**
  String get errAlreadyDecided;

  /// No description provided for @errSelfApproval.
  ///
  /// In vi, this message translates to:
  /// **'Bạn không thể tự duyệt đơn của mình'**
  String get errSelfApproval;

  /// No description provided for @errRegionMismatch.
  ///
  /// In vi, this message translates to:
  /// **'Dữ liệu thuộc khu vực khác, bạn không có quyền xem'**
  String get errRegionMismatch;

  /// No description provided for @errNoEmployee.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản chưa được gắn với hồ sơ nhân viên'**
  String get errNoEmployee;

  /// No description provided for @myApplication.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ ứng tuyển của tôi'**
  String get myApplication;

  /// No description provided for @myApplicationHint.
  ///
  /// In vi, this message translates to:
  /// **'Nộp hồ sơ, xem tiến trình tuyển dụng'**
  String get myApplicationHint;

  /// No description provided for @candidates.
  ///
  /// In vi, this message translates to:
  /// **'Ứng viên'**
  String get candidates;

  /// No description provided for @candidatesHint.
  ///
  /// In vi, this message translates to:
  /// **'Danh sách hồ sơ ứng tuyển và chuyển bước'**
  String get candidatesHint;

  /// No description provided for @applyNow.
  ///
  /// In vi, this message translates to:
  /// **'Nộp hồ sơ'**
  String get applyNow;

  /// No description provided for @editProfile.
  ///
  /// In vi, this message translates to:
  /// **'Sửa hồ sơ'**
  String get editProfile;

  /// No description provided for @saveProfile.
  ///
  /// In vi, this message translates to:
  /// **'Lưu hồ sơ'**
  String get saveProfile;

  /// No description provided for @fullName.
  ///
  /// In vi, this message translates to:
  /// **'Họ và tên'**
  String get fullName;

  /// No description provided for @appliedPosition.
  ///
  /// In vi, this message translates to:
  /// **'Vị trí ứng tuyển'**
  String get appliedPosition;

  /// No description provided for @consentAi.
  ///
  /// In vi, this message translates to:
  /// **'Đồng ý cho AI đọc và tóm tắt CV của tôi'**
  String get consentAi;

  /// No description provided for @notAppliedYet.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa nộp hồ sơ nào'**
  String get notAppliedYet;

  /// No description provided for @progress.
  ///
  /// In vi, this message translates to:
  /// **'Tiến trình'**
  String get progress;

  /// No description provided for @profileSaved.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu hồ sơ'**
  String get profileSaved;

  /// No description provided for @profileLockedHint.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ đã vào vòng phỏng vấn nên không sửa được nữa'**
  String get profileLockedHint;

  /// No description provided for @moveTo.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển sang'**
  String get moveTo;

  /// No description provided for @statusChanged.
  ///
  /// In vi, this message translates to:
  /// **'Đã chuyển bước'**
  String get statusChanged;

  /// No description provided for @noCandidates.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có ứng viên'**
  String get noCandidates;

  /// No description provided for @allStatuses.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get allStatuses;

  /// No description provided for @note.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú'**
  String get note;

  /// No description provided for @stageSubmitted.
  ///
  /// In vi, this message translates to:
  /// **'Đã nộp'**
  String get stageSubmitted;

  /// No description provided for @stageAnalyzed.
  ///
  /// In vi, this message translates to:
  /// **'AI đã tóm tắt'**
  String get stageAnalyzed;

  /// No description provided for @stageScreening.
  ///
  /// In vi, this message translates to:
  /// **'Đang sàng lọc'**
  String get stageScreening;

  /// No description provided for @stageInterview.
  ///
  /// In vi, this message translates to:
  /// **'Phỏng vấn'**
  String get stageInterview;

  /// No description provided for @stageOffered.
  ///
  /// In vi, this message translates to:
  /// **'Mời nhận việc'**
  String get stageOffered;

  /// No description provided for @stageRejected.
  ///
  /// In vi, this message translates to:
  /// **'Chưa phù hợp'**
  String get stageRejected;

  /// No description provided for @errProfileLocked.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ đã vào vòng phỏng vấn nên không sửa được nữa'**
  String get errProfileLocked;

  /// No description provided for @cvSection.
  ///
  /// In vi, this message translates to:
  /// **'CV'**
  String get cvSection;

  /// No description provided for @cvNone.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có CV'**
  String get cvNone;

  /// No description provided for @cvAttached.
  ///
  /// In vi, this message translates to:
  /// **'Đã có CV'**
  String get cvAttached;

  /// No description provided for @uploadCv.
  ///
  /// In vi, this message translates to:
  /// **'Tải CV lên (PDF)'**
  String get uploadCv;

  /// No description provided for @replaceCv.
  ///
  /// In vi, this message translates to:
  /// **'Thay CV khác'**
  String get replaceCv;

  /// No description provided for @cvUploaded.
  ///
  /// In vi, this message translates to:
  /// **'Đã tải CV lên'**
  String get cvUploaded;

  /// No description provided for @cvWaitingAi.
  ///
  /// In vi, this message translates to:
  /// **'AI đang đọc CV, kết quả sẽ có sau ít phút'**
  String get cvWaitingAi;

  /// No description provided for @openCv.
  ///
  /// In vi, this message translates to:
  /// **'Mở CV'**
  String get openCv;

  /// No description provided for @aiSummary.
  ///
  /// In vi, this message translates to:
  /// **'Tóm tắt của AI'**
  String get aiSummary;

  /// No description provided for @aiDisclaimer.
  ///
  /// In vi, this message translates to:
  /// **'Bản tóm tắt do AI tạo, hãy đối chiếu với CV gốc trước khi quyết định.'**
  String get aiDisclaimer;

  /// No description provided for @yearsExperience.
  ///
  /// In vi, this message translates to:
  /// **'{years} năm kinh nghiệm'**
  String yearsExperience(String years);

  /// No description provided for @skills.
  ///
  /// In vi, this message translates to:
  /// **'Kỹ năng'**
  String get skills;

  /// No description provided for @suitablePositions.
  ///
  /// In vi, this message translates to:
  /// **'Vị trí phù hợp'**
  String get suitablePositions;

  /// No description provided for @strengths.
  ///
  /// In vi, this message translates to:
  /// **'Điểm mạnh'**
  String get strengths;

  /// No description provided for @interviewQuestions.
  ///
  /// In vi, this message translates to:
  /// **'Nên hỏi thêm khi phỏng vấn'**
  String get interviewQuestions;

  /// No description provided for @errCvNotPdf.
  ///
  /// In vi, this message translates to:
  /// **'File CV phải là PDF'**
  String get errCvNotPdf;

  /// No description provided for @errCvTooLarge.
  ///
  /// In vi, this message translates to:
  /// **'CV tối đa 10 MB'**
  String get errCvTooLarge;

  /// No description provided for @payslips.
  ///
  /// In vi, this message translates to:
  /// **'Phiếu lương'**
  String get payslips;

  /// No description provided for @payslipsHint.
  ///
  /// In vi, this message translates to:
  /// **'Lương từng kỳ, thưởng và phạt'**
  String get payslipsHint;

  /// No description provided for @baseSalary.
  ///
  /// In vi, this message translates to:
  /// **'Lương cơ bản'**
  String get baseSalary;

  /// No description provided for @grossPay.
  ///
  /// In vi, this message translates to:
  /// **'Tổng thu nhập'**
  String get grossPay;

  /// No description provided for @netPay.
  ///
  /// In vi, this message translates to:
  /// **'Thực nhận'**
  String get netPay;

  /// No description provided for @netUsd.
  ///
  /// In vi, this message translates to:
  /// **'≈ {amount} quy đổi theo tỷ giá ngày trả'**
  String netUsd(String amount);

  /// No description provided for @paidOn.
  ///
  /// In vi, this message translates to:
  /// **'Trả ngày {date}'**
  String paidOn(String date);

  /// No description provided for @bonusesPenalties.
  ///
  /// In vi, this message translates to:
  /// **'Thưởng / phạt'**
  String get bonusesPenalties;

  /// No description provided for @bonus.
  ///
  /// In vi, this message translates to:
  /// **'Thưởng'**
  String get bonus;

  /// No description provided for @penalty.
  ///
  /// In vi, this message translates to:
  /// **'Phạt'**
  String get penalty;

  /// No description provided for @noPayslips.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có phiếu lương'**
  String get noPayslips;

  /// No description provided for @payrollRuns.
  ///
  /// In vi, this message translates to:
  /// **'Chốt lương'**
  String get payrollRuns;

  /// No description provided for @payrollRunsHint.
  ///
  /// In vi, this message translates to:
  /// **'Tính và chi lương cả khu vực theo kỳ'**
  String get payrollRunsHint;

  /// No description provided for @startPayrollRun.
  ///
  /// In vi, this message translates to:
  /// **'Chốt lương kỳ {period}'**
  String startPayrollRun(String period);

  /// No description provided for @runRunning.
  ///
  /// In vi, this message translates to:
  /// **'Đang chạy'**
  String get runRunning;

  /// No description provided for @runCompleted.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn tất'**
  String get runCompleted;

  /// No description provided for @runFailed.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi, đã hoàn tác'**
  String get runFailed;

  /// No description provided for @retryRun.
  ///
  /// In vi, this message translates to:
  /// **'Chạy lại'**
  String get retryRun;

  /// No description provided for @sagaSteps.
  ///
  /// In vi, this message translates to:
  /// **'Các bước'**
  String get sagaSteps;

  /// No description provided for @stepCollectHours.
  ///
  /// In vi, this message translates to:
  /// **'Lấy giờ công'**
  String get stepCollectHours;

  /// No description provided for @stepFetchRate.
  ///
  /// In vi, this message translates to:
  /// **'Lấy tỷ giá'**
  String get stepFetchRate;

  /// No description provided for @stepCalculate.
  ///
  /// In vi, this message translates to:
  /// **'Tính phiếu lương'**
  String get stepCalculate;

  /// No description provided for @stepPay.
  ///
  /// In vi, this message translates to:
  /// **'Chi lương qua kênh thanh toán'**
  String get stepPay;

  /// No description provided for @stepComplete.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn tất'**
  String get stepComplete;

  /// No description provided for @stepCompensate.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn tác phần chưa chi'**
  String get stepCompensate;

  /// No description provided for @stepRetry.
  ///
  /// In vi, this message translates to:
  /// **'Chạy lại'**
  String get stepRetry;

  /// No description provided for @stepResume.
  ///
  /// In vi, this message translates to:
  /// **'Chạy tiếp sau khi khởi động lại'**
  String get stepResume;

  /// No description provided for @paidSummary.
  ///
  /// In vi, this message translates to:
  /// **'{count} phiếu đã chi · {amount}'**
  String paidSummary(int count, String amount);

  /// No description provided for @noRuns.
  ///
  /// In vi, this message translates to:
  /// **'Chưa chốt kỳ nào'**
  String get noRuns;

  /// No description provided for @errRunExists.
  ///
  /// In vi, this message translates to:
  /// **'Kỳ này đã chốt rồi'**
  String get errRunExists;

  /// No description provided for @errRunFailed.
  ///
  /// In vi, this message translates to:
  /// **'Kỳ này đã chốt nhưng lỗi, hãy chạy lại'**
  String get errRunFailed;

  /// No description provided for @groupReport.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo tập đoàn'**
  String get groupReport;

  /// No description provided for @groupReportHint.
  ///
  /// In vi, this message translates to:
  /// **'Số liệu hợp nhất mọi khu vực, quy về USD'**
  String get groupReportHint;

  /// No description provided for @payrollCostByRegion.
  ///
  /// In vi, this message translates to:
  /// **'Chi phí lương theo khu vực'**
  String get payrollCostByRegion;

  /// No description provided for @leavesByRegion.
  ///
  /// In vi, this message translates to:
  /// **'Đơn nghỉ theo khu vực'**
  String get leavesByRegion;

  /// No description provided for @candidatesByRegion.
  ///
  /// In vi, this message translates to:
  /// **'Ứng viên theo khu vực'**
  String get candidatesByRegion;

  /// No description provided for @groupTotal.
  ///
  /// In vi, this message translates to:
  /// **'Toàn tập đoàn'**
  String get groupTotal;

  /// No description provided for @dataAsOf.
  ///
  /// In vi, this message translates to:
  /// **'Số liệu tới sự kiện #{id}'**
  String dataAsOf(String id);

  /// No description provided for @noReportData.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có số liệu'**
  String get noReportData;

  /// No description provided for @employeesCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} người'**
  String employeesCount(int count);

  /// No description provided for @projects.
  ///
  /// In vi, this message translates to:
  /// **'Dự án và hợp đồng'**
  String get projects;

  /// No description provided for @projectsHint.
  ///
  /// In vi, this message translates to:
  /// **'Dự án, khách hàng, nhân sự tham gia'**
  String get projectsHint;

  /// No description provided for @searchProjects.
  ///
  /// In vi, this message translates to:
  /// **'Tìm mã dự án, hợp đồng, khách hàng'**
  String get searchProjects;

  /// No description provided for @noProjects.
  ///
  /// In vi, this message translates to:
  /// **'Không có dự án'**
  String get noProjects;

  /// No description provided for @projectMoney.
  ///
  /// In vi, this message translates to:
  /// **'Giá trị dự án'**
  String get projectMoney;

  /// No description provided for @deposit.
  ///
  /// In vi, this message translates to:
  /// **'Tiền cọc'**
  String get deposit;

  /// No description provided for @expectedAcceptance.
  ///
  /// In vi, this message translates to:
  /// **'Nghiệm thu dự kiến'**
  String get expectedAcceptance;

  /// No description provided for @customer.
  ///
  /// In vi, this message translates to:
  /// **'Khách hàng'**
  String get customer;

  /// No description provided for @customerContactHidden.
  ///
  /// In vi, this message translates to:
  /// **'Liên hệ của khách hàng chỉ bộ phận tài chính xem được'**
  String get customerContactHidden;

  /// No description provided for @contracts.
  ///
  /// In vi, this message translates to:
  /// **'Hợp đồng'**
  String get contracts;

  /// No description provided for @projectMembers.
  ///
  /// In vi, this message translates to:
  /// **'Nhân sự tham gia'**
  String get projectMembers;

  /// No description provided for @myProjects.
  ///
  /// In vi, this message translates to:
  /// **'Dự án của tôi'**
  String get myProjects;

  /// No description provided for @myProjectsHint.
  ///
  /// In vi, this message translates to:
  /// **'Dự án đang tham gia và số giờ đã làm'**
  String get myProjectsHint;

  /// No description provided for @noMyProjects.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa tham gia dự án nào'**
  String get noMyProjects;

  /// No description provided for @finance.
  ///
  /// In vi, this message translates to:
  /// **'Tài chính'**
  String get finance;

  /// No description provided for @financeHint.
  ///
  /// In vi, this message translates to:
  /// **'Thu chi theo tháng, nhà cung cấp, chốt sổ'**
  String get financeHint;

  /// No description provided for @incomeExpense.
  ///
  /// In vi, this message translates to:
  /// **'Thu chi'**
  String get incomeExpense;

  /// No description provided for @suppliers.
  ///
  /// In vi, this message translates to:
  /// **'Nhà cung cấp'**
  String get suppliers;

  /// No description provided for @revenue.
  ///
  /// In vi, this message translates to:
  /// **'Doanh thu'**
  String get revenue;

  /// No description provided for @cost.
  ///
  /// In vi, this message translates to:
  /// **'Chi phí'**
  String get cost;

  /// No description provided for @profit.
  ///
  /// In vi, this message translates to:
  /// **'Lợi nhuận'**
  String get profit;

  /// No description provided for @periodClosed.
  ///
  /// In vi, this message translates to:
  /// **'Đã chốt sổ'**
  String get periodClosed;

  /// No description provided for @closePeriod.
  ///
  /// In vi, this message translates to:
  /// **'Chốt sổ'**
  String get closePeriod;

  /// No description provided for @noFinanceData.
  ///
  /// In vi, this message translates to:
  /// **'Năm này chưa có số liệu'**
  String get noFinanceData;

  /// No description provided for @purchased.
  ///
  /// In vi, this message translates to:
  /// **'Đã mua'**
  String get purchased;

  /// No description provided for @paid.
  ///
  /// In vi, this message translates to:
  /// **'Đã trả'**
  String get paid;

  /// No description provided for @balance.
  ///
  /// In vi, this message translates to:
  /// **'Còn nợ'**
  String get balance;

  /// No description provided for @recordPurchase.
  ///
  /// In vi, this message translates to:
  /// **'Ghi mua'**
  String get recordPurchase;

  /// No description provided for @recordPayment.
  ///
  /// In vi, this message translates to:
  /// **'Trả tiền'**
  String get recordPayment;

  /// No description provided for @materialName.
  ///
  /// In vi, this message translates to:
  /// **'Tên vật liệu'**
  String get materialName;

  /// No description provided for @amount.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền'**
  String get amount;

  /// No description provided for @purchaseHistory.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử mua'**
  String get purchaseHistory;

  /// No description provided for @paymentHistory.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử trả'**
  String get paymentHistory;

  /// No description provided for @financeByRegion.
  ///
  /// In vi, this message translates to:
  /// **'Doanh thu, chi phí đã chốt sổ'**
  String get financeByRegion;

  /// No description provided for @cancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get save;

  /// No description provided for @errPeriodClosed.
  ///
  /// In vi, this message translates to:
  /// **'Tháng này đã chốt sổ, không ghi thêm được'**
  String get errPeriodClosed;

  /// No description provided for @errPeriodNotEnded.
  ///
  /// In vi, this message translates to:
  /// **'Tháng này chưa kết thúc, chưa chốt sổ được'**
  String get errPeriodNotEnded;

  /// No description provided for @errOverpaid.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền trả lớn hơn số còn nợ'**
  String get errOverpaid;

  /// No description provided for @errInvalidAmount.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền không hợp lệ'**
  String get errInvalidAmount;

  /// No description provided for @closePeriodConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Chốt sổ tháng {period}? Sau khi chốt không ghi thêm chứng từ vào tháng này.'**
  String closePeriodConfirm(String period);

  /// No description provided for @hoursValue.
  ///
  /// In vi, this message translates to:
  /// **'{hours} giờ'**
  String hoursValue(String hours);

  /// No description provided for @clockToday.
  ///
  /// In vi, this message translates to:
  /// **'Chấm công hôm nay'**
  String get clockToday;

  /// No description provided for @noShiftToday.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay bạn không có ca làm việc, không chấm công được'**
  String get noShiftToday;

  /// No description provided for @clockIn.
  ///
  /// In vi, this message translates to:
  /// **'Vào ca'**
  String get clockIn;

  /// No description provided for @clockOut.
  ///
  /// In vi, this message translates to:
  /// **'Ra ca'**
  String get clockOut;

  /// No description provided for @shiftDone.
  ///
  /// In vi, this message translates to:
  /// **'Đã xong ca hôm nay'**
  String get shiftDone;

  /// No description provided for @holidayShift.
  ///
  /// In vi, this message translates to:
  /// **'Ngày lễ'**
  String get holidayShift;

  /// No description provided for @sundayShift.
  ///
  /// In vi, this message translates to:
  /// **'Chủ nhật'**
  String get sundayShift;

  /// No description provided for @tabOvertime.
  ///
  /// In vi, this message translates to:
  /// **'Tăng ca'**
  String get tabOvertime;

  /// No description provided for @newOvertime.
  ///
  /// In vi, this message translates to:
  /// **'Xin tăng ca'**
  String get newOvertime;

  /// No description provided for @noOvertime.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có đơn tăng ca'**
  String get noOvertime;

  /// No description provided for @submitOvertime.
  ///
  /// In vi, this message translates to:
  /// **'Gửi đơn'**
  String get submitOvertime;

  /// No description provided for @errNoShift.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay bạn không có ca làm việc'**
  String get errNoShift;

  /// No description provided for @errAlreadyClockedOut.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã ra ca hôm nay rồi'**
  String get errAlreadyClockedOut;

  /// No description provided for @errTooSoon.
  ///
  /// In vi, this message translates to:
  /// **'Vừa vào ca, chờ ít nhất 5 phút mới ra ca được'**
  String get errTooSoon;

  /// No description provided for @errInvalidHours.
  ///
  /// In vi, this message translates to:
  /// **'Số giờ tăng ca phải từ 0,5 đến 12'**
  String get errInvalidHours;

  /// No description provided for @clockedIn.
  ///
  /// In vi, this message translates to:
  /// **'Đã vào ca lúc {time}'**
  String clockedIn(String time);

  /// No description provided for @clockedOut.
  ///
  /// In vi, this message translates to:
  /// **'Đã ra ca lúc {time}, làm {hours} giờ'**
  String clockedOut(String time, String hours);

  /// No description provided for @totalHoursToday.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay làm {hours} giờ'**
  String totalHoursToday(String hours);

  /// No description provided for @notifications.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có thông báo'**
  String get noNotifications;

  /// No description provided for @markAllRead.
  ///
  /// In vi, this message translates to:
  /// **'Đọc hết'**
  String get markAllRead;

  /// No description provided for @nGeneric.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có thông báo mới'**
  String get nGeneric;

  /// No description provided for @nLeaveRequested.
  ///
  /// In vi, this message translates to:
  /// **'{employee} xin nghỉ {days} ngày từ {date}'**
  String nLeaveRequested(String employee, String days, String date);

  /// No description provided for @nLeaveApproved.
  ///
  /// In vi, this message translates to:
  /// **'Đơn nghỉ từ {date} đã được duyệt'**
  String nLeaveApproved(String date);

  /// No description provided for @nLeaveRejected.
  ///
  /// In vi, this message translates to:
  /// **'Đơn nghỉ từ {date} bị từ chối'**
  String nLeaveRejected(String date);

  /// No description provided for @nOvertimeRequested.
  ///
  /// In vi, this message translates to:
  /// **'{employee} xin tăng ca {hours} giờ ngày {date}'**
  String nOvertimeRequested(String employee, String hours, String date);

  /// No description provided for @nOvertimeApproved.
  ///
  /// In vi, this message translates to:
  /// **'Đơn tăng ca ngày {date} đã được duyệt'**
  String nOvertimeApproved(String date);

  /// No description provided for @nOvertimeRejected.
  ///
  /// In vi, this message translates to:
  /// **'Đơn tăng ca ngày {date} bị từ chối'**
  String nOvertimeRejected(String date);

  /// No description provided for @nCandidateApplied.
  ///
  /// In vi, this message translates to:
  /// **'Có hồ sơ ứng tuyển mới: {position}'**
  String nCandidateApplied(String position);

  /// No description provided for @nCandidateStatus.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ của bạn đã chuyển sang bước: {stage}'**
  String nCandidateStatus(String stage);

  /// No description provided for @nPayrollPaid.
  ///
  /// In vi, this message translates to:
  /// **'Lương kỳ {period} đã được chi'**
  String nPayrollPaid(String period);

  /// No description provided for @nPayrollFailed.
  ///
  /// In vi, this message translates to:
  /// **'Chốt lương kỳ {period} bị lỗi, cần chạy lại'**
  String nPayrollFailed(String period);

  /// No description provided for @nFinanceClosed.
  ///
  /// In vi, this message translates to:
  /// **'Đã chốt sổ tài chính tháng {period}'**
  String nFinanceClosed(String period);

  /// No description provided for @importCandidates.
  ///
  /// In vi, this message translates to:
  /// **'Nhập ứng viên từ tệp'**
  String get importCandidates;

  /// No description provided for @confirmAll.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận tất cả'**
  String get confirmAll;

  /// No description provided for @importRowNew.
  ///
  /// In vi, this message translates to:
  /// **'Thêm mới'**
  String get importRowNew;

  /// No description provided for @importRowUpdate.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật'**
  String get importRowUpdate;

  /// No description provided for @importRowAccepted.
  ///
  /// In vi, this message translates to:
  /// **'Đã ghi'**
  String get importRowAccepted;

  /// No description provided for @importErrMissingName.
  ///
  /// In vi, this message translates to:
  /// **'Thiếu họ tên'**
  String get importErrMissingName;

  /// No description provided for @importErrMissingContact.
  ///
  /// In vi, this message translates to:
  /// **'Thiếu email và số điện thoại'**
  String get importErrMissingContact;

  /// No description provided for @importErrInvalidEmail.
  ///
  /// In vi, this message translates to:
  /// **'Email sai định dạng'**
  String get importErrInvalidEmail;

  /// No description provided for @errUnsupportedFile.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ nhận tệp .csv hoặc .xlsx'**
  String get errUnsupportedFile;

  /// No description provided for @errMissingNameColumn.
  ///
  /// In vi, this message translates to:
  /// **'Tệp không có cột họ tên ở dòng đầu'**
  String get errMissingNameColumn;

  /// No description provided for @errEmptyFile.
  ///
  /// In vi, this message translates to:
  /// **'Tệp không có dòng ứng viên nào'**
  String get errEmptyFile;

  /// No description provided for @errFileTooLarge.
  ///
  /// In vi, this message translates to:
  /// **'Tệp lớn hơn 2 MB'**
  String get errFileTooLarge;

  /// No description provided for @confirmSelected.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận đã chọn ({count})'**
  String confirmSelected(int count);

  /// No description provided for @importAccepted.
  ///
  /// In vi, this message translates to:
  /// **'Đã ghi {count} hồ sơ'**
  String importAccepted(int count);

  /// No description provided for @importSummary.
  ///
  /// In vi, this message translates to:
  /// **'{total} dòng, còn {pending} dòng chờ xác nhận'**
  String importSummary(int total, int pending);

  /// No description provided for @importRowNumber.
  ///
  /// In vi, this message translates to:
  /// **'Dòng {n}'**
  String importRowNumber(int n);

  /// No description provided for @roleAuditor.
  ///
  /// In vi, this message translates to:
  /// **'Kiểm toán'**
  String get roleAuditor;

  /// No description provided for @gemAmethyst.
  ///
  /// In vi, this message translates to:
  /// **'Thạch anh tím'**
  String get gemAmethyst;

  /// No description provided for @auditLog.
  ///
  /// In vi, this message translates to:
  /// **'Sổ kiểm toán'**
  String get auditLog;

  /// No description provided for @auditLogHint.
  ///
  /// In vi, this message translates to:
  /// **'Sự kiện mọi khu vực, kiểm chuỗi băm, xuất cho kiểm toán'**
  String get auditLogHint;

  /// No description provided for @auditEvents.
  ///
  /// In vi, this message translates to:
  /// **'Sự kiện'**
  String get auditEvents;

  /// No description provided for @accessLog.
  ///
  /// In vi, this message translates to:
  /// **'Ai đã truy cập'**
  String get accessLog;

  /// No description provided for @verifyChain.
  ///
  /// In vi, this message translates to:
  /// **'Kiểm chuỗi băm'**
  String get verifyChain;

  /// No description provided for @exportAudit.
  ///
  /// In vi, this message translates to:
  /// **'Xuất cho kiểm toán'**
  String get exportAudit;

  /// No description provided for @auditSearch.
  ///
  /// In vi, this message translates to:
  /// **'Tra cứu'**
  String get auditSearch;

  /// No description provided for @chainIntact.
  ///
  /// In vi, this message translates to:
  /// **'Sổ còn nguyên vẹn, không dòng nào bị sửa'**
  String get chainIntact;

  /// No description provided for @exportChecksumHint.
  ///
  /// In vi, this message translates to:
  /// **'Mã SHA-256 của tệp xuất. Bên kiểm toán tính lại mã của tệp nhận được, khác mã này là tệp đã bị sửa.'**
  String get exportChecksumHint;

  /// No description provided for @copyChecksum.
  ///
  /// In vi, this message translates to:
  /// **'Chép mã'**
  String get copyChecksum;

  /// No description provided for @close.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get close;

  /// No description provided for @allRegions.
  ///
  /// In vi, this message translates to:
  /// **'Mọi khu vực'**
  String get allRegions;

  /// No description provided for @errAccessExpired.
  ///
  /// In vi, this message translates to:
  /// **'Quyền kiểm toán của bạn đã hết hạn'**
  String get errAccessExpired;

  /// No description provided for @chainBroken.
  ///
  /// In vi, this message translates to:
  /// **'Chuỗi băm sai từ dòng #{id}'**
  String chainBroken(String id);

  /// No description provided for @chainChecked.
  ///
  /// In vi, this message translates to:
  /// **'Đã kiểm {count} dòng'**
  String chainChecked(int count);

  /// No description provided for @exportDone.
  ///
  /// In vi, this message translates to:
  /// **'Đã xuất {count} dòng'**
  String exportDone(int count);

  /// No description provided for @rowsCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} dòng'**
  String rowsCount(int count);

  /// No description provided for @supplierPurchases.
  ///
  /// In vi, this message translates to:
  /// **'{count} lần mua'**
  String supplierPurchases(int count);

  /// No description provided for @supplierPaidPercent.
  ///
  /// In vi, this message translates to:
  /// **'đã trả {percent}%'**
  String supplierPaidPercent(String percent);

  /// No description provided for @acceptProject.
  ///
  /// In vi, this message translates to:
  /// **'Nghiệm thu'**
  String get acceptProject;

  /// No description provided for @projectInProgress.
  ///
  /// In vi, this message translates to:
  /// **'Đang thi công'**
  String get projectInProgress;

  /// No description provided for @errAlreadyAccepted.
  ///
  /// In vi, this message translates to:
  /// **'Dự án này đã nghiệm thu rồi'**
  String get errAlreadyAccepted;

  /// No description provided for @errFinanceUnavailable.
  ///
  /// In vi, this message translates to:
  /// **'Chưa ghi được doanh thu ở tài chính, dự án chưa đổi trạng thái. Thử lại sau.'**
  String get errFinanceUnavailable;

  /// No description provided for @acceptProjectConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Nghiệm thu dự án và ghi doanh thu {amount} vào tài chính?'**
  String acceptProjectConfirm(String amount);

  /// No description provided for @projectAcceptedOn.
  ///
  /// In vi, this message translates to:
  /// **'Đã nghiệm thu {date}'**
  String projectAcceptedOn(String date);

  /// No description provided for @nProjectAccepted.
  ///
  /// In vi, this message translates to:
  /// **'Dự án {project} đã nghiệm thu, doanh thu đã ghi vào tài chính'**
  String nProjectAccepted(String project);

  /// No description provided for @workConditions.
  ///
  /// In vi, this message translates to:
  /// **'Điều kiện làm việc'**
  String get workConditions;

  /// No description provided for @workHoursSummary.
  ///
  /// In vi, this message translates to:
  /// **'{hours} giờ · tăng ca {overtime} giờ'**
  String workHoursSummary(String hours, String overtime);

  /// No description provided for @noticeQueued.
  ///
  /// In vi, this message translates to:
  /// **'đang chờ gửi'**
  String get noticeQueued;

  /// No description provided for @noticeSent.
  ///
  /// In vi, this message translates to:
  /// **'đã gửi'**
  String get noticeSent;

  /// No description provided for @customerNotice.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận cho khách hàng qua {channel}: {status}'**
  String customerNotice(String channel, String status);

  /// No description provided for @attachCv.
  ///
  /// In vi, this message translates to:
  /// **'Đính kèm CV (PDF, tối đa 10 MB)'**
  String get attachCv;

  /// No description provided for @cvSelected.
  ///
  /// In vi, this message translates to:
  /// **'CV: {name}'**
  String cvSelected(String name);

  /// No description provided for @stageHired.
  ///
  /// In vi, this message translates to:
  /// **'Đã nhận vào làm'**
  String get stageHired;

  /// No description provided for @hireCandidate.
  ///
  /// In vi, this message translates to:
  /// **'Nhận vào làm'**
  String get hireCandidate;

  /// No description provided for @hiredKeepPassword.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu: giữ nguyên mật khẩu người này đang dùng.'**
  String get hiredKeepPassword;

  /// No description provided for @hiredRelogin.
  ///
  /// In vi, this message translates to:
  /// **'Người này đăng xuất rồi đăng nhập lại để vào với vai trò Nhân viên.'**
  String get hiredRelogin;

  /// No description provided for @hireConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Nhận {name} vào làm? Email {email} sẽ là tên đăng nhập của nhân viên mới.'**
  String hireConfirm(String name, String email);

  /// No description provided for @hiredTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đã tạo nhân viên {id}'**
  String hiredTitle(String id);

  /// No description provided for @hiredLogin.
  ///
  /// In vi, this message translates to:
  /// **'Tên đăng nhập: {login}'**
  String hiredLogin(String login);

  /// No description provided for @hiredTempPassword.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu tạm: {password} (chỉ hiện một lần, đổi ở lần đăng nhập đầu)'**
  String hiredTempPassword(String password);

  /// No description provided for @home.
  ///
  /// In vi, this message translates to:
  /// **'Trang chủ'**
  String get home;

  /// No description provided for @sectionMyWork.
  ///
  /// In vi, this message translates to:
  /// **'Công việc của tôi'**
  String get sectionMyWork;

  /// No description provided for @sectionManage.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý'**
  String get sectionManage;

  /// No description provided for @sectionFinance.
  ///
  /// In vi, this message translates to:
  /// **'Tài chính'**
  String get sectionFinance;

  /// No description provided for @sectionAudit.
  ///
  /// In vi, this message translates to:
  /// **'Kiểm toán'**
  String get sectionAudit;

  /// No description provided for @nPayslipIssued.
  ///
  /// In vi, this message translates to:
  /// **'Phiếu lương kỳ {period} của bạn đã có'**
  String nPayslipIssued(String period);

  /// No description provided for @nPayrollNeedsAttention.
  ///
  /// In vi, this message translates to:
  /// **'Chốt lương kỳ {period} cần xử lý tay'**
  String nPayrollNeedsAttention(String period);

  /// No description provided for @errPeriodLocked.
  ///
  /// In vi, this message translates to:
  /// **'Kỳ này đang chốt lương, tạm chưa duyệt được. Thử lại sau ít phút'**
  String get errPeriodLocked;

  /// No description provided for @runNeedsAttention.
  ///
  /// In vi, this message translates to:
  /// **'Cần xử lý tay'**
  String get runNeedsAttention;

  /// No description provided for @stepLockPeriod.
  ///
  /// In vi, this message translates to:
  /// **'Khóa kỳ ở chấm công'**
  String get stepLockPeriod;

  /// No description provided for @stepReserveBudget.
  ///
  /// In vi, this message translates to:
  /// **'Giữ ngân sách lương'**
  String get stepReserveBudget;

  /// No description provided for @stepReleaseBudget.
  ///
  /// In vi, this message translates to:
  /// **'Nhả ngân sách (bù trừ)'**
  String get stepReleaseBudget;

  /// No description provided for @stepRecordExpense.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chi phí lương sang tài chính'**
  String get stepRecordExpense;

  /// No description provided for @stepIssuePayslips.
  ///
  /// In vi, this message translates to:
  /// **'Gửi phiếu lương cho nhân viên'**
  String get stepIssuePayslips;

  /// No description provided for @stepUnlockPeriod.
  ///
  /// In vi, this message translates to:
  /// **'Mở khóa kỳ'**
  String get stepUnlockPeriod;

  /// No description provided for @stepNeedsAttention.
  ///
  /// In vi, this message translates to:
  /// **'Chờ xử lý tay'**
  String get stepNeedsAttention;

  /// No description provided for @knowledge.
  ///
  /// In vi, this message translates to:
  /// **'Kho tri thức'**
  String get knowledge;

  /// No description provided for @knowledgeHint.
  ///
  /// In vi, this message translates to:
  /// **'Quy định lương, nghỉ phép, tăng ca, quy trình'**
  String get knowledgeHint;

  /// No description provided for @knowledgeSearchHint.
  ///
  /// In vi, this message translates to:
  /// **'Tìm, ví dụ: tăng ca, chốt lương'**
  String get knowledgeSearchHint;

  /// No description provided for @knowledgeEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy bài phù hợp'**
  String get knowledgeEmpty;

  /// No description provided for @sectionKnowledge.
  ///
  /// In vi, this message translates to:
  /// **'Tri thức'**
  String get sectionKnowledge;

  /// No description provided for @knowledgeTabAsk.
  ///
  /// In vi, this message translates to:
  /// **'Hỏi AI'**
  String get knowledgeTabAsk;

  /// No description provided for @knowledgeTabSearch.
  ///
  /// In vi, this message translates to:
  /// **'Tìm bài'**
  String get knowledgeTabSearch;

  /// No description provided for @knowledgeTabGraph.
  ///
  /// In vi, this message translates to:
  /// **'Đồ thị'**
  String get knowledgeTabGraph;

  /// No description provided for @askHint.
  ///
  /// In vi, this message translates to:
  /// **'Hỏi về lương, nghỉ phép, chấm công…'**
  String get askHint;

  /// No description provided for @askIntro.
  ///
  /// In vi, this message translates to:
  /// **'Trợ lý trả lời dựa trên kho tri thức và đồ thị tri thức của công ty, kèm nguồn để bạn tự kiểm tra.'**
  String get askIntro;

  /// No description provided for @askExample1.
  ///
  /// In vi, this message translates to:
  /// **'Làm thêm giờ được trả bao nhiêu?'**
  String get askExample1;

  /// No description provided for @askExample2.
  ///
  /// In vi, this message translates to:
  /// **'Ai duyệt đơn nghỉ phép của tôi?'**
  String get askExample2;

  /// No description provided for @askExample3.
  ///
  /// In vi, this message translates to:
  /// **'Vì sao không duyệt được đơn khi đang chốt lương?'**
  String get askExample3;

  /// No description provided for @askExample4.
  ///
  /// In vi, this message translates to:
  /// **'Dữ liệu cá nhân của tôi được bảo vệ thế nào?'**
  String get askExample4;

  /// No description provided for @askThinking.
  ///
  /// In vi, this message translates to:
  /// **'Đang tìm trong kho tri thức…'**
  String get askThinking;

  /// No description provided for @askSources.
  ///
  /// In vi, this message translates to:
  /// **'Nguồn'**
  String get askSources;

  /// No description provided for @askGraphFacts.
  ///
  /// In vi, this message translates to:
  /// **'Dựa trên đồ thị tri thức'**
  String get askGraphFacts;

  /// No description provided for @askAnsweredBy.
  ///
  /// In vi, this message translates to:
  /// **'Trả lời bởi {model}'**
  String askAnsweredBy(String model);

  /// No description provided for @askNoAi.
  ///
  /// In vi, this message translates to:
  /// **'Không dùng AI, trích trực tiếp từ kho'**
  String get askNoAi;

  /// No description provided for @askCached.
  ///
  /// In vi, this message translates to:
  /// **'đã lưu sẵn'**
  String get askCached;

  /// No description provided for @askHelpful.
  ///
  /// In vi, this message translates to:
  /// **'Hữu ích'**
  String get askHelpful;

  /// No description provided for @askNotHelpful.
  ///
  /// In vi, this message translates to:
  /// **'Chưa đúng'**
  String get askNotHelpful;

  /// No description provided for @askThanks.
  ///
  /// In vi, this message translates to:
  /// **'Cảm ơn góp ý của bạn'**
  String get askThanks;

  /// No description provided for @askFailed.
  ///
  /// In vi, this message translates to:
  /// **'Chưa gửi được câu hỏi'**
  String get askFailed;

  /// No description provided for @askNewChat.
  ///
  /// In vi, this message translates to:
  /// **'Cuộc trò chuyện mới'**
  String get askNewChat;

  /// No description provided for @askSend.
  ///
  /// In vi, this message translates to:
  /// **'Gửi'**
  String get askSend;

  /// No description provided for @askViaKeyword.
  ///
  /// In vi, this message translates to:
  /// **'từ khóa'**
  String get askViaKeyword;

  /// No description provided for @askViaSemantic.
  ///
  /// In vi, this message translates to:
  /// **'theo nghĩa'**
  String get askViaSemantic;

  /// No description provided for @askViaGraph.
  ///
  /// In vi, this message translates to:
  /// **'đồ thị'**
  String get askViaGraph;

  /// No description provided for @graphSearchHint.
  ///
  /// In vi, this message translates to:
  /// **'Tìm khái niệm, ví dụ: tăng ca'**
  String get graphSearchHint;

  /// No description provided for @graphRelated.
  ///
  /// In vi, this message translates to:
  /// **'Liên kết'**
  String get graphRelated;

  /// No description provided for @graphReadArticle.
  ///
  /// In vi, this message translates to:
  /// **'Đọc bài'**
  String get graphReadArticle;

  /// No description provided for @graphAskAbout.
  ///
  /// In vi, this message translates to:
  /// **'Hỏi AI về mục này'**
  String get graphAskAbout;

  /// No description provided for @graphAskTemplate.
  ///
  /// In vi, this message translates to:
  /// **'Giải thích giúp tôi về {topic}'**
  String graphAskTemplate(String topic);

  /// No description provided for @graphTypeConcept.
  ///
  /// In vi, this message translates to:
  /// **'Khái niệm'**
  String get graphTypeConcept;

  /// No description provided for @graphTypeProcess.
  ///
  /// In vi, this message translates to:
  /// **'Quy trình'**
  String get graphTypeProcess;

  /// No description provided for @graphTypeStep.
  ///
  /// In vi, this message translates to:
  /// **'Bước'**
  String get graphTypeStep;

  /// No description provided for @graphTypeRule.
  ///
  /// In vi, this message translates to:
  /// **'Quy tắc'**
  String get graphTypeRule;

  /// No description provided for @graphTypeRole.
  ///
  /// In vi, this message translates to:
  /// **'Vai trò'**
  String get graphTypeRole;

  /// No description provided for @graphTypeService.
  ///
  /// In vi, this message translates to:
  /// **'Service'**
  String get graphTypeService;

  /// No description provided for @graphTypeRegion.
  ///
  /// In vi, this message translates to:
  /// **'Quốc gia'**
  String get graphTypeRegion;

  /// No description provided for @graphTypeDocument.
  ///
  /// In vi, this message translates to:
  /// **'Bài viết'**
  String get graphTypeDocument;

  /// No description provided for @knowledgeMore.
  ///
  /// In vi, this message translates to:
  /// **'Thêm'**
  String get knowledgeMore;

  /// No description provided for @ontologyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bản thể học'**
  String get ontologyTitle;

  /// No description provided for @ontologyClasses.
  ///
  /// In vi, this message translates to:
  /// **'Cây lớp'**
  String get ontologyClasses;

  /// No description provided for @ontologyRelations.
  ///
  /// In vi, this message translates to:
  /// **'Quan hệ'**
  String get ontologyRelations;

  /// No description provided for @ontologyRules.
  ///
  /// In vi, this message translates to:
  /// **'Luật suy luận'**
  String get ontologyRules;

  /// No description provided for @ontologyTotals.
  ///
  /// In vi, this message translates to:
  /// **'{nodes} nút · {asserted} cạnh có sẵn · {extracted} cạnh AI trích · {inferred} cạnh suy ra'**
  String ontologyTotals(int nodes, int asserted, int extracted, int inferred);

  /// No description provided for @ontologyReasoning.
  ///
  /// In vi, this message translates to:
  /// **'Lần suy luận gần nhất: {count} cạnh mới trong {ms} ms'**
  String ontologyReasoning(int count, int ms);

  /// No description provided for @ontologyRerun.
  ///
  /// In vi, this message translates to:
  /// **'Chạy lại suy luận'**
  String get ontologyRerun;

  /// No description provided for @ontologyTransitive.
  ///
  /// In vi, this message translates to:
  /// **'bắc cầu'**
  String get ontologyTransitive;

  /// No description provided for @ontologySymmetric.
  ///
  /// In vi, this message translates to:
  /// **'đối xứng'**
  String get ontologySymmetric;

  /// No description provided for @ontologyInverse.
  ///
  /// In vi, this message translates to:
  /// **'ngược của {name}'**
  String ontologyInverse(String name);

  /// No description provided for @ontologySubProperty.
  ///
  /// In vi, this message translates to:
  /// **'kéo theo {name}'**
  String ontologySubProperty(String name);

  /// No description provided for @ontologyDerived.
  ///
  /// In vi, this message translates to:
  /// **'chỉ do suy luận'**
  String get ontologyDerived;

  /// No description provided for @ontologyEdgeCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} cạnh'**
  String ontologyEdgeCount(int count);

  /// No description provided for @ontologyExport.
  ///
  /// In vi, this message translates to:
  /// **'Xuất RDF/OWL dạng Turtle tại /knowledge/ontology?format=turtle, mở được bằng Protégé.'**
  String get ontologyExport;

  /// No description provided for @sparqlTitle.
  ///
  /// In vi, this message translates to:
  /// **'Truy vấn SPARQL'**
  String get sparqlTitle;

  /// No description provided for @sparqlHint.
  ///
  /// In vi, this message translates to:
  /// **'Viết câu SELECT hoặc chọn câu mẫu'**
  String get sparqlHint;

  /// No description provided for @sparqlRun.
  ///
  /// In vi, this message translates to:
  /// **'Chạy'**
  String get sparqlRun;

  /// No description provided for @sparqlIncludeInferred.
  ///
  /// In vi, this message translates to:
  /// **'Tính cả cạnh suy luận'**
  String get sparqlIncludeInferred;

  /// No description provided for @sparqlNoRows.
  ///
  /// In vi, this message translates to:
  /// **'Không có kết quả'**
  String get sparqlNoRows;

  /// No description provided for @sparqlRows.
  ///
  /// In vi, this message translates to:
  /// **'{count} dòng · {ms} ms'**
  String sparqlRows(int count, int ms);

  /// No description provided for @sparqlError.
  ///
  /// In vi, this message translates to:
  /// **'Câu truy vấn lỗi: {message}'**
  String sparqlError(String message);

  /// No description provided for @sparqlSampleInvolves.
  ///
  /// In vi, this message translates to:
  /// **'Chốt lương cần service nào'**
  String get sparqlSampleInvolves;

  /// No description provided for @sparqlSampleViewers.
  ///
  /// In vi, this message translates to:
  /// **'Ai được xem lương thực nhận'**
  String get sparqlSampleViewers;

  /// No description provided for @sparqlSampleBefore.
  ///
  /// In vi, this message translates to:
  /// **'Bước nào trước bước chi ngân hàng'**
  String get sparqlSampleBefore;

  /// No description provided for @sparqlSampleRabbit.
  ///
  /// In vi, this message translates to:
  /// **'Service nào dùng RabbitMQ'**
  String get sparqlSampleRabbit;

  /// No description provided for @sparqlSampleCount.
  ///
  /// In vi, this message translates to:
  /// **'Đếm service mỗi nơi'**
  String get sparqlSampleCount;

  /// No description provided for @proposalsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đề xuất từ AI'**
  String get proposalsTitle;

  /// No description provided for @proposalsRun.
  ///
  /// In vi, this message translates to:
  /// **'Cho AI đọc bài mới'**
  String get proposalsRun;

  /// No description provided for @proposalsRunning.
  ///
  /// In vi, this message translates to:
  /// **'AI đang đọc bài viết…'**
  String get proposalsRunning;

  /// No description provided for @proposalsQueued.
  ///
  /// In vi, this message translates to:
  /// **'AI sẽ đọc {count} bài'**
  String proposalsQueued(int count);

  /// No description provided for @proposalsNoAi.
  ///
  /// In vi, this message translates to:
  /// **'Chưa cấu hình AI cho việc trích xuất'**
  String get proposalsNoAi;

  /// No description provided for @proposalsPending.
  ///
  /// In vi, this message translates to:
  /// **'Chờ duyệt'**
  String get proposalsPending;

  /// No description provided for @proposalsInvalid.
  ///
  /// In vi, this message translates to:
  /// **'Không hợp lệ'**
  String get proposalsInvalid;

  /// No description provided for @proposalsApproved.
  ///
  /// In vi, this message translates to:
  /// **'Đã duyệt'**
  String get proposalsApproved;

  /// No description provided for @proposalsRejected.
  ///
  /// In vi, this message translates to:
  /// **'Đã bỏ'**
  String get proposalsRejected;

  /// No description provided for @proposalsEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Không có đề xuất'**
  String get proposalsEmpty;

  /// No description provided for @proposalNewNode.
  ///
  /// In vi, this message translates to:
  /// **'Nút mới'**
  String get proposalNewNode;

  /// No description provided for @proposalFrom.
  ///
  /// In vi, this message translates to:
  /// **'Trích từ bài {article}'**
  String proposalFrom(String article);

  /// No description provided for @proposalApprove.
  ///
  /// In vi, this message translates to:
  /// **'Duyệt'**
  String get proposalApprove;

  /// No description provided for @proposalReject.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ'**
  String get proposalReject;

  /// No description provided for @proposalApproved.
  ///
  /// In vi, this message translates to:
  /// **'Đã thêm vào đồ thị, máy đang suy luận lại'**
  String get proposalApproved;

  /// No description provided for @proposalRejected.
  ///
  /// In vi, this message translates to:
  /// **'Đã bỏ đề xuất'**
  String get proposalRejected;

  /// No description provided for @proposalConfidence.
  ///
  /// In vi, this message translates to:
  /// **'Độ tin cậy {percent}%'**
  String proposalConfidence(int percent);

  /// No description provided for @proposalReasonEvidence.
  ///
  /// In vi, this message translates to:
  /// **'Câu trích không có trong bài'**
  String get proposalReasonEvidence;

  /// No description provided for @proposalReasonConfidence.
  ///
  /// In vi, this message translates to:
  /// **'AI không chắc chắn'**
  String get proposalReasonConfidence;

  /// No description provided for @proposalReasonOntology.
  ///
  /// In vi, this message translates to:
  /// **'Sai miền hoặc phạm vi của quan hệ ({code})'**
  String proposalReasonOntology(String code);

  /// No description provided for @proposalReasonUnused.
  ///
  /// In vi, this message translates to:
  /// **'Nút không dùng trong cạnh hợp lệ nào'**
  String get proposalReasonUnused;

  /// No description provided for @proposalReasonOther.
  ///
  /// In vi, this message translates to:
  /// **'Lý do: {code}'**
  String proposalReasonOther(String code);

  /// No description provided for @graphInferred.
  ///
  /// In vi, this message translates to:
  /// **'Suy ra'**
  String get graphInferred;

  /// No description provided for @graphInferredBy.
  ///
  /// In vi, this message translates to:
  /// **'Máy suy ra bằng luật: {rule}'**
  String graphInferredBy(String rule);

  /// No description provided for @graphBecause.
  ///
  /// In vi, this message translates to:
  /// **'Vì'**
  String get graphBecause;

  /// No description provided for @graphEvidence.
  ///
  /// In vi, this message translates to:
  /// **'AI trích từ bài viết, HR đã duyệt:'**
  String get graphEvidence;

  /// No description provided for @graphGoTo.
  ///
  /// In vi, this message translates to:
  /// **'Mở nút này'**
  String get graphGoTo;

  /// No description provided for @graphPathTo.
  ///
  /// In vi, this message translates to:
  /// **'Nối tới…'**
  String get graphPathTo;

  /// No description provided for @graphPathTitle.
  ///
  /// In vi, this message translates to:
  /// **'Từ {from} tới {to}'**
  String graphPathTitle(String from, String to);

  /// No description provided for @graphPathNone.
  ///
  /// In vi, this message translates to:
  /// **'Không nối được trong 6 bước'**
  String get graphPathNone;

  /// No description provided for @graphPathPick.
  ///
  /// In vi, this message translates to:
  /// **'Chọn khái niệm cần nối tới'**
  String get graphPathPick;

  /// No description provided for @graphTypeTechnology.
  ///
  /// In vi, this message translates to:
  /// **'Công nghệ'**
  String get graphTypeTechnology;

  /// No description provided for @graphTypePattern.
  ///
  /// In vi, this message translates to:
  /// **'Mẫu kiến trúc'**
  String get graphTypePattern;

  /// No description provided for @todoTitle.
  ///
  /// In vi, this message translates to:
  /// **'Việc cần xử lý'**
  String get todoTitle;

  /// No description provided for @todoLeaves.
  ///
  /// In vi, this message translates to:
  /// **'{count} đơn nghỉ chờ duyệt'**
  String todoLeaves(int count);

  /// No description provided for @todoOvertime.
  ///
  /// In vi, this message translates to:
  /// **'{count} đơn tăng ca chờ duyệt'**
  String todoOvertime(int count);

  /// No description provided for @todoCandidates.
  ///
  /// In vi, this message translates to:
  /// **'{count} hồ sơ ứng viên mới'**
  String todoCandidates(int count);

  /// No description provided for @todoNone.
  ///
  /// In vi, this message translates to:
  /// **'Không có việc nào đang chờ'**
  String get todoNone;

  /// No description provided for @signOutConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất khỏi TBT Center?'**
  String get signOutConfirm;

  /// No description provided for @stepErrorTimeout.
  ///
  /// In vi, this message translates to:
  /// **'Kênh thanh toán không phản hồi kịp; hệ thống đối soát theo mã tham chiếu trước khi chi lại'**
  String get stepErrorTimeout;

  /// No description provided for @stepErrorGeneric.
  ///
  /// In vi, this message translates to:
  /// **'Bước này không chạy được; bấm Chạy lại hoặc báo bộ phận kỹ thuật'**
  String get stepErrorGeneric;

  /// No description provided for @errSparqlSyntax.
  ///
  /// In vi, this message translates to:
  /// **'Câu truy vấn chưa đúng cú pháp. Kiểm tra lại dấu ngoặc, dấu chấm cuối mỗi điều kiện và tên tiền tố (kg:, kgo:).'**
  String get errSparqlSyntax;

  /// No description provided for @appearance.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện'**
  String get appearance;

  /// No description provided for @themeSystem.
  ///
  /// In vi, this message translates to:
  /// **'Theo điện thoại'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In vi, this message translates to:
  /// **'Sáng'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In vi, this message translates to:
  /// **'Tối'**
  String get themeDark;

  /// No description provided for @payoutCompany.
  ///
  /// In vi, this message translates to:
  /// **'Công ty'**
  String get payoutCompany;

  /// No description provided for @payoutPayRegion.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển lương {region}'**
  String payoutPayRegion(String region);

  /// No description provided for @payoutPayGroup.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển cả tập đoàn'**
  String get payoutPayGroup;

  /// No description provided for @payoutPaySelected.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển cho {count} người'**
  String payoutPaySelected(int count);

  /// No description provided for @payoutConfirmTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển lương kỳ {period}?'**
  String payoutConfirmTitle(String period);

  /// No description provided for @payoutConfirmRegion.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển cho nhân viên công ty {region}. Ai đã nhận rồi sẽ được hỏi lại trước khi chuyển.'**
  String payoutConfirmRegion(String region);

  /// No description provided for @payoutConfirmGroup.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển cho nhân viên của cả {count} công ty. Ai đã nhận rồi sẽ được hỏi lại trước khi chuyển.'**
  String payoutConfirmGroup(int count);

  /// No description provided for @payoutConfirmPeople.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển cho {count} người đã chọn ở công ty {region}.'**
  String payoutConfirmPeople(int count, String region);

  /// No description provided for @payoutConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển'**
  String get payoutConfirm;

  /// No description provided for @payoutDuplicateTitle.
  ///
  /// In vi, this message translates to:
  /// **'Có người đã nhận lương kỳ này'**
  String get payoutDuplicateTitle;

  /// No description provided for @payoutDuplicateBody.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển lại sẽ chi thêm một lần nữa cho những người này. Lựa chọn nào cũng được ghi vào nhật ký.'**
  String get payoutDuplicateBody;

  /// No description provided for @payoutDuplicateRegion.
  ///
  /// In vi, this message translates to:
  /// **'{region}: {count} người đã nhận'**
  String payoutDuplicateRegion(String region, int count);

  /// No description provided for @payoutDuplicatePerson.
  ///
  /// In vi, this message translates to:
  /// **'{employee} · đã nhận {count} lần'**
  String payoutDuplicatePerson(String employee, int count);

  /// No description provided for @payoutSkipPaid.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ qua người đã nhận'**
  String get payoutSkipPaid;

  /// No description provided for @payoutResend.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển lại'**
  String get payoutResend;

  /// No description provided for @payoutTabPeople.
  ///
  /// In vi, this message translates to:
  /// **'Nhân viên'**
  String get payoutTabPeople;

  /// No description provided for @payoutTabRuns.
  ///
  /// In vi, this message translates to:
  /// **'Các đợt'**
  String get payoutTabRuns;

  /// No description provided for @payoutTabLog.
  ///
  /// In vi, this message translates to:
  /// **'Nhật ký'**
  String get payoutTabLog;

  /// No description provided for @payoutUnpaid.
  ///
  /// In vi, this message translates to:
  /// **'Chưa chuyển'**
  String get payoutUnpaid;

  /// No description provided for @payoutPaidTimes.
  ///
  /// In vi, this message translates to:
  /// **'Đã chuyển {count} lần'**
  String payoutPaidTimes(int count);

  /// No description provided for @payoutNotCalculated.
  ///
  /// In vi, this message translates to:
  /// **'Kỳ này chưa chốt lương. Hãy chuyển cho cả công ty trước.'**
  String get payoutNotCalculated;

  /// No description provided for @payoutResultTitle.
  ///
  /// In vi, this message translates to:
  /// **'Kết quả chuyển lương'**
  String get payoutResultTitle;

  /// No description provided for @payoutResultSummary.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển {paid} · chuyển lại {resent} · bỏ qua {skipped}'**
  String payoutResultSummary(int paid, int resent, int skipped);

  /// No description provided for @payoutResultFailed.
  ///
  /// In vi, this message translates to:
  /// **'{count} khoản chưa chuyển được, hãy thử lại sau'**
  String payoutResultFailed(int count);

  /// No description provided for @payoutResultMissing.
  ///
  /// In vi, this message translates to:
  /// **'{count} người chưa có phiếu lương kỳ này'**
  String payoutResultMissing(int count);

  /// No description provided for @payoutStarted.
  ///
  /// In vi, this message translates to:
  /// **'Đã bắt đầu chốt kỳ và chuyển lương'**
  String get payoutStarted;

  /// No description provided for @payoutRetried.
  ///
  /// In vi, this message translates to:
  /// **'Đang chuyển nốt phần chưa chuyển'**
  String get payoutRetried;

  /// No description provided for @payoutBusy.
  ///
  /// In vi, this message translates to:
  /// **'Kỳ này đang chốt hoặc đang chuyển, chờ xong rồi thử lại'**
  String get payoutBusy;

  /// No description provided for @payoutUnreachable.
  ///
  /// In vi, this message translates to:
  /// **'Không kết nối được máy chủ công ty này'**
  String get payoutUnreachable;

  /// No description provided for @payoutNothing.
  ///
  /// In vi, this message translates to:
  /// **'Không có khoản nào phải chuyển'**
  String get payoutNothing;

  /// No description provided for @payoutAmountHidden.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền chỉ xem được trong công ty đó'**
  String get payoutAmountHidden;

  /// No description provided for @payoutLogPaid.
  ///
  /// In vi, this message translates to:
  /// **'Đã chuyển'**
  String get payoutLogPaid;

  /// No description provided for @payoutLogResent.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển lại'**
  String get payoutLogResent;

  /// No description provided for @payoutLogSkipped.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ qua vì đã nhận'**
  String get payoutLogSkipped;

  /// No description provided for @payoutLogWarned.
  ///
  /// In vi, this message translates to:
  /// **'Cảnh báo chuyển trùng'**
  String get payoutLogWarned;

  /// No description provided for @payoutLogFailed.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển không được'**
  String get payoutLogFailed;

  /// No description provided for @payoutLogSaga.
  ///
  /// In vi, this message translates to:
  /// **'Chốt lương tự động'**
  String get payoutLogSaga;

  /// No description provided for @payoutLogLine.
  ///
  /// In vi, this message translates to:
  /// **'{actor} · {time}'**
  String payoutLogLine(String actor, String time);

  /// No description provided for @noPayoutLog.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có lần chuyển nào'**
  String get noPayoutLog;

  /// No description provided for @errPayoutFailed.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển lương bị gián đoạn. Khoản đã chuyển vẫn được ghi lại, hãy thử lại sau.'**
  String get errPayoutFailed;

  /// No description provided for @payoutAccepted.
  ///
  /// In vi, this message translates to:
  /// **'Đang chuyển {count} khoản, xem tiến độ ở tab Nhật ký'**
  String payoutAccepted(int count);

  /// No description provided for @payoutLogInDoubt.
  ///
  /// In vi, this message translates to:
  /// **'Chưa rõ, cần đối soát'**
  String get payoutLogInDoubt;

  /// No description provided for @manualIpButton.
  ///
  /// In vi, this message translates to:
  /// **'Change Manual IP'**
  String get manualIpButton;

  /// No description provided for @manualIpTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đổi IP thủ công'**
  String get manualIpTitle;

  /// No description provided for @manualIpHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập IP công khai để giả lập đang ở nước đó: app dò khu vực lưu hồ sơ và ngôn ngữ theo IP này. Để trống để dùng IP thật.'**
  String get manualIpHint;

  /// No description provided for @manualIpCurrent.
  ///
  /// In vi, this message translates to:
  /// **'Khu vực đang nhận: {region}'**
  String manualIpCurrent(String region);

  /// No description provided for @manualIpInvalid.
  ///
  /// In vi, this message translates to:
  /// **'IP không hợp lệ'**
  String get manualIpInvalid;

  /// No description provided for @manualIpSaved.
  ///
  /// In vi, this message translates to:
  /// **'Đang giả lập IP {ip}'**
  String manualIpSaved(String ip);

  /// No description provided for @manualIpCleared.
  ///
  /// In vi, this message translates to:
  /// **'Đã dùng lại IP thật'**
  String get manualIpCleared;

  /// No description provided for @manualIpReset.
  ///
  /// In vi, this message translates to:
  /// **'Dùng IP thật'**
  String get manualIpReset;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'pt', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
