abstract class AppException implements Exception {
  final String message;
  final String prefix;

  AppException(this.message, this.prefix);

  @override
  String toString() {
    return '$prefix$message';
  }
}

class FetchDataException extends AppException {
  FetchDataException(String message) : super(message, 'Error During Communication: ');
}

class BadRequestException extends AppException {
  BadRequestException(String message) : super(message, 'Invalid Request: ');
}

class UnauthorizedException extends AppException {
  UnauthorizedException(String message) : super(message, 'Unauthorized: ');
}

class InvalidInputException extends AppException {
  InvalidInputException(String message) : super(message, 'Invalid Input: ');
}

class CacheException extends AppException {
  CacheException(String message) : super(message, 'Cache Failure: ');
}

class ConflictException extends AppException {
  ConflictException(String message) : super(message, 'Conflict Detected: ');
}
