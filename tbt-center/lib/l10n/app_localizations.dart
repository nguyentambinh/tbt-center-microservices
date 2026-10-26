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

  /// No description provided for @moreNotifications.
  ///
  /// In vi, this message translates to:
  /// **'và {count} thông báo khác'**
  String moreNotifications(int count);

  /// No description provided for @filterAll.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get filterAll;

  /// No description provided for @filterStatus.
  ///
  /// In vi, this message translates to:
  /// **'Trạng thái'**
  String get filterStatus;

  /// No description provided for @filterType.
  ///
  /// In vi, this message translates to:
  /// **'Loại'**
  String get filterType;

  /// No description provided for @filterRead.
  ///
  /// In vi, this message translates to:
  /// **'Đã đọc'**
  String get filterRead;

  /// No description provided for @filterUnread.
  ///
  /// In vi, this message translates to:
  /// **'Chưa đọc'**
  String get filterUnread;

  /// No description provided for @profileTab.
  ///
  /// In vi, this message translates to:
  /// **'Cá nhân'**
  String get profileTab;

  /// No description provided for @myProfile.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin cá nhân'**
  String get myProfile;

  /// No description provided for @proposeChange.
  ///
  /// In vi, this message translates to:
  /// **'Đề xuất sửa thông tin'**
  String get proposeChange;

  /// No description provided for @proposeChangeHint.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ sửa ô cần đổi. HR duyệt xong thông tin mới được cập nhật.'**
  String get proposeChangeHint;

  /// No description provided for @changeReason.
  ///
  /// In vi, this message translates to:
  /// **'Lý do (không bắt buộc)'**
  String get changeReason;

  /// No description provided for @sendRequest.
  ///
  /// In vi, this message translates to:
  /// **'Gửi đề xuất'**
  String get sendRequest;

  /// No description provided for @changeRequestSent.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi đề xuất, chờ HR duyệt'**
  String get changeRequestSent;

  /// No description provided for @changeRequestPending.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đang có một đề xuất chờ HR duyệt'**
  String get changeRequestPending;

  /// No description provided for @changeRequestNoChange.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa sửa ô nào'**
  String get changeRequestNoChange;

  /// No description provided for @changeHistory.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử đề xuất'**
  String get changeHistory;

  /// No description provided for @changeRequests.
  ///
  /// In vi, this message translates to:
  /// **'Đề xuất sửa hồ sơ'**
  String get changeRequests;

  /// No description provided for @changeRequestsHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhân viên đề xuất sửa thông tin cá nhân'**
  String get changeRequestsHint;

  /// No description provided for @pendingChangeRequests.
  ///
  /// In vi, this message translates to:
  /// **'{count} đề xuất sửa hồ sơ'**
  String pendingChangeRequests(int count);

  /// No description provided for @noChangeRequests.
  ///
  /// In vi, this message translates to:
  /// **'Không có đề xuất nào'**
  String get noChangeRequests;

  /// No description provided for @oldValue.
  ///
  /// In vi, this message translates to:
  /// **'Cũ'**
  String get oldValue;

  /// No description provided for @newValue.
  ///
  /// In vi, this message translates to:
  /// **'Mới'**
  String get newValue;

  /// No description provided for @decisionNote.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú cho nhân viên (không bắt buộc)'**
  String get decisionNote;

  /// No description provided for @fieldFacebook.
  ///
  /// In vi, this message translates to:
  /// **'Facebook'**
  String get fieldFacebook;

  /// No description provided for @fieldXHandle.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản X'**
  String get fieldXHandle;

  /// No description provided for @accountInfo.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản'**
  String get accountInfo;

  /// No description provided for @nProfileChangeRequested.
  ///
  /// In vi, this message translates to:
  /// **'{employee} đề xuất sửa thông tin cá nhân'**
  String nProfileChangeRequested(String employee);

  /// No description provided for @nProfileChangeApproved.
  ///
  /// In vi, this message translates to:
  /// **'HR đã duyệt đề xuất sửa thông tin của bạn'**
  String get nProfileChangeApproved;

  /// No description provided for @nProfileChangeRejected.
  ///
  /// In vi, this message translates to:
  /// **'HR từ chối đề xuất sửa thông tin: {note}'**
  String nProfileChangeRejected(String note);

  /// No description provided for @invalidAmount.
  ///
  /// In vi, this message translates to:
  /// **'Giá trị không hợp lệ'**
  String get invalidAmount;

  /// No description provided for @invalidEmail.
  ///
  /// In vi, this message translates to:
  /// **'Email không hợp lệ'**
  String get invalidEmail;

  /// No description provided for @todoProfileChanges.
  ///
  /// In vi, this message translates to:
  /// **'{count} đề xuất sửa hồ sơ'**
  String todoProfileChanges(int count);

  /// No description provided for @departments.
  ///
  /// In vi, this message translates to:
  /// **'Phòng ban'**
  String get departments;

  /// No description provided for @departmentsHint.
  ///
  /// In vi, this message translates to:
  /// **'Điều chuyển, trưởng phòng, giải thể'**
  String get departmentsHint;

  /// No description provided for @departmentAdd.
  ///
  /// In vi, this message translates to:
  /// **'Thêm phòng ban'**
  String get departmentAdd;

  /// No description provided for @departmentName.
  ///
  /// In vi, this message translates to:
  /// **'Tên phòng ban'**
  String get departmentName;

  /// No description provided for @departmentNameTaken.
  ///
  /// In vi, this message translates to:
  /// **'Công ty này đã có phòng ban cùng tên'**
  String get departmentNameTaken;

  /// No description provided for @departmentCreated.
  ///
  /// In vi, this message translates to:
  /// **'Đã thêm phòng {name}'**
  String departmentCreated(String name);

  /// No description provided for @departmentEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Phòng ban chưa có ai'**
  String get departmentEmpty;

  /// No description provided for @departmentHead.
  ///
  /// In vi, this message translates to:
  /// **'Trưởng phòng'**
  String get departmentHead;

  /// No description provided for @departmentHeadIs.
  ///
  /// In vi, this message translates to:
  /// **'Trưởng phòng: {name}'**
  String departmentHeadIs(String name);

  /// No description provided for @departmentMembers.
  ///
  /// In vi, this message translates to:
  /// **'{count} người'**
  String departmentMembers(int count);

  /// No description provided for @noHead.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có trưởng phòng'**
  String get noHead;

  /// No description provided for @noDepartments.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có phòng ban nào'**
  String get noDepartments;

  /// No description provided for @sortedByHours.
  ///
  /// In vi, this message translates to:
  /// **'Trưởng phòng đứng đầu, còn lại theo tổng giờ làm'**
  String get sortedByHours;

  /// No description provided for @setHead.
  ///
  /// In vi, this message translates to:
  /// **'Giao làm trưởng phòng'**
  String get setHead;

  /// No description provided for @headAssigned.
  ///
  /// In vi, this message translates to:
  /// **'{name} đã làm trưởng phòng'**
  String headAssigned(String name);

  /// No description provided for @moveToDepartment.
  ///
  /// In vi, this message translates to:
  /// **'Điều chuyển sang phòng khác'**
  String get moveToDepartment;

  /// No description provided for @moveHere.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển vào phòng'**
  String get moveHere;

  /// No description provided for @transferDone.
  ///
  /// In vi, this message translates to:
  /// **'Đã chuyển sang {name}'**
  String transferDone(String name);

  /// No description provided for @addMembers.
  ///
  /// In vi, this message translates to:
  /// **'Thêm người vào phòng'**
  String get addMembers;

  /// No description provided for @addMembersFrom.
  ///
  /// In vi, this message translates to:
  /// **'Lấy người từ phòng nào?'**
  String get addMembersFrom;

  /// No description provided for @addMembersTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển vào {name}'**
  String addMembersTitle(String name);

  /// No description provided for @membersMoved.
  ///
  /// In vi, this message translates to:
  /// **'Đã chuyển {count} người'**
  String membersMoved(int count);

  /// No description provided for @membersMovedPartly.
  ///
  /// In vi, this message translates to:
  /// **'Đã chuyển {moved} người, {failed} người không chuyển được'**
  String membersMovedPartly(int moved, int failed);

  /// No description provided for @dissolveDepartment.
  ///
  /// In vi, this message translates to:
  /// **'Giải thể phòng ban'**
  String get dissolveDepartment;

  /// No description provided for @dissolveTitle.
  ///
  /// In vi, this message translates to:
  /// **'Giải thể {name}?'**
  String dissolveTitle(String name);

  /// No description provided for @dissolveReason.
  ///
  /// In vi, this message translates to:
  /// **'Lý do giải thể'**
  String get dissolveReason;

  /// No description provided for @dissolveNoLongerNeeded.
  ///
  /// In vi, this message translates to:
  /// **'Không còn nhu cầu'**
  String get dissolveNoLongerNeeded;

  /// No description provided for @dissolveRestructured.
  ///
  /// In vi, this message translates to:
  /// **'Cơ cấu lại hoặc sáp nhập'**
  String get dissolveRestructured;

  /// No description provided for @dissolveUnderperforming.
  ///
  /// In vi, this message translates to:
  /// **'Hoạt động kém hiệu quả'**
  String get dissolveUnderperforming;

  /// No description provided for @dissolveOutsourced.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển sang thuê ngoài'**
  String get dissolveOutsourced;

  /// No description provided for @dissolveBusinessClosed.
  ///
  /// In vi, this message translates to:
  /// **'Thu hẹp hoặc đóng cửa mảng kinh doanh'**
  String get dissolveBusinessClosed;

  /// No description provided for @dissolveMembersMove.
  ///
  /// In vi, this message translates to:
  /// **'Phòng còn {count} người, chọn phòng nhận lại họ'**
  String dissolveMembersMove(int count);

  /// No description provided for @chooseReceivingDepartment.
  ///
  /// In vi, this message translates to:
  /// **'Chọn phòng nhận'**
  String get chooseReceivingDepartment;

  /// No description provided for @dissolveConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Giải thể'**
  String get dissolveConfirm;

  /// No description provided for @dissolveDone.
  ///
  /// In vi, this message translates to:
  /// **'Đã giải thể {name}'**
  String dissolveDone(String name);

  /// No description provided for @unassignedStaff.
  ///
  /// In vi, this message translates to:
  /// **'Người mới chưa có phòng'**
  String get unassignedStaff;

  /// No description provided for @unassignedCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} người mới chưa có phòng ban'**
  String unassignedCount(int count);

  /// No description provided for @unassignedHint.
  ///
  /// In vi, this message translates to:
  /// **'Để AI gợi ý xếp phòng hoặc lập phòng mới'**
  String get unassignedHint;

  /// No description provided for @noUnassigned.
  ///
  /// In vi, this message translates to:
  /// **'Ai cũng đã có phòng ban'**
  String get noUnassigned;

  /// No description provided for @aiSuggestPlacement.
  ///
  /// In vi, this message translates to:
  /// **'AI gợi ý xếp phòng'**
  String get aiSuggestPlacement;

  /// No description provided for @aiThinking.
  ///
  /// In vi, this message translates to:
  /// **'AI đang xem xét...'**
  String get aiThinking;

  /// No description provided for @suggestionByAi.
  ///
  /// In vi, this message translates to:
  /// **'Gợi ý do AI đưa ra, HR quyết định cuối cùng'**
  String get suggestionByAi;

  /// No description provided for @suggestionByRules.
  ///
  /// In vi, this message translates to:
  /// **'AI đang bận, gợi ý theo chức vụ trùng nhiều nhất'**
  String get suggestionByRules;

  /// No description provided for @suggestedDepartment.
  ///
  /// In vi, this message translates to:
  /// **'Gợi ý: {name}'**
  String suggestedDepartment(String name);

  /// No description provided for @acceptSuggestion.
  ///
  /// In vi, this message translates to:
  /// **'Đồng ý'**
  String get acceptSuggestion;

  /// No description provided for @chooseOther.
  ///
  /// In vi, this message translates to:
  /// **'Chọn phòng khác'**
  String get chooseOther;

  /// No description provided for @chooseDepartment.
  ///
  /// In vi, this message translates to:
  /// **'Chọn phòng ban'**
  String get chooseDepartment;

  /// No description provided for @newDepartmentProposals.
  ///
  /// In vi, this message translates to:
  /// **'Đề xuất lập phòng mới'**
  String get newDepartmentProposals;

  /// No description provided for @createDepartmentAndMove.
  ///
  /// In vi, this message translates to:
  /// **'Lập phòng và chuyển người'**
  String get createDepartmentAndMove;

  /// No description provided for @rankings.
  ///
  /// In vi, this message translates to:
  /// **'Nhân viên xuất sắc'**
  String get rankings;

  /// No description provided for @rankingsHint.
  ///
  /// In vi, this message translates to:
  /// **'Xếp hạng theo giờ làm, đề cử thăng chức'**
  String get rankingsHint;

  /// No description provided for @rankingFormula.
  ///
  /// In vi, this message translates to:
  /// **'Điểm = giờ thường + 1,5 × giờ tăng ca + 2 × số ngày công'**
  String get rankingFormula;

  /// No description provided for @rankingDetail.
  ///
  /// In vi, this message translates to:
  /// **'{work} giờ · {overtime} giờ tăng ca · {days} ngày'**
  String rankingDetail(String work, String overtime, int days);

  /// No description provided for @points.
  ///
  /// In vi, this message translates to:
  /// **'điểm'**
  String get points;

  /// No description provided for @noRankings.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có dữ liệu chấm công trong khoảng này'**
  String get noRankings;

  /// No description provided for @lastMonths.
  ///
  /// In vi, this message translates to:
  /// **'{count} tháng gần nhất'**
  String lastMonths(int count);

  /// No description provided for @filterPeriod.
  ///
  /// In vi, this message translates to:
  /// **'Khoảng thời gian'**
  String get filterPeriod;

  /// No description provided for @filterDepartment.
  ///
  /// In vi, this message translates to:
  /// **'Phòng ban'**
  String get filterDepartment;

  /// No description provided for @filterPosition.
  ///
  /// In vi, this message translates to:
  /// **'Chức vụ'**
  String get filterPosition;

  /// No description provided for @filterCompany.
  ///
  /// In vi, this message translates to:
  /// **'Công ty'**
  String get filterCompany;

  /// No description provided for @filterRegion.
  ///
  /// In vi, this message translates to:
  /// **'Khu vực'**
  String get filterRegion;

  /// No description provided for @statusWorking.
  ///
  /// In vi, this message translates to:
  /// **'Đang làm'**
  String get statusWorking;

  /// No description provided for @statusArchived.
  ///
  /// In vi, this message translates to:
  /// **'Đã bảo lưu'**
  String get statusArchived;

  /// No description provided for @viewProfile.
  ///
  /// In vi, this message translates to:
  /// **'Xem hồ sơ'**
  String get viewProfile;

  /// No description provided for @nominatePromotion.
  ///
  /// In vi, this message translates to:
  /// **'Đề cử thăng chức'**
  String get nominatePromotion;

  /// No description provided for @nominateTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đề cử {name}'**
  String nominateTitle(String name);

  /// No description provided for @proposedPosition.
  ///
  /// In vi, this message translates to:
  /// **'Chức vụ đề xuất'**
  String get proposedPosition;

  /// No description provided for @raisePercent.
  ///
  /// In vi, this message translates to:
  /// **'Mức tăng lương'**
  String get raisePercent;

  /// No description provided for @raisePercentInvalid.
  ///
  /// In vi, this message translates to:
  /// **'Nhập từ 0,1 đến 100'**
  String get raisePercentInvalid;

  /// No description provided for @nominationReason.
  ///
  /// In vi, this message translates to:
  /// **'Lý do đề cử'**
  String get nominationReason;

  /// No description provided for @sendToExecutives.
  ///
  /// In vi, this message translates to:
  /// **'Gửi Ban lãnh đạo'**
  String get sendToExecutives;

  /// No description provided for @nominationSent.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi đề cử lên Ban lãnh đạo'**
  String get nominationSent;

  /// No description provided for @nominations.
  ///
  /// In vi, this message translates to:
  /// **'Đề cử thăng chức'**
  String get nominations;

  /// No description provided for @nominationsHint.
  ///
  /// In vi, this message translates to:
  /// **'Ban lãnh đạo duyệt, tăng chức và lương'**
  String get nominationsHint;

  /// No description provided for @noNominations.
  ///
  /// In vi, this message translates to:
  /// **'Không có đề cử nào'**
  String get noNominations;

  /// No description provided for @raiseBy.
  ///
  /// In vi, this message translates to:
  /// **'Tăng lương {percent}%'**
  String raiseBy(String percent);

  /// No description provided for @approvePromotion.
  ///
  /// In vi, this message translates to:
  /// **'Duyệt thăng chức'**
  String get approvePromotion;

  /// No description provided for @approvePromotionHint.
  ///
  /// In vi, this message translates to:
  /// **'{name} sẽ lên {position} và được tăng {percent}% lương cơ bản.'**
  String approvePromotionHint(String name, String position, String percent);

  /// No description provided for @promotionApproved.
  ///
  /// In vi, this message translates to:
  /// **'Đã duyệt: đổi chức vụ và tăng lương'**
  String get promotionApproved;

  /// No description provided for @promotionApprovedNoRaise.
  ///
  /// In vi, this message translates to:
  /// **'Đã đổi chức vụ, tăng lương chưa xong, thử lại ở Lương'**
  String get promotionApprovedNoRaise;

  /// No description provided for @promotionRejected.
  ///
  /// In vi, this message translates to:
  /// **'Đã từ chối đề cử'**
  String get promotionRejected;

  /// No description provided for @todoNominations.
  ///
  /// In vi, this message translates to:
  /// **'{count} đề cử thăng chức chờ duyệt'**
  String todoNominations(int count);

  /// No description provided for @archiveProfile.
  ///
  /// In vi, this message translates to:
  /// **'Bảo lưu hồ sơ'**
  String get archiveProfile;

  /// No description provided for @archiveTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bảo lưu hồ sơ {name}?'**
  String archiveTitle(String name);

  /// No description provided for @archiveProjectsWarning.
  ///
  /// In vi, this message translates to:
  /// **'Người này đang ở {count} dự án. Bảo lưu sẽ rút khỏi tất cả:'**
  String archiveProjectsWarning(int count);

  /// No description provided for @archiveNoProjects.
  ///
  /// In vi, this message translates to:
  /// **'Người này không ở dự án nào.'**
  String get archiveNoProjects;

  /// No description provided for @archiveKeepsPersonal.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin cá nhân vẫn được giữ, có thể khôi phục sau.'**
  String get archiveKeepsPersonal;

  /// No description provided for @archiveReason.
  ///
  /// In vi, this message translates to:
  /// **'Lý do bảo lưu'**
  String get archiveReason;

  /// No description provided for @archiveConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Bảo lưu'**
  String get archiveConfirm;

  /// No description provided for @archiveDone.
  ///
  /// In vi, this message translates to:
  /// **'Đã bảo lưu, rút khỏi {count} dự án'**
  String archiveDone(int count);

  /// No description provided for @profileArchivedBanner.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ đang bảo lưu. Lý do: {reason}'**
  String profileArchivedBanner(String reason);

  /// No description provided for @restoreProfile.
  ///
  /// In vi, this message translates to:
  /// **'Khôi phục'**
  String get restoreProfile;

  /// No description provided for @restoreDone.
  ///
  /// In vi, this message translates to:
  /// **'Đã khôi phục hồ sơ'**
  String get restoreDone;

  /// No description provided for @fieldRequired.
  ///
  /// In vi, this message translates to:
  /// **'Không được để trống'**
  String get fieldRequired;

  /// No description provided for @errIsHead.
  ///
  /// In vi, this message translates to:
  /// **'Trưởng phòng phải giao lại cho người khác trước khi chuyển đi'**
  String get errIsHead;

  /// No description provided for @errLastMember.
  ///
  /// In vi, this message translates to:
  /// **'Phòng ban phải còn ít nhất một người'**
  String get errLastMember;

  /// No description provided for @errSameDepartment.
  ///
  /// In vi, this message translates to:
  /// **'Nhân viên đã ở phòng này rồi'**
  String get errSameDepartment;

  /// No description provided for @errArchived.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ đang bảo lưu, khôi phục trước đã'**
  String get errArchived;

  /// No description provided for @errNotArchived.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ này không bảo lưu'**
  String get errNotArchived;

  /// No description provided for @errMembersRemaining.
  ///
  /// In vi, this message translates to:
  /// **'Phòng còn người, chọn phòng nhận lại họ'**
  String get errMembersRemaining;

  /// No description provided for @errNotMember.
  ///
  /// In vi, this message translates to:
  /// **'Người này không thuộc phòng ban'**
  String get errNotMember;

  /// No description provided for @errPendingExists.
  ///
  /// In vi, this message translates to:
  /// **'Đã có một yêu cầu đang chờ duyệt'**
  String get errPendingExists;

  /// No description provided for @errServiceUnavailable.
  ///
  /// In vi, this message translates to:
  /// **'Một phần hệ thống đang bận, thử lại sau ít phút'**
  String get errServiceUnavailable;

  /// No description provided for @nPromotionNominated.
  ///
  /// In vi, this message translates to:
  /// **'{employee} được đề cử lên {position}, chờ duyệt'**
  String nPromotionNominated(String employee, String position);

  /// No description provided for @nPromotionApproved.
  ///
  /// In vi, this message translates to:
  /// **'Chúc mừng! Bạn được thăng chức lên {position}'**
  String nPromotionApproved(String position);

  /// No description provided for @nPromotionRejected.
  ///
  /// In vi, this message translates to:
  /// **'Đề cử lên {position} chưa được duyệt'**
  String nPromotionRejected(String position);

  /// No description provided for @nPromotionApprovedHr.
  ///
  /// In vi, this message translates to:
  /// **'Ban lãnh đạo đã duyệt thăng chức cho {employee}'**
  String nPromotionApprovedHr(String employee);

  /// No description provided for @nPromotionRejectedHr.
  ///
  /// In vi, this message translates to:
  /// **'Ban lãnh đạo không duyệt thăng chức cho {employee}'**
  String nPromotionRejectedHr(String employee);

  /// No description provided for @nEmployeeTransferred.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã được điều chuyển sang phòng ban mới'**
  String get nEmployeeTransferred;

  /// No description provided for @nDepartmentHeadAssigned.
  ///
  /// In vi, this message translates to:
  /// **'Bạn được giao làm trưởng phòng'**
  String get nDepartmentHeadAssigned;

  /// No description provided for @memberHours.
  ///
  /// In vi, this message translates to:
  /// **'{hours} giờ'**
  String memberHours(String hours);

  /// No description provided for @stageInterviewed.
  ///
  /// In vi, this message translates to:
  /// **'Đã phỏng vấn'**
  String get stageInterviewed;

  /// No description provided for @interviewAwaitingCandidate.
  ///
  /// In vi, this message translates to:
  /// **'Chờ ứng viên xác nhận'**
  String get interviewAwaitingCandidate;

  /// No description provided for @interviewAwaitingHr.
  ///
  /// In vi, this message translates to:
  /// **'Chờ HR xác nhận lại'**
  String get interviewAwaitingHr;

  /// No description provided for @interviewConfirmed.
  ///
  /// In vi, this message translates to:
  /// **'Đã xác nhận'**
  String get interviewConfirmed;

  /// No description provided for @interviewCancelled.
  ///
  /// In vi, this message translates to:
  /// **'Đã hủy'**
  String get interviewCancelled;

  /// No description provided for @interviewSchedule.
  ///
  /// In vi, this message translates to:
  /// **'Lịch phỏng vấn'**
  String get interviewSchedule;

  /// No description provided for @minutesAttached.
  ///
  /// In vi, this message translates to:
  /// **'Biên bản: {name}'**
  String minutesAttached(String name);

  /// No description provided for @chooseInterviewTime.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ngày giờ'**
  String get chooseInterviewTime;

  /// No description provided for @errTimeInPast.
  ///
  /// In vi, this message translates to:
  /// **'Giờ phỏng vấn phải sau thời điểm hiện tại'**
  String get errTimeInPast;

  /// No description provided for @interviewLocation.
  ///
  /// In vi, this message translates to:
  /// **'Địa điểm hoặc link họp'**
  String get interviewLocation;

  /// No description provided for @send.
  ///
  /// In vi, this message translates to:
  /// **'Gửi'**
  String get send;

  /// No description provided for @rejectCandidate.
  ///
  /// In vi, this message translates to:
  /// **'Từ chối'**
  String get rejectCandidate;

  /// No description provided for @rejectCandidateHint.
  ///
  /// In vi, this message translates to:
  /// **'Từ chối hồ sơ {name}? Sau này vẫn xem xét lại được.'**
  String rejectCandidateHint(String name);

  /// No description provided for @scheduleInterview.
  ///
  /// In vi, this message translates to:
  /// **'Hẹn phỏng vấn'**
  String get scheduleInterview;

  /// No description provided for @scheduleAgain.
  ///
  /// In vi, this message translates to:
  /// **'Hẹn lại phỏng vấn'**
  String get scheduleAgain;

  /// No description provided for @interviewSent.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi lịch, đang chờ bên kia xác nhận'**
  String get interviewSent;

  /// No description provided for @proposeOtherTime.
  ///
  /// In vi, this message translates to:
  /// **'Đề xuất giờ khác'**
  String get proposeOtherTime;

  /// No description provided for @confirmTime.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận giờ này'**
  String get confirmTime;

  /// No description provided for @interviewConfirmedDone.
  ///
  /// In vi, this message translates to:
  /// **'Đã xác nhận lịch phỏng vấn'**
  String get interviewConfirmedDone;

  /// No description provided for @uploadMinutes.
  ///
  /// In vi, this message translates to:
  /// **'Tải biên bản phỏng vấn'**
  String get uploadMinutes;

  /// No description provided for @minutesUploaded.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu biên bản, hồ sơ chuyển sang đã phỏng vấn'**
  String get minutesUploaded;

  /// No description provided for @minutesAfterInterview.
  ///
  /// In vi, this message translates to:
  /// **'Qua giờ phỏng vấn mới tải được biên bản (Word, Excel)'**
  String get minutesAfterInterview;

  /// No description provided for @openMinutes.
  ///
  /// In vi, this message translates to:
  /// **'Mở biên bản'**
  String get openMinutes;

  /// No description provided for @moveToScreening.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển sang sàng lọc'**
  String get moveToScreening;

  /// No description provided for @reconsider.
  ///
  /// In vi, this message translates to:
  /// **'Xem xét lại'**
  String get reconsider;

  /// No description provided for @reconsidered.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ đã quay về bước trước lúc từ chối'**
  String get reconsidered;

  /// No description provided for @waitingCandidateReply.
  ///
  /// In vi, this message translates to:
  /// **'Đang chờ ứng viên xác nhận hoặc đề xuất giờ khác'**
  String get waitingCandidateReply;

  /// No description provided for @waitingHrReply.
  ///
  /// In vi, this message translates to:
  /// **'Đang chờ HR xác nhận giờ bạn đề xuất'**
  String get waitingHrReply;

  /// No description provided for @hiredSalaryPending.
  ///
  /// In vi, this message translates to:
  /// **'Chưa lưu được lương thỏa thuận, cần nhập lại ở màn Lương'**
  String get hiredSalaryPending;

  /// No description provided for @offerFromAi.
  ///
  /// In vi, this message translates to:
  /// **'AI gợi ý'**
  String get offerFromAi;

  /// No description provided for @offerFromRules.
  ///
  /// In vi, this message translates to:
  /// **'Gợi ý theo dữ liệu'**
  String get offerFromRules;

  /// No description provided for @offerPeerMedian.
  ///
  /// In vi, this message translates to:
  /// **'Lương ở giữa của những người cùng chức vụ, phòng có nhiều người cùng chức vụ nhất'**
  String get offerPeerMedian;

  /// No description provided for @offerRegionMedian.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có ai cùng chức vụ: lương ở giữa của khu vực, phòng đông người nhất'**
  String get offerRegionMedian;

  /// No description provided for @agreedSalary.
  ///
  /// In vi, this message translates to:
  /// **'Lương cơ bản thỏa thuận'**
  String get agreedSalary;

  /// No description provided for @currency.
  ///
  /// In vi, this message translates to:
  /// **'Tiền tệ'**
  String get currency;

  /// No description provided for @errInvalidStep.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ không thể chuyển như vậy ở bước hiện tại, tải lại để xem bước mới nhất'**
  String get errInvalidStep;

  /// No description provided for @errNotScreened.
  ///
  /// In vi, this message translates to:
  /// **'Cần sàng lọc hồ sơ trước khi hẹn phỏng vấn'**
  String get errNotScreened;

  /// No description provided for @errInterviewNotConfirmed.
  ///
  /// In vi, this message translates to:
  /// **'Lịch phỏng vấn chưa được xác nhận'**
  String get errInterviewNotConfirmed;

  /// No description provided for @errNotInterviewed.
  ///
  /// In vi, this message translates to:
  /// **'Cần tải biên bản phỏng vấn trước khi nhận việc'**
  String get errNotInterviewed;

  /// No description provided for @errNotRejected.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ này chưa bị từ chối'**
  String get errNotRejected;

  /// No description provided for @errInvalidOffer.
  ///
  /// In vi, this message translates to:
  /// **'Lương thỏa thuận phải lớn hơn 0 và có mã tiền tệ'**
  String get errInvalidOffer;

  /// No description provided for @errMinutesFile.
  ///
  /// In vi, this message translates to:
  /// **'Biên bản phải là tệp Word hoặc Excel'**
  String get errMinutesFile;

  /// No description provided for @nInterviewScheduled.
  ///
  /// In vi, this message translates to:
  /// **'Lịch phỏng vấn {position} lúc {time}, mở để xác nhận'**
  String nInterviewScheduled(String position, String time);

  /// No description provided for @nInterviewConfirmed.
  ///
  /// In vi, this message translates to:
  /// **'Lịch phỏng vấn lúc {time} đã được xác nhận'**
  String nInterviewConfirmed(String time);

  /// No description provided for @nInterviewConfirmedHr.
  ///
  /// In vi, this message translates to:
  /// **'Ứng viên {position} đã chốt lịch phỏng vấn lúc {time}'**
  String nInterviewConfirmedHr(String position, String time);

  /// No description provided for @nInterviewProposed.
  ///
  /// In vi, this message translates to:
  /// **'Ứng viên {position} đề xuất phỏng vấn lúc {time}'**
  String nInterviewProposed(String position, String time);

  /// No description provided for @projectTier.
  ///
  /// In vi, this message translates to:
  /// **'Phân cấp'**
  String get projectTier;

  /// No description provided for @tierSmall.
  ///
  /// In vi, this message translates to:
  /// **'Cấp 1 · Nhỏ'**
  String get tierSmall;

  /// No description provided for @tierMedium.
  ///
  /// In vi, this message translates to:
  /// **'Cấp 2 · Vừa'**
  String get tierMedium;

  /// No description provided for @tierLarge.
  ///
  /// In vi, this message translates to:
  /// **'Cấp 3 · Lớn'**
  String get tierLarge;

  /// No description provided for @tierStrategic.
  ///
  /// In vi, this message translates to:
  /// **'Cấp 4 · Trọng điểm'**
  String get tierStrategic;

  /// No description provided for @tierRule.
  ///
  /// In vi, this message translates to:
  /// **'Tối đa {months} tháng, ít nhất {members} người'**
  String tierRule(int months, int members);

  /// No description provided for @warnRed.
  ///
  /// In vi, this message translates to:
  /// **'Còn ≤ 1 tháng'**
  String get warnRed;

  /// No description provided for @warnOrange.
  ///
  /// In vi, this message translates to:
  /// **'Còn ≤ 6 tháng'**
  String get warnOrange;

  /// No description provided for @warnYellow.
  ///
  /// In vi, this message translates to:
  /// **'Còn ≤ 12 tháng'**
  String get warnYellow;

  /// No description provided for @warnNotStarted.
  ///
  /// In vi, this message translates to:
  /// **'Chưa bắt đầu'**
  String get warnNotStarted;

  /// No description provided for @warnAccepted.
  ///
  /// In vi, this message translates to:
  /// **'Đã nghiệm thu'**
  String get warnAccepted;

  /// No description provided for @warnNormal.
  ///
  /// In vi, this message translates to:
  /// **'Còn hơn 12 tháng'**
  String get warnNormal;

  /// No description provided for @projectCharts.
  ///
  /// In vi, this message translates to:
  /// **'Biểu đồ dự án'**
  String get projectCharts;

  /// No description provided for @chart2d.
  ///
  /// In vi, this message translates to:
  /// **'2D'**
  String get chart2d;

  /// No description provided for @chart3d.
  ///
  /// In vi, this message translates to:
  /// **'3D'**
  String get chart3d;

  /// No description provided for @chartTimeline.
  ///
  /// In vi, this message translates to:
  /// **'Thời gian'**
  String get chartTimeline;

  /// No description provided for @chartProgress.
  ///
  /// In vi, this message translates to:
  /// **'Tiến độ'**
  String get chartProgress;

  /// No description provided for @chartMembers.
  ///
  /// In vi, this message translates to:
  /// **'Số người'**
  String get chartMembers;

  /// No description provided for @chartValue.
  ///
  /// In vi, this message translates to:
  /// **'Giá trị'**
  String get chartValue;

  /// No description provided for @thousandUsd.
  ///
  /// In vi, this message translates to:
  /// **'nghìn USD'**
  String get thousandUsd;

  /// No description provided for @projectProposals.
  ///
  /// In vi, this message translates to:
  /// **'Đề xuất dự án'**
  String get projectProposals;

  /// No description provided for @projectNew.
  ///
  /// In vi, this message translates to:
  /// **'Tạo dự án'**
  String get projectNew;

  /// No description provided for @wizardFiles.
  ///
  /// In vi, this message translates to:
  /// **'Hợp đồng và ảnh'**
  String get wizardFiles;

  /// No description provided for @wizardFilesHint.
  ///
  /// In vi, this message translates to:
  /// **'Tải hợp đồng theo mẫu (PDF hoặc Word), AI sẽ đọc và điền sẵn thông tin; không có hợp đồng thì nhập tay ở bước sau.'**
  String get wizardFilesHint;

  /// No description provided for @wizardInfo.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin dự án'**
  String get wizardInfo;

  /// No description provided for @wizardMembers.
  ///
  /// In vi, this message translates to:
  /// **'Nhân viên tham gia'**
  String get wizardMembers;

  /// No description provided for @wizardSend.
  ///
  /// In vi, this message translates to:
  /// **'Gửi Ban lãnh đạo'**
  String get wizardSend;

  /// No description provided for @downloadContractTemplate.
  ///
  /// In vi, this message translates to:
  /// **'Tải mẫu hợp đồng'**
  String get downloadContractTemplate;

  /// No description provided for @uploadContract.
  ///
  /// In vi, this message translates to:
  /// **'Tải hợp đồng lên'**
  String get uploadContract;

  /// No description provided for @uploadProjectImage.
  ///
  /// In vi, this message translates to:
  /// **'Tải ảnh công trình'**
  String get uploadProjectImage;

  /// No description provided for @contractReadByAi.
  ///
  /// In vi, this message translates to:
  /// **'AI đã đọc hợp đồng và điền sẵn, kiểm lại ở bước sau'**
  String get contractReadByAi;

  /// No description provided for @contractReadManual.
  ///
  /// In vi, this message translates to:
  /// **'Chưa đọc được hợp đồng tự động, vui lòng nhập tay ở bước sau'**
  String get contractReadManual;

  /// No description provided for @projectName.
  ///
  /// In vi, this message translates to:
  /// **'Tên dự án'**
  String get projectName;

  /// No description provided for @customerName.
  ///
  /// In vi, this message translates to:
  /// **'Khách hàng'**
  String get customerName;

  /// No description provided for @customerCompany.
  ///
  /// In vi, this message translates to:
  /// **'Doanh nghiệp'**
  String get customerCompany;

  /// No description provided for @customerIndividual.
  ///
  /// In vi, this message translates to:
  /// **'Cá nhân'**
  String get customerIndividual;

  /// No description provided for @customerContact.
  ///
  /// In vi, this message translates to:
  /// **'Liên hệ khách hàng (email hoặc điện thoại)'**
  String get customerContact;

  /// No description provided for @contractType.
  ///
  /// In vi, this message translates to:
  /// **'Loại hợp đồng'**
  String get contractType;

  /// No description provided for @contractValue.
  ///
  /// In vi, this message translates to:
  /// **'Giá trị hợp đồng'**
  String get contractValue;

  /// No description provided for @depositAmount.
  ///
  /// In vi, this message translates to:
  /// **'Tạm ứng'**
  String get depositAmount;

  /// No description provided for @startDate.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In vi, this message translates to:
  /// **'Kết thúc'**
  String get endDate;

  /// No description provided for @acceptanceDate.
  ///
  /// In vi, this message translates to:
  /// **'Nghiệm thu'**
  String get acceptanceDate;

  /// No description provided for @propErrName.
  ///
  /// In vi, this message translates to:
  /// **'Cần tên dự án'**
  String get propErrName;

  /// No description provided for @propErrCustomer.
  ///
  /// In vi, this message translates to:
  /// **'Cần tên khách hàng'**
  String get propErrCustomer;

  /// No description provided for @propErrValue.
  ///
  /// In vi, this message translates to:
  /// **'Giá trị hợp đồng phải lớn hơn 0'**
  String get propErrValue;

  /// No description provided for @propErrDeposit.
  ///
  /// In vi, this message translates to:
  /// **'Tạm ứng không được âm hay lớn hơn giá trị hợp đồng'**
  String get propErrDeposit;

  /// No description provided for @propErrDates.
  ///
  /// In vi, this message translates to:
  /// **'Cần ngày bắt đầu và ngày kết thúc'**
  String get propErrDates;

  /// No description provided for @propErrStartPast.
  ///
  /// In vi, this message translates to:
  /// **'Ngày bắt đầu không được trước hôm nay'**
  String get propErrStartPast;

  /// No description provided for @propErrEndBeforeStart.
  ///
  /// In vi, this message translates to:
  /// **'Ngày kết thúc phải sau ngày bắt đầu'**
  String get propErrEndBeforeStart;

  /// No description provided for @propErrAcceptance.
  ///
  /// In vi, this message translates to:
  /// **'Nghiệm thu phải từ ngày kết thúc tới 90 ngày sau'**
  String get propErrAcceptance;

  /// No description provided for @propErrTooLong.
  ///
  /// In vi, this message translates to:
  /// **'Dự án cấp này làm quá thời gian tối đa'**
  String get propErrTooLong;

  /// No description provided for @propErrFewMembers.
  ///
  /// In vi, this message translates to:
  /// **'Chưa đủ số người tối thiểu của cấp này'**
  String get propErrFewMembers;

  /// No description provided for @membersNeeded.
  ///
  /// In vi, this message translates to:
  /// **'Cần ít nhất {min} người · đã chọn {picked}'**
  String membersNeeded(int min, int picked);

  /// No description provided for @suggestMembers.
  ///
  /// In vi, this message translates to:
  /// **'AI gợi ý nhân viên'**
  String get suggestMembers;

  /// No description provided for @activeProjects.
  ///
  /// In vi, this message translates to:
  /// **'{count} dự án đang làm'**
  String activeProjects(int count);

  /// No description provided for @next.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp'**
  String get next;

  /// No description provided for @back.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại'**
  String get back;

  /// No description provided for @sendToExecutive.
  ///
  /// In vi, this message translates to:
  /// **'Gửi duyệt'**
  String get sendToExecutive;

  /// No description provided for @proposalSent.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi đề xuất, chờ Ban lãnh đạo duyệt'**
  String get proposalSent;

  /// No description provided for @noProposals.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có đề xuất dự án'**
  String get noProposals;

  /// No description provided for @proposalVersion.
  ///
  /// In vi, this message translates to:
  /// **'Bản {version}'**
  String proposalVersion(int version);

  /// No description provided for @propAwaitingExecutive.
  ///
  /// In vi, this message translates to:
  /// **'Chờ Ban lãnh đạo'**
  String get propAwaitingExecutive;

  /// No description provided for @propAwaitingProposer.
  ///
  /// In vi, this message translates to:
  /// **'Chờ bên lập xác nhận'**
  String get propAwaitingProposer;

  /// No description provided for @propApproved.
  ///
  /// In vi, this message translates to:
  /// **'Đã duyệt'**
  String get propApproved;

  /// No description provided for @propRejected.
  ///
  /// In vi, this message translates to:
  /// **'Đã từ chối'**
  String get propRejected;

  /// No description provided for @proposalEdit.
  ///
  /// In vi, this message translates to:
  /// **'Sửa đề xuất'**
  String get proposalEdit;

  /// No description provided for @proposalNoteHint.
  ///
  /// In vi, this message translates to:
  /// **'Lý do hoặc điều cần sửa'**
  String get proposalNoteHint;

  /// No description provided for @proposalApprovedDone.
  ///
  /// In vi, this message translates to:
  /// **'Đã duyệt, dự án {id} đã được tạo'**
  String proposalApprovedDone(String id);

  /// No description provided for @acceptEdits.
  ///
  /// In vi, this message translates to:
  /// **'Đồng ý bản sửa'**
  String get acceptEdits;

  /// No description provided for @withdrawProposal.
  ///
  /// In vi, this message translates to:
  /// **'Rút đề xuất'**
  String get withdrawProposal;

  /// No description provided for @waitingOtherSide.
  ///
  /// In vi, this message translates to:
  /// **'Đang chờ bên kia trả lời'**
  String get waitingOtherSide;

  /// No description provided for @openContract.
  ///
  /// In vi, this message translates to:
  /// **'Mở hợp đồng'**
  String get openContract;

  /// No description provided for @openImage.
  ///
  /// In vi, this message translates to:
  /// **'Mở ảnh'**
  String get openImage;

  /// No description provided for @openProject.
  ///
  /// In vi, this message translates to:
  /// **'Mở dự án'**
  String get openProject;

  /// No description provided for @propActSubmitted.
  ///
  /// In vi, this message translates to:
  /// **'Gửi đề xuất'**
  String get propActSubmitted;

  /// No description provided for @propActCounter.
  ///
  /// In vi, this message translates to:
  /// **'Sửa lại đề xuất'**
  String get propActCounter;

  /// No description provided for @propActApprove.
  ///
  /// In vi, this message translates to:
  /// **'Đồng ý'**
  String get propActApprove;

  /// No description provided for @propActReject.
  ///
  /// In vi, this message translates to:
  /// **'Từ chối'**
  String get propActReject;

  /// No description provided for @propActWithdraw.
  ///
  /// In vi, this message translates to:
  /// **'Rút đề xuất'**
  String get propActWithdraw;

  /// No description provided for @todoProposals.
  ///
  /// In vi, this message translates to:
  /// **'{count} đề xuất dự án chờ duyệt'**
  String todoProposals(int count);

  /// No description provided for @nProjectProposed.
  ///
  /// In vi, this message translates to:
  /// **'Đề xuất dự án mới cần duyệt: {name}'**
  String nProjectProposed(String name);

  /// No description provided for @nProjectCountered.
  ///
  /// In vi, this message translates to:
  /// **'Ban lãnh đạo đã sửa đề xuất {name}, cần bạn xác nhận'**
  String nProjectCountered(String name);

  /// No description provided for @nProjectApproved.
  ///
  /// In vi, this message translates to:
  /// **'Dự án {name} đã được duyệt và tạo'**
  String nProjectApproved(String name);

  /// No description provided for @nProjectRejected.
  ///
  /// In vi, this message translates to:
  /// **'Đề xuất dự án {name} bị từ chối'**
  String nProjectRejected(String name);

  /// No description provided for @workCalendar.
  ///
  /// In vi, this message translates to:
  /// **'Lịch làm việc'**
  String get workCalendar;

  /// No description provided for @clockStats.
  ///
  /// In vi, this message translates to:
  /// **'Biểu đồ chấm công'**
  String get clockStats;

  /// No description provided for @shiftHours.
  ///
  /// In vi, this message translates to:
  /// **'Ca {start}–{end}'**
  String shiftHours(String start, String end);

  /// No description provided for @errShiftEnded.
  ///
  /// In vi, this message translates to:
  /// **'Đã qua giờ kết thúc ca nên không chấm vào được nữa'**
  String get errShiftEnded;

  /// No description provided for @errTooManyFiles.
  ///
  /// In vi, this message translates to:
  /// **'Mỗi đơn chỉ đính kèm tối đa 5 tệp'**
  String get errTooManyFiles;

  /// No description provided for @errFileType.
  ///
  /// In vi, this message translates to:
  /// **'Loại tệp không được nhận, hãy chọn đúng loại tệp yêu cầu'**
  String get errFileType;

  /// No description provided for @addEvidence.
  ///
  /// In vi, this message translates to:
  /// **'Thêm minh chứng'**
  String get addEvidence;

  /// No description provided for @viewOriginalLeave.
  ///
  /// In vi, this message translates to:
  /// **'Xem đơn gốc ({count})'**
  String viewOriginalLeave(int count);

  /// No description provided for @evidenceUploaded.
  ///
  /// In vi, this message translates to:
  /// **'Đã thêm minh chứng, AI đang tóm tắt cho HR'**
  String get evidenceUploaded;

  /// No description provided for @noEvidence.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có minh chứng'**
  String get noEvidence;

  /// No description provided for @aiLeaveSummary.
  ///
  /// In vi, this message translates to:
  /// **'AI tóm tắt minh chứng'**
  String get aiLeaveSummary;

  /// No description provided for @evidenceMatches.
  ///
  /// In vi, this message translates to:
  /// **'Khớp lý do nghỉ'**
  String get evidenceMatches;

  /// No description provided for @evidenceCheck.
  ///
  /// In vi, this message translates to:
  /// **'Cần xem kỹ'**
  String get evidenceCheck;

  /// No description provided for @calWorked.
  ///
  /// In vi, this message translates to:
  /// **'Đã làm'**
  String get calWorked;

  /// No description provided for @calLeave.
  ///
  /// In vi, this message translates to:
  /// **'Nghỉ phép'**
  String get calLeave;

  /// No description provided for @calHoliday.
  ///
  /// In vi, this message translates to:
  /// **'Ngày lễ'**
  String get calHoliday;

  /// No description provided for @calAbsent.
  ///
  /// In vi, this message translates to:
  /// **'Vắng không phép'**
  String get calAbsent;

  /// No description provided for @calScheduled.
  ///
  /// In vi, this message translates to:
  /// **'Có ca'**
  String get calScheduled;

  /// No description provided for @calLeaveOfType.
  ///
  /// In vi, this message translates to:
  /// **'Nghỉ: {type}'**
  String calLeaveOfType(String type);

  /// No description provided for @noShiftThisDay.
  ///
  /// In vi, this message translates to:
  /// **'Không có ca ngày này'**
  String get noShiftThisDay;

  /// No description provided for @estimatedDayPay.
  ///
  /// In vi, this message translates to:
  /// **'Tiền ước tính hôm nay: {amount}'**
  String estimatedDayPay(String amount);

  /// No description provided for @estimatedMonthPay.
  ///
  /// In vi, this message translates to:
  /// **'Tiền ước tính theo giờ làm: {amount}'**
  String estimatedMonthPay(String amount);

  /// No description provided for @payEstimateHint.
  ///
  /// In vi, this message translates to:
  /// **'Tính theo lương cơ bản, 26 ngày công, tăng ca 150%; chưa trừ bảo hiểm, thuế'**
  String get payEstimateHint;

  /// No description provided for @projectsThisDay.
  ///
  /// In vi, this message translates to:
  /// **'Dự án đang tham gia'**
  String get projectsThisDay;

  /// No description provided for @statsScopeRegion.
  ///
  /// In vi, this message translates to:
  /// **'Cả khu vực'**
  String get statsScopeRegion;

  /// No description provided for @statsScopeMine.
  ///
  /// In vi, this message translates to:
  /// **'Của tôi'**
  String get statsScopeMine;

  /// No description provided for @statsDays.
  ///
  /// In vi, this message translates to:
  /// **'Ngày đã chấm công'**
  String get statsDays;

  /// No description provided for @statsLate.
  ///
  /// In vi, this message translates to:
  /// **'Vào trễ'**
  String get statsLate;

  /// No description provided for @statsByWeekday.
  ///
  /// In vi, this message translates to:
  /// **'Theo thứ trong tuần'**
  String get statsByWeekday;

  /// No description provided for @statsByHour.
  ///
  /// In vi, this message translates to:
  /// **'Giờ vào ca'**
  String get statsByHour;

  /// No description provided for @statsByMonth.
  ///
  /// In vi, this message translates to:
  /// **'Ngày công và số lần trễ theo tháng'**
  String get statsByMonth;

  /// No description provided for @errPayrollTooEarly.
  ///
  /// In vi, this message translates to:
  /// **'Kỳ lương này chưa tới hạn: lương tháng M chốt từ ngày 10 tháng M+1'**
  String get errPayrollTooEarly;

  /// No description provided for @errAmountLowered.
  ///
  /// In vi, this message translates to:
  /// **'Mức đề xuất chỉ được giữ nguyên hoặc tăng, không được hạ'**
  String get errAmountLowered;

  /// No description provided for @errNotHigher.
  ///
  /// In vi, this message translates to:
  /// **'Mức đề xuất phải cao hơn lương hiện tại'**
  String get errNotHigher;

  /// No description provided for @errNoSalary.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có lương cơ bản trong hệ thống'**
  String get errNoSalary;

  /// No description provided for @errAwaitingAck.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo trước đang chờ cấp trên xác nhận, chưa gửi bản mới được'**
  String get errAwaitingAck;

  /// No description provided for @acknowledge.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận'**
  String get acknowledge;

  /// No description provided for @byDay.
  ///
  /// In vi, this message translates to:
  /// **'Ngày'**
  String get byDay;

  /// No description provided for @byMonth.
  ///
  /// In vi, this message translates to:
  /// **'Tháng'**
  String get byMonth;

  /// No description provided for @byYear.
  ///
  /// In vi, this message translates to:
  /// **'Năm'**
  String get byYear;

  /// No description provided for @costs.
  ///
  /// In vi, this message translates to:
  /// **'Chi phí'**
  String get costs;

  /// No description provided for @export.
  ///
  /// In vi, this message translates to:
  /// **'Xuất tệp'**
  String get export;

  /// No description provided for @exportExcel.
  ///
  /// In vi, this message translates to:
  /// **'Xuất Excel'**
  String get exportExcel;

  /// No description provided for @exportPdf.
  ///
  /// In vi, this message translates to:
  /// **'Xuất PDF'**
  String get exportPdf;

  /// No description provided for @exportedAt.
  ///
  /// In vi, this message translates to:
  /// **'Xuất lúc {time}'**
  String exportedAt(String time);

  /// No description provided for @exportId.
  ///
  /// In vi, this message translates to:
  /// **'Mã'**
  String get exportId;

  /// No description provided for @exportPeriod.
  ///
  /// In vi, this message translates to:
  /// **'Kỳ'**
  String get exportPeriod;

  /// No description provided for @exportRank.
  ///
  /// In vi, this message translates to:
  /// **'Hạng'**
  String get exportRank;

  /// No description provided for @exportMargin.
  ///
  /// In vi, this message translates to:
  /// **'Biên lãi'**
  String get exportMargin;

  /// No description provided for @exportCurrency.
  ///
  /// In vi, this message translates to:
  /// **'Tiền tệ'**
  String get exportCurrency;

  /// No description provided for @exportRevenueUsd.
  ///
  /// In vi, this message translates to:
  /// **'Doanh thu (USD)'**
  String get exportRevenueUsd;

  /// No description provided for @exportCostUsd.
  ///
  /// In vi, this message translates to:
  /// **'Chi phí (USD)'**
  String get exportCostUsd;

  /// No description provided for @exportFinanceTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thu chi năm {year}'**
  String exportFinanceTitle(int year);

  /// No description provided for @financeAnalytics.
  ///
  /// In vi, this message translates to:
  /// **'Phân tích'**
  String get financeAnalytics;

  /// No description provided for @materialCost.
  ///
  /// In vi, this message translates to:
  /// **'Chi vật liệu'**
  String get materialCost;

  /// No description provided for @payrollCost.
  ///
  /// In vi, this message translates to:
  /// **'Chi lương'**
  String get payrollCost;

  /// No description provided for @materialsUsed.
  ///
  /// In vi, this message translates to:
  /// **'Vật liệu đã dùng'**
  String get materialsUsed;

  /// No description provided for @revenueByStage.
  ///
  /// In vi, this message translates to:
  /// **'Doanh thu theo đợt'**
  String get revenueByStage;

  /// No description provided for @projectProfitRanking.
  ///
  /// In vi, this message translates to:
  /// **'Xếp hạng dự án theo lợi nhuận'**
  String get projectProfitRanking;

  /// No description provided for @projectSalaryShares.
  ///
  /// In vi, this message translates to:
  /// **'Lương dự án chia cho từng người'**
  String get projectSalaryShares;

  /// No description provided for @overtimePay.
  ///
  /// In vi, this message translates to:
  /// **'Tăng ca'**
  String get overtimePay;

  /// No description provided for @insuranceDeduction.
  ///
  /// In vi, this message translates to:
  /// **'Bảo hiểm'**
  String get insuranceDeduction;

  /// No description provided for @incomeTax.
  ///
  /// In vi, this message translates to:
  /// **'Thuế thu nhập'**
  String get incomeTax;

  /// No description provided for @salaryGrowth.
  ///
  /// In vi, this message translates to:
  /// **'Lương qua các kỳ'**
  String get salaryGrowth;

  /// No description provided for @salaryGrowthRate.
  ///
  /// In vi, this message translates to:
  /// **'Thực nhận {rate} sau {count} kỳ'**
  String salaryGrowthRate(String rate, int count);

  /// No description provided for @payrollOpensOn.
  ///
  /// In vi, this message translates to:
  /// **'Kỳ {period} mở chốt lương từ {date}'**
  String payrollOpensOn(String period, String date);

  /// No description provided for @raiseRequests.
  ///
  /// In vi, this message translates to:
  /// **'Đề xuất tăng lương'**
  String get raiseRequests;

  /// No description provided for @raiseRequestsHint.
  ///
  /// In vi, this message translates to:
  /// **'Gửi, chuyển lên, duyệt tăng lương'**
  String get raiseRequestsHint;

  /// No description provided for @newRaiseRequest.
  ///
  /// In vi, this message translates to:
  /// **'Đề xuất tăng lương'**
  String get newRaiseRequest;

  /// No description provided for @noRaiseRequests.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có đề xuất tăng lương'**
  String get noRaiseRequests;

  /// No description provided for @proposedSalary.
  ///
  /// In vi, this message translates to:
  /// **'Lương cơ bản đề xuất'**
  String get proposedSalary;

  /// No description provided for @raiseMinimum.
  ///
  /// In vi, this message translates to:
  /// **'Không thấp hơn {amount}'**
  String raiseMinimum(String amount);

  /// No description provided for @raiseReason.
  ///
  /// In vi, this message translates to:
  /// **'Lý do (thành tích, trách nhiệm mới...)'**
  String get raiseReason;

  /// No description provided for @raiseActionTitle.
  ///
  /// In vi, this message translates to:
  /// **'Mức lương và ghi chú'**
  String get raiseActionTitle;

  /// No description provided for @raiseSent.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi đề xuất tăng lương'**
  String get raiseSent;

  /// No description provided for @raiseForwarded.
  ///
  /// In vi, this message translates to:
  /// **'Đã chuyển lên cấp duyệt'**
  String get raiseForwarded;

  /// No description provided for @raiseApprovedDone.
  ///
  /// In vi, this message translates to:
  /// **'Đã duyệt, lương cơ bản đã tăng'**
  String get raiseApprovedDone;

  /// No description provided for @raiseForward.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển lên duyệt'**
  String get raiseForward;

  /// No description provided for @raiseReturn.
  ///
  /// In vi, this message translates to:
  /// **'Trả lại'**
  String get raiseReturn;

  /// No description provided for @raiseEdit.
  ///
  /// In vi, this message translates to:
  /// **'Sửa mức đề xuất'**
  String get raiseEdit;

  /// No description provided for @raiseAwaitingHr.
  ///
  /// In vi, this message translates to:
  /// **'Chờ HR xem'**
  String get raiseAwaitingHr;

  /// No description provided for @raiseAwaitingApprover.
  ///
  /// In vi, this message translates to:
  /// **'Chờ cấp trên duyệt'**
  String get raiseAwaitingApprover;

  /// No description provided for @raiseAwaitingEmployee.
  ///
  /// In vi, this message translates to:
  /// **'Trả lại cho nhân viên'**
  String get raiseAwaitingEmployee;

  /// No description provided for @raiseWithdrawn.
  ///
  /// In vi, this message translates to:
  /// **'Đã rút'**
  String get raiseWithdrawn;

  /// No description provided for @raiseRequestedFirst.
  ///
  /// In vi, this message translates to:
  /// **'Ban đầu đề xuất {amount}'**
  String raiseRequestedFirst(String amount);

  /// No description provided for @reportSubmissions.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo gửi cấp trên'**
  String get reportSubmissions;

  /// No description provided for @reportSubmissionsHint.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo nhân sự, tài chính theo kỳ, chờ cấp trên xác nhận'**
  String get reportSubmissionsHint;

  /// No description provided for @reportHr.
  ///
  /// In vi, this message translates to:
  /// **'Nhân sự'**
  String get reportHr;

  /// No description provided for @reportFinance.
  ///
  /// In vi, this message translates to:
  /// **'Tài chính'**
  String get reportFinance;

  /// No description provided for @noReports.
  ///
  /// In vi, this message translates to:
  /// **'Chưa gửi báo cáo nào'**
  String get noReports;

  /// No description provided for @submitReport.
  ///
  /// In vi, this message translates to:
  /// **'Gửi báo cáo'**
  String get submitReport;

  /// No description provided for @submitReportTitle.
  ///
  /// In vi, this message translates to:
  /// **'Gửi báo cáo kỳ {period}'**
  String submitReportTitle(String period);

  /// No description provided for @reportWaitingAck.
  ///
  /// In vi, this message translates to:
  /// **'Đang chờ xác nhận'**
  String get reportWaitingAck;

  /// No description provided for @reportSent.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi báo cáo lên cấp trên'**
  String get reportSent;

  /// No description provided for @reportAcknowledged.
  ///
  /// In vi, this message translates to:
  /// **'Đã xác nhận báo cáo'**
  String get reportAcknowledged;

  /// No description provided for @returnReport.
  ///
  /// In vi, this message translates to:
  /// **'Trả lại báo cáo'**
  String get returnReport;

  /// No description provided for @reportStatusSubmitted.
  ///
  /// In vi, this message translates to:
  /// **'Chờ xác nhận'**
  String get reportStatusSubmitted;

  /// No description provided for @reportStatusAcknowledged.
  ///
  /// In vi, this message translates to:
  /// **'Đã xác nhận'**
  String get reportStatusAcknowledged;

  /// No description provided for @reportStatusReturned.
  ///
  /// In vi, this message translates to:
  /// **'Bị trả lại'**
  String get reportStatusReturned;

  /// No description provided for @reportPeriod.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo kỳ {period}'**
  String reportPeriod(String period);

  /// No description provided for @reportHeadcount.
  ///
  /// In vi, this message translates to:
  /// **'{people} nhân viên, {departments} phòng ban'**
  String reportHeadcount(int people, int departments);

  /// No description provided for @reportUnassigned.
  ///
  /// In vi, this message translates to:
  /// **'{count} người chưa có phòng ban'**
  String reportUnassigned(int count);

  /// No description provided for @reportNominations.
  ///
  /// In vi, this message translates to:
  /// **'Đề cử thăng chức: {pending} chờ, {approved} đã duyệt'**
  String reportNominations(int pending, int approved);

  /// No description provided for @resignations.
  ///
  /// In vi, this message translates to:
  /// **'Xin thôi việc'**
  String get resignations;

  /// No description provided for @resignationsHint.
  ///
  /// In vi, this message translates to:
  /// **'Gửi đơn nghỉ việc, theo dõi duyệt'**
  String get resignationsHint;

  /// No description provided for @newResignation.
  ///
  /// In vi, this message translates to:
  /// **'Gửi đơn'**
  String get newResignation;

  /// No description provided for @resignationLastDay.
  ///
  /// In vi, this message translates to:
  /// **'Ngày làm cuối'**
  String get resignationLastDay;

  /// No description provided for @resignationLastDayOn.
  ///
  /// In vi, this message translates to:
  /// **'Ngày làm cuối: {date}'**
  String resignationLastDayOn(String date);

  /// No description provided for @resignationReason.
  ///
  /// In vi, this message translates to:
  /// **'Lý do nghỉ việc'**
  String get resignationReason;

  /// No description provided for @resignationNotice.
  ///
  /// In vi, this message translates to:
  /// **'Báo trước ít nhất {days} ngày'**
  String resignationNotice(int days);

  /// No description provided for @resignationSent.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi đơn thôi việc cho HR'**
  String get resignationSent;

  /// No description provided for @noResignations.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có đơn thôi việc nào'**
  String get noResignations;

  /// No description provided for @resignationPending.
  ///
  /// In vi, this message translates to:
  /// **'Chờ HR duyệt'**
  String get resignationPending;

  /// No description provided for @resignationApproved.
  ///
  /// In vi, this message translates to:
  /// **'Đã duyệt, chờ ngày nghỉ'**
  String get resignationApproved;

  /// No description provided for @resignationCompleted.
  ///
  /// In vi, this message translates to:
  /// **'Đã nghỉ việc'**
  String get resignationCompleted;

  /// No description provided for @resignationWithdrawn.
  ///
  /// In vi, this message translates to:
  /// **'Đã rút đơn'**
  String get resignationWithdrawn;

  /// No description provided for @resignationWithdraw.
  ///
  /// In vi, this message translates to:
  /// **'Rút đơn'**
  String get resignationWithdraw;

  /// No description provided for @resignationComplete.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn tất nghỉ việc'**
  String get resignationComplete;

  /// No description provided for @resignationCompleteConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ {name} sẽ được bảo lưu và rút khỏi mọi dự án. Tiếp tục?'**
  String resignationCompleteConfirm(String name);

  /// No description provided for @resignationCompletedDone.
  ///
  /// In vi, this message translates to:
  /// **'Đã hoàn tất nghỉ việc, hồ sơ chuyển vào lưu trữ'**
  String get resignationCompletedDone;

  /// No description provided for @errNoticeTooShort.
  ///
  /// In vi, this message translates to:
  /// **'Ngày làm cuối phải cách hôm nay ít nhất 30 ngày'**
  String get errNoticeTooShort;

  /// No description provided for @errBeforeLastDay.
  ///
  /// In vi, this message translates to:
  /// **'Chưa tới ngày làm cuối, chưa hoàn tất được'**
  String get errBeforeLastDay;

  /// No description provided for @exportCsv.
  ///
  /// In vi, this message translates to:
  /// **'Xuất CSV'**
  String get exportCsv;

  /// No description provided for @exportJson.
  ///
  /// In vi, this message translates to:
  /// **'Xuất JSON'**
  String get exportJson;

  /// No description provided for @auditCharts.
  ///
  /// In vi, this message translates to:
  /// **'Biểu đồ'**
  String get auditCharts;

  /// No description provided for @auditFilter.
  ///
  /// In vi, this message translates to:
  /// **'Lọc chi tiết'**
  String get auditFilter;

  /// No description provided for @auditService.
  ///
  /// In vi, this message translates to:
  /// **'Dịch vụ'**
  String get auditService;

  /// No description provided for @auditEventType.
  ///
  /// In vi, this message translates to:
  /// **'Loại sự kiện'**
  String get auditEventType;

  /// No description provided for @auditTime.
  ///
  /// In vi, this message translates to:
  /// **'Thời điểm'**
  String get auditTime;

  /// No description provided for @auditFromTime.
  ///
  /// In vi, this message translates to:
  /// **'Từ lúc'**
  String get auditFromTime;

  /// No description provided for @auditToTime.
  ///
  /// In vi, this message translates to:
  /// **'Đến lúc'**
  String get auditToTime;

  /// No description provided for @anyTime.
  ///
  /// In vi, this message translates to:
  /// **'Bất kỳ'**
  String get anyTime;

  /// No description provided for @anomalyAny.
  ///
  /// In vi, this message translates to:
  /// **'Bất thường'**
  String get anomalyAny;

  /// No description provided for @anomalyAfterHours.
  ///
  /// In vi, this message translates to:
  /// **'Ngoài giờ (22h–6h)'**
  String get anomalyAfterHours;

  /// No description provided for @anomalyFailure.
  ///
  /// In vi, this message translates to:
  /// **'Thất bại, từ chối'**
  String get anomalyFailure;

  /// No description provided for @auditTotal.
  ///
  /// In vi, this message translates to:
  /// **'Tổng sự kiện'**
  String get auditTotal;

  /// No description provided for @auditByRegion.
  ///
  /// In vi, this message translates to:
  /// **'Theo khu vực'**
  String get auditByRegion;

  /// No description provided for @auditByHour.
  ///
  /// In vi, this message translates to:
  /// **'Theo giờ địa phương (đỏ là ngoài giờ)'**
  String get auditByHour;

  /// No description provided for @auditByDay.
  ///
  /// In vi, this message translates to:
  /// **'Theo ngày'**
  String get auditByDay;

  /// No description provided for @auditByType.
  ///
  /// In vi, this message translates to:
  /// **'Loại sự kiện nhiều nhất'**
  String get auditByType;

  /// No description provided for @auditByService.
  ///
  /// In vi, this message translates to:
  /// **'Theo dịch vụ'**
  String get auditByService;

  /// No description provided for @clearFilters.
  ///
  /// In vi, this message translates to:
  /// **'Xóa bộ lọc'**
  String get clearFilters;

  /// No description provided for @auditSignedExport.
  ///
  /// In vi, this message translates to:
  /// **'Xuất CSV có mã SHA-256'**
  String get auditSignedExport;

  /// No description provided for @approvalInbox.
  ///
  /// In vi, this message translates to:
  /// **'Hộp duyệt chung'**
  String get approvalInbox;

  /// No description provided for @approvalInboxHint.
  ///
  /// In vi, this message translates to:
  /// **'Dự án, thăng chức, tăng lương chờ duyệt ở 6 khu vực'**
  String get approvalInboxHint;

  /// No description provided for @approvalKindProject.
  ///
  /// In vi, this message translates to:
  /// **'Dự án'**
  String get approvalKindProject;

  /// No description provided for @approvalKindPromotion.
  ///
  /// In vi, this message translates to:
  /// **'Thăng chức'**
  String get approvalKindPromotion;

  /// No description provided for @approvalKindRaise.
  ///
  /// In vi, this message translates to:
  /// **'Tăng lương'**
  String get approvalKindRaise;

  /// No description provided for @noApprovals.
  ///
  /// In vi, this message translates to:
  /// **'Không còn đề xuất nào chờ duyệt'**
  String get noApprovals;

  /// No description provided for @approvalWaiting.
  ///
  /// In vi, this message translates to:
  /// **'{count} đề xuất chờ duyệt'**
  String approvalWaiting(int count);

  /// No description provided for @approvalRegionsDown.
  ///
  /// In vi, this message translates to:
  /// **'Chưa lấy được dữ liệu của: {regions}'**
  String approvalRegionsDown(String regions);

  /// No description provided for @approvalByRegion.
  ///
  /// In vi, this message translates to:
  /// **'Chờ duyệt theo khu vực'**
  String get approvalByRegion;

  /// No description provided for @approvalPromotionLine.
  ///
  /// In vi, this message translates to:
  /// **'Lên {position}, tăng {percent}% lương'**
  String approvalPromotionLine(String position, String percent);

  /// No description provided for @approvalDone.
  ///
  /// In vi, this message translates to:
  /// **'Đã ghi quyết định'**
  String get approvalDone;

  /// No description provided for @approvalConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Duyệt {title}?'**
  String approvalConfirm(String title);

  /// No description provided for @approvalRejectConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Từ chối {title}?'**
  String approvalRejectConfirm(String title);

  /// No description provided for @approvalColKind.
  ///
  /// In vi, this message translates to:
  /// **'Loại'**
  String get approvalColKind;

  /// No description provided for @approvalColTitle.
  ///
  /// In vi, this message translates to:
  /// **'Nội dung'**
  String get approvalColTitle;

  /// No description provided for @approvalColDetail.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết'**
  String get approvalColDetail;

  /// No description provided for @approvalColUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật'**
  String get approvalColUpdated;

  /// No description provided for @jobPositions.
  ///
  /// In vi, this message translates to:
  /// **'Vị trí tuyển dụng'**
  String get jobPositions;

  /// No description provided for @jobPositionsHint.
  ///
  /// In vi, this message translates to:
  /// **'Mở vị trí, số người cần tuyển, xem ứng viên theo điểm AI'**
  String get jobPositionsHint;

  /// No description provided for @newJobPosition.
  ///
  /// In vi, this message translates to:
  /// **'Mở vị trí'**
  String get newJobPosition;

  /// No description provided for @editJobPosition.
  ///
  /// In vi, this message translates to:
  /// **'Sửa vị trí'**
  String get editJobPosition;

  /// No description provided for @noJobPositions.
  ///
  /// In vi, this message translates to:
  /// **'Chưa mở vị trí tuyển dụng nào'**
  String get noJobPositions;

  /// No description provided for @positionTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tên vị trí'**
  String get positionTitle;

  /// No description provided for @positionDepartment.
  ///
  /// In vi, this message translates to:
  /// **'Phòng ban'**
  String get positionDepartment;

  /// No description provided for @positionHeadcount.
  ///
  /// In vi, this message translates to:
  /// **'Số người cần tuyển'**
  String get positionHeadcount;

  /// No description provided for @positionDescription.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả công việc'**
  String get positionDescription;

  /// No description provided for @positionRequirements.
  ///
  /// In vi, this message translates to:
  /// **'Yêu cầu'**
  String get positionRequirements;

  /// No description provided for @positionRequirementsHint.
  ///
  /// In vi, this message translates to:
  /// **'AI dựa vào phần này để chấm mức phù hợp của CV'**
  String get positionRequirementsHint;

  /// No description provided for @positionOpen.
  ///
  /// In vi, this message translates to:
  /// **'Đang tuyển'**
  String get positionOpen;

  /// No description provided for @positionFilled.
  ///
  /// In vi, this message translates to:
  /// **'Đã đủ người'**
  String get positionFilled;

  /// No description provided for @positionClosed.
  ///
  /// In vi, this message translates to:
  /// **'Đã đóng'**
  String get positionClosed;

  /// No description provided for @closePosition.
  ///
  /// In vi, this message translates to:
  /// **'Đóng vị trí'**
  String get closePosition;

  /// No description provided for @reopenPosition.
  ///
  /// In vi, this message translates to:
  /// **'Mở lại'**
  String get reopenPosition;

  /// No description provided for @positionSaved.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu vị trí tuyển dụng'**
  String get positionSaved;

  /// No description provided for @positionApplicants.
  ///
  /// In vi, this message translates to:
  /// **'Ứng viên (điểm AI cao trước)'**
  String get positionApplicants;

  /// No description provided for @positionProgress.
  ///
  /// In vi, this message translates to:
  /// **'Đã tuyển {hired}/{headcount} · {applicants} ứng viên'**
  String positionProgress(int hired, int headcount, int applicants);

  /// No description provided for @positionSlotsLeft.
  ///
  /// In vi, this message translates to:
  /// **'Còn {count} chỗ'**
  String positionSlotsLeft(int count);

  /// No description provided for @choosePositions.
  ///
  /// In vi, this message translates to:
  /// **'Chọn vị trí ứng tuyển'**
  String get choosePositions;

  /// No description provided for @choosePositionsHint.
  ///
  /// In vi, this message translates to:
  /// **'Bấm để chọn'**
  String get choosePositionsHint;

  /// No description provided for @choosePositionsHelper.
  ///
  /// In vi, this message translates to:
  /// **'Chọn một hoặc nhiều vị trí, tối đa {max}'**
  String choosePositionsHelper(int max);

  /// No description provided for @positionsChosen.
  ///
  /// In vi, this message translates to:
  /// **'Xong ({count} vị trí)'**
  String positionsChosen(int count);

  /// No description provided for @positionMatchTitle.
  ///
  /// In vi, this message translates to:
  /// **'Mức phù hợp với vị trí (AI)'**
  String get positionMatchTitle;

  /// No description provided for @positionMatchPending.
  ///
  /// In vi, this message translates to:
  /// **'AI đang so khớp'**
  String get positionMatchPending;

  /// No description provided for @positionMatchNone.
  ///
  /// In vi, this message translates to:
  /// **'Chưa so khớp'**
  String get positionMatchNone;

  /// No description provided for @positionMatchStrengths.
  ///
  /// In vi, this message translates to:
  /// **'Đáp ứng'**
  String get positionMatchStrengths;

  /// No description provided for @positionMatchGaps.
  ///
  /// In vi, this message translates to:
  /// **'Còn thiếu'**
  String get positionMatchGaps;

  /// No description provided for @bestMatch.
  ///
  /// In vi, this message translates to:
  /// **'Phù hợp {score}%'**
  String bestMatch(int score);

  /// No description provided for @errNoPosition.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ít nhất một vị trí ứng tuyển'**
  String get errNoPosition;

  /// No description provided for @errTooManyPositions.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ chọn tối đa 5 vị trí'**
  String get errTooManyPositions;

  /// No description provided for @errPositionUnavailable.
  ///
  /// In vi, this message translates to:
  /// **'Vị trí này đã đóng hoặc đã đủ người, chọn vị trí khác'**
  String get errPositionUnavailable;

  /// No description provided for @errPositionTitleExists.
  ///
  /// In vi, this message translates to:
  /// **'Đã có vị trí đang tuyển cùng tên'**
  String get errPositionTitleExists;

  /// No description provided for @errInvalidHeadcount.
  ///
  /// In vi, this message translates to:
  /// **'Số người cần tuyển từ 1 đến 500'**
  String get errInvalidHeadcount;

  /// No description provided for @errHeadcountBelowHired.
  ///
  /// In vi, this message translates to:
  /// **'Đã tuyển {hired} người, không thể đặt thấp hơn'**
  String errHeadcountBelowHired(int hired);

  /// No description provided for @errInvalidPosition.
  ///
  /// In vi, this message translates to:
  /// **'Nhập tên vị trí và số người cần tuyển'**
  String get errInvalidPosition;

  /// No description provided for @nRaiseRequested.
  ///
  /// In vi, this message translates to:
  /// **'{employee} gửi đề xuất tăng lương'**
  String nRaiseRequested(String employee);

  /// No description provided for @nRaiseForwarded.
  ///
  /// In vi, this message translates to:
  /// **'HR chuyển đề xuất tăng lương của {employee}, cần bạn duyệt'**
  String nRaiseForwarded(String employee);

  /// No description provided for @nRaiseApproved.
  ///
  /// In vi, this message translates to:
  /// **'Đề xuất tăng lương của bạn đã được duyệt'**
  String get nRaiseApproved;

  /// No description provided for @nRaiseRejected.
  ///
  /// In vi, this message translates to:
  /// **'Đề xuất tăng lương của bạn bị từ chối'**
  String get nRaiseRejected;

  /// No description provided for @nRaiseReturned.
  ///
  /// In vi, this message translates to:
  /// **'Đề xuất tăng lương được trả lại, mời bạn xem và sửa'**
  String get nRaiseReturned;

  /// No description provided for @nReportSubmitted.
  ///
  /// In vi, this message translates to:
  /// **'Có báo cáo {report} kỳ {period} gửi lên cần xác nhận'**
  String nReportSubmitted(String report, String period);

  /// No description provided for @nReportAcknowledged.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo {report} kỳ {period} đã được xác nhận'**
  String nReportAcknowledged(String report, String period);

  /// No description provided for @nReportReturned.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo {report} kỳ {period} bị trả lại, xem ghi chú'**
  String nReportReturned(String report, String period);

  /// No description provided for @nResignationRequested.
  ///
  /// In vi, this message translates to:
  /// **'{employee} xin thôi việc, ngày làm cuối {date}'**
  String nResignationRequested(String employee, String date);

  /// No description provided for @nResignationApproved.
  ///
  /// In vi, this message translates to:
  /// **'Đơn thôi việc của bạn đã được duyệt, ngày làm cuối {date}'**
  String nResignationApproved(String date);

  /// No description provided for @nResignationRejected.
  ///
  /// In vi, this message translates to:
  /// **'Đơn thôi việc của bạn không được duyệt'**
  String get nResignationRejected;

  /// No description provided for @nResignationWithdrawn.
  ///
  /// In vi, this message translates to:
  /// **'{employee} đã rút đơn thôi việc'**
  String nResignationWithdrawn(String employee);

  /// No description provided for @reportKindHr.
  ///
  /// In vi, this message translates to:
  /// **'nhân sự'**
  String get reportKindHr;

  /// No description provided for @reportKindFinance.
  ///
  /// In vi, this message translates to:
  /// **'tài chính'**
  String get reportKindFinance;

  /// No description provided for @openFullPage.
  ///
  /// In vi, this message translates to:
  /// **'Mở màn đầy đủ'**
  String get openFullPage;

  /// No description provided for @requestAlreadyHandled.
  ///
  /// In vi, this message translates to:
  /// **'Đơn này đã được xử lý'**
  String get requestAlreadyHandled;

  /// No description provided for @requestFrom.
  ///
  /// In vi, this message translates to:
  /// **'Người gửi'**
  String get requestFrom;

  /// No description provided for @waitingSuperior.
  ///
  /// In vi, this message translates to:
  /// **'Chờ cấp trên duyệt'**
  String get waitingSuperior;

  /// No description provided for @signupTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký tài khoản ứng viên'**
  String get signupTitle;

  /// No description provided for @signupHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập thông tin thật của bạn. Mã xác nhận 6 số sẽ gửi về email này.'**
  String get signupHint;

  /// No description provided for @sendCode.
  ///
  /// In vi, this message translates to:
  /// **'Gửi mã xác nhận'**
  String get sendCode;

  /// No description provided for @codeSentTo.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi mã tới {email}, kiểm tra cả thư mục Spam'**
  String codeSentTo(String email);

  /// No description provided for @verificationCode.
  ///
  /// In vi, this message translates to:
  /// **'Mã xác nhận (6 số)'**
  String get verificationCode;

  /// No description provided for @newPassword.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu'**
  String get newPassword;

  /// No description provided for @passwordRule.
  ///
  /// In vi, this message translates to:
  /// **'Ít nhất 8 ký tự, có cả chữ và số'**
  String get passwordRule;

  /// No description provided for @confirmPassword.
  ///
  /// In vi, this message translates to:
  /// **'Nhập lại mật khẩu'**
  String get confirmPassword;

  /// No description provided for @createAccount.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận và tạo tài khoản'**
  String get createAccount;

  /// No description provided for @resendCode.
  ///
  /// In vi, this message translates to:
  /// **'Gửi lại mã'**
  String get resendCode;

  /// No description provided for @resendIn.
  ///
  /// In vi, this message translates to:
  /// **'Gửi lại mã sau {seconds} giây'**
  String resendIn(int seconds);

  /// No description provided for @editDetails.
  ///
  /// In vi, this message translates to:
  /// **'Sửa họ tên, email, số điện thoại'**
  String get editDetails;

  /// No description provided for @signupDone.
  ///
  /// In vi, this message translates to:
  /// **'Đã tạo tài khoản, mời bạn đăng nhập'**
  String get signupDone;

  /// No description provided for @changePassword.
  ///
  /// In vi, this message translates to:
  /// **'Đổi mật khẩu'**
  String get changePassword;

  /// No description provided for @passwordChanged.
  ///
  /// In vi, this message translates to:
  /// **'Đã đổi mật khẩu'**
  String get passwordChanged;

  /// No description provided for @profileViewed.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ của bạn đã được xem'**
  String get profileViewed;

  /// No description provided for @profileViewedHint.
  ///
  /// In vi, this message translates to:
  /// **'HR đã mở xem hồ sơ nên bạn không sửa thông tin, đổi CV được nữa'**
  String get profileViewedHint;

  /// No description provided for @cvRequired.
  ///
  /// In vi, this message translates to:
  /// **'Đính kèm CV (PDF) để lưu hồ sơ'**
  String get cvRequired;

  /// No description provided for @accountDetails.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin từ tài khoản đăng ký'**
  String get accountDetails;

  /// No description provided for @errInvalidEmail.
  ///
  /// In vi, this message translates to:
  /// **'Email không hợp lệ'**
  String get errInvalidEmail;

  /// No description provided for @errInvalidName.
  ///
  /// In vi, this message translates to:
  /// **'Họ tên từ 2 đến 80 ký tự'**
  String get errInvalidName;

  /// No description provided for @errInvalidPhone.
  ///
  /// In vi, this message translates to:
  /// **'Số điện thoại không hợp lệ'**
  String get errInvalidPhone;

  /// No description provided for @errWeakPassword.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu cần ít nhất 8 ký tự, có cả chữ và số'**
  String get errWeakPassword;

  /// No description provided for @errEmailTaken.
  ///
  /// In vi, this message translates to:
  /// **'Email này đã có tài khoản, hãy đăng nhập'**
  String get errEmailTaken;

  /// No description provided for @errCodeTooSoon.
  ///
  /// In vi, this message translates to:
  /// **'Vừa gửi mã, chờ 60 giây rồi gửi lại'**
  String get errCodeTooSoon;

  /// No description provided for @errCodeExpired.
  ///
  /// In vi, this message translates to:
  /// **'Mã đã hết hạn hoặc nhập sai quá nhiều lần, hãy gửi lại mã'**
  String get errCodeExpired;

  /// No description provided for @errWrongCode.
  ///
  /// In vi, this message translates to:
  /// **'Mã xác nhận không đúng'**
  String get errWrongCode;

  /// No description provided for @errSignupUnavailable.
  ///
  /// In vi, this message translates to:
  /// **'Chưa gửi được email lúc này, thử lại sau ít phút'**
  String get errSignupUnavailable;

  /// No description provided for @projectTime.
  ///
  /// In vi, this message translates to:
  /// **'Thời gian'**
  String get projectTime;

  /// No description provided for @me.
  ///
  /// In vi, this message translates to:
  /// **'Tôi'**
  String get me;

  /// No description provided for @myProjectPay.
  ///
  /// In vi, this message translates to:
  /// **'Tiền dự án của tôi: {amount}'**
  String myProjectPay(String amount);

  /// No description provided for @mySchedule.
  ///
  /// In vi, this message translates to:
  /// **'Lịch làm việc của tôi'**
  String get mySchedule;

  /// No description provided for @myScheduleHint.
  ///
  /// In vi, this message translates to:
  /// **'Tháng này đã đi làm {days} buổi trong thời gian dự án'**
  String myScheduleHint(int days);

  /// No description provided for @myScheduleEarned.
  ///
  /// In vi, this message translates to:
  /// **'Tiền ước tính theo các buổi đi làm: {amount}'**
  String myScheduleEarned(String amount);

  /// No description provided for @notCheckedIn.
  ///
  /// In vi, this message translates to:
  /// **'Chưa chấm công'**
  String get notCheckedIn;

  /// No description provided for @contractRequired.
  ///
  /// In vi, this message translates to:
  /// **'Bắt buộc tải hợp đồng (PDF, Word) để AI đọc ra thông tin dự án'**
  String get contractRequired;

  /// No description provided for @attachedBonuses.
  ///
  /// In vi, this message translates to:
  /// **'Thưởng phạt 12 tháng qua (gửi kèm đề xuất)'**
  String get attachedBonuses;

  /// No description provided for @bonusNet.
  ///
  /// In vi, this message translates to:
  /// **'Cộng dồn: {amount}'**
  String bonusNet(String amount);

  /// No description provided for @moreItems.
  ///
  /// In vi, this message translates to:
  /// **'và {count} khoản khác'**
  String moreItems(int count);

  /// No description provided for @orgTree.
  ///
  /// In vi, this message translates to:
  /// **'Sơ đồ tổ chức'**
  String get orgTree;

  /// No description provided for @orgTreeSearch.
  ///
  /// In vi, this message translates to:
  /// **'Tìm người, chức vụ (gõ không dấu cũng được)'**
  String get orgTreeSearch;

  /// No description provided for @orgTreeSummary.
  ///
  /// In vi, this message translates to:
  /// **'{departments} phòng ban · {people} người'**
  String orgTreeSummary(int departments, int people);

  /// No description provided for @orgTreeToggle.
  ///
  /// In vi, this message translates to:
  /// **'Thu gọn hoặc mở tất cả'**
  String get orgTreeToggle;

  /// No description provided for @level1.
  ///
  /// In vi, this message translates to:
  /// **'Nhân viên'**
  String get level1;

  /// No description provided for @level2.
  ///
  /// In vi, this message translates to:
  /// **'Chuyên viên, kỹ sư'**
  String get level2;

  /// No description provided for @level3.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ huy, phó phòng'**
  String get level3;

  /// No description provided for @level4.
  ///
  /// In vi, this message translates to:
  /// **'Trưởng phòng, quản lý'**
  String get level4;

  /// No description provided for @level5.
  ///
  /// In vi, this message translates to:
  /// **'Giám đốc khối'**
  String get level5;

  /// No description provided for @level6.
  ///
  /// In vi, this message translates to:
  /// **'Ban lãnh đạo'**
  String get level6;

  /// No description provided for @noHigherPosition.
  ///
  /// In vi, this message translates to:
  /// **'Người này đã ở cấp cao nhất trong cây chức vụ'**
  String get noHigherPosition;

  /// No description provided for @errNotHigherPosition.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ đề cử lên chức vụ cấp cao hơn hiện tại'**
  String get errNotHigherPosition;

  /// No description provided for @errUnknownPosition.
  ///
  /// In vi, this message translates to:
  /// **'Chọn chức vụ trong danh sách'**
  String get errUnknownPosition;

  /// No description provided for @overtimeApprovedToday.
  ///
  /// In vi, this message translates to:
  /// **'Tăng ca đã duyệt {hours} giờ: làm tới {until} vẫn được tính'**
  String overtimeApprovedToday(String hours, String until);

  /// No description provided for @overtimePendingToday.
  ///
  /// In vi, this message translates to:
  /// **'Đơn tăng ca {hours} giờ đang chờ duyệt: chưa được tính cho tới khi duyệt'**
  String overtimePendingToday(String hours);

  /// No description provided for @overtimeNoneToday.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có đơn tăng ca được duyệt: làm quá giờ ca sẽ không được tính'**
  String get overtimeNoneToday;

  /// No description provided for @viewZoomIn.
  ///
  /// In vi, this message translates to:
  /// **'Phóng to'**
  String get viewZoomIn;

  /// No description provided for @viewZoomOut.
  ///
  /// In vi, this message translates to:
  /// **'Thu nhỏ'**
  String get viewZoomOut;

  /// No description provided for @viewFromTop.
  ///
  /// In vi, this message translates to:
  /// **'Nhìn từ trên xuống'**
  String get viewFromTop;

  /// No description provided for @viewFromBottom.
  ///
  /// In vi, this message translates to:
  /// **'Nhìn từ dưới lên'**
  String get viewFromBottom;

  /// No description provided for @viewRotateLeft.
  ///
  /// In vi, this message translates to:
  /// **'Xoay trái'**
  String get viewRotateLeft;

  /// No description provided for @viewRotateRight.
  ///
  /// In vi, this message translates to:
  /// **'Xoay phải'**
  String get viewRotateRight;

  /// No description provided for @viewReset.
  ///
  /// In vi, this message translates to:
  /// **'Về góc nhìn ban đầu'**
  String get viewReset;

  /// No description provided for @sectionGroup.
  ///
  /// In vi, this message translates to:
  /// **'Tập đoàn'**
  String get sectionGroup;

  /// No description provided for @sectionAdmin.
  ///
  /// In vi, this message translates to:
  /// **'Quản trị'**
  String get sectionAdmin;

  /// No description provided for @roleGroup.
  ///
  /// In vi, this message translates to:
  /// **'Cấp tập đoàn'**
  String get roleGroup;

  /// No description provided for @groupOverview.
  ///
  /// In vi, this message translates to:
  /// **'Tổng quan tập đoàn'**
  String get groupOverview;

  /// No description provided for @groupOverviewHint.
  ///
  /// In vi, this message translates to:
  /// **'Số liệu từng nước, bấm vào một nước để xem chi tiết'**
  String get groupOverviewHint;

  /// No description provided for @adminConsole.
  ///
  /// In vi, this message translates to:
  /// **'Quản trị dữ liệu'**
  String get adminConsole;

  /// No description provided for @adminConsoleHint.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản, lịch làm việc, chức vụ, thống kê, sao lưu, SQL'**
  String get adminConsoleHint;

  /// No description provided for @viewingRegion.
  ///
  /// In vi, this message translates to:
  /// **'Đang xem: {region}'**
  String viewingRegion(String region);

  /// No description provided for @chooseRegion.
  ///
  /// In vi, this message translates to:
  /// **'Chọn khu vực cần xem'**
  String get chooseRegion;

  /// No description provided for @approvalKindLeave.
  ///
  /// In vi, this message translates to:
  /// **'Đơn nghỉ'**
  String get approvalKindLeave;

  /// No description provided for @approvalKindOvertime.
  ///
  /// In vi, this message translates to:
  /// **'Tăng ca'**
  String get approvalKindOvertime;

  /// No description provided for @approvalKindProfile.
  ///
  /// In vi, this message translates to:
  /// **'Sửa hồ sơ'**
  String get approvalKindProfile;

  /// No description provided for @approvalKindResignation.
  ///
  /// In vi, this message translates to:
  /// **'Thôi việc'**
  String get approvalKindResignation;

  /// No description provided for @groupTotals.
  ///
  /// In vi, this message translates to:
  /// **'Toàn tập đoàn'**
  String get groupTotals;

  /// No description provided for @groupEmployees.
  ///
  /// In vi, this message translates to:
  /// **'Nhân viên'**
  String get groupEmployees;

  /// No description provided for @groupRevenueYtd.
  ///
  /// In vi, this message translates to:
  /// **'Doanh thu năm nay (USD)'**
  String get groupRevenueYtd;

  /// No description provided for @groupCostYtd.
  ///
  /// In vi, this message translates to:
  /// **'Chi phí năm nay (USD)'**
  String get groupCostYtd;

  /// No description provided for @groupRegionDown.
  ///
  /// In vi, this message translates to:
  /// **'Chưa lấy được số liệu của nước này, kéo xuống để thử lại'**
  String get groupRegionDown;

  /// No description provided for @execActions.
  ///
  /// In vi, this message translates to:
  /// **'Làm thẳng'**
  String get execActions;

  /// No description provided for @execChangePosition.
  ///
  /// In vi, this message translates to:
  /// **'Thăng chức, đổi chức vụ'**
  String get execChangePosition;

  /// No description provided for @execPromote.
  ///
  /// In vi, this message translates to:
  /// **'Thăng chức'**
  String get execPromote;

  /// No description provided for @execChangeOnly.
  ///
  /// In vi, this message translates to:
  /// **'Đổi chức vụ'**
  String get execChangeOnly;

  /// No description provided for @execNewPosition.
  ///
  /// In vi, this message translates to:
  /// **'Chức vụ mới'**
  String get execNewPosition;

  /// No description provided for @execNoHigherPosition.
  ///
  /// In vi, this message translates to:
  /// **'Không còn chức vụ cấp cao hơn để thăng'**
  String get execNoHigherPosition;

  /// No description provided for @execReason.
  ///
  /// In vi, this message translates to:
  /// **'Lý do (ghi vào sổ kiểm toán)'**
  String get execReason;

  /// No description provided for @execReasonRequired.
  ///
  /// In vi, this message translates to:
  /// **'Lý do (bắt buộc)'**
  String get execReasonRequired;

  /// No description provided for @execSalary.
  ///
  /// In vi, this message translates to:
  /// **'Đổi lương cơ bản'**
  String get execSalary;

  /// No description provided for @execCurrentSalary.
  ///
  /// In vi, this message translates to:
  /// **'Lương cơ bản hiện tại: {amount}'**
  String execCurrentSalary(String amount);

  /// No description provided for @execNewSalary.
  ///
  /// In vi, this message translates to:
  /// **'Lương cơ bản mới'**
  String get execNewSalary;

  /// No description provided for @execBonus.
  ///
  /// In vi, this message translates to:
  /// **'Thưởng, phạt'**
  String get execBonus;

  /// No description provided for @execBonusKind.
  ///
  /// In vi, this message translates to:
  /// **'Thưởng'**
  String get execBonusKind;

  /// No description provided for @execPenaltyKind.
  ///
  /// In vi, this message translates to:
  /// **'Phạt'**
  String get execPenaltyKind;

  /// No description provided for @execAmount.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền (theo tiền lương của nhân viên)'**
  String get execAmount;

  /// No description provided for @execApply.
  ///
  /// In vi, this message translates to:
  /// **'Áp dụng ngay'**
  String get execApply;

  /// No description provided for @execAuditNote.
  ///
  /// In vi, this message translates to:
  /// **'Có hiệu lực ngay, không qua ai duyệt; ghi vào sổ kiểm toán kèm tên người thực hiện.'**
  String get execAuditNote;

  /// No description provided for @execApplied.
  ///
  /// In vi, this message translates to:
  /// **'Đã áp dụng và ghi vào sổ kiểm toán'**
  String get execApplied;

  /// No description provided for @nominationScope.
  ///
  /// In vi, this message translates to:
  /// **'Phạm vi'**
  String get nominationScope;

  /// No description provided for @nominationScopeRegion.
  ///
  /// In vi, this message translates to:
  /// **'Thăng chức trong nước'**
  String get nominationScopeRegion;

  /// No description provided for @nominationScopeGroupHr.
  ///
  /// In vi, this message translates to:
  /// **'Lên Nhân sự tập đoàn'**
  String get nominationScopeGroupHr;

  /// No description provided for @nominationScopeGroupFinance.
  ///
  /// In vi, this message translates to:
  /// **'Lên Tài chính tập đoàn'**
  String get nominationScopeGroupFinance;

  /// No description provided for @nominationGroupNote.
  ///
  /// In vi, this message translates to:
  /// **'Văn phòng quản lý tập đoàn duyệt; duyệt xong người này làm việc được ở mọi khu vực.'**
  String get nominationGroupNote;

  /// No description provided for @nominationToGroup.
  ///
  /// In vi, this message translates to:
  /// **'Lên cấp tập đoàn'**
  String get nominationToGroup;

  /// No description provided for @adminTabOverview.
  ///
  /// In vi, this message translates to:
  /// **'Tổng quan'**
  String get adminTabOverview;

  /// No description provided for @adminTabAccounts.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản'**
  String get adminTabAccounts;

  /// No description provided for @adminTabCalendar.
  ///
  /// In vi, this message translates to:
  /// **'Lịch làm việc'**
  String get adminTabCalendar;

  /// No description provided for @adminTabPositions.
  ///
  /// In vi, this message translates to:
  /// **'Chức vụ'**
  String get adminTabPositions;

  /// No description provided for @adminTabData.
  ///
  /// In vi, this message translates to:
  /// **'Dữ liệu'**
  String get adminTabData;

  /// No description provided for @adminAccountsByRole.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản theo vai trò'**
  String get adminAccountsByRole;

  /// No description provided for @adminAccountsTotal.
  ///
  /// In vi, this message translates to:
  /// **'{n} tài khoản'**
  String adminAccountsTotal(int n);

  /// No description provided for @adminDatabases.
  ///
  /// In vi, this message translates to:
  /// **'Cơ sở dữ liệu'**
  String get adminDatabases;

  /// No description provided for @adminDbLine.
  ///
  /// In vi, this message translates to:
  /// **'{tables} bảng · {rows} dòng · {size}'**
  String adminDbLine(int tables, String rows, String size);

  /// No description provided for @adminActivity.
  ///
  /// In vi, this message translates to:
  /// **'Hoạt động 14 ngày qua (số sự kiện)'**
  String get adminActivity;

  /// No description provided for @adminRowsByDb.
  ///
  /// In vi, this message translates to:
  /// **'Số dòng theo cơ sở dữ liệu'**
  String get adminRowsByDb;

  /// No description provided for @adminDbUnavailable.
  ///
  /// In vi, this message translates to:
  /// **'Chưa đọc được cơ sở dữ liệu này'**
  String get adminDbUnavailable;

  /// No description provided for @adminSearchAccounts.
  ///
  /// In vi, this message translates to:
  /// **'Tìm tên, email, tên đăng nhập'**
  String get adminSearchAccounts;

  /// No description provided for @adminAccountDisabled.
  ///
  /// In vi, this message translates to:
  /// **'Đã khóa'**
  String get adminAccountDisabled;

  /// No description provided for @adminEditAccount.
  ///
  /// In vi, this message translates to:
  /// **'Sửa tài khoản {name}'**
  String adminEditAccount(String name);

  /// No description provided for @adminAccountEnabled.
  ///
  /// In vi, this message translates to:
  /// **'Cho phép đăng nhập'**
  String get adminAccountEnabled;

  /// No description provided for @adminRoles.
  ///
  /// In vi, this message translates to:
  /// **'Vai trò'**
  String get adminRoles;

  /// No description provided for @adminSaved.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu và ghi vào sổ kiểm toán'**
  String get adminSaved;

  /// No description provided for @adminHolidays.
  ///
  /// In vi, this message translates to:
  /// **'Ngày lễ'**
  String get adminHolidays;

  /// No description provided for @adminAddHoliday.
  ///
  /// In vi, this message translates to:
  /// **'Thêm ngày lễ'**
  String get adminAddHoliday;

  /// No description provided for @adminHolidayName.
  ///
  /// In vi, this message translates to:
  /// **'Tên ngày lễ'**
  String get adminHolidayName;

  /// No description provided for @adminHolidayRemove.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ ngày lễ {name}?'**
  String adminHolidayRemove(String name);

  /// No description provided for @adminNoHolidays.
  ///
  /// In vi, this message translates to:
  /// **'Năm này chưa có ngày lễ nào'**
  String get adminNoHolidays;

  /// No description provided for @adminShift.
  ///
  /// In vi, this message translates to:
  /// **'Giờ ca làm'**
  String get adminShift;

  /// No description provided for @adminShiftHint.
  ///
  /// In vi, this message translates to:
  /// **'Đổi giờ vào, giờ ra cho mọi ca trong khoảng ngày (chỉ từ hôm nay trở đi, công đã chấm giữ nguyên)'**
  String get adminShiftHint;

  /// No description provided for @adminShiftChange.
  ///
  /// In vi, this message translates to:
  /// **'Đổi giờ ca'**
  String get adminShiftChange;

  /// No description provided for @adminShiftStart.
  ///
  /// In vi, this message translates to:
  /// **'Giờ vào'**
  String get adminShiftStart;

  /// No description provided for @adminShiftEnd.
  ///
  /// In vi, this message translates to:
  /// **'Giờ ra'**
  String get adminShiftEnd;

  /// No description provided for @adminShiftRange.
  ///
  /// In vi, this message translates to:
  /// **'Khoảng ngày'**
  String get adminShiftRange;

  /// No description provided for @adminShiftDone.
  ///
  /// In vi, this message translates to:
  /// **'Đã đổi giờ cho {n} ca làm'**
  String adminShiftDone(int n);

  /// No description provided for @adminAddPosition.
  ///
  /// In vi, this message translates to:
  /// **'Thêm chức vụ'**
  String get adminAddPosition;

  /// No description provided for @adminEditPosition.
  ///
  /// In vi, this message translates to:
  /// **'Sửa chức vụ'**
  String get adminEditPosition;

  /// No description provided for @adminPositionName.
  ///
  /// In vi, this message translates to:
  /// **'Tên chức vụ'**
  String get adminPositionName;

  /// No description provided for @adminPositionLevel.
  ///
  /// In vi, this message translates to:
  /// **'Cấp'**
  String get adminPositionLevel;

  /// No description provided for @adminCoefficient.
  ///
  /// In vi, this message translates to:
  /// **'Hệ số lương'**
  String get adminCoefficient;

  /// No description provided for @adminHolders.
  ///
  /// In vi, this message translates to:
  /// **'{n} người đang giữ'**
  String adminHolders(int n);

  /// No description provided for @adminDeletePosition.
  ///
  /// In vi, this message translates to:
  /// **'Xóa chức vụ'**
  String get adminDeletePosition;

  /// No description provided for @adminSql.
  ///
  /// In vi, this message translates to:
  /// **'Truy vấn SQL'**
  String get adminSql;

  /// No description provided for @adminSqlHint.
  ///
  /// In vi, this message translates to:
  /// **'Mặc định chỉ đọc; mỗi lần chạy đều được ghi vào sổ kiểm toán'**
  String get adminSqlHint;

  /// No description provided for @adminSqlWrite.
  ///
  /// In vi, this message translates to:
  /// **'Cho phép ghi (INSERT, UPDATE, DELETE)'**
  String get adminSqlWrite;

  /// No description provided for @adminSqlWriteConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Câu lệnh sẽ sửa dữ liệu thật và được ghi vào sổ kiểm toán. Chạy?'**
  String get adminSqlWriteConfirm;

  /// No description provided for @adminSqlRun.
  ///
  /// In vi, this message translates to:
  /// **'Chạy'**
  String get adminSqlRun;

  /// No description provided for @adminSqlRows.
  ///
  /// In vi, this message translates to:
  /// **'{n} dòng'**
  String adminSqlRows(int n);

  /// No description provided for @adminSqlAffected.
  ///
  /// In vi, this message translates to:
  /// **'Đã tác động {n} dòng'**
  String adminSqlAffected(int n);

  /// No description provided for @adminSqlTruncated.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ hiện 500 dòng đầu'**
  String get adminSqlTruncated;

  /// No description provided for @adminTechnical.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết kỹ thuật'**
  String get adminTechnical;

  /// No description provided for @adminBackups.
  ///
  /// In vi, this message translates to:
  /// **'Sao lưu'**
  String get adminBackups;

  /// No description provided for @adminBackupNow.
  ///
  /// In vi, this message translates to:
  /// **'Sao lưu ngay'**
  String get adminBackupNow;

  /// No description provided for @adminBackupDone.
  ///
  /// In vi, this message translates to:
  /// **'Đã sao lưu toàn bộ dữ liệu khu vực'**
  String get adminBackupDone;

  /// No description provided for @adminBackupNone.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có bản sao lưu'**
  String get adminBackupNone;

  /// No description provided for @adminDownload.
  ///
  /// In vi, this message translates to:
  /// **'Tải về'**
  String get adminDownload;

  /// No description provided for @errGroupOnly.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ văn phòng quản lý tập đoàn duyệt được đề cử này'**
  String get errGroupOnly;

  /// No description provided for @errSamePosition.
  ///
  /// In vi, this message translates to:
  /// **'Nhân viên đang giữ chức vụ này rồi'**
  String get errSamePosition;

  /// No description provided for @errInUse.
  ///
  /// In vi, this message translates to:
  /// **'Còn người giữ chức vụ này nên chưa xóa được'**
  String get errInUse;

  /// No description provided for @errReadOnly.
  ///
  /// In vi, this message translates to:
  /// **'Câu lệnh có ghi dữ liệu; bật Cho phép ghi nếu thật sự muốn sửa'**
  String get errReadOnly;

  /// No description provided for @errSqlError.
  ///
  /// In vi, this message translates to:
  /// **'Câu lệnh không chạy được, xem chi tiết kỹ thuật bên dưới'**
  String get errSqlError;

  /// No description provided for @errUnknownDatabase.
  ///
  /// In vi, this message translates to:
  /// **'Chọn cơ sở dữ liệu trong danh sách'**
  String get errUnknownDatabase;

  /// No description provided for @errEmptySql.
  ///
  /// In vi, this message translates to:
  /// **'Nhập câu lệnh SQL'**
  String get errEmptySql;

  /// No description provided for @errStorageUnavailable.
  ///
  /// In vi, this message translates to:
  /// **'Kho lưu trữ chưa sẵn sàng, thử lại sau'**
  String get errStorageUnavailable;

  /// No description provided for @errIdentityUnavailable.
  ///
  /// In vi, this message translates to:
  /// **'Chưa kết nối được dịch vụ tài khoản, thử lại sau'**
  String get errIdentityUnavailable;

  /// No description provided for @errOtherRegion.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản này thuộc khu vực khác'**
  String get errOtherRegion;

  /// No description provided for @errRoleNotAllowed.
  ///
  /// In vi, this message translates to:
  /// **'Bạn không được gán hoặc gỡ vai trò này'**
  String get errRoleNotAllowed;

  /// No description provided for @errSelfChange.
  ///
  /// In vi, this message translates to:
  /// **'Không tự sửa tài khoản của chính mình'**
  String get errSelfChange;

  /// No description provided for @errInvalidShift.
  ///
  /// In vi, this message translates to:
  /// **'Giờ ca không hợp lệ: giờ ra phải sau giờ vào'**
  String get errInvalidShift;

  /// No description provided for @errInvalidRange.
  ///
  /// In vi, this message translates to:
  /// **'Khoảng ngày không hợp lệ (tối đa một năm)'**
  String get errInvalidRange;

  /// No description provided for @adminRemove.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ'**
  String get adminRemove;

  /// No description provided for @evClockedIn.
  ///
  /// In vi, this message translates to:
  /// **'Chấm công vào ca'**
  String get evClockedIn;

  /// No description provided for @evClockedOut.
  ///
  /// In vi, this message translates to:
  /// **'Chấm công ra ca'**
  String get evClockedOut;

  /// No description provided for @evLeaveRequested.
  ///
  /// In vi, this message translates to:
  /// **'Gửi đơn nghỉ phép'**
  String get evLeaveRequested;

  /// No description provided for @evLeaveApproved.
  ///
  /// In vi, this message translates to:
  /// **'Duyệt đơn nghỉ phép'**
  String get evLeaveApproved;

  /// No description provided for @evLeaveRejected.
  ///
  /// In vi, this message translates to:
  /// **'Từ chối đơn nghỉ phép'**
  String get evLeaveRejected;

  /// No description provided for @evOvertimeRequested.
  ///
  /// In vi, this message translates to:
  /// **'Gửi đơn tăng ca'**
  String get evOvertimeRequested;

  /// No description provided for @evOvertimeApproved.
  ///
  /// In vi, this message translates to:
  /// **'Duyệt đơn tăng ca'**
  String get evOvertimeApproved;

  /// No description provided for @evOvertimeRejected.
  ///
  /// In vi, this message translates to:
  /// **'Từ chối đơn tăng ca'**
  String get evOvertimeRejected;

  /// No description provided for @evHolidayAdded.
  ///
  /// In vi, this message translates to:
  /// **'Thêm ngày lễ'**
  String get evHolidayAdded;

  /// No description provided for @evHolidayRemoved.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ ngày lễ'**
  String get evHolidayRemoved;

  /// No description provided for @evShiftChanged.
  ///
  /// In vi, this message translates to:
  /// **'Đổi giờ ca làm'**
  String get evShiftChanged;

  /// No description provided for @evCandidateApplied.
  ///
  /// In vi, this message translates to:
  /// **'Ứng viên nộp hồ sơ'**
  String get evCandidateApplied;

  /// No description provided for @evCandidateAnalyzed.
  ///
  /// In vi, this message translates to:
  /// **'AI đã đọc CV ứng viên'**
  String get evCandidateAnalyzed;

  /// No description provided for @evCandidateCvUploaded.
  ///
  /// In vi, this message translates to:
  /// **'Ứng viên tải CV lên'**
  String get evCandidateCvUploaded;

  /// No description provided for @evCandidateProfileUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Ứng viên sửa hồ sơ'**
  String get evCandidateProfileUpdated;

  /// No description provided for @evCandidateStatusChanged.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển bước hồ sơ ứng viên'**
  String get evCandidateStatusChanged;

  /// No description provided for @evCandidateHired.
  ///
  /// In vi, this message translates to:
  /// **'Nhận ứng viên vào làm'**
  String get evCandidateHired;

  /// No description provided for @evInterviewScheduled.
  ///
  /// In vi, this message translates to:
  /// **'Hẹn lịch phỏng vấn'**
  String get evInterviewScheduled;

  /// No description provided for @evInterviewConfirmed.
  ///
  /// In vi, this message translates to:
  /// **'Ứng viên xác nhận lịch phỏng vấn'**
  String get evInterviewConfirmed;

  /// No description provided for @evInterviewProposed.
  ///
  /// In vi, this message translates to:
  /// **'Ứng viên đề xuất giờ phỏng vấn khác'**
  String get evInterviewProposed;

  /// No description provided for @evPayslipIssued.
  ///
  /// In vi, this message translates to:
  /// **'Phát phiếu lương'**
  String get evPayslipIssued;

  /// No description provided for @evPayrollRunCompleted.
  ///
  /// In vi, this message translates to:
  /// **'Chốt lương xong'**
  String get evPayrollRunCompleted;

  /// No description provided for @evPayrollRunFailed.
  ///
  /// In vi, this message translates to:
  /// **'Chốt lương lỗi'**
  String get evPayrollRunFailed;

  /// No description provided for @evPayrollRunNeedsAttention.
  ///
  /// In vi, this message translates to:
  /// **'Chốt lương cần xử lý'**
  String get evPayrollRunNeedsAttention;

  /// No description provided for @evPayrollExpenseRecorded.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chi phí lương vào sổ tài chính'**
  String get evPayrollExpenseRecorded;

  /// No description provided for @evPayoutLogged.
  ///
  /// In vi, this message translates to:
  /// **'Ghi nhận chuyển lương'**
  String get evPayoutLogged;

  /// No description provided for @evSalaryAgreed.
  ///
  /// In vi, this message translates to:
  /// **'Chốt mức lương nhận việc'**
  String get evSalaryAgreed;

  /// No description provided for @evSalaryRaised.
  ///
  /// In vi, this message translates to:
  /// **'Tăng lương'**
  String get evSalaryRaised;

  /// No description provided for @evSalaryChanged.
  ///
  /// In vi, this message translates to:
  /// **'Văn phòng quản lý đổi lương cơ bản'**
  String get evSalaryChanged;

  /// No description provided for @evBonusGranted.
  ///
  /// In vi, this message translates to:
  /// **'Thưởng'**
  String get evBonusGranted;

  /// No description provided for @evPenaltyApplied.
  ///
  /// In vi, this message translates to:
  /// **'Phạt'**
  String get evPenaltyApplied;

  /// No description provided for @evRaiseRequested.
  ///
  /// In vi, this message translates to:
  /// **'Gửi đề xuất tăng lương'**
  String get evRaiseRequested;

  /// No description provided for @evRaiseForwarded.
  ///
  /// In vi, this message translates to:
  /// **'HR chuyển đề xuất tăng lương lên'**
  String get evRaiseForwarded;

  /// No description provided for @evRaiseApproved.
  ///
  /// In vi, this message translates to:
  /// **'Duyệt tăng lương'**
  String get evRaiseApproved;

  /// No description provided for @evRaiseRejected.
  ///
  /// In vi, this message translates to:
  /// **'Từ chối tăng lương'**
  String get evRaiseRejected;

  /// No description provided for @evRaiseReturned.
  ///
  /// In vi, this message translates to:
  /// **'Trả lại đề xuất tăng lương'**
  String get evRaiseReturned;

  /// No description provided for @evRaiseWithdrawn.
  ///
  /// In vi, this message translates to:
  /// **'Rút đề xuất tăng lương'**
  String get evRaiseWithdrawn;

  /// No description provided for @evPromotionNominated.
  ///
  /// In vi, this message translates to:
  /// **'Đề cử thăng chức'**
  String get evPromotionNominated;

  /// No description provided for @evPromotionApproved.
  ///
  /// In vi, this message translates to:
  /// **'Duyệt thăng chức'**
  String get evPromotionApproved;

  /// No description provided for @evPromotionRejected.
  ///
  /// In vi, this message translates to:
  /// **'Từ chối thăng chức'**
  String get evPromotionRejected;

  /// No description provided for @evEmployeePromoted.
  ///
  /// In vi, this message translates to:
  /// **'Văn phòng quản lý thăng chức'**
  String get evEmployeePromoted;

  /// No description provided for @evPositionChanged.
  ///
  /// In vi, this message translates to:
  /// **'Văn phòng quản lý đổi chức vụ'**
  String get evPositionChanged;

  /// No description provided for @evPositionCreated.
  ///
  /// In vi, this message translates to:
  /// **'Thêm chức vụ'**
  String get evPositionCreated;

  /// No description provided for @evPositionUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Sửa chức vụ'**
  String get evPositionUpdated;

  /// No description provided for @evPositionDeleted.
  ///
  /// In vi, this message translates to:
  /// **'Xóa chức vụ'**
  String get evPositionDeleted;

  /// No description provided for @evEmployeeHired.
  ///
  /// In vi, this message translates to:
  /// **'Thêm nhân viên mới'**
  String get evEmployeeHired;

  /// No description provided for @evEmployeeTransferred.
  ///
  /// In vi, this message translates to:
  /// **'Điều chuyển phòng ban'**
  String get evEmployeeTransferred;

  /// No description provided for @evEmployeeArchived.
  ///
  /// In vi, this message translates to:
  /// **'Bảo lưu hồ sơ nhân viên'**
  String get evEmployeeArchived;

  /// No description provided for @evEmployeeRestored.
  ///
  /// In vi, this message translates to:
  /// **'Mở lại hồ sơ nhân viên'**
  String get evEmployeeRestored;

  /// No description provided for @evDepartmentCreated.
  ///
  /// In vi, this message translates to:
  /// **'Thành lập phòng ban'**
  String get evDepartmentCreated;

  /// No description provided for @evDepartmentDissolved.
  ///
  /// In vi, this message translates to:
  /// **'Giải thể phòng ban'**
  String get evDepartmentDissolved;

  /// No description provided for @evDepartmentHeadChanged.
  ///
  /// In vi, this message translates to:
  /// **'Đổi trưởng phòng'**
  String get evDepartmentHeadChanged;

  /// No description provided for @evProfileChangeRequested.
  ///
  /// In vi, this message translates to:
  /// **'Đề xuất sửa hồ sơ'**
  String get evProfileChangeRequested;

  /// No description provided for @evProfileChangeApproved.
  ///
  /// In vi, this message translates to:
  /// **'Duyệt sửa hồ sơ'**
  String get evProfileChangeApproved;

  /// No description provided for @evProfileChangeRejected.
  ///
  /// In vi, this message translates to:
  /// **'Từ chối sửa hồ sơ'**
  String get evProfileChangeRejected;

  /// No description provided for @evResignationRequested.
  ///
  /// In vi, this message translates to:
  /// **'Gửi đơn thôi việc'**
  String get evResignationRequested;

  /// No description provided for @evResignationApproved.
  ///
  /// In vi, this message translates to:
  /// **'Duyệt đơn thôi việc'**
  String get evResignationApproved;

  /// No description provided for @evResignationRejected.
  ///
  /// In vi, this message translates to:
  /// **'Từ chối đơn thôi việc'**
  String get evResignationRejected;

  /// No description provided for @evResignationWithdrawn.
  ///
  /// In vi, this message translates to:
  /// **'Rút đơn thôi việc'**
  String get evResignationWithdrawn;

  /// No description provided for @evResignationCompleted.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn tất thôi việc'**
  String get evResignationCompleted;

  /// No description provided for @evReportSubmitted.
  ///
  /// In vi, this message translates to:
  /// **'Gửi báo cáo lên cấp trên'**
  String get evReportSubmitted;

  /// No description provided for @evReportAcknowledged.
  ///
  /// In vi, this message translates to:
  /// **'Cấp trên xác nhận báo cáo'**
  String get evReportAcknowledged;

  /// No description provided for @evReportReturned.
  ///
  /// In vi, this message translates to:
  /// **'Cấp trên trả lại báo cáo'**
  String get evReportReturned;

  /// No description provided for @evProjectCreated.
  ///
  /// In vi, this message translates to:
  /// **'Tạo dự án'**
  String get evProjectCreated;

  /// No description provided for @evProjectProposed.
  ///
  /// In vi, this message translates to:
  /// **'Gửi đề xuất dự án'**
  String get evProjectProposed;

  /// No description provided for @evProjectProposalApproved.
  ///
  /// In vi, this message translates to:
  /// **'Duyệt đề xuất dự án'**
  String get evProjectProposalApproved;

  /// No description provided for @evProjectProposalRejected.
  ///
  /// In vi, this message translates to:
  /// **'Từ chối đề xuất dự án'**
  String get evProjectProposalRejected;

  /// No description provided for @evProjectProposalCountered.
  ///
  /// In vi, this message translates to:
  /// **'Đề xuất dự án được sửa qua lại'**
  String get evProjectProposalCountered;

  /// No description provided for @evProjectAccepted.
  ///
  /// In vi, this message translates to:
  /// **'Nghiệm thu dự án'**
  String get evProjectAccepted;

  /// No description provided for @evProjectMembersRemoved.
  ///
  /// In vi, this message translates to:
  /// **'Rút nhân viên khỏi dự án'**
  String get evProjectMembersRemoved;

  /// No description provided for @evAcceptanceRevenueRecorded.
  ///
  /// In vi, this message translates to:
  /// **'Ghi doanh thu nghiệm thu'**
  String get evAcceptanceRevenueRecorded;

  /// No description provided for @evMaterialPurchased.
  ///
  /// In vi, this message translates to:
  /// **'Mua vật liệu'**
  String get evMaterialPurchased;

  /// No description provided for @evSupplierPaid.
  ///
  /// In vi, this message translates to:
  /// **'Trả tiền nhà cung cấp'**
  String get evSupplierPaid;

  /// No description provided for @evFinancePeriodClosed.
  ///
  /// In vi, this message translates to:
  /// **'Chốt sổ tài chính tháng'**
  String get evFinancePeriodClosed;

  /// No description provided for @evAdminSqlRead.
  ///
  /// In vi, this message translates to:
  /// **'Quản trị chạy truy vấn SQL (chỉ đọc)'**
  String get evAdminSqlRead;

  /// No description provided for @evAdminSqlWrite.
  ///
  /// In vi, this message translates to:
  /// **'Quản trị sửa dữ liệu bằng SQL'**
  String get evAdminSqlWrite;

  /// No description provided for @evBackupCreated.
  ///
  /// In vi, this message translates to:
  /// **'Sao lưu dữ liệu'**
  String get evBackupCreated;

  /// No description provided for @evAccountChanged.
  ///
  /// In vi, this message translates to:
  /// **'Đổi tài khoản, vai trò'**
  String get evAccountChanged;

  /// No description provided for @nAuditLog.
  ///
  /// In vi, this message translates to:
  /// **'Nhật ký mới: {event}{by}'**
  String nAuditLog(String event, String by);

  /// No description provided for @nAuditLogBy.
  ///
  /// In vi, this message translates to:
  /// **' (bởi {by})'**
  String nAuditLogBy(String by);

  /// No description provided for @nPositionChanged.
  ///
  /// In vi, this message translates to:
  /// **'Chức vụ của bạn đã đổi thành {position}'**
  String nPositionChanged(String position);

  /// No description provided for @nSalaryChanged.
  ///
  /// In vi, this message translates to:
  /// **'Lương cơ bản mới của bạn: {amount}'**
  String nSalaryChanged(String amount);

  /// No description provided for @nBonusGranted.
  ///
  /// In vi, this message translates to:
  /// **'Bạn được thưởng {amount}: {reason}'**
  String nBonusGranted(String amount, String reason);

  /// No description provided for @nPenaltyApplied.
  ///
  /// In vi, this message translates to:
  /// **'Bạn bị phạt {amount}: {reason}'**
  String nPenaltyApplied(String amount, String reason);

  /// No description provided for @errProtectedDatabase.
  ///
  /// In vi, this message translates to:
  /// **'Cơ sở dữ liệu nhật ký quản trị không được truy vấn ở đây'**
  String get errProtectedDatabase;

  /// No description provided for @errPastDate.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ xin nghỉ cho ngày tương lai (từ ngày mai trở đi)'**
  String get errPastDate;

  /// No description provided for @leaveAttach.
  ///
  /// In vi, this message translates to:
  /// **'Đính kèm minh chứng (Word, PDF, ảnh)'**
  String get leaveAttach;

  /// No description provided for @approvalsOthers.
  ///
  /// In vi, this message translates to:
  /// **'Đơn của nhân viên chờ bạn duyệt ({n})'**
  String approvalsOthers(int n);

  /// No description provided for @approvalsMine.
  ///
  /// In vi, this message translates to:
  /// **'Đơn của bạn đang chờ cấp trên ({n})'**
  String approvalsMine(int n);

  /// No description provided for @requestMineTag.
  ///
  /// In vi, this message translates to:
  /// **'Đơn của bạn'**
  String get requestMineTag;

  /// No description provided for @projectOverdue.
  ///
  /// In vi, this message translates to:
  /// **'Trễ hạn'**
  String get projectOverdue;
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
