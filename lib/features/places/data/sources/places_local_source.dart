import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/place_model.dart';

abstract class PlacesLocalSource {
  Future<void> cachePlaces(List<PlaceModel> places);
  Future<List<PlaceModel>> getCachedPlaces();
  Future<List<PlaceModel>> getUserDestinations();
  Future<void> addUserDestination(PlaceModel place);
}

class PlacesLocalSourceImpl implements PlacesLocalSource {
  final SharedPreferences _prefs;
  PlacesLocalSourceImpl(this._prefs);

  static const _key = 'cached_places';
  static const _userDestinationsKey = 'user_destinations';

  /// Max pins stored locally (preferences size).
  static const _maxUserDestinations = 50;

  @override
  Future<void> cachePlaces(List<PlaceModel> places) async {
    final encoded = places
        .map((p) => p.toJson())
        .toList();
    await _prefs.setString(_key, jsonEncode(encoded));
  }

  @override
  Future<List<PlaceModel>> getCachedPlaces() {
    final raw = _prefs.getString(_key);
    if (raw == null) throw const CacheException('No cached places');
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return Future.value(list.map(PlaceModel.fromJson).toList());
  }

  @override
  Future<List<PlaceModel>> getUserDestinations() async {
    final raw = _prefs.getString(_userDestinationsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return list.map(PlaceModel.fromJson).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addUserDestination(PlaceModel place) async {
    final existing = await getUserDestinations();
    final merged = [place, ...existing.where((p) => p.id != place.id)]
        .take(_maxUserDestinations)
        .toList();
    await _prefs.setString(
      _userDestinationsKey,
      jsonEncode(merged.map((p) => p.toJson()).toList()),
    );
  }
}
