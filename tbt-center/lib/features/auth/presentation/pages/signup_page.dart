/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/auth/auth_gateway.dart';
import '../../../../core/config/env.dart';
import '../../../../core/error/app_failure.dart';
import '../../../../core/locale/locale_providers.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/widgets/input_rules.dart';

/// Đăng ký ứng viên ở service recruitment của khu vực nộp hồ sơ (không cần đăng nhập)
class SignupRepository {
  SignupRepository(this._dio, {required this.baseUrl});

  final Dio _dio;
  final String baseUrl;

  Future<void> sendCode({required String email, required String fullName, required String language}) =>
      _post('send', {'email': email, 'fullName': fullName, 'language': language});

  Future<void> verify({required String email, required String code, required String password}) =>
      _post('verify', {'email': email, 'code': code, 'password': password});

  Future<void> _post(String step, Map<String, Object> body) async {
    try {
      await _dio.post<Map<String, dynamic>>('$baseUrl/recruitment/public/signup/${step == 'send' ? 'code' : 'verify'}', data: body, options: Options(extra: {noCache: true}));
    } on DioException catch (e) {
      throw e.error is AppFailure ? e.error! : AppFailure.fromDio(e);
    }
  }
}

final signupRepositoryProvider = Provider<SignupRepository>(
  (ref) => SignupRepository(ref.watch(apiClientProvider), baseUrl: Env.kongUrl(ref.watch(submitRegionProvider))),
);

/// Màn đăng ký: họ tên, email → mã 6 số gửi về email → đặt mật khẩu → tạo tài khoản
class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _codeSent = false;
  bool _busy = false;
  bool _hidden = true;
  String? _error;
  int _resendIn = 0;
  Timer? _timer;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in [_name, _email, _code, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _detailsValid => _name.text.trim().length >= 2 && _emailPattern.hasMatch(_email.text.trim());

  bool get _passwordValid {
    final p = _password.text;
    return p.length >= 8 && RegExp('[A-Za-z]').hasMatch(p) && RegExp('[0-9]').hasMatch(p) && p == _confirm.text;
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } on AppFailure catch (e) {
      if (mounted) setState(() => _error = e.message(AppLocalizations.of(context)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendCode() => _run(() async {
        await ref.read(signupRepositoryProvider).sendCode(
              email: _email.text.trim(),
              fullName: _name.text.trim(),
              language: Localizations.localeOf(context).languageCode,
            );
        _timer?.cancel();
        setState(() {
          _codeSent = true;
          _resendIn = 60;
        });
        _timer = Timer.periodic(const Duration(seconds: 1), (t) {
          if (!mounted || _resendIn <= 1) t.cancel();
          if (mounted) setState(() => _resendIn = (_resendIn - 1).clamp(0, 60));
        });
      });

  Future<void> _verify() => _run(() async {
        final l10n = AppLocalizations.of(context);
        final locale = Localizations.localeOf(context).languageCode;
        final email = _email.text.trim();
        await ref.read(signupRepositoryProvider).verify(email: email, code: _code.text.trim(), password: _password.text);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.signupDone), behavior: SnackBarBehavior.floating));
        try {
          await ref.read(authControllerProvider.notifier).signIn(locale: locale, loginHint: email);
        } on SignInCancelled {
          // Người dùng đóng trang đăng nhập, lần sau đăng nhập bằng email vừa tạo
        }
      });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    InputDecoration field(String label, {String? helper, Widget? suffix}) =>
        InputDecoration(labelText: label, helperText: helper, helperMaxLines: 2, border: const OutlineInputBorder(), suffixIcon: suffix);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.signupTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(l10n.signupHint, style: TextStyle(color: context.tbt.textSecondary)),
          const SizedBox(height: 16),
          TextField(inputFormatters: InputRules.name, controller: _name, enabled: !_codeSent, textCapitalization: TextCapitalization.words, decoration: field(l10n.fullName), onChanged: (_) => setState(() {})),
          const SizedBox(height: 12),
          TextField(inputFormatters: InputRules.email, controller: _email, enabled: !_codeSent, keyboardType: TextInputType.emailAddress, decoration: field(l10n.fieldEmail), onChanged: (_) => setState(() {})),
          const SizedBox(height: 12),
          const SizedBox(height: 16),
          if (!_codeSent)
            FilledButton(
              onPressed: _busy || !_detailsValid ? null : _sendCode,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: Text(l10n.sendCode),
            )
          else ...[
            Text(l10n.codeSentTo(_email.text.trim()), style: TextStyle(color: context.tbt.success)),
            const SizedBox(height: 12),
            TextField(
              controller: _code,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: field(l10n.verificationCode),
              onChanged: (_) => setState(() {}),
            ),
            TextField(
              inputFormatters: InputRules.password,
              controller: _password,
              obscureText: _hidden,
              decoration: field(l10n.newPassword, helper: l10n.passwordRule, suffix: IconButton(icon: Icon(_hidden ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _hidden = !_hidden))),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(inputFormatters: InputRules.password, controller: _confirm, obscureText: _hidden, decoration: field(l10n.confirmPassword), onChanged: (_) => setState(() {})),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy || _code.text.length != 6 || !_passwordValid ? null : _verify,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: Text(l10n.createAccount),
            ),
            TextButton(
              onPressed: _busy || _resendIn > 0 ? null : _sendCode,
              child: Text(_resendIn > 0 ? l10n.resendIn(_resendIn) : l10n.resendCode),
            ),
            TextButton(onPressed: _busy ? null : () => setState(() => _codeSent = false), child: Text(l10n.editDetails)),
          ],
          if (_error case final error?) Padding(padding: const EdgeInsets.only(top: 12), child: Text(error, style: TextStyle(color: Theme.of(context).colorScheme.error))),
          if (_busy) const Padding(padding: EdgeInsets.only(top: 12), child: LinearProgressIndicator()),
        ],
      ),
    );
  }
}
