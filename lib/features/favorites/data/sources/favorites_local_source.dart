import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite_item.dart';

abstract class FavoritesLocalSource {
  Future<void> saveFavorites(List<FavoriteItem> items);
  Future<List<FavoriteItem>> getCachedFavorites();
}

class FavoritesLocalSourceImpl implements FavoritesLocalSource {
  final SharedPreferences _prefs;
  FavoritesLocalSourceImpl(this._prefs);
  static const _key = 'cached_favorites';

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
}
