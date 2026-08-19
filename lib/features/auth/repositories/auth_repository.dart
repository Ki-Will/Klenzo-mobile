import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/auth_model.dart';

class AuthRepository {
  AuthRepository(this._dio, this._storage);

  final Dio _dio;
  final SecureStorage _storage;

  Future<AuthResponse> login(LoginRequest req) async {
    try {
      final res = await _dio.post(
        Endpoints.login,
        data: req.toJson(),
      );
      final authResponse = AuthResponse.fromJson(res.data as Map<String, dynamic>);
      await _persistTokens(authResponse.tokens);
      return authResponse;
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    }
  }

  Future<AuthResponse> register(RegisterRequest req) async {
    try {
      final res = await _dio.post(
        Endpoints.register,
        data: req.toJson(),
      );
      final authResponse = AuthResponse.fromJson(res.data as Map<String, dynamic>);
      await _persistTokens(authResponse.tokens);
      return authResponse;
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    }
  }

  Future<AuthUser> getMe() async {
    try {
      final res = await _dio.get(Endpoints.me);
      return AuthUser.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(Endpoints.logout);
    } catch (_) {
      // best-effort
    } finally {
      await _storage.clearAll();
    }
  }

  Future<void> _persistTokens(AuthTokens tokens) async {
    await _storage.saveAccessToken(tokens.accessToken);
    await _storage.saveRefreshToken(tokens.refreshToken);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.read(dioProvider),
    ref.read(secureStorageProvider),
  );
});
