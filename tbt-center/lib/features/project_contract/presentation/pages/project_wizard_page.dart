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
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/config/env.dart';
import '../../../../core/error/error_reporter.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/proposal.dart';
import '../providers/project_providers.dart';
import '../widgets/project_widgets.dart';
import '../widgets/proposal_form.dart';

/// Tạo dự án theo từng bước: tải hợp đồng, ảnh; AI đọc hợp đồng; chọn nhân viên; gửi Ban lãnh đạo
class ProjectWizardPage extends ConsumerStatefulWidget {
  const ProjectWizardPage({super.key});

  @override
  ConsumerState<ProjectWizardPage> createState() => _ProjectWizardPageState();
}

class _ProjectWizardPageState extends ConsumerState<ProjectWizardPage> {
  int _step = 0;
  bool _busy = false;
  late ProposalData _data = ProposalData(currency: Env.currencyOf(ref.read(authControllerProvider).value?.region));
  ({String key, String name})? _contract;
  ({String key, String name})? _image;
  String? _extractSource;
  MemberSuggestion? _suggestion;

  /// Đổi khóa form khi AI điền dữ liệu, để các ô nhận giá trị mới
  int _formVersion = 0;

  Future<void> _busyRun(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } on Object catch (e) {
      reportFailure(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pick(String kind) async {
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: kind == 'contract' ? const ['pdf', 'docx'] : const ['jpg', 'jpeg', 'png'],
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    await _busyRun(() async {
      final key = await ref.read(projectRepositoryProvider).uploadFile(kind: kind, fileName: picked.name, bytes: bytes);
      setState(() => kind == 'contract' ? _contract = (key: key, name: picked.name) : _image = (key: key, name: picked.name));
      if (kind == 'contract') await _extract();
    });
  }

  Future<void> _extract() async {
    final contract = _contract;
    if (contract == null) return;
    final result = await ref.read(projectRepositoryProvider).extract(objectKey: contract.key, fileName: contract.name);
    setState(() {
      _data = _data.fillFrom(result.fields);
      _extractSource = result.source;
      _formVersion++;
    });
  }

  Future<void> _suggest() async {
    final language = Localizations.localeOf(context).languageCode;
    await _busyRun(() async {
      final s = await ref.read(projectRepositoryProvider).suggestMembers(_data, language: language);
      setState(() {
        _suggestion = s;
        _data = _data.withMembers(s.memberIds);
      });
    });
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    await _busyRun(() async {
      await ref.read(projectRepositoryProvider).propose(_data, contractKey: _contract?.key, contractName: _contract?.name, imageKey: _image?.key);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.proposalSent), behavior: SnackBarBehavior.floating));
      context.pushReplacement(Routes.projectProposals);
    });
  }

  List<String> get _errors => _data.errors(rateToUsd: rateToUsd(_data.currency));

  bool get _infoValid => _errors.where((e) => e != 'too_few_members').isEmpty;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final steps = [
      Step(title: Text(l10n.wizardFiles), isActive: _step >= 0, state: _contract == null ? StepState.indexed : StepState.complete, content: _filesStep(l10n)),
      Step(title: Text(l10n.wizardInfo), isActive: _step >= 1, content: ProposalForm(key: ValueKey(_formVersion), initial: _data, onChanged: (d) => setState(() => _data = d))),
      Step(title: Text(l10n.wizardMembers), isActive: _step >= 2, content: _membersStep(l10n)),
      Step(title: Text(l10n.wizardSend), isActive: _step >= 3, content: _reviewStep(l10n)),
    ];
    // Bước 1 bắt buộc có hợp đồng (AI đọc ra các ô), không nhập tay từ đầu
    final canNext = switch (_step) {
      0 => _contract != null,
      1 => _infoValid,
      2 => _errors.isEmpty,
      _ => _errors.isEmpty,
    };
    return Scaffold(
      appBar: AppBar(title: Text(l10n.projectNew)),
      body: Stepper(
        currentStep: _step,
        steps: steps,
        // Làm tuần tự: chỉ quay lại bước trước, hoặc sang đúng bước kế khi bước này đã xong
        onStepTapped: (i) => setState(() => _step = i < _step || (i == _step + 1 && canNext) ? i : _step),
        onStepCancel: _step == 0 ? null : () => setState(() => _step--),
        onStepContinue: _busy || !canNext ? null : () => _step == steps.length - 1 ? _submit() : setState(() => _step++),
        controlsBuilder: (context, details) => Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            children: [
              FilledButton(
                onPressed: details.onStepContinue,
                child: _busy
                    ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_step == steps.length - 1 ? l10n.sendToExecutive : l10n.next),
              ),
              const SizedBox(width: 8),
              if (details.onStepCancel != null) TextButton(onPressed: details.onStepCancel, child: Text(l10n.back)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filesStep(AppLocalizations l10n) {
    final source = _extractSource;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.wizardFilesHint, style: TextStyle(color: context.tbt.textSecondary)),
        const SizedBox(height: 8),
        if (Env.filesUrl.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => launchUrl(Uri.parse(Env.contractTemplateUrl), mode: LaunchMode.externalApplication),
            icon: const Icon(Icons.download_outlined),
            label: Text(l10n.downloadContractTemplate),
          ),
        ),
        OutlinedButton.icon(
          onPressed: _busy ? null : () => _pick('contract'),
          icon: Icon(_contract == null ? Icons.upload_file : Icons.description),
          label: Text(_contract?.name ?? l10n.uploadContract),
        ),
        if (_contract == null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(l10n.contractRequired, style: TextStyle(color: context.tbt.caution, fontSize: 12))),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _busy ? null : () => _pick('image'),
          icon: Icon(_image == null ? Icons.add_photo_alternate_outlined : Icons.image),
          label: Text(_image?.name ?? l10n.uploadProjectImage),
        ),
        if (source != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(source == 'manual' ? Icons.edit_note : Icons.auto_awesome, color: context.tbt.brandGold),
              const SizedBox(width: 8),
              Expanded(child: Text(source == 'manual' ? l10n.contractReadManual : l10n.contractReadByAi)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _membersStep(AppLocalizations l10n) {
    final s = _suggestion;
    final tier = _data.value == null ? 1 : projectTier(_data.value! / rateToUsd(_data.currency));
    final selected = _data.memberIds.toSet();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.membersNeeded(tierMinMembers[tier]!, selected.length), style: TextStyle(color: selected.length < tierMinMembers[tier]! ? Theme.of(context).colorScheme.error : context.tbt.success)),
        const SizedBox(height: 8),
        FilledButton.tonalIcon(onPressed: _busy ? null : _suggest, icon: const Icon(Icons.auto_awesome), label: Text(l10n.suggestMembers)),
        if (s?.reason case final reason? when reason.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(reason, style: TextStyle(color: context.tbt.textSecondary))),
        if (s != null)
          SizedBox(
            height: 320,
            child: ListView(
              children: [
                for (final e in [...s.employees]..sort((a, b) => (selected.contains(b.id) ? 1 : 0).compareTo(selected.contains(a.id) ? 1 : 0)))
                  CheckboxListTile(
                    value: selected.contains(e.id),
                    dense: true,
                    title: Text(e.name),
                    subtitle: Text([e.position, l10n.activeProjects(e.activeProjects)].whereType<String>().join(' · ')),
                    onChanged: (v) => setState(() => _data = _data.withMembers(v == true ? [..._data.memberIds, e.id] : [..._data.memberIds]..remove(e.id))),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _reviewStep(AppLocalizations l10n) {
    final days = DateFormat.yMMMd(Localizations.localeOf(context).toString());
    final money = NumberFormat.decimalPattern(Localizations.localeOf(context).toString());
    final d = _data;
    final tier = d.value == null ? 1 : projectTier(d.value! / rateToUsd(d.currency));
    String day(DateTime? v) => v == null ? '—' : days.format(v);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(d.name ?? '', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        Text(d.customerName ?? ''),
        const SizedBox(height: 6),
        TagChip(label: tierLabel(l10n, tier), color: context.tbt.brandGold, icon: Icons.layers_outlined),
        const SizedBox(height: 6),
        Text('${l10n.contractValue}: ${d.value == null ? '—' : money.format(d.value)} ${d.currency ?? ''}'),
        Text('${day(d.startDate)} → ${day(d.endDate)} · ${l10n.acceptanceDate}: ${day(d.acceptanceDate)}'),
        Text(l10n.employeesCount(d.memberIds.length)),
        if (_contract != null) Text(l10n.minutesAttached(_contract!.name)),
        for (final e in _errors) Text('• ${proposalErrorText(l10n, e)}', style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
      ],
    );
  }
}
