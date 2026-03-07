import 'package:flutter/foundation.dart' show ChangeNotifier;

import 'package:sem_dsn/models/category.dart';
import 'package:sem_dsn/services/categories_api.dart'
    show fetchCategoriesAll, getActualitesCategory, getFallbackCategories;

/// Tri des catégories : par [Category.position] si fourni par le backend, sinon par id (plus ancien au plus récent).
List<Category> _sortParentCategories(List<Category> list) {
  final sorted = List<Category>.from(list);
  sorted.sort((a, b) {
    final orderA = a.position ?? a.id;
    final orderB = b.position ?? b.id;
    return orderA.compareTo(orderB);
  });
  return sorted;
}

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
      final raw = list.isNotEmpty ? list : getFallbackCategories();
      final sorted = _sortParentCategories(raw);
      // Actualités en dur toujours en premier (éviter doublon si l’API envoie déjà une catégorie actualites).
      final withoutActualites =
          sorted.where((c) => c.slug != 'actualites').toList();
      _parentCategories = [getActualitesCategory(), ...withoutActualites];
    } catch (_) {
      _parentCategories = _sortParentCategories(getFallbackCategories());
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
