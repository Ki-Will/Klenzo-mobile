import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../repositories/transfer_repository.dart';
import '../models/transfer_model.dart';
import '../../wallet/providers/wallet_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/k_button.dart';
import '../../../shared/widgets/k_card.dart';
import '../../../shared/widgets/k_text_field.dart';

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _narrationCtrl = TextEditingController();

  String? _selectedWalletId;
  String? _selectedBankCode;
  BankAccount? _resolvedAccount;
  bool _isResolving = false;
  bool _isSending = false;
  String? _errorMsg;

  static const _banks = [
    {'name': 'Access Bank', 'code': '044'},
    {'name': 'GTBank', 'code': '058'},
    {'name': 'Zenith Bank', 'code': '057'},
    {'name': 'UBA', 'code': '033'},
    {'name': 'First Bank', 'code': '011'},
    {'name': 'Kuda', 'code': '090267'},
    {'name': 'Opay', 'code': '100004'},
  ];

  @override
  void dispose() {
    _accountCtrl.dispose();
    _amountCtrl.dispose();
    _narrationCtrl.dispose();
    super.dispose();
  }

  Future<void> _resolveAccount() async {
    if (_accountCtrl.text.length < 10 || _selectedBankCode == null) return;
    setState(() {
      _isResolving = true;
      _resolvedAccount = null;
    });
    try {
      final account =
          await ref.read(transferRepositoryProvider).resolveAccount(
                accountNumber: _accountCtrl.text,
                bankCode: _selectedBankCode!,
              );
      setState(() => _resolvedAccount = account);
    } catch (e) {
      setState(() => _errorMsg = e.toString());
    } finally {
      setState(() => _isResolving = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWalletId == null) {
      setState(() => _errorMsg = 'Please select a source wallet');
      return;
    }
    setState(() {
      _isSending = true;
      _errorMsg = null;
    });
    try {
      final response =
          await ref.read(transferRepositoryProvider).sendTransfer(
                TransferRequest(
                  fromWalletId: _selectedWalletId!,
                  toAccount: _accountCtrl.text,
                  amount: double.parse(_amountCtrl.text),
                  currency: 'NGN',
                  narration: _narrationCtrl.text.isEmpty
                      ? null
                      : _narrationCtrl.text,
                  bankCode: _selectedBankCode,
                ),
              );
      ref.invalidate(walletsProvider);
      ref.invalidate(transactionsProvider);
      if (mounted) _showSuccess(response);
    } catch (e) {
      setState(() => _errorMsg = e.toString());
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _showSuccess(TransferResponse response) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.successLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: AppColors.success, size: 32),
            ),
            const SizedBox(height: 16),
            Text('Transfer Sent!',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Your transfer is being processed.',
                style: TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(
                'Ref: ${response.reference ?? response.transactionId}',
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 12)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/home');
                },
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletsAsync = ref.watch(walletsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Send Money')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('From Wallet',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              walletsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text(e.toString(),
                    style: const TextStyle(color: AppColors.danger)),
                data: (wallets) => DropdownButtonFormField<String>(
                  value: _selectedWalletId,
                  hint: const Text('Select wallet'),
                  items: wallets
                      .map((w) => DropdownMenuItem(
                            value: w.id,
                            child: Text(
                                '${w.name} — ${w.balance.toStringAsFixed(2)} ${w.currency}'),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedWalletId = v),
                  validator: (v) => v == null ? 'Select a wallet' : null,
                ),
              ),
              const SizedBox(height: 20),
              const Text('Bank',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedBankCode,
                hint: const Text('Select bank'),
                items: _banks
                    .map((b) => DropdownMenuItem(
                          value: b['code'],
                          child: Text(b['name']!),
                        ))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedBankCode = v;
                    _resolvedAccount = null;
                  });
                  _resolveAccount();
                },
                validator: (v) => v == null ? 'Select a bank' : null,
              ),
              const SizedBox(height: 16),
              KTextField(
                label: 'Account Number',
                hint: '0123456789',
                controller: _accountCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (v) => Validators.required(v, 'Account number'),
                onChanged: (_) => _resolveAccount(),
              ),
              if (_isResolving)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: LinearProgressIndicator(color: AppColors.accent),
                ),
              if (_resolvedAccount != null) ...[
                const SizedBox(height: 8),
                KCard(
                  color: AppColors.accentSurface,
                  child: Row(
                    children: [
                      const Icon(Icons.verified_user_outlined,
                          color: AppColors.accent, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        _resolvedAccount!.accountName,
                        style: const TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              KTextField(
                label: 'Amount (NGN)',
                hint: '0.00',
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: Validators.amount,
              ),
              const SizedBox(height: 16),
              KTextField(
                label: 'Narration (optional)',
                hint: 'Payment for...',
                controller: _narrationCtrl,
                maxLines: 2,
              ),
              if (_errorMsg != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.dangerLight,
                    borderRadius: BorderRadius.all(AppRadius.md),
                  ),
                  child: Text(_errorMsg!,
                      style: const TextStyle(
                          color: AppColors.danger, fontSize: 13)),
                ),
              ],
              const SizedBox(height: 28),
              KButton(
                label: 'Send Money',
                onPressed: _submit,
                isLoading: _isSending,
                icon: Icons.send_rounded,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
