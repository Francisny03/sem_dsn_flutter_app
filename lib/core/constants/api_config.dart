/// URL de base de l'API — à modifier ici uniquement pour changer partout.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'https://appdsn.reveurs.pro/api';

  static String categoriesAll() => '$baseUrl/categories/all';
  static String categories() => '$baseUrl/categories';
  static String category(int id) => '$baseUrl/categories/$id';

  static String articles() => '$baseUrl/articles';
  static String article(int id) => '$baseUrl/articles/$id';

  static String books() => '$baseUrl/books';
}
