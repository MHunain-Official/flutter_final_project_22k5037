import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_endpoints.dart';
import '../errors/exceptions.dart';

// Builds and configures the single Dio instance used by all data sources
class HttpClient {
  static Dio build(SharedPreferences prefs) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.base,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Attach JWT token to every request if one is stored
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = prefs.getString('jwt_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            throw AuthException('Session expired, please log in again');
          }
          handler.next(error);
        },
      ),
    );

    return dio;
  }

  // Map DioException → AppException (keeps data sources clean)
  static AppException handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const NetworkException();
    }
    final code = e.response?.statusCode;
    if (code == 401) return const AuthException();
    final msg = e.response?.data?['error'] ?? e.message ?? 'Unknown error';
    return ServerException(msg.toString(), code);
  }
}
