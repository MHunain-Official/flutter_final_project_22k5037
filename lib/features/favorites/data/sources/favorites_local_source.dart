import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite_item.dart';
import '../../../places/data/models/place_model.dart';

abstract class FavoritesLocalSource {
  Future<void> saveFavorites(List<FavoriteItem> items);
  Future<List<FavoriteItem>> getCachedFavorites();
  Future<void> toggleCachedFavorite(PlaceModel place);
  Future<void> enqueuePendingFavoriteToggle({
    required PlaceModel place,
    required bool shouldAdd,
  });
  Future<List<PendingFavoriteOp>> getPendingFavoriteOps();
  Future<void> removePendingFavoriteOp(int placeId);
}

class FavoritesLocalSourceImpl implements FavoritesLocalSource {
  final SharedPreferences _prefs;
  FavoritesLocalSourceImpl(this._prefs);
  static const _key = 'cached_favorites';
  static const _pendingOpsKey = 'pending_favorite_ops';

  @override
  Future<void> saveFavorites(List<FavoriteItem> items) async {
    final encoded = items
        .map((f) => {'place_id': f.placeId, 'place_title': f.placeTitle, 'place_thumbnail_url': f.thumbnailUrl})
        .toList();
    await _prefs.setString(_key, jsonEncode(encoded));
  }

  @override
  Future<List<FavoriteItem>> getCachedFavorites() {
    final raw = _prefs.getString(_key);
    if (raw == null) return Future.value([]);
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return Future.value(list.map(FavoriteItem.fromJson).toList());
  }

  @override
  Future<void> toggleCachedFavorite(PlaceModel place) async {
    final current = await getCachedFavorites();
    final exists = current.any((f) => f.placeId == place.id);
    final next = exists
        ? current.where((f) => f.placeId != place.id).toList()
        : [
            FavoriteItem.fromPlace(place),
            ...current,
          ];
    await saveFavorites(next);
  }

  @override
  Future<void> enqueuePendingFavoriteToggle({
    required PlaceModel place,
    required bool shouldAdd,
  }) async {
    final pending = await getPendingFavoriteOps();
    final existingIndex = pending.indexWhere((e) => e.placeId == place.id);
    final action = shouldAdd ? PendingFavoriteAction.add : PendingFavoriteAction.remove;

    if (existingIndex != -1) {
      final existing = pending[existingIndex];
      if (existing.action != action) {
        pending.removeAt(existingIndex); // Opposite toggle cancels the pending op.
      } else {
        pending[existingIndex] = PendingFavoriteOp.fromPlace(
          place,
          action: action,
        );
      }
    } else {
      pending.add(PendingFavoriteOp.fromPlace(place, action: action));
    }

    await _prefs.setString(
      _pendingOpsKey,
      jsonEncode(pending.map((e) => e.toJson()).toList()),
    );
  }

  @override
  Future<List<PendingFavoriteOp>> getPendingFavoriteOps() async {
    final raw = _prefs.getString(_pendingOpsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return list.map(PendingFavoriteOp.fromJson).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> removePendingFavoriteOp(int placeId) async {
    final pending = await getPendingFavoriteOps();
    pending.removeWhere((e) => e.placeId == placeId);
    await _prefs.setString(
      _pendingOpsKey,
      jsonEncode(pending.map((e) => e.toJson()).toList()),
    );
  }
}

enum PendingFavoriteAction { add, remove }

class PendingFavoriteOp {
  final int placeId;
  final PendingFavoriteAction action;
  final String placeTitle;
  final String thumbnailUrl;
  final String url;
  final int albumId;

  const PendingFavoriteOp({
    required this.placeId,
    required this.action,
    required this.placeTitle,
    required this.thumbnailUrl,
    required this.url,
    required this.albumId,
  });

  factory PendingFavoriteOp.fromPlace(
    PlaceModel place, {
    required PendingFavoriteAction action,
  }) {
    return PendingFavoriteOp(
      placeId: place.id,
      action: action,
      placeTitle: place.title,
      thumbnailUrl: place.thumbnailUrl,
      url: place.url,
      albumId: place.albumId,
    );
  }

  factory PendingFavoriteOp.fromJson(Map<String, dynamic> json) {
    return PendingFavoriteOp(
      placeId: (json['place_id'] as num).toInt(),
      action: (json['action'] as String) == 'add'
          ? PendingFavoriteAction.add
          : PendingFavoriteAction.remove,
      placeTitle: (json['place_title'] as String?) ?? '',
      thumbnailUrl: (json['place_thumbnail_url'] as String?) ?? '',
      url: (json['place_url'] as String?) ?? '',
      albumId: (json['album_id'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'place_id': placeId,
        'action': action == PendingFavoriteAction.add ? 'add' : 'remove',
        'place_title': placeTitle,
        'place_thumbnail_url': thumbnailUrl,
        'place_url': url,
        'album_id': albumId,
      };

  PlaceModel toPlaceModel() => PlaceModel(
        id: placeId,
        title: placeTitle,
        thumbnailUrl: placeThumbnailUrlOrFallback,
        url: placeUrlOrFallback,
        albumId: albumId,
      );

  String get placeThumbnailUrlOrFallback =>
      placeId > 0 ? PlaceModel.resolvedImageUrl(placeId, thumbnailUrl, thumbnail: true) : thumbnailUrl;

  String get placeUrlOrFallback =>
      placeId > 0 ? PlaceModel.resolvedImageUrl(placeId, url, thumbnail: false) : url;
}
