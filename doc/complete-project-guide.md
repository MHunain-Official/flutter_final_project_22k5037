# Smart Travel Companion - Complete Project Guide

This document explains the full project in one place: architecture, folder strategy, state management, data flow, backend integration, and the purpose of each important file.

---

## 1) Project Approach

The app uses a **feature-first modular architecture** with **Bloc** for state management and a lightweight clean separation:

- **UI layer**: widgets/screens only, no direct HTTP or DB logic.
- **Presentation layer**: Bloc + Events + States (orchestrates flows).
- **Data layer**: repositories + sources (remote/local) + models.
- **Core layer**: shared infrastructure (routing, DI, theme, network, errors, constants).
- **Server layer**: Express API + PostgreSQL + Redis + external API proxying.

Why this approach:

- Scales feature by feature.
- Easier to test and maintain.
- Reuse of shared infra (`Dio`, routing, theme, errors, DI).
- Clear boundaries: UI asks Bloc, Bloc asks repository, repository asks sources.

---

## 2) State Management

State management is **`flutter_bloc`**.

Pattern:

1. UI dispatches an Event.
2. Bloc handles the Event.
3. Bloc emits State.
4. UI reacts via `BlocBuilder` / `BlocListener`.

Blocs in this project:

- `AuthBloc`: login/register/logout.
- `PlacesBloc`: first load, search, pagination, load-more.
- `DetailBloc`: weather loading for place detail.
- `FavoritesBloc`: fetch/toggle favorites.
- `SettingsBloc`: dark mode persistence.

Why Bloc:

- Predictable unidirectional flow.
- Keeps screens thin.
- Good async/error handling with explicit states.

---

## 3) End-to-End Data Flow

### Places flow

`HomeScreen` -> `LoadPlaces` -> `PlacesBloc` -> `PlacesRepositoryImpl` -> `PlacesRemoteSource` (`/api/places`) -> `PlacesLoaded`.

Fallback path:

- If network fails/offline, repository checks local cache in `SharedPreferences`.
- Returns `isOffline=true`.
- UI shows `OfflineBanner`.

### Auth flow

`LoginScreen/RegisterScreen` -> `AuthBloc` -> `AuthRepositoryImpl` -> remote auth route -> JWT stored locally -> `GoRouter` redirect.

### Favorites flow

Heart tap -> `ToggleFavoriteEvent` -> `FavoritesBloc` -> repository -> server (`/api/favorites`) + local fallback cache.

### Weather flow

`DetailScreen` -> `LoadWeather` -> `DetailBloc` -> `DetailRepositoryImpl` -> `/api/places/weather/current` -> Open-Meteo via backend.

---

## 4) Pagination Strategy

Pagination is server-backed and UI-friendly:

- Batch size constant: `kPlacesItemsPerBatch` in `core/constants/places_pagination.dart`.
- Backend route `/api/places` returns `data`, `total`, `hasMore`, `page`, `limit`.
- `PlacesBloc` tracks loaded page count and hasMore.
- Home UI supports:
  - auto load near bottom,
  - manual "Load next N" control,
  - "end of list" indicator.

Why:

- Avoids loading all rows at once.
- Faster first paint.
- Better UX for large lists.

---

## 5) Routing and Access Control

`GoRouter` is configured in `core/routing/app_router.dart`.

Routes include splash, auth, home, add-destination, detail, favorites, map, settings, about, help-support.

Global redirect checks token:

- no token -> auth routes.
- has token -> app routes.
- splash resolves immediately to login/home.

---

## 6) Backend and Infrastructure

Server stack:

- **Express** API
- **PostgreSQL** for users/favorites
- **Redis** for caching
- **JWT** auth middleware
- **Open-Meteo** proxy route for weather

The `start.sh` script starts prerequisites and runs both backend + Flutter.

---

## 7) File-by-File Guide (Flutter)

### Root Flutter files

- `lib/main.dart`: app entry, dependency setup, root app widget.

### Core constants

- `lib/core/constants/api_base.dart`: base URL resolver by platform.
- `lib/core/constants/api_endpoints.dart`: central API route constants.
- `lib/core/constants/route_names.dart`: route path constants.
- `lib/core/constants/developer_contact.dart`: support/contact/profile links.
- `lib/core/constants/places_pagination.dart`: items-per-batch pagination constant.

### Core DI/network/errors/theme/routing

- `lib/core/di/injection.dart`: registers all services/repositories/blocs in GetIt.
- `lib/core/network/http_client.dart`: creates configured Dio client + interceptors.
- `lib/core/network/network_info.dart`: connectivity abstraction for online/offline checks.
- `lib/core/errors/exceptions.dart`: low-level data-source exceptions.
- `lib/core/errors/failures.dart`: domain-level failure types used by blocs/UI.
- `lib/core/theme/app_theme.dart`: color system + dark/light theme setup.
- `lib/core/routing/app_router.dart`: router tree + auth redirect policy.

### Auth feature

- `lib/features/auth/data/models/user_model.dart`: user DTO.
- `lib/features/auth/data/sources/auth_remote_source.dart`: login/register/me API calls.
- `lib/features/auth/data/sources/auth_local_source.dart`: token/user local persistence.
- `lib/features/auth/data/repositories/auth_repository_impl.dart`: auth orchestration.
- `lib/features/auth/presentation/bloc/auth_event.dart`: auth events.
- `lib/features/auth/presentation/bloc/auth_state.dart`: auth states.
- `lib/features/auth/presentation/bloc/auth_bloc.dart`: auth state machine.
- `lib/features/auth/ui/login_screen.dart`: login UI.
- `lib/features/auth/ui/register_screen.dart`: register UI.

### Places feature

