// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'TBT Center';

  @override
  String get tagline => 'MULTINATIONALER KONZERN';

  @override
  String gemPalette(String gem) {
    return 'Farbschema $gem';
  }

  @override
  String get gemGold => 'Gold';

  @override
  String get gemPlatinum => 'Platin';

  @override
  String get gemEmerald => 'Smaragd';

  @override
  String get gemRuby => 'Rubin';

  @override
  String get gemSapphire => 'Saphir';

  @override
  String get gemDiamond => 'Diamant';

  @override
  String get samplePayslipTitle => 'Gehaltsabrechnung Oktober';

  @override
  String get viewDetails => 'Details ansehen';

  @override
  String get downloadPdf => 'PDF herunterladen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get language => 'Sprache';

  @override
  String get languageAuto => 'Automatisch (nach Standort)';

  @override
  String get dataRegion => 'Datenregion';

  @override
  String get detecting => 'Standort wird ermittelt…';

  @override
  String get locationUnknown =>
      'Standort unbekannt, Standardregion wird verwendet';

  @override
  String detectedCountry(String country) {
    return 'Land: $country';
  }

  @override
  String get refreshLocation => 'Erneut ermitteln';

  @override
  String get simulateLocation => 'Standort simulieren';

  @override
  String get simulateHint => 'Nur in Debug-Builds, um andere Länder zu testen';

  @override
  String get simulateIp => 'IP-Adresse';

  @override
  String get simulateCountry => 'Oder Ländercode (z. B. DE)';

  @override
  String get apply => 'Übernehmen';

  @override
  String get clearSimulation => 'Simulation beenden';

  @override
  String get regionVn => 'Vietnam';

  @override
  String get regionDe => 'Deutschland';

  @override
  String get regionUs => 'Vereinigte Staaten';

  @override
  String get regionBr => 'Brasilien';

  @override
  String get regionZa => 'Südafrika';

  @override
  String get regionAu => 'Australien';

  @override
  String get bannerOffline =>
      'Keine Internetverbindung · gespeicherte Daten werden angezeigt';

  @override
  String get bannerServerDown =>
      'Server nicht erreichbar · gespeicherte Daten werden angezeigt';

  @override
  String get bannerUnstable => 'Instabile Verbindung';

  @override
  String get bannerRecovered => 'Wieder verbunden';

  @override
  String get reconnect => 'Neu verbinden';

  @override
  String get errorNetwork =>
      'Keine Internetverbindung. Bitte WLAN oder mobile Daten prüfen.';

  @override
  String get errorTimeout =>
      'Der Server antwortet zu langsam. Bitte erneut versuchen.';

  @override
  String get errorServer =>
      'Der Server hat ein Problem. Bitte später erneut versuchen.';

  @override
  String get errorUnauthorized =>
      'Ihre Sitzung ist abgelaufen. Bitte erneut anmelden.';

  @override
  String get errorForbidden => 'Dafür fehlt Ihnen die Berechtigung.';

  @override
  String get errorNotFound => 'Die angeforderten Daten wurden nicht gefunden.';

  @override
  String get errorValidation => 'Einige Angaben sind ungültig. Bitte prüfen.';

  @override
  String get errorOfflineWrite =>
      'Zum Speichern ist eine Verbindung nötig. Ihre Eingaben bleiben erhalten.';

  @override
  String get errorUnknown =>
      'Ein unerwarteter Fehler ist aufgetreten. Bitte erneut versuchen.';

  @override
  String get signIn => 'Anmelden';

  @override
  String get applyAsCandidate => 'Bewerben · Konto erstellen';

  @override
  String get signOut => 'Abmelden';

  @override
  String welcome(String name) {
    return 'Hallo, $name';
  }

  @override
  String dataStoredIn(String region) {
    return 'Ihre Daten werden in der Region $region gespeichert';
  }

  @override
  String get signInFailed =>
      'Die Anmeldeseite konnte nicht geöffnet werden. Bitte Verbindung zum Server prüfen.';

  @override
  String get roleExecutive => 'Geschäftsleitung';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get roleHr => 'Personalwesen';

  @override
  String get roleFinance => 'Finanzen';

  @override
  String get roleEmployee => 'Mitarbeiter';

  @override
  String get roleCandidate => 'Bewerber';

  @override
  String get regionCheckTitle => 'Regionale Verbindung';

  @override
  String get regionCheckHint =>
      'Ruft Ihren regionalen Server über Kong mit Ihrem Anmeldetoken auf.';

  @override
  String get regionCheckButton => 'Prüfen';

  @override
  String regionCheckOk(String service) {
    return 'Der Server $service antwortet';
  }

  @override
  String get savedDataNote => 'Gespeicherte Daten werden angezeigt';

  @override
  String get themePreview => 'Edelstein-Farbschemata ansehen';

  @override
  String get employees => 'Personalakten';

  @override
  String get employeesHint => 'Mitarbeiterliste und Profile Ihrer Region';

  @override
  String get open => 'Öffnen';

  @override
  String get searchEmployees => 'Nach Name, ID oder E-Mail suchen';

  @override
  String employeeCount(int count) {
    return '$count Mitarbeiter';
  }

  @override
  String get noEmployees => 'Keine Mitarbeiter gefunden';

  @override
  String get loadMore => 'Mehr laden';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get sectionWork => 'Arbeit';

  @override
  String get sectionContact => 'Kontakt';

  @override
  String get sectionRelatives => 'Angehörige';

  @override
  String get sectionHealth => 'Gesundheit';

  @override
  String get sectionInsurance => 'Versicherung';

  @override
  String get fieldId => 'Personalnummer';

  @override
  String get fieldCompany => 'Gesellschaft';

  @override
  String get fieldDepartment => 'Abteilung';

  @override
  String get fieldPosition => 'Position';

  @override
  String get fieldBirthYear => 'Geburtsjahr';

  @override
  String get fieldGender => 'Geschlecht';

  @override
  String get genderMale => 'Männlich';

  @override
  String get genderFemale => 'Weiblich';

  @override
  String get fieldHiredOn => 'Eintrittsdatum';

  @override
  String get fieldLaborContract => 'Arbeitsvertrag';

  @override
  String get fieldEmail => 'E-Mail';

  @override
  String get fieldPhone => 'Telefon';

  @override
  String get fieldAddress => 'Adresse';

  @override
  String get fieldHometown => 'Herkunft';

  @override
  String get fieldHeight => 'Größe';

  @override
  String get fieldWeight => 'Gewicht';

  @override
  String get fieldVision => 'Sehkraft';

  @override
  String get fieldMedicalHistory => 'Vorerkrankungen';

  @override
  String get fieldUpdatedOn => 'Aktualisiert';

  @override
  String get fieldInsuranceType => 'Versicherungsart';

  @override
  String get fieldInsuranceNumber => 'Versicherungsnummer';

  @override
  String get fieldExpiresOn => 'Gültig bis';

  @override
  String get noData => 'Noch keine Daten';

  @override
  String get attendance => 'Zeiterfassung & Urlaub';

  @override
  String get attendanceHint =>
      'Ihre Arbeitszeiten, Urlaubsanträge und Genehmigungen';

  @override
  String get tabTimesheet => 'Zeiten';

  @override
  String get tabLeave => 'Urlaub';

  @override
  String get tabApprovals => 'Genehmigungen';

  @override
  String totalHours(String hours, int days) {
    return '$hours Stunden an $days Tagen';
  }

  @override
  String checkInOut(String checkIn, String checkOut) {
    return 'Kommen $checkIn · Gehen $checkOut';
  }

  @override
  String overtimeHours(String hours) {
    return 'Überstunden $hours Std.';
  }

  @override
  String get newLeave => 'Urlaub beantragen';

  @override
  String get leaveType => 'Art';

  @override
  String get leaveAnnual => 'Urlaub';

  @override
  String get leaveSick => 'Krankheit';

  @override
  String get leaveUnpaid => 'Unbezahlter Urlaub';

  @override
  String get leavePersonal => 'Private Angelegenheiten';

  @override
  String get leaveDates => 'Zeitraum';

  @override
  String get pickDates => 'Datum wählen';

  @override
  String get reason => 'Grund';

  @override
  String get submitLeave => 'Absenden';

  @override
  String get leaveSubmitted => 'Urlaubsantrag gesendet';

  @override
  String get statusPending => 'Ausstehend';

  @override
  String get statusApproved => 'Genehmigt';

  @override
  String get statusRejected => 'Abgelehnt';

  @override
  String get approve => 'Genehmigen';

  @override
  String get reject => 'Ablehnen';

  @override
  String leaveDays(int days) {
    return '$days Tage';
  }

  @override
  String get noLeaves => 'Noch keine Urlaubsanträge';

  @override
  String get noPending => 'Keine offenen Anträge';

  @override
  String get noTimesheets => 'Noch keine Zeiterfassung';

  @override
  String get leaveDecided => 'Antrag aktualisiert';

  @override
  String get errOverlap =>
      'Dieser Zeitraum überschneidet sich mit einem anderen Antrag';

  @override
  String get errTooLong => 'Ein Antrag darf höchstens 30 Tage umfassen';

  @override
  String get errInvalidDates => 'Das Enddatum muss nach dem Startdatum liegen';

  @override
  String get errAlreadyDecided => 'Dieser Antrag wurde bereits bearbeitet';

  @override
  String get errSelfApproval =>
      'Eigene Anträge können nicht selbst genehmigt werden';

  @override
  String get errRegionMismatch => 'Diese Daten gehören zu einer anderen Region';

  @override
  String get errNoEmployee => 'Ihr Konto ist keinem Mitarbeiter zugeordnet';

  @override
  String get myApplication => 'Meine Bewerbung';

  @override
  String get myApplicationHint => 'Bewerben und Fortschritt verfolgen';

  @override
  String get candidates => 'Bewerber';

  @override
  String get candidatesHint => 'Bewerbungen und Auswahlschritte';

  @override
  String get applyNow => 'Bewerben';

  @override
  String get editProfile => 'Profil bearbeiten';

  @override
  String get saveProfile => 'Speichern';

  @override
  String get fullName => 'Vollständiger Name';

  @override
  String get appliedPosition => 'Gewünschte Position';

  @override
  String get consentAi =>
      'Ich stimme zu, dass eine KI meinen Lebenslauf liest und zusammenfasst';

  @override
  String get notAppliedYet => 'Sie haben sich noch nicht beworben';

  @override
  String get progress => 'Fortschritt';

  @override
  String get profileSaved => 'Profil gespeichert';

  @override
  String get profileLockedHint =>
      'Die Bewerbung ist in der Interviewphase und kann nicht mehr geändert werden';

  @override
  String get moveTo => 'Verschieben nach';

  @override
  String get statusChanged => 'Status aktualisiert';

  @override
  String get noCandidates => 'Noch keine Bewerber';

  @override
  String get allStatuses => 'Alle';

  @override
  String get note => 'Notiz';

  @override
  String get stageSubmitted => 'Eingereicht';

  @override
  String get stageAnalyzed => 'KI-Zusammenfassung';

  @override
  String get stageScreening => 'Vorauswahl';

  @override
  String get stageInterview => 'Vorstellungsgespräch';

  @override
  String get stageOffered => 'Angebot';

  @override
  String get stageRejected => 'Absage';

  @override
  String get errProfileLocked =>
      'Die Bewerbung kann in dieser Phase nicht mehr geändert werden';

  @override
  String get cvSection => 'Lebenslauf';

  @override
  String get cvNone => 'Noch kein Lebenslauf';

  @override
  String get cvAttached => 'Lebenslauf hochgeladen';

  @override
  String get uploadCv => 'Lebenslauf hochladen (PDF)';

  @override
  String get replaceCv => 'Lebenslauf ersetzen';

  @override
  String get cvUploaded => 'Lebenslauf hochgeladen';

  @override
  String get cvWaitingAi =>
      'Die KI liest Ihren Lebenslauf, das dauert einige Minuten';

  @override
  String get openCv => 'Lebenslauf öffnen';

  @override
  String get aiSummary => 'KI-Zusammenfassung';

  @override
  String get aiDisclaimer =>
      'Von einer KI erstellt. Bitte vor einer Entscheidung mit dem Original vergleichen.';

  @override
  String yearsExperience(String years) {
    return '$years Jahre Erfahrung';
  }

  @override
  String get skills => 'Fähigkeiten';

  @override
  String get suitablePositions => 'Passende Positionen';

  @override
  String get strengths => 'Stärken';

  @override
  String get interviewQuestions => 'Im Gespräch klären';

  @override
  String get errCvNotPdf => 'Der Lebenslauf muss eine PDF-Datei sein';

  @override
  String get errCvTooLarge => 'Der Lebenslauf darf höchstens 10 MB groß sein';

  @override
  String get payslips => 'Gehaltsabrechnungen';

  @override
  String get payslipsHint => 'Gehalt je Monat, Prämien und Abzüge';

  @override
  String get baseSalary => 'Grundgehalt';

  @override
  String get grossPay => 'Brutto';

  @override
  String get netPay => 'Netto';

  @override
  String netUsd(String amount) {
    return '≈ $amount zum Kurs am Zahltag';
  }

  @override
  String paidOn(String date) {
    return 'Gezahlt am $date';
  }

  @override
  String get bonusesPenalties => 'Prämien / Abzüge';

  @override
  String get bonus => 'Prämie';

  @override
  String get penalty => 'Abzug';

  @override
  String get noPayslips => 'Noch keine Abrechnungen';

  @override
  String get payrollRuns => 'Lohnabrechnung';

  @override
  String get payrollRunsHint =>
      'Gehälter der Region je Monat berechnen und auszahlen';

  @override
  String startPayrollRun(String period) {
    return 'Abrechnung $period starten';
  }

  @override
  String get runRunning => 'Läuft';

  @override
  String get runCompleted => 'Abgeschlossen';

  @override
  String get runFailed => 'Fehlgeschlagen, rückgängig gemacht';

  @override
  String get retryRun => 'Erneut ausführen';

  @override
  String get sagaSteps => 'Schritte';

  @override
  String get stepCollectHours => 'Arbeitszeiten abrufen';

  @override
  String get stepFetchRate => 'Wechselkurs abrufen';

  @override
  String get stepCalculate => 'Abrechnungen berechnen';

  @override
  String get stepPay => 'Über die Bank auszahlen';

  @override
  String get stepComplete => 'Abschließen';

  @override
  String get stepCompensate => 'Unbezahlten Teil rückgängig machen';

  @override
  String get stepRetry => 'Wiederholung';

  @override
  String get stepResume => 'Nach Neustart fortgesetzt';

  @override
  String paidSummary(int count, String amount) {
    return '$count Abrechnungen bezahlt · $amount';
  }

  @override
  String get noRuns => 'Noch keine Abrechnung';

  @override
  String get errRunExists => 'Dieser Monat wurde bereits abgerechnet';

  @override
  String get errRunFailed =>
      'Dieser Monat ist fehlgeschlagen, bitte erneut ausführen';

  @override
  String get groupReport => 'Konzernbericht';

  @override
  String get groupReportHint => 'Konsolidierte Zahlen aller Regionen in USD';

  @override
  String get payrollCostByRegion => 'Personalkosten nach Region';

  @override
  String get leavesByRegion => 'Urlaubsanträge nach Region';

  @override
  String get candidatesByRegion => 'Bewerber nach Region';

  @override
  String get groupTotal => 'Gesamter Konzern';

  @override
  String dataAsOf(String id) {
    return 'Daten bis Ereignis #$id';
  }

  @override
  String get noReportData => 'Noch keine Daten';

  @override
  String employeesCount(int count) {
    return '$count Personen';
  }

  @override
  String get projects => 'Projekte und Verträge';

  @override
  String get projectsHint => 'Projekte, Kunden und Mitarbeitende';

  @override
  String get searchProjects => 'Projekt, Vertrag oder Kunde suchen';

  @override
  String get noProjects => 'Keine Projekte';

  @override
  String get projectMoney => 'Projektwert';

  @override
  String get deposit => 'Anzahlung';

  @override
  String get expectedAcceptance => 'Erwartete Abnahme';

  @override
  String get customer => 'Kunde';

  @override
  String get customerContactHidden =>
      'Kontaktdaten des Kunden sieht nur die Finanzabteilung';

  @override
  String get contracts => 'Verträge';

  @override
  String get projectMembers => 'Mitarbeitende';

  @override
  String get myProjects => 'Meine Projekte';

  @override
  String get myProjectsHint => 'Ihre Projekte und Arbeitsstunden';

  @override
  String get noMyProjects => 'Sie sind noch in keinem Projekt';

  @override
  String get finance => 'Finanzen';

  @override
  String get financeHint =>
      'Monatliche Einnahmen und Kosten, Lieferanten, Abschluss';

  @override
  String get incomeExpense => 'Einnahmen & Kosten';

  @override
  String get suppliers => 'Lieferanten';

  @override
  String get revenue => 'Umsatz';

  @override
  String get cost => 'Kosten';

  @override
  String get profit => 'Gewinn';

  @override
  String get periodClosed => 'Abgeschlossen';

  @override
  String get closePeriod => 'Monat abschließen';

  @override
  String get noFinanceData => 'Keine Zahlen für dieses Jahr';

  @override
  String get purchased => 'Eingekauft';

  @override
  String get paid => 'Bezahlt';

  @override
  String get balance => 'Offen';

  @override
  String get recordPurchase => 'Einkauf erfassen';

  @override
  String get recordPayment => 'Zahlung erfassen';

  @override
  String get materialName => 'Material';

  @override
  String get amount => 'Betrag';

  @override
  String get purchaseHistory => 'Einkäufe';

  @override
  String get paymentHistory => 'Zahlungen';

  @override
  String get financeByRegion => 'Abgeschlossene Umsätze und Kosten';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get errPeriodClosed => 'Dieser Monat ist abgeschlossen';

  @override
  String get errPeriodNotEnded => 'Dieser Monat ist noch nicht vorbei';

  @override
  String get errOverpaid => 'Zahlung ist höher als der offene Betrag';

  @override
  String get errInvalidAmount => 'Ungültiger Betrag';

  @override
  String closePeriodConfirm(String period) {
    return '$period abschließen? Danach sind keine Buchungen in diesem Monat mehr möglich.';
  }

  @override
  String hoursValue(String hours) {
    return '$hours Std.';
  }

  @override
  String get clockToday => 'Zeiterfassung heute';

  @override
  String get noShiftToday =>
      'Sie haben heute keine Schicht, Stempeln ist nicht möglich';

  @override
  String get clockIn => 'Einstempeln';

  @override
  String get clockOut => 'Ausstempeln';

  @override
  String get shiftDone => 'Schicht beendet';

  @override
  String get holidayShift => 'Feiertag';

  @override
  String get sundayShift => 'Sonntag';

  @override
  String get tabOvertime => 'Überstunden';

  @override
  String get newOvertime => 'Überstunden beantragen';

  @override
  String get noOvertime => 'Keine Überstundenanträge';

  @override
  String get submitOvertime => 'Absenden';

  @override
  String get errNoShift => 'Sie haben heute keine Schicht';

  @override
  String get errAlreadyClockedOut => 'Sie haben heute bereits ausgestempelt';

  @override
  String get errTooSoon =>
      'Gerade eingestempelt, bitte mindestens 5 Minuten warten';

  @override
  String get errInvalidHours =>
      'Überstunden müssen zwischen 0,5 und 12 Stunden liegen';

  @override
  String clockedIn(String time) {
    return 'Eingestempelt um $time';
  }

  @override
  String clockedOut(String time, String hours) {
    return 'Ausgestempelt um $time, $hours Std. gearbeitet';
  }

  @override
  String totalHoursToday(String hours) {
    return 'Heute $hours Std. gearbeitet';
  }

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get noNotifications => 'Noch keine Benachrichtigungen';

  @override
  String get markAllRead => 'Alle gelesen';

  @override
  String get nGeneric => 'Sie haben eine neue Benachrichtigung';

  @override
  String nLeaveRequested(String employee, String days, String date) {
    return '$employee beantragt $days Tage Urlaub ab $date';
  }

  @override
  String nLeaveApproved(String date) {
    return 'Ihr Urlaub ab $date wurde genehmigt';
  }

  @override
  String nLeaveRejected(String date) {
    return 'Ihr Urlaub ab $date wurde abgelehnt';
  }

  @override
  String nOvertimeRequested(String employee, String hours, String date) {
    return '$employee beantragt $hours Überstunden am $date';
  }

  @override
  String nOvertimeApproved(String date) {
    return 'Ihre Überstunden am $date wurden genehmigt';
  }

  @override
  String nOvertimeRejected(String date) {
    return 'Ihre Überstunden am $date wurden abgelehnt';
  }

  @override
  String nCandidateApplied(String position) {
    return 'Neue Bewerbung: $position';
  }

  @override
  String nCandidateStatus(String stage) {
    return 'Ihre Bewerbung ist jetzt: $stage';
  }

  @override
  String nPayrollPaid(String period) {
    return 'Gehalt für $period wurde ausgezahlt';
  }

  @override
  String nPayrollFailed(String period) {
    return 'Lohnlauf $period fehlgeschlagen, bitte erneut starten';
  }

  @override
  String nFinanceClosed(String period) {
    return 'Finanzen für $period wurden abgeschlossen';
  }

  @override
  String get importCandidates => 'Bewerber aus Datei importieren';

  @override
  String get confirmAll => 'Alle bestätigen';

  @override
  String get importRowNew => 'Neu';

  @override
  String get importRowUpdate => 'Aktualisieren';

  @override
  String get importRowAccepted => 'Gespeichert';

  @override
  String get importErrMissingName => 'Name fehlt';

  @override
  String get importErrMissingContact => 'E-Mail und Telefon fehlen';

  @override
  String get importErrInvalidEmail => 'Ungültige E-Mail';

  @override
  String get errUnsupportedFile => 'Nur .csv- oder .xlsx-Dateien';

  @override
  String get errMissingNameColumn => 'Die erste Zeile hat keine Namensspalte';

  @override
  String get errEmptyFile => 'Die Datei enthält keine Bewerber';

  @override
  String get errFileTooLarge => 'Datei größer als 2 MB';

  @override
  String confirmSelected(int count) {
    return 'Auswahl bestätigen ($count)';
  }

  @override
  String importAccepted(int count) {
    return '$count Profile gespeichert';
  }

  @override
  String importSummary(int total, int pending) {
    return '$total Zeilen, $pending warten auf Bestätigung';
  }

  @override
  String importRowNumber(int n) {
    return 'Zeile $n';
  }

  @override
  String get roleAuditor => 'Prüfer';

  @override
  String get gemAmethyst => 'Amethyst';

  @override
  String get auditLog => 'Prüfprotokoll';

  @override
  String get auditLogHint =>
      'Ereignisse aller Regionen, Hash-Kette prüfen, Export';

  @override
  String get auditEvents => 'Ereignisse';

  @override
  String get accessLog => 'Zugriffsprotokoll';

  @override
  String get verifyChain => 'Hash-Kette prüfen';

  @override
  String get exportAudit => 'Für Prüfung exportieren';

  @override
  String get auditSearch => 'Suche';

  @override
  String get chainIntact => 'Das Protokoll ist unverändert';

  @override
  String get exportChecksumHint =>
      'SHA-256 der exportierten Datei. Weicht der nachgerechnete Wert ab, wurde die Datei verändert.';

  @override
  String get copyChecksum => 'Kopieren';

  @override
  String get close => 'Schließen';

  @override
  String get allRegions => 'Alle Regionen';

  @override
  String get errAccessExpired => 'Ihr Prüfzugang ist abgelaufen';

  @override
  String chainBroken(String id) {
    return 'Hash-Kette ab Zeile #$id ungültig';
  }

  @override
  String chainChecked(int count) {
    return '$count Zeilen geprüft';
  }

  @override
  String exportDone(int count) {
    return '$count Zeilen exportiert';
  }

  @override
  String rowsCount(int count) {
    return '$count Zeilen';
  }

  @override
  String supplierPurchases(int count) {
    return '$count Einkäufe';
  }

  @override
  String supplierPaidPercent(String percent) {
    return '$percent % bezahlt';
  }

  @override
  String get acceptProject => 'Abnahme';

  @override
  String get projectInProgress => 'In Arbeit';

  @override
  String get errAlreadyAccepted => 'Dieses Projekt ist bereits abgenommen';

  @override
  String get errFinanceUnavailable =>
      'Die Finanzabteilung konnte den Umsatz nicht buchen, das Projekt wurde nicht geändert.';

  @override
  String acceptProjectConfirm(String amount) {
    return 'Projekt abnehmen und $amount als Umsatz buchen?';
  }

  @override
  String projectAcceptedOn(String date) {
    return 'Abgenommen am $date';
  }

  @override
  String nProjectAccepted(String project) {
    return 'Projekt $project wurde abgenommen, Umsatz gebucht';
  }

  @override
  String get workConditions => 'Arbeitsbedingungen';

  @override
  String workHoursSummary(String hours, String overtime) {
    return '$hours Std. · Überstunden $overtime Std.';
  }

  @override
  String get noticeQueued => 'in Warteschlange';

  @override
  String get noticeSent => 'gesendet';

  @override
  String customerNotice(String channel, String status) {
    return 'Kundenbestätigung per $channel: $status';
  }

  @override
  String get attachCv => 'Lebenslauf anhängen (PDF, max. 10 MB)';

  @override
  String cvSelected(String name) {
    return 'Lebenslauf: $name';
  }

  @override
  String get stageHired => 'Eingestellt';

  @override
  String get hireCandidate => 'Einstellen';

  @override
  String get hiredKeepPassword =>
      'Passwort: unverändert, das bisherige Passwort.';

  @override
  String get hiredRelogin =>
      'Bitte ab- und wieder anmelden, um die Rolle Mitarbeiter zu erhalten.';

  @override
  String hireConfirm(String name, String email) {
    return '$name einstellen? $email wird der Login des neuen Mitarbeiters.';
  }

  @override
  String hiredTitle(String id) {
    return 'Mitarbeiter $id angelegt';
  }

  @override
  String hiredLogin(String login) {
    return 'Login: $login';
  }

  @override
  String hiredTempPassword(String password) {
    return 'Temporäres Passwort: $password (nur einmal angezeigt, bei der ersten Anmeldung ändern)';
  }

  @override
  String get home => 'Start';

  @override
  String get sectionMyWork => 'Meine Arbeit';

  @override
  String get sectionManage => 'Verwaltung';

  @override
  String get sectionFinance => 'Finanzen';

  @override
  String get sectionAudit => 'Prüfung';

  @override
  String nPayslipIssued(String period) {
    return 'Ihre Gehaltsabrechnung für $period ist da';
  }

  @override
  String nPayrollNeedsAttention(String period) {
    return 'Lohnabrechnung $period muss manuell bearbeitet werden';
  }

  @override
  String get errPeriodLocked =>
      'Die Lohnabrechnung für diesen Zeitraum läuft. Bitte später erneut versuchen';

  @override
  String get runNeedsAttention => 'Manuell prüfen';

  @override
  String get stepLockPeriod => 'Zeitraum in der Zeiterfassung sperren';

  @override
  String get stepReserveBudget => 'Lohnbudget reservieren';

  @override
  String get stepReleaseBudget => 'Budget freigeben (Kompensation)';

  @override
  String get stepRecordExpense => 'Lohnkosten in der Buchhaltung erfassen';

  @override
  String get stepIssuePayslips => 'Gehaltsabrechnungen versenden';

  @override
  String get stepUnlockPeriod => 'Zeitraum entsperren';

  @override
  String get stepNeedsAttention => 'Wartet auf manuelle Bearbeitung';

  @override
  String get knowledge => 'Wissensdatenbank';

  @override
  String get knowledgeHint => 'Regeln zu Lohn, Urlaub, Überstunden und Abläufe';

  @override
  String get knowledgeSearchHint => 'Suchen, z. B. Überstunden, Lohn';

  @override
  String get knowledgeEmpty => 'Keine passenden Artikel';

  @override
  String get sectionKnowledge => 'Wissen';

  @override
  String get knowledgeTabAsk => 'KI fragen';

  @override
  String get knowledgeTabSearch => 'Artikel';

  @override
  String get knowledgeTabGraph => 'Graph';

  @override
  String get askHint => 'Fragen zu Lohn, Urlaub, Zeiterfassung…';

  @override
  String get askIntro =>
      'Der Assistent antwortet aus der Wissensdatenbank und dem Wissensgraphen des Unternehmens, mit überprüfbaren Quellen.';

  @override
  String get askExample1 => 'Wie werden Überstunden bezahlt?';

  @override
  String get askExample2 => 'Wer genehmigt meinen Urlaubsantrag?';

  @override
  String get askExample3 =>
      'Warum kann ich während des Lohnabschlusses nichts genehmigen?';

  @override
  String get askExample4 => 'Wie werden meine persönlichen Daten geschützt?';

  @override
  String get askThinking => 'Durchsuche die Wissensdatenbank…';

  @override
  String get askSources => 'Quellen';

  @override
  String get askGraphFacts => 'Aus dem Wissensgraphen';

  @override
  String askAnsweredBy(String model) {
    return 'Antwort von $model';
  }

  @override
  String get askNoAi => 'Ohne KI, direkt aus der Wissensdatenbank';

  @override
  String get askCached => 'zwischengespeichert';

  @override
  String get askHelpful => 'Hilfreich';

  @override
  String get askNotHelpful => 'Nicht richtig';

  @override
  String get askThanks => 'Danke für Ihr Feedback';

  @override
  String get askFailed => 'Frage konnte nicht gesendet werden';

  @override
  String get askNewChat => 'Neues Gespräch';

  @override
  String get askSend => 'Senden';

  @override
  String get askViaKeyword => 'Stichwort';

  @override
  String get askViaSemantic => 'Bedeutung';

  @override
  String get askViaGraph => 'Graph';

  @override
  String get graphSearchHint => 'Begriff suchen, z. B. Überstunden';

  @override
  String get graphRelated => 'Verbindungen';

  @override
  String get graphReadArticle => 'Artikel lesen';

  @override
  String get graphAskAbout => 'KI dazu fragen';

  @override
  String graphAskTemplate(String topic) {
    return 'Erkläre mir $topic';
  }

  @override
  String get graphTypeConcept => 'Begriff';

  @override
  String get graphTypeProcess => 'Prozess';

  @override
  String get graphTypeStep => 'Schritt';

  @override
  String get graphTypeRule => 'Regel';

  @override
  String get graphTypeRole => 'Rolle';

  @override
  String get graphTypeService => 'Dienst';

  @override
  String get graphTypeRegion => 'Land';

  @override
  String get graphTypeDocument => 'Artikel';

  @override
  String get knowledgeMore => 'Mehr';

  @override
  String get ontologyTitle => 'Ontologie';

  @override
  String get ontologyClasses => 'Klassenbaum';

  @override
  String get ontologyRelations => 'Relationen';

  @override
  String get ontologyRules => 'Schlussregeln';

  @override
  String ontologyTotals(int nodes, int asserted, int extracted, int inferred) {
    return '$nodes Knoten · $asserted feste Kanten · $extracted von KI · $inferred gefolgert';
  }

  @override
  String ontologyReasoning(int count, int ms) {
    return 'Letzte Folgerung: $count neue Kanten in $ms ms';
  }

  @override
  String get ontologyRerun => 'Erneut folgern';

  @override
  String get ontologyTransitive => 'transitiv';

  @override
  String get ontologySymmetric => 'symmetrisch';

  @override
  String ontologyInverse(String name) {
    return 'invers zu $name';
  }

  @override
  String ontologySubProperty(String name) {
    return 'impliziert $name';
  }

  @override
  String get ontologyDerived => 'nur gefolgert';

  @override
  String ontologyEdgeCount(int count) {
    return '$count Kanten';
  }

  @override
  String get ontologyExport =>
      'RDF/OWL-Export (Turtle) unter /knowledge/ontology?format=turtle, lesbar mit Protégé.';

  @override
  String get sparqlTitle => 'SPARQL-Abfrage';

  @override
  String get sparqlHint => 'SELECT-Abfrage schreiben oder Beispiel wählen';

  @override
  String get sparqlRun => 'Ausführen';

  @override
  String get sparqlIncludeInferred => 'Gefolgerte Kanten einbeziehen';

  @override
  String get sparqlNoRows => 'Keine Ergebnisse';

  @override
  String sparqlRows(int count, int ms) {
    return '$count Zeilen · $ms ms';
  }

  @override
  String sparqlError(String message) {
    return 'Abfragefehler: $message';
  }

  @override
  String get sparqlSampleInvolves => 'Dienste für den Lohnabschluss';

  @override
  String get sparqlSampleViewers => 'Wer sieht den Nettolohn';

  @override
  String get sparqlSampleBefore => 'Schritte vor der Bankzahlung';

  @override
  String get sparqlSampleRabbit => 'Dienste mit RabbitMQ';

  @override
  String get sparqlSampleCount => 'Dienste pro Ort';

  @override
  String get proposalsTitle => 'KI-Vorschläge';

  @override
  String get proposalsRun => 'KI neue Artikel lesen lassen';

  @override
  String get proposalsRunning => 'KI liest Artikel…';

  @override
  String proposalsQueued(int count) {
    return 'KI liest $count Artikel';
  }

  @override
  String get proposalsNoAi => 'Keine KI für die Extraktion konfiguriert';

  @override
  String get proposalsPending => 'Offen';

  @override
  String get proposalsInvalid => 'Ungültig';

  @override
  String get proposalsApproved => 'Genehmigt';

  @override
  String get proposalsRejected => 'Abgelehnt';

  @override
  String get proposalsEmpty => 'Keine Vorschläge';

  @override
  String get proposalNewNode => 'Neuer Knoten';

  @override
  String proposalFrom(String article) {
    return 'Zitat aus $article';
  }

  @override
  String get proposalApprove => 'Genehmigen';

  @override
  String get proposalReject => 'Ablehnen';

  @override
  String get proposalApproved => 'Zum Graphen hinzugefügt, wird neu gefolgert';

  @override
  String get proposalRejected => 'Vorschlag abgelehnt';

  @override
  String proposalConfidence(int percent) {
    return 'Sicherheit $percent%';
  }

  @override
  String get proposalReasonEvidence => 'Zitat steht nicht im Artikel';

  @override
  String get proposalReasonConfidence => 'KI ist unsicher';

  @override
  String proposalReasonOntology(String code) {
    return 'Verletzt Domäne oder Bereich ($code)';
  }

  @override
  String get proposalReasonUnused =>
      'Knoten wird von keiner gültigen Kante genutzt';

  @override
  String proposalReasonOther(String code) {
    return 'Grund: $code';
  }

  @override
  String get graphInferred => 'Gefolgert';

  @override
  String graphInferredBy(String rule) {
    return 'Gefolgert mit Regel: $rule';
  }

  @override
  String get graphBecause => 'Weil';

  @override
  String get graphEvidence => 'Von der KI aus einem Artikel, von HR genehmigt:';

  @override
  String get graphGoTo => 'Diesen Knoten öffnen';

  @override
  String get graphPathTo => 'Verbinden mit…';

  @override
  String graphPathTitle(String from, String to) {
    return 'Von $from zu $to';
  }

  @override
  String get graphPathNone => 'Keine Verbindung in 6 Schritten';

  @override
  String get graphPathPick => 'Ziel-Begriff wählen';

  @override
  String get graphTypeTechnology => 'Technologie';

  @override
  String get graphTypePattern => 'Architekturmuster';

  @override
  String get todoTitle => 'Zu erledigen';

  @override
  String todoLeaves(int count) {
    return '$count Urlaubsanträge warten auf Freigabe';
  }

  @override
  String todoOvertime(int count) {
    return '$count Überstundenanträge warten auf Freigabe';
  }

  @override
  String todoCandidates(int count) {
    return '$count neue Bewerbungen';
  }

  @override
  String get todoNone => 'Nichts wartet auf Sie';

  @override
  String get signOutConfirm => 'Von TBT Center abmelden?';

  @override
  String get stepErrorTimeout =>
      'Die Bank hat nicht rechtzeitig geantwortet; das System gleicht per Referenz ab, bevor erneut gezahlt wird';

  @override
  String get stepErrorGeneric =>
      'Dieser Schritt konnte nicht ausgeführt werden; tippen Sie auf Wiederholen oder wenden Sie sich an die IT';

  @override
  String get errSparqlSyntax =>
      'Die Abfrage enthält einen Syntaxfehler. Prüfen Sie Klammern, den Punkt nach jedem Muster und die Präfixe (kg:, kgo:).';

  @override
  String get appearance => 'Darstellung';

  @override
  String get themeSystem => 'Wie am Telefon';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';
}
