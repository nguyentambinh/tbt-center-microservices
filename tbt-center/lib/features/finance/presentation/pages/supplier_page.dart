/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/error/error_reporter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/finance.dart';
import '../providers/finance_providers.dart';
import '../../../../core/widgets/input_rules.dart';

/// Đối chiếu công nợ một nhà cung cấp: lịch sử mua, trả, số còn nợ (R104).
class SupplierPage extends ConsumerWidget {
  const SupplierPage({super.key, required this.supplierId});

  final String supplierId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final detail = ref.watch(supplierDetailProvider(supplierId));
    final roles = ref.watch(authControllerProvider).value?.roles ?? const <String>[];
    final canWrite = roles.any(financeWriterRoles.contains);

    return Scaffold(
      appBar: AppBar(title: Text(detail.value?.supplier.name ?? supplierId)),
      body: switch (detail) {
        AsyncValue(:final value?) => RefreshIndicator(
            onRefresh: () => ref.refresh(supplierDetailProvider(supplierId).future),
            child: _LedgerView(detail: value),
          ),
        AsyncValue(:final error?) =>
          ErrorView(error: error, onRetry: () => ref.invalidate(supplierDetailProvider(supplierId))),
        _ => const SkeletonList(),
      },
      bottomNavigationBar: canWrite && detail.hasValue
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.add_shopping_cart),
                        label: Text(l10n.recordPurchase),
                        onPressed: () => _openForm(context, purchase: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.payments_outlined),
                        label: Text(l10n.recordPayment),
                        onPressed: () => _openForm(context, purchase: false),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  void _openForm(BuildContext context, {required bool purchase}) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => _EntryForm(supplierId: supplierId, purchase: purchase),
      );
}

class _LedgerView extends StatelessWidget {
  const _LedgerView({required this.detail});

  final SupplierDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final text = Theme.of(context).textTheme;
    final s = detail.supplier;
    final currency = detail.imports.firstOrNull?.currency ?? detail.payments.firstOrNull?.currency;
    String money(double v, [String? c]) => (c ?? currency) == null
        ? NumberFormat.decimalPattern(locale).format(v)
        : NumberFormat.simpleCurrency(locale: locale, name: c ?? currency).format(v);
    String day(DateTime d) => DateFormat.yMMMd(locale).format(d);

    Widget total(String label, double value, {Color? color}) => Row(
          children: [
            Expanded(child: Text(label, style: TextStyle(color: color))),
            Text(money(value), style: text.titleMedium?.copyWith(color: color)),
          ],
        );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (s.contact != null || s.address != null)
          Text([s.contact, s.address].nonNulls.join(' · '), style: TextStyle(color: context.tbt.textSecondary)),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                total(l10n.purchased, s.purchased),
                total(l10n.paid, s.paid),
                const Divider(),
                total(l10n.balance, s.balance, color: Theme.of(context).colorScheme.primary),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(l10n.purchaseHistory, style: text.titleLarge),
        if (detail.imports.isEmpty) Text(l10n.noData),
        for (final e in detail.imports)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.inventory_2_outlined),
            title: Text(e.label ?? '-'),
            subtitle: Text(day(e.date)),
            trailing: Text(money(e.amount, e.currency)),
          ),
        const SizedBox(height: 8),
        Text(l10n.paymentHistory, style: text.titleLarge),
        if (detail.payments.isEmpty) Text(l10n.noData),
        for (final e in detail.payments)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.check_circle_outline, color: context.tbt.success),
            title: Text(money(e.amount, e.currency)),
            subtitle: Text([day(e.date), e.label].nonNulls.join(' · ')),
          ),
      ],
    );
  }
}

/// Form ghi một lần mua vật liệu hoặc một lần trả tiền.
class _EntryForm extends ConsumerStatefulWidget {
  const _EntryForm({required this.supplierId, required this.purchase});

  final String supplierId;
  final bool purchase;

  @override
  ConsumerState<_EntryForm> createState() => _EntryFormState();
}

class _EntryFormState extends ConsumerState<_EntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _material = TextEditingController();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  DateTime _date = DateTime.now();
  bool _saving = false;

  static final _amountPattern = RegExp(r'^\d{1,16}(\.\d{1,2})?$');

  @override
  void dispose() {
    _material.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final repository = ref.read(financeRepositoryProvider);
    final amount = _amount.text.trim();
    try {
      if (widget.purchase) {
        await repository.recordPurchase(
          supplierId: widget.supplierId,
          materialName: _material.text.trim(),
          date: _date,
          amount: amount,
        );
      } else {
        await repository.recordPayment(supplierId: widget.supplierId, date: _date, amount: amount, note: _note.text.trim());
      }
      ref
        ..invalidate(supplierDetailProvider(widget.supplierId))
        ..invalidate(suppliersProvider)
        ..invalidate(financeSummaryProvider);
      if (mounted) Navigator.pop(context);
    } on Object catch (e) {
      reportFailure(e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.viewInsetsOf(context).bottom + 16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.purchase ? l10n.recordPurchase : l10n.recordPayment, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (widget.purchase)
              TextFormField(
                inputFormatters: InputRules.shortText,
                controller: _material,
                decoration: InputDecoration(labelText: l10n.materialName),
                validator: (v) => (v ?? '').trim().isEmpty ? l10n.errorValidation : null,
              ),
            TextFormField(
              inputFormatters: InputRules.decimal,
              controller: _amount,
              decoration: InputDecoration(labelText: l10n.amount),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                final text = (v ?? '').trim();
                return _amountPattern.hasMatch(text) && double.parse(text) > 0 ? null : l10n.errInvalidAmount;
              },
            ),
            if (!widget.purchase)
              TextFormField(inputFormatters: InputRules.note, controller: _note, decoration: InputDecoration(labelText: l10n.note)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.event),
              label: Text(DateFormat.yMMMd(locale).format(_date)),
              onPressed: _pickDate,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
