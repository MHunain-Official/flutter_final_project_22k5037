import 'package:equatable/equatable.dart';
import '../../data/models/place_model.dart';

abstract class PlacesState extends Equatable {
  const PlacesState();
  @override
  List<Object?> get props => [];
}

class PlacesInitial extends PlacesState {}

class PlacesLoading extends PlacesState {}

class PlacesLoaded extends PlacesState {
  final List<PlaceModel> places;
  final bool isLoadingMore;
  final bool hasMore;
  final bool isOffline;
  final String search;
  /// Total items in catalog (from API `total`), when known.
  final int? catalogTotal;

  /// How many items each remote page load requests (see `places_pagination.dart`).
  final int itemsPerBatch;

  /// Highest page index successfully loaded from the backend (starts at 1).
  final int loadedRemotePages;

  const PlacesLoaded({
    required this.places,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.isOffline = false,
    this.search = '',
    this.catalogTotal,
    required this.itemsPerBatch,
    this.loadedRemotePages = 1,
  });

  PlacesLoaded copyWith({
    List<PlaceModel>? places,
    bool? isLoadingMore,
    bool? hasMore,
    bool? isOffline,
    String? search,
    int? catalogTotal,
    bool clearCatalogTotal = false,
    int? itemsPerBatch,
    int? loadedRemotePages,
  }) =>
      PlacesLoaded(
        places: places ?? this.places,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasMore: hasMore ?? this.hasMore,
        isOffline: isOffline ?? this.isOffline,
        search: search ?? this.search,
        catalogTotal:
            clearCatalogTotal ? null : (catalogTotal ?? this.catalogTotal),
        itemsPerBatch: itemsPerBatch ?? this.itemsPerBatch,
        loadedRemotePages: loadedRemotePages ?? this.loadedRemotePages,
      );

  @override
  List<Object?> get props => [
        places,
        isLoadingMore,
        hasMore,
        isOffline,
        search,
        catalogTotal,
        itemsPerBatch,
        loadedRemotePages,
      ];
}

class PlacesError extends PlacesState {
  final String message;
  const PlacesError(this.message);
  @override
  List<Object?> get props => [message];
}
