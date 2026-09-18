import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/k_badge.dart';
import '../../../shared/widgets/k_button.dart';
import '../../../shared/widgets/k_card.dart';
import '../../../shared/widgets/k_text_field.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

enum _MfaStep { idle, setup, disable }

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  // MFA
  _MfaStep _mfaStep = _MfaStep.idle;
  bool _mfaEnabled = false;
  String? _mfaSecret;
  String? _mfaOtpauthUrl;
  final _mfaCodeCtrl = TextEditingController();
  bool _mfaLoading = false;
  String? _mfaError;
  String? _mfaSuccess;

  @override
  void initState() {
    super.initState();
    _loadMfaStatus();
  }

  @override
  void dispose() {
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    _mfaCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMfaStatus() async {
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.get(Endpoints.mfaStatus);
      if (mounted) {
        setState(() { _mfaEnabled = res.data['mfaEnabled'] == true; });
      }
    } catch (_) {}
  }

  Future<void> _changePassword() async {
    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.post(Endpoints.changePassword, data: {
        'currentPassword': _currentPassCtrl.text,
        'newPassword': _newPassCtrl.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated')),
        );
        _currentPassCtrl.clear();
        _newPassCtrl.clear();
        _confirmPassCtrl.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── MFA handlers ──

  Future<void> _startMfaSetup() async {
    setState(() { _mfaLoading = true; _mfaError = null; _mfaSuccess = null; });
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.post(Endpoints.mfaSetup);
      final data = res.data as Map<String, dynamic>;
      setState(() {
        _mfaStep = _MfaStep.setup;
        _mfaSecret = data['secret']?.toString();
        _mfaOtpauthUrl = data['otpauthUrl']?.toString();
        _mfaLoading = false;
      });
    } catch (e) {
      setState(() { _mfaLoading = false; _mfaError = e.toString(); });
    }
  }

  Future<void> _confirmMfaEnable() async {
    final code = _mfaCodeCtrl.text.trim();
    if (code.length != 6) return;
    setState(() { _mfaLoading = true; _mfaError = null; });
    try {
      final dio = ref.read(dioProvider);
      await dio.post(Endpoints.mfaEnable, data: {'code': code});
      setState(() {
        _mfaStep = _MfaStep.idle;
        _mfaEnabled = true;
        _mfaSuccess = 'Two-factor authentication has been enabled.';
        _mfaCodeCtrl.clear();
      });
    } catch (e) {
      setState(() { _mfaLoading = false; _mfaError = 'Invalid code — try again'; });
    }
  }

  Future<void> _confirmMfaDisable() async {
    final code = _mfaCodeCtrl.text.trim();
    if (code.length != 6) return;
    setState(() { _mfaLoading = true; _mfaError = null; });
    try {
      final dio = ref.read(dioProvider);
      await dio.post(Endpoints.mfaDisable, data: {'code': code});
      setState(() {
        _mfaStep = _MfaStep.idle;
        _mfaEnabled = false;
        _mfaSuccess = 'Two-factor authentication has been disabled.';
        _mfaCodeCtrl.clear();
      });
    } catch (e) {
      setState(() { _mfaLoading = false; _mfaError = 'Invalid code — try again'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Two-Factor Authentication ──
            const Text('TWO-FACTOR AUTHENTICATION',
                style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2)),
            const SizedBox(height: 10),

            if (_mfaSuccess != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.all(AppRadius.md),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_mfaSuccess!, style: const TextStyle(color: AppColors.success, fontSize: 13))),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            if (_mfaStep == _MfaStep.idle) ...[
              KCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            color: AppColors.accentSurface,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.security_outlined,
                              color: AppColors.accent, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Authenticator App',
                                  style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                              Text(
                                _mfaEnabled
                                    ? 'Protecting your account with TOTP'
                                    : 'Add an extra layer of security',
                                style: const TextStyle(
                                    color: AppColors.textMuted, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        KBadge(
                          label: _mfaEnabled ? 'ENABLED' : 'OFF',
                          variant: _mfaEnabled
                              ? KBadgeVariant.success
                              : KBadgeVariant.neutral,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: _mfaEnabled
                          ? KButton(
                              label: 'Disable',
                              isLoading: false,
                              onPressed: () {
                                setState(() {
                                  _mfaStep = _MfaStep.disable;
                                  _mfaCodeCtrl.clear();
                                  _mfaError = null;
                                  _mfaSuccess = null;
                                });
                              },
                            )
                          : KButton(
                              label: 'Enable',
                              isLoading: false,
                              onPressed: _startMfaSetup,
                            ),
                    ),
                  ],
                ),
              ),
            ],

            if (_mfaStep == _MfaStep.setup) ...[
              KCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Scan this QR code with your authenticator app.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 16),
                    Center(
                      child: _mfaOtpauthUrl != null
                          ? QrImageView(
                              data: _mfaOtpauthUrl!,
                              version: QrVersions.auto,
                              size: 200,
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.all(12),
                            )
                          : const SizedBox(
                              width: 200,
                              height: 200,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                    ),
                    if (_mfaSecret != null) ...[
                      const SizedBox(height: 16),
                      const Text('Manual key:',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHighest,
                          borderRadius: BorderRadius.all(AppRadius.sm),
                        ),
                        child: Text(_mfaSecret!,
                            style: const TextStyle(
                                fontFamily: 'monospace', fontSize: 13, color: AppColors.textPrimary)),
                      ),
                    ],
                    const SizedBox(height: 20),
                    KTextField(
                      label: 'Verification code',
                      hint: '000000',
                      controller: _mfaCodeCtrl,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _confirmMfaEnable(),
                    ),
                    if (_mfaError != null) ...[
                      const SizedBox(height: 8),
                      Text(_mfaError!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: KButton(
                            label: 'Verify & Enable',
                            isLoading: _mfaLoading,
                            onPressed: _mfaCodeCtrl.text.length == 6 ? _confirmMfaEnable : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: KButton(
                            label: 'Cancel',
                            isLoading: false,
                            onPressed: () { setState(() { _mfaStep = _MfaStep.idle; }); },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            if (_mfaStep == _MfaStep.disable) ...[
              KCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter the code from your authenticator app to disable MFA.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    KTextField(
                      label: 'Verification code',
                      hint: '000000',
                      controller: _mfaCodeCtrl,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _confirmMfaDisable(),
                    ),
                    if (_mfaError != null) ...[
                      const SizedBox(height: 8),
                      Text(_mfaError!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: KButton(
                            label: 'Disable MFA',
                            isLoading: _mfaLoading,
                            onPressed: _mfaCodeCtrl.text.length == 6 ? _confirmMfaDisable : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: KButton(
                            label: 'Cancel',
                            isLoading: false,
                            onPressed: () { setState(() { _mfaStep = _MfaStep.idle; }); },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Active Sessions
            const Text('ACTIVE SESSIONS',
                style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2)),
            const SizedBox(height: 10),
            KCard(
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: AppColors.successLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.phone_android_rounded,
                        color: AppColors.success, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('This Device',
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                        Text(user?.email ?? '',
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                  const KBadge(
                    label: 'CURRENT',
                    variant: KBadgeVariant.success,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Change Password
            const Text('CHANGE PASSWORD',
                style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2)),
            const SizedBox(height: 10),
            KCard(
              child: Column(
                children: [
                  KTextField(
                    label: 'Current Password',
                    controller: _currentPassCtrl,
                    obscureText: _obscureCurrent,
                    textInputAction: TextInputAction.next,
                    suffix: IconButton(
                      icon: Icon(
                        _obscureCurrent
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscureCurrent = !_obscureCurrent),
                    ),
                  ),
                  const SizedBox(height: 12),
                  KTextField(
                    label: 'New Password',
                    controller: _newPassCtrl,
                    obscureText: _obscureNew,
                    textInputAction: TextInputAction.next,
                    suffix: IconButton(
                      icon: Icon(
                        _obscureNew
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscureNew = !_obscureNew),
                    ),
                  ),
                  const SizedBox(height: 12),
                  KTextField(
                    label: 'Confirm New Password',
                    controller: _confirmPassCtrl,
                    obscureText: _obscureConfirm,
                    textInputAction: TextInputAction.done,
                    suffix: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                      onPressed: () => setState(
                          () => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  const SizedBox(height: 16),
                  KButton(
                    label: 'Update Password',
                    onPressed: _changePassword,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
