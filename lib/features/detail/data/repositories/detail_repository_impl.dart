import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../models/weather_model.dart';
import '../sources/weather_remote_source.dart';

class DetailRepositoryImpl {
  final WeatherRemoteSource _weatherSource;
  DetailRepositoryImpl(this._weatherSource);

  // Default coords: New Zealand (matches the Lake Tekapo hero in design)
  Future<Either<Failure, WeatherModel>> getWeather({
    double lat = -43.89,
    double lon = 170.48,
  }) async {
    try {
      final weather = await _weatherSource.getWeather(lat, lon);
      return Right(weather);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
