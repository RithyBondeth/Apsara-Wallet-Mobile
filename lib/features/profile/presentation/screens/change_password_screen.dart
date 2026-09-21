import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:apsara_wallet_mobile/core/extensions/buildcontext_extension.dart';
import 'package:apsara_wallet_mobile/core/themes/app_spacing.dart';
import 'package:apsara_wallet_mobile/features/auth/data/auth_repository.dart';
import 'package:apsara_wallet_mobile/features/profile/presentation/widgets/settings_sub_scaffold.dart';
import 'package:apsara_wallet_mobile/shared/widgets/buttons/primary_button.dart';
import 'package:apsara_wallet_mobile/shared/widgets/inputs/app_text_field.dart';
import 'package:apsara_wallet_mobile/core/networks/api_error_l10n.dart';

/// Change Password — reached from Security & Privacy. Verifies the current
/// password server-side, so a stolen unlocked phone can't silently rotate the
/// credential. Mirrors the reset-password form, plus the current-password
/// field.
@RoutePage()
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _current = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String? _currentError;
  String? _passwordError;
  String? _confirmError;
  bool _busy = false;

  @override
  void dispose() {
    _current.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final current = _current.text;
    final password = _password.text;
    final confirm = _confirm.text;
    setState(() {
      _currentError = current.isEmpty ? l10n.authErrorPasswordRequired : null;
      _passwordError = password.length < 8
          ? l10n.authErrorPasswordTooShort
          : (password == current ? l10n.changePasswordSameAsCurrent : null);
      _confirmError = confirm != password
          ? l10n.authErrorPasswordMismatch
          : null;
    });
    if (_currentError != null ||
        _passwordError != null ||
        _confirmError != null) {
      return;
    }

    context.hideKeyboard();
    setState(() => _busy = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .changePassword(currentPassword: current, newPassword: password);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(l10n.changePasswordSuccess),
        ),
      );
      context.router.maybePop();
    } on AuthException catch (e) {
      if (!mounted) return;
      // The only user-fixable server rejection is a wrong current password;
      // surface it on that field rather than as a generic toast.
      setState(() {
        _busy = false;
        _currentError = l10n.changePasswordWrongCurrent;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(localizedApiError(l10n, e.message)),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(l10n.changePasswordFailed),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SettingsSubScaffold(
      title: l10n.securityChangePassword,
      children: [
        AppTextField(
          label: l10n.changePasswordCurrentLabel,
          hint: l10n.changePasswordCurrentHint,
          controller: _current,
          prefixIcon: LucideIcons.lockKeyhole,
          obscure: true,
          textInputAction: TextInputAction.next,
          errorText: _currentError,
          onChanged: (_) {
            if (_currentError != null) setState(() => _currentError = null);
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: l10n.resetPasswordNewLabel,
          hint: l10n.resetPasswordNewHint,
          controller: _password,
          prefixIcon: LucideIcons.lock,
          obscure: true,
          textInputAction: TextInputAction.next,
          errorText: _passwordError,
          onChanged: (_) {
            if (_passwordError != null) setState(() => _passwordError = null);
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: l10n.resetPasswordConfirmLabel,
          hint: l10n.resetPasswordConfirmHint,
          controller: _confirm,
          prefixIcon: LucideIcons.lock,
          obscure: true,
          textInputAction: TextInputAction.done,
          errorText: _confirmError,
          onChanged: (_) {
            if (_confirmError != null) setState(() => _confirmError = null);
          },
          onSubmitted: (_) => _save(),
        ),
        const SizedBox(height: AppSpacing.xxl),
        PrimaryButton(
          label: l10n.commonSave,
          loading: _busy,
          onPressed: _busy ? null : _save,
        ),
      ],
    );
  }
}
