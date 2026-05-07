import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/detail_repository_impl.dart';
import 'detail_event.dart';
import 'detail_state.dart';

class DetailBloc extends Bloc<DetailEvent, DetailState> {
  final DetailRepositoryImpl _repo;
  DetailBloc(this._repo) : super(DetailInitial()) {
    on<LoadWeather>(_onLoad);
  }

  Future<void> _onLoad(LoadWeather e, Emitter<DetailState> emit) async {
    emit(DetailLoading());
    final result = await _repo.getWeather(lat: e.lat, lon: e.lon);
    result.fold(
      (fail) => emit(DetailError(fail.message)),
      (weather) => emit(DetailLoaded(weather)),
    );
  }
}
