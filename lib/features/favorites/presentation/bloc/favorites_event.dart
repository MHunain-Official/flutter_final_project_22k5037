import 'package:equatable/equatable.dart';
import '../../../places/data/models/place_model.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();
  @override
  List<Object?> get props => [];
}

class LoadFavorites extends FavoritesEvent {}

class ToggleFavoriteEvent extends FavoritesEvent {
  final PlaceModel place;
  const ToggleFavoriteEvent(this.place);
  @override
  List<Object?> get props => [place.id];
}
