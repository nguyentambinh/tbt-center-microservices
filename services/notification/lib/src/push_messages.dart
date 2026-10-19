/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

// Câu dài giữ nguyên như file .arb
// ignore_for_file: lines_longer_than_80_chars

import 'package:notification_service/src/domain/notification_rules.dart';

/// Câu đẩy theo ngôn ngữ, khớp chuỗi n... trong app (lib/l10n)
const _templates = <String, Map<String, String>>{
  'vi': {
    'payslip_issued': 'Phiếu lương kỳ {period} của bạn đã có',
    'payroll_needs_attention': 'Chốt lương kỳ {period} cần xử lý tay',
    'leave_requested': '{employee} xin nghỉ {days} ngày từ {date}',
    'leave_approved': 'Đơn nghỉ từ {date} đã được duyệt',
    'leave_rejected': 'Đơn nghỉ từ {date} bị từ chối',
    'overtime_requested': '{employee} xin tăng ca {hours} giờ ngày {date}',
    'overtime_approved': 'Đơn tăng ca ngày {date} đã được duyệt',
    'overtime_rejected': 'Đơn tăng ca ngày {date} bị từ chối',
    'candidate_applied': 'Có hồ sơ ứng tuyển mới: {position}',
    'candidate_status': 'Hồ sơ của bạn đã chuyển sang bước: {stage}',
    'payroll_paid': 'Lương kỳ {period} đã được chi',
    'payroll_failed': 'Chốt lương kỳ {period} bị lỗi, cần chạy lại',
    'finance_closed': 'Đã chốt sổ tài chính tháng {period}',
    'project_accepted':
        'Dự án {project} đã nghiệm thu, doanh thu đã ghi vào tài chính',
    '': 'Bạn có thông báo mới',
  },
  'en': {
    'payslip_issued': 'Your payslip for {period} is ready',
    'payroll_needs_attention': 'Payroll for {period} needs manual handling',
    'leave_requested': '{employee} requested {days} days of leave from {date}',
    'leave_approved': 'Your leave from {date} was approved',
    'leave_rejected': 'Your leave from {date} was rejected',
    'overtime_requested': '{employee} requested {hours} h overtime on {date}',
    'overtime_approved': 'Your overtime on {date} was approved',
    'overtime_rejected': 'Your overtime on {date} was rejected',
    'candidate_applied': 'New application: {position}',
    'candidate_status': 'Your application moved to: {stage}',
    'payroll_paid': 'Salary for {period} has been paid',
    'payroll_failed': 'Payroll for {period} failed and needs a retry',
    'finance_closed': 'Finance for {period} has been closed',
    'project_accepted':
        'Project {project} was accepted and its revenue recorded',
    '': 'You have a new notification',
  },
  'de': {
    'payslip_issued': 'Ihre Gehaltsabrechnung für {period} ist da',
    'payroll_needs_attention':
        'Lohnabrechnung {period} muss manuell bearbeitet werden',
    'leave_requested': '{employee} beantragt {days} Tage Urlaub ab {date}',
    'leave_approved': 'Ihr Urlaub ab {date} wurde genehmigt',
    'leave_rejected': 'Ihr Urlaub ab {date} wurde abgelehnt',
    'overtime_requested': '{employee} beantragt {hours} Überstunden am {date}',
    'overtime_approved': 'Ihre Überstunden am {date} wurden genehmigt',
    'overtime_rejected': 'Ihre Überstunden am {date} wurden abgelehnt',
    'candidate_applied': 'Neue Bewerbung: {position}',
    'candidate_status': 'Ihre Bewerbung ist jetzt: {stage}',
    'payroll_paid': 'Gehalt für {period} wurde ausgezahlt',
    'payroll_failed': 'Lohnlauf {period} fehlgeschlagen, bitte erneut starten',
    'finance_closed': 'Finanzen für {period} wurden abgeschlossen',
    'project_accepted': 'Projekt {project} wurde abgenommen, Umsatz gebucht',
    '': 'Sie haben eine neue Benachrichtigung',
  },
  'pt': {
    'payslip_issued': 'Seu holerite de {period} está disponível',
    'payroll_needs_attention':
        'A folha de {period} precisa de tratamento manual',
    'leave_requested':
        '{employee} pediu {days} dias de folga a partir de {date}',
    'leave_approved': 'Sua folga a partir de {date} foi aprovada',
    'leave_rejected': 'Sua folga a partir de {date} foi recusada',
    'overtime_requested': '{employee} pediu {hours} h extras em {date}',
    'overtime_approved': 'Suas horas extras em {date} foram aprovadas',
    'overtime_rejected': 'Suas horas extras em {date} foram recusadas',
    'candidate_applied': 'Nova candidatura: {position}',
    'candidate_status': 'Sua candidatura passou para: {stage}',
    'payroll_paid': 'O salário de {period} foi pago',
    'payroll_failed': 'A folha de {period} falhou, execute novamente',
    'finance_closed': 'As finanças de {period} foram fechadas',
    'project_accepted': 'Projeto {project} aceito, receita registrada',
    '': 'Você tem uma nova notificação',
  },
};

/// Tên bước tuyển dụng theo ngôn ngữ, khớp stage... trong app
const _stages = <String, Map<String, String>>{
  'vi': {
    'submitted': 'Đã nộp',
    'analyzed': 'AI đã tóm tắt',
    'screening': 'Đang sàng lọc',
    'interview': 'Phỏng vấn',
    'offered': 'Mời nhận việc',
    'hired': 'Đã nhận vào làm',
    'rejected': 'Chưa phù hợp',
  },
  'en': {
    'submitted': 'Submitted',
    'analyzed': 'AI summarised',
    'screening': 'Screening',
    'interview': 'Interview',
    'offered': 'Offer made',
    'hired': 'Hired',
    'rejected': 'Not selected',
  },
  'de': {
    'submitted': 'Eingereicht',
    'analyzed': 'KI-Zusammenfassung',
    'screening': 'Vorauswahl',
    'interview': 'Vorstellungsgespräch',
    'offered': 'Angebot',
    'hired': 'Eingestellt',
    'rejected': 'Absage',
  },
  'pt': {
    'submitted': 'Enviado',
    'analyzed': 'Resumido pela IA',
    'screening': 'Triagem',
    'interview': 'Entrevista',
    'offered': 'Proposta',
    'hired': 'Contratado',
    'rejected': 'Não selecionado',
  },
};

/// Tham số trong câu: {employee}, {days}, {date}...
Map<String, String> _values(Map<String, Object?> p, String language) => {
  'employee': '${p['employeeId'] ?? '-'}',
  'days': '${p['days'] ?? '-'}',
  'hours': '${p['hours'] ?? '-'}',
  'date': '${p['fromDate'] ?? p['workDate'] ?? '-'}',
  'position': '${p['appliedPosition'] ?? '-'}',
  'stage':
      (_stages[language] ?? _stages['en']!)[p['status']] ??
      '${p['status'] ?? '-'}',
  'period': '${p['period'] ?? '-'}',
  'project': '${p['projectId'] ?? '-'}',
};

/// Nội dung thông báo đẩy cho [language] (vi, en, de, pt; khác thì en)
({String title, String body}) pushText(NewNotification n, String language) {
  final lang = _templates[language] ?? _templates['en']!;
  var text = lang[n.kind] ?? lang['']!;
  for (final e in _values(n.params, language).entries) {
    text = text.replaceAll('{${e.key}}', e.value);
  }
  return (title: 'TBT Center', body: text);
}
