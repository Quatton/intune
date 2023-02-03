class User {
  final String id;
  final String email;
  final String name;
  final String? imageUrl;
  final String? spotifyId;
  User({
    required this.id,
    required this.email,
    required this.name,
    this.imageUrl,
    this.spotifyId,
  });
}
