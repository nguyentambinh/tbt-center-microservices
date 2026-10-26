// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TBT Center';

  @override
  String get tagline => 'MULTINATIONAL GROUP';

  @override
  String gemPalette(String gem) {
    return '$gem palette';
  }

  @override
  String get gemGold => 'Gold';

  @override
  String get gemPlatinum => 'Platinum';

  @override
  String get gemEmerald => 'Emerald';

  @override
  String get gemRuby => 'Ruby';

  @override
  String get gemSapphire => 'Sapphire';

  @override
  String get gemDiamond => 'Diamond';

  @override
  String get samplePayslipTitle => 'October payslip';

  @override
  String get viewDetails => 'View details';

  @override
  String get downloadPdf => 'Download PDF';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageAuto => 'Automatic (by location)';

  @override
  String get dataRegion => 'Data region';

  @override
  String get detecting => 'Detecting location…';

  @override
  String get locationUnknown => 'Location unknown, using the default region';

  @override
  String detectedCountry(String country) {
    return 'Country: $country';
  }

  @override
  String get refreshLocation => 'Detect again';

  @override
  String get simulateLocation => 'Simulate location';

  @override
  String get simulateHint =>
      'Debug builds only, for testing as if you were in another country';

  @override
  String get simulateIp => 'IP address';

  @override
  String get simulateCountry => 'Or country code (e.g. DE)';

  @override
  String get apply => 'Apply';

  @override
  String get clearSimulation => 'Clear simulation';

  @override
  String get regionVn => 'Vietnam';

  @override
  String get regionDe => 'Germany';

  @override
  String get regionUs => 'United States';

  @override
  String get regionBr => 'Brazil';

  @override
  String get regionZa => 'South Africa';

  @override
  String get regionAu => 'Australia';

  @override
  String get bannerOffline => 'No internet connection · showing saved data';

  @override
  String get bannerServerDown => 'Can\'t reach the server · showing saved data';

  @override
  String get bannerUnstable => 'Unstable connection';

  @override
  String get bannerRecovered => 'Back online';

  @override
  String get reconnect => 'Reconnect';

  @override
  String get errorNetwork =>
      'No internet connection. Check your Wi-Fi or mobile data.';

  @override
  String get errorTimeout =>
      'The server took too long to respond. Please try again.';

  @override
  String get errorServer =>
      'The server is having problems. Please try again later.';

  @override
  String get errorUnauthorized =>
      'Your session has expired. Please sign in again.';

  @override
  String get errorForbidden => 'You don\'t have permission to do this.';

  @override
  String get errorNotFound => 'The requested data was not found.';

  @override
  String get errorValidation =>
      'Some information is invalid. Please check and try again.';

  @override
  String get errorOfflineWrite =>
      'You need a connection to save changes. What you entered is kept.';

  @override
  String get errorUnknown => 'Something went wrong. Please try again.';

  @override
  String get signIn => 'Sign in';

  @override
  String get applyAsCandidate => 'Apply · create an account';

  @override
  String get signOut => 'Sign out';

  @override
  String welcome(String name) {
    return 'Hello, $name';
  }

  @override
  String dataStoredIn(String region) {
    return 'Your data is stored in the $region region';
  }

  @override
  String get signInFailed =>
      'Couldn\'t open the sign-in page. Check the connection to the server and try again.';

  @override
  String get roleExecutive => 'Executive office';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get roleHr => 'Human resources';

  @override
  String get roleFinance => 'Finance';

  @override
  String get roleEmployee => 'Employee';

  @override
  String get roleCandidate => 'Candidate';

  @override
  String get regionCheckTitle => 'Regional connection';

  @override
  String get regionCheckHint =>
      'Calls your regional server through Kong with your sign-in token.';

  @override
  String get regionCheckButton => 'Check';

  @override
  String regionCheckOk(String service) {
    return 'The $service server is responding';
  }

  @override
  String get savedDataNote => 'Showing saved data';

  @override
  String get themePreview => 'View gem palettes';

  @override
  String get employees => 'Employee records';

  @override
  String get employeesHint => 'Employee list and profiles in your region';

  @override
  String get open => 'Open';

  @override
  String get searchEmployees => 'Search by name, ID or email';

  @override
  String employeeCount(int count) {
    return '$count employees';
  }

  @override
  String get noEmployees => 'No employees found';

  @override
  String get loadMore => 'Load more';

  @override
  String get retry => 'Try again';

  @override
  String get sectionWork => 'Work';

  @override
  String get sectionContact => 'Contact';

  @override
  String get sectionRelatives => 'Relatives';

  @override
  String get sectionHealth => 'Health';

  @override
  String get sectionInsurance => 'Insurance';

  @override
  String get fieldId => 'Employee ID';

  @override
  String get fieldCompany => 'Company';

  @override
  String get fieldDepartment => 'Department';

  @override
  String get fieldPosition => 'Position';

  @override
  String get fieldBirthYear => 'Year of birth';

  @override
  String get fieldGender => 'Gender';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get fieldHiredOn => 'Hire date';

  @override
  String get fieldLaborContract => 'Employment contract';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldPhone => 'Phone';

  @override
  String get fieldAddress => 'Address';

  @override
  String get fieldHometown => 'Hometown';

  @override
  String get fieldHeight => 'Height';

  @override
  String get fieldWeight => 'Weight';

  @override
  String get fieldVision => 'Vision';

  @override
  String get fieldMedicalHistory => 'Medical history';

  @override
  String get fieldUpdatedOn => 'Updated';

  @override
  String get fieldInsuranceType => 'Insurance type';

  @override
  String get fieldInsuranceNumber => 'Insurance number';

  @override
  String get fieldExpiresOn => 'Expires';

  @override
  String get noData => 'No data yet';

  @override
  String get attendance => 'Attendance & leave';

  @override
  String get attendanceHint => 'Your hours, leave requests and approvals';

  @override
  String get tabTimesheet => 'Timesheet';

  @override
  String get tabLeave => 'Leave';

  @override
  String get tabApprovals => 'Approvals';

  @override
  String totalHours(String hours, int days) {
    return '$hours hours over $days days';
  }

  @override
  String checkInOut(String checkIn, String checkOut) {
    return 'In $checkIn · Out $checkOut';
  }

  @override
  String overtimeHours(String hours) {
    return 'Overtime $hours h';
  }

  @override
  String get newLeave => 'Request leave';

  @override
  String get leaveType => 'Leave type';

  @override
  String get leaveAnnual => 'Annual leave';

  @override
  String get leaveSick => 'Sick leave';

  @override
  String get leaveUnpaid => 'Unpaid leave';

  @override
  String get leavePersonal => 'Personal matters';

  @override
  String get leaveDates => 'Dates';

  @override
  String get pickDates => 'Pick dates';

  @override
  String get reason => 'Reason';

  @override
  String get submitLeave => 'Submit';

  @override
  String get leaveSubmitted => 'Leave request submitted';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String leaveDays(int days) {
    return '$days days';
  }

  @override
  String get noLeaves => 'No leave requests yet';

  @override
  String get noPending => 'Nothing waiting for approval';

  @override
  String get noTimesheets => 'No timesheet data yet';

  @override
  String get leaveDecided => 'Request updated';

  @override
  String get errOverlap => 'These dates overlap another leave request';

  @override
  String get errTooLong => 'A request can cover at most 30 days';

  @override
  String get errInvalidDates => 'The end date must be after the start date';

  @override
  String get errAlreadyDecided => 'This request was already handled';

  @override
  String get errSelfApproval => 'You cannot approve your own request';

  @override
  String get errRegionMismatch => 'This data belongs to another region';

  @override
  String get errNoEmployee =>
      'Your account is not linked to an employee record';

  @override
  String get myApplication => 'My application';

  @override
  String get myApplicationHint => 'Apply and follow your progress';

  @override
  String get candidates => 'Candidates';

  @override
  String get candidatesHint => 'Applications and hiring steps';

  @override
  String get applyNow => 'Apply';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get saveProfile => 'Save';

  @override
  String get fullName => 'Full name';

  @override
  String get appliedPosition => 'Position applied for';

  @override
  String get consentAi => 'I agree to an AI reading and summarising my CV';

  @override
  String get notAppliedYet => 'You haven\'t applied yet';

  @override
  String get progress => 'Progress';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get profileLockedHint =>
      'Your application is past screening and can no longer be edited';

  @override
  String get moveTo => 'Move to';

  @override
  String get statusChanged => 'Status updated';

  @override
  String get noCandidates => 'No candidates yet';

  @override
  String get allStatuses => 'All';

  @override
  String get note => 'Note';

  @override
  String get stageSubmitted => 'Submitted';

  @override
  String get stageAnalyzed => 'AI summarised';

  @override
  String get stageScreening => 'Screening';

  @override
  String get stageInterview => 'Interview';

  @override
  String get stageOffered => 'Offer made';

  @override
  String get stageRejected => 'Not selected';

  @override
  String get errProfileLocked =>
      'Your application can no longer be edited at this stage';

  @override
  String get cvSection => 'CV';

  @override
  String get cvNone => 'No CV yet';

  @override
  String get cvAttached => 'CV uploaded';

  @override
  String get uploadCv => 'Upload CV (PDF)';

  @override
  String get replaceCv => 'Replace CV';

  @override
  String get cvUploaded => 'CV uploaded';

  @override
  String get cvWaitingAi =>
      'The AI is reading your CV, this takes a few minutes';

  @override
  String get openCv => 'Open CV';

  @override
  String get aiSummary => 'AI summary';

  @override
  String get aiDisclaimer =>
      'Generated by AI. Check it against the original CV before deciding.';

  @override
  String yearsExperience(String years) {
    return '$years years of experience';
  }

  @override
  String get skills => 'Skills';

  @override
  String get suitablePositions => 'Suitable positions';

  @override
  String get strengths => 'Strengths';

  @override
  String get interviewQuestions => 'Ask in the interview';

  @override
  String get errCvNotPdf => 'The CV must be a PDF file';

  @override
  String get errCvTooLarge => 'The CV can be at most 10 MB';

  @override
  String get payslips => 'Payslips';

  @override
  String get payslipsHint => 'Pay per period, bonuses and penalties';

  @override
  String get baseSalary => 'Base salary';

  @override
  String get grossPay => 'Gross pay';

  @override
  String get netPay => 'Net pay';

  @override
  String netUsd(String amount) {
    return '≈ $amount at the payment-day rate';
  }

  @override
  String paidOn(String date) {
    return 'Paid on $date';
  }

  @override
  String get bonusesPenalties => 'Bonuses / penalties';

  @override
  String get bonus => 'Bonus';

  @override
  String get penalty => 'Penalty';

  @override
  String get noPayslips => 'No payslips yet';

  @override
  String get payrollRuns => 'Payroll runs';

  @override
  String get payrollRunsHint => 'Calculate and pay the whole region per period';

  @override
  String startPayrollRun(String period) {
    return 'Run payroll for $period';
  }

  @override
  String get runRunning => 'Running';

  @override
  String get runCompleted => 'Completed';

  @override
  String get runFailed => 'Failed, rolled back';

  @override
  String get retryRun => 'Run again';

  @override
  String get sagaSteps => 'Steps';

  @override
  String get stepCollectHours => 'Collect working hours';

  @override
  String get stepFetchRate => 'Fetch exchange rate';

  @override
  String get stepCalculate => 'Calculate payslips';

  @override
  String get stepPay => 'Pay through the payout channel';

  @override
  String get stepComplete => 'Complete';

  @override
  String get stepCompensate => 'Roll back unpaid part';

  @override
  String get stepRetry => 'Retry';

  @override
  String get stepResume => 'Resumed after restart';

  @override
  String paidSummary(int count, String amount) {
    return '$count payslips paid · $amount';
  }

  @override
  String get noRuns => 'No payroll runs yet';

  @override
  String get errRunExists => 'This period has already been run';

  @override
  String get errRunFailed => 'This period failed earlier, run it again';

  @override
  String get groupReport => 'Group report';

  @override
  String get groupReportHint => 'Consolidated figures of all regions in USD';

  @override
  String get payrollCostByRegion => 'Payroll cost by region';

  @override
  String get leavesByRegion => 'Leave requests by region';

  @override
  String get candidatesByRegion => 'Candidates by region';

  @override
  String get groupTotal => 'Whole group';

  @override
  String dataAsOf(String id) {
    return 'Data up to event #$id';
  }

  @override
  String get noReportData => 'No data yet';

  @override
  String employeesCount(int count) {
    return '$count people';
  }

  @override
  String get projects => 'Projects and contracts';

  @override
  String get projectsHint => 'Projects, customers and team members';

  @override
  String get searchProjects => 'Search project, contract or customer';

  @override
  String get noProjects => 'No projects';

  @override
  String get projectMoney => 'Project value';

  @override
  String get deposit => 'Deposit';

  @override
  String get expectedAcceptance => 'Expected acceptance';

  @override
  String get customer => 'Customer';

  @override
  String get customerContactHidden =>
      'Customer contact details are visible to finance only';

  @override
  String get contracts => 'Contracts';

  @override
  String get projectMembers => 'Team members';

  @override
  String get myProjects => 'My projects';

  @override
  String get myProjectsHint => 'Projects you work on and your hours';

  @override
  String get noMyProjects => 'You are not on any project yet';

  @override
  String get finance => 'Finance';

  @override
  String get financeHint => 'Monthly income and costs, suppliers, closing';

  @override
  String get incomeExpense => 'Income & costs';

  @override
  String get suppliers => 'Suppliers';

  @override
  String get revenue => 'Revenue';

  @override
  String get cost => 'Costs';

  @override
  String get profit => 'Profit';

  @override
  String get periodClosed => 'Closed';

  @override
  String get closePeriod => 'Close month';

  @override
  String get noFinanceData => 'No figures for this year';

  @override
  String get purchased => 'Purchased';

  @override
  String get paid => 'Paid';

  @override
  String get balance => 'Owed';

  @override
  String get recordPurchase => 'Record purchase';

  @override
  String get recordPayment => 'Record payment';

  @override
  String get materialName => 'Material';

  @override
  String get amount => 'Amount';

  @override
  String get purchaseHistory => 'Purchases';

  @override
  String get paymentHistory => 'Payments';

  @override
  String get financeByRegion => 'Closed revenue and costs';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get errPeriodClosed => 'This month is closed';

  @override
  String get errPeriodNotEnded => 'This month has not ended yet';

  @override
  String get errOverpaid => 'Payment is larger than the amount owed';

  @override
  String get errInvalidAmount => 'Invalid amount';

  @override
  String closePeriodConfirm(String period) {
    return 'Close $period? No more entries can be added to this month afterwards.';
  }

  @override
  String hoursValue(String hours) {
    return '$hours h';
  }

  @override
  String get clockToday => 'Today\'s attendance';

  @override
  String get noShiftToday =>
      'You have no shift today, clocking is not available';

  @override
  String get clockIn => 'Clock in';

  @override
  String get clockOut => 'Clock out';

  @override
  String get shiftDone => 'Shift completed';

  @override
  String get holidayShift => 'Public holiday';

  @override
  String get sundayShift => 'Sunday';

  @override
  String get tabOvertime => 'Overtime';

  @override
  String get newOvertime => 'Request overtime';

  @override
  String get noOvertime => 'No overtime requests';

  @override
  String get submitOvertime => 'Submit';

  @override
  String get errNoShift => 'You have no shift today';

  @override
  String get errAlreadyClockedOut => 'You have already clocked out today';

  @override
  String get errTooSoon => 'You just clocked in, wait at least 5 minutes';

  @override
  String get errInvalidHours => 'Overtime must be between 0.5 and 12 hours';

  @override
  String clockedIn(String time) {
    return 'Clocked in at $time';
  }

  @override
  String clockedOut(String time, String hours) {
    return 'Clocked out at $time, $hours h worked';
  }

  @override
  String totalHoursToday(String hours) {
    return '$hours h worked today';
  }

  @override
  String get notifications => 'Notifications';

  @override
  String get noNotifications => 'No notifications yet';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get nGeneric => 'You have a new notification';

  @override
  String nLeaveRequested(String employee, String days, String date) {
    return '$employee requested $days days of leave from $date';
  }

  @override
  String nLeaveApproved(String date) {
    return 'Your leave from $date was approved';
  }

  @override
  String nLeaveRejected(String date) {
    return 'Your leave from $date was rejected';
  }

  @override
  String nOvertimeRequested(String employee, String hours, String date) {
    return '$employee requested $hours h overtime on $date';
  }

  @override
  String nOvertimeApproved(String date) {
    return 'Your overtime on $date was approved';
  }

  @override
  String nOvertimeRejected(String date) {
    return 'Your overtime on $date was rejected';
  }

  @override
  String nCandidateApplied(String position) {
    return 'New application: $position';
  }

  @override
  String nCandidateStatus(String stage) {
    return 'Your application moved to: $stage';
  }

  @override
  String nPayrollPaid(String period) {
    return 'Salary for $period has been paid';
  }

  @override
  String nPayrollFailed(String period) {
    return 'Payroll for $period failed and needs a retry';
  }

  @override
  String nFinanceClosed(String period) {
    return 'Finance for $period has been closed';
  }

  @override
  String get importCandidates => 'Import candidates from file';

  @override
  String get confirmAll => 'Confirm all';

  @override
  String get importRowNew => 'New';

  @override
  String get importRowUpdate => 'Update';

  @override
  String get importRowAccepted => 'Saved';

  @override
  String get importErrMissingName => 'Missing name';

  @override
  String get importErrMissingContact => 'Missing email and phone';

  @override
  String get importErrInvalidEmail => 'Invalid email';

  @override
  String get errUnsupportedFile => 'Only .csv or .xlsx files are accepted';

  @override
  String get errMissingNameColumn => 'The first row has no name column';

  @override
  String get errEmptyFile => 'The file has no candidate rows';

  @override
  String get errFileTooLarge => 'File is larger than 2 MB';

  @override
  String confirmSelected(int count) {
    return 'Confirm selected ($count)';
  }

  @override
  String importAccepted(int count) {
    return '$count profiles saved';
  }

  @override
  String importSummary(int total, int pending) {
    return '$total rows, $pending waiting for confirmation';
  }

  @override
  String importRowNumber(int n) {
    return 'Row $n';
  }

  @override
  String get roleAuditor => 'Auditor';

  @override
  String get gemAmethyst => 'Amethyst';

  @override
  String get auditLog => 'Audit log';

  @override
  String get auditLogHint =>
      'All regions\' events, hash chain check, export for audit';

  @override
  String get auditEvents => 'Events';

  @override
  String get accessLog => 'Access log';

  @override
  String get verifyChain => 'Verify hash chain';

  @override
  String get exportAudit => 'Export for audit';

  @override
  String get auditSearch => 'Search';

  @override
  String get chainIntact => 'The log is intact, no row was changed';

  @override
  String get exportChecksumHint =>
      'SHA-256 of the exported file. The auditor recomputes it; a different value means the file was changed.';

  @override
  String get copyChecksum => 'Copy';

  @override
  String get close => 'Close';

  @override
  String get allRegions => 'All regions';

  @override
  String get errAccessExpired => 'Your audit access has expired';

  @override
  String chainBroken(String id) {
    return 'Hash chain broken at row #$id';
  }

  @override
  String chainChecked(int count) {
    return '$count rows checked';
  }

  @override
  String exportDone(int count) {
    return '$count rows exported';
  }

  @override
  String rowsCount(int count) {
    return '$count rows';
  }

  @override
  String supplierPurchases(int count) {
    return '$count purchases';
  }

  @override
  String supplierPaidPercent(String percent) {
    return '$percent% paid';
  }

  @override
  String get acceptProject => 'Accept project';

  @override
  String get projectInProgress => 'In progress';

  @override
  String get errAlreadyAccepted => 'This project is already accepted';

  @override
  String get errFinanceUnavailable =>
      'Finance could not record the revenue, the project was not changed. Try again later.';

  @override
  String acceptProjectConfirm(String amount) {
    return 'Accept the project and record $amount as revenue?';
  }

  @override
  String projectAcceptedOn(String date) {
    return 'Accepted on $date';
  }

  @override
  String nProjectAccepted(String project) {
    return 'Project $project was accepted and its revenue recorded';
  }

  @override
  String get workConditions => 'Working conditions';

  @override
  String workHoursSummary(String hours, String overtime) {
    return '$hours h · overtime $overtime h';
  }

  @override
  String get noticeQueued => 'queued';

  @override
  String get noticeSent => 'sent';

  @override
  String customerNotice(String channel, String status) {
    return 'Customer confirmation via $channel: $status';
  }

  @override
  String get attachCv => 'Attach CV (PDF, up to 10 MB)';

  @override
  String cvSelected(String name) {
    return 'CV: $name';
  }

  @override
  String get stageHired => 'Hired';

  @override
  String get hireCandidate => 'Hire';

  @override
  String get hiredKeepPassword =>
      'Password: unchanged, the one this person already uses.';

  @override
  String get hiredRelogin =>
      'They need to sign out and sign in again to get the Employee role.';

  @override
  String hireConfirm(String name, String email) {
    return 'Hire $name? $email becomes the new employee\'s sign-in.';
  }

  @override
  String hiredTitle(String id) {
    return 'Employee $id created';
  }

  @override
  String hiredLogin(String login) {
    return 'Sign-in: $login';
  }

  @override
  String hiredTempPassword(String password) {
    return 'Temporary password: $password (shown once, must be changed at first sign-in)';
  }

  @override
  String get home => 'Home';

  @override
  String get sectionMyWork => 'My work';

  @override
  String get sectionManage => 'Management';

  @override
  String get sectionFinance => 'Finance';

  @override
  String get sectionAudit => 'Audit';

  @override
  String nPayslipIssued(String period) {
    return 'Your payslip for $period is ready';
  }

  @override
  String nPayrollNeedsAttention(String period) {
    return 'Payroll for $period needs manual handling';
  }

  @override
  String get errPeriodLocked =>
      'Payroll for this period is being closed. Try again in a few minutes';

  @override
  String get runNeedsAttention => 'Needs attention';

  @override
  String get stepLockPeriod => 'Lock period in attendance';

  @override
  String get stepReserveBudget => 'Reserve payroll budget';

  @override
  String get stepReleaseBudget => 'Release budget (compensation)';

  @override
  String get stepRecordExpense => 'Record payroll expense in finance';

  @override
  String get stepIssuePayslips => 'Send payslips to employees';

  @override
  String get stepUnlockPeriod => 'Unlock period';

  @override
  String get stepNeedsAttention => 'Waiting for manual handling';

  @override
  String get knowledge => 'Knowledge base';

  @override
  String get knowledgeHint => 'Pay, leave, overtime rules and processes';

  @override
  String get knowledgeSearchHint => 'Search, e.g. overtime, payroll';

  @override
  String get knowledgeEmpty => 'No matching articles';

  @override
  String get sectionKnowledge => 'Knowledge';

  @override
  String get knowledgeTabAsk => 'Ask AI';

  @override
  String get knowledgeTabSearch => 'Articles';

  @override
  String get knowledgeTabGraph => 'Graph';

  @override
  String get askHint => 'Ask about pay, leave, attendance…';

  @override
  String get askIntro =>
      'The assistant answers from the company knowledge base and knowledge graph, with sources you can check.';

  @override
  String get askExample1 => 'How is overtime paid?';

  @override
  String get askExample2 => 'Who approves my leave request?';

  @override
  String get askExample3 =>
      'Why can\'t requests be approved during payroll closing?';

  @override
  String get askExample4 => 'How is my personal data protected?';

  @override
  String get askThinking => 'Searching the knowledge base…';

  @override
  String get askSources => 'Sources';

  @override
  String get askGraphFacts => 'From the knowledge graph';

  @override
  String askAnsweredBy(String model) {
    return 'Answered by $model';
  }

  @override
  String get askNoAi => 'No AI used, quoted from the knowledge base';

  @override
  String get askCached => 'cached';

  @override
  String get askHelpful => 'Helpful';

  @override
  String get askNotHelpful => 'Not right';

  @override
  String get askThanks => 'Thanks for your feedback';

  @override
  String get askFailed => 'Could not send the question';

  @override
  String get askNewChat => 'New conversation';

  @override
  String get askSend => 'Send';

  @override
  String get askViaKeyword => 'keyword';

  @override
  String get askViaSemantic => 'meaning';

  @override
  String get askViaGraph => 'graph';

  @override
  String get graphSearchHint => 'Find a concept, e.g. overtime';

  @override
  String get graphRelated => 'Connections';

  @override
  String get graphReadArticle => 'Read article';

  @override
  String get graphAskAbout => 'Ask AI about this';

  @override
  String graphAskTemplate(String topic) {
    return 'Explain $topic to me';
  }

  @override
  String get graphTypeConcept => 'Concept';

  @override
  String get graphTypeProcess => 'Process';

  @override
  String get graphTypeStep => 'Step';

  @override
  String get graphTypeRule => 'Rule';

  @override
  String get graphTypeRole => 'Role';

  @override
  String get graphTypeService => 'Service';

  @override
  String get graphTypeRegion => 'Country';

  @override
  String get graphTypeDocument => 'Article';

  @override
  String get knowledgeMore => 'More';

  @override
  String get ontologyTitle => 'Ontology';

  @override
  String get ontologyClasses => 'Class tree';

  @override
  String get ontologyRelations => 'Relations';

  @override
  String get ontologyRules => 'Inference rules';

  @override
  String ontologyTotals(int nodes, int asserted, int extracted, int inferred) {
    return '$nodes nodes · $asserted stated edges · $extracted AI-extracted · $inferred inferred';
  }

  @override
  String ontologyReasoning(int count, int ms) {
    return 'Last reasoning run: $count new edges in $ms ms';
  }

  @override
  String get ontologyRerun => 'Run reasoning again';

  @override
  String get ontologyTransitive => 'transitive';

  @override
  String get ontologySymmetric => 'symmetric';

  @override
  String ontologyInverse(String name) {
    return 'inverse of $name';
  }

  @override
  String ontologySubProperty(String name) {
    return 'implies $name';
  }

  @override
  String get ontologyDerived => 'inferred only';

  @override
  String ontologyEdgeCount(int count) {
    return '$count edges';
  }

  @override
  String get ontologyExport =>
      'RDF/OWL export (Turtle) at /knowledge/ontology?format=turtle, opens in Protégé.';

  @override
  String get sparqlTitle => 'SPARQL query';

  @override
  String get sparqlHint => 'Write a SELECT query or pick a sample';

  @override
  String get sparqlRun => 'Run';

  @override
  String get sparqlIncludeInferred => 'Include inferred edges';

  @override
  String get sparqlNoRows => 'No results';

  @override
  String sparqlRows(int count, int ms) {
    return '$count rows · $ms ms';
  }

  @override
  String sparqlError(String message) {
    return 'Query error: $message';
  }

  @override
  String get sparqlSampleInvolves => 'Services payroll closing needs';

  @override
  String get sparqlSampleViewers => 'Who can view net pay';

  @override
  String get sparqlSampleBefore => 'Steps before the bank payment';

  @override
  String get sparqlSampleRabbit => 'Services using RabbitMQ';

  @override
  String get sparqlSampleCount => 'Services per place';

  @override
  String get proposalsTitle => 'AI proposals';

  @override
  String get proposalsRun => 'Let AI read new articles';

  @override
  String get proposalsRunning => 'AI is reading articles…';

  @override
  String proposalsQueued(int count) {
    return 'AI will read $count articles';
  }

  @override
  String get proposalsNoAi => 'No AI configured for extraction';

  @override
  String get proposalsPending => 'Pending';

  @override
  String get proposalsInvalid => 'Invalid';

  @override
  String get proposalsApproved => 'Approved';

  @override
  String get proposalsRejected => 'Rejected';

  @override
  String get proposalsEmpty => 'No proposals';

  @override
  String get proposalNewNode => 'New node';

  @override
  String proposalFrom(String article) {
    return 'Quoted from $article';
  }

  @override
  String get proposalApprove => 'Approve';

  @override
  String get proposalReject => 'Reject';

  @override
  String get proposalApproved => 'Added to the graph, reasoning again';

  @override
  String get proposalRejected => 'Proposal rejected';

  @override
  String proposalConfidence(int percent) {
    return 'Confidence $percent%';
  }

  @override
  String get proposalReasonEvidence => 'Quote is not in the article';

  @override
  String get proposalReasonConfidence => 'AI is not confident';

  @override
  String proposalReasonOntology(String code) {
    return 'Breaks the relation domain or range ($code)';
  }

  @override
  String get proposalReasonUnused => 'Node is not used by any valid edge';

  @override
  String proposalReasonOther(String code) {
    return 'Reason: $code';
  }

  @override
  String get graphInferred => 'Inferred';

  @override
  String graphInferredBy(String rule) {
    return 'Inferred by rule: $rule';
  }

  @override
  String get graphBecause => 'Because';

  @override
  String get graphEvidence =>
      'Extracted by AI from an article, approved by HR:';

  @override
  String get graphGoTo => 'Open this node';

  @override
  String get graphPathTo => 'Connect to…';

  @override
  String graphPathTitle(String from, String to) {
    return 'From $from to $to';
  }

  @override
  String get graphPathNone => 'No connection within 6 steps';

  @override
  String get graphPathPick => 'Pick the concept to connect to';

  @override
  String get graphTypeTechnology => 'Technology';

  @override
  String get graphTypePattern => 'Architecture pattern';

  @override
  String get todoTitle => 'Needs your attention';

  @override
  String todoLeaves(int count) {
    return '$count leave requests awaiting approval';
  }

  @override
  String todoOvertime(int count) {
    return '$count overtime requests awaiting approval';
  }

  @override
  String todoCandidates(int count) {
    return '$count new applications';
  }

  @override
  String get todoNone => 'Nothing is waiting for you';

  @override
  String get signOutConfirm => 'Sign out of TBT Center?';

  @override
  String get stepErrorTimeout =>
      'The payout channel did not respond in time; the system reconciles by reference before paying again';

  @override
  String get stepErrorGeneric =>
      'This step could not run; tap Retry or contact IT';

  @override
  String get errSparqlSyntax =>
      'The query has a syntax error. Check the brackets, the dot after each pattern and the prefixes (kg:, kgo:).';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'Same as phone';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get payoutCompany => 'Company';

  @override
  String payoutPayRegion(String region) {
    return 'Pay $region';
  }

  @override
  String get payoutPayGroup => 'Pay the whole group';

  @override
  String payoutPaySelected(int count) {
    return 'Pay $count people';
  }

  @override
  String payoutConfirmTitle(String period) {
    return 'Pay period $period?';
  }

  @override
  String payoutConfirmRegion(String region) {
    return 'Pays the employees of $region. Anyone already paid is shown to you first.';
  }

  @override
  String payoutConfirmGroup(int count) {
    return 'Pays the employees of all $count companies. Anyone already paid is shown to you first.';
  }

  @override
  String payoutConfirmPeople(int count, String region) {
    return 'Pays the $count selected people in $region.';
  }

  @override
  String get payoutConfirm => 'Pay';

  @override
  String get payoutDuplicateTitle => 'Some people are already paid';

  @override
  String get payoutDuplicateBody =>
      'Paying again sends their salary one more time. Either choice is recorded in the log.';

  @override
  String payoutDuplicateRegion(String region, int count) {
    return '$region: $count already paid';
  }

  @override
  String payoutDuplicatePerson(String employee, int count) {
    return '$employee · paid $count times';
  }

  @override
  String get payoutSkipPaid => 'Skip those already paid';

  @override
  String get payoutResend => 'Pay again';

  @override
  String get payoutTabPeople => 'Employees';

  @override
  String get payoutTabRuns => 'Runs';

  @override
  String get payoutTabLog => 'Log';

  @override
  String get payoutUnpaid => 'Not paid';

  @override
  String payoutPaidTimes(int count) {
    return 'Paid $count times';
  }

  @override
  String get payoutNotCalculated =>
      'This period has not been run yet. Pay the whole company first.';

  @override
  String get payoutResultTitle => 'Payout result';

  @override
  String payoutResultSummary(int paid, int resent, int skipped) {
    return 'Paid $paid · again $resent · skipped $skipped';
  }

  @override
  String payoutResultFailed(int count) {
    return '$count payments did not go through, try again later';
  }

  @override
  String payoutResultMissing(int count) {
    return '$count people have no payslip this period';
  }

  @override
  String get payoutStarted => 'Payroll started and paying';

  @override
  String get payoutRetried => 'Paying the remaining part';

  @override
  String get payoutBusy =>
      'This period is being processed, try again when it finishes';

  @override
  String get payoutUnreachable => 'Could not reach this company\'s server';

  @override
  String get payoutNothing => 'Nothing to pay';

  @override
  String get payoutAmountHidden =>
      'Amounts are visible only inside that company';

  @override
  String get payoutLogPaid => 'Paid';

  @override
  String get payoutLogResent => 'Paid again';

  @override
  String get payoutLogSkipped => 'Skipped, already paid';

  @override
  String get payoutLogWarned => 'Duplicate warning';

  @override
  String get payoutLogFailed => 'Did not go through';

  @override
  String get payoutLogSaga => 'Automatic payroll';

  @override
  String payoutLogLine(String actor, String time) {
    return '$actor · $time';
  }

  @override
  String get noPayoutLog => 'No payouts yet';

  @override
  String get errPayoutFailed =>
      'The payout was interrupted. Completed payments are recorded, try again later.';

  @override
  String payoutAccepted(int count) {
    return 'Paying $count items, follow progress in the Log tab';
  }

  @override
  String get payoutLogInDoubt => 'Unclear, needs reconciliation';

  @override
  String get manualIpButton => 'Change Manual IP';

  @override
  String get manualIpTitle => 'Manual IP';

  @override
  String get manualIpHint =>
      'Enter a public IP to act as if you were in that country: region and language are detected from it. Leave empty to use the real IP.';

  @override
  String manualIpCurrent(String region) {
    return 'Detected region: $region';
  }

  @override
  String get manualIpInvalid => 'Invalid IP';

  @override
  String manualIpSaved(String ip) {
    return 'Simulating IP $ip';
  }

  @override
  String get manualIpCleared => 'Using the real IP again';

  @override
  String get manualIpReset => 'Real IP';

  @override
  String moreNotifications(int count) {
    return 'and $count more';
  }

  @override
  String get filterAll => 'All';

  @override
  String get filterStatus => 'Status';

  @override
  String get filterType => 'Type';

  @override
  String get filterRead => 'Read';

  @override
  String get filterUnread => 'Unread';

  @override
  String get profileTab => 'Profile';

  @override
  String get myProfile => 'My profile';

  @override
  String get proposeChange => 'Request changes';

  @override
  String get proposeChangeHint =>
      'Edit only what changed. Your profile updates after HR approves.';

  @override
  String get changeReason => 'Reason (optional)';

  @override
  String get sendRequest => 'Send request';

  @override
  String get changeRequestSent => 'Request sent, waiting for HR';

  @override
  String get changeRequestPending => 'You have a request waiting for HR';

  @override
  String get changeRequestNoChange => 'Nothing has changed';

  @override
  String get changeHistory => 'Request history';

  @override
  String get changeRequests => 'Profile change requests';

  @override
  String get changeRequestsHint => 'Employees asking to update their details';

  @override
  String pendingChangeRequests(int count) {
    return '$count profile change requests';
  }

  @override
  String get noChangeRequests => 'No requests';

  @override
  String get oldValue => 'Old';

  @override
  String get newValue => 'New';

  @override
  String get decisionNote => 'Note to employee (optional)';

  @override
  String get fieldFacebook => 'Facebook';

  @override
  String get fieldXHandle => 'X handle';

  @override
  String get accountInfo => 'Account';

  @override
  String nProfileChangeRequested(String employee) {
    return '$employee asked to update their profile';
  }

  @override
  String get nProfileChangeApproved => 'HR approved your profile changes';

  @override
  String nProfileChangeRejected(String note) {
    return 'HR rejected your profile changes: $note';
  }

  @override
  String get invalidAmount => 'Invalid value';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String todoProfileChanges(int count) {
    return '$count profile change requests';
  }

  @override
  String get departments => 'Departments';

  @override
  String get departmentsHint => 'Transfers, heads, dissolution';

  @override
  String get departmentAdd => 'Add department';

  @override
  String get departmentName => 'Department name';

  @override
  String get departmentNameTaken =>
      'This company already has a department with that name';

  @override
  String departmentCreated(String name) {
    return 'Department $name added';
  }

  @override
  String get departmentEmpty => 'No one in this department yet';

  @override
  String get departmentHead => 'Head';

  @override
  String departmentHeadIs(String name) {
    return 'Head: $name';
  }

  @override
  String departmentMembers(int count) {
    return '$count people';
  }

  @override
  String get noHead => 'No head yet';

  @override
  String get noDepartments => 'No departments yet';

  @override
  String get sortedByHours => 'Head first, then by total hours worked';

  @override
  String get setHead => 'Make head';

  @override
  String headAssigned(String name) {
    return '$name is now the head';
  }

  @override
  String get moveToDepartment => 'Move to another department';

  @override
  String get moveHere => 'Move here';

  @override
  String transferDone(String name) {
    return 'Moved to $name';
  }

  @override
  String get addMembers => 'Add people';

  @override
  String get addMembersFrom => 'Take people from which department?';

  @override
  String addMembersTitle(String name) {
    return 'Move into $name';
  }

  @override
  String membersMoved(int count) {
    return '$count people moved';
  }

  @override
  String membersMovedPartly(int moved, int failed) {
    return '$moved moved, $failed could not be moved';
  }

  @override
  String get dissolveDepartment => 'Dissolve department';

  @override
  String dissolveTitle(String name) {
    return 'Dissolve $name?';
  }

  @override
  String get dissolveReason => 'Reason';

  @override
  String get dissolveNoLongerNeeded => 'No longer needed';

  @override
  String get dissolveRestructured => 'Restructured or merged';

  @override
  String get dissolveUnderperforming => 'Underperforming';

  @override
  String get dissolveOutsourced => 'Outsourced';

  @override
  String get dissolveBusinessClosed => 'Business line scaled down or closed';

  @override
  String dissolveMembersMove(int count) {
    return '$count people remain; choose a department to take them';
  }

  @override
  String get chooseReceivingDepartment => 'Choose receiving department';

  @override
  String get dissolveConfirm => 'Dissolve';

  @override
  String dissolveDone(String name) {
    return '$name dissolved';
  }

  @override
  String get unassignedStaff => 'New staff without a department';

  @override
  String unassignedCount(int count) {
    return '$count new people without a department';
  }

  @override
  String get unassignedHint => 'Let AI suggest a department or a new one';

  @override
  String get noUnassigned => 'Everyone has a department';

  @override
  String get aiSuggestPlacement => 'AI placement suggestions';

  @override
  String get aiThinking => 'AI is thinking...';

  @override
  String get suggestionByAi => 'Suggested by AI; HR makes the final call';

  @override
  String get suggestionByRules =>
      'AI unavailable; suggested by matching positions';

  @override
  String suggestedDepartment(String name) {
    return 'Suggested: $name';
  }

  @override
  String get acceptSuggestion => 'Accept';

  @override
  String get chooseOther => 'Choose another';

  @override
  String get chooseDepartment => 'Choose department';

  @override
  String get newDepartmentProposals => 'Proposed new departments';

  @override
  String get createDepartmentAndMove => 'Create and move people';

  @override
  String get rankings => 'Top performers';

  @override
  String get rankingsHint => 'Ranking by hours, promotion nominations';

  @override
  String get rankingFormula =>
      'Score = regular hours + 1.5 × overtime + 2 × days worked';

  @override
  String rankingDetail(String work, String overtime, int days) {
    return '$work h · $overtime h overtime · $days days';
  }

  @override
  String get points => 'points';

  @override
  String get noRankings => 'No attendance data in this period';

  @override
  String lastMonths(int count) {
    return 'Last $count months';
  }

  @override
  String get filterPeriod => 'Period';

  @override
  String get filterDepartment => 'Department';

  @override
  String get filterPosition => 'Position';

  @override
  String get filterCompany => 'Company';

  @override
  String get filterRegion => 'Region';

  @override
  String get statusWorking => 'Working';

  @override
  String get statusArchived => 'Archived';

  @override
  String get viewProfile => 'View profile';

  @override
  String get nominatePromotion => 'Nominate for promotion';

  @override
  String nominateTitle(String name) {
    return 'Nominate $name';
  }

  @override
  String get proposedPosition => 'Proposed position';

  @override
  String get raisePercent => 'Salary raise';

  @override
  String get raisePercentInvalid => 'Enter 0.1 to 100';

  @override
  String get nominationReason => 'Reason for nomination';

  @override
  String get sendToExecutives => 'Send to executives';

  @override
  String get nominationSent => 'Nomination sent to executives';

  @override
  String get nominations => 'Promotion nominations';

  @override
  String get nominationsHint => 'Executives approve title and pay';

  @override
  String get noNominations => 'No nominations';

  @override
  String raiseBy(String percent) {
    return 'Raise $percent%';
  }

  @override
  String get approvePromotion => 'Approve promotion';

  @override
  String approvePromotionHint(String name, String position, String percent) {
    return '$name becomes $position with a $percent% base salary raise.';
  }

  @override
  String get promotionApproved => 'Approved: title and salary updated';

  @override
  String get promotionApprovedNoRaise =>
      'Title changed; salary raise pending, retry in Payroll';

  @override
  String get promotionRejected => 'Nomination rejected';

  @override
  String todoNominations(int count) {
    return '$count promotions to review';
  }

  @override
  String get archiveProfile => 'Archive profile';

  @override
  String archiveTitle(String name) {
    return 'Archive $name?';
  }

  @override
  String archiveProjectsWarning(int count) {
    return 'This person is on $count projects and will be removed from all of them:';
  }

  @override
  String get archiveNoProjects => 'This person is not on any project.';

  @override
  String get archiveKeepsPersonal =>
      'Personal details are kept and the profile can be restored.';

  @override
  String get archiveReason => 'Reason';

  @override
  String get archiveConfirm => 'Archive';

  @override
  String archiveDone(int count) {
    return 'Archived and removed from $count projects';
  }

  @override
  String profileArchivedBanner(String reason) {
    return 'Profile archived. Reason: $reason';
  }

  @override
  String get restoreProfile => 'Restore';

  @override
  String get restoreDone => 'Profile restored';

  @override
  String get fieldRequired => 'Required';

  @override
  String get errIsHead => 'Assign a new head before moving the current one';

  @override
  String get errLastMember => 'A department must keep at least one person';

  @override
  String get errSameDepartment => 'Already in this department';

  @override
  String get errArchived => 'This profile is archived; restore it first';

  @override
  String get errNotArchived => 'This profile is not archived';

  @override
  String get errMembersRemaining =>
      'People remain; choose a receiving department';

  @override
  String get errNotMember => 'Not a member of this department';

  @override
  String get errPendingExists => 'A request is already waiting for review';

  @override
  String get errServiceUnavailable =>
      'Part of the system is busy; try again shortly';

  @override
  String nPromotionNominated(String employee, String position) {
    return '$employee nominated for $position, awaiting review';
  }

  @override
  String nPromotionApproved(String position) {
    return 'Congratulations! You were promoted to $position';
  }

  @override
  String nPromotionRejected(String position) {
    return 'Promotion to $position not approved';
  }

  @override
  String nPromotionApprovedHr(String employee) {
    return 'Executives approved the promotion of $employee';
  }

  @override
  String nPromotionRejectedHr(String employee) {
    return 'Executives rejected the promotion of $employee';
  }

  @override
  String get nEmployeeTransferred => 'You were moved to a new department';

  @override
  String get nDepartmentHeadAssigned => 'You are now head of your department';

  @override
  String memberHours(String hours) {
    return '$hours h';
  }

  @override
  String get stageInterviewed => 'Interviewed';

  @override
  String get interviewAwaitingCandidate => 'Waiting for candidate';

  @override
  String get interviewAwaitingHr => 'Waiting for HR';

  @override
  String get interviewConfirmed => 'Confirmed';

  @override
  String get interviewCancelled => 'Cancelled';

  @override
  String get interviewSchedule => 'Interview';

  @override
  String minutesAttached(String name) {
    return 'Minutes: $name';
  }

  @override
  String get chooseInterviewTime => 'Choose date and time';

  @override
  String get errTimeInPast => 'The interview time must be in the future';

  @override
  String get interviewLocation => 'Place or meeting link';

  @override
  String get send => 'Send';

  @override
  String get rejectCandidate => 'Reject';

  @override
  String rejectCandidateHint(String name) {
    return 'Reject $name? You can reconsider later.';
  }

  @override
  String get scheduleInterview => 'Schedule interview';

  @override
  String get scheduleAgain => 'Schedule again';

  @override
  String get interviewSent => 'Time sent, waiting for confirmation';

  @override
  String get proposeOtherTime => 'Suggest another time';

  @override
  String get confirmTime => 'Confirm this time';

  @override
  String get interviewConfirmedDone => 'Interview confirmed';

  @override
  String get uploadMinutes => 'Upload interview minutes';

  @override
  String get minutesUploaded =>
      'Minutes saved, candidate marked as interviewed';

  @override
  String get minutesAfterInterview =>
      'Upload the minutes (Word, Excel) after the interview';

  @override
  String get openMinutes => 'Open minutes';

  @override
  String get moveToScreening => 'Move to screening';

  @override
  String get reconsider => 'Reconsider';

  @override
  String get reconsidered => 'Application moved back to its previous step';

  @override
  String get waitingCandidateReply =>
      'Waiting for the candidate to confirm or suggest a time';

  @override
  String get waitingHrReply => 'Waiting for HR to confirm your time';

  @override
  String get hiredSalaryPending =>
      'The agreed salary was not saved, enter it again in Payroll';

  @override
  String get offerFromAi => 'AI suggestion';

  @override
  String get offerFromRules => 'Data-based suggestion';

  @override
  String get offerPeerMedian =>
      'Median pay of the same position, department with most peers';

  @override
  String get offerRegionMedian =>
      'No peers yet: regional median pay, largest department';

  @override
  String get agreedSalary => 'Agreed base salary';

  @override
  String get currency => 'Currency';

  @override
  String get errInvalidStep =>
      'This step is not allowed now, refresh to see the latest step';

  @override
  String get errNotScreened => 'Screen the application before scheduling';

  @override
  String get errInterviewNotConfirmed => 'The interview is not confirmed yet';

  @override
  String get errNotInterviewed => 'Upload the interview minutes before hiring';

  @override
  String get errNotRejected => 'This application is not rejected';

  @override
  String get errInvalidOffer => 'Salary must be above 0 with a currency';

  @override
  String get errMinutesFile => 'Minutes must be a Word or Excel file';

  @override
  String nInterviewScheduled(String position, String time) {
    return 'Interview for $position at $time, tap to confirm';
  }

  @override
  String nInterviewConfirmed(String time) {
    return 'Your interview at $time is confirmed';
  }

  @override
  String nInterviewConfirmedHr(String position, String time) {
    return 'Interview for $position at $time is confirmed';
  }

  @override
  String nInterviewProposed(String position, String time) {
    return 'Candidate for $position proposed $time';
  }

  @override
  String get projectTier => 'Tier';

  @override
  String get tierSmall => 'Tier 1 · Small';

  @override
  String get tierMedium => 'Tier 2 · Medium';

  @override
  String get tierLarge => 'Tier 3 · Large';

  @override
  String get tierStrategic => 'Tier 4 · Strategic';

  @override
  String tierRule(int months, int members) {
    return 'Up to $months months, at least $members people';
  }

  @override
  String get warnRed => '≤ 1 month left';

  @override
  String get warnOrange => '≤ 6 months left';

  @override
  String get warnYellow => '≤ 12 months left';

  @override
  String get warnNotStarted => 'Not started';

  @override
  String get warnAccepted => 'Accepted';

  @override
  String get warnNormal => 'Over 12 months left';

  @override
  String get projectCharts => 'Project charts';

  @override
  String get chart2d => '2D';

  @override
  String get chart3d => '3D';

  @override
  String get chartTimeline => 'Timeline';

  @override
  String get chartProgress => 'Progress';

  @override
  String get chartMembers => 'People';

  @override
  String get chartValue => 'Value';

  @override
  String get thousandUsd => 'thousand USD';

  @override
  String get projectProposals => 'Project proposals';

  @override
  String get projectNew => 'New project';

  @override
  String get wizardFiles => 'Contract and image';

  @override
  String get wizardFilesHint =>
      'Upload the contract (PDF or Word, from the template); AI fills in the form. Without a contract, enter it by hand next.';

  @override
  String get wizardInfo => 'Project details';

  @override
  String get wizardMembers => 'Team';

  @override
  String get wizardSend => 'Send to management';

  @override
  String get downloadContractTemplate => 'Download contract template';

  @override
  String get uploadContract => 'Upload contract';

  @override
  String get uploadProjectImage => 'Upload project image';

  @override
  String get contractReadByAi =>
      'AI read the contract and filled the form, check it next';

  @override
  String get contractReadManual =>
      'Could not read the contract automatically, enter the details next';

  @override
  String get projectName => 'Project name';

  @override
  String get customerName => 'Client';

  @override
  String get customerCompany => 'Company';

  @override
  String get customerIndividual => 'Individual';

  @override
  String get customerContact => 'Client contact (email or phone)';

  @override
  String get contractType => 'Contract type';

  @override
  String get contractValue => 'Contract value';

  @override
  String get depositAmount => 'Deposit';

  @override
  String get startDate => 'Start';

  @override
  String get endDate => 'End';

  @override
  String get acceptanceDate => 'Acceptance';

  @override
  String get propErrName => 'Project name is required';

  @override
  String get propErrCustomer => 'Client is required';

  @override
  String get propErrValue => 'Contract value must be above 0';

  @override
  String get propErrDeposit =>
      'Deposit cannot be negative or above the contract value';

  @override
  String get propErrDates => 'Start and end dates are required';

  @override
  String get propErrStartPast => 'Start date cannot be in the past';

  @override
  String get propErrEndBeforeStart => 'End must be after start';

  @override
  String get propErrAcceptance =>
      'Acceptance must be within 90 days after the end';

  @override
  String get propErrTooLong => 'Too long for this tier';

  @override
  String get propErrFewMembers => 'Not enough people for this tier';

  @override
  String membersNeeded(int min, int picked) {
    return 'At least $min people · $picked selected';
  }

  @override
  String get suggestMembers => 'AI team suggestion';

  @override
  String activeProjects(int count) {
    return '$count active projects';
  }

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get sendToExecutive => 'Send for approval';

  @override
  String get proposalSent => 'Proposal sent, waiting for management';

  @override
  String get noProposals => 'No project proposals';

  @override
  String proposalVersion(int version) {
    return 'Version $version';
  }

  @override
  String get propAwaitingExecutive => 'Waiting for management';

  @override
  String get propAwaitingProposer => 'Waiting for proposer';

  @override
  String get propApproved => 'Approved';

  @override
  String get propRejected => 'Rejected';

  @override
  String get proposalEdit => 'Edit proposal';

  @override
  String get proposalNoteHint => 'Reason or what to change';

  @override
  String proposalApprovedDone(String id) {
    return 'Approved, project $id created';
  }

  @override
  String get acceptEdits => 'Accept edits';

  @override
  String get withdrawProposal => 'Withdraw';

  @override
  String get waitingOtherSide => 'Waiting for the other side';

  @override
  String get openContract => 'Open contract';

  @override
  String get openImage => 'Open image';

  @override
  String get openProject => 'Open project';

  @override
  String get propActSubmitted => 'Submitted';

  @override
  String get propActCounter => 'Edited';

  @override
  String get propActApprove => 'Agreed';

  @override
  String get propActReject => 'Rejected';

  @override
  String get propActWithdraw => 'Withdrawn';

  @override
  String todoProposals(int count) {
    return '$count project proposals to review';
  }

  @override
  String nProjectProposed(String name) {
    return 'New project proposal to review: $name';
  }

  @override
  String nProjectCountered(String name) {
    return 'Management edited $name, please confirm';
  }

  @override
  String nProjectApproved(String name) {
    return 'Project $name approved and created';
  }

  @override
  String nProjectRejected(String name) {
    return 'Project proposal $name rejected';
  }

  @override
  String get workCalendar => 'Work calendar';

  @override
  String get clockStats => 'Attendance charts';

  @override
  String shiftHours(String start, String end) {
    return 'Shift $start–$end';
  }

  @override
  String get errShiftEnded => 'The shift has ended, you can no longer clock in';

  @override
  String get errTooManyFiles => 'At most 5 files per request';

  @override
  String get errFileType =>
      'This file type is not accepted, choose a supported file';

  @override
  String get addEvidence => 'Add evidence';

  @override
  String viewOriginalLeave(int count) {
    return 'View originals ($count)';
  }

  @override
  String get evidenceUploaded => 'Evidence added, AI summary updated for HR';

  @override
  String get noEvidence => 'No evidence yet';

  @override
  String get aiLeaveSummary => 'AI evidence summary';

  @override
  String get evidenceMatches => 'Matches the request';

  @override
  String get evidenceCheck => 'Needs a closer look';

  @override
  String get calWorked => 'Worked';

  @override
  String get calLeave => 'Leave';

  @override
  String get calHoliday => 'Holiday';

  @override
  String get calAbsent => 'Absent';

  @override
  String get calScheduled => 'Scheduled';

  @override
  String calLeaveOfType(String type) {
    return 'Leave: $type';
  }

  @override
  String get noShiftThisDay => 'No shift on this day';

  @override
  String estimatedDayPay(String amount) {
    return 'Estimated pay for the day: $amount';
  }

  @override
  String estimatedMonthPay(String amount) {
    return 'Estimated pay from hours worked: $amount';
  }

  @override
  String get payEstimateHint =>
      'Based on base salary, 26 working days, overtime at 150%; before insurance and tax';

  @override
  String get projectsThisDay => 'Projects on this day';

  @override
  String get statsScopeRegion => 'Whole region';

  @override
  String get statsScopeMine => 'Mine';

  @override
  String get statsDays => 'Days clocked';

  @override
  String get statsLate => 'Late arrivals';

  @override
  String get statsByWeekday => 'By weekday';

  @override
  String get statsByHour => 'Clock-in time';

  @override
  String get statsByMonth => 'Days and late arrivals by month';

  @override
  String get errPayrollTooEarly =>
      'This period is not open yet: month M pays from the 10th of month M+1';

  @override
  String get errAmountLowered => 'The proposed salary can only stay or go up';

  @override
  String get errNotHigher =>
      'The requested salary must be above the current one';

  @override
  String get errNoSalary => 'No base salary on record yet';

  @override
  String get errAwaitingAck =>
      'The previous report is waiting for confirmation';

  @override
  String get acknowledge => 'Confirm';

  @override
  String get byDay => 'Day';

  @override
  String get byMonth => 'Month';

  @override
  String get byYear => 'Year';

  @override
  String get costs => 'Costs';

  @override
  String get export => 'Export';

  @override
  String get exportExcel => 'Export Excel';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String exportedAt(String time) {
    return 'Exported at $time';
  }

  @override
  String get exportId => 'ID';

  @override
  String get exportPeriod => 'Period';

  @override
  String get exportRank => 'Rank';

  @override
  String get exportMargin => 'Margin';

  @override
  String get exportCurrency => 'Currency';

  @override
  String get exportRevenueUsd => 'Revenue (USD)';

  @override
  String get exportCostUsd => 'Costs (USD)';

  @override
  String exportFinanceTitle(int year) {
    return 'Income and costs $year';
  }

  @override
  String get financeAnalytics => 'Analytics';

  @override
  String get materialCost => 'Materials';

  @override
  String get payrollCost => 'Payroll';

  @override
  String get materialsUsed => 'Materials used';

  @override
  String get revenueByStage => 'Revenue by stage';

  @override
  String get projectProfitRanking => 'Projects ranked by profit';

  @override
  String get projectSalaryShares => 'Project pay per person';

  @override
  String get overtimePay => 'Overtime';

  @override
  String get insuranceDeduction => 'Insurance';

  @override
  String get incomeTax => 'Income tax';

  @override
  String get salaryGrowth => 'Pay over time';

  @override
  String salaryGrowthRate(String rate, int count) {
    return 'Net pay $rate over $count periods';
  }

  @override
  String payrollOpensOn(String period, String date) {
    return 'Payroll for $period opens on $date';
  }

  @override
  String get raiseRequests => 'Raise requests';

  @override
  String get raiseRequestsHint => 'Request, forward, approve raises';

  @override
  String get newRaiseRequest => 'Request a raise';

  @override
  String get noRaiseRequests => 'No raise requests';

  @override
  String get proposedSalary => 'Proposed base salary';

  @override
  String raiseMinimum(String amount) {
    return 'At least $amount';
  }

  @override
  String get raiseReason => 'Reason (results, new duties...)';

  @override
  String get raiseActionTitle => 'Salary and note';

  @override
  String get raiseSent => 'Raise request sent';

  @override
  String get raiseForwarded => 'Forwarded for approval';

  @override
  String get raiseApprovedDone => 'Approved, base salary raised';

  @override
  String get raiseForward => 'Forward';

  @override
  String get raiseReturn => 'Return';

  @override
  String get raiseEdit => 'Edit amount';

  @override
  String get raiseAwaitingHr => 'With HR';

  @override
  String get raiseAwaitingApprover => 'Awaiting approval';

  @override
  String get raiseAwaitingEmployee => 'Returned to employee';

  @override
  String get raiseWithdrawn => 'Withdrawn';

  @override
  String raiseRequestedFirst(String amount) {
    return 'Originally requested $amount';
  }

  @override
  String get reportSubmissions => 'Reports to management';

  @override
  String get reportSubmissionsHint => 'HR and finance reports, confirmation';

  @override
  String get reportHr => 'HR';

  @override
  String get reportFinance => 'Finance';

  @override
  String get noReports => 'No reports yet';

  @override
  String get submitReport => 'Send report';

  @override
  String submitReportTitle(String period) {
    return 'Send report for $period';
  }

  @override
  String get reportWaitingAck => 'Awaiting confirmation';

  @override
  String get reportSent => 'Report sent to management';

  @override
  String get reportAcknowledged => 'Report confirmed';

  @override
  String get returnReport => 'Return report';

  @override
  String get reportStatusSubmitted => 'Awaiting confirmation';

  @override
  String get reportStatusAcknowledged => 'Confirmed';

  @override
  String get reportStatusReturned => 'Returned';

  @override
  String reportPeriod(String period) {
    return 'Report for $period';
  }

  @override
  String reportHeadcount(int people, int departments) {
    return '$people employees, $departments departments';
  }

  @override
  String reportUnassigned(int count) {
    return '$count without a department';
  }

  @override
  String reportNominations(int pending, int approved) {
    return 'Promotions: $pending pending, $approved approved';
  }

  @override
  String get resignations => 'Resignation';

  @override
  String get resignationsHint => 'Submit and track resignations';

  @override
  String get newResignation => 'Resign';

  @override
  String get resignationLastDay => 'Last working day';

  @override
  String resignationLastDayOn(String date) {
    return 'Last day: $date';
  }

  @override
  String get resignationReason => 'Reason for leaving';

  @override
  String resignationNotice(int days) {
    return 'Give at least $days days of notice';
  }

  @override
  String get resignationSent => 'Resignation sent to HR';

  @override
  String get noResignations => 'No resignations yet';

  @override
  String get resignationPending => 'Waiting for HR';

  @override
  String get resignationApproved => 'Approved, serving notice';

  @override
  String get resignationCompleted => 'Left the company';

  @override
  String get resignationWithdrawn => 'Withdrawn';

  @override
  String get resignationWithdraw => 'Withdraw';

  @override
  String get resignationComplete => 'Complete exit';

  @override
  String resignationCompleteConfirm(String name) {
    return '$name\'s record will be archived and removed from all projects. Continue?';
  }

  @override
  String get resignationCompletedDone => 'Exit completed, record archived';

  @override
  String get errNoticeTooShort =>
      'The last day must be at least 30 days from today';

  @override
  String get errBeforeLastDay => 'The last working day has not come yet';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get exportJson => 'Export JSON';

  @override
  String get auditCharts => 'Charts';

  @override
  String get auditFilter => 'Detailed filter';

  @override
  String get auditService => 'Service';

  @override
  String get auditEventType => 'Event type';

  @override
  String get auditTime => 'Time';

  @override
  String get auditFromTime => 'From';

  @override
  String get auditToTime => 'To';

  @override
  String get anyTime => 'Any';

  @override
  String get anomalyAny => 'Anomalies';

  @override
  String get anomalyAfterHours => 'After hours (10pm–6am)';

  @override
  String get anomalyFailure => 'Failed or rejected';

  @override
  String get auditTotal => 'Total events';

  @override
  String get auditByRegion => 'By region';

  @override
  String get auditByHour => 'By local hour (red is after hours)';

  @override
  String get auditByDay => 'By day';

  @override
  String get auditByType => 'Top event types';

  @override
  String get auditByService => 'By service';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get auditSignedExport => 'Signed CSV with SHA-256';

  @override
  String get approvalInbox => 'Approval inbox';

  @override
  String get approvalInboxHint =>
      'Projects, promotions, raises waiting in all regions';

  @override
  String get approvalKindProject => 'Project';

  @override
  String get approvalKindPromotion => 'Promotion';

  @override
  String get approvalKindRaise => 'Raise';

  @override
  String get noApprovals => 'Nothing is waiting for approval';

  @override
  String approvalWaiting(int count) {
    return '$count waiting for approval';
  }

  @override
  String approvalRegionsDown(String regions) {
    return 'No data from: $regions';
  }

  @override
  String get approvalByRegion => 'Waiting by region';

  @override
  String approvalPromotionLine(String position, String percent) {
    return 'To $position, +$percent% salary';
  }

  @override
  String get approvalDone => 'Decision saved';

  @override
  String approvalConfirm(String title) {
    return 'Approve $title?';
  }

  @override
  String approvalRejectConfirm(String title) {
    return 'Reject $title?';
  }

  @override
  String get approvalColKind => 'Type';

  @override
  String get approvalColTitle => 'Subject';

  @override
  String get approvalColDetail => 'Details';

  @override
  String get approvalColUpdated => 'Updated';

  @override
  String get jobPositions => 'Job openings';

  @override
  String get jobPositionsHint =>
      'Open roles, headcount, applicants ranked by AI match';

  @override
  String get newJobPosition => 'New opening';

  @override
  String get editJobPosition => 'Edit opening';

  @override
  String get noJobPositions => 'No job openings yet';

  @override
  String get positionTitle => 'Job title';

  @override
  String get positionDepartment => 'Department';

  @override
  String get positionHeadcount => 'People needed';

  @override
  String get positionDescription => 'Job description';

  @override
  String get positionRequirements => 'Requirements';

  @override
  String get positionRequirementsHint =>
      'AI scores each CV against these requirements';

  @override
  String get positionOpen => 'Hiring';

  @override
  String get positionFilled => 'Filled';

  @override
  String get positionClosed => 'Closed';

  @override
  String get closePosition => 'Close opening';

  @override
  String get reopenPosition => 'Reopen';

  @override
  String get positionSaved => 'Job opening saved';

  @override
  String get positionApplicants => 'Applicants (best AI match first)';

  @override
  String positionProgress(int hired, int headcount, int applicants) {
    return 'Hired $hired/$headcount · $applicants applicants';
  }

  @override
  String positionSlotsLeft(int count) {
    return '$count left';
  }

  @override
  String get choosePositions => 'Choose positions';

  @override
  String get choosePositionsHint => 'Tap to choose';

  @override
  String choosePositionsHelper(int max) {
    return 'Choose one or more, up to $max';
  }

  @override
  String positionsChosen(int count) {
    return 'Done ($count chosen)';
  }

  @override
  String get positionMatchTitle => 'Fit for each position (AI)';

  @override
  String get positionMatchPending => 'AI is matching';

  @override
  String get positionMatchNone => 'Not matched';

  @override
  String get positionMatchStrengths => 'Meets';

  @override
  String get positionMatchGaps => 'Missing';

  @override
  String bestMatch(int score) {
    return '$score% match';
  }

  @override
  String get errNoPosition => 'Choose at least one position';

  @override
  String get errTooManyPositions => 'Choose at most 5 positions';

  @override
  String get errPositionUnavailable =>
      'This position is closed or full, choose another';

  @override
  String get errPositionTitleExists =>
      'An open position with this title already exists';

  @override
  String get errInvalidHeadcount => 'People needed must be 1 to 500';

  @override
  String errHeadcountBelowHired(int hired) {
    return '$hired already hired, cannot set lower';
  }

  @override
  String get errInvalidPosition =>
      'Enter a job title and how many people are needed';

  @override
  String nRaiseRequested(String employee) {
    return '$employee requested a raise';
  }

  @override
  String nRaiseForwarded(String employee) {
    return 'HR forwarded $employee\'s raise request for your approval';
  }

  @override
  String get nRaiseApproved => 'Your raise request was approved';

  @override
  String get nRaiseRejected => 'Your raise request was rejected';

  @override
  String get nRaiseReturned => 'Your raise request was returned for changes';

  @override
  String nReportSubmitted(String report, String period) {
    return 'New $report report for $period to confirm';
  }

  @override
  String nReportAcknowledged(String report, String period) {
    return '$report report for $period was confirmed';
  }

  @override
  String nReportReturned(String report, String period) {
    return '$report report for $period was returned, see the note';
  }

  @override
  String nResignationRequested(String employee, String date) {
    return '$employee resigned, last working day $date';
  }

  @override
  String nResignationApproved(String date) {
    return 'Your resignation was approved, last day $date';
  }

  @override
  String get nResignationRejected => 'Your resignation was not approved';

  @override
  String nResignationWithdrawn(String employee) {
    return '$employee withdrew their resignation';
  }

  @override
  String get reportKindHr => 'HR';

  @override
  String get reportKindFinance => 'finance';

  @override
  String get openFullPage => 'Open full page';

  @override
  String get requestAlreadyHandled => 'This request has already been handled';

  @override
  String get requestFrom => 'From';

  @override
  String get waitingSuperior => 'Waiting for your superior';

  @override
  String get signupTitle => 'Create a candidate account';

  @override
  String get signupHint =>
      'Enter your real details. A 6-digit code will be sent to this email.';

  @override
  String get sendCode => 'Send code';

  @override
  String codeSentTo(String email) {
    return 'Code sent to $email, check Spam too';
  }

  @override
  String get verificationCode => 'Verification code (6 digits)';

  @override
  String get newPassword => 'Password';

  @override
  String get passwordRule => 'At least 8 characters with letters and digits';

  @override
  String get confirmPassword => 'Repeat password';

  @override
  String get createAccount => 'Verify and create account';

  @override
  String get resendCode => 'Resend code';

  @override
  String resendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get editDetails => 'Edit name, email, phone';

  @override
  String get signupDone => 'Account created, please sign in';

  @override
  String get changePassword => 'Change password';

  @override
  String get passwordChanged => 'Password changed';

  @override
  String get profileViewed => 'Your application has been viewed';

  @override
  String get profileViewedHint =>
      'HR has opened your application, so it can no longer be edited';

  @override
  String get cvRequired => 'Attach your CV (PDF) to save';

  @override
  String get accountDetails => 'From your registered account';

  @override
  String get errInvalidEmail => 'Email is not valid';

  @override
  String get errInvalidName => 'Name must be 2 to 80 characters';

  @override
  String get errInvalidPhone => 'Phone number is not valid';

  @override
  String get errWeakPassword =>
      'Password needs 8+ characters with letters and digits';

  @override
  String get errEmailTaken =>
      'This email already has an account, please sign in';

  @override
  String get errCodeTooSoon => 'A code was just sent, wait 60 seconds';

  @override
  String get errCodeExpired =>
      'The code expired or was entered wrong too often, request a new one';

  @override
  String get errWrongCode => 'Wrong verification code';

  @override
  String get errSignupUnavailable =>
      'Cannot send email right now, try again shortly';

  @override
  String get projectTime => 'Period';

  @override
  String get me => 'Me';

  @override
  String myProjectPay(String amount) {
    return 'My project pay: $amount';
  }

  @override
  String get mySchedule => 'My work schedule';

  @override
  String myScheduleHint(int days) {
    return '$days days worked this month during the project';
  }

  @override
  String myScheduleEarned(String amount) {
    return 'Estimated pay for days worked: $amount';
  }

  @override
  String get notCheckedIn => 'Not checked in';

  @override
  String get contractRequired =>
      'Upload the contract (PDF, Word) so AI can read the project details';

  @override
  String get attachedBonuses =>
      'Bonuses and penalties, last 12 months (attached)';

  @override
  String bonusNet(String amount) {
    return 'Net: $amount';
  }

  @override
  String moreItems(int count) {
    return 'and $count more';
  }

  @override
  String get orgTree => 'Organisation chart';

  @override
  String get orgTreeSearch => 'Search people or roles';

  @override
  String orgTreeSummary(int departments, int people) {
    return '$departments departments · $people people';
  }

  @override
  String get orgTreeToggle => 'Collapse or expand all';

  @override
  String get level1 => 'Staff';

  @override
  String get level2 => 'Specialist, engineer';

  @override
  String get level3 => 'Lead, deputy head';

  @override
  String get level4 => 'Head, manager';

  @override
  String get level5 => 'Director';

  @override
  String get level6 => 'Executive board';

  @override
  String get noHigherPosition => 'This person is already at the top level';

  @override
  String get errNotHigherPosition => 'Promotion must be to a higher level';

  @override
  String get errUnknownPosition => 'Pick a position from the list';

  @override
  String overtimeApprovedToday(String hours, String until) {
    return '$hours h overtime approved: work until $until counts';
  }

  @override
  String overtimePendingToday(String hours) {
    return '$hours h overtime request pending: not counted until approved';
  }

  @override
  String get overtimeNoneToday =>
      'No approved overtime: time after the shift is not counted';

  @override
  String get viewZoomIn => 'Zoom in';

  @override
  String get viewZoomOut => 'Zoom out';

  @override
  String get viewFromTop => 'View from above';

  @override
  String get viewFromBottom => 'View from below';

  @override
  String get viewRotateLeft => 'Rotate left';

  @override
  String get viewRotateRight => 'Rotate right';

  @override
  String get viewReset => 'Reset view';

  @override
  String get sectionGroup => 'Group';

  @override
  String get sectionAdmin => 'Administration';

  @override
  String get roleGroup => 'Group level';

  @override
  String get groupOverview => 'Group overview';

  @override
  String get groupOverviewHint =>
      'Figures per country, tap a country for details';

  @override
  String get adminConsole => 'Data administration';

  @override
  String get adminConsoleHint =>
      'Accounts, work calendar, positions, statistics, backups, SQL';

  @override
  String viewingRegion(String region) {
    return 'Viewing: $region';
  }

  @override
  String get chooseRegion => 'Choose a region';

  @override
  String get approvalKindLeave => 'Leave';

  @override
  String get approvalKindOvertime => 'Overtime';

  @override
  String get approvalKindProfile => 'Profile change';

  @override
  String get approvalKindResignation => 'Resignation';

  @override
  String get groupTotals => 'Whole group';

  @override
  String get groupEmployees => 'Employees';

  @override
  String get groupRevenueYtd => 'Revenue this year (USD)';

  @override
  String get groupCostYtd => 'Costs this year (USD)';

  @override
  String get groupRegionDown =>
      'Could not load this country yet, pull to retry';

  @override
  String get execActions => 'Act directly';

  @override
  String get execChangePosition => 'Promote or change position';

  @override
  String get execPromote => 'Promote';

  @override
  String get execChangeOnly => 'Change position';

  @override
  String get execNewPosition => 'New position';

  @override
  String get execNoHigherPosition => 'No higher position available';

  @override
  String get execReason => 'Reason (kept in the audit log)';

  @override
  String get execReasonRequired => 'Reason (required)';

  @override
  String get execSalary => 'Change base salary';

  @override
  String execCurrentSalary(String amount) {
    return 'Current base salary: $amount';
  }

  @override
  String get execNewSalary => 'New base salary';

  @override
  String get execBonus => 'Bonus or penalty';

  @override
  String get execBonusKind => 'Bonus';

  @override
  String get execPenaltyKind => 'Penalty';

  @override
  String get execAmount => 'Amount (in the employee\'s salary currency)';

  @override
  String get execApply => 'Apply now';

  @override
  String get execAuditNote =>
      'Takes effect immediately without further approval; recorded in the audit log with your name.';

  @override
  String get execApplied => 'Applied and recorded in the audit log';

  @override
  String get nominationScope => 'Scope';

  @override
  String get nominationScopeRegion => 'Promotion within the country';

  @override
  String get nominationScopeGroupHr => 'To Group HR';

  @override
  String get nominationScopeGroupFinance => 'To Group finance';

  @override
  String get nominationGroupNote =>
      'Decided by the group executive office; once approved this person works across all regions.';

  @override
  String get nominationToGroup => 'Group level';

  @override
  String get adminTabOverview => 'Overview';

  @override
  String get adminTabAccounts => 'Accounts';

  @override
  String get adminTabCalendar => 'Work calendar';

  @override
  String get adminTabPositions => 'Positions';

  @override
  String get adminTabData => 'Data';

  @override
  String get adminAccountsByRole => 'Accounts by role';

  @override
  String adminAccountsTotal(int n) {
    return '$n accounts';
  }

  @override
  String get adminDatabases => 'Databases';

  @override
  String adminDbLine(int tables, String rows, String size) {
    return '$tables tables · $rows rows · $size';
  }

  @override
  String get adminActivity => 'Activity in the last 14 days (events)';

  @override
  String get adminRowsByDb => 'Rows per database';

  @override
  String get adminDbUnavailable => 'This database could not be read';

  @override
  String get adminSearchAccounts => 'Search name, email, username';

  @override
  String get adminAccountDisabled => 'Disabled';

  @override
  String adminEditAccount(String name) {
    return 'Edit account $name';
  }

  @override
  String get adminAccountEnabled => 'Allow sign-in';

  @override
  String get adminRoles => 'Roles';

  @override
  String get adminSaved => 'Saved and recorded in the audit log';

  @override
  String get adminHolidays => 'Holidays';

  @override
  String get adminAddHoliday => 'Add holiday';

  @override
  String get adminHolidayName => 'Holiday name';

  @override
  String adminHolidayRemove(String name) {
    return 'Remove holiday $name?';
  }

  @override
  String get adminNoHolidays => 'No holidays for this year yet';

  @override
  String get adminShift => 'Shift hours';

  @override
  String get adminShiftHint =>
      'Change start and end time for every shift in a date range (from today on; past work stays as recorded)';

  @override
  String get adminShiftChange => 'Change shift hours';

  @override
  String get adminShiftStart => 'Start';

  @override
  String get adminShiftEnd => 'End';

  @override
  String get adminShiftRange => 'Date range';

  @override
  String adminShiftDone(int n) {
    return 'Updated $n shifts';
  }

  @override
  String get adminAddPosition => 'Add position';

  @override
  String get adminEditPosition => 'Edit position';

  @override
  String get adminPositionName => 'Position name';

  @override
  String get adminPositionLevel => 'Level';

  @override
  String get adminCoefficient => 'Salary coefficient';

  @override
  String adminHolders(int n) {
    return '$n holders';
  }

  @override
  String get adminDeletePosition => 'Delete position';

  @override
  String get adminSql => 'SQL query';

  @override
  String get adminSqlHint =>
      'Read-only by default; every run is recorded in the audit log';

  @override
  String get adminSqlWrite => 'Allow writes (INSERT, UPDATE, DELETE)';

  @override
  String get adminSqlWriteConfirm =>
      'This changes real data and is recorded in the audit log. Run it?';

  @override
  String get adminSqlRun => 'Run';

  @override
  String adminSqlRows(int n) {
    return '$n rows';
  }

  @override
  String adminSqlAffected(int n) {
    return '$n rows affected';
  }

  @override
  String get adminSqlTruncated => 'Showing the first 500 rows';

  @override
  String get adminTechnical => 'Technical details';

  @override
  String get adminBackups => 'Backups';

  @override
  String get adminBackupNow => 'Back up now';

  @override
  String get adminBackupDone => 'The region\'s data has been backed up';

  @override
  String get adminBackupNone => 'No backups yet';

  @override
  String get adminDownload => 'Download';

  @override
  String get errGroupOnly =>
      'Only the group executive office can decide this nomination';

  @override
  String get errSamePosition => 'The employee already holds this position';

  @override
  String get errInUse =>
      'Someone still holds this position, so it cannot be deleted';

  @override
  String get errReadOnly =>
      'The statement writes data; turn on Allow writes if you really mean it';

  @override
  String get errSqlError =>
      'The statement failed, see the technical details below';

  @override
  String get errUnknownDatabase => 'Pick a database from the list';

  @override
  String get errEmptySql => 'Enter an SQL statement';

  @override
  String get errStorageUnavailable =>
      'Storage is not available, try again later';

  @override
  String get errIdentityUnavailable =>
      'The account service is not reachable, try again later';

  @override
  String get errOtherRegion => 'This account belongs to another region';

  @override
  String get errRoleNotAllowed => 'You may not grant or remove this role';

  @override
  String get errSelfChange => 'You cannot change your own account';

  @override
  String get errInvalidShift =>
      'Invalid shift: the end must be after the start';

  @override
  String get errInvalidRange => 'Invalid date range (at most one year)';

  @override
  String get adminRemove => 'Remove';

  @override
  String get evClockedIn => 'Clocked in';

  @override
  String get evClockedOut => 'Clocked out';

  @override
  String get evLeaveRequested => 'Leave requested';

  @override
  String get evLeaveApproved => 'Leave approved';

  @override
  String get evLeaveRejected => 'Leave rejected';

  @override
  String get evOvertimeRequested => 'Overtime requested';

  @override
  String get evOvertimeApproved => 'Overtime approved';

  @override
  String get evOvertimeRejected => 'Overtime rejected';

  @override
  String get evHolidayAdded => 'Holiday added';

  @override
  String get evHolidayRemoved => 'Holiday removed';

  @override
  String get evShiftChanged => 'Shift hours changed';

  @override
  String get evCandidateApplied => 'Candidate applied';

  @override
  String get evCandidateAnalyzed => 'Candidate CV analyzed by AI';

  @override
  String get evCandidateCvUploaded => 'Candidate uploaded a CV';

  @override
  String get evCandidateProfileUpdated => 'Candidate profile updated';

  @override
  String get evCandidateStatusChanged => 'Candidate stage changed';

  @override
  String get evCandidateHired => 'Candidate hired';

  @override
  String get evInterviewScheduled => 'Interview scheduled';

  @override
  String get evInterviewConfirmed => 'Interview confirmed';

  @override
  String get evInterviewProposed => 'Another interview time proposed';

  @override
  String get evPayslipIssued => 'Payslip issued';

  @override
  String get evPayrollRunCompleted => 'Payroll run completed';

  @override
  String get evPayrollRunFailed => 'Payroll run failed';

  @override
  String get evPayrollRunNeedsAttention => 'Payroll run needs attention';

  @override
  String get evPayrollExpenseRecorded => 'Payroll expense recorded';

  @override
  String get evPayoutLogged => 'Payout recorded';

  @override
  String get evSalaryAgreed => 'Starting salary agreed';

  @override
  String get evSalaryRaised => 'Salary raised';

  @override
  String get evSalaryChanged => 'Base salary changed by the executive office';

  @override
  String get evBonusGranted => 'Bonus granted';

  @override
  String get evPenaltyApplied => 'Penalty applied';

  @override
  String get evRaiseRequested => 'Raise requested';

  @override
  String get evRaiseForwarded => 'Raise forwarded by HR';

  @override
  String get evRaiseApproved => 'Raise approved';

  @override
  String get evRaiseRejected => 'Raise rejected';

  @override
  String get evRaiseReturned => 'Raise returned';

  @override
  String get evRaiseWithdrawn => 'Raise withdrawn';

  @override
  String get evPromotionNominated => 'Promotion nominated';

  @override
  String get evPromotionApproved => 'Promotion approved';

  @override
  String get evPromotionRejected => 'Promotion rejected';

  @override
  String get evEmployeePromoted => 'Promoted by the executive office';

  @override
  String get evPositionChanged => 'Position changed by the executive office';

  @override
  String get evPositionCreated => 'Position created';

  @override
  String get evPositionUpdated => 'Position updated';

  @override
  String get evPositionDeleted => 'Position deleted';

  @override
  String get evEmployeeHired => 'Employee hired';

  @override
  String get evEmployeeTransferred => 'Employee transferred';

  @override
  String get evEmployeeArchived => 'Employee archived';

  @override
  String get evEmployeeRestored => 'Employee restored';

  @override
  String get evDepartmentCreated => 'Department created';

  @override
  String get evDepartmentDissolved => 'Department dissolved';

  @override
  String get evDepartmentHeadChanged => 'Department head changed';

  @override
  String get evProfileChangeRequested => 'Profile change requested';

  @override
  String get evProfileChangeApproved => 'Profile change approved';

  @override
  String get evProfileChangeRejected => 'Profile change rejected';

  @override
  String get evResignationRequested => 'Resignation submitted';

  @override
  String get evResignationApproved => 'Resignation approved';

  @override
  String get evResignationRejected => 'Resignation rejected';

  @override
  String get evResignationWithdrawn => 'Resignation withdrawn';

  @override
  String get evResignationCompleted => 'Resignation completed';

  @override
  String get evReportSubmitted => 'Report submitted';

  @override
  String get evReportAcknowledged => 'Report acknowledged';

  @override
  String get evReportReturned => 'Report returned';

  @override
  String get evProjectCreated => 'Project created';

  @override
  String get evProjectProposed => 'Project proposed';

  @override
  String get evProjectProposalApproved => 'Project proposal approved';

  @override
  String get evProjectProposalRejected => 'Project proposal rejected';

  @override
  String get evProjectProposalCountered => 'Project proposal revised';

  @override
  String get evProjectAccepted => 'Project accepted';

  @override
  String get evProjectMembersRemoved => 'Members removed from project';

  @override
  String get evAcceptanceRevenueRecorded => 'Acceptance revenue recorded';

  @override
  String get evMaterialPurchased => 'Material purchased';

  @override
  String get evSupplierPaid => 'Supplier paid';

  @override
  String get evFinancePeriodClosed => 'Finance period closed';

  @override
  String get evAdminSqlRead => 'Admin ran a read-only SQL query';

  @override
  String get evAdminSqlWrite => 'Admin changed data with SQL';

  @override
  String get evBackupCreated => 'Backup created';

  @override
  String get evAccountChanged => 'Account or roles changed';

  @override
  String nAuditLog(String event, String by) {
    return 'New log entry: $event$by';
  }

  @override
  String nAuditLogBy(String by) {
    return ' (by $by)';
  }

  @override
  String nPositionChanged(String position) {
    return 'Your position is now $position';
  }

  @override
  String nSalaryChanged(String amount) {
    return 'Your new base salary: $amount';
  }

  @override
  String nBonusGranted(String amount, String reason) {
    return 'You received a bonus of $amount: $reason';
  }

  @override
  String nPenaltyApplied(String amount, String reason) {
    return 'A penalty of $amount was applied: $reason';
  }

  @override
  String get errProtectedDatabase =>
      'The admin log database cannot be queried here';

  @override
  String get errPastDate => 'Leave can only start from tomorrow';

  @override
  String get leaveAttach => 'Attach evidence (Word, PDF, image)';

  @override
  String approvalsOthers(int n) {
    return 'Employee requests awaiting you ($n)';
  }

  @override
  String approvalsMine(int n) {
    return 'Your requests awaiting your manager ($n)';
  }

  @override
  String get requestMineTag => 'Yours';

  @override
  String get projectOverdue => 'Overdue';

  @override
  String get reportMonth => 'Report month';

  @override
  String get reportMonthDone => 'already acknowledged';

  @override
  String get errFuturePeriod =>
      'Only the current or a past month can be reported';

  @override
  String get errPeriodAcknowledged =>
      'This month was already acknowledged and cannot be sent again';

  @override
  String get resignationAttachLetter => 'Attach resignation letter';

  @override
  String get resignationLetterHint =>
      'Required: photo, Word or PDF (max 10 MB)';

  @override
  String resignationOpenLetter(String name) {
    return 'Open letter: $name';
  }

  @override
  String get resignationAiTitle => 'AI reading of the letter';

  @override
  String get resignationAiRetention => 'Ideas to retain';

  @override
  String get resignationAiConcerns => 'Check';

  @override
  String get resignationAiNote =>
      'AI summary for reference only; the reviewer decides';

  @override
  String get errLetterRequired =>
      'Please attach the resignation letter (photo, Word or PDF)';

  @override
  String get rcCareer => 'Career';

  @override
  String get rcSalary => 'Pay';

  @override
  String get rcWorkload => 'Workload';

  @override
  String get rcManagement => 'Management';

  @override
  String get rcEnvironment => 'Work environment';

  @override
  String get rcPersonal => 'Personal';

  @override
  String get rcHealth => 'Health';

  @override
  String get rcRelocation => 'Relocation';

  @override
  String get rcOther => 'Other';

  @override
  String get auditExportNow => 'Export';

  @override
  String get auditRecord => 'Record';

  @override
  String get auditActor => 'Done by';

  @override
  String get auditData => 'Event data';

  @override
  String get auditWhyFlagged => 'Why it was flagged';

  @override
  String get anomalyAfterHoursWhy =>
      'Done between 22:00 and 06:00 local time, outside normal hours';

  @override
  String get anomalyFailureWhy =>
      'The event failed, was rejected, compensated or needs manual handling';

  @override
  String get auditAskAi => 'Ask AI about this anomaly';

  @override
  String get auditAiTitle => 'AI analysis';

  @override
  String get auditChecks => 'What to check';

  @override
  String get auditLikelyBenign => 'Possibly harmless if';

  @override
  String get riskHigh => 'High risk';

  @override
  String get riskMedium => 'Medium risk';

  @override
  String get riskLow => 'Low risk';

  @override
  String get interviewTimePassed =>
      'This time has passed, please propose another one';
}
