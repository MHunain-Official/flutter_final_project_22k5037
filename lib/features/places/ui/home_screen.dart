import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_names.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_theme.dart';
import '../data/models/place_model.dart';
import '../data/sources/places_local_source.dart';
import '../presentation/bloc/places_bloc.dart';
import '../presentation/bloc/places_event.dart';
import '../presentation/bloc/places_state.dart';
import '../../favorites/presentation/bloc/favorites_bloc.dart';
import '../../favorites/presentation/bloc/favorites_event.dart';
import '../../favorites/presentation/bloc/favorites_state.dart';
import 'widgets/place_card.dart';
import 'widgets/filter_chips.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/place_card_shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum _PlaceSort { original, titleAz, albumId }

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  Timer? _debounce;
  Timer? _loadMoreDebounce;
  _PlaceSort _sort = _PlaceSort.original;

  late final PlacesBloc _placesBloc;
  late final FavoritesBloc _favoritesBloc;

  List<PlaceModel> _userPlaces = [];

  @override
  void initState() {
    super.initState();
    _placesBloc = sl<PlacesBloc>()..add(const LoadPlaces());
    _favoritesBloc = sl<FavoritesBloc>()..add(LoadFavorites());
    _scrollCtrl.addListener(_onScroll);
    _loadUserDestinations();
  }

  @override
  void dispose() {
    _placesBloc.close();
    _favoritesBloc.close();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadUserDestinations() async {
    final list = await sl<PlacesLocalSource>().getUserDestinations();
    if (mounted) setState(() => _userPlaces = list);
  }

  Future<void> _onRefreshPlaces() async {
    await _loadUserDestinations();
    _placesBloc.add(LoadPlaces(search: _searchCtrl.text));
    await _placesBloc.stream.firstWhere((s) => s is PlacesLoaded || s is PlacesError);
  }

  // Debounce search input — waits 400ms after user stops typing
  void _onSearchChanged(PlacesBloc bloc, String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      bloc.add(LoadPlaces(search: query));
    });
  }

  // Trigger pagination when the user scrolls near the bottom
  void _onScroll() {
    if (!mounted) return;
    if (!_scrollCtrl.hasClients) return;
    if (_scrollCtrl.position.pixels <
        _scrollCtrl.position.maxScrollExtent - 200) {
      return;
    }
    _loadMoreDebounce?.cancel();
    _loadMoreDebounce = Timer(const Duration(milliseconds: 150), () {
      if (!mounted || !_scrollCtrl.hasClients) return;
      if (_scrollCtrl.position.pixels <
          _scrollCtrl.position.maxScrollExtent - 200) {
        return;
      }
      _placesBloc.add(LoadMorePlaces());
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PlacesBloc>.value(value: _placesBloc),
        BlocProvider<FavoritesBloc>.value(value: _favoritesBloc),
      ],
      child: Scaffold(
        drawer: const AppDrawer(),
        body: SafeArea(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _onRefreshPlaces,
            child: CustomScrollView(
              controller: _scrollCtrl,
              slivers: [
                // ── App bar with search ──
                SliverToBoxAdapter(child: _buildHeader(context)),

                // ── Filter chips (All / Favorites) ──
                SliverToBoxAdapter(
                  child: FilterChipsRow(
                    selected: 'all',
                    onSelected: (f) {
                      if (f == 'favorites') {
                        context.push(RouteNames.favorites);
                      }
                    },
                  ),
                ),

                // ── Offline banner ──
                BlocBuilder<PlacesBloc, PlacesState>(
                  builder: (_, state) {
                    if (state is PlacesLoaded && state.isOffline) {
                      return const SliverToBoxAdapter(child: OfflineBanner());
                    }
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  },
                ),

                if (_userPlaces.isNotEmpty)
                  SliverToBoxAdapter(child: _buildUserDestinationsBar(context)),

                // ── Main content ──
                BlocBuilder<PlacesBloc, PlacesState>(
                  builder: (ctx, state) {
                    if (state is PlacesInitial || state is PlacesLoading) {
                      return _shimmerGrid();
                    }
                    if (state is PlacesError) {
                      return SliverFillRemaining(
                        child: EmptyStateWidget(
                          icon: Icons.wifi_off_rounded,
                          title: 'Something went wrong',
                          subtitle: state.message,
                          actionLabel: 'Retry',
                          onAction: () => _placesBloc
                              .add(LoadPlaces(search: _searchCtrl.text)),
                        ),
                      );
                    }
                    if (state is PlacesLoaded) {
                      if (state.places.isEmpty && _userPlaces.isEmpty) {
                        return SliverFillRemaining(
                          child: EmptyStateWidget(
                            icon: Icons.search_off_rounded,
                            title: 'No places found',
                            subtitle: 'Try adjusting your search or filter',
                            actionLabel: 'Clear Filters',
                            onAction: () {
                              _searchCtrl.clear();

                              _placesBloc.add(const LoadPlaces());
                            },
                          ),
                        );
                      }
                      if (state.places.isEmpty) {
                        return SliverFillRemaining(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: EmptyStateWidget(
                              icon: Icons.travel_explore_outlined,
                              title: 'No catalog matches',
                              subtitle:
                                  'Your saved destinations appear above. Try clearing search or '
                                  'pull down to refresh the list.',
                              actionLabel: 'Clear search',
                              onAction: () {
                                _searchCtrl.clear();
                                _placesBloc.add(const LoadPlaces());
                              },
                            ),
                          ),
                        );
                      }
                      return _catalogSection(ctx, state);
                    }
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'Loading…',
                          style: Theme.of(ctx).textTheme.bodySmall,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton.small(
              heroTag: 'fab-add-place',
              backgroundColor: AppColors.primary.withValues(alpha: 0.9),
              foregroundColor: Colors.white,
              onPressed: () => context.push(RouteNames.addDestination).then((added) {
                if (added == true) _loadUserDestinations();
              }),
              tooltip: 'Add destination',
              child: const Icon(Icons.add),
            ),
            const SizedBox(height: 14),
            FloatingActionButton(
              heroTag: 'fab-map',
              backgroundColor: AppColors.primary,
              tooltip: 'Map',
              onPressed: () => context.push(RouteNames.map),
              child: const Icon(Icons.map_outlined, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _showTravelUpdatesSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(RouteNames.settings),
          ),
        ]),
        const SizedBox(height: 8),
        Text('Explore Places', style: Theme.of(context).textTheme.displayLarge),
        const SizedBox(height: 4),
        BlocBuilder<PlacesBloc, PlacesState>(
          builder: (_, s) {
            if (s is PlacesLoaded) {
              final n = s.places.length;
              final total = s.catalogTotal;
              final buf = StringBuffer();
              if (total != null) {
                buf.write('Showing $n of $total destinations');
              } else {
                buf.write('$n destination${n == 1 ? '' : 's'} loaded');
              }
              if (!s.isLoadingMore) {
                buf.write(' · ${s.itemsPerBatch} per fetch');
                if (s.loadedRemotePages > 1 || s.hasMore) {
                  buf.write(' · batches loaded: ${s.loadedRemotePages}');
                }
                buf.write(s.hasMore ? '' : ' · end of list');
              } else {
                buf.write(' · loading…');
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  buf.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }
            return const SizedBox(height: 8);
          },
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _searchCtrl,
          builder: (ctx, val, _) {
            return TextField(
              controller: _searchCtrl,
              onChanged: (q) => _onSearchChanged(_placesBloc, q),
              decoration: InputDecoration(
                hintText: 'Search places...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: val.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          _placesBloc.add(const LoadPlaces());
                        },
                      )
                    : null,
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Text('Sort', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        SegmentedButton<_PlaceSort>(
          segments: const [
            ButtonSegment(value: _PlaceSort.original, label: Text('Default'), icon: Icon(Icons.sort, size: 16)),
            ButtonSegment(value: _PlaceSort.titleAz, label: Text('A–Z'), icon: Icon(Icons.text_fields, size: 16)),
            ButtonSegment(value: _PlaceSort.albumId, label: Text('Album'), icon: Icon(Icons.photo_album_outlined, size: 16)),
          ],
          selected: {_sort},
          onSelectionChanged: (set) => setState(() => _sort = set.first),
        ),
      ]),
    );
  }

  Widget _buildUserDestinationsBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your destinations',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 128,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _userPlaces.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (ctx, i) {
                final place = _userPlaces[i];
                return BlocBuilder<FavoritesBloc, FavoritesState>(
                  builder: (_, favState) {
                    final isFav = favState is FavoritesLoaded &&
                        favState.placeIds.contains(place.id);
                    return SizedBox(
                      width: 220,
                      child: PlaceCard(
                        place: place,
                        isFavorite: isFav,
                        onTap: () => ctx.push(RouteNames.detail, extra: place),
                        onFavoriteToggle: () {
                          _favoritesBloc.add(ToggleFavoriteEvent(place));
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showTravelUpdatesSheet(BuildContext parentContext) {
    final router = GoRouter.of(parentContext);
    showModalBottomSheet<void>(
      context: parentContext,
      showDragHandle: true,
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Travel updates', style: Theme.of(sheetCtx).textTheme.titleLarge),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.flight_takeoff_outlined),
              title: const Text('Trip reminders'),
              subtitle: Text(
                'Push alerts need the Node server, Redis, and notification routes — see project docs. '
                'Use Help & Support for questions.',
                style: Theme.of(sheetCtx).textTheme.bodySmall,
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.cloud_outlined),
              title: const Text('Weather tips'),
              subtitle: Text(
                'Tap any destination in the list to open its detail screen — live weather loads there '
                '(backend must be running on port 3000).',
                style: Theme.of(sheetCtx).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 4,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(sheetCtx);
                    router.push(RouteNames.helpSupport);
                  },
                  child: const Text('Help & Support'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(sheetCtx);
                    router.push(RouteNames.about);
                  },
                  child: const Text('About'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<PlaceModel> _applySort(List<PlaceModel> places) {
    final copy = List<PlaceModel>.from(places);
    switch (_sort) {
      case _PlaceSort.original:
        return copy;
      case _PlaceSort.titleAz:
        copy.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        return copy;
      case _PlaceSort.albumId:
        copy.sort((a, b) {
          final c = a.albumId.compareTo(b.albumId);
          return c != 0 ? c : a.id.compareTo(b.id);
        });
        return copy;
    }
  }

  /// Catalog list + optional “load more” / end-of-catalog hint.
  Widget _catalogSection(BuildContext ctx, PlacesLoaded state) {
    return SliverMainAxisGroup(
      slivers: [
        _placeListSliver(ctx, state),
        SliverToBoxAdapter(child: _paginationFooterHint(ctx, state)),
      ],
    );
  }

  Widget _placeListSliver(BuildContext ctx, PlacesLoaded state) {
    final sorted = _applySort(state.places);
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, i) {
            if (i < sorted.length) {
              final place = sorted[i];
              return BlocBuilder<FavoritesBloc, FavoritesState>(
                builder: (_, favState) {
                  final isFav = favState is FavoritesLoaded &&
                      favState.placeIds.contains(place.id);
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: PlaceCard(
                      place: place,
                      isFavorite: isFav,
                      onTap: () => ctx.push(RouteNames.detail, extra: place),
                      onFavoriteToggle: () {
                        _favoritesBloc.add(ToggleFavoriteEvent(place));
                      },
                    ),
                  );
                },
              );
            }
            if (state.isLoadingMore) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return const SizedBox.shrink();
          },
          childCount: sorted.length + (state.isLoadingMore ? 1 : 0),
        ),
      ),
    );
  }

  Widget _paginationFooterHint(BuildContext context, PlacesLoaded state) {
    final style = Theme.of(context).textTheme.bodySmall;

    if (state.isLoadingMore) {
      return const SizedBox(height: 8);
    }

    if (state.hasMore) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.south_rounded, size: 18, color: style?.color?.withValues(alpha: 0.7)),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'After ${state.places.length} places, the next ${state.itemsPerBatch} load when you scroll to the bottom or tap below.',
                    textAlign: TextAlign.center,
                    style: style,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () => _placesBloc.add(LoadMorePlaces()),
              icon: const Icon(Icons.expand_more),
              label: Text('Load next ${state.itemsPerBatch}'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.check_circle_outline, size: 20, color: AppColors.primary.withValues(alpha: 0.8)),
            const SizedBox(height: 8),
            Text(
              'End of catalog',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            if (state.catalogTotal != null && state.places.length == state.catalogTotal)
              Text(
                'All ${state.catalogTotal} places are loaded.',
                textAlign: TextAlign.center,
                style: style,
              ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerGrid() => SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, __) => const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: PlaceCardShimmer(),
            ),
            childCount: 6,
          ),
        ),
      );
}
