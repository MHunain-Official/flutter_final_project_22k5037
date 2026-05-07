import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/http_client.dart';
import '../network/network_info.dart';

// Feature: auth
import '../../features/auth/data/sources/auth_remote_source.dart';
import '../../features/auth/data/sources/auth_local_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// Feature: places
import '../../features/places/data/sources/places_remote_source.dart';
import '../../features/places/data/sources/places_local_source.dart';
import '../../features/places/data/repositories/places_repository_impl.dart';
import '../../features/places/presentation/bloc/places_bloc.dart';

// Feature: detail / weather
import '../../features/detail/data/sources/weather_remote_source.dart';
import '../../features/detail/data/repositories/detail_repository_impl.dart';
import '../../features/detail/presentation/bloc/detail_bloc.dart';

// Feature: favorites
import '../../features/favorites/data/sources/favorites_remote_source.dart';
import '../../features/favorites/data/sources/favorites_local_source.dart';
import '../../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../../features/favorites/presentation/bloc/favorites_bloc.dart';

// Feature: settings
import '../../features/settings/presentation/bloc/settings_bloc.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> setupDependencies() async {
  // --- External ---
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<Dio>(() => HttpClient.build(sl()));
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // --- Auth ---
  sl.registerLazySingleton<AuthRemoteSource>(() => AuthRemoteSourceImpl(sl()));
  sl.registerLazySingleton<AuthLocalSource>(() => AuthLocalSourceImpl(sl()));
  sl.registerLazySingleton(() => AuthRepositoryImpl(sl(), sl()));
  sl.registerFactory(() => AuthBloc(sl()));

  // --- Places ---
  sl.registerLazySingleton<PlacesRemoteSource>(() => PlacesRemoteSourceImpl(sl()));
  sl.registerLazySingleton<PlacesLocalSource>(() => PlacesLocalSourceImpl(sl()));
  sl.registerLazySingleton(() => PlacesRepositoryImpl(sl(), sl(), sl()));
  sl.registerFactory(() => PlacesBloc(sl()));

  // --- Detail / Weather ---
  sl.registerLazySingleton<WeatherRemoteSource>(() => WeatherRemoteSourceImpl(sl()));
  sl.registerLazySingleton(() => DetailRepositoryImpl(sl()));
  sl.registerFactory(() => DetailBloc(sl()));

  // --- Favorites ---
  sl.registerLazySingleton<FavoritesRemoteSource>(() => FavoritesRemoteSourceImpl(sl()));
  sl.registerLazySingleton<FavoritesLocalSource>(() => FavoritesLocalSourceImpl(sl()));
  sl.registerLazySingleton(() => FavoritesRepositoryImpl(sl(), sl(), sl()));
  sl.registerFactory(() => FavoritesBloc(sl()));

  // --- Settings ---
  sl.registerFactory(() => SettingsBloc(sl()));
}
