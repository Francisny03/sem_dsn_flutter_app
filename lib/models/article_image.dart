/// Image d’un article (URL absolue).
class ArticleImage {
  const ArticleImage({
    required this.id,
    required this.articleId,
    required this.url,
    this.caption,
    this.sortOrder = 0,
  });

  final int id;
  final int articleId;
  final String url;
  final String? caption;
  final int sortOrder;

  factory ArticleImage.fromJson(Map<String, dynamic> json) {
    return ArticleImage(
      id: json['id'] as int,
      articleId: json['article_id'] as int,
      url: json['url'] as String? ?? '',
      caption: json['caption'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }
}
