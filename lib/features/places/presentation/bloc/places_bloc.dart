import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/places_pagination.dart';
import '../../data/repositories/places_repository_impl.dart';
import 'places_event.dart';
import 'places_state.dart';

class PlacesBloc extends Bloc<PlacesEvent, PlacesState> {
  final PlacesRepositoryImpl _repo;
  int _page = 1;

  PlacesBloc(this._repo) : super(PlacesInitial()) {
    on<LoadPlaces>(_onLoad);
    on<LoadMorePlaces>(_onLoadMore);
  }

  Future<void> _onLoad(LoadPlaces e, Emitter<PlacesState> emit) async {
    emit(PlacesLoading());
    _page = 1;

    final result = await _repo.getPlaces(
      page: 1,
      limit: kPlacesItemsPerBatch,
      search: e.search,
    );
    result.fold(
      (fail) => emit(PlacesError(fail.message)),
      (r) => emit(PlacesLoaded(
        places: r.places,
        hasMore: r.hasMore,
        catalogTotal: r.total,
        isOffline: r.isOffline,
        search: e.search,
        itemsPerBatch: kPlacesItemsPerBatch,
        loadedRemotePages: 1,
      )),
    );
  }

  Future<void> _onLoadMore(LoadMorePlaces e, Emitter<PlacesState> emit) async {
    final current = state;
    if (current is! PlacesLoaded || current.isLoadingMore || !current.hasMore) return;

    emit(current.copyWith(isLoadingMore: true));
    _page++;

    final result = await _repo.getPlaces(
      page: _page,
      limit: kPlacesItemsPerBatch,
      search: current.search,
    );
    result.fold(
      (fail) => emit(current.copyWith(isLoadingMore: false)),
      (r) => emit(current.copyWith(
        places: [...current.places, ...r.places],
        isLoadingMore: false,
        hasMore: r.hasMore,
        catalogTotal: r.total ?? current.catalogTotal,
        isOffline: current.isOffline || r.isOffline,
        loadedRemotePages: _page,
      )),
    );
  }
}
