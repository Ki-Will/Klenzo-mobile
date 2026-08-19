import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../wallet/providers/wallet_provider.dart';
import '../../wallet/models/wallet_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/k_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final walletsAsync = ref.watch(walletsProvider);
    final totalAsync = ref.watch(totalBalanceProvider);
    final txAsync = ref.watch(transactionsProvider(null));

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.bgCard,
        onRefresh: () async {
          ref.invalidate(walletsProvider);
          ref.invalidate(transactionsProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: AppColors.bgBase,
              titleSpacing: AppSpacing.md,
              title: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      gradient: AppColors.brandGradient,
                      borderRadius: BorderRadius.all(AppRadius.md),
                    ),
                    child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text('Klenzo',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 18)),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      color: AppColors.textSecondary),
                  onPressed: () => context.push('/notifications'),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => context.push('/profile'),
                    child: CircleAvatar(
                      radius: 17,
                      backgroundColor: AppColors.accentSurface,
                      child: Text(
                        user?.firstName.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${user?.firstName ?? 'there'} 👋',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Your Financial Overview',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 20),

                    // Total balance
                    KGradientCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Balance',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 8),
                          totalAsync.when(
                            loading: () =>
                                const CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                            error: (_, __) => const Text('—',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 28)),
                            data: (total) => Text(
                              Formatters.currency(total),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              _QuickAction(
                                  icon: Icons.send_rounded,
                                  label: 'Send',
                                  onTap: () => context.push('/transfers')),
                              const SizedBox(width: 16),
                              _QuickAction(
                                  icon: Icons
                                      .account_balance_wallet_outlined,
                                  label: 'Wallets',
                                  onTap: () => context.push('/wallets')),
                              const SizedBox(width: 16),
                              _QuickAction(
                                  icon: Icons.people_outline_rounded,
                                  label: 'Payroll',
                                  onTap: () => context.push('/payroll')),
                              const SizedBox(width: 16),
                              _QuickAction(
                                  icon: Icons.shield_outlined,
                                  label: 'KYC',
                                  onTap: () => context.push('/kyc')),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Wallets row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('My Wallets',
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                        TextButton(
                          onPressed: () => context.push('/wallets'),
                          child: const Text('See all'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    walletsAsync.when(
                      loading: () => const SizedBox(
                          height: 100,
                          child:
                              Center(child: CircularProgressIndicator())),
                      error: (e, _) => Text(e.toString(),
                          style:
                              const TextStyle(color: AppColors.danger)),
                      data: (wallets) => SizedBox(
                        height: 110,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: wallets.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (ctx, i) =>
                              _SmallWalletCard(wallet: wallets[i]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Recent transactions
                    const Text('Recent Transactions',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    txAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text(e.toString(),
                          style:
                              const TextStyle(color: AppColors.danger)),
                      data: (txs) {
                        final recent = txs.take(5).toList();
                        if (recent.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text('No transactions yet',
                                  style: TextStyle(
                                      color: AppColors.textMuted)),
                            ),
                          );
                        }
                        return Column(
                          children: recent
                              .map((tx) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 8),
                                    child: _TxRow(tx: tx),
                                  ))
                              .toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: const BorderRadius.all(AppRadius.md),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallWalletCard extends StatelessWidget {
  final Wallet wallet;
  const _SmallWalletCard({required this.wallet});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: const BorderRadius.all(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(wallet.name,
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Formatters.currency(wallet.balance,
                    currency: wallet.currency),
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              Text(wallet.currency,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TxRow extends StatelessWidget {
  final Transaction tx;
  const _TxRow({required this.tx});
  bool get _isCredit => tx.type == 'credit' || tx.type == 'deposit';

  @override
  Widget build(BuildContext context) {
    return KCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _isCredit
                  ? AppColors.successLight
                  : AppColors.dangerLight,
              borderRadius: const BorderRadius.all(AppRadius.md),
            ),
            child: Icon(
              _isCredit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: _isCredit ? AppColors.success : AppColors.danger,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.description,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(Formatters.dateShort(tx.createdAt),
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
          Text(
            '${_isCredit ? '+' : '-'}${Formatters.currency(tx.amount, currency: tx.currency)}',
            style: TextStyle(
              color: _isCredit ? AppColors.success : AppColors.danger,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
