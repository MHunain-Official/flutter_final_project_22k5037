# Architecture — Smart Travel Companion

## Overview

The app follows **Clean Architecture** with a strict **feature-based folder structure**.  
Each feature owns three layers: `data`, `presentation`, and `ui`.

```
lib/
├── core/                         # Shared infrastructure
│   ├── constants/                # API endpoints, route names
│   ├── di/                       # Dependency injection (GetIt)
│   ├── errors/                   # Failures & exceptions
│   ├── network/                  # Dio HTTP client, connectivity
│   ├── routing/                  # GoRouter app router
│   └── theme/                    # AppTheme, AppColors
│
├── features/
│   ├── auth/
│   │   ├── data/                 # UserModel, remote/local sources, repository impl
│   │   ├── presentation/         # AuthBloc, events, states
│   │   └── ui/                   # LoginScreen, RegisterScreen
│   ├── places/
│   │   ├── data/                 # PlaceModel, remote/local sources, repository impl
│   │   ├── presentation/         # PlacesBloc, events, states
│   │   └── ui/                   # HomeScreen + widgets (PlaceCard, FilterChips)
│   ├── detail/
│   │   ├── data/                 # WeatherModel, WeatherRemoteSource, repository impl
│   │   ├── presentation/         # DetailBloc, events, states
│   │   └── ui/                   # DetailScreen, WeatherCard, ExpandableDescription
│   ├── favorites/
│   │   ├── data/                 # FavoriteItem, remote/local sources, repository impl
│   │   ├── presentation/         # FavoritesBloc, events, states
│   │   └── ui/                   # FavoritesScreen
│   ├── settings/
│   │   ├── presentation/         # SettingsBloc, events, states
│   │   └── ui/                   # SettingsScreen
│   └── map/
│       └── ui/                   # MapScreen (flutter_map + OpenStreetMap)
│
└── shared/
    └── widgets/                  # AppDrawer, EmptyStateWidget, OfflineBanner,
                                  # LoadingIndicator, PlaceCardShimmer
```

---

## SOLID Principles Applied

| Principle | Where |
|-----------|-------|
| **S** – Single Responsibility | Each Bloc handles exactly one feature. `NetworkInfo` only checks connectivity. `HttpClient` only builds Dio. |
| **O** – Open/Closed | `Failure` is an abstract class. New failure types are added by extending, not modifying. |
| **L** – Liskov Substitution | `PlacesRepositoryImpl` implements the abstract `PlacesRepository`. Any compliant impl can replace it. |
| **I** – Interface Segregation | `AuthRemoteSource` and `AuthLocalSource` are separate interfaces — remote handles HTTP, local handles secure storage. |
| **D** – Dependency Inversion | All Blocs depend on repository *abstractions*, not concrete implementations. `GetIt` wires the concrete classes at startup. |

---

## State Management — Bloc

Every feature has a `Bloc<Event, State>` pair:

```
Event  →  Bloc  →  State
```

- **AuthBloc**: `LoginRequested | RegisterRequested | LogoutRequested`  
- **PlacesBloc**: `LoadPlaces | LoadMorePlaces` (pagination with 400 ms debounce on search)  
- **DetailBloc**: `LoadDetail` (fetches weather from Open-Meteo via backend proxy)  
- **FavoritesBloc**: `LoadFavorites | ToggleFavoriteEvent` (syncs with PostgreSQL + Redis cache)  
- **SettingsBloc**: `LoadSettings | ToggleTheme` (persists to SharedPreferences)

---

## Navigation — GoRouter

Routes are defined in `AppRouter`. Global redirect logic checks the JWT token:

- **Unauthenticated** → redirect to `/login`
- **Authenticated visiting `/login` or `/register`** → redirect to `/home`

Named routes live in `RouteNames` constants.

---

## Error Handling

All repository methods return `Either<Failure, T>` (dartz).  
UI converts the `Left` side to an error state and shows `EmptyStateWidget` with a retry button.

```
Repository → Either<Failure, T>
Bloc       → fold(fail → emit(Error), ok → emit(Loaded))
UI         → BlocBuilder → show error widget or data
```

---

## Offline Support

1. `places_local_source.dart` caches the last successful response in `SharedPreferences`.
2. On network failure the repository returns the cached JSON and sets `isOffline: true` on the state.
3. `OfflineBanner` animates in at the top of HomeScreen when `isOffline == true`.
