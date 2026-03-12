import 'package:flutter/foundation.dart';

import 'package:sem_dsn/models/article.dart';
import 'package:sem_dsn/services/articles_api.dart';

/// Nombre d'articles chargés par page (pagination).
const int kArticlesPageSize = 15;

/// Provider des articles API (cache en mémoire, partagé entre home et recherche).
class ArticlesProvider extends ChangeNotifier {
  List<Article> _articles = [];
  bool _loading = false;
  bool _loadFailed = false;

  /// Cache des articles par catégorie (ex. id 7 = Réalisations), pour les onglets home.
  final Map<int, List<Article>> _articlesByCategory = {};
  final Map<int, int> _pageByCategory = {};
  final Map<int, int> _totalByCategory = {};
  final Map<int, bool> _loadingMoreByCategory = {};

  List<Article> get articles => _articles;
  bool get loading => _loading;
  bool get loadFailed => _loadFailed;

  /// Articles chargés pour une catégorie (ex. Réalisations). Vide si pas encore chargé.
  List<Article> getArticlesForCategory(int categoryId) =>
      _articlesByCategory[categoryId] ?? [];

  bool hasMoreForCategory(int categoryId) {
    final list = _articlesByCategory[categoryId];
    if (list == null || list.isEmpty) return false;
    final total = _totalByCategory[categoryId] ?? 0;
    if (list.length < total) return true;
    // Si l'API renvoie total = taille de la page (ex. 15), on considère qu'il peut y avoir plus
    // quand on a reçu une page pleine.
    final page = _pageByCategory[categoryId] ?? 1;
    return list.length >= kArticlesPageSize &&
        list.length == page * kArticlesPageSize;
  }

  bool loadingMoreForCategory(int categoryId) =>
      _loadingMoreByCategory[categoryId] ?? false;

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
        limit: kArticlesPageSize,
      );
      _articlesByCategory[categoryId] = res.results;
      _pageByCategory[categoryId] = 1;
      _totalByCategory[categoryId] = res.total;
      notifyListeners();
    } catch (_) {
      _articlesByCategory[categoryId] = [];
      _pageByCategory[categoryId] = 0;
      _totalByCategory[categoryId] = 0;
      notifyListeners();
    }
  }

  /// Charge la page suivante pour une catégorie et l'ajoute à la liste.
  Future<void> loadMoreArticlesForCategory(int categoryId) async {
    if (_loadingMoreByCategory[categoryId] == true) return;
    if (!hasMoreForCategory(categoryId)) return;
    _loadingMoreByCategory[categoryId] = true;
    notifyListeners();
    try {
      final page = (_pageByCategory[categoryId] ?? 1) + 1;
      final res = await fetchArticlesByCategory(
        categoryId,
        page: page,
        limit: kArticlesPageSize,
      );
      final current = _articlesByCategory[categoryId] ?? [];
      _articlesByCategory[categoryId] = [...current, ...res.results];
      _pageByCategory[categoryId] = page;
      final prevTotal = _totalByCategory[categoryId] ?? 0;
      _totalByCategory[categoryId] = res.total > prevTotal
          ? res.total
          : prevTotal;
    } catch (_) {
      // garde l'état actuel
    } finally {
      _loadingMoreByCategory[categoryId] = false;
      notifyListeners();
    }
  }
}
