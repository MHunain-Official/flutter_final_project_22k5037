import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/places_pagination.dart';
import '../../../../core/network/http_client.dart';
import '../models/place_model.dart';

/// One page from `GET /api/places` — includes server pagination metadata.
class PlacesRemotePage {
  final List<PlaceModel> places;
  final bool hasMore;
  final int? total;

  const PlacesRemotePage({
    required this.places,
    required this.hasMore,
    this.total,
  });
}

abstract class PlacesRemoteSource {
  Future<PlacesRemotePage> fetchPlaces({
    int page,
    int limit,
    String search,
  });
}

class PlacesRemoteSourceImpl implements PlacesRemoteSource {
  final Dio _dio;
  PlacesRemoteSourceImpl(this._dio);

  @override
  Future<PlacesRemotePage> fetchPlaces({
    int page = 1,
    int limit = kPlacesItemsPerBatch,
    String search = '',
  }) async {
    try {
      final res = await _dio.get(ApiEndpoints.places, queryParameters: {
        'page': page,
        'limit': limit,
        if (search.isNotEmpty) 'search': search,
      });
      final body = res.data as Map<String, dynamic>;
      final raw = body['data'] as List;
      final items = raw.cast<Map<String, dynamic>>();
      final places = items.map(PlaceModel.fromJson).toList();
      final hm = body['hasMore'];
      final hasMore = hm is bool
          ? hm
          : places.length >= limit;
      final total = (body['total'] as num?)?.toInt();
      return PlacesRemotePage(places: places, hasMore: hasMore, total: total);
    } on DioException catch (e) {
      throw HttpClient.handleDioError(e);
    }
  }
}
