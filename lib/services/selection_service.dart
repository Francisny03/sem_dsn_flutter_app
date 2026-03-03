import 'package:flutter/foundation.dart';

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

/// Service global de sélection d'articles (étoile). Notifie les listeners à chaque changement.
class SelectionService extends ChangeNotifier {
  SelectionService._();
  static final SelectionService instance = SelectionService._();

  final List<SelectedArticle> _items = [];

  List<SelectedArticle> get items => List.unmodifiable(_items);

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
  }

  void remove(SelectedArticle article) {
    _items.removeWhere((a) =>
        a.title == article.title &&
        a.date == article.date &&
        a.imagePath == article.imagePath);
    notifyListeners();
  }

  void toggle(SelectedArticle article) {
    if (contains(article)) {
      remove(article);
    } else {
      add(article);
    }
  }
}
