import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../places/data/models/place_model.dart';
import '../models/favorite_item.dart';
import '../sources/favorites_remote_source.dart';
import '../sources/favorites_local_source.dart';

class FavoritesRepositoryImpl {
  final FavoritesRemoteSource _remote;
  final FavoritesLocalSource _local;
  final NetworkInfo _network;

  FavoritesRepositoryImpl(this._remote, this._local, this._network);

  Future<Either<Failure, List<FavoriteItem>>> getFavorites() async {
    if (await _network.isConnected) {
      try {
        await _syncPendingFavoriteOps();
        final items = await _remote.getFavorites();
        await _local.saveFavorites(items);
        return Right(items);
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      final cached = await _local.getCachedFavorites();
      return Right(cached);
    }
  }

  Future<Either<Failure, Unit>> toggleFavorite(PlaceModel place) async {
    final cached = await _local.getCachedFavorites();
    final alreadyFav = cached.any((f) => f.placeId == place.id);
    final shouldAdd = !alreadyFav;

    if (!await _network.isConnected) {
      await _local.toggleCachedFavorite(place);
      await _local.enqueuePendingFavoriteToggle(place: place, shouldAdd: shouldAdd);
      return const Right(unit);
    }

    try {
      if (alreadyFav) {
        await _remote.removeFavorite(place.id);
      } else {
        await _remote.addFavorite(place);
      }
      await _local.toggleCachedFavorite(place);
      return const Right(unit);
    } on NetworkException {
      await _local.toggleCachedFavorite(place);
      await _local.enqueuePendingFavoriteToggle(place: place, shouldAdd: shouldAdd);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  Future<void> _syncPendingFavoriteOps() async {
    final pending = await _local.getPendingFavoriteOps();
    for (final op in pending) {
      if (op.action == PendingFavoriteAction.add) {
        await _remote.addFavorite(op.toPlaceModel());
      } else {
        await _remote.removeFavorite(op.placeId);
      }
      await _local.removePendingFavoriteOp(op.placeId);
    }
  }
}
