class Game {
  final String name;
  final String description;
  final String iconAsset;
  final double rating;
  final String downloads;
  final String playStoreUrl;
  final String category;

  const Game({
    required this.name,
    required this.description,
    required this.iconAsset,
    required this.rating,
    required this.downloads,
    required this.playStoreUrl,
    required this.category,
  });
}
