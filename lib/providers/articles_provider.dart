import 'package:flutter/foundation.dart';

import 'package:sem_dsn/models/article.dart';
import 'package:sem_dsn/services/articles_api.dart';

/// Provider des articles API (cache en mémoire, partagé entre home et recherche).
class ArticlesProvider extends ChangeNotifier {
  List<Article> _articles = [];
  bool _loading = false;

  List<Article> get articles => _articles;
  bool get loading => _loading;

  /// Charge les articles si pas déjà chargés.
  Future<void> loadIfNeeded() async {
    if (_loading || _articles.isNotEmpty) return;
    await load();
  }

  /// Force le rechargement (ex. pull-to-refresh).
  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      final res = await fetchArticles();
      _articles = res.results;
    } catch (_) {
      _articles = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
