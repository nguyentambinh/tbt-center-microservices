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
import 'package:go_router/go_router.dart';

import '../../../../core/error/error_reporter.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/candidate_import.dart';
import '../providers/candidate_providers.dart';

/// Chọn tệp `.csv`, `.xlsx`, gửi lên và mở danh sách nháp. Dùng ở màn Ứng viên.
Future<void> pickAndImportCandidates(BuildContext context, WidgetRef ref) async {
  final picked = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: const ['csv', 'xlsx']);
  if (picked == null) return;
  try {
    final draft = await ref.read(candidateImportRepositoryProvider).upload(picked.name, await picked.readAsBytes());
    if (context.mounted) await context.push('${Routes.candidates}/imports/${draft.id}');
  } on Object catch (e) {
    reportFailure(e);
  }
}

/// Danh sách nháp (R84): HR xác nhận tất cả, hoặc tick từng người rồi xác nhận.
/// Chỉ dòng được xác nhận mới thành hồ sơ; dòng lỗi không tick được.
class CandidateImportPage extends ConsumerStatefulWidget {
  const CandidateImportPage({super.key, required this.importId});

  final String importId;

  @override
  ConsumerState<CandidateImportPage> createState() => _CandidateImportPageState();
}

class _CandidateImportPageState extends ConsumerState<CandidateImportPage> {
  final _selected = <String>{};
  bool _sending = false;

  Future<void> _confirm({required bool all}) async {
    setState(() => _sending = true);
    try {
      final result = await ref
          .read(candidateImportRepositoryProvider)
          .confirm(widget.importId, rowIds: all ? null : _selected.toList());
      _selected.clear();
      ref
        ..invalidate(candidateImportProvider(widget.importId))
        ..invalidate(candidateListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context).importAccepted(result.accepted)),
            behavior: SnackBarBehavior.floating,
          ));
      }
    } on Object catch (e) {
      reportFailure(e);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final draft = ref.watch(candidateImportProvider(widget.importId));
    final pending = draft.value?.pendingRows.length ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text(draft.value?.fileName ?? l10n.importCandidates)),
      body: switch (draft) {
        AsyncValue(:final value?) => ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.importSummary(value.rows.length, pending),
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
              for (final row in value.rows)
                _RowTile(
                  row: row,
                  selected: _selected.contains(row.id),
                  onChanged: row.pending
                      ? (v) => setState(() => v ? _selected.add(row.id) : _selected.remove(row.id))
                      : null,
                ),
            ],
          ),
        AsyncValue(:final error?) =>
          ErrorView(error: error, onRetry: () => ref.invalidate(candidateImportProvider(widget.importId))),
        _ => const SkeletonList(),
      },
      bottomNavigationBar: pending == 0
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _sending || _selected.isEmpty ? null : () => _confirm(all: false),
                        child: Text(l10n.confirmSelected(_selected.length)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _sending ? null : () => _confirm(all: true),
                        child: Text(l10n.confirmAll),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _RowTile extends StatelessWidget {
  const _RowTile({required this.row, required this.selected, this.onChanged});

  final ImportRow row;
  final bool selected;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (label, color) = switch (row) {
      ImportRow(status: 'accepted') => (l10n.importRowAccepted, const Color(0xFF3FCF8E)),
      ImportRow(status: 'invalid') => (_errorText(l10n, row.error), const Color(0xFFFF4D79)),
      ImportRow(isUpdate: true) => (l10n.importRowUpdate, AppColors.brandGold),
      _ => (l10n.importRowNew, Theme.of(context).colorScheme.primary),
    };
    final details = [row.email, row.phone, row.appliedPosition].nonNulls.join(' · ');
    return CheckboxListTile(
      value: selected || row.status == 'accepted',
      onChanged: onChanged == null ? null : (v) => onChanged!(v ?? false),
      title: Text(row.fullName.isEmpty ? '—' : row.fullName),
      subtitle: Text(
        '${l10n.importRowNumber(row.rowNumber)}${details.isEmpty ? '' : ' · $details'}',
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      secondary: Text(label, style: TextStyle(color: color, fontSize: 12)),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  static String _errorText(AppLocalizations l10n, String? error) => switch (error) {
        'missing_name' => l10n.importErrMissingName,
        'missing_contact' => l10n.importErrMissingContact,
        'invalid_email' => l10n.importErrInvalidEmail,
        _ => l10n.errorValidation,
      };
}
