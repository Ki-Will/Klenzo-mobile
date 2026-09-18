import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/k_button.dart';
import '../../../shared/widgets/k_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  // MFA state
  final _mfaCtrl = TextEditingController();
  bool _mfaLoading = false;
  String? _mfaError;

  final _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _mfaCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authProvider.notifier).login(
          _emailCtrl.text.trim(),
          _passCtrl.text,
        );
    if (ok && mounted) context.go('/home');
  }

  Future<void> _mfaSubmit() async {
    final code = _mfaCtrl.text.trim();
    if (code.length != 6 || !ref.read(authProvider).mfaRequired) return;

    setState(() { _mfaLoading = true; _mfaError = null; });

    final ok = await ref.read(authProvider.notifier).loginWithMfa(
          ref.read(authProvider).mfaToken!,
          code,
        );

    setState(() { _mfaLoading = false; });

    if (ok && mounted) context.go('/home');
    if (!ok && mounted) {
      setState(() { _mfaError = 'Invalid code — try again'; });
    }
  }

  Future<void> _googleLogin() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return; // user cancelled
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Google sign-in failed')),
          );
        }
        return;
      }

      final ok = await ref.read(authProvider.notifier).loginWithGoogle(idToken);
      if (ok && mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google sign-in failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;
    final mfaRequired = authState is AuthMfaRequired;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        gradient: AppColors.brandGradient,
                        borderRadius: BorderRadius.all(AppRadius.md),
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Klenzo',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Text('Welcome back',
                    style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 6),
                Text(
                  mfaRequired
                      ? 'Enter the code from your authenticator app'
                      : 'Sign in to your account to continue',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
                ),
                const SizedBox(height: 32),

                // ── Error banner ──
                if (authState is AuthError) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.dangerLight,
                      borderRadius: BorderRadius.all(AppRadius.md),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.danger, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(authState.message,
                              style: const TextStyle(
                                  color: AppColors.danger, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                if (mfaRequired) ...[
                  // ── MFA input ──
                  KTextField(
                    label: 'Authentication code',
                    hint: '000000',
                    controller: _mfaCtrl,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _mfaSubmit(),
                  ),
                  if (_mfaError != null) ...[
                    const SizedBox(height: 8),
                    Text(_mfaError!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                  ],
                  const SizedBox(height: 24),
                  KButton(
                    label: 'Verify',
                    onPressed: _mfaSubmit,
                    isLoading: _mfaLoading,
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(authProvider.notifier).logout();
                    },
                    child: const Text('Cancel'),
                  ),
                ] else ...[
                  // ── Email + password form ──
                  KTextField(
                    label: 'Email address',
                    hint: 'you@example.com',
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  KTextField(
                    label: 'Password',
                    hint: '••••••••',
                    controller: _passCtrl,
                    obscureText: _obscure,
                    validator: Validators.password,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    suffix: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textMuted,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Forgot password?'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  KButton(
                      label: 'Sign In', onPressed: _submit, isLoading: isLoading),

                  // ── Google sign-in button ──
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      onPressed: _googleLogin,
                      icon: const Icon(Icons.g_mobiledata_rounded, size: 22),
                      label: const Text('Continue with Google'),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? ",
                          style: TextStyle(color: AppColors.textSecondary)),
                      TextButton(
                        onPressed: () => context.push('/register'),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: const Text('Sign up'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
