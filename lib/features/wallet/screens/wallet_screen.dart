import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/wallet_provider.dart';
import '../repositories/wallet_repository.dart';
import '../models/wallet_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/k_badge.dart';
import '../../../shared/widgets/k_card.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'New wallet',
            onPressed: () => _showCreateWallet(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.bgCard,
        onRefresh: () => ref.refresh(walletsProvider.future),
        child: walletsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(e.toString(),
                  style: const TextStyle(color: AppColors.danger),
                  textAlign: TextAlign.center),
            ),
          ),
          data: (wallets) => wallets.isEmpty
              ? ListView(children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.account_balance_wallet_outlined,
                            color: AppColors.textMuted, size: 56),
                        SizedBox(height: 16),
                        Text('No wallets yet',
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                        SizedBox(height: 8),
                        Text('Tap + to create your first wallet',
                            style: TextStyle(color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ])
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: wallets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) => _WalletCard(wallet: wallets[i]),
                ),
        ),
      ),
    );
  }

  void _showCreateWallet(BuildContext ctx, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    String selectedCurrency = 'NGN';
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx2, setState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx2).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New Wallet', style: Theme.of(ctx2).textTheme.titleLarge),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Wallet name'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCurrency,
                decoration: const InputDecoration(labelText: 'Currency'),
                items: ['NGN', 'USD', 'GBP', 'EUR']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => selectedCurrency = v!),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    await ref.read(walletRepositoryProvider).createWallet(
                          name: nameCtrl.text,
                          currency: selectedCurrency,
                        );
                    ref.invalidate(walletsProvider);
                    if (ctx2.mounted) Navigator.pop(ctx2);
                  },
                  child: const Text('Create Wallet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final Wallet wallet;
  const _WalletCard({required this.wallet});

  @override
  Widget build(BuildContext context) {
    return KGradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(wallet.name,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              KBadge(
                label: wallet.status.toUpperCase(),
                variant: wallet.status == 'active'
                    ? KBadgeVariant.success
                    : KBadgeVariant.warning,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            Formatters.currency(wallet.balance, currency: wallet.currency),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(wallet.currency,
              style: const TextStyle(color: Colors.white54, fontSize: 13)),
          if (wallet.accountNumber != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.account_balance_outlined,
                    color: Colors.white54, size: 14),
                const SizedBox(width: 6),
                Text(
                    '${wallet.bankName ?? ''} • ${wallet.accountNumber}',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
