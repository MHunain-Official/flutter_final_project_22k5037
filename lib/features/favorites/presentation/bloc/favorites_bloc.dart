import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/favorites_repository_impl.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesRepositoryImpl _repo;
  FavoritesBloc(this._repo) : super(FavoritesInitial()) {
    on<LoadFavorites>(_onLoad);
    on<ToggleFavoriteEvent>(_onToggle);
  }

  Future<void> _onLoad(LoadFavorites e, Emitter<FavoritesState> emit) async {
    emit(FavoritesLoading());
    final result = await _repo.getFavorites();
    result.fold(
      (fail) => emit(FavoritesError(fail.message)),
      (items) => emit(FavoritesLoaded(items)),
    );
  }

  Future<void> _onToggle(ToggleFavoriteEvent e, Emitter<FavoritesState> emit) async {
    final result = await _repo.toggleFavorite(e.place);
    result.fold(
      (_) {}, // silently ignore toggle errors — optimistic UI from PlacesBloc
      (_) => add(LoadFavorites()), // refresh the list on success
    );
  }
}
