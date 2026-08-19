import 'package:hive_flutter/hive_flutter.dart';

class LocalCache {
  static const String _cacheBoxName = 'local_cache';
  static const String _queueBoxName = 'offline_queue';

  static const String _balanceKey = 'wallet_balance';
  static const String _transactionsKey = 'recent_transactions';

  Future<void> saveCachedBalance(double balance) async {
    final box = Hive.box(_cacheBoxName);
    await box.put(_balanceKey, balance);
  }

  double getCachedBalance() {
    final box = Hive.box(_cacheBoxName);
    return box.get(_balanceKey, defaultValue: 0.0) as double;
  }

  Future<void> saveCachedTransactions(List<Map<String, dynamic>> transactions) async {
    final box = Hive.box(_cacheBoxName);
    await box.put(_transactionsKey, transactions);
  }

  List<Map<String, dynamic>> getCachedTransactions() {
    final box = Hive.box(_cacheBoxName);
    final rawList = box.get(_transactionsKey, defaultValue: []);
    if (rawList is List) {
      return rawList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  // ─── Offline Queue ──────────────────────────────────────────────────────────
  
  Future<void> enqueueTransfer(Map<String, dynamic> transferData) async {
    final box = Hive.box(_queueBoxName);
    await box.add(transferData);
  }

  List<Map<String, dynamic>> getQueuedTransfers() {
    final box = Hive.box(_queueBoxName);
    return box.values.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> removeQueuedTransfer(int index) async {
    final box = Hive.box(_queueBoxName);
    await box.deleteAt(index);
  }

  Future<void> clearQueue() async {
    final box = Hive.box(_queueBoxName);
    await box.clear();
  }
}