- `lib/features/places/data/models/place_model.dart`: place entity + image URL normalization + demo data.
- `lib/features/places/data/models/places_fetch_result.dart`: places fetch result metadata.
- `lib/features/places/data/sources/places_remote_source.dart`: paginated places API source.
- `lib/features/places/data/sources/places_local_source.dart`: cached places + user destinations local storage.
- `lib/features/places/data/repositories/places_repository_impl.dart`: online/offline merge logic.
- `lib/features/places/presentation/bloc/places_event.dart`: places events.
- `lib/features/places/presentation/bloc/places_state.dart`: places states + pagination metadata.
- `lib/features/places/presentation/bloc/places_bloc.dart`: load/search/load-more logic.
- `lib/features/places/ui/home_screen.dart`: explore screen, search/sort, pagination UI, travel updates sheet.
- `lib/features/places/ui/add_destination_screen.dart`: add custom destination form.
- `lib/features/places/ui/widgets/place_card.dart`: reusable place row card.
- `lib/features/places/ui/widgets/filter_chips.dart`: top filter chips.

### Detail feature

- `lib/features/detail/data/models/weather_model.dart`: weather model + mapping helpers.
- `lib/features/detail/data/sources/weather_remote_source.dart`: weather API source + response checks.
- `lib/features/detail/data/repositories/detail_repository_impl.dart`: weather repository.
- `lib/features/detail/presentation/bloc/detail_event.dart`: weather events.
- `lib/features/detail/presentation/bloc/detail_state.dart`: weather states.
- `lib/features/detail/presentation/bloc/detail_bloc.dart`: weather load state machine.
- `lib/features/detail/ui/detail_screen.dart`: place detail page + weather + hero image.
- `lib/features/detail/ui/widgets/weather_card.dart`: weather display card + skeleton.
- `lib/features/detail/ui/widgets/expandable_description.dart`: expanding description widget.

### Favorites feature

- `lib/features/favorites/data/models/favorite_item.dart`: favorite DTO.
- `lib/features/favorites/data/sources/favorites_remote_source.dart`: favorites REST source.
- `lib/features/favorites/data/sources/favorites_local_source.dart`: local favorites cache.
- `lib/features/favorites/data/repositories/favorites_repository_impl.dart`: remote/local favorites orchestration.
- `lib/features/favorites/presentation/bloc/favorites_event.dart`: favorites events.
- `lib/features/favorites/presentation/bloc/favorites_state.dart`: favorites states.
- `lib/features/favorites/presentation/bloc/favorites_bloc.dart`: list/toggle favorites logic.
- `lib/features/favorites/ui/favorites_screen.dart`: favorites listing screen.

### Settings + Map features

- `lib/features/settings/presentation/bloc/settings_event.dart`: settings events.
- `lib/features/settings/presentation/bloc/settings_state.dart`: settings state model.
- `lib/features/settings/presentation/bloc/settings_bloc.dart`: theme toggle persistence.
- `lib/features/settings/ui/settings_screen.dart`: settings UI with nav + sign out.
- `lib/features/map/ui/map_screen.dart`: map markers screen.

### Shared UI

- `lib/shared/widgets/app_drawer.dart`: side drawer + navigation links.
- `lib/shared/widgets/empty_state_widget.dart`: reusable empty/error state UI.
- `lib/shared/widgets/offline_banner.dart`: offline indicator.
- `lib/shared/widgets/place_card_shimmer.dart`: shimmer loading placeholder.
- `lib/shared/widgets/loading_indicator.dart`: generic loading widget.
- `lib/shared/ui/about_developer_screen.dart`: about profile screen.
- `lib/shared/ui/help_support_screen.dart`: help/support contact screen.

---

## 8) File-by-File Guide (Server)

### Entry + routing

- `server/server.js`: Express app init, middleware, route mounting, health endpoint.
- `server/routes/auth.js`: register/login/me auth APIs.
- `server/routes/places.js`: places list/detail + weather proxy endpoints.
- `server/routes/favorites.js`: user favorites CRUD (auth protected).
- `server/routes/notifications.js`: notification APIs.

### Middleware / services / DB

- `server/middleware/auth.js`: JWT verification and user extraction.
- `server/services/notificationsLogic.js`: notification business logic helpers.
- `server/db/postgres.js`: PostgreSQL pool config.
- `server/db/redis.js`: Redis client + cache helper functions.
- `server/db/schema_notifications.sql`: notifications schema script.

### Scripts

- `start.sh`: one-command local bootstrap for PostgreSQL/Redis/backend/flutter.

---

## 9) Key Design Decisions and Why

- **Feature-based foldering**: easier growth and ownership.
- **Bloc over setState-only**: explicit app states and cleaner async handling.
- **Repository pattern**: isolates UI from transport/storage details.
- **Dio + centralized endpoints**: consistent HTTP config and auth header handling.
- **Redis cache**: faster backend responses and reduced external API calls.
- **Offline-first fallback**: app remains usable without internet.
- **Server proxy for weather**: hides external API details from client, centralizes control.
- **Config constants** (`route_names`, `api_endpoints`, pagination): fewer magic strings.

---

## 10) How to Extend Safely

When adding a new feature:

1. Create `features/<name>/{data,presentation,ui}`.
2. Add model/source/repository in `data`.
3. Add bloc events/states/bloc in `presentation`.
4. Add screen/widgets in `ui`.
5. Register dependencies in `core/di/injection.dart`.
6. Add route constants + route mapping.
7. Handle failures with `Failure` classes.
8. Add docs and tests.

---

## 11) Existing Project Documentation

- `doc/setup.md`: environment + DB + run setup.
- `doc/features.md`: feature walkthrough.
- `doc/architecture.md`: high-level architecture notes.
- `doc/complete-project-guide.md` (this file): full consolidated reference.

