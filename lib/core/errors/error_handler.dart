import 'package:dio/dio.dart';
import 'app_exception.dart';

class ErrorHandler {
  /// Convert a DioException into a typed AppException.
  static AppException fromDio(DioException dioError) {
    final status = dioError.response?.statusCode;
    final message = getMessage(dioError);

    switch (status) {
      case 400:
        return BadRequestException(message);
      case 401:
        return UnauthorizedException(message);
      case 403:
        return UnauthorizedException(message);
      case 404:
        return FetchDataException(message);
      case 409:
        return ConflictException(message);
      default:
        return FetchDataException(message);
    }
  }

  static String getMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Network timeout. Please check your internet connection.';
        case DioExceptionType.badResponse:
          final status = error.response?.statusCode;
          final data = error.response?.data;
          
          String serverMessage = '';
          if (data is Map) {
            final msg = data['message'];
            if (msg is List) {
              serverMessage = msg.join(', ');
            } else {
              serverMessage = msg?.toString() ?? '';
            }
          }

          if (status == 400) {
            return serverMessage.isNotEmpty ? serverMessage : 'Bad request. Please check input parameters.';
          } else if (status == 401) {
            return serverMessage.isNotEmpty ? serverMessage : 'Incorrect email or password.';
          } else if (status == 403) {
            return serverMessage.isNotEmpty ? serverMessage : 'Access denied. Compliance verification may be required.';
          } else if (status == 404) {
            return serverMessage.isNotEmpty ? serverMessage : 'Resource not found.';
          } else if (status == 409) {
            return serverMessage.isNotEmpty ? serverMessage : 'A conflict occurred. Check duplicate requests.';
          } else if (status == 500) {
            return 'Internal server error. Our engineers are investigating.';
          }
          return 'HTTP error $status: ${error.message}';
        case DioExceptionType.cancel:
          return 'Request cancelled.';
        case DioExceptionType.connectionError:
          return 'No internet connection. Checked cached data.';
        default:
          return 'An unexpected network error occurred.';
      }
    } else if (error is AppException) {
      return error.message;
    }
    return error?.toString() ?? 'An unknown error occurred.';
  }
}
