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
import 'package:tbt_common/tbt_common.dart';

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
    'project_proposed': 'Đề xuất dự án mới cần duyệt: {name}',
    'project_countered':
        'Ban lãnh đạo đã sửa đề xuất dự án {name}, cần bạn xác nhận',
    'project_approved': 'Dự án {name} đã được duyệt và tạo',
    'project_rejected': 'Đề xuất dự án {name} bị từ chối',
    'raise_requested': 'Có đề xuất tăng lương mới của {employee}',
    'raise_forwarded': 'HR chuyển đề xuất tăng lương của {employee} cần duyệt',
    'raise_approved': 'Đề xuất tăng lương của bạn đã được duyệt',
    'raise_rejected': 'Đề xuất tăng lương của bạn bị từ chối',
    'raise_returned': 'HR trả lại đề xuất tăng lương, mời bạn xem và sửa',
    'report_submitted': 'Có báo cáo {report} kỳ {period} gửi lên cần xác nhận',
    'report_acknowledged': 'Báo cáo {report} kỳ {period} đã được xác nhận',
    'report_returned': 'Báo cáo {report} kỳ {period} bị trả lại, xem ghi chú',
    'resignation_requested': '{employee} xin thôi việc, ngày làm cuối {date}',
    'resignation_approved': 'Đơn thôi việc của bạn đã được duyệt, ngày làm cuối {date}',
    'resignation_rejected': 'Đơn thôi việc của bạn không được duyệt',
    'audit_log': 'Có nhật ký mới trong sổ kiểm toán, mở để xem chi tiết',
    'position_changed': 'Chức vụ của bạn đã đổi thành {title}',
    'salary_changed': 'Lương cơ bản mới của bạn: {amount}',
    'bonus_granted': 'Bạn được thưởng {amount}',
    'penalty_applied': 'Bạn bị phạt {amount}',
    'resignation_withdrawn': '{employee} đã rút đơn thôi việc',
    'interview_scheduled':
        'Lịch phỏng vấn {position} lúc {time}, mở app để xác nhận',
    'interview_confirmed': 'Lịch phỏng vấn lúc {time} đã được xác nhận',
    'interview_confirmed_hr':
        'Ứng viên {position} đã chốt lịch phỏng vấn lúc {time}',
    'interview_proposed': 'Ứng viên {position} đề xuất phỏng vấn lúc {time}',
    'payroll_paid': 'Lương kỳ {period} đã được chi',
    'payroll_failed': 'Chốt lương kỳ {period} bị lỗi, cần chạy lại',
    'finance_closed': 'Đã chốt sổ tài chính tháng {period}',
    'project_accepted':
        'Dự án {project} đã nghiệm thu, doanh thu đã ghi vào tài chính',
    'profile_change_requested':
        'Có đề xuất sửa thông tin của {employee} cần duyệt',
    'profile_change_approved': 'Đề xuất sửa thông tin của bạn đã được duyệt',
    'profile_change_rejected': 'Đề xuất sửa thông tin của bạn bị từ chối',
    'promotion_nominated':
        '{employee} được đề cử lên {newPosition}, chờ Ban lãnh đạo duyệt',
    'promotion_approved': 'Chúc mừng! Bạn được thăng chức lên {newPosition}',
    'promotion_rejected': 'Đề cử thăng chức lên {newPosition} chưa được duyệt',
    'promotion_approved_hr': 'Ban lãnh đạo đã duyệt thăng chức cho {employee}',
    'promotion_rejected_hr':
        'Ban lãnh đạo không duyệt thăng chức cho {employee}',
    'employee_transferred': 'Bạn đã được điều chuyển sang phòng ban mới',
    'department_head_assigned': 'Bạn được giao làm trưởng phòng',
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
    'project_proposed': 'New project proposal to review: {name}',
    'project_countered':
        'Management edited the proposal {name}, please confirm',
    'project_approved': 'Project {name} was approved and created',
    'project_rejected': 'Project proposal {name} was rejected',
    'raise_requested': 'New raise request from {employee}',
    'raise_forwarded':
        'HR forwarded a raise request from {employee} for approval',
    'raise_approved': 'Your raise request was approved',
    'raise_rejected': 'Your raise request was rejected',
    'raise_returned': 'HR returned your raise request for changes',
    'report_submitted': 'New {report} report for {period} to confirm',
    'report_acknowledged': '{report} report for {period} was confirmed',
    'report_returned':
        '{report} report for {period} was returned, see the note',
    'resignation_requested': '{employee} resigned, last working day {date}',
    'resignation_approved': 'Your resignation was approved, last day {date}',
    'resignation_rejected': 'Your resignation was not approved',
    'audit_log': 'New entry in the audit log, open it for details',
    'position_changed': 'Your position is now {title}',
    'salary_changed': 'Your new base salary: {amount}',
    'bonus_granted': 'You received a bonus of {amount}',
    'penalty_applied': 'A penalty of {amount} was applied',
    'resignation_withdrawn': '{employee} withdrew their resignation',
    'interview_scheduled':
        'Interview for {position} at {time}, open the app to confirm',
    'interview_confirmed': 'Your interview at {time} is confirmed',
    'interview_confirmed_hr': 'Interview for {position} at {time} is confirmed',
    'interview_proposed': 'Candidate for {position} proposed {time}',
    'payroll_paid': 'Salary for {period} has been paid',
    'payroll_failed': 'Payroll for {period} failed and needs a retry',
    'finance_closed': 'Finance for {period} has been closed',
    'project_accepted':
        'Project {project} was accepted and its revenue recorded',
    'profile_change_requested': '{employee} asked to update their profile',
    'profile_change_approved': 'Your profile update was approved',
    'profile_change_rejected': 'Your profile update was rejected',
    'promotion_nominated':
        '{employee} was nominated for {newPosition}, awaiting executives',
    'promotion_approved': 'Congratulations! You were promoted to {newPosition}',
    'promotion_rejected': 'Your promotion to {newPosition} was not approved',
    'promotion_approved_hr': 'Executives approved the promotion of {employee}',
    'promotion_rejected_hr': 'Executives rejected the promotion of {employee}',
    'employee_transferred': 'You were moved to a new department',
    'department_head_assigned': 'You are now head of your department',
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
    'project_proposed': 'Neuer Projektvorschlag zur Prüfung: {name}',
    'project_countered':
        'Die Leitung hat den Vorschlag {name} geändert, bitte bestätigen',
    'project_approved': 'Projekt {name} wurde genehmigt und angelegt',
    'project_rejected': 'Projektvorschlag {name} wurde abgelehnt',
    'raise_requested': 'Neuer Gehaltswunsch von {employee}',
    'raise_forwarded': 'HR hat den Gehaltswunsch von {employee} zur Genehmigung weitergeleitet',
    'raise_approved': 'Ihr Gehaltswunsch wurde genehmigt',
    'raise_rejected': 'Ihr Gehaltswunsch wurde abgelehnt',
    'raise_returned':
        'HR hat Ihren Gehaltswunsch zur Überarbeitung zurückgegeben',
    'report_submitted': 'Neuer Bericht {report} für {period} zur Bestätigung',
    'report_acknowledged': 'Bericht {report} für {period} wurde bestätigt',
    'report_returned': 'Bericht {report} für {period} wurde zurückgegeben',
    'resignation_requested': '{employee} hat gekündigt, letzter Arbeitstag {date}',
    'resignation_approved': 'Ihre Kündigung wurde bestätigt, letzter Tag {date}',
    'resignation_rejected': 'Ihre Kündigung wurde nicht bestätigt',
    'audit_log': 'Neuer Eintrag im Prüfprotokoll, für Details öffnen',
    'position_changed': 'Ihre Position ist jetzt {title}',
    'salary_changed': 'Ihr neues Grundgehalt: {amount}',
    'bonus_granted': 'Sie erhalten einen Bonus von {amount}',
    'penalty_applied': 'Ein Abzug von {amount} wurde verhängt',
    'resignation_withdrawn': '{employee} hat die Kündigung zurückgezogen',
    'interview_scheduled':
        'Gespräch für {position} am {time}, bitte in der App bestätigen',
    'interview_confirmed': 'Ihr Gespräch am {time} ist bestätigt',
    'interview_confirmed_hr': 'Gespräch für {position} am {time} ist bestätigt',
    'interview_proposed': 'Bewerber für {position} schlägt {time} vor',
    'payroll_paid': 'Gehalt für {period} wurde ausgezahlt',
    'payroll_failed': 'Lohnlauf {period} fehlgeschlagen, bitte erneut starten',
    'finance_closed': 'Finanzen für {period} wurden abgeschlossen',
    'project_accepted': 'Projekt {project} wurde abgenommen, Umsatz gebucht',
    'profile_change_requested': '{employee} möchte das Profil ändern',
    'profile_change_approved': 'Ihre Profiländerung wurde genehmigt',
    'profile_change_rejected': 'Ihre Profiländerung wurde abgelehnt',
    'promotion_nominated':
        '{employee} wurde für {newPosition} nominiert, Freigabe ausstehend',
    'promotion_approved': 'Glückwunsch! Sie wurden zu {newPosition} befördert',
    'promotion_rejected':
        'Die Beförderung zu {newPosition} wurde nicht genehmigt',
    'promotion_approved_hr':
        'Die Geschäftsleitung hat die Beförderung von {employee} genehmigt',
    'promotion_rejected_hr':
        'Die Geschäftsleitung hat die Beförderung von {employee} abgelehnt',
    'employee_transferred': 'Sie wurden in eine neue Abteilung versetzt',
    'department_head_assigned': 'Sie leiten jetzt Ihre Abteilung',
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
    'project_proposed': 'Nova proposta de projeto para revisar: {name}',
    'project_countered': 'A diretoria alterou a proposta {name}, confirme',
    'project_approved': 'Projeto {name} aprovado e criado',
    'project_rejected': 'Proposta de projeto {name} recusada',
    'raise_requested': 'Novo pedido de aumento de {employee}',
    'raise_forwarded':
        'O RH encaminhou o pedido de aumento de {employee} para aprovação',
    'raise_approved': 'Seu pedido de aumento foi aprovado',
    'raise_rejected': 'Seu pedido de aumento foi recusado',
    'raise_returned': 'O RH devolveu seu pedido de aumento para ajustes',
    'report_submitted': 'Novo relatório {report} de {period} para confirmar',
    'report_acknowledged': 'Relatório {report} de {period} confirmado',
    'report_returned': 'Relatório {report} de {period} devolvido, veja a nota',
    'resignation_requested': '{employee} pediu demissão, último dia {date}',
    'resignation_approved': 'Seu pedido de demissão foi aprovado, último dia {date}',
    'resignation_rejected': 'Seu pedido de demissão não foi aprovado',
    'audit_log': 'Novo registro na auditoria, abra para ver',
    'position_changed': 'Seu cargo agora é {title}',
    'salary_changed': 'Seu novo salário base: {amount}',
    'bonus_granted': 'Você recebeu um bônus de {amount}',
    'penalty_applied': 'Foi aplicada uma penalidade de {amount}',
    'resignation_withdrawn': '{employee} retirou o pedido de demissão',
    'interview_scheduled':
        'Entrevista para {position} em {time}, confirme no app',
    'interview_confirmed': 'Sua entrevista em {time} está confirmada',
    'interview_confirmed_hr': 'Entrevista para {position} em {time} confirmada',
    'interview_proposed': 'Candidato a {position} sugeriu {time}',
    'payroll_paid': 'O salário de {period} foi pago',
    'payroll_failed': 'A folha de {period} falhou, execute novamente',
    'finance_closed': 'As finanças de {period} foram fechadas',
    'project_accepted': 'Projeto {project} aceito, receita registrada',
    'profile_change_requested': '{employee} pediu para atualizar o perfil',
    'profile_change_approved': 'A atualização do seu perfil foi aprovada',
    'profile_change_rejected': 'A atualização do seu perfil foi recusada',
    'promotion_nominated':
        '{employee} foi indicado para {newPosition}, aguardando a diretoria',
    'promotion_approved': 'Parabéns! Você foi promovido a {newPosition}',
    'promotion_rejected': 'A promoção para {newPosition} não foi aprovada',
    'promotion_approved_hr': 'A diretoria aprovou a promoção de {employee}',
    'promotion_rejected_hr': 'A diretoria recusou a promoção de {employee}',
    'employee_transferred': 'Você foi transferido para um novo departamento',
    'department_head_assigned': 'Agora você chefia o seu departamento',
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
    'interviewed': 'Đã phỏng vấn',
    'hired': 'Đã nhận vào làm',
    'rejected': 'Chưa phù hợp',
  },
  'en': {
    'submitted': 'Submitted',
    'analyzed': 'AI summarised',
    'screening': 'Screening',
    'interview': 'Interview',
    'interviewed': 'Interviewed',
    'hired': 'Hired',
    'rejected': 'Not selected',
  },
  'de': {
    'submitted': 'Eingereicht',
    'analyzed': 'KI-Zusammenfassung',
    'screening': 'Vorauswahl',
    'interview': 'Vorstellungsgespräch',
    'interviewed': 'Gespräch geführt',
    'hired': 'Eingestellt',
    'rejected': 'Absage',
  },
  'pt': {
    'submitted': 'Enviado',
    'analyzed': 'Resumido pela IA',
    'screening': 'Triagem',
    'interview': 'Entrevista',
    'interviewed': 'Entrevistado',
    'hired': 'Contratado',
    'rejected': 'Não selecionado',
  },
};

