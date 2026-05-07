// Low-level exceptions thrown in the data layer and caught by repositories
class AppException implements Exception {
  final String message;
  const AppException(this.message);
  @override
  String toString() => 'AppException: $message';
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Network unavailable']);
}

class ServerException extends AppException {
  final int? statusCode;
  const ServerException([super.message = 'Server error', this.statusCode]);
}

class AuthException extends AppException {
  const AuthException([super.message = 'Unauthorized']);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Cache read/write failed']);
}
