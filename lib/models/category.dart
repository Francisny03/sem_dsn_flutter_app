/// Catégorie renvoyée par l'API (arbre : parent + children).
class Category {
  const Category({
    required this.id,
    this.parentId,
    required this.name,
    required this.slug,
    required this.createdAt,
    required this.updatedAt,
    this.children = const [],
    this.position,
  });

  final int id;
  final int? parentId;
  final String name;
  final String slug;
  final String createdAt;
  final String updatedAt;
  final List<Category> children;

  /// Ordre d’affichage (si fourni par le backend) ; sinon on trie par id.
  final int? position;

  bool get isParent => parentId == null;
  bool get hasChildren => children.isNotEmpty;

  factory Category.fromJson(Map<String, dynamic> json) {
    final childrenList = json['children'] as List<dynamic>?;
    return Category(
      id: json['id'] as int,
      parentId: json['parent_id'] as int?,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      children:
          childrenList
              ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      position: json['position'] as int?,
    );
  }
}
