import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sem_dsn/core/constants/app_assets.dart';
import 'package:sem_dsn/core/constants/app_border_radius.dart';
import 'package:sem_dsn/core/constants/app_font_sizes.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/core/animation/selection_star_animation.dart';
import 'package:sem_dsn/models/article.dart';
import 'package:sem_dsn/providers/categories_provider.dart';
import 'package:sem_dsn/services/selection_service.dart';
import 'package:sem_dsn/widget/article_detail_args.dart';
import 'package:sem_dsn/widget/image_from_path.dart';
import 'package:sem_dsn/widget/netflix_shimmer.dart';

/// Section "Featured" (À La Une) : liste horizontale de cartes d'articles en vedette.
/// Si [loading] est true, affiche un placeholder style Netflix.
/// Si [articles] est fourni (API), affiche ces articles ; sinon données statiques.
class FeaturedSection extends StatefulWidget {
  const FeaturedSection({
    super.key,
    this.articles,
    this.loading = false,
    this.sectionTitle,
    this.displayTag,
    this.selectionService,
    this.onArticleTap,
  });

  final List<Article>? articles;

  /// true = afficher le placeholder de chargement (style Netflix).
  final bool loading;

  /// Si fourni (ex. nom de la sous-catégorie API), remplace le titre par défaut.
  final String? sectionTitle;

  /// Tag affiché (ex. nom du parent). Si fourni, utilisé pour les articles au lieu de la catégorie de l'article.
  final String? displayTag;
  final SelectionService? selectionService;
  final void Function(ArticleDetailArgs args)? onArticleTap;

  @override
  State<FeaturedSection> createState() => _FeaturedSectionState();
}

class _FeaturedSectionState extends State<FeaturedSection> {
  @override
  void initState() {
    super.initState();
    widget.selectionService?.addListener(_onSelectionChanged);
  }

  @override
  void didUpdateWidget(covariant FeaturedSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectionService != widget.selectionService) {
      oldWidget.selectionService?.removeListener(_onSelectionChanged);
      widget.selectionService?.addListener(_onSelectionChanged);
    }
  }

  @override
  void dispose() {
    widget.selectionService?.removeListener(_onSelectionChanged);
    super.dispose();
  }

  void _onSelectionChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    if (widget.loading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              widget.sectionTitle ?? AppStrings.sectionTitleFeatured,
              style: const TextStyle(
                color: AppColors.sectionTitle,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              itemBuilder: (_, __) =>
                  NetflixShimmer(child: _FeaturedSkeletonCard()),
            ),
          ),
        ],
      );
    }
    final apiArticles = widget.articles ?? [];
    final useApi = apiArticles.isNotEmpty;
    final count = useApi ? apiArticles.length : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            widget.sectionTitle ?? AppStrings.sectionTitleFeatured,
            style: TextStyle(
              color: AppColors.sectionTitle,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (count > 0)
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: count,
              itemBuilder: (context, index) {
                final article = apiArticles[index];
                final imagePath =
                    article.firstImageUrl ?? AppAssets.defaultImageArticle;
                final date = Article.formatDisplayDate(article.articleDate);
                final cat = article.categories.isNotEmpty
                    ? article.categories.first
                    : null;
                final tag =
                    widget.displayTag ??
                    (context
                            .read<CategoriesProvider>()
                            .getDisplayNameForCategory(cat) ??
                        cat?.name ??
                        AppStrings.news);
                final selectedArticle = SelectedArticle(
                  title: article.title,
                  date: date,
                  imagePath: imagePath,
                );
                final heroTag = ArticleDetailArgs.heroTagFor(
                  imagePath: imagePath,
                  title: article.title,
                  date: date,
                  sourceId: 'featured',
                  index: index,
                );
                return _FeaturedCard(
                  imagePath: imagePath,
                  title: article.title,
                  date: date,
                  heroTag: heroTag,
                  showPlayButton: article.hasVideo,
                  isStarSelected:
                      widget.selectionService?.contains(selectedArticle) ??
                      false,
                  onStarTap: widget.selectionService != null
                      ? () => widget.selectionService!.toggle(selectedArticle)
                      : null,
                  onTap: widget.onArticleTap != null
                      ? () => widget.onArticleTap!(
                          ArticleDetailArgs.fromArticle(
                            article,
                            tag,
                            isHeroOrFeatured: true,
                            heroTagOverride: heroTag,
                          ),
                        )
                      : null,
                );
              },
            ),
          ),
      ],
    );
  }
}

const Color _kFeaturedSkeletonColor = Color(0xFF3D3D3D);

/// Carte skeleton pour À la une (même forme que _FeaturedCard : rectangle + texte en bas).
class _FeaturedSkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 220,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: AppBorderRadius.r12,
      ),
      child: ClipRRect(
        borderRadius: AppBorderRadius.r12,
        child: Stack(
          children: [
            Positioned(
              left: 12,
              right: 12,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _kFeaturedSkeletonColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 14,
                    width: 100,
                    decoration: BoxDecoration(
                      color: _kFeaturedSkeletonColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Icon(
                Icons.star_border,
                size: 20,
                color: _kFeaturedSkeletonColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.imagePath,
    required this.title,
    required this.date,
    required this.heroTag,
    this.showPlayButton = false,
    this.isStarSelected = false,
    this.onStarTap,
    this.onTap,
  });

  final String imagePath;
  final String title;
  final String date;
  final Object heroTag;
  final bool showPlayButton;
  final bool isStarSelected;
  final VoidCallback? onStarTap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 220,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(borderRadius: AppBorderRadius.r12),
        child: ClipRRect(
          borderRadius: AppBorderRadius.r12,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: heroTag,
                child: ImageFromPath(
                  path: imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.gradientFeatured,
                ),
              ),
              if (showPlayButton)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: AppColors.whiteTextColor,
                      size: 36,
                    ),
                  ),
                ),
              if (onStarTap != null)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onStarTap,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: AnimatedSelectionStar(
                        isSelected: isStarSelected,
                        onTap: onStarTap!,
                        selectedColor: AppColors.heroSelectionTag,
                        unselectedColor: AppColors.whiteTextColor,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.whiteTextColor,
                        fontSize: AppFontSizes.featuredTitle,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: TextStyle(
                        color: AppColors.whiteTextColor.withValues(alpha: 0.9),
                        fontSize: AppFontSizes.featuredDate,
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
