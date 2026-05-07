import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/http_client.dart';
import '../models/favorite_item.dart';
import '../../../places/data/models/place_model.dart';

abstract class FavoritesRemoteSource {
  Future<List<FavoriteItem>> getFavorites();
  Future<void> addFavorite(PlaceModel place);
  Future<void> removeFavorite(int placeId);
}

class FavoritesRemoteSourceImpl implements FavoritesRemoteSource {
  final Dio _dio;
  FavoritesRemoteSourceImpl(this._dio);

  @override
  Future<List<FavoriteItem>> getFavorites() async {
    try {
      final res = await _dio.get(ApiEndpoints.favorites);
      return (res.data as List)
          .cast<Map<String, dynamic>>()
          .map(FavoriteItem.fromJson)
          .toList();
    } on DioException catch (e) {
      throw HttpClient.handleDioError(e);
    }
  }

  @override
  Future<void> addFavorite(PlaceModel place) async {
    try {
      await _dio.post(ApiEndpoints.favorites, data: {
        'placeId': place.id,
        'placeTitle': place.title,
        'placeThumbnailUrl': place.thumbnailUrl,
        'placeUrl': place.url,
      });
    } on DioException catch (e) {
      throw HttpClient.handleDioError(e);
    }
  }

  @override
  Future<void> removeFavorite(int placeId) async {
    try {
      await _dio.delete(ApiEndpoints.deleteFavorite(placeId));
    } on DioException catch (e) {
      throw HttpClient.handleDioError(e);
    }
  }
}
