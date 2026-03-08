class AppAssets {
  static const String logoApp = 'assets/icons/logo_app.svg';
  static const String logoSplashscreen = 'assets/icons/logo_splashscreen.svg';
  static const String bibliography = 'assets/icons/bibliography.svg';
  static const String gallery = 'assets/icons/gallery.svg';
  static const String home = 'assets/icons/home.svg';
  static const String livecustom = 'assets/icons/livecustom.svg';
  static const String liveOn = 'assets/icons/liveOn.svg';

  static const String selection = 'assets/icons/selection.svg';

  static const String selection2 = 'assets/icons/selection2.svg';
  static const String selection2Full = 'assets/icons/selection2full.svg';
  static const String threeDots = 'assets/icons/three_dots.svg';
  static const String search = 'assets/icons/search.svg';

  static const String dsn = 'assets/icons/dsn.svg';

  static const String welcome1 = 'assets/images/welcome1.png';
  static const String welcome2 = 'assets/images/welcome2.png';
  static const String welcome3 = 'assets/images/welcome3.png';

  static const String alaune1 = 'assets/images/alaune1.png';
  static const String alaune2 = 'assets/images/alaune2.png';
  static const String hero1 = 'assets/images/hero1.png';
  static const String hero2 = 'assets/images/hero2.png';
  static const String news1 = 'assets/images/news1.png';
  static const String news2 = 'assets/images/news2.png';
  static const String news3 = 'assets/images/news3.png';

  static const String biblio1 = 'assets/images/biblio1.png';
  static const String biblio2 = 'assets/images/biblio2.png';
  static const String biblio3 = 'assets/images/biblio3.png';
  static const String biblio4 = 'assets/images/biblio4.png';
  static const String biblio5 = 'assets/images/biblio5.png';

  static const String revue1 = 'assets/images/revue1.png';
  static const String revue2 = 'assets/images/revue2.png';
  static const String revue3 = 'assets/images/revue3.png';

  static const String defaultImageArticle = 'assets/images/placeholder.png';

  /// Si [path] est null ou vide, renvoie [defaultImageArticle], sinon [path].
  /// À utiliser pour home, photothèque, bibliographie, sélection quand le backend peut ne pas renvoyer d’image.
  static String imageOrDefault(String? path) =>
      (path == null || path.trim().isEmpty) ? defaultImageArticle : path;

  // static const String videotest = 'assets/videos/videotest.mp4';
}
