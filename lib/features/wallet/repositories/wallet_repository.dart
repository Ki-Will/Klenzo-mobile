import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../../../core/errors/error_handler.dart';
import '../models/wallet_model.dart';

class WalletRepository {
  WalletRepository(this._dio);
  final Dio _dio;

  Future<List<Wallet>> getWallets() async {
    try {
      final res = await _dio.get(Endpoints.wallets);
      final list = (res.data as List);
      return list
          .map((e) => Wallet.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    }
  }

  Future<Wallet> getWallet(String id) async {
    try {
      final res = await _dio.get('${Endpoints.wallets}/$id');
      return Wallet.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    }
  }

  Future<List<Transaction>> getTransactions({
    String? walletId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await _dio.get(
        Endpoints.transactions,
        queryParameters: {
          if (walletId != null) 'walletId': walletId,
          'page': page,
          'limit': limit,
        },
      );
      final list = res.data['data'] as List? ?? res.data as List;
      return list
          .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    }
  }

  Future<Wallet> createWallet(
      {required String name, required String currency}) async {
    try {
      final res = await _dio
          .post(Endpoints.wallets, data: {'name': name, 'currency': currency});
      return Wallet.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    }
  }
}

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(ref.read(dioProvider));
});
