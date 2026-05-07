import 'package:dartz/dartz.dart';

import '../../../../core/constants/places_pagination.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../models/place_model.dart';
import '../models/places_fetch_result.dart';
import '../sources/places_remote_source.dart';
import '../sources/places_local_source.dart';

class PlacesRepositoryImpl {
  final PlacesRemoteSource _remote;
  final PlacesLocalSource _local;
  final NetworkInfo _network;

  PlacesRepositoryImpl(this._remote, this._local, this._network);

  /// Online → fetch and cache; offline → cache; on failure (page 1) → cache or demo sample.
  Future<Either<Failure, PlacesFetchResult>> getPlaces({
    int page = 1,
    int limit = kPlacesItemsPerBatch,
    String search = '',
  }) async {
    if (await _network.isConnected) {
      try {
        final pg = await _remote.fetchPlaces(page: page, limit: limit, search: search);
        if (page == 1 && search.isEmpty && pg.places.isNotEmpty) {
          await _local.cachePlaces(pg.places);
        }
        return Right(PlacesFetchResult(
          places: pg.places,
          isOffline: false,
          hasMore: pg.hasMore,
          total: pg.total,
        ));
      } on NetworkException {
        final recovered = await _recoverFromLocalOrDemo(page: page, limit: limit, search: search);
        if (recovered != null) return Right(recovered);
        return const Left(NetworkFailure());
      } on ServerException catch (e) {
        final recovered = await _recoverFromLocalOrDemo(page: page, limit: limit, search: search);
        if (recovered != null) return Right(recovered);
        return Left(ServerFailure(e.message));
      }
    } else {
      try {
        final cached = await _local.getCachedPlaces();
        final filtered = _filterBySearch(cached, search);
        final slice = _pageSlice(filtered, page, limit);
        final start = (page - 1) * limit;
        final hasMoreOffline = start + slice.length < filtered.length;
        if (slice.isEmpty && search.isNotEmpty) {
          return const Left(NetworkFailure('No cached places match your search while offline.'));
        }
        if (slice.isEmpty) {
          return Right(PlacesFetchResult(
            places: PlaceModel.demoPlaces,
            isOffline: true,
            hasMore: false,
            total: PlaceModel.demoPlaces.length,
          ));
        }
        return Right(PlacesFetchResult(
          places: slice,
          isOffline: true,
          hasMore: hasMoreOffline,
          total: filtered.length,
        ));
      } on CacheException catch (e) {
        if (page == 1 && search.isEmpty) {
          return const Right(PlacesFetchResult(
            places: PlaceModel.demoPlaces,
            isOffline: true,
            hasMore: false,
            total: 6,
          ));
        }
        return Left(CacheFailure(e.message));
      }
    }
  }

  Future<PlacesFetchResult?> _recoverFromLocalOrDemo({
    required int page,
    required int limit,
    required String search,
  }) async {
    if (page != 1) return null;
    try {
      final cached = await _local.getCachedPlaces();
      final filtered = _filterBySearch(cached, search);
      final slice = _pageSlice(filtered, page, limit);
      final start = (page - 1) * limit;
      if (slice.isNotEmpty) {
        return PlacesFetchResult(
          places: slice,
          isOffline: true,
          hasMore: start + slice.length < filtered.length,
          total: filtered.length,
        );
      }
    } on CacheException {
      // fall through to demo
    }
    if (search.isEmpty) {
      return const PlacesFetchResult(
        places: PlaceModel.demoPlaces,
        isOffline: true,
        hasMore: false,
        total: 6,
      );
    }
    return null;
  }

  List<PlaceModel> _filterBySearch(List<PlaceModel> list, String search) {
    if (search.isEmpty) return list;
    final q = search.toLowerCase();
    return list.where((p) => p.title.toLowerCase().contains(q)).toList();
  }

  List<PlaceModel> _pageSlice(List<PlaceModel> all, int page, int limit) {
    final start = (page - 1) * limit;
    if (start >= all.length) return [];
    return all.sublist(start, start + limit > all.length ? all.length : start + limit);
  }
}
