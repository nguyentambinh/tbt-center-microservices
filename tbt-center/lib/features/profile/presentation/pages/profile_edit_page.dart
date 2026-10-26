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

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/locale/hometowns.dart';
import '../../../../core/error/error_reporter.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../hr/domain/entities/employee.dart';
import '../../domain/change_request.dart';
import '../providers/profile_providers.dart';
import 'profile_page.dart';
import '../../../../core/widgets/input_rules.dart';

/// Nhân viên sửa ô cần đổi rồi gửi đề xuất; chỉ trường đã đổi được gửi lên HR
class ProfileEditPage extends ConsumerWidget {
  const ProfileEditPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(myProfileProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.proposeChange)),
      body: switch (profile) {
        AsyncValue(:final value?) => _EditForm(employee: value),
        AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(myProfileProvider)),
        _ => const SkeletonList(),
      },
    );
  }
}

class _EditForm extends ConsumerStatefulWidget {
  const _EditForm({required this.employee});

  final EmployeeDetail employee;

  @override
  ConsumerState<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends ConsumerState<_EditForm> {
  final _form = GlobalKey<FormState>();
  late final Map<String, String> _original;
  late final Map<String, TextEditingController> _fields;
  final _reason = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    final e = widget.employee;
    String text(Object? v) => v?.toString() ?? '';
    _original = {
      'email': text(e.summary.email),
      'phone': text(e.contact['phone']),
      'address': text(e.contact['address']),
      'facebook': text(e.contact['facebook']),
      'xHandle': text(e.contact['xHandle']),
      'hometownCode': text(e.contact['hometownCode']),
      'heightCm': text(e.health['heightCm']),
      'weightKg': text(e.health['weightKg']),
      'visionScore': text(e.health['visionScore']),
      'medicalHistory': text(e.health['medicalHistory']),
    };
    _fields = {for (final k in editableProfileFields) k: TextEditingController(text: _original[k])};
  }

  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    _reason.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context);
    if (!_form.currentState!.validate()) return;
    final changes = <String, Object?>{
      for (final k in editableProfileFields)
        if (_fields[k]!.text.trim() != _original[k]) k: numericProfileFields.contains(k) ? int.parse(_fields[k]!.text.trim()) : _fields[k]!.text.trim(),
    };
    if (changes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.changeRequestNoChange)));
      return;
    }
    setState(() => _sending = true);
    try {
      await ref.read(profileRepositoryProvider).submit(changes, reason: _reason.text.trim().isEmpty ? null : _reason.text.trim());
      ref.invalidate(myChangeRequestsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.changeRequestSent)));
      context.pop();
    } on Object catch (e) {
      reportFailure(e);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  /// Quê quán, chiều cao, thị lực chọn trong danh sách, hiện chữ thay cho mã số
  List<({String value, String label})>? _pickers(BuildContext context, String key) {
    final current = _original[key] ?? '';
    return switch (key) {
      'hometownCode' => [
          for (final o in hometownOptions(ref.read(authControllerProvider).value?.countryCode)) (value: o.code, label: o.name),
          if (current.isNotEmpty && hometownOptions(ref.read(authControllerProvider).value?.countryCode).every((o) => o.code != current)) (value: current, label: hometownName(current) ?? current),
        ],
      'heightCm' => [for (var cm = 140; cm <= 210; cm++) (value: '$cm', label: '$cm cm')],
      'visionScore' => [for (var v = 1; v <= 10; v++) (value: '$v', label: '$v/10')],
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.proposeChangeHint),
          const SizedBox(height: 12),
          for (final k in editableProfileFields)
            if (_pickers(context, k) case final options?)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DropdownButtonFormField<String>(
                  initialValue: options.any((o) => o.value == _fields[k]!.text) ? _fields[k]!.text : null,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: profileFieldLabel(l10n, k)),
                  items: [for (final o in options) DropdownMenuItem(value: o.value, child: Text(o.label, overflow: TextOverflow.ellipsis))],
                  onChanged: (v) => setState(() => _fields[k]!.text = v ?? ''),
                ),
              )
            else
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextFormField(
                inputFormatters: InputRules.profileField(k),
                controller: _fields[k],
                decoration: InputDecoration(labelText: profileFieldLabel(l10n, k)),
                keyboardType: numericProfileFields.contains(k)
                    ? TextInputType.number
                    : k == 'email'
                        ? TextInputType.emailAddress
                        : TextInputType.text,
                maxLines: k == 'medicalHistory' || k == 'address' ? 2 : 1,
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty || value == _original[k]) return null;
                  if (numericProfileFields.contains(k) && (int.tryParse(value) ?? 0) <= 0) return l10n.invalidAmount;
                  if (k == 'email' && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) return l10n.invalidEmail;
                  return null;
                },
              ),
            ),
          TextField(inputFormatters: InputRules.note, controller: _reason, decoration: InputDecoration(labelText: l10n.changeReason), maxLines: 2),
          const SizedBox(height: 20),
          FilledButton.icon(
            icon: _sending ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send),
            label: Text(l10n.sendRequest),
            onPressed: _sending ? null : _send,
          ),
        ],
      ),
    );
  }
}
