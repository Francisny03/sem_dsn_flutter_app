/// Image d'une galerie (photothèque) renvoyée par l'API.
class GalleryImage {
  const GalleryImage({
    required this.id,
    required this.galleryId,
    required this.name,
    required this.filename,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
    required this.url,
  });

  final int id;
  final int galleryId;
  final String name;
  final String filename;
  final int sortOrder;
  final String createdAt;
  final String updatedAt;
  final String url;

  static GalleryImage fromJson(Map<String, dynamic> json) {
    return GalleryImage(
      id: json['id'] as int,
      galleryId: json['gallery_id'] as int,
      name: json['name'] as String? ?? '',
      filename: json['filename'] as String? ?? '',
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }
}
