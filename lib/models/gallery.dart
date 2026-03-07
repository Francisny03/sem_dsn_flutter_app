/// Galerie (photothèque) renvoyée par l'API.
class Gallery {
  const Gallery({
    required this.id,
    required this.name,
    this.cover,
    required this.createdAt,
    required this.updatedAt,
    this.coverUrl,
  });

  final int id;
  final String name;
  final String? cover;
  final String createdAt;
  final String updatedAt;
  final String? coverUrl;

  static Gallery fromJson(Map<String, dynamic> json) {
    return Gallery(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      cover: json['cover'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      coverUrl: json['cover_url'] as String?,
    );
  }
}
