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
    results: list
        .map((e) => Article.fromJson(e as Map<String, dynamic>))
        .toList(),
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

/// Réponse de l’endpoint articles/home (À la une + Contenu général).
class ArticlesHomeResponse {
  const ArticlesHomeResponse({
    required this.aLaUne,
    required this.contenuGeneral,
  });

  final List<Article> aLaUne;
  final List<Article> contenuGeneral;
}

/// Récupère les articles d’une catégorie (ex. Réalisations id=7).
Future<ArticlesResponse> fetchArticlesByCategory(
  int categoryId, {
  int page = 1,
  int limit = 20,
}) async {
  final uri = Uri.parse(
    ApiConfig.articlesByCategory(categoryId, page: page, limit: limit),
  );
  final response = await http.get(uri, headers: {'accept': '*/*'});
  if (response.statusCode != 200) {
    throw Exception(
      'articles/public/categories/$categoryId: ${response.statusCode}',
    );
  }
  final map = json.decode(response.body) as Map<String, dynamic>;
  final list = map['results'] as List<dynamic>? ?? [];
  final total = map['total'] as int? ?? 0;
  return ArticlesResponse(
    results: list
        .map((e) => Article.fromJson(e as Map<String, dynamic>))
        .toList(),
    total: total,
  );
}

/// Récupère les articles pour la page d’accueil (À la une + contenu général).
Future<ArticlesHomeResponse> fetchArticlesHome() async {
  final uri = Uri.parse(ApiConfig.articlesHome());
  final response = await http.get(uri, headers: {'accept': 'application/json'});
  if (response.statusCode != 200) {
    throw Exception('articles/home: ${response.statusCode}');
  }
  final map = json.decode(response.body) as Map<String, dynamic>;
  final aLaUneList = map['a_la_une'] as List<dynamic>? ?? [];
  final contenuList = map['contenu_general'] as List<dynamic>? ?? [];
  return ArticlesHomeResponse(
    aLaUne: aLaUneList
        .map((e) => Article.fromJson(e as Map<String, dynamic>))
        .toList(),
    contenuGeneral: contenuList
        .map((e) => Article.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
