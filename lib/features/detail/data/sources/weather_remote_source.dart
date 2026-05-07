import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/http_client.dart';
import '../models/weather_model.dart';

abstract class WeatherRemoteSource {
  Future<WeatherModel> getWeather(double lat, double lon);
}

class WeatherRemoteSourceImpl implements WeatherRemoteSource {
  final Dio _dio;
  WeatherRemoteSourceImpl(this._dio);

  @override
  Future<WeatherModel> getWeather(double lat, double lon) async {
    try {
      final res = await _dio.get(ApiEndpoints.weather, queryParameters: {
        'lat': lat,
        'lon': lon,
      });
      final data = res.data;
      if (data is! Map<String, dynamic>) {
        throw const ServerException('Invalid weather response');
      }
      if (data['current'] is! Map<String, dynamic>) {
        throw ServerException(
          (data['error']?.toString()) ?? 'Weather data unavailable',
        );
      }
      return WeatherModel.fromJson(data);
    } on DioException catch (e) {
      throw HttpClient.handleDioError(e);
    } catch (e) {
      throw ServerException('Weather parse failed: $e');
    }
  }
}
