import 'package:equatable/equatable.dart';

// Represents one photo/place from the API. Favorite state lives in FavoritesBloc.
class PlaceModel extends Equatable {
  final int id;
  final String title;
  final String thumbnailUrl;
  final String url;
  final int albumId;

  const PlaceModel({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.url,
    required this.albumId,
  });

  /// JSONPlaceholder uses flaky `via.placeholder.com` URLs; replace with deterministic Picsum seeds.
  static String resolvedImageUrl(int id, Object? raw, {required bool thumbnail}) {
    final u = (raw?.toString() ?? '').trim();
    final w = thumbnail ? 240 : 800;
    final h = thumbnail ? 200 : 520;
    if (u.isEmpty ||
        u.contains('via.placeholder.com') ||
        u.contains('placehold.it')) {
      return 'https://picsum.photos/seed/stravel$id/$w/$h';
    }
    return u;
  }

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] as num).toInt();
    final albumId = (json['albumId'] as num?)?.toInt() ?? 0;
    return PlaceModel(
      id: id,
      title: json['title'] as String,
      thumbnailUrl: resolvedImageUrl(
        id,
        json['thumbnailUrl'] ?? json['thumbnail_url'],
        thumbnail: true,
      ),
      url: resolvedImageUrl(
        id,
        json['url'],
        thumbnail: false,
      ),
      albumId: albumId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'thumbnailUrl': thumbnailUrl,
        'url': url,
        'albumId': albumId,
      };

  /// Shown when the API is unreachable and there is no cache (same shape as `/api/places`).
  static const List<PlaceModel> demoPlaces = [
    PlaceModel(
      id: 1,
      albumId: 1,
      title: 'accusamus beatae ad facilis cum similique qui sunt',
      url: 'https://picsum.photos/seed/demo1/800/520',
      thumbnailUrl: 'https://picsum.photos/seed/demo1/240/200',
    ),
    PlaceModel(
      id: 2,
      albumId: 1,
      title: 'reprehenderit est deserunt velit ipsam',
      url: 'https://picsum.photos/seed/demo2/800/520',
      thumbnailUrl: 'https://picsum.photos/seed/demo2/240/200',
    ),
    PlaceModel(
      id: 3,
      albumId: 1,
      title: 'officia porro iure quia iusto qui ipsa ut modi',
      url: 'https://picsum.photos/seed/demo3/800/520',
      thumbnailUrl: 'https://picsum.photos/seed/demo3/240/200',
    ),
    PlaceModel(
      id: 4,
      albumId: 1,
      title: 'culpa odio esse rerum omnis laboriosam voluptate repudiandae',
      url: 'https://picsum.photos/seed/demo4/800/520',
      thumbnailUrl: 'https://picsum.photos/seed/demo4/240/200',
    ),
    PlaceModel(
      id: 5,
      albumId: 1,
      title: 'natus nisi omnis corporis facere molestiae rerum in',
      url: 'https://picsum.photos/seed/demo5/800/520',
      thumbnailUrl: 'https://picsum.photos/seed/demo5/240/200',
    ),
    PlaceModel(
      id: 6,
      albumId: 1,
      title: 'doloremque illum facilis quis expedita sit aut',
      url: 'https://picsum.photos/seed/demo6/800/520',
      thumbnailUrl: 'https://picsum.photos/seed/demo6/240/200',
    ),
  ];

  @override
  List<Object?> get props => [id];
}
