import 'package:sem_dsn/models/article_image.dart';
import 'package:sem_dsn/models/article_source.dart';
import 'package:sem_dsn/models/category.dart';

/// Article renvoyé par l’API (liste ou détail).
class Article {
  const Article({
    required this.id,
    required this.title,
    required this.description,
    this.categoryId,
    required this.articleDate,
    required this.slug,
    required this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
    this.subtitle,
    this.sources = const [],
    this.isPublished = true,
    this.images = const [],
    this.categories = const [],
    this.videoUrl,
  });

  final int id;
  final String title;
  final String description;
  final int? categoryId;
  final String articleDate;
  final String slug;
  final String publishedAt;
  final String createdAt;
  final String updatedAt;
  final String? subtitle;
  final List<ArticleSource> sources;
  final bool isPublished;
  final List<ArticleImage> images;
  final List<Category> categories;

  /// URL vidéo (ex. YouTube) si l’article en a une.
  final String? videoUrl;

  /// Première image URL ou null (null si liste vide ou url vide).
  String? get firstImageUrl {
    if (images.isEmpty) return null;
    final sorted = List<ArticleImage>.from(images)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final url = sorted.first.url;
    return (url.isEmpty) ? null : url;
  }

  /// True si l’article a une vidéo à afficher.
  bool get hasVideo =>
      videoUrl != null && videoUrl!.trim().isNotEmpty;

  /// Date affichée (article_date ou published_at).
  String get displayDate => articleDate;

  /// Date formatée pour l’UI (ex. "7 Mar 2026").
  static String formatDisplayDate(String iso) {
    if (iso.length < 10) return iso;
    try {
      final d = DateTime.parse(iso);
      const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
      return '${d.day} ${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return iso.substring(0, 10);
    }
  }

  factory Article.fromJson(Map<String, dynamic> json) {
    final sourcesList = json['sources'] as List<dynamic>?;
    final imagesList = json['images'] as List<dynamic>?;
    final categoriesList = json['categories'] as List<dynamic>?;
    return Article(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      categoryId: json['category_id'] as int?,
      articleDate: json['article_date'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      publishedAt: json['published_at'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      sources:
          sourcesList
              ?.map((e) => ArticleSource.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isPublished: json['is_published'] as bool? ?? true,
      images:
          imagesList
              ?.map((e) => ArticleImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      categories:
          categoriesList
              ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      videoUrl: json['video_url'] as String?,
    );
  }
}
