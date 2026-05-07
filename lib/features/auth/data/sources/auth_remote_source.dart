import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/http_client.dart';
import '../models/user_model.dart';

// Contract — depends on abstraction (SOLID: DIP)
abstract class AuthRemoteSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register(String name, String email, String password);
  Future<UserModel> getMe();
}

class AuthRemoteSourceImpl implements AuthRemoteSource {
  final Dio _dio;
  AuthRemoteSourceImpl(this._dio);

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await _dio.post(ApiEndpoints.login, data: {
        'email': email,
        'password': password,
      });
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw HttpClient.handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final res = await _dio.post(ApiEndpoints.register, data: {
        'name': name,
        'email': email,
        'password': password,
      });
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw HttpClient.handleDioError(e);
    }
  }

  @override
  Future<UserModel> getMe() async {
    try {
      final res = await _dio.get(ApiEndpoints.me);
      return UserModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw HttpClient.handleDioError(e);
    }
  }
}
