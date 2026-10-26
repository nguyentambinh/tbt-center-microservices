/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/error_reporter.dart';
import '../../../../core/auth/auth_controller.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/filter_bar.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/change_request.dart';
import '../providers/profile_providers.dart';
import 'profile_page.dart';

/// HR duyệt đề xuất sửa thông tin cá nhân của nhân viên
class ChangeRequestsPage extends ConsumerStatefulWidget {
  const ChangeRequestsPage({super.key});

  @override
  ConsumerState<ChangeRequestsPage> createState() => _ChangeRequestsPageState();
}

class _ChangeRequestsPageState extends ConsumerState<ChangeRequestsPage> {
  String? _status = 'pending';

  Future<void> _decide(ChangeRequest request, bool approve) async {
    final l10n = AppLocalizations.of(context);
    final note = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(approve ? l10n.approve : l10n.reject),
        content: TextField(controller: note, decoration: InputDecoration(labelText: l10n.decisionNote), maxLines: 2),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(approve ? l10n.approve : l10n.reject)),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(profileRepositoryProvider).decide(request.id, approve: approve, note: note.text.trim().isEmpty ? null : note.text.trim());
      ref.invalidate(changeRequestsProvider);
    } on Object catch (e) {
      reportFailure(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final me = ref.watch(authControllerProvider).value?.employeeId;
    final locale = Localizations.localeOf(context).toString();
    final requests = ref.watch(changeRequestsProvider(_status));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.changeRequests)),
      body: Column(
        children: [
          FilterBar(
            children: [
              FilterSpinner<String>(
                label: l10n.filterStatus,
                value: _status,
                options: [
                  (value: 'pending', label: l10n.statusPending),
                  (value: 'approved', label: l10n.statusApproved),
                  (value: 'rejected', label: l10n.statusRejected),
                ],
                onChanged: (v) => setState(() => _status = v),
              ),
            ],
          ),
          Expanded(
            child: switch (requests) {
              AsyncValue(:final value?) when value.isEmpty => EmptyView(message: l10n.noChangeRequests),
              AsyncValue(:final value?) => RefreshIndicator(
                  onRefresh: () => ref.refresh(changeRequestsProvider(_status).future),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    children: [
                      for (final r in value)
                        ChangeRequestTile(
                          request: r,
                          locale: locale,
                          showName: true,
                          actions: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                IconButton(
                                  tooltip: l10n.viewProfile,
                                  icon: const Icon(Icons.badge_outlined),
                                  onPressed: () => context.push('${Routes.employees}/${Uri.encodeComponent(r.employeeId)}'),
                                ),
                                const Spacer(),
                                if (r.pending && r.employeeId == me)
                                  Text(l10n.waitingSuperior, style: TextStyle(color: context.tbt.textSecondary))
                                else if (r.pending) ...[
                                  OutlinedButton(onPressed: () => _decide(r, false), child: Text(l10n.reject, maxLines: 1)),
                                  const SizedBox(width: 8),
                                  FilledButton(onPressed: () => _decide(r, true), child: Text(l10n.approve, maxLines: 1)),
                                ],
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(changeRequestsProvider(_status))),
              _ => const SkeletonList(),
            },
          ),
        ],
      ),
    );
  }
}
