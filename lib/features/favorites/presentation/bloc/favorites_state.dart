import 'package:equatable/equatable.dart';
import '../../data/models/favorite_item.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();
  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {}
class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<FavoriteItem> items;
  // Quick lookup set for O(1) checks in home screen
  final Set<int> placeIds;

  FavoritesLoaded(this.items) : placeIds = items.map((f) => f.placeId).toSet();

  @override
  List<Object?> get props => [items];
}

class FavoritesError extends FavoritesState {
  final String message;
  const FavoritesError(this.message);
  @override
  List<Object?> get props => [message];
}