/// Tên mảng báo cáo gửi cấp trên
const _reportKinds = {
  'vi': {'hr': 'nhân sự', 'finance': 'tài chính'},
  'en': {'hr': 'HR', 'finance': 'finance'},
  'de': {'hr': 'Personal', 'finance': 'Finanzen'},
  'pt': {'hr': 'RH', 'finance': 'financeiro'},
};

/// Tham số trong câu: {employee}, {days}, {date}...
Map<String, String> _values(Map<String, Object?> p, String language) => {
  'employee': '${p['employeeId'] ?? '-'}',
  'days': '${p['days'] ?? '-'}',
  'hours': '${p['hours'] ?? '-'}',
  'date': '${p['fromDate'] ?? p['workDate'] ?? p['lastDay'] ?? '-'}',
  'position': '${p['appliedPosition'] ?? '-'}',
  'stage':
      (_stages[language] ?? _stages['en']!)[p['status']] ??
      '${p['status'] ?? '-'}',
  'period': '${p['period'] ?? '-'}',
  'project': '${p['projectId'] ?? '-'}',
  'name': '${p['name'] ?? '-'}',
  'report':
      _reportKinds[language]?[p['reportKind']] ?? '${p['reportKind'] ?? '-'}',
  'newPosition': '${p['proposedPosition'] ?? '-'}',
  'title': '${p['position'] ?? '-'}',
  'amount': '${p['amount'] ?? '-'} ${p['currency'] ?? ''}'.trim(),
  'time': switch (DateTime.tryParse('${p['scheduledAt']}')) {
    final at? => formatRegionTime(at, '${p['countryCode'] ?? ''}'),
    null => '-',
  },
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
