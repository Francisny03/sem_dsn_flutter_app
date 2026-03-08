/// Livre renvoyé par l’API (bibliographie).
class Book {
  const Book({
    required this.id,
    required this.name,
    required this.cover,
    required this.file,
    required this.createdAt,
    required this.updatedAt,
    required this.coverUrl,
    required this.fileUrl,
    this.author,
    this.description,
    this.publishedAt,
  });

  final int id;
  final String name;
  final String cover;
  final String file;
  final String createdAt;
  final String updatedAt;
  final String coverUrl;
  final String fileUrl;

  /// Auteur du livre (optionnel, fourni par l’API si dispo).
  final String? author;

  /// Résumé / description du livre (optionnel).
  final String? description;

  /// Date de publication du livre (optionnel). Le backend peut envoyer une date+heure (ISO) ; on n’utilise que la date pour l’affichage.
  final String? publishedAt;

  /// Année extraite de [publishedAt] ou [createdAt] pour l’affichage (ex. "2026").
  String get year {
    final raw = publishedAt ?? createdAt;
    if (raw.length >= 4) return raw.substring(0, 4);
    return '';
  }

  /// Date affichée : date complète ou seule année selon le format dispo.
  String get displayDate {
    final raw = publishedAt ?? createdAt;
    if (raw.isEmpty) return '';
    if (raw.length <= 4) return raw;
    try {
      final d = DateTime.parse(raw);
      const months = [
        'Jan',
        'Fév',
        'Mar',
        'Avr',
        'Mai',
        'Juin',
        'Juil',
        'Août',
        'Sep',
        'Oct',
        'Nov',
        'Déc',
      ];
      return '${d.day} ${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return raw.length >= 4 ? raw.substring(0, 4) : raw;
    }
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      cover: json['cover'] as String? ?? '',
      file: json['file'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      coverUrl: json['cover_url'] as String? ?? '',
      fileUrl: json['file_url'] as String? ?? '',
      author: json['author'] as String?,
      description: json['description'] as String?,
      publishedAt: _parseDateOnly(json['published_at'] as String?),
    );
  }

  /// Le backend peut envoyer une date+heure (ex. 2026-01-15T14:30:00Z) ; on garde uniquement la date (YYYY-MM-DD).
  static String? _parseDateOnly(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length >= 10) return value.substring(0, 10);
    return value;
  }
}
