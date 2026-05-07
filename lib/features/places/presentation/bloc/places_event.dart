import 'package:equatable/equatable.dart';

abstract class PlacesEvent extends Equatable {
  const PlacesEvent();
  @override
  List<Object?> get props => [];
}

// Load first page (or refresh)
class LoadPlaces extends PlacesEvent {
  final String search;
  const LoadPlaces({this.search = ''});
  @override
  List<Object?> get props => [search];
}

// Load next page for pagination
class LoadMorePlaces extends PlacesEvent {}
