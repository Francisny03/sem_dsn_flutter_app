import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sem_dsn/services/selection_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _readStorageKey = 'sem_dsn_read_articles';

/// Cache des articles déjà lus. Persiste sur le disque (SharedPreferences).
/// Reste jusqu'à désinstallation de l'app.
class ReadArticlesService extends ChangeNotifier {
  ReadArticlesService._();
  static final ReadArticlesService instance = ReadArticlesService._();

  final Set<String> _readKeys = {};
  SharedPreferences? _prefs;

  static String _keyFor(SelectedArticle article) =>
      '${article.title}|${article.date}|${article.imagePath}';

  /// Charge la liste des articles lus depuis le disque. À appeler avant [runApp] (ex. dans [main]).
  Future<void> loadFromDisk() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs?.getString(_readStorageKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>?;
      if (list == null) return;
      _readKeys.clear();
      for (final e in list) {
        if (e is String) _readKeys.add(e);
      }
    } catch (_) {
      // ignore invalid data
    }
  }

  Future<void> _save() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs ??= prefs;
    await prefs.setString(_readStorageKey, jsonEncode(_readKeys.toList()));
  }

  bool isRead(SelectedArticle article) => _readKeys.contains(_keyFor(article));

  void markAsRead(SelectedArticle article) {
    final key = _keyFor(article);
    if (_readKeys.contains(key)) return;
    _readKeys.add(key);
    notifyListeners();
    _save();
  }
}
