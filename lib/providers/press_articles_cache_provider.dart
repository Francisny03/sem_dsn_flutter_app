import 'package:flutter/foundation.dart';

import 'package:sem_dsn/models/article.dart';

/// Cache des articles de presse affichés sur la home (Actualités).
/// Utilisé par la section "Autres Actualités" en bas de la page détail.
class PressArticlesCacheProvider extends ChangeNotifier {
  List<Article> _pressArticles = [];

  List<Article> get pressArticles => _pressArticles;

  void setPressArticles(List<Article> list) {
    if (listEquals(list, _pressArticles)) return;
    _pressArticles = list;
    notifyListeners();
  }
}
