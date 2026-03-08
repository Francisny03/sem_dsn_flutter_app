/// URL de base de l'API — à modifier ici uniquement pour changer partout.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'https://appdsn.reveurs.pro/api';

  static String categoriesAll() => '$baseUrl/categories/all';
  static String categories() => '$baseUrl/categories';
  static String category(int id) => '$baseUrl/categories/$id';

  static String articles() => '$baseUrl/articles';
  static String article(int id) => '$baseUrl/articles/$id';
  static String articlesHome() => '$baseUrl/articles/home?category_id=all';

  /// Tous les articles publics (liste globale ou filtrée par catégorie). Utilisé pour Hero, filtres et overlay (ex. Discours).
  static String articlesPublicAll({
    int page = 1,
    int limit = 200,
    int? categoryId,
  }) {
    var url = '$baseUrl/articles/public/all?page=$page&limit=$limit';
    if (categoryId != null) {
      url += '&category_id=$categoryId';
    }
    return url;
  }

  /// Articles d’une catégorie (ex. Réalisations). page/limit pour pagination.
  static String articlesByCategory(int categoryId, {int page = 1, int limit = 20}) =>
      '$baseUrl/articles/public/categories/$categoryId?page=$page&limit=$limit';

  static String books() => '$baseUrl/books';

  static String galleries() => '$baseUrl/galleries';
  static String galleryImages(int galleryId) => '$baseUrl/galleries/$galleryId/images';
}
