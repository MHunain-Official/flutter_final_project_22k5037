import 'package:equatable/equatable.dart';

import 'place_model.dart';

/// Result of loading places — includes whether data came from the network or cache / demo fallback.
class PlacesFetchResult extends Equatable {
  final List<PlaceModel> places;
  final bool isOffline;
  /// Whether another page can be requested (from API or local slice).
  final bool hasMore;
  /// Total catalog size when known (e.g. server `total`); null for unknown.
  final int? total;

  const PlacesFetchResult({
    required this.places,
    this.isOffline = false,
    this.hasMore = false,
    this.total,
  });

  @override
  List<Object?> get props => [places, isOffline, hasMore, total];
}
