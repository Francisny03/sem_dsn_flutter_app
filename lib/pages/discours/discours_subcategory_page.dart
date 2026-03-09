import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sem_dsn/core/constants/app_border_radius.dart';
import 'package:sem_dsn/core/constants/app_font_sizes.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/constants/discours_data.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/core/animation/selection_star_animation.dart';
import 'package:sem_dsn/services/selection_service.dart';
import 'package:sem_dsn/widget/article_detail_args.dart';
import 'package:sem_dsn/widget/article_video_player.dart';

/// Seuil de scroll (px) à partir duquel le titre s'affiche dans l'AppBar.
const double _kTitleInAppBarScrollThreshold = 90;

/// Page d'une sous-catégorie Discours : titre en rouge italic (font menu),
/// puis liste des items en style Campagne (image stack, gradient, titre, date, sélection).
/// Le nom de la sous-catégorie apparaît dans l'AppBar après scroll.
class DiscoursSubcategoryPage extends StatefulWidget {
  const DiscoursSubcategoryPage({
    super.key,
    required this.subcategoryTitle,
    required this.items,
    required this.onArticleTap,
  });

  final String subcategoryTitle;
  final List<DiscoursOverlayItem> items;
  final void Function(ArticleDetailArgs args) onArticleTap;

  @override
  State<DiscoursSubcategoryPage> createState() =>
      _DiscoursSubcategoryPageState();
}

class _DiscoursSubcategoryPageState extends State<DiscoursSubcategoryPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showTitleInAppBar = false;

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
    final show = _scrollController.offset > _kTitleInAppBarScrollThreshold;
    if (show != _showTitleInAppBar && mounted) {
      setState(() => _showTitleInAppBar = show);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectionService = context.watch<SelectionService>();
    final tag = AppStrings.speeches;
    final subcategoryTitle = widget.subcategoryTitle;
    final items = widget.items;
    final onArticleTap = widget.onArticleTap;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.bg,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 22),
              color: AppColors.blackIcon,
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: _showTitleInAppBar
                ? Text(
                    subcategoryTitle,
                    style: const TextStyle(
                      color: AppColors.navBottomSelectItem,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : null,
            titleSpacing: 0,
            centerTitle: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text(
                subcategoryTitle,
                style: const TextStyle(
                  color: AppColors.navBottomSelectItem,
                  fontSize: AppFontSizes.menuTitle,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          if (items.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = items[index];
                  final article = SelectedArticle(
                    title: item.title,
                    date: item.date,
                    imagePath: item.image,
                  );
                  final heroTag = ArticleDetailArgs.heroTagFor(
                    imagePath: item.image,
                    title: item.title,
                    date: item.date,
                    sourceId: 'discours_${widget.subcategoryTitle}_$index',
                    index: index,
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _DiscoursOverlayCard(
                      imagePath: item.image,
                      title: item.title,
                      date: item.date,
                      showPlayButton: item.isVideo,
                      heroTag: heroTag,
                      isStarSelected: selectionService.contains(article),
                      onStarTap: () => selectionService.toggle(article),
                      onTap: () => onArticleTap(
                        ArticleDetailArgs(
                          title: item.title,
                          date: item.date,
                          tag: tag,
                          body: AppStrings.articleBodySample,
                          imagePath: item.image,
                          isVideo: item.isVideo,
                          videoPath: item.isVideo ? kYoutubeTestUrl : null,
                          isHeroOrFeatured: false,
                          heroTagOverride: heroTag,
                        ),
                      ),
                    ),
                  );
                }, childCount: items.length),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _DiscoursOverlayCard extends StatelessWidget {
  const _DiscoursOverlayCard({
    required this.imagePath,
    required this.title,
    required this.date,
    required this.showPlayButton,
    required this.heroTag,
    required this.isStarSelected,
    required this.onStarTap,
    required this.onTap,
  });

  final String imagePath;
  final String title;
  final String date;
  final bool showPlayButton;
  final Object heroTag;
  final bool isStarSelected;
  final VoidCallback onStarTap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: AppBorderRadius.r10,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 220,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: heroTag,
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientFeatured,
                    ),
                  ),
                ],
              ),
            ),
            if (showPlayButton)
              Hero(
                tag: ArticleDetailArgs.heroTagForVideoPlay(heroTag),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: AppColors.whiteTextColor,
                    size: 40,
                  ),
                ),
              ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: onStarTap,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: AnimatedSelectionStar(
                    isSelected: isStarSelected,
                    onTap: onStarTap,
                    selectedColor: AppColors.heroSelectionTag,
                    unselectedColor: AppColors.whiteTextColor,
                    size: 22,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 80,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.whiteTextColor,
                      fontSize: AppFontSizes.campaignTitle,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 0),
                  Text(
                    date,
                    style: TextStyle(
                      color: AppColors.whiteTextColor.withValues(alpha: 0.9),
                      fontSize: AppFontSizes.campaignDate,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
