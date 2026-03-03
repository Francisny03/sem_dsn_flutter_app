import 'package:sem_dsn/core/constants/app_strings.dart';

/// Arguments pour ouvrir la page détail (hero, à la une, campagne, presse, etc.).
class ArticleDetailArgs {
  const ArticleDetailArgs({
    required this.title,
    required this.date,
    required this.tag,
    required this.body,
    required this.imagePath,
    this.isVideo = false,
    this.isHeroOrFeatured = false,
    this.titleInAppBarScrollOffset,
  });

  final String title;
  final String date;
  final String tag;
  final String body;
  final String imagePath;
  final bool isVideo;

  /// true = Hero ou À la une : tag/titre/date sur l'image, en dessous uniquement le corps.
  /// false = Press, Campagne, Réalisations etc. : image seule, tag/titre/date en dessous + corps.
  final bool isHeroOrFeatured;

  /// Seuil de scroll (offset en px) à partir duquel le titre s'affiche dans l'app bar.
  /// Si null, même formule pour Hero/Featured et Presse (aligné sur le comportement featured).
  /// Tu peux passer une valeur pour contrôler le moment toi-même (ex: 200.0).
  final double? titleInAppBarScrollOffset;

  /// Afficher la section "Autres Actualités" en bas (si tag == Actualités).
  bool get showOtherNews => tag == AppStrings.news;
}
