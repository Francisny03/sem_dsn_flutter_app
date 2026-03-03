import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sem_dsn/core/constants/app_assets.dart';
import 'package:sem_dsn/core/constants/app_border_radius.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/core/animation/selection_star_animation.dart';

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

  /// Afficher la section "Autres Actualités" en bas (si tag == Actualités).
  bool get showOtherNews => tag == AppStrings.news;
}

/// Page détail : image/vidéo derrière la status bar, tag, titre, date, article, puis "Autres Actualités" si applicable.
/// SliverAppBar : le titre s'affiche dans l'AppBar quand on scrolle.
class ArticleDetailPage extends StatefulWidget {
  const ArticleDetailPage({super.key, required this.args});

  final ArticleDetailArgs args;

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  bool _isStarSelected = false;
  final ScrollController _scrollController = ScrollController();
  bool _showTitleInAppBar = false;
  static const double _imageHeight = 280;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final topPadding = MediaQuery.paddingOf(context).top;
    final expandedHeight = _imageHeight + topPadding;
    final threshold = expandedHeight - kToolbarHeight - 20;
    final shouldShow = _scrollController.offset > threshold;
    if (shouldShow != _showTitleInAppBar) {
      setState(() => _showTitleInAppBar = shouldShow);
    }
  }

  void _shareArticle(BuildContext buttonContext) {
    final text = '${widget.args.title}\n\n${widget.args.body}';
    final box = buttonContext.findRenderObject() as RenderBox?;
    Share.share(
      text,
      subject: widget.args.title,
      sharePositionOrigin: box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final expandedHeight = _imageHeight + topPadding;
    final isOverImage = !_showTitleInAppBar;
    final iconColor = isOverImage ? Colors.white : AppColors.blackIcon;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isOverImage
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: AppColors.bg,
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              expandedHeight: expandedHeight,
              pinned: true,
              stretch: true,
              backgroundColor: AppColors.bg,
              toolbarHeight: topPadding + kToolbarHeight,
              leading: SizedBox(
                width: 56,
                height: topPadding + kToolbarHeight,
                child: Stack(
                  children: [
                    Positioned(
                      left: 6,
                      top: topPadding - 50,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: iconColor,
                          size: 22,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(8),
                          minimumSize: const Size(40, 40),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                SizedBox(
                  width: 56 * 2 + 4,
                  height: topPadding + kToolbarHeight,
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      Positioned(
                        right: 10,
                        top: topPadding - 50,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _DetailAppBarStar(
                              isSelected: _isStarSelected,
                              onTap: () {
                                setState(
                                  () => _isStarSelected = !_isStarSelected,
                                );
                                if (_isStarSelected) {}
                              },
                              iconColor: iconColor,
                            ),
                            const SizedBox(width: 4),
                            Builder(
                              builder: (buttonContext) => IconButton(
                                icon: Icon(
                                  Icons.share,
                                  color: iconColor,
                                  size: 22,
                                ),
                                onPressed: () => _shareArticle(buttonContext),
                                style: IconButton.styleFrom(
                                  padding: const EdgeInsets.all(8),
                                  minimumSize: const Size(40, 40),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              titleSpacing: -5,
              title: _showTitleInAppBar
                  ? SizedBox(
                      height: topPadding + kToolbarHeight,
                      child: Align(
                        alignment: Alignment(
                          -1,
                          2 *
                                  (topPadding - 30) /
                                  (topPadding + kToolbarHeight) -
                              1,
                        ),
                        child: Text(
                          widget.args.title,
                          style: const TextStyle(
                            color: AppColors.onSurfaceLight,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                  : null,
              flexibleSpace: FlexibleSpaceBar(
                background: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCollapsed =
                        constraints.maxHeight <= kToolbarHeight + 24;
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(widget.args.imagePath, fit: BoxFit.cover),
                        if (widget.args.isVideo)
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withValues(alpha: 0.5),
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          ),
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0x66000000),
                                Colors.transparent,
                                Color(0x99000000),
                              ],
                              stops: [0.0, 0.25, 1.0],
                            ),
                          ),
                        ),
                        if (widget.args.isHeroOrFeatured)
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom: 24,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.heroTag,
                                    borderRadius: AppBorderRadius.rtotal,
                                  ),
                                  child: Text(
                                    widget.args.tag,
                                    style: const TextStyle(
                                      color: AppColors.whiteTextColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.args.title,
                                  style: const TextStyle(
                                    color: AppColors.whiteTextColor,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (widget.args.date.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.args.date,
                                    style: TextStyle(
                                      color: AppColors.whiteTextColor
                                          .withValues(alpha: 0.9),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        if (isCollapsed)
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: AppColors.bg,
                          ),
                      ],
                    );
                  },
                ),
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: _ArticleContent(
                title: widget.args.title,
                date: widget.args.date,
                tag: widget.args.tag,
                body: widget.args.body,
                showTagTitleDate: !widget.args.isHeroOrFeatured,
              ),
            ),
            if (widget.args.showOtherNews) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    AppStrings.otherNewsTitle,
                    style: const TextStyle(
                      color: AppColors.sectionTitle,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    _otherNewsItems
                        .map(
                          (e) => _OtherNewsTile(
                            imagePath: e.image,
                            title: e.title,
                            date: e.date,
                            onTap: () {},
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ] else
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

/// Étoile de sélection dans l'AppBar (même comportement + animation).
class _DetailAppBarStar extends StatelessWidget {
  const _DetailAppBarStar({
    required this.isSelected,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedSelectionStar(
      isSelected: isSelected,
      onTap: onTap,
      selectedColor: AppColors.heroSelectionTag,
      unselectedColor: iconColor,
      size: 22,
    );
  }
}

/// Bloc sous l'image : optionnellement tag + titre + date, puis corps de l'article.
class _ArticleContent extends StatelessWidget {
  const _ArticleContent({
    required this.title,
    required this.date,
    required this.tag,
    required this.body,
    this.showTagTitleDate = true,
  });

  final String title;
  final String date;
  final String tag;
  final String body;

  /// false = Hero/À la une : afficher uniquement le corps (sans tag, titre, date).
  final bool showTagTitleDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTagTitleDate) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.heroTag,
                borderRadius: AppBorderRadius.rtotal,
              ),
              child: Text(
                tag,
                style: const TextStyle(
                  color: AppColors.whiteTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.newsTitle,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (date.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                date,
                style: const TextStyle(color: AppColors.newsDate, fontSize: 14),
              ),
            ],
            const SizedBox(height: 20),
          ],
          Text(
            body,
            style: const TextStyle(
              color: AppColors.newsTitle,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Données pour "Autres Actualités".
final List<({String image, String title, String date})> _otherNewsItems = [
  (
    image: AppAssets.news1,
    title:
        "Le président Denis Sassou-Nguesso a été reçu jeudi à Beijing en Chine",
    date: '04 Septembre 2025',
  ),
  (
    image: AppAssets.news2,
    title: "Chine : Denis Sassou-Nguesso reçu par Vladimir Poutine à Pékin",
    date: '04 Septembre 2025',
  ),
  (
    image: AppAssets.news3,
    title: "France - Congo : Macron reçoit Denis Sassou N'Guesso à l'Élysée",
    date: '23 Mai 2025',
  ),
];

class _OtherNewsTile extends StatelessWidget {
  const _OtherNewsTile({
    required this.imagePath,
    required this.title,
    required this.date,
    required this.onTap,
  });

  final String imagePath;
  final String title;
  final String date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorderRadius.r10,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: AppBorderRadius.r10,
                child: Image.asset(
                  imagePath,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.newsTitle,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: const TextStyle(
                        color: AppColors.newsDate,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
