/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/proposal.dart';
import 'project_widgets.dart';

/// Tỷ giá gần đúng 1 USD = ? để báo phân cấp ngay trên form; server kiểm lại bằng tỷ giá thật
const approxUsdRates = {'USD': 1.0, 'VND': 25400.0, 'EUR': 0.92, 'BRL': 5.6, 'ZAR': 18.0, 'AUD': 1.52};

double rateToUsd(String? currency) => approxUsdRates[currency?.toUpperCase()] ?? 1;

String proposalErrorText(AppLocalizations l10n, String code) => switch (code) {
      'name_required' => l10n.propErrName,
      'customer_required' => l10n.propErrCustomer,
      'invalid_value' => l10n.propErrValue,
      'invalid_deposit' => l10n.propErrDeposit,
      'dates_required' => l10n.propErrDates,
      'start_in_past' => l10n.propErrStartPast,
      'end_before_start' => l10n.propErrEndBeforeStart,
      'acceptance_out_of_range' => l10n.propErrAcceptance,
      'too_long_for_tier' => l10n.propErrTooLong,
      'too_few_members' => l10n.propErrFewMembers,
      _ => code,
    };

/// Các ô của đề xuất dự án; mỗi lần sửa gọi [onChanged] với bản mới
class ProposalForm extends StatefulWidget {
  const ProposalForm({super.key, required this.initial, required this.onChanged, this.showMemberRule = false});

  final ProposalData initial;
  final ValueChanged<ProposalData> onChanged;

  /// Bước nhập thông tin chưa chọn người, nên bỏ qua lỗi thiếu người
  final bool showMemberRule;

  @override
  State<ProposalForm> createState() => _ProposalFormState();
}

class _ProposalFormState extends State<ProposalForm> {
  late final _name = TextEditingController(text: widget.initial.name);
  late final _customer = TextEditingController(text: widget.initial.customerName);
  late final _contact = TextEditingController(text: widget.initial.customerContact);
  late final _type = TextEditingController(text: widget.initial.contractType);
  late final _value = TextEditingController(text: _money(widget.initial.value));
  late final _deposit = TextEditingController(text: _money(widget.initial.deposit));
  late final _currency = TextEditingController(text: widget.initial.currency);
  late String _customerType = widget.initial.customerType;
  late DateTime? _start = widget.initial.startDate;
  late DateTime? _end = widget.initial.endDate;
  late DateTime? _acceptance = widget.initial.acceptanceDate;

  static String _money(double? v) => v == null ? '' : NumberFormat('#0.##').format(v);

  @override
  void dispose() {
    for (final c in [_name, _customer, _contact, _type, _value, _deposit, _currency]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _text(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  ProposalData get _data => ProposalData(
        name: _text(_name),
        customerName: _text(_customer),
        customerType: _customerType,
        customerContact: _text(_contact),
        contractType: _text(_type),
        value: double.tryParse(_value.text.trim()),
        deposit: double.tryParse(_deposit.text.trim()),
        currency: _text(_currency)?.toUpperCase(),
        startDate: _start,
        endDate: _end,
        acceptanceDate: _acceptance,
        memberIds: widget.initial.memberIds,
      );

  void _changed() {
    setState(() {});
    widget.onChanged(_data);
  }

  Future<void> _pickDate(DateTime? current, ValueChanged<DateTime> set) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );
    if (picked == null) return;
    set(picked);
    _changed();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final days = DateFormat.yMMMd(Localizations.localeOf(context).toString());
    final data = _data;
    final errors = data.errors(rateToUsd: rateToUsd(data.currency)).where((e) => widget.showMemberRule || e != 'too_few_members').toList();
    final tier = data.value == null ? null : projectTier(data.value! / rateToUsd(data.currency));
    InputDecoration field(String label) => InputDecoration(labelText: label);
    Widget date(String label, DateTime? value, ValueChanged<DateTime> set) => Expanded(
          child: OutlinedButton(
            onPressed: () => _pickDate(value, set),
            child: Column(
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: context.tbt.textSecondary)),
                Text(value == null ? '—' : days.format(value)),
              ],
            ),
          ),
        );
    final money = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(controller: _name, decoration: field(l10n.projectName), onChanged: (_) => _changed()),
        const SizedBox(height: 12),
        TextField(controller: _customer, decoration: field(l10n.customerName), onChanged: (_) => _changed()),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: [
            ButtonSegment(value: 'company', label: Text(l10n.customerCompany)),
            ButtonSegment(value: 'individual', label: Text(l10n.customerIndividual)),
          ],
          selected: {_customerType},
          onSelectionChanged: (v) {
            _customerType = v.first;
            _changed();
          },
        ),
        const SizedBox(height: 12),
        TextField(controller: _contact, decoration: field(l10n.customerContact), onChanged: (_) => _changed()),
        const SizedBox(height: 12),
        TextField(controller: _type, decoration: field(l10n.contractType), onChanged: (_) => _changed()),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(controller: _value, keyboardType: TextInputType.number, inputFormatters: money, decoration: field(l10n.contractValue), onChanged: (_) => _changed()),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _currency,
                maxLength: 3,
                textCapitalization: TextCapitalization.characters,
                decoration: field(l10n.currency).copyWith(counterText: ''),
                onChanged: (_) => _changed(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(controller: _deposit, keyboardType: TextInputType.number, inputFormatters: money, decoration: field(l10n.depositAmount), onChanged: (_) => _changed()),
        const SizedBox(height: 12),
        Row(
          children: [
            date(l10n.startDate, _start, (d) => _start = d),
            const SizedBox(width: 8),
            date(l10n.endDate, _end, (d) => _end = d),
            const SizedBox(width: 8),
            date(l10n.acceptanceDate, _acceptance, (d) => _acceptance = d),
          ],
        ),
        if (tier != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              TagChip(label: tierLabel(l10n, tier), color: context.tbt.brandGold, icon: Icons.layers_outlined),
              const SizedBox(width: 8),
              Expanded(child: Text(l10n.tierRule(tierMaxMonths[tier]!, tierMinMembers[tier]!), style: TextStyle(color: context.tbt.textSecondary, fontSize: 12))),
            ],
          ),
        ],
        if (errors.isNotEmpty) ...[
          const SizedBox(height: 8),
          for (final e in errors)
            Text('• ${proposalErrorText(l10n, e)}', style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
        ],
      ],
    );
  }
}
