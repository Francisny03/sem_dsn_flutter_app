import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:sem_dsn/core/constants/api_config.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/models/category.dart';

/// Récupère les catégories (arbre) depuis l'API. Les éléments racine sont les parents.
Future<List<Category>> fetchCategoriesAll() async {
  final uri = Uri.parse(ApiConfig.categoriesAll());
  final response = await http.get(uri, headers: {'accept': '*/*'});
  if (response.statusCode != 200) {
    throw Exception('categories/all: ${response.statusCode}');
  }
  final list = json.decode(response.body) as List<dynamic>;
  return list.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
}

/// Catégories affichées quand l’API échoue ou renvoie une liste vide (toujours des onglets visibles).
List<Category> getFallbackCategories() {
  const base = '2026-01-01T00:00:00.000Z';
  return [
    Category(
      id: 0,
      parentId: null,
      name: AppStrings.news,
      slug: 'articles',
      createdAt: base,
      updatedAt: base,
      children: [],
    ),
    Category(
      id: 1,
      parentId: null,
      name: AppStrings.campaign,
      slug: 'campagne-2026',
      createdAt: base,
      updatedAt: base,
      children: [],
    ),
    Category(
      id: 2,
      parentId: null,
      name: AppStrings.achievements,
      slug: 'r-alisations',
      createdAt: base,
      updatedAt: base,
      children: [],
    ),
    Category(
      id: 3,
      parentId: null,
      name: AppStrings.speeches,
      slug: 'discours',
      createdAt: base,
      updatedAt: base,
      children: [],
    ),
    Category(
      id: 4,
      parentId: null,
      name: AppStrings.projects,
      slug: 'projets',
      createdAt: base,
      updatedAt: base,
      children: [],
    ),
    Category(
      id: 5,
      parentId: null,
      name: AppStrings.interviews,
      slug: 'interviews',
      createdAt: base,
      updatedAt: base,
      children: [],
    ),
    Category(
      id: 6,
      parentId: null,
      name: AppStrings.archives,
      slug: 'archives',
      createdAt: base,
      updatedAt: base,
      children: [],
    ),
  ];
}
