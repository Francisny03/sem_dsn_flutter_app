import 'package:flutter/foundation.dart';

import 'package:sem_dsn/models/book.dart';
import 'package:sem_dsn/services/books_api.dart';

/// Provider des livres (bibliographie) — cache en mémoire.
class BooksProvider extends ChangeNotifier {
  List<Book> _books = [];
  bool _loading = false;

  List<Book> get books => _books;
  bool get loading => _loading;

  Future<void> loadIfNeeded() async {
    if (_loading || _books.isNotEmpty) return;
    await load();
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      final res = await fetchBooks();
      _books = res.results;
    } catch (_) {
      _books = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
