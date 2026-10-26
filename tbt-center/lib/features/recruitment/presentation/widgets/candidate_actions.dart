/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/error/error_reporter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/candidate.dart';
import '../providers/candidate_providers.dart';
import 'interview_widgets.dart';
import '../../../../core/widgets/input_rules.dart';

/// Thao tác của HR theo bước: chỉ đi tới, phỏng vấn xong (có biên bản) mới nhận việc
class CandidateActions extends ConsumerStatefulWidget {
  const CandidateActions({super.key, required this.candidate});

  final Candidate candidate;

  @override
  ConsumerState<CandidateActions> createState() => _CandidateActionsState();
}

class _CandidateActionsState extends ConsumerState<CandidateActions> {
  bool _busy = false;

  Candidate get _c => widget.candidate;

  Future<void> _run(Future<Candidate> Function() action, String done) async {
    setState(() => _busy = true);
    try {
      await action();
      ref
        ..invalidate(candidateDetailProvider(_c.id))
        ..invalidate(candidateListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(done), behavior: SnackBarBehavior.floating));
      }
    } on Object catch (e) {
      reportFailure(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _confirm(String title, String message, {bool danger = false}) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          FilledButton(
            style: danger ? FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error) : null,
            onPressed: () => Navigator.pop(context, true),
            child: Text(title),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _reject() async {
    final l10n = AppLocalizations.of(context);
    if (!await _confirm(l10n.rejectCandidate, l10n.rejectCandidateHint(_c.fullName), danger: true)) return;
    final repo = ref.read(candidateRepositoryProvider);
    final interviewOpen = _c.status == 'interview' && !(_c.interview?.cancelled ?? true);
    await _run(
      () => interviewOpen ? repo.respondInterview(_c.id, action: 'decline') : repo.changeStage(_c.id, status: 'rejected'),
      l10n.statusChanged,
    );
  }

  Future<void> _schedule() async {
    final l10n = AppLocalizations.of(context);
    final picked = await showInterviewDialog(context, title: l10n.scheduleInterview, askLocation: true, location: _c.interview?.location);
    if (picked == null) return;
    await _run(
      () => ref.read(candidateRepositoryProvider).scheduleInterview(_c.id, at: picked.at, location: picked.location, note: picked.note),
      l10n.interviewSent,
    );
  }

  Future<void> _propose() async {
    final l10n = AppLocalizations.of(context);
    final picked = await showInterviewDialog(context, title: l10n.proposeOtherTime, initial: _c.interview?.scheduledAt);
    if (picked == null) return;
    await _run(
      () => ref.read(candidateRepositoryProvider).respondInterview(_c.id, action: 'propose', at: picked.at, note: picked.note),
      l10n.interviewSent,
    );
  }

  Future<void> _uploadMinutes() async {
    final l10n = AppLocalizations.of(context);
    final picked = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: const ['doc', 'docx', 'xls', 'xlsx']);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    await _run(
      () => ref.read(candidateRepositoryProvider).uploadMinutes(_c.id, fileName: picked.name, bytes: bytes),
      l10n.minutesUploaded,
    );
  }

  Future<void> _openMinutes() async {
    try {
      final url = await ref.read(candidateRepositoryProvider).minutesUrl(_c.id);
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } on Object catch (e) {
      reportFailure(e);
    }
  }

  Future<void> _hire() async {
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    final OfferSuggestion suggestion;
    try {
      suggestion = await ref.read(candidateRepositoryProvider).offerSuggestion(_c.id, language: language);
    } on Object catch (e) {
      reportFailure(e);
      return;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (!mounted) return;
    final offer = await showDialog<HireOffer>(context: context, builder: (_) => _OfferDialog(candidate: _c, suggestion: suggestion));
    if (offer == null || !mounted) return;
    setState(() => _busy = true);
    final HireResult result;
    try {
      result = await ref.read(candidateRepositoryProvider).hire(_c.id, offer: offer);
    } on Object catch (e) {
      reportFailure(e);
      return;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    ref
      ..invalidate(candidateDetailProvider(_c.id))
      ..invalidate(candidateListProvider);
    if (!navigator.mounted) return;
    await showDialog<void>(
      context: navigator.context,
      builder: (context) => AlertDialog(
        title: Text(l10n.hiredTitle(result.employeeId)),
        content: SelectableText(
          [
            l10n.hiredLogin(result.login),
            if (result.temporaryPassword case final password?) l10n.hiredTempPassword(password) else l10n.hiredKeepPassword,
            if (!result.salarySet && offer.baseSalary != null) l10n.hiredSalaryPending,
            l10n.hiredRelogin,
          ].join('\n\n'),
        ),
        actions: [FilledButton(onPressed: () => Navigator.pop(context), child: Text(l10n.close))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(candidateRepositoryProvider);
    final interview = _c.interview;
    final reject = OutlinedButton.icon(
      onPressed: _busy ? null : _reject,
      icon: const Icon(Icons.block),
      label: Text(l10n.rejectCandidate),
      style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
    );
    final buttons = <Widget>[
      ...switch (_c.status) {
        'submitted' || 'analyzed' => [
            FilledButton.icon(
              onPressed: _busy ? null : () => _run(() => repo.changeStage(_c.id, status: 'screening'), l10n.statusChanged),
              icon: const Icon(Icons.filter_alt_outlined),
              label: Text(l10n.moveToScreening),
            ),
            reject,
          ],
        'screening' => [
            FilledButton.icon(onPressed: _busy ? null : _schedule, icon: const Icon(Icons.event), label: Text(l10n.scheduleInterview)),
            reject,
          ],
        'interview' when interview == null || interview.cancelled => [
            FilledButton.icon(onPressed: _busy ? null : _schedule, icon: const Icon(Icons.event_repeat), label: Text(l10n.scheduleAgain)),
            reject,
          ],
        'interview' => [
            if (interview!.state == 'awaiting_hr' && interview.held) Text(l10n.interviewTimePassed, style: TextStyle(color: context.tbt.warning)),
            if (interview.state == 'awaiting_hr' && !interview.held)
              FilledButton.icon(
                onPressed: _busy ? null : () => _run(() => repo.respondInterview(_c.id, action: 'confirm'), l10n.interviewConfirmedDone),
                icon: const Icon(Icons.check),
                label: Text(l10n.confirmTime),
              ),
            if (interview.confirmed)
              FilledButton.icon(
                onPressed: _busy || !interview.held ? null : _uploadMinutes,
                icon: const Icon(Icons.upload_file),
                label: Text(l10n.uploadMinutes),
              ),
            if (!interview.confirmed) OutlinedButton.icon(onPressed: _busy ? null : _propose, icon: const Icon(Icons.schedule), label: Text(l10n.proposeOtherTime)),
            reject,
          ],
        'interviewed' => [
            FilledButton.icon(
              onPressed: _busy ? null : _hire,
              icon: _busy ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.how_to_reg),
              label: Text(l10n.hireCandidate),
            ),
            OutlinedButton.icon(onPressed: _openMinutes, icon: const Icon(Icons.description_outlined), label: Text(l10n.openMinutes)),
            reject,
          ],
        'rejected' => [
            OutlinedButton.icon(
              onPressed: _busy ? null : () => _run(() => repo.reconsider(_c.id), l10n.reconsidered),
              icon: const Icon(Icons.restore),
              label: Text(l10n.reconsider),
            ),
          ],
        _ => const <Widget>[],
      },
    ];
    final hint = switch (_c.status) {
      'interview' when interview != null && interview.confirmed && !interview.held => l10n.minutesAfterInterview,
      'interview' when interview?.state == 'awaiting_candidate' => l10n.waitingCandidateReply,
      _ => null,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (interview != null && (_c.status == 'interview' || _c.status == 'interviewed')) InterviewCard(interview: interview),
        if (buttons.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: buttons),
        ],
        if (hint != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(hint, style: TextStyle(color: context.tbt.textSecondary))),
      ],
    );
  }
}

/// Hộp xác nhận nhận việc: AI gợi ý phòng ban, lương; HR sửa trước khi chốt
class _OfferDialog extends StatefulWidget {
  const _OfferDialog({required this.candidate, required this.suggestion});

  final Candidate candidate;
  final OfferSuggestion suggestion;

  @override
  State<_OfferDialog> createState() => _OfferDialogState();
}

class _OfferDialogState extends State<_OfferDialog> {
  late String? _department = widget.suggestion.departmentId;
  late final _salary = TextEditingController(text: widget.suggestion.baseSalary == null ? '' : NumberFormat('#0').format(widget.suggestion.baseSalary));
  late final _currency = TextEditingController(text: widget.suggestion.currency ?? '');

  @override
  void dispose() {
    _salary.dispose();
    _currency.dispose();
    super.dispose();
  }

  double? get _amount => double.tryParse(_salary.text.replaceAll(RegExp(r'[^0-9.]'), ''));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = widget.suggestion;
    final reason = switch (s.reason) {
      'peer_median' => l10n.offerPeerMedian,
      'region_median' => l10n.offerRegionMedian,
      final other => other,
    };
    final valid = _amount != null && _amount! > 0 && _currency.text.trim().length == 3;
    return AlertDialog(
      title: Text(l10n.hireCandidate),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.hireConfirm(widget.candidate.fullName, widget.candidate.email ?? '')),
            const SizedBox(height: 12),
            if (reason != null && reason.isNotEmpty)
              Card(
                child: ListTile(
                  leading: Icon(s.fromAi ? Icons.auto_awesome : Icons.calculate_outlined, color: context.tbt.brandGold),
                  title: Text(s.fromAi ? l10n.offerFromAi : l10n.offerFromRules),
                  subtitle: Text(reason),
                ),
              ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: s.departments.any((d) => d.id == _department) ? _department : null,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.departments),
              items: [
                for (final d in s.departments)
                  DropdownMenuItem(value: d.id, child: Text([d.name, d.company].whereType<String>().join(' · '), overflow: TextOverflow.ellipsis)),
              ],
              onChanged: (v) => setState(() => _department = v),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    inputFormatters: InputRules.decimal,
                    controller: _salary,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.agreedSalary),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    inputFormatters: InputRules.currency,
                    controller: _currency,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(labelText: l10n.currency, counterText: ''),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(
          onPressed: valid
              ? () => Navigator.pop(context, HireOffer(departmentId: _department, baseSalary: _amount, currency: _currency.text.trim().toUpperCase()))
              : null,
          child: Text(l10n.hireCandidate),
        ),
      ],
    );
  }
}
