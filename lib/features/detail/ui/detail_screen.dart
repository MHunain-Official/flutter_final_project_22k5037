import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_theme.dart';
import '../../places/data/models/place_model.dart';
import '../presentation/bloc/detail_bloc.dart';
import '../presentation/bloc/detail_event.dart';
import '../presentation/bloc/detail_state.dart';
import 'widgets/weather_card.dart';
import 'widgets/expandable_description.dart';

class DetailScreen extends StatelessWidget {
  final PlaceModel place;
  const DetailScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DetailBloc>()..add(const LoadWeather()),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // ── Hero image in collapsible app bar ──
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Hero(
                  tag: 'place_${place.id}',
                  child: CachedNetworkImage(
                    imageUrl: place.url,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: AppColors.textMuted.withValues(alpha: 0.2)),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.textMuted.withValues(alpha: 0.2),
                      child: const Icon(Icons.image_not_supported_outlined, size: 48),
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Place title
                    Text(
                      place.title,
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.location_on, size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text('Album #${place.albumId}',
                          style: Theme.of(context).textTheme.bodySmall),
                    ]),
                    const SizedBox(height: 24),

                    // ── Weather card with AnimatedSwitcher ──
                    BlocBuilder<DetailBloc, DetailState>(
                      builder: (_, state) => AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: switch (state) {
                          DetailInitial() => const WeatherCardSkeleton(),
                          DetailLoading() => const WeatherCardSkeleton(),
                          DetailLoaded(weather: final w) => WeatherCard(weather: w),
                          DetailError(message: final m) => _WeatherError(message: m),
                          _ => const WeatherCardSkeleton(),
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Expandable description ──
                    Text('About this place',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontSize: 16)),
                    const SizedBox(height: 8),
                    ExpandableDescription(
                      text:
                          '${place.title.replaceAll(' ', ' ')} is a breathtaking destination '
                          'that draws visitors from around the world. Known for its stunning '
                          'natural beauty and unique landscapes, it offers an unforgettable '
                          'experience for photographers, adventurers, and nature enthusiasts alike. '
                          'The area is rich in local culture, wildlife, and scenic viewpoints that '
                          'make every visit truly memorable.',
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('View on Map'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherError extends StatelessWidget {
  final String message;
  const _WeatherError({required this.message});
  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('weatherError'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        const Icon(Icons.wifi_off_rounded, color: AppColors.danger),
        const SizedBox(width: 12),
        Expanded(child: Text(message, style: Theme.of(context).textTheme.bodySmall)),
      ]),
    );
  }
}
