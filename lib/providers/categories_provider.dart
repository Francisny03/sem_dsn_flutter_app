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
  final Map<int, String> _categoryIdToDisplayName = {};

  List<Category> get parentCategories => _parentCategories;
  bool get loading => _loading;

  /// Nom à afficher pour une catégorie : si elle a un parent (parent_id != null), retourne le nom du parent.
  String? getDisplayNameForCategory(Category? category) {
    if (category == null) return null;
    if (category.parentId == null) return category.name;
    return _categoryIdToDisplayName[category.id] ?? category.name;
  }

  String? getDisplayNameForCategoryId(int categoryId) =>
      _categoryIdToDisplayName[categoryId];

  void _buildCategoryDisplayNames() {
    _categoryIdToDisplayName.clear();
    for (final parent in _parentCategories) {
      _categoryIdToDisplayName[parent.id] = parent.name;
      for (final child in parent.children) {
        _categoryIdToDisplayName[child.id] = parent.name;
      }
    }
  }

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
      final withoutActualites = sorted
          .where((c) => c.slug != 'actualites' && c.id != 3)
          .toList();
      _parentCategories = [getActualitesCategory(), ...withoutActualites];
      _buildCategoryDisplayNames();
    } catch (_) {
      _parentCategories = _sortParentCategories(getFallbackCategories());
      _buildCategoryDisplayNames();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
