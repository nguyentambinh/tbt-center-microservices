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
  String get stepPay => 'Pay through the bank';

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
}
