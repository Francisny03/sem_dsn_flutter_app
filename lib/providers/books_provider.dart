import 'package:flutter/foundation.dart';

import 'package:sem_dsn/models/book.dart';
import 'package:sem_dsn/services/books_api.dart';

/// Provider des livres (bibliographie) — cache en mémoire.
class BooksProvider extends ChangeNotifier {
  List<Book> _books = [];
  bool _loading = false;
  bool _loadFailed = false;

  List<Book> get books => _books;
  bool get loading => _loading;
  bool get loadFailed => _loadFailed;

  Book? getBookById(int id) {
    try {
      return _books.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadIfNeeded() async {
    if (_loading || _books.isNotEmpty) return;
    await load();
  }

  Future<void> load() async {
    _loading = true;
    _loadFailed = false;
    notifyListeners();
    try {
      final res = await fetchBooks();
      final list = res.results;
      list.sort((a, b) => (a.position ?? 0).compareTo(b.position ?? 0));
      _books = list;
    } catch (_) {
      _loadFailed = true;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
