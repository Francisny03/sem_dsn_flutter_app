/// Source d’un article (nom + URL).
class ArticleSource {
  const ArticleSource({required this.name, required this.url});

  final String name;
  final String url;

  factory ArticleSource.fromJson(Map<String, dynamic> json) {
    return ArticleSource(
      name: json['name'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }
}
