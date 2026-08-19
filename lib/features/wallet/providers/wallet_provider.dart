import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wallet_model.dart';
import '../repositories/wallet_repository.dart';

// ── Wallets List ─────────────────────────────────────────────────────────
final walletsProvider = FutureProvider<List<Wallet>>((ref) {
  return ref.watch(walletRepositoryProvider).getWallets();
});

// ── Selected wallet id ──────────────────────────────────────────────────
final selectedWalletIdProvider = StateProvider<String?>((ref) => null);

// ── Transactions ────────────────────────────────────────────────────────
final transactionsProvider =
    FutureProvider.family<List<Transaction>, String?>((ref, walletId) {
  return ref
      .watch(walletRepositoryProvider)
      .getTransactions(walletId: walletId);
});

// ── Total balance across all wallets ────────────────────────────────────
final totalBalanceProvider = Provider<AsyncValue<double>>((ref) {
  return ref.watch(walletsProvider).whenData(
        (wallets) => wallets.fold(0.0, (sum, w) => sum + w.balance),
      );
});
