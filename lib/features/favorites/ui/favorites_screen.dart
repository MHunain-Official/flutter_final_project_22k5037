import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_theme.dart';
import '../presentation/bloc/favorites_bloc.dart';
import '../presentation/bloc/favorites_event.dart';
import '../presentation/bloc/favorites_state.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/loading_indicator.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<FavoritesBloc>()..add(LoadFavorites()),
      child: Scaffold(
        appBar: AppBar(title: const Text('My Favorites')),
        body: BlocBuilder<FavoritesBloc, FavoritesState>(
          builder: (ctx, state) {
            if (state is FavoritesLoading) return const AppLoadingIndicator();
            if (state is FavoritesError) {
              return EmptyStateWidget(
                icon: Icons.error_outline,
                title: 'Failed to load favorites',
                subtitle: state.message,
                actionLabel: 'Retry',
                onAction: () => ctx.read<FavoritesBloc>().add(LoadFavorites()),
              );
            }
            if (state is FavoritesLoaded) {
              if (state.items.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.favorite_border,
                  title: 'No favorites yet',
                  subtitle: 'Tap the heart icon on any place to save it here',
                );
              }
              return AnimatedList(
                initialItemCount: state.items.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (_, i, anim) => SizeTransition(
                  sizeFactor: anim,
                  child: _FavoriteRow(item: state.items[i]),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _FavoriteRow extends StatelessWidget {
  final dynamic item;
  const _FavoriteRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
            imageUrl: item.thumbnailUrl ?? '',
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => Container(
              width: 56, height: 56,
              color: AppColors.textMuted.withValues(alpha: 0.2),
              child: const Icon(Icons.image_not_supported_outlined, size: 20),
            ),
          ),
        ),
        title: Text(
          item.placeTitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('Place #${item.placeId}', style: Theme.of(context).textTheme.bodySmall),
        trailing: const Icon(Icons.favorite, color: AppColors.heart),
      ),
    );
  }
}
