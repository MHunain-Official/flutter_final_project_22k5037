import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/route_names.dart';
import '../di/injection.dart';
import '../../features/auth/data/sources/auth_local_source.dart';
import '../../features/auth/ui/login_screen.dart';
import '../../features/auth/ui/register_screen.dart';
import '../../features/places/ui/add_destination_screen.dart';
import '../../features/places/ui/home_screen.dart';
import '../../features/detail/ui/detail_screen.dart';
import '../../features/places/data/models/place_model.dart';
import '../../features/favorites/ui/favorites_screen.dart';
import '../../features/map/ui/map_screen.dart';
import '../../features/settings/ui/settings_screen.dart';
import '../../shared/ui/about_developer_screen.dart';
import '../../shared/ui/help_support_screen.dart';

class AppRouter {
  AppRouter._();

  static GoRouter build() {
    return GoRouter(
      initialLocation: RouteNames.splash,
      redirect: _globalRedirect,
      routes: [
        // Splash → decides where to go
        GoRoute(
          path: RouteNames.splash,
          builder: (_, __) => const _SplashRedirector(),
        ),
        GoRoute(
          path: RouteNames.login,
          builder: (_, __) => const LoginScreen(),
        ),
        GoRoute(
          path: RouteNames.register,
          builder: (_, __) => const RegisterScreen(),
        ),
        GoRoute(
          path: RouteNames.home,
          builder: (_, __) => const HomeScreen(),
        ),
        GoRoute(
          path: RouteNames.addDestination,
          builder: (_, __) => const AddDestinationScreen(),
        ),
        GoRoute(
          path: RouteNames.detail,
          builder: (context, state) {
            final place = state.extra as PlaceModel;
            return DetailScreen(place: place);
          },
        ),
        GoRoute(
          path: RouteNames.favorites,
          builder: (_, __) => const FavoritesScreen(),
        ),
        GoRoute(
          path: RouteNames.map,
          builder: (_, __) => const MapScreen(),
        ),
        GoRoute(
          path: RouteNames.settings,
          builder: (_, __) => const SettingsScreen(),
        ),
        GoRoute(
          path: RouteNames.about,
          builder: (_, __) => const AboutDeveloperScreen(),
        ),
        GoRoute(
          path: RouteNames.helpSupport,
          builder: (_, __) => const HelpSupportScreen(),
        ),
      ],
    );
  }

  static Future<String?> _globalRedirect(BuildContext ctx, GoRouterState state) async {
    final local = sl<AuthLocalSource>();
    final hasToken = await local.getToken() != null;
    final location = state.matchedLocation;

    // Splash must always resolve; it is not a destination that "stays" loaded.
    if (location == RouteNames.splash) {
      return hasToken ? RouteNames.home : RouteNames.login;
    }

    final onAuth = location == RouteNames.login || location == RouteNames.register;

    if (!hasToken && !onAuth) return RouteNames.login;
    if (hasToken && onAuth) return RouteNames.home;
    return null;
  }
}

// Tiny widget — just triggers the redirect logic on first frame
class _SplashRedirector extends StatelessWidget {
  const _SplashRedirector();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
