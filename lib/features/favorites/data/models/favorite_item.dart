import 'package:equatable/equatable.dart';
import '../../../places/data/models/place_model.dart';

class FavoriteItem extends Equatable {
  final int placeId;
  final String placeTitle;
  final String? thumbnailUrl;

  const FavoriteItem({
    required this.placeId,
    required this.placeTitle,
    this.thumbnailUrl,
  });

  factory FavoriteItem.fromJson(Map<String, dynamic> json) => FavoriteItem(
        placeId: json['place_id'] as int,
        placeTitle: json['place_title'] as String,
        thumbnailUrl: json['place_thumbnail_url'] as String?,
      );

  factory FavoriteItem.fromPlace(PlaceModel place) => FavoriteItem(
        placeId: place.id,
        placeTitle: place.title,
        thumbnailUrl: place.thumbnailUrl,
      );

  @override
  List<Object?> get props => [placeId];
}
