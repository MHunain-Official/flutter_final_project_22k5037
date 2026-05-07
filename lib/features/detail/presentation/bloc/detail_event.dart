import 'package:equatable/equatable.dart';

abstract class DetailEvent extends Equatable {
  const DetailEvent();
  @override
  List<Object?> get props => [];
}

class LoadWeather extends DetailEvent {
  final double lat;
  final double lon;
  const LoadWeather({this.lat = -43.89, this.lon = 170.48});
  @override
  List<Object?> get props => [lat, lon];
}
