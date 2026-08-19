import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/wallet_provider.dart';
import '../models/wallet_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/k_badge.dart';
import '../../../shared/widgets/k_card.dart';

class TransactionsScreen extends ConsumerWidget {
  final String? walletId;
  const TransactionsScreen({super.key, this.walletId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(transactionsProvider(walletId));

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.bgCard,
        onRefresh: () => ref.refresh(transactionsProvider(walletId).future),
        child: txAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
              child: Text(e.toString(),
                  style: const TextStyle(color: AppColors.danger))),
          data: (txs) => txs.isEmpty
              ? ListView(children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            color: AppColors.textMuted, size: 52),
                        SizedBox(height: 14),
                        Text('No transactions yet',
                            style: TextStyle(color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ])
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: txs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) => _TxTile(tx: txs[i]),
                ),
        ),
      ),
    );
  }
}

class _TxTile extends StatelessWidget {
  final Transaction tx;
  const _TxTile({required this.tx});

  bool get _isCredit => tx.type == 'credit' || tx.type == 'deposit';

  KBadgeVariant get _badgeVariant => switch (tx.status) {
        'completed' || 'success' => KBadgeVariant.success,
        'pending' => KBadgeVariant.warning,
        'failed' => KBadgeVariant.danger,
        _ => KBadgeVariant.neutral,
      };

  @override
  Widget build(BuildContext context) {
    return KCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color:
                  _isCredit ? AppColors.successLight : AppColors.dangerLight,
              borderRadius: const BorderRadius.all(AppRadius.md),
            ),
            child: Icon(
              _isCredit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: _isCredit ? AppColors.success : AppColors.danger,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.description,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(Formatters.dateShort(tx.createdAt),
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_isCredit ? '+' : '-'}${Formatters.currency(tx.amount, currency: tx.currency)}',
                style: TextStyle(
                  color: _isCredit ? AppColors.success : AppColors.danger,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              KBadge(label: tx.status, variant: _badgeVariant),
            ],
          ),
        ],
      ),
    );
  }
}
