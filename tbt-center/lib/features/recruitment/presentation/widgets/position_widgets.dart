/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/job_position.dart';

/// Màu theo điểm phù hợp: từ 80 hợp, 50–79 một phần, dưới 50 yếu
Color matchColor(BuildContext context, int score) => score >= 80
    ? context.tbt.success
    : score >= 50
        ? context.tbt.caution
        : context.tbt.danger;

/// Ô chọn vị trí ứng tuyển: bấm để sổ danh sách, tick một hoặc nhiều vị trí
class PositionPicker extends StatelessWidget {
  const PositionPicker({super.key, required this.positions, required this.selected, required this.onChanged, this.errorText});

  final List<JobPosition> positions;
  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;
  final String? errorText;

  Future<void> _open(BuildContext context) async {
    final picked = await showModalBottomSheet<Set<int>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _PositionSheet(positions: positions, initial: selected),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chosen = [for (final p in positions) if (selected.contains(p.id)) p];
    return InkWell(
      onTap: () => _open(context),
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        isEmpty: chosen.isEmpty,
        decoration: InputDecoration(
          labelText: l10n.appliedPosition,
          hintText: l10n.choosePositionsHint,
          helperText: l10n.choosePositionsHelper(maxPositionsPerCandidate),
          errorText: errorText,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: chosen.isEmpty
            ? null
            : Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final p in chosen)
                    InputChip(
                      label: Text(p.title),
                      visualDensity: VisualDensity.compact,
                      onDeleted: () => onChanged({...selected}..remove(p.id)),
                    ),
                ],
              ),
      ),
    );
  }
}

class _PositionSheet extends StatefulWidget {
  const _PositionSheet({required this.positions, required this.initial});

  final List<JobPosition> positions;
  final Set<int> initial;

  @override
  State<_PositionSheet> createState() => _PositionSheetState();
}

class _PositionSheetState extends State<_PositionSheet> {
  late final Set<int> _selected = {...widget.initial};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final full = _selected.length >= maxPositionsPerCandidate;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.75),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(l10n.choosePositions, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final p in widget.positions)
                    CheckboxListTile(
                      value: _selected.contains(p.id),
                      title: Text(p.title),
                      subtitle: Text(
                        [?p.department, l10n.positionSlotsLeft(p.remaining)].join(' · '),
                        style: TextStyle(color: context.tbt.textSecondary),
                      ),
                      onChanged: !_selected.contains(p.id) && full
                          ? null
                          : (v) => setState(() => v == true ? _selected.add(p.id) : _selected.remove(p.id)),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: FilledButton(
                onPressed: () => Navigator.pop(context, _selected),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                child: Text(l10n.positionsChosen(_selected.length)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Điểm phù hợp của CV với từng vị trí ứng viên đã chọn, AI chấm
class PositionMatchCard extends StatelessWidget {
  const PositionMatchCard({super.key, required this.matches, required this.waitingForAi});

  final List<PositionMatch> matches;

  /// Đã có CV và đồng ý cho AI đọc, chỉ chưa tới lượt chấm
  final bool waitingForAi;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.fact_check_outlined, color: context.tbt.brandGold, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(l10n.positionMatchTitle, style: text.titleLarge)),
            ]),
            for (final m in matches)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(child: Text(m.title, style: const TextStyle(fontWeight: FontWeight.bold))),
                      if (m.score case final s?)
                        Text('$s%', style: TextStyle(color: matchColor(context, s), fontWeight: FontWeight.bold))
                      else
                        Text(waitingForAi ? l10n.positionMatchPending : l10n.positionMatchNone, style: TextStyle(color: context.tbt.textSecondary, fontSize: 12)),
                    ]),
                    if (m.score case final s?) ...[
                      const SizedBox(height: 4),
                      LinearProgressIndicator(value: s / 100, minHeight: 6, borderRadius: BorderRadius.circular(3), color: matchColor(context, s)),
                    ],
                    if (m.verdict case final v? when v.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text(v)),
                    if (m.strengths case final v? when v.isNotEmpty) Text('${l10n.positionMatchStrengths}: $v', style: TextStyle(color: context.tbt.success, fontSize: 12)),
                    if (m.gaps case final v? when v.isNotEmpty) Text('${l10n.positionMatchGaps}: $v', style: TextStyle(color: context.tbt.caution, fontSize: 12)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
