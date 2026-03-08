import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/constants/app_assets.dart';
import 'package:sem_dsn/models/article.dart';
import 'package:sem_dsn/models/article_source.dart';

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
    this.articleId,
    this.sources,
    this.bodyHtml,
  });

  final String title;
  final String date;
  final String tag;
  final String body;
  final String imagePath;
  final bool isVideo;

  /// Id API de l’article (pour chargement détail ou suivi).
  final int? articleId;

  /// Sources à afficher en fin d’article (nom + URL en colonne).
  final List<ArticleSource>? sources;

  /// Corps en HTML (si défini, utilisé à la place de [body] pour l’affichage).
  final String? bodyHtml;

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

  /// Construit les arguments à partir d’un [Article] API (tag = nom catégorie, image = première image ou placeholder).
  static ArticleDetailArgs fromArticle(
    Article article,
    String tag, {
    Object? heroTagOverride,
    bool isHeroOrFeatured = false,
  }) {
    final date = _formatArticleDate(article.articleDate);
    final hasVideo = article.hasVideo;
    return ArticleDetailArgs(
      title: article.title,
      date: date,
      tag: tag,
      body: article.subtitle ?? article.title,
      bodyHtml: article.description.isNotEmpty ? article.description : null,
      imagePath: article.firstImageUrl ?? AppAssets.defaultImageArticle,
      articleId: article.id,
      sources: article.sources.isNotEmpty ? article.sources : null,
      isHeroOrFeatured: isHeroOrFeatured,
      heroTagOverride: heroTagOverride,
      isVideo: hasVideo,
      videoPath: hasVideo ? article.videoUrl : null,
    );
  }

  static String _formatArticleDate(String iso) {
    if (iso.length < 10) return iso;
    try {
      final d = DateTime.parse(iso);
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
      return iso.substring(0, 10);
    }
  }

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
