import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Modèle d'un article sélectionné (présent dans l'onglet Sélection).
class SelectedArticle {
  const SelectedArticle({
    required this.title,
    required this.date,
    required this.imagePath,
  });

  final String title;
  final String date;
  final String imagePath;

  Map<String, String> toJson() => {
        'title': title,
        'date': date,
        'imagePath': imagePath,
      };

  static SelectedArticle fromJson(Map<String, dynamic> json) {
    return SelectedArticle(
      title: json['title'] as String? ?? '',
      date: json['date'] as String? ?? '',
      imagePath: json['imagePath'] as String? ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectedArticle &&
          title == other.title &&
          date == other.date &&
          imagePath == other.imagePath;

  @override
  int get hashCode => Object.hash(title, date, imagePath);
}

const String _selectionStorageKey = 'sem_dsn_selection';

/// Service global de sélection d'articles (étoile). Persiste sur le disque (SharedPreferences).
/// Reste jusqu'à désinstallation de l'app. Notifie les listeners à chaque changement.
class SelectionService extends ChangeNotifier {
  SelectionService._();
  static final SelectionService instance = SelectionService._();

  final List<SelectedArticle> _items = [];
  SharedPreferences? _prefs;

  List<SelectedArticle> get items => List.unmodifiable(_items);

  /// Charge les sélections depuis le disque. À appeler avant [runApp] (ex. dans [main]).
  Future<void> loadFromDisk() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs?.getString(_selectionStorageKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>?;
      if (list == null) return;
      _items.clear();
      for (final e in list) {
        if (e is Map<String, dynamic>) {
          _items.add(SelectedArticle.fromJson(e));
        }
      }
    } catch (_) {
      // ignore invalid data
    }
  }

  Future<void> _save() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs ??= prefs;
    final list = _items.map((e) => e.toJson()).toList();
    await prefs.setString(_selectionStorageKey, jsonEncode(list));
  }

  bool contains(SelectedArticle article) {
    return _items.any((a) =>
        a.title == article.title &&
        a.date == article.date &&
        a.imagePath == article.imagePath);
  }

  void add(SelectedArticle article) {
    if (contains(article)) return;
    _items.add(article);
    notifyListeners();
    _save();
  }

  void remove(SelectedArticle article) {
    _items.removeWhere((a) =>
        a.title == article.title &&
        a.date == article.date &&
        a.imagePath == article.imagePath);
    notifyListeners();
    _save();
  }

  void toggle(SelectedArticle article) {
    if (contains(article)) {
      remove(article);
    } else {
      add(article);
    }
  }
}
