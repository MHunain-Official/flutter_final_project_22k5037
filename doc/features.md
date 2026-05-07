# Features — Smart Travel Companion

## 1. Authentication

**Screens**: `LoginScreen`, `RegisterScreen`

Users register with name, email, and password. Credentials are validated on both client and server. The server hashes passwords with bcryptjs and returns a signed JWT.

The JWT is stored securely in `flutter_secure_storage` (not shared preferences) so it persists across app restarts and is never accessible to other apps.

**Flow**
```
User enters credentials
  → AuthBloc dispatches LoginRequested
  → AuthRemoteSource: POST /api/auth/login
  → AuthLocalSource: saves JWT
  → GoRouter redirect fires → navigates to HomeScreen
```

---

## 2. Home Screen — Explore Places

**Screen**: `HomeScreen`

The home screen fetches paginated photos from JSONPlaceholder (proxied through the Node.js backend, Redis-cached for 5 minutes). Each card shows the thumbnail, title, and a heart button.

**Features**
- **Pull-to-refresh**: `RefreshIndicator` re-dispatches `LoadPlaces`
- **Infinite scroll**: Triggers `LoadMorePlaces` 200 px before the bottom
- **Debounced search**: 400 ms delay before firing a search request (avoids hammering the API)
- **Shimmer loading**: `PlaceCardShimmer` while the first page loads
- **Filter chip**: Tap "Favorites" to jump to the Favorites screen
- **Offline banner**: Shown when serving stale cached data
- **Map FAB**: Floating button navigates to the map

---

## 3. Detail Screen

**Screen**: `DetailScreen`

Tapping a place card navigates to the detail screen via GoRouter `extra` parameter (no ID-based refetch needed).

**Features**
- **Hero animation**: `place_<id>` tag shared between `PlaceCard` and `DetailScreen`
- **SliverAppBar**: Collapses as the user scrolls
- **Expandable description**: Tap to reveal full text (AnimatedSize)
- **Weather card**: Fetches current weather from Open-Meteo via backend proxy (lat/lon hardcoded per place). Skeleton shown while loading, error banner on failure

---

## 4. Favorites

**Screen**: `FavoritesScreen`

Users can heart any place from the home screen or detail screen. Favorites are persisted to PostgreSQL and cached per user in Redis.

**Features**
- **Optimistic toggle**: The heart icon responds immediately; the network call happens in the background
- **Offline cache**: `favorites_local_source.dart` stores the last known favorites list in `SharedPreferences`
- **Swipe-to-delete**: Dismissible list tile removes the favorite with confirmation
- **Empty state**: Friendly illustration when there are no favorites

---

## 5. Map Screen

**Screen**: `MapScreen`

Displays 6 curated destinations as markers on an OpenStreetMap (via `flutter_map`). No API key required.

**Destinations shown**
- Lahore (default center)
- Karachi
- Islamabad
- Murree
- Neelum Valley
- Hunza Valley

Tapping a marker shows a popup with the destination name.

---

## 6. Settings

**Screen**: `SettingsScreen`

- **Dark mode toggle**: Persisted to `SharedPreferences` via `SettingsBloc`. The theme is applied app-wide through `MaterialApp.themeMode`.
- **Navigation shortcuts**: Quick links to Favorites and Map screens from settings.
- **Logout**: Clears the JWT from secure storage and redirects to LoginScreen.

---

## 7. Offline Support

The app gracefully degrades when there is no internet connection:

1. `NetworkInfo` (connectivity_plus) checks connectivity before each request.
2. On failure, the `PlacesRepositoryImpl` reads the last successful response from `SharedPreferences`.
3. The `PlacesLoaded` state carries `isOffline: true`.
4. `OfflineBanner` slides in at the top of `HomeScreen` to inform the user.

---

## 8. Notifications (Infrastructure)

`flutter_local_notifications` is registered in `pubspec.yaml` and initialised in `injection.dart`.  
It can be triggered when a user adds a favorite (e.g. "Added to your favorites!").
