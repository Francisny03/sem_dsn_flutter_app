import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:sem_dsn/core/constants/api_config.dart';
import 'package:sem_dsn/models/book.dart';

class BooksResponse {
  const BooksResponse({required this.results, required this.total});

  final List<Book> results;
  final int total;
}

Future<BooksResponse> fetchBooks() async {
  final uri = Uri.parse(ApiConfig.books());
  final response = await http.get(uri, headers: {'accept': '*/*'});
  if (response.statusCode != 200) {
    throw Exception('books: ${response.statusCode}');
  }
  final map = json.decode(response.body) as Map<String, dynamic>;
  final list = map['results'] as List<dynamic>? ?? [];
  final total = map['total'] as int? ?? 0;
  return BooksResponse(
    results: list.map((e) => Book.fromJson(e as Map<String, dynamic>)).toList(),
    total: total,
  );
}
