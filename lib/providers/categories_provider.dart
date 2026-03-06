import 'package:flutter/foundation.dart' show ChangeNotifier;

import 'package:sem_dsn/models/category.dart';
import 'package:sem_dsn/services/categories_api.dart'
    show fetchCategoriesAll, getFallbackCategories;

/// Provider des catégories parentes du home filter (cache en mémoire, évite rechargement à chaque ouverture / hot restart).
class CategoriesProvider extends ChangeNotifier {
  List<Category> _parentCategories = [];
  bool _loading = false;

  List<Category> get parentCategories => _parentCategories;
  bool get loading => _loading;

  /// Charge les catégories si pas déjà chargées. À appeler au premier affichage du home.
  Future<void> loadIfNeeded() async {
    if (_loading || _parentCategories.isNotEmpty) return;
    await load();
  }

  /// Force le rechargement (ex. pull-to-refresh).
  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      final list = await fetchCategoriesAll();
      _parentCategories = list.isNotEmpty ? list : getFallbackCategories();
    } catch (_) {
      _parentCategories = getFallbackCategories();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
