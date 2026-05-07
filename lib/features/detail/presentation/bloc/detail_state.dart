import 'package:equatable/equatable.dart';
import '../../data/models/weather_model.dart';

abstract class DetailState extends Equatable {
  const DetailState();
  @override
  List<Object?> get props => [];
}

class DetailInitial extends DetailState {}
class DetailLoading extends DetailState {}

class DetailLoaded extends DetailState {
  final WeatherModel weather;
  const DetailLoaded(this.weather);
  @override
  List<Object?> get props => [weather];
}

class DetailError extends DetailState {
  final String message;
  const DetailError(this.message);
  @override
  List<Object?> get props => [message];
}
