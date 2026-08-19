import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../../../core/errors/error_handler.dart';
import '../models/transfer_model.dart';

class TransferRepository {
  TransferRepository(this._dio);
  final Dio _dio;

  Future<BankAccount> resolveAccount({
    required String accountNumber,
    required String bankCode,
  }) async {
    try {
      final res = await _dio.post('${Endpoints.transfers}/resolve', data: {
        'accountNumber': accountNumber,
        'bankCode': bankCode,
      });
      return BankAccount.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    }
  }

  Future<TransferResponse> sendTransfer(TransferRequest req) async {
    try {
      final res =
          await _dio.post(Endpoints.transfers, data: req.toJson());
      return TransferResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    }
  }
}

final transferRepositoryProvider = Provider<TransferRepository>((ref) {
  return TransferRepository(ref.read(dioProvider));
});
