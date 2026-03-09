import 'package:flutter/foundation.dart';

import 'package:sem_dsn/models/article.dart';
import 'package:sem_dsn/services/articles_api.dart';

/// Provider des articles API (cache en mémoire, partagé entre home et recherche).
class ArticlesProvider extends ChangeNotifier {
  List<Article> _articles = [];
  bool _loading = false;
  bool _loadFailed = false;

  /// Cache des articles par catégorie (ex. id 7 = Réalisations), pour les onglets home.
  final Map<int, List<Article>> _articlesByCategory = {};

  List<Article> get articles => _articles;
  bool get loading => _loading;
  bool get loadFailed => _loadFailed;

  /// Articles chargés pour une catégorie (ex. Réalisations). Vide si pas encore chargé.
  List<Article> getArticlesForCategory(int categoryId) =>
      _articlesByCategory[categoryId] ?? [];

  /// Charge les articles si pas déjà chargés.
  Future<void> loadIfNeeded() async {
    if (_loading || _articles.isNotEmpty) return;
    await load();
  }

  /// Force le rechargement (ex. pull-to-refresh).
  Future<void> load() async {
    _loading = true;
    _loadFailed = false;
    notifyListeners();
    try {
      final res = await fetchArticles();
      _articles = res.results;
    } catch (_) {
      _articles = [];
      _loadFailed = true;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Charge les articles d’une catégorie (ex. Réalisations, Discours). Utilise articles/public/all?category_id=.
  Future<void> loadArticlesForCategory(int categoryId) async {
    try {
      final res = await fetchArticlesByCategory(
        categoryId,
        page: 1,
        limit: 200,
      );
      _articlesByCategory[categoryId] = res.results;
      notifyListeners();
    } catch (_) {
      _articlesByCategory[categoryId] = [];
      notifyListeners();
    }
  }
}
