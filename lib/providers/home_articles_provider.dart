import 'package:flutter/foundation.dart' show ChangeNotifier;

import 'package:sem_dsn/models/article.dart';
import 'package:sem_dsn/services/articles_api.dart' show fetchArticlesHome;

/// Provider des articles de la page d’accueil (Actualités) : À la une + Autres infos.
class HomeArticlesProvider extends ChangeNotifier {
  List<Article> _aLaUne = [];
  List<Article> _contenuGeneral = [];
  bool _loading = false;

  List<Article> get aLaUne => _aLaUne;
  List<Article> get contenuGeneral => _contenuGeneral;
  bool get loading => _loading;

  /// Charge les articles home si pas déjà chargés.
  Future<void> loadIfNeeded() async {
    if (_loading || (_aLaUne.isNotEmpty || _contenuGeneral.isNotEmpty)) return;
    await load();
  }

  /// Force le rechargement (ex. pull-to-refresh).
  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      final res = await fetchArticlesHome();
      _aLaUne = res.aLaUne;
      _contenuGeneral = res.contenuGeneral;
    } catch (_) {
      _aLaUne = [];
      _contenuGeneral = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
