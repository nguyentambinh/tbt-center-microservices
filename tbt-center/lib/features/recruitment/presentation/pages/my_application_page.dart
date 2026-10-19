/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/error/error_reporter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/candidate.dart';
import '../providers/candidate_providers.dart';
import '../widgets/stage_widgets.dart';

/// Màn của ứng viên: chưa nộp thì hiện form, đã nộp thì hiện hồ sơ và tiến trình.
class MyApplicationPage extends ConsumerStatefulWidget {
  const MyApplicationPage({super.key});

  @override
  ConsumerState<MyApplicationPage> createState() => _MyApplicationPageState();
}

class _MyApplicationPageState extends ConsumerState<MyApplicationPage> {
  bool _editing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final application = ref.watch(myApplicationProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myApplication)),
      body: switch (application) {
        AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(myApplicationProvider)),
        AsyncValue(hasValue: true, :final value) when value == null || _editing => _ApplicationForm(
            current: value,
            onSaved: () => setState(() => _editing = false),
          ),
        AsyncValue(:final value?) => _ApplicationView(candidate: value, onEdit: () => setState(() => _editing = true)),
        _ => const SkeletonList(),
      },
    );
  }
}

class _ApplicationView extends StatelessWidget {
  const _ApplicationView({required this.candidate, required this.onEdit});

  final Candidate candidate;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(child: Text(candidate.fullName, style: text.headlineSmall)),
            StageChip(candidate.status),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          [candidate.appliedPosition, candidate.email, candidate.phone].whereType<String>().join(' · '),
          style: TextStyle(color: context.tbt.textSecondary),
        ),
        const SizedBox(height: 16),
        if (candidate.editable)
          OutlinedButton.icon(onPressed: onEdit, icon: const Icon(Icons.edit_outlined), label: Text(l10n.editProfile))
        else
          Text(l10n.profileLockedHint, style: TextStyle(color: context.tbt.textSecondary)),
        const SizedBox(height: 16),
        _CvCard(candidate: candidate),
        const Divider(height: 32),
        Text(l10n.progress, style: text.titleLarge),
        StageTimeline(history: candidate.history),
      ],
    );
  }
}


class _CvCard extends ConsumerStatefulWidget {
  const _CvCard({required this.candidate});

  final Candidate candidate;

  @override
  ConsumerState<_CvCard> createState() => _CvCardState();
}

class _CvCardState extends ConsumerState<_CvCard> {
  bool _uploading = false;

  Future<void> _pickAndUpload() async {
    final l10n = AppLocalizations.of(context);
    final picked = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: const ['pdf']);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();

    setState(() => _uploading = true);
    try {
      await ref.read(candidateRepositoryProvider).uploadCv(bytes);
      ref.invalidate(myApplicationProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.cvUploaded), behavior: SnackBarBehavior.floating),
        );
      }
    } on Object catch (e) {
      reportFailure(e);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = widget.candidate;
    final waitingForAi = c.hasCv && c.consentAi && c.status == 'submitted';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(c.hasCv ? Icons.description : Icons.upload_file, color: context.tbt.brandGold),
                const SizedBox(width: 8),
                Text(c.hasCv ? l10n.cvAttached : l10n.cvNone, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            if (waitingForAi) ...[
              const SizedBox(height: 8),
              Text(l10n.cvWaitingAi, style: TextStyle(color: context.tbt.textSecondary)),
            ],
            if (c.editable) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _uploading ? null : _pickAndUpload,
                icon: _uploading
                    ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.upload),
                label: Text(c.hasCv ? l10n.replaceCv : l10n.uploadCv),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ApplicationForm extends ConsumerStatefulWidget {
  const _ApplicationForm({required this.current, required this.onSaved});

  final Candidate? current;
  final VoidCallback onSaved;

  @override
  ConsumerState<_ApplicationForm> createState() => _ApplicationFormState();
}

class _ApplicationFormState extends ConsumerState<_ApplicationForm> {
  late final _name = TextEditingController(text: widget.current?.fullName);
  late final _email = TextEditingController(text: widget.current?.email);
  late final _phone = TextEditingController(text: widget.current?.phone);
  late final _position = TextEditingController(text: widget.current?.appliedPosition);
  late bool _consent = widget.current?.consentAi ?? false;
  bool _saving = false;
  String? _error;

  /// CV chọn ngay trong form, tải lên sau khi lưu hồ sơ (cần hồ sơ trước).
  ({String name, List<int> bytes})? _cv;

  /// Server cũng chặn trên 10 MB; báo sớm để khỏi tải lên vô ích.
  static const _maxCvBytes = 10 * 1024 * 1024;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _position]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickCv() async {
    final picked = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: const ['pdf']);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    if (bytes.length > _maxCvBytes) {
      setState(() => _error = AppLocalizations.of(context).errCvTooLarge);
      return;
    }
    setState(() {
      _cv = (name: picked.name, bytes: bytes);
      _error = null;
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(candidateRepositoryProvider).saveMyApplication(CandidateInput(
            fullName: _name.text.trim(),
            email: _email.text.trim(),
            phone: _phone.text.trim(),
            appliedPosition: _position.text.trim(),
            consentAi: _consent,
          ));
      if (_cv case final cv?) {
        await ref.read(candidateRepositoryProvider).uploadCv(cv.bytes);
      }
      ref.invalidate(myApplicationProvider);
      widget.onSaved();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.profileSaved), behavior: SnackBarBehavior.floating),
        );
      }
    } on AppFailure catch (e) {
      setState(() => _error = e.message(l10n));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    InputDecoration field(String label) => InputDecoration(labelText: label, border: const OutlineInputBorder());

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (widget.current == null) ...[
          EmptyView(message: l10n.notAppliedYet, icon: Icons.work_outline),
          const SizedBox(height: 16),
        ],
        TextField(controller: _name, decoration: field(l10n.fullName), onChanged: (_) => setState(() {})),
        const SizedBox(height: 12),
        TextField(controller: _email, decoration: field(l10n.fieldEmail), keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 12),
        TextField(controller: _phone, decoration: field(l10n.fieldPhone), keyboardType: TextInputType.phone),
        const SizedBox(height: 12),
        TextField(controller: _position, decoration: field(l10n.appliedPosition)),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _saving ? null : _pickCv,
          icon: Icon(_cv == null ? Icons.attach_file : Icons.description),
          label: Text(_cv == null ? l10n.attachCv : l10n.cvSelected(_cv!.name)),
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        ),
        CheckboxListTile(
          value: _consent,
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.consentAi),
          onChanged: (value) => setState(() => _consent = value ?? false),
        ),
        if (_error case final error?) Text(error, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _saving || _name.text.trim().isEmpty ? null : _save,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: _saving
              ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(widget.current == null ? l10n.applyNow : l10n.saveProfile),
        ),
      ],
    );
  }
}
