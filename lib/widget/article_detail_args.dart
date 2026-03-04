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
    this.videoPath,
    this.isHeroOrFeatured = false,
    this.titleInAppBarScrollOffset,
    this.heroTagOverride,
  });

  final String title;
  final String date;
  final String tag;
  final String body;
  final String imagePath;
  final bool isVideo;

  /// Chemin de la vidéo (asset ou URL). Si [isVideo] est true et [videoPath] null, utiliser une vidéo par défaut côté lecteur.
  final String? videoPath;

  /// Si défini, utilisé comme tag Hero à la place de heroTagFor(...). Évite les doublons quand le même article apparaît plusieurs fois (ex. À la une, Autres actualités).
  final Object? heroTagOverride;

  /// true = Hero ou À la une : tag/titre/date sur l'image, en dessous uniquement le corps.
  /// false = Press, Campagne, Réalisations etc. : image seule, tag/titre/date en dessous + corps.
  final bool isHeroOrFeatured;

  /// Seuil de scroll (offset en px) à partir duquel le titre s'affiche dans l'app bar.
  /// Si null, même formule pour Hero/Featured et Presse (aligné sur le comportement featured).
  /// Tu peux passer une valeur pour contrôler le moment toi-même (ex: 200.0).
  final double? titleInAppBarScrollOffset;

  /// Afficher la section "Autres Actualités" en bas (si tag == Actualités).
  bool get showOtherNews => tag == AppStrings.news;

  /// Tag unique pour la Hero animation (même tag à la source et sur la page détail).
  Object get heroTag =>
      heroTagOverride ??
      ArticleDetailArgs.heroTagFor(
        imagePath: imagePath,
        title: title,
        date: date,
      );

  /// Tag Hero pour l’icône play (vidéo), à utiliser sur la home et sur la page détail.
  Object get heroTagVideoPlay => ArticleDetailArgs.heroTagForVideoPlay(heroTag);

  /// Construit un tag à partir de (imagePath, title, date). Optionnellement [sourceId] et [index] pour rendre le tag unique par emplacement (évite "multiple heroes same tag").
  static Object heroTagFor({
    required String imagePath,
    required String title,
    required String date,
    Object? sourceId,
    int? index,
  }) => Object.hash(imagePath, title, date, sourceId, index);

  /// Tag pour la Hero de l’icône play (vidéo). Même tag sur la liste et sur la page détail.
  static Object heroTagForVideoPlay(Object heroTag) =>
      Object.hash(heroTag, 'video_play');
}
