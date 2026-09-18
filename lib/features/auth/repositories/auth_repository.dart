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

  /// Returns [AuthResponse] on success or [MfaChallenge] if MFA is required.
  Future<LoginResult> login(LoginRequest req) async {
    try {
      final res = await _dio.post(
        Endpoints.login,
        data: req.toJson(),
      );
      final data = res.data as Map<String, dynamic>;

      if (data['mfaRequired'] == true) {
        return MfaChallenge.fromJson(data);
      }

      final authResponse = AuthResponse.fromJson(data);
      await _persistTokens(authResponse.tokens);
      return authResponse;
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    }
  }

  /// Completes the MFA second step of login.
  Future<AuthResponse> loginMfa(String mfaToken, String code) async {
    try {
      final res = await _dio.post(
        Endpoints.loginMfa,
        data: {'mfaToken': mfaToken, 'code': code},
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
      final res = await _dio.get(Endpoints.profile);
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

  // ── Google OAuth ──────────────────────────────────────────────────────────

  /// Exchange a Google ID token for Klenzo tokens.
  /// Returns [AuthResponse] or [MfaChallenge] if the user has MFA enabled.
  Future<LoginResult> googleLogin(String idToken) async {
    try {
      final res = await _dio.post(
        Endpoints.googleToken,
        data: {'idToken': idToken},
      );
      final data = res.data as Map<String, dynamic>;

      if (data['mfaRequired'] == true) {
        return MfaChallenge.fromJson(data);
      }

      final authResponse = AuthResponse.fromJson(data);
      await _persistTokens(authResponse.tokens);
      return authResponse;
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    }
  }

  // ── MFA management ───────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getMfaStatus() async {
    try {
      final res = await _dio.get(Endpoints.mfaStatus);
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> setupMfa() async {
    try {
      final res = await _dio.post(Endpoints.mfaSetup);
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    }
  }

  Future<void> enableMfa(String code) async {
    try {
      await _dio.post(
        Endpoints.mfaEnable,
        data: {'code': code},
      );
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    }
  }

  Future<void> disableMfa(String code) async {
    try {
      await _dio.post(
        Endpoints.mfaDisable,
        data: {'code': code},
      );
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

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
