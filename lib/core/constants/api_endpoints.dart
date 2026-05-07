import 'api_base.dart';

// Central constants — base URL resolves per platform (Android emulator vs desktop).
class ApiEndpoints {
  ApiEndpoints._();

  static String get base => resolveApiBase();

  // Auth
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String me = '/api/auth/me';

  // Places
  static const String places = '/api/places';
  static String placeDetail(int id) => '/api/places/$id';
  static const String weather = '/api/places/weather/current';

  // Favorites
  static const String favorites = '/api/favorites';
  static String deleteFavorite(int id) => '/api/favorites/$id';
}
