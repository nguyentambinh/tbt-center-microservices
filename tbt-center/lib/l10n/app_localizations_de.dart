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
  String get stepPay => 'Auszahlung über den Zahlungskanal';

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
      'Der Zahlungskanal hat nicht rechtzeitig geantwortet; das System gleicht per Referenz ab, bevor erneut gezahlt wird';

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

  @override
  String get payoutCompany => 'Gesellschaft';

  @override
  String payoutPayRegion(String region) {
    return '$region auszahlen';
  }

  @override
  String get payoutPayGroup => 'Ganzen Konzern auszahlen';

  @override
  String payoutPaySelected(int count) {
    return '$count Personen auszahlen';
  }

  @override
  String payoutConfirmTitle(String period) {
    return 'Periode $period auszahlen?';
  }

  @override
  String payoutConfirmRegion(String region) {
    return 'Zahlt an die Mitarbeitenden von $region. Bereits Bezahlte werden Ihnen vorher angezeigt.';
  }

  @override
  String payoutConfirmGroup(int count) {
    return 'Zahlt an die Mitarbeitenden aller $count Gesellschaften. Bereits Bezahlte werden Ihnen vorher angezeigt.';
  }

  @override
  String payoutConfirmPeople(int count, String region) {
    return 'Zahlt an die $count ausgewählten Personen in $region.';
  }

  @override
  String get payoutConfirm => 'Auszahlen';

  @override
  String get payoutDuplicateTitle => 'Einige wurden bereits bezahlt';

  @override
  String get payoutDuplicateBody =>
      'Erneutes Zahlen überweist ihr Gehalt noch einmal. Jede Wahl wird protokolliert.';

  @override
  String payoutDuplicateRegion(String region, int count) {
    return '$region: $count bereits bezahlt';
  }

  @override
  String payoutDuplicatePerson(String employee, int count) {
    return '$employee · $count-mal bezahlt';
  }

  @override
  String get payoutSkipPaid => 'Bereits Bezahlte überspringen';

  @override
  String get payoutResend => 'Erneut zahlen';

  @override
  String get payoutTabPeople => 'Mitarbeitende';

  @override
  String get payoutTabRuns => 'Läufe';

  @override
  String get payoutTabLog => 'Protokoll';

  @override
  String get payoutUnpaid => 'Nicht bezahlt';

  @override
  String payoutPaidTimes(int count) {
    return '$count-mal bezahlt';
  }

  @override
  String get payoutNotCalculated =>
      'Diese Periode ist noch nicht abgerechnet. Zuerst die ganze Gesellschaft auszahlen.';

  @override
  String get payoutResultTitle => 'Ergebnis der Auszahlung';

  @override
  String payoutResultSummary(int paid, int resent, int skipped) {
    return 'Bezahlt $paid · erneut $resent · übersprungen $skipped';
  }

  @override
  String payoutResultFailed(int count) {
    return '$count Zahlungen nicht durchgeführt, bitte später erneut versuchen';
  }

  @override
  String payoutResultMissing(int count) {
    return '$count Personen ohne Lohnabrechnung in dieser Periode';
  }

  @override
  String get payoutStarted => 'Abrechnung gestartet, Auszahlung läuft';

  @override
  String get payoutRetried => 'Restlicher Teil wird ausgezahlt';

  @override
  String get payoutBusy =>
      'Diese Periode wird gerade verarbeitet, bitte danach erneut versuchen';

  @override
  String get payoutUnreachable => 'Server dieser Gesellschaft nicht erreichbar';

  @override
  String get payoutNothing => 'Nichts auszuzahlen';

  @override
  String get payoutAmountHidden =>
      'Beträge nur innerhalb dieser Gesellschaft sichtbar';

  @override
  String get payoutLogPaid => 'Bezahlt';

  @override
  String get payoutLogResent => 'Erneut bezahlt';

  @override
  String get payoutLogSkipped => 'Übersprungen, bereits bezahlt';

  @override
  String get payoutLogWarned => 'Warnung: doppelte Zahlung';

  @override
  String get payoutLogFailed => 'Nicht durchgeführt';

  @override
  String get payoutLogSaga => 'Automatische Abrechnung';

  @override
  String payoutLogLine(String actor, String time) {
    return '$actor · $time';
  }

  @override
  String get noPayoutLog => 'Noch keine Auszahlungen';

  @override
  String get errPayoutFailed =>
      'Die Auszahlung wurde unterbrochen. Erledigte Zahlungen sind gespeichert, bitte später erneut versuchen.';

  @override
  String payoutAccepted(int count) {
    return '$count Zahlungen laufen, Fortschritt im Tab Protokoll';
  }

  @override
  String get payoutLogInDoubt => 'Unklar, Abgleich nötig';

  @override
  String get manualIpButton => 'Change Manual IP';

  @override
  String get manualIpTitle => 'Manuelle IP';

  @override
  String get manualIpHint =>
      'Öffentliche IP eingeben, um dieses Land zu simulieren: Region und Sprache werden daraus erkannt. Leer lassen für die echte IP.';

  @override
  String manualIpCurrent(String region) {
    return 'Erkannte Region: $region';
  }

  @override
  String get manualIpInvalid => 'Ungültige IP';

  @override
  String manualIpSaved(String ip) {
    return 'IP $ip wird simuliert';
  }

  @override
  String get manualIpCleared => 'Wieder echte IP';

  @override
  String get manualIpReset => 'Echte IP';

  @override
  String moreNotifications(int count) {
    return 'und $count weitere';
  }

  @override
  String get filterAll => 'Alle';

  @override
  String get filterStatus => 'Status';

  @override
  String get filterType => 'Typ';

  @override
  String get filterRead => 'Gelesen';

  @override
  String get filterUnread => 'Ungelesen';

  @override
  String get profileTab => 'Profil';

  @override
  String get myProfile => 'Mein Profil';

  @override
  String get proposeChange => 'Änderung beantragen';

  @override
  String get proposeChangeHint =>
      'Nur Geänderte Felder bearbeiten. Das Profil wird nach Freigabe durch HR aktualisiert.';

  @override
  String get changeReason => 'Grund (optional)';

  @override
  String get sendRequest => 'Antrag senden';

  @override
  String get changeRequestSent => 'Antrag gesendet, wartet auf HR';

  @override
  String get changeRequestPending => 'Ein Antrag wartet auf HR';

  @override
  String get changeRequestNoChange => 'Nichts geändert';

  @override
  String get changeHistory => 'Antragsverlauf';

  @override
  String get changeRequests => 'Profiländerungen';

  @override
  String get changeRequestsHint => 'Mitarbeitende möchten Angaben ändern';

  @override
  String pendingChangeRequests(int count) {
    return '$count Profiländerungen';
  }

  @override
  String get noChangeRequests => 'Keine Anträge';

  @override
  String get oldValue => 'Alt';

  @override
  String get newValue => 'Neu';

  @override
  String get decisionNote => 'Hinweis (optional)';

  @override
  String get fieldFacebook => 'Facebook';

  @override
  String get fieldXHandle => 'X-Konto';

  @override
  String get accountInfo => 'Konto';

  @override
  String nProfileChangeRequested(String employee) {
    return '$employee möchte das Profil ändern';
  }

  @override
  String get nProfileChangeApproved => 'HR hat deine Änderungen genehmigt';

  @override
  String nProfileChangeRejected(String note) {
    return 'HR hat deine Änderungen abgelehnt: $note';
  }

  @override
  String get invalidAmount => 'Ungültiger Wert';

  @override
  String get invalidEmail => 'Ungültige E-Mail';

  @override
  String todoProfileChanges(int count) {
    return '$count Profiländerungen';
  }

  @override
  String get departments => 'Abteilungen';

  @override
  String get departmentsHint => 'Versetzungen, Leitung, Auflösung';

  @override
  String get departmentAdd => 'Abteilung hinzufügen';

  @override
  String get departmentName => 'Name der Abteilung';

  @override
  String get departmentNameTaken =>
      'Diese Firma hat bereits eine Abteilung mit diesem Namen';

  @override
  String departmentCreated(String name) {
    return 'Abteilung $name hinzugefügt';
  }

  @override
  String get departmentEmpty => 'Noch niemand in dieser Abteilung';

  @override
  String get departmentHead => 'Leitung';

  @override
  String departmentHeadIs(String name) {
    return 'Leitung: $name';
  }

  @override
  String departmentMembers(int count) {
    return '$count Personen';
  }

  @override
  String get noHead => 'Noch keine Leitung';

  @override
  String get noDepartments => 'Noch keine Abteilungen';

  @override
  String get sortedByHours => 'Leitung zuerst, dann nach Gesamtstunden';

  @override
  String get setHead => 'Zur Leitung machen';

  @override
  String headAssigned(String name) {
    return '$name leitet jetzt die Abteilung';
  }

  @override
  String get moveToDepartment => 'In andere Abteilung versetzen';

  @override
  String get moveHere => 'Hierher versetzen';

  @override
  String transferDone(String name) {
    return 'Nach $name versetzt';
  }

  @override
  String get addMembers => 'Personen hinzufügen';

  @override
  String get addMembersFrom => 'Aus welcher Abteilung?';

  @override
  String addMembersTitle(String name) {
    return 'Nach $name versetzen';
  }

  @override
  String membersMoved(int count) {
    return '$count Personen versetzt';
  }

  @override
  String membersMovedPartly(int moved, int failed) {
    return '$moved versetzt, $failed nicht möglich';
  }

  @override
  String get dissolveDepartment => 'Abteilung auflösen';

  @override
  String dissolveTitle(String name) {
    return '$name auflösen?';
  }

  @override
  String get dissolveReason => 'Grund';

  @override
  String get dissolveNoLongerNeeded => 'Nicht mehr benötigt';

  @override
  String get dissolveRestructured => 'Umstrukturiert oder zusammengelegt';

  @override
  String get dissolveUnderperforming => 'Zu wenig effizient';

  @override
  String get dissolveOutsourced => 'Ausgelagert';

  @override
  String get dissolveBusinessClosed =>
      'Geschäftsbereich verkleinert oder geschlossen';

  @override
  String dissolveMembersMove(int count) {
    return 'Noch $count Personen; wählen Sie die aufnehmende Abteilung';
  }

  @override
  String get chooseReceivingDepartment => 'Aufnehmende Abteilung wählen';

  @override
  String get dissolveConfirm => 'Auflösen';

  @override
  String dissolveDone(String name) {
    return '$name aufgelöst';
  }

  @override
  String get unassignedStaff => 'Neue Mitarbeitende ohne Abteilung';

  @override
  String unassignedCount(int count) {
    return '$count Neue ohne Abteilung';
  }

  @override
  String get unassignedHint => 'KI schlägt eine Abteilung oder eine neue vor';

  @override
  String get noUnassigned => 'Alle haben eine Abteilung';

  @override
  String get aiSuggestPlacement => 'KI-Vorschläge zur Zuordnung';

  @override
  String get aiThinking => 'KI denkt nach...';

  @override
  String get suggestionByAi => 'Von KI vorgeschlagen; HR entscheidet';

  @override
  String get suggestionByRules =>
      'KI nicht verfügbar; Vorschlag nach passenden Positionen';

  @override
  String suggestedDepartment(String name) {
    return 'Vorschlag: $name';
  }

  @override
  String get acceptSuggestion => 'Übernehmen';

  @override
  String get chooseOther => 'Andere wählen';

  @override
  String get chooseDepartment => 'Abteilung wählen';

  @override
  String get newDepartmentProposals => 'Vorgeschlagene neue Abteilungen';

  @override
  String get createDepartmentAndMove => 'Anlegen und versetzen';

  @override
  String get rankings => 'Top-Mitarbeitende';

  @override
  String get rankingsHint => 'Rangliste nach Stunden, Beförderungen';

  @override
  String get rankingFormula =>
      'Punkte = Normalstunden + 1,5 × Überstunden + 2 × Arbeitstage';

  @override
  String rankingDetail(String work, String overtime, int days) {
    return '$work Std. · $overtime Überstd. · $days Tage';
  }

  @override
  String get points => 'Punkte';

  @override
  String get noRankings => 'Keine Zeiterfassung in diesem Zeitraum';

  @override
  String lastMonths(int count) {
    return 'Letzte $count Monate';
  }

  @override
  String get filterPeriod => 'Zeitraum';

  @override
  String get filterDepartment => 'Abteilung';

  @override
  String get filterPosition => 'Position';

  @override
  String get filterCompany => 'Firma';

  @override
  String get filterRegion => 'Region';

  @override
  String get statusWorking => 'Aktiv';

  @override
  String get statusArchived => 'Archiviert';

  @override
  String get viewProfile => 'Profil ansehen';

  @override
  String get nominatePromotion => 'Zur Beförderung vorschlagen';

  @override
  String nominateTitle(String name) {
    return '$name vorschlagen';
  }

  @override
  String get proposedPosition => 'Vorgeschlagene Position';

  @override
  String get raisePercent => 'Gehaltserhöhung';

  @override
  String get raisePercentInvalid => '0,1 bis 100 eingeben';

  @override
  String get nominationReason => 'Begründung';

  @override
  String get sendToExecutives => 'An die Geschäftsleitung';

  @override
  String get nominationSent => 'Vorschlag an die Geschäftsleitung gesendet';

  @override
  String get nominations => 'Beförderungsvorschläge';

  @override
  String get nominationsHint =>
      'Geschäftsleitung genehmigt Position und Gehalt';

  @override
  String get noNominations => 'Keine Vorschläge';

  @override
  String raiseBy(String percent) {
    return 'Erhöhung $percent %';
  }

  @override
  String get approvePromotion => 'Beförderung genehmigen';

  @override
  String approvePromotionHint(String name, String position, String percent) {
    return '$name wird $position mit $percent % mehr Grundgehalt.';
  }

  @override
  String get promotionApproved => 'Genehmigt: Position und Gehalt aktualisiert';

  @override
  String get promotionApprovedNoRaise =>
      'Position geändert; Erhöhung noch offen';

  @override
  String get promotionRejected => 'Vorschlag abgelehnt';

  @override
  String todoNominations(int count) {
    return '$count Beförderungen zu prüfen';
  }

  @override
  String get archiveProfile => 'Profil archivieren';

  @override
  String archiveTitle(String name) {
    return '$name archivieren?';
  }

  @override
  String archiveProjectsWarning(int count) {
    return 'Diese Person ist in $count Projekten und wird aus allen entfernt:';
  }

  @override
  String get archiveNoProjects => 'Diese Person ist in keinem Projekt.';

  @override
  String get archiveKeepsPersonal =>
      'Persönliche Daten bleiben erhalten, Wiederherstellung möglich.';

  @override
  String get archiveReason => 'Grund';

  @override
  String get archiveConfirm => 'Archivieren';

  @override
  String archiveDone(int count) {
    return 'Archiviert, aus $count Projekten entfernt';
  }

  @override
  String profileArchivedBanner(String reason) {
    return 'Profil archiviert. Grund: $reason';
  }

  @override
  String get restoreProfile => 'Wiederherstellen';

  @override
  String get restoreDone => 'Profil wiederhergestellt';

  @override
  String get fieldRequired => 'Pflichtfeld';

  @override
  String get errIsHead => 'Vor der Versetzung eine neue Leitung bestimmen';

  @override
  String get errLastMember => 'Eine Abteilung braucht mindestens eine Person';

  @override
  String get errSameDepartment => 'Bereits in dieser Abteilung';

  @override
  String get errArchived => 'Profil ist archiviert; zuerst wiederherstellen';

  @override
  String get errNotArchived => 'Dieses Profil ist nicht archiviert';

  @override
  String get errMembersRemaining =>
      'Noch Personen vorhanden; aufnehmende Abteilung wählen';

  @override
  String get errNotMember => 'Nicht in dieser Abteilung';

  @override
  String get errPendingExists => 'Es wartet bereits eine Anfrage';

  @override
  String get errServiceUnavailable =>
      'Ein Teil des Systems ist beschäftigt; bitte gleich erneut';

  @override
  String nPromotionNominated(String employee, String position) {
    return '$employee für $position vorgeschlagen';
  }

  @override
  String nPromotionApproved(String position) {
    return 'Glückwunsch! Sie wurden zu $position befördert';
  }

  @override
  String nPromotionRejected(String position) {
    return 'Beförderung zu $position nicht genehmigt';
  }

  @override
  String nPromotionApprovedHr(String employee) {
    return 'Beförderung von $employee genehmigt';
  }

  @override
  String nPromotionRejectedHr(String employee) {
    return 'Beförderung von $employee abgelehnt';
  }

  @override
  String get nEmployeeTransferred =>
      'Sie wurden in eine neue Abteilung versetzt';

  @override
  String get nDepartmentHeadAssigned => 'Sie leiten jetzt Ihre Abteilung';

  @override
  String memberHours(String hours) {
    return '$hours Std.';
  }

  @override
  String get stageInterviewed => 'Gespräch geführt';

  @override
  String get interviewAwaitingCandidate => 'Wartet auf Bewerber';

  @override
  String get interviewAwaitingHr => 'Wartet auf HR';

  @override
  String get interviewConfirmed => 'Bestätigt';

  @override
  String get interviewCancelled => 'Abgesagt';

  @override
  String get interviewSchedule => 'Vorstellungsgespräch';

  @override
  String minutesAttached(String name) {
    return 'Protokoll: $name';
  }

  @override
  String get chooseInterviewTime => 'Datum und Uhrzeit wählen';

  @override
  String get errTimeInPast => 'Der Termin muss in der Zukunft liegen';

  @override
  String get interviewLocation => 'Ort oder Meeting-Link';

  @override
  String get send => 'Senden';

  @override
  String get rejectCandidate => 'Absagen';

  @override
  String rejectCandidateHint(String name) {
    return '$name absagen? Sie können es später erneut prüfen.';
  }

  @override
  String get scheduleInterview => 'Gespräch planen';

  @override
  String get scheduleAgain => 'Neu planen';

  @override
  String get interviewSent => 'Termin gesendet, wartet auf Bestätigung';

  @override
  String get proposeOtherTime => 'Anderen Termin vorschlagen';

  @override
  String get confirmTime => 'Termin bestätigen';

  @override
  String get interviewConfirmedDone => 'Gespräch bestätigt';

  @override
  String get uploadMinutes => 'Protokoll hochladen';

  @override
  String get minutesUploaded => 'Protokoll gespeichert, Gespräch abgeschlossen';

  @override
  String get minutesAfterInterview =>
      'Protokoll (Word, Excel) nach dem Gespräch hochladen';

  @override
  String get openMinutes => 'Protokoll öffnen';

  @override
  String get moveToScreening => 'Zur Vorauswahl';

  @override
  String get reconsider => 'Erneut prüfen';

  @override
  String get reconsidered => 'Bewerbung ist wieder im vorherigen Schritt';

  @override
  String get waitingCandidateReply =>
      'Wartet auf Bestätigung oder Gegenvorschlag';

  @override
  String get waitingHrReply => 'Wartet auf Bestätigung durch HR';

  @override
  String get hiredSalaryPending =>
      'Gehalt nicht gespeichert, bitte unter Gehalt erneut eingeben';

  @override
  String get offerFromAi => 'KI-Vorschlag';

  @override
  String get offerFromRules => 'Vorschlag aus Daten';

  @override
  String get offerPeerMedian =>
      'Mittleres Gehalt gleicher Position, Abteilung mit den meisten Kollegen';

  @override
  String get offerRegionMedian =>
      'Keine Kollegen: regionales Mittel, größte Abteilung';

  @override
  String get agreedSalary => 'Vereinbartes Grundgehalt';

  @override
  String get currency => 'Währung';

  @override
  String get errInvalidStep =>
      'Dieser Schritt ist jetzt nicht möglich, bitte neu laden';

  @override
  String get errNotScreened => 'Erst Vorauswahl, dann Termin';

  @override
  String get errInterviewNotConfirmed =>
      'Das Gespräch ist noch nicht bestätigt';

  @override
  String get errNotInterviewed => 'Vor der Einstellung Protokoll hochladen';

  @override
  String get errNotRejected => 'Diese Bewerbung wurde nicht abgesagt';

  @override
  String get errInvalidOffer =>
      'Gehalt muss über 0 sein und eine Währung haben';

  @override
  String get errMinutesFile => 'Protokoll muss Word oder Excel sein';

  @override
  String nInterviewScheduled(String position, String time) {
    return 'Gespräch für $position am $time, tippen zum Bestätigen';
  }

  @override
  String nInterviewConfirmed(String time) {
    return 'Ihr Gespräch am $time ist bestätigt';
  }

  @override
  String nInterviewConfirmedHr(String position, String time) {
    return 'Gespräch für $position am $time ist bestätigt';
  }

  @override
  String nInterviewProposed(String position, String time) {
    return 'Bewerber für $position schlägt $time vor';
  }

  @override
  String get projectTier => 'Stufe';

  @override
  String get tierSmall => 'Stufe 1 · Klein';

  @override
  String get tierMedium => 'Stufe 2 · Mittel';

  @override
  String get tierLarge => 'Stufe 3 · Groß';

  @override
  String get tierStrategic => 'Stufe 4 · Strategisch';

  @override
  String tierRule(int months, int members) {
    return 'Höchstens $months Monate, mindestens $members Personen';
  }

  @override
  String get warnRed => '≤ 1 Monat übrig';

  @override
  String get warnOrange => '≤ 6 Monate übrig';

  @override
  String get warnYellow => '≤ 12 Monate übrig';

  @override
  String get warnNotStarted => 'Nicht begonnen';

  @override
  String get warnAccepted => 'Abgenommen';

  @override
  String get warnNormal => 'Über 12 Monate übrig';

  @override
  String get projectCharts => 'Projektdiagramme';

  @override
  String get chart2d => '2D';

  @override
  String get chart3d => '3D';

  @override
  String get chartTimeline => 'Zeitachse';

  @override
  String get chartProgress => 'Fortschritt';

  @override
  String get chartMembers => 'Personen';

  @override
  String get chartValue => 'Wert';

  @override
  String get thousandUsd => 'Tsd. USD';

  @override
  String get projectProposals => 'Projektvorschläge';

  @override
  String get projectNew => 'Neues Projekt';

  @override
  String get wizardFiles => 'Vertrag und Bild';

  @override
  String get wizardFilesHint =>
      'Vertrag hochladen (PDF oder Word, nach Vorlage); die KI füllt das Formular aus. Ohne Vertrag im nächsten Schritt von Hand eingeben.';

  @override
  String get wizardInfo => 'Projektdaten';

  @override
  String get wizardMembers => 'Team';

  @override
  String get wizardSend => 'An die Leitung senden';

  @override
  String get downloadContractTemplate => 'Vertragsvorlage laden';

  @override
  String get uploadContract => 'Vertrag hochladen';

  @override
  String get uploadProjectImage => 'Projektbild hochladen';

  @override
  String get contractReadByAi =>
      'Die KI hat den Vertrag gelesen, bitte im nächsten Schritt prüfen';

  @override
  String get contractReadManual =>
      'Vertrag konnte nicht gelesen werden, bitte von Hand eingeben';

  @override
  String get projectName => 'Projektname';

  @override
  String get customerName => 'Kunde';

  @override
  String get customerCompany => 'Unternehmen';

  @override
  String get customerIndividual => 'Privatperson';

  @override
  String get customerContact => 'Kundenkontakt (E-Mail oder Telefon)';

  @override
  String get contractType => 'Vertragsart';

  @override
  String get contractValue => 'Vertragswert';

  @override
  String get depositAmount => 'Anzahlung';

  @override
  String get startDate => 'Beginn';

  @override
  String get endDate => 'Ende';

  @override
  String get acceptanceDate => 'Abnahme';

  @override
  String get propErrName => 'Projektname fehlt';

  @override
  String get propErrCustomer => 'Kunde fehlt';

  @override
  String get propErrValue => 'Vertragswert muss über 0 liegen';

  @override
  String get propErrDeposit =>
      'Anzahlung darf nicht negativ oder höher als der Vertragswert sein';

  @override
  String get propErrDates => 'Beginn und Ende fehlen';

  @override
  String get propErrStartPast =>
      'Beginn darf nicht in der Vergangenheit liegen';

  @override
  String get propErrEndBeforeStart => 'Ende muss nach dem Beginn liegen';

  @override
  String get propErrAcceptance =>
      'Abnahme muss innerhalb von 90 Tagen nach Ende liegen';

  @override
  String get propErrTooLong => 'Zu lang für diese Stufe';

  @override
  String get propErrFewMembers => 'Zu wenige Personen für diese Stufe';

  @override
  String membersNeeded(int min, int picked) {
    return 'Mindestens $min Personen · $picked gewählt';
  }

  @override
  String get suggestMembers => 'KI-Teamvorschlag';

  @override
  String activeProjects(int count) {
    return '$count laufende Projekte';
  }

  @override
  String get next => 'Weiter';

  @override
  String get back => 'Zurück';

  @override
  String get sendToExecutive => 'Zur Genehmigung senden';

  @override
  String get proposalSent => 'Vorschlag gesendet, wartet auf die Leitung';

  @override
  String get noProposals => 'Keine Projektvorschläge';

  @override
  String proposalVersion(int version) {
    return 'Version $version';
  }

  @override
  String get propAwaitingExecutive => 'Wartet auf Leitung';

  @override
  String get propAwaitingProposer => 'Wartet auf Antragsteller';

  @override
  String get propApproved => 'Genehmigt';

  @override
  String get propRejected => 'Abgelehnt';

  @override
  String get proposalEdit => 'Vorschlag ändern';

  @override
  String get proposalNoteHint => 'Grund oder Änderungswunsch';

  @override
  String proposalApprovedDone(String id) {
    return 'Genehmigt, Projekt $id angelegt';
  }

  @override
  String get acceptEdits => 'Änderungen annehmen';

  @override
  String get withdrawProposal => 'Zurückziehen';

  @override
  String get waitingOtherSide => 'Wartet auf die andere Seite';

  @override
  String get openContract => 'Vertrag öffnen';

  @override
  String get openImage => 'Bild öffnen';

  @override
  String get openProject => 'Projekt öffnen';

  @override
  String get propActSubmitted => 'Eingereicht';

  @override
  String get propActCounter => 'Geändert';

  @override
  String get propActApprove => 'Zugestimmt';

  @override
  String get propActReject => 'Abgelehnt';

  @override
  String get propActWithdraw => 'Zurückgezogen';

  @override
  String todoProposals(int count) {
    return '$count Projektvorschläge zu prüfen';
  }

  @override
  String nProjectProposed(String name) {
    return 'Neuer Projektvorschlag: $name';
  }

  @override
  String nProjectCountered(String name) {
    return 'Die Leitung hat $name geändert, bitte bestätigen';
  }

  @override
  String nProjectApproved(String name) {
    return 'Projekt $name genehmigt und angelegt';
  }

  @override
  String nProjectRejected(String name) {
    return 'Projektvorschlag $name abgelehnt';
  }

  @override
  String get workCalendar => 'Arbeitskalender';

  @override
  String get clockStats => 'Anwesenheitsdiagramme';

  @override
  String shiftHours(String start, String end) {
    return 'Schicht $start–$end';
  }

  @override
  String get errShiftEnded =>
      'Die Schicht ist vorbei, Einstempeln nicht mehr möglich';

  @override
  String get errTooManyFiles => 'Höchstens 5 Dateien pro Antrag';

  @override
  String get errFileType => 'Dieser Dateityp wird nicht angenommen';

  @override
  String get addEvidence => 'Nachweis hinzufügen';

  @override
  String viewOriginalLeave(int count) {
    return 'Originale ansehen ($count)';
  }

  @override
  String get evidenceUploaded =>
      'Nachweis hinzugefügt, KI-Zusammenfassung für HR aktualisiert';

  @override
  String get noEvidence => 'Noch keine Nachweise';

  @override
  String get aiLeaveSummary => 'KI-Zusammenfassung der Nachweise';

  @override
  String get evidenceMatches => 'Passt zum Antrag';

  @override
  String get evidenceCheck => 'Genauer prüfen';

  @override
  String get calWorked => 'Gearbeitet';

  @override
  String get calLeave => 'Urlaub';

  @override
  String get calHoliday => 'Feiertag';

  @override
  String get calAbsent => 'Abwesend';

  @override
  String get calScheduled => 'Geplant';

  @override
  String calLeaveOfType(String type) {
    return 'Urlaub: $type';
  }

  @override
  String get noShiftThisDay => 'Keine Schicht an diesem Tag';

  @override
  String estimatedDayPay(String amount) {
    return 'Geschätzter Tagesverdienst: $amount';
  }

  @override
  String estimatedMonthPay(String amount) {
    return 'Geschätzter Verdienst nach Stunden: $amount';
  }

  @override
  String get payEstimateHint =>
      'Grundgehalt, 26 Arbeitstage, Überstunden 150 %; vor Versicherung und Steuern';

  @override
  String get projectsThisDay => 'Projekte an diesem Tag';

  @override
  String get statsScopeRegion => 'Gesamte Region';

  @override
  String get statsScopeMine => 'Meine';

  @override
  String get statsDays => 'Erfasste Tage';

  @override
  String get statsLate => 'Verspätungen';

  @override
  String get statsByWeekday => 'Nach Wochentag';

  @override
  String get statsByHour => 'Einstempelzeit';

  @override
  String get statsByMonth => 'Tage und Verspätungen pro Monat';

  @override
  String get errPayrollTooEarly =>
      'Dieser Zeitraum ist noch nicht offen: Monat M ab dem 10. des Folgemonats';

  @override
  String get errAmountLowered =>
      'Das Gehalt darf nur gleich bleiben oder steigen';

  @override
  String get errNotHigher =>
      'Das gewünschte Gehalt muss über dem aktuellen liegen';

  @override
  String get errNoSalary => 'Noch kein Grundgehalt hinterlegt';

  @override
  String get errAwaitingAck => 'Der vorige Bericht wartet noch auf Bestätigung';

  @override
  String get acknowledge => 'Bestätigen';

  @override
  String get byDay => 'Tag';

  @override
  String get byMonth => 'Monat';

  @override
  String get byYear => 'Jahr';

  @override
  String get costs => 'Kosten';

  @override
  String get export => 'Exportieren';

  @override
  String get exportExcel => 'Als Excel';

  @override
  String get exportPdf => 'Als PDF';

  @override
  String exportedAt(String time) {
    return 'Exportiert am $time';
  }

  @override
  String get exportId => 'ID';

  @override
  String get exportPeriod => 'Zeitraum';

  @override
  String get exportRank => 'Rang';

  @override
  String get exportMargin => 'Marge';

  @override
  String get exportCurrency => 'Währung';

  @override
  String get exportRevenueUsd => 'Umsatz (USD)';

  @override
  String get exportCostUsd => 'Kosten (USD)';

  @override
  String exportFinanceTitle(int year) {
    return 'Einnahmen und Kosten $year';
  }

  @override
  String get financeAnalytics => 'Analyse';

  @override
  String get materialCost => 'Material';

  @override
  String get payrollCost => 'Löhne';

  @override
  String get materialsUsed => 'Verwendetes Material';

  @override
  String get revenueByStage => 'Umsatz nach Abschnitt';

  @override
  String get projectProfitRanking => 'Projekte nach Gewinn';

  @override
  String get projectSalaryShares => 'Projektlohn je Person';

  @override
  String get overtimePay => 'Überstunden';

  @override
  String get insuranceDeduction => 'Sozialversicherung';

  @override
  String get incomeTax => 'Lohnsteuer';

  @override
  String get salaryGrowth => 'Gehalt im Verlauf';

  @override
  String salaryGrowthRate(String rate, int count) {
    return 'Netto $rate über $count Zeiträume';
  }

  @override
  String payrollOpensOn(String period, String date) {
    return 'Abrechnung $period öffnet am $date';
  }

  @override
  String get raiseRequests => 'Gehaltswünsche';

  @override
  String get raiseRequestsHint => 'Wünsche senden, weiterleiten, genehmigen';

  @override
  String get newRaiseRequest => 'Gehaltswunsch';

  @override
  String get noRaiseRequests => 'Keine Gehaltswünsche';

  @override
  String get proposedSalary => 'Vorgeschlagenes Grundgehalt';

  @override
  String raiseMinimum(String amount) {
    return 'Mindestens $amount';
  }

  @override
  String get raiseReason => 'Begründung (Leistung, neue Aufgaben...)';

  @override
  String get raiseActionTitle => 'Gehalt und Notiz';

  @override
  String get raiseSent => 'Gehaltswunsch gesendet';

  @override
  String get raiseForwarded => 'Zur Genehmigung weitergeleitet';

  @override
  String get raiseApprovedDone => 'Genehmigt, Grundgehalt erhöht';

  @override
  String get raiseForward => 'Weiterleiten';

  @override
  String get raiseReturn => 'Zurückgeben';

  @override
  String get raiseEdit => 'Betrag ändern';

  @override
  String get raiseAwaitingHr => 'Bei HR';

  @override
  String get raiseAwaitingApprover => 'Wartet auf Genehmigung';

  @override
  String get raiseAwaitingEmployee => 'An Mitarbeiter zurück';

  @override
  String get raiseWithdrawn => 'Zurückgezogen';

  @override
  String raiseRequestedFirst(String amount) {
    return 'Ursprünglich $amount';
  }

  @override
  String get reportSubmissions => 'Berichte an die Leitung';

  @override
  String get reportSubmissionsHint => 'Personal- und Finanzberichte';

  @override
  String get reportHr => 'Personal';

  @override
  String get reportFinance => 'Finanzen';

  @override
  String get noReports => 'Noch keine Berichte';

  @override
  String get submitReport => 'Bericht senden';

  @override
  String submitReportTitle(String period) {
    return 'Bericht $period senden';
  }

  @override
  String get reportWaitingAck => 'Wartet auf Bestätigung';

  @override
  String get reportSent => 'Bericht an die Leitung gesendet';

  @override
  String get reportAcknowledged => 'Bericht bestätigt';

  @override
  String get returnReport => 'Bericht zurückgeben';

  @override
  String get reportStatusSubmitted => 'Wartet';

  @override
  String get reportStatusAcknowledged => 'Bestätigt';

  @override
  String get reportStatusReturned => 'Zurückgegeben';

  @override
  String reportPeriod(String period) {
    return 'Bericht $period';
  }

  @override
  String reportHeadcount(int people, int departments) {
    return '$people Mitarbeiter, $departments Abteilungen';
  }

  @override
  String reportUnassigned(int count) {
    return '$count ohne Abteilung';
  }

  @override
  String reportNominations(int pending, int approved) {
    return 'Beförderungen: $pending offen, $approved genehmigt';
  }

  @override
  String get resignations => 'Kündigung';

  @override
  String get resignationsHint => 'Kündigung einreichen und verfolgen';

  @override
  String get newResignation => 'Kündigen';

  @override
  String get resignationLastDay => 'Letzter Arbeitstag';

  @override
  String resignationLastDayOn(String date) {
    return 'Letzter Tag: $date';
  }

  @override
  String get resignationReason => 'Grund der Kündigung';

  @override
  String resignationNotice(int days) {
    return 'Mindestens $days Tage Kündigungsfrist';
  }

  @override
  String get resignationSent => 'Kündigung an HR gesendet';

  @override
  String get noResignations => 'Noch keine Kündigungen';

  @override
  String get resignationPending => 'Wartet auf HR';

  @override
  String get resignationApproved => 'Bestätigt, Kündigungsfrist läuft';

  @override
  String get resignationCompleted => 'Ausgeschieden';

  @override
  String get resignationWithdrawn => 'Zurückgezogen';

  @override
  String get resignationWithdraw => 'Zurückziehen';

  @override
  String get resignationComplete => 'Austritt abschließen';

  @override
  String resignationCompleteConfirm(String name) {
    return 'Die Akte von $name wird archiviert und aus allen Projekten entfernt. Fortfahren?';
  }

  @override
  String get resignationCompletedDone =>
      'Austritt abgeschlossen, Akte archiviert';

  @override
  String get errNoticeTooShort =>
      'Der letzte Tag muss mindestens 30 Tage entfernt sein';

  @override
  String get errBeforeLastDay =>
      'Der letzte Arbeitstag ist noch nicht erreicht';

  @override
  String get exportCsv => 'CSV exportieren';

  @override
  String get exportJson => 'JSON exportieren';

  @override
  String get auditCharts => 'Diagramme';

  @override
  String get auditFilter => 'Detailfilter';

  @override
  String get auditService => 'Dienst';

  @override
  String get auditEventType => 'Ereignistyp';

  @override
  String get auditTime => 'Zeitpunkt';

  @override
  String get auditFromTime => 'Von';

  @override
  String get auditToTime => 'Bis';

  @override
  String get anyTime => 'Beliebig';

  @override
  String get anomalyAny => 'Auffällig';

  @override
  String get anomalyAfterHours => 'Außerhalb der Zeit (22–6 Uhr)';

  @override
  String get anomalyFailure => 'Fehlgeschlagen, abgelehnt';

  @override
  String get auditTotal => 'Ereignisse gesamt';

  @override
  String get auditByRegion => 'Nach Region';

  @override
  String get auditByHour => 'Nach Ortszeit (rot = außerhalb)';

  @override
  String get auditByDay => 'Nach Tag';

  @override
  String get auditByType => 'Häufigste Ereignistypen';

  @override
  String get auditByService => 'Nach Dienst';

  @override
  String get clearFilters => 'Filter löschen';

  @override
  String get auditSignedExport => 'CSV mit SHA-256';

  @override
  String get approvalInbox => 'Genehmigungen';

  @override
  String get approvalInboxHint =>
      'Projekte, Beförderungen, Gehälter aller Regionen';

  @override
  String get approvalKindProject => 'Projekt';

  @override
  String get approvalKindPromotion => 'Beförderung';

  @override
  String get approvalKindRaise => 'Gehaltserhöhung';

  @override
  String get noApprovals => 'Nichts wartet auf Genehmigung';

  @override
  String approvalWaiting(int count) {
    return '$count warten auf Genehmigung';
  }

  @override
  String approvalRegionsDown(String regions) {
    return 'Keine Daten von: $regions';
  }

  @override
  String get approvalByRegion => 'Offen nach Region';

  @override
  String approvalPromotionLine(String position, String percent) {
    return 'Zu $position, +$percent% Gehalt';
  }

  @override
  String get approvalDone => 'Entscheidung gespeichert';

  @override
  String approvalConfirm(String title) {
    return '$title genehmigen?';
  }

  @override
  String approvalRejectConfirm(String title) {
    return '$title ablehnen?';
  }

  @override
  String get approvalColKind => 'Art';

  @override
  String get approvalColTitle => 'Inhalt';

  @override
  String get approvalColDetail => 'Details';

  @override
  String get approvalColUpdated => 'Aktualisiert';

  @override
  String get jobPositions => 'Offene Stellen';

  @override
  String get jobPositionsHint => 'Stellen, Bedarf, Bewerber nach KI-Eignung';

  @override
  String get newJobPosition => 'Neue Stelle';

  @override
  String get editJobPosition => 'Stelle bearbeiten';

  @override
  String get noJobPositions => 'Noch keine offenen Stellen';

  @override
  String get positionTitle => 'Stellenbezeichnung';

  @override
  String get positionDepartment => 'Abteilung';

  @override
  String get positionHeadcount => 'Benötigte Personen';

  @override
  String get positionDescription => 'Aufgaben';

  @override
  String get positionRequirements => 'Anforderungen';

  @override
  String get positionRequirementsHint =>
      'Die KI bewertet Lebensläufe anhand dieser Anforderungen';

  @override
  String get positionOpen => 'Offen';

  @override
  String get positionFilled => 'Besetzt';

  @override
  String get positionClosed => 'Geschlossen';

  @override
  String get closePosition => 'Stelle schließen';

  @override
  String get reopenPosition => 'Wieder öffnen';

  @override
  String get positionSaved => 'Stelle gespeichert';

  @override
  String get positionApplicants => 'Bewerber (beste KI-Eignung zuerst)';

  @override
  String positionProgress(int hired, int headcount, int applicants) {
    return 'Eingestellt $hired/$headcount · $applicants Bewerber';
  }

  @override
  String positionSlotsLeft(int count) {
    return '$count frei';
  }

  @override
  String get choosePositions => 'Stellen wählen';

  @override
  String get choosePositionsHint => 'Zum Auswählen tippen';

  @override
  String choosePositionsHelper(int max) {
    return 'Eine oder mehrere, höchstens $max';
  }

  @override
  String positionsChosen(int count) {
    return 'Fertig ($count gewählt)';
  }

  @override
  String get positionMatchTitle => 'Eignung je Stelle (KI)';

  @override
  String get positionMatchPending => 'KI prüft';

  @override
  String get positionMatchNone => 'Nicht geprüft';

  @override
  String get positionMatchStrengths => 'Erfüllt';

  @override
  String get positionMatchGaps => 'Fehlt';

  @override
  String bestMatch(int score) {
    return '$score% passend';
  }

  @override
  String get errNoPosition => 'Mindestens eine Stelle wählen';

  @override
  String get errTooManyPositions => 'Höchstens 5 Stellen';

  @override
  String get errPositionUnavailable =>
      'Diese Stelle ist geschlossen oder besetzt';

  @override
  String get errPositionTitleExists =>
      'Eine offene Stelle mit diesem Titel existiert bereits';

  @override
  String get errInvalidHeadcount => 'Bedarf muss zwischen 1 und 500 liegen';

  @override
  String errHeadcountBelowHired(int hired) {
    return '$hired bereits eingestellt';
  }

  @override
  String get errInvalidPosition => 'Titel und Bedarf eingeben';

  @override
  String nRaiseRequested(String employee) {
    return '$employee hat eine Gehaltserhöhung beantragt';
  }

  @override
  String nRaiseForwarded(String employee) {
    return 'HR hat den Gehaltswunsch von $employee zur Genehmigung weitergeleitet';
  }

  @override
  String get nRaiseApproved => 'Ihr Gehaltswunsch wurde genehmigt';

  @override
  String get nRaiseRejected => 'Ihr Gehaltswunsch wurde abgelehnt';

  @override
  String get nRaiseReturned =>
      'Ihr Gehaltswunsch wurde zur Überarbeitung zurückgegeben';

  @override
  String nReportSubmitted(String report, String period) {
    return 'Neuer Bericht $report für $period zur Bestätigung';
  }

  @override
  String nReportAcknowledged(String report, String period) {
    return 'Bericht $report für $period wurde bestätigt';
  }

  @override
  String nReportReturned(String report, String period) {
    return 'Bericht $report für $period wurde zurückgegeben';
  }

  @override
  String nResignationRequested(String employee, String date) {
    return '$employee hat gekündigt, letzter Arbeitstag $date';
  }

  @override
  String nResignationApproved(String date) {
    return 'Ihre Kündigung wurde bestätigt, letzter Tag $date';
  }

  @override
  String get nResignationRejected => 'Ihre Kündigung wurde nicht bestätigt';

  @override
  String nResignationWithdrawn(String employee) {
    return '$employee hat die Kündigung zurückgezogen';
  }

  @override
  String get reportKindHr => 'Personal';

  @override
  String get reportKindFinance => 'Finanzen';

  @override
  String get openFullPage => 'Ganze Seite öffnen';

  @override
  String get requestAlreadyHandled => 'Dieser Antrag wurde bereits bearbeitet';

  @override
  String get requestFrom => 'Von';

  @override
  String get waitingSuperior => 'Wartet auf Vorgesetzte';

  @override
  String get signupTitle => 'Bewerberkonto erstellen';

  @override
  String get signupHint =>
      'Geben Sie Ihre Daten ein. Ein 6-stelliger Code wird an diese E-Mail gesendet.';

  @override
  String get sendCode => 'Code senden';

  @override
  String codeSentTo(String email) {
    return 'Code an $email gesendet, auch Spam prüfen';
  }

  @override
  String get verificationCode => 'Bestätigungscode (6 Ziffern)';

  @override
  String get newPassword => 'Passwort';

  @override
  String get passwordRule => 'Mindestens 8 Zeichen mit Buchstaben und Ziffern';

  @override
  String get confirmPassword => 'Passwort wiederholen';

  @override
  String get createAccount => 'Bestätigen und Konto erstellen';

  @override
  String get resendCode => 'Code erneut senden';

  @override
  String resendIn(int seconds) {
    return 'Erneut senden in $seconds s';
  }

  @override
  String get editDetails => 'Name, E-Mail, Telefon ändern';

  @override
  String get signupDone => 'Konto erstellt, bitte anmelden';

  @override
  String get changePassword => 'Passwort ändern';

  @override
  String get passwordChanged => 'Passwort geändert';

  @override
  String get profileViewed => 'Ihre Bewerbung wurde angesehen';

  @override
  String get profileViewedHint =>
      'HR hat Ihre Bewerbung geöffnet, sie kann nicht mehr geändert werden';

  @override
  String get cvRequired => 'Lebenslauf (PDF) anhängen, um zu speichern';

  @override
  String get accountDetails => 'Aus Ihrem Konto';

  @override
  String get errInvalidEmail => 'E-Mail ist ungültig';

  @override
  String get errInvalidName => 'Name 2 bis 80 Zeichen';

  @override
  String get errInvalidPhone => 'Telefonnummer ungültig';

  @override
  String get errWeakPassword =>
      'Passwort braucht 8+ Zeichen mit Buchstaben und Ziffern';

  @override
  String get errEmailTaken => 'Für diese E-Mail gibt es bereits ein Konto';

  @override
  String get errCodeTooSoon => 'Code gerade gesendet, 60 Sekunden warten';

  @override
  String get errCodeExpired =>
      'Code abgelaufen oder zu oft falsch, neuen anfordern';

  @override
  String get errWrongCode => 'Falscher Code';

  @override
  String get errSignupUnavailable => 'E-Mail kann gerade nicht gesendet werden';

  @override
  String get projectTime => 'Zeitraum';

  @override
  String get me => 'Ich';

  @override
  String myProjectPay(String amount) {
    return 'Meine Projektvergütung: $amount';
  }

  @override
  String get mySchedule => 'Mein Arbeitsplan';

  @override
  String myScheduleHint(int days) {
    return '$days Arbeitstage diesen Monat im Projekt';
  }

  @override
  String myScheduleEarned(String amount) {
    return 'Geschätzte Vergütung: $amount';
  }

  @override
  String get notCheckedIn => 'Nicht eingestempelt';

  @override
  String get contractRequired =>
      'Vertrag (PDF, Word) hochladen, damit die KI die Daten liest';

  @override
  String get attachedBonuses =>
      'Prämien und Abzüge, letzte 12 Monate (angehängt)';

  @override
  String bonusNet(String amount) {
    return 'Saldo: $amount';
  }

  @override
  String moreItems(int count) {
    return 'und $count weitere';
  }

  @override
  String get orgTree => 'Organigramm';

  @override
  String get orgTreeSearch => 'Personen oder Rollen suchen';

  @override
  String orgTreeSummary(int departments, int people) {
    return '$departments Abteilungen · $people Personen';
  }

  @override
  String get orgTreeToggle => 'Alle ein-/ausklappen';

  @override
  String get level1 => 'Mitarbeitende';

  @override
  String get level2 => 'Fachkraft, Ingenieur';

  @override
  String get level3 => 'Leitung, Stellvertretung';

  @override
  String get level4 => 'Abteilungsleitung';

  @override
  String get level5 => 'Direktion';

  @override
  String get level6 => 'Geschäftsführung';

  @override
  String get noHigherPosition => 'Bereits auf der höchsten Ebene';

  @override
  String get errNotHigherPosition => 'Beförderung nur auf höhere Ebene';

  @override
  String get errUnknownPosition => 'Position aus der Liste wählen';

  @override
  String overtimeApprovedToday(String hours, String until) {
    return '$hours Std. Überstunden genehmigt: Arbeit bis $until zählt';
  }

  @override
  String overtimePendingToday(String hours) {
    return 'Überstundenantrag über $hours Std. offen: zählt erst nach Genehmigung';
  }

  @override
  String get overtimeNoneToday =>
      'Keine genehmigten Überstunden: Zeit nach Schichtende zählt nicht';

  @override
  String get viewZoomIn => 'Vergrößern';

  @override
  String get viewZoomOut => 'Verkleinern';

  @override
  String get viewFromTop => 'Von oben ansehen';

  @override
  String get viewFromBottom => 'Von unten ansehen';

  @override
  String get viewRotateLeft => 'Nach links drehen';

  @override
  String get viewRotateRight => 'Nach rechts drehen';

  @override
  String get viewReset => 'Ansicht zurücksetzen';

  @override
  String get sectionGroup => 'Konzern';

  @override
  String get sectionAdmin => 'Verwaltung';

  @override
  String get roleGroup => 'Konzernebene';

  @override
  String get groupOverview => 'Konzernübersicht';

  @override
  String get groupOverviewHint =>
      'Kennzahlen je Land, Land antippen für Details';

  @override
  String get adminConsole => 'Datenverwaltung';

  @override
  String get adminConsoleHint =>
      'Konten, Arbeitskalender, Positionen, Statistik, Sicherungen, SQL';

  @override
  String viewingRegion(String region) {
    return 'Ansicht: $region';
  }

  @override
  String get chooseRegion => 'Region wählen';

  @override
  String get approvalKindLeave => 'Urlaub';

  @override
  String get approvalKindOvertime => 'Überstunden';

  @override
  String get approvalKindProfile => 'Profiländerung';

  @override
  String get approvalKindResignation => 'Kündigung';

  @override
  String get groupTotals => 'Gesamter Konzern';

  @override
  String get groupEmployees => 'Mitarbeitende';

  @override
  String get groupRevenueYtd => 'Umsatz dieses Jahr (USD)';

  @override
  String get groupCostYtd => 'Kosten dieses Jahr (USD)';

  @override
  String get groupRegionDown =>
      'Daten dieses Landes nicht verfügbar, zum Aktualisieren ziehen';

  @override
  String get execActions => 'Direkt ausführen';

  @override
  String get execChangePosition => 'Befördern oder Position ändern';

  @override
  String get execPromote => 'Befördern';

  @override
  String get execChangeOnly => 'Position ändern';

  @override
  String get execNewPosition => 'Neue Position';

  @override
  String get execNoHigherPosition => 'Keine höhere Position verfügbar';

  @override
  String get execReason => 'Grund (im Prüfprotokoll)';

  @override
  String get execReasonRequired => 'Grund (Pflicht)';

  @override
  String get execSalary => 'Grundgehalt ändern';

  @override
  String execCurrentSalary(String amount) {
    return 'Aktuelles Grundgehalt: $amount';
  }

  @override
  String get execNewSalary => 'Neues Grundgehalt';

  @override
  String get execBonus => 'Bonus oder Abzug';

  @override
  String get execBonusKind => 'Bonus';

  @override
  String get execPenaltyKind => 'Abzug';

  @override
  String get execAmount => 'Betrag (in der Gehaltswährung)';

  @override
  String get execApply => 'Sofort anwenden';

  @override
  String get execAuditNote =>
      'Sofort wirksam ohne weitere Freigabe; mit Ihrem Namen im Prüfprotokoll.';

  @override
  String get execApplied => 'Angewendet und protokolliert';

  @override
  String get nominationScope => 'Ebene';

  @override
  String get nominationScopeRegion => 'Beförderung im Land';

  @override
  String get nominationScopeGroupHr => 'Zum Konzernpersonal';

  @override
  String get nominationScopeGroupFinance => 'Zu den Konzernfinanzen';

  @override
  String get nominationGroupNote =>
      'Entscheidet die Konzernleitung; danach arbeitet die Person in allen Regionen.';

  @override
  String get nominationToGroup => 'Konzernebene';

  @override
  String get adminTabOverview => 'Übersicht';

  @override
  String get adminTabAccounts => 'Konten';

  @override
  String get adminTabCalendar => 'Arbeitskalender';

  @override
  String get adminTabPositions => 'Positionen';

  @override
  String get adminTabData => 'Daten';

  @override
  String get adminAccountsByRole => 'Konten nach Rolle';

  @override
  String adminAccountsTotal(int n) {
    return '$n Konten';
  }

  @override
  String get adminDatabases => 'Datenbanken';

  @override
  String adminDbLine(int tables, String rows, String size) {
    return '$tables Tabellen · $rows Zeilen · $size';
  }

  @override
  String get adminActivity => 'Aktivität der letzten 14 Tage (Ereignisse)';

  @override
  String get adminRowsByDb => 'Zeilen je Datenbank';

  @override
  String get adminDbUnavailable => 'Diese Datenbank war nicht lesbar';

  @override
  String get adminSearchAccounts => 'Name, E-Mail, Benutzername suchen';

  @override
  String get adminAccountDisabled => 'Gesperrt';

  @override
  String adminEditAccount(String name) {
    return 'Konto $name bearbeiten';
  }

  @override
  String get adminAccountEnabled => 'Anmeldung erlauben';

  @override
  String get adminRoles => 'Rollen';

  @override
  String get adminSaved => 'Gespeichert und protokolliert';

  @override
  String get adminHolidays => 'Feiertage';

  @override
  String get adminAddHoliday => 'Feiertag hinzufügen';

  @override
  String get adminHolidayName => 'Name des Feiertags';

  @override
  String adminHolidayRemove(String name) {
    return 'Feiertag $name entfernen?';
  }

  @override
  String get adminNoHolidays => 'Für dieses Jahr noch keine Feiertage';

  @override
  String get adminShift => 'Schichtzeiten';

  @override
  String get adminShiftHint =>
      'Beginn und Ende aller Schichten im Zeitraum ändern (ab heute; erfasste Zeiten bleiben)';

  @override
  String get adminShiftChange => 'Schichtzeiten ändern';

  @override
  String get adminShiftStart => 'Beginn';

  @override
  String get adminShiftEnd => 'Ende';

  @override
  String get adminShiftRange => 'Zeitraum';

  @override
  String adminShiftDone(int n) {
    return '$n Schichten geändert';
  }

  @override
  String get adminAddPosition => 'Position hinzufügen';

  @override
  String get adminEditPosition => 'Position bearbeiten';

  @override
  String get adminPositionName => 'Positionsname';

  @override
  String get adminPositionLevel => 'Ebene';

  @override
  String get adminCoefficient => 'Gehaltsfaktor';

  @override
  String adminHolders(int n) {
    return '$n Personen';
  }

  @override
  String get adminDeletePosition => 'Position löschen';

  @override
  String get adminSql => 'SQL-Abfrage';

  @override
  String get adminSqlHint =>
      'Standardmäßig nur lesen; jede Ausführung wird protokolliert';

  @override
  String get adminSqlWrite => 'Schreiben erlauben (INSERT, UPDATE, DELETE)';

  @override
  String get adminSqlWriteConfirm =>
      'Dies ändert echte Daten und wird protokolliert. Ausführen?';

  @override
  String get adminSqlRun => 'Ausführen';

  @override
  String adminSqlRows(int n) {
    return '$n Zeilen';
  }

  @override
  String adminSqlAffected(int n) {
    return '$n Zeilen betroffen';
  }

  @override
  String get adminSqlTruncated => 'Nur die ersten 500 Zeilen';

  @override
  String get adminTechnical => 'Technische Details';

  @override
  String get adminBackups => 'Sicherungen';

  @override
  String get adminBackupNow => 'Jetzt sichern';

  @override
  String get adminBackupDone => 'Die Daten der Region wurden gesichert';

  @override
  String get adminBackupNone => 'Noch keine Sicherungen';

  @override
  String get adminDownload => 'Herunterladen';

  @override
  String get errGroupOnly =>
      'Nur die Konzernleitung entscheidet diese Nominierung';

  @override
  String get errSamePosition => 'Die Person hat diese Position bereits';

  @override
  String get errInUse =>
      'Die Position ist noch besetzt und kann nicht gelöscht werden';

  @override
  String get errReadOnly =>
      'Die Anweisung schreibt Daten; Schreiben erlauben einschalten, wenn gewollt';

  @override
  String get errSqlError =>
      'Die Anweisung schlug fehl, siehe technische Details';

  @override
  String get errUnknownDatabase => 'Datenbank aus der Liste wählen';

  @override
  String get errEmptySql => 'SQL-Anweisung eingeben';

  @override
  String get errStorageUnavailable =>
      'Speicher nicht verfügbar, später erneut versuchen';

  @override
  String get errIdentityUnavailable =>
      'Kontodienst nicht erreichbar, später erneut versuchen';

  @override
  String get errOtherRegion => 'Dieses Konto gehört zu einer anderen Region';

  @override
  String get errRoleNotAllowed =>
      'Diese Rolle dürfen Sie nicht vergeben oder entziehen';

  @override
  String get errSelfChange => 'Das eigene Konto kann nicht geändert werden';

  @override
  String get errInvalidShift =>
      'Ungültige Schicht: Ende muss nach Beginn liegen';

  @override
  String get errInvalidRange => 'Ungültiger Zeitraum (höchstens ein Jahr)';

  @override
  String get adminRemove => 'Entfernen';

  @override
  String get evClockedIn => 'Eingestempelt';

  @override
  String get evClockedOut => 'Ausgestempelt';

  @override
  String get evLeaveRequested => 'Urlaub beantragt';

  @override
  String get evLeaveApproved => 'Urlaub genehmigt';

  @override
  String get evLeaveRejected => 'Urlaub abgelehnt';

  @override
  String get evOvertimeRequested => 'Überstunden beantragt';

  @override
  String get evOvertimeApproved => 'Überstunden genehmigt';

  @override
  String get evOvertimeRejected => 'Überstunden abgelehnt';

  @override
  String get evHolidayAdded => 'Feiertag hinzugefügt';

  @override
  String get evHolidayRemoved => 'Feiertag entfernt';

  @override
  String get evShiftChanged => 'Schichtzeiten geändert';

  @override
  String get evCandidateApplied => 'Bewerbung eingegangen';

  @override
  String get evCandidateAnalyzed => 'Lebenslauf von KI ausgewertet';

  @override
  String get evCandidateCvUploaded => 'Lebenslauf hochgeladen';

  @override
  String get evCandidateProfileUpdated => 'Bewerberprofil geändert';

  @override
  String get evCandidateStatusChanged => 'Bewerbungsstatus geändert';

  @override
  String get evCandidateHired => 'Bewerber eingestellt';

  @override
  String get evInterviewScheduled => 'Interview geplant';

  @override
  String get evInterviewConfirmed => 'Interview bestätigt';

  @override
  String get evInterviewProposed => 'Anderer Interviewtermin vorgeschlagen';

  @override
  String get evPayslipIssued => 'Gehaltsabrechnung erstellt';

  @override
  String get evPayrollRunCompleted => 'Lohnlauf abgeschlossen';

  @override
  String get evPayrollRunFailed => 'Lohnlauf fehlgeschlagen';

  @override
  String get evPayrollRunNeedsAttention => 'Lohnlauf braucht Prüfung';

  @override
  String get evPayrollExpenseRecorded => 'Lohnkosten verbucht';

  @override
  String get evPayoutLogged => 'Auszahlung protokolliert';

  @override
  String get evSalaryAgreed => 'Einstiegsgehalt vereinbart';

  @override
  String get evSalaryRaised => 'Gehalt erhöht';

  @override
  String get evSalaryChanged => 'Grundgehalt von der Leitung geändert';

  @override
  String get evBonusGranted => 'Bonus gewährt';

  @override
  String get evPenaltyApplied => 'Abzug verhängt';

  @override
  String get evRaiseRequested => 'Gehaltserhöhung beantragt';

  @override
  String get evRaiseForwarded => 'Gehaltserhöhung weitergeleitet';

  @override
  String get evRaiseApproved => 'Gehaltserhöhung genehmigt';

  @override
  String get evRaiseRejected => 'Gehaltserhöhung abgelehnt';

  @override
  String get evRaiseReturned => 'Gehaltserhöhung zurückgegeben';

  @override
  String get evRaiseWithdrawn => 'Gehaltserhöhung zurückgezogen';

  @override
  String get evPromotionNominated => 'Beförderung vorgeschlagen';

  @override
  String get evPromotionApproved => 'Beförderung genehmigt';

  @override
  String get evPromotionRejected => 'Beförderung abgelehnt';

  @override
  String get evEmployeePromoted => 'Von der Leitung befördert';

  @override
  String get evPositionChanged => 'Position von der Leitung geändert';

  @override
  String get evPositionCreated => 'Position angelegt';

  @override
  String get evPositionUpdated => 'Position geändert';

  @override
  String get evPositionDeleted => 'Position gelöscht';

  @override
  String get evEmployeeHired => 'Mitarbeiter eingestellt';

  @override
  String get evEmployeeTransferred => 'Mitarbeiter versetzt';

  @override
  String get evEmployeeArchived => 'Mitarbeiter archiviert';

  @override
  String get evEmployeeRestored => 'Mitarbeiter wiederhergestellt';

  @override
  String get evDepartmentCreated => 'Abteilung gegründet';

  @override
  String get evDepartmentDissolved => 'Abteilung aufgelöst';

  @override
  String get evDepartmentHeadChanged => 'Abteilungsleitung geändert';

  @override
  String get evProfileChangeRequested => 'Profiländerung beantragt';

  @override
  String get evProfileChangeApproved => 'Profiländerung genehmigt';

  @override
  String get evProfileChangeRejected => 'Profiländerung abgelehnt';

  @override
  String get evResignationRequested => 'Kündigung eingereicht';

  @override
  String get evResignationApproved => 'Kündigung angenommen';

  @override
  String get evResignationRejected => 'Kündigung abgelehnt';

  @override
  String get evResignationWithdrawn => 'Kündigung zurückgezogen';

  @override
  String get evResignationCompleted => 'Austritt abgeschlossen';

  @override
  String get evReportSubmitted => 'Bericht eingereicht';

  @override
  String get evReportAcknowledged => 'Bericht bestätigt';

  @override
  String get evReportReturned => 'Bericht zurückgegeben';

  @override
  String get evProjectCreated => 'Projekt angelegt';

  @override
  String get evProjectProposed => 'Projekt vorgeschlagen';

  @override
  String get evProjectProposalApproved => 'Projektvorschlag genehmigt';

  @override
  String get evProjectProposalRejected => 'Projektvorschlag abgelehnt';

  @override
  String get evProjectProposalCountered => 'Projektvorschlag überarbeitet';

  @override
  String get evProjectAccepted => 'Projekt abgenommen';

  @override
  String get evProjectMembersRemoved => 'Mitglieder aus Projekt entfernt';

  @override
  String get evAcceptanceRevenueRecorded => 'Abnahmeumsatz verbucht';

  @override
  String get evMaterialPurchased => 'Material gekauft';

  @override
  String get evSupplierPaid => 'Lieferant bezahlt';

  @override
  String get evFinancePeriodClosed => 'Finanzperiode abgeschlossen';

  @override
  String get evAdminSqlRead => 'Admin: SQL-Abfrage (nur lesen)';

  @override
  String get evAdminSqlWrite => 'Admin: Daten per SQL geändert';

  @override
  String get evBackupCreated => 'Sicherung erstellt';

  @override
  String get evAccountChanged => 'Konto oder Rollen geändert';

  @override
  String nAuditLog(String event, String by) {
    return 'Neuer Protokolleintrag: $event$by';
  }

  @override
  String nAuditLogBy(String by) {
    return ' (von $by)';
  }

  @override
  String nPositionChanged(String position) {
    return 'Ihre Position ist jetzt $position';
  }

  @override
  String nSalaryChanged(String amount) {
    return 'Ihr neues Grundgehalt: $amount';
  }

  @override
  String nBonusGranted(String amount, String reason) {
    return 'Bonus von $amount: $reason';
  }

  @override
  String nPenaltyApplied(String amount, String reason) {
    return 'Abzug von $amount: $reason';
  }

  @override
  String get errProtectedDatabase =>
      'Die Admin-Protokolldatenbank ist hier gesperrt';

  @override
  String get errPastDate => 'Urlaub kann erst ab morgen beginnen';

  @override
  String get leaveAttach => 'Nachweis anhängen (Word, PDF, Bild)';

  @override
  String approvalsOthers(int n) {
    return 'Anträge von Mitarbeitenden ($n)';
  }

  @override
  String approvalsMine(int n) {
    return 'Ihre Anträge bei der Leitung ($n)';
  }

  @override
  String get requestMineTag => 'Ihrer';

  @override
  String get projectOverdue => 'Überfällig';
}
