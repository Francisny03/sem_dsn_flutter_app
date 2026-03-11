import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:sem_dsn/core/constants/api_config.dart';
import 'package:sem_dsn/models/live.dart';

/// Récupère la config du direct (un seul par app).
/// L'API peut renvoyer un objet unique ou une liste ; on prend le premier si liste.
Future<Live?> fetchLive() async {
  final uri = Uri.parse(ApiConfig.lives());
  final response = await http.get(uri, headers: {'accept': 'application/json'});
  if (response.statusCode != 200) {
    return null;
  }
  final body = response.body.trim();
  if (body.isEmpty) return null;

  final decoded = json.decode(body);
  if (decoded is List) {
    if (decoded.isEmpty) return null;
    final first = decoded.first;
    if (first is! Map<String, dynamic>) return null;
    return Live.fromJson(first);
  }
  if (decoded is Map<String, dynamic>) {
    return Live.fromJson(decoded);
  }
  return null;
}
