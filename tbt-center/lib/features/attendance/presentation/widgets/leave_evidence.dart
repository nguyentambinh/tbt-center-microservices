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
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/error/error_reporter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/attendance.dart';
import '../providers/attendance_providers.dart';

/// Minh chứng của đơn nghỉ: người gửi thêm tệp khi đơn còn chờ, HR xem bản gốc và bản AI tóm tắt
class LeaveEvidence extends ConsumerStatefulWidget {
  const LeaveEvidence({super.key, required this.leave, this.canUpload = false, this.showSummary = false});

  final LeaveRequest leave;
  final bool canUpload;
  final bool showSummary;

  @override
  ConsumerState<LeaveEvidence> createState() => _LeaveEvidenceState();
}

class _LeaveEvidenceState extends ConsumerState<LeaveEvidence> {
  bool _uploading = false;

  Future<void> _upload() async {
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final picked = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: const ['docx', 'pdf', 'jpg', 'jpeg', 'png']);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() => _uploading = true);
    try {
      await ref.read(attendanceRepositoryProvider).uploadLeaveFile(widget.leave.id, fileName: picked.name, bytes: bytes, language: language);
      ref
        ..invalidate(myLeavesProvider)
        ..invalidate(pendingLeavesProvider)
        ..invalidate(leaveFilesProvider(widget.leave.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.evidenceUploaded), behavior: SnackBarBehavior.floating));
      }
    } on Object catch (e) {
      reportFailure(e);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _openFiles() => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (_) => _FilesSheet(leaveId: widget.leave.id),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final leave = widget.leave;
    final summary = leave.aiSummary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showSummary && summary != null) _SummaryCard(summary: summary),
        if (leave.fileCount > 0 || widget.canUpload)
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (leave.fileCount > 0)
                TextButton.icon(onPressed: _openFiles, icon: const Icon(Icons.folder_open_outlined, size: 18), label: Text(l10n.viewOriginalLeave(leave.fileCount))),
              if (widget.canUpload)
                TextButton.icon(
                  onPressed: _uploading ? null : _upload,
                  icon: _uploading ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.attach_file, size: 18),
                  label: Text(l10n.addEvidence),
                ),
            ],
          ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final Map<String, dynamic> summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final matches = summary['matchesRequest'] == true;
    final color = matches ? context.tbt.success : context.tbt.warning;
    final points = [for (final p in summary['keyPoints'] as List? ?? const []) '$p'];
    final concerns = summary['concerns'] as String?;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: context.tbt.glassBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 18, color: context.tbt.brandGold),
              const SizedBox(width: 6),
              Expanded(child: Text(l10n.aiLeaveSummary, style: const TextStyle(fontWeight: FontWeight.bold))),
              Text(matches ? l10n.evidenceMatches : l10n.evidenceCheck, style: TextStyle(color: color, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          if (summary['summary'] case final String text) Text(text),
          for (final p in points) Text('• $p'),
          if (concerns != null && concerns.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text(concerns, style: TextStyle(color: context.tbt.warning))),
          const SizedBox(height: 4),
          Text(l10n.aiDisclaimer, style: TextStyle(color: context.tbt.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

class _FilesSheet extends ConsumerWidget {
  const _FilesSheet({required this.leaveId});

  final String leaveId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final files = ref.watch(leaveFilesProvider(leaveId));
    return SizedBox(
      height: 320,
      child: switch (files) {
        AsyncValue(:final value?) when value.isEmpty => EmptyView(message: l10n.noEvidence, icon: Icons.folder_off_outlined),
        AsyncValue(:final value?) => ListView(
            children: [
              for (final f in value)
                ListTile(
                  leading: Icon(f.isImage ? Icons.image_outlined : Icons.description_outlined),
                  title: Text(f.fileName),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: f.url == null ? null : () => launchUrl(Uri.parse(f.url!), mode: LaunchMode.externalApplication),
                ),
            ],
          ),
        AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(leaveFilesProvider(leaveId))),
        _ => const SkeletonList(),
      },
    );
  }
}
