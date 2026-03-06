import 'package:sem_dsn/models/category.dart';

/// Mode d'affichage du contenu d'une catégorie (parent avec ou sans enfants).
/// Dès que l'API fournira ce champ par catégorie, on l'utilisera ; en attendant
/// on dérive à partir du nombre d'enfants (1 → overlay, 2+ → with_children).
enum CategoryDisplayLayout {
  /// Liste overlay (image + gradient + titre/date).
  overlay,

  /// Deux blocs : 1er enfant = « À la une », reste = « Articles de presse ».
  withChildren,

  /// Grille de sous-catégories (style Discours).
  discoursGrid,

  /// Image en haut, titre/date en dessous (ex. Réalisations, Économie).
  imageBelow,
}

/// Retourne le layout pour une catégorie.
/// Pour l'instant : 1 enfant → overlay, 2+ enfants → with_children.
/// Plus tard : si [category] a un champ layout fourni par l'API, l'utiliser en priorité.
CategoryDisplayLayout getDisplayLayoutForCategory(Category category) {
  // TODO: quand l'API envoie display_layout (overlay | with_children | discours_grid | image_below),
  // lire category.displayLayout et le retourner ici pour piloter l'affichage sans mise à jour app.
  final n = category.children.length;
  if (n == 0) {
    return CategoryDisplayLayout
        .overlay; // parent sans enfants : géré par HomeFilterContent
  }
  if (n == 1) {
    return CategoryDisplayLayout.overlay;
  }
  return CategoryDisplayLayout.withChildren;
}
