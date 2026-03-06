import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:sem_dsn/core/constants/api_config.dart';
import 'package:sem_dsn/models/article.dart';

/// Réponse paginée des articles.
class ArticlesResponse {
  const ArticlesResponse({required this.results, required this.total});

  final List<Article> results;
  final int total;
}

/// Récupère la liste des articles.
Future<ArticlesResponse> fetchArticles() async {
  final uri = Uri.parse(ApiConfig.articles());
  final response = await http.get(uri, headers: {'accept': '*/*'});
  if (response.statusCode != 200) {
    throw Exception('articles: ${response.statusCode}');
  }
  final map = json.decode(response.body) as Map<String, dynamic>;
  final list = map['results'] as List<dynamic>? ?? [];
  final total = map['total'] as int? ?? 0;
  return ArticlesResponse(
    results:
        list.map((e) => Article.fromJson(e as Map<String, dynamic>)).toList(),
    total: total,
  );
}

/// Récupère un article par id.
Future<Article> fetchArticleById(int id) async {
  final uri = Uri.parse(ApiConfig.article(id));
  final response = await http.get(uri, headers: {'accept': '*/*'});
  if (response.statusCode != 200) {
    throw Exception('article/$id: ${response.statusCode}');
  }
  final map = json.decode(response.body) as Map<String, dynamic>;
  return Article.fromJson(map);
}
