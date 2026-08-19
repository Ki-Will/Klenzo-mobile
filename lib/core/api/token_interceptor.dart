import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage.dart';
import 'endpoints.dart';
import '../../features/auth/providers/auth_provider.dart';

class TokenInterceptor extends Interceptor {
  final Ref ref;
  final _secureStorage = SecureStorage();
  late final Dio _refreshDio;

  TokenInterceptor(this.ref) {
    _refreshDio = Dio(BaseOptions(baseUrl: Endpoints.baseUrl));
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secureStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final isAuthRoute = err.requestOptions.path.contains('/auth/login') ||
          err.requestOptions.path.contains('/auth/register') ||
          err.requestOptions.path.contains('/auth/refresh');

      if (!isAuthRoute) {
        final refreshed = await _refreshToken();
        if (refreshed) {
          try {
            final response = await _retryRequest(err.requestOptions);
            return handler.resolve(response);
          } catch (e) {
            return handler.reject(DioException(
              requestOptions: err.requestOptions,
              error: e,
            ));
          }
        } else {
          // Force logout
          await ref.read(authProvider.notifier).logout();
          return handler.reject(err);
        }
      }
    }
    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _refreshDio.post(
        Endpoints.refresh,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newAccessToken = response.data['accessToken'];
        final newRefreshToken = response.data['refreshToken'];

        if (newAccessToken != null && newRefreshToken != null) {
          await _secureStorage.saveAccessToken(newAccessToken);
          await _secureStorage.saveRefreshToken(newRefreshToken);
          return true;
        }
      }
    } catch (_) {
      // Refresh token request failed
    }
    return false;
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions) async {
    final token = await _secureStorage.getAccessToken();
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $token',
      },
    );

    final dio = Dio(BaseOptions(baseUrl: Endpoints.baseUrl));
    return dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}
