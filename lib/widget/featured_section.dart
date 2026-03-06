import 'package:flutter/material.dart';
import 'package:sem_dsn/core/constants/app_assets.dart';
import 'package:sem_dsn/core/constants/app_border_radius.dart';
import 'package:sem_dsn/core/constants/app_font_sizes.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/core/animation/selection_star_animation.dart';
import 'package:sem_dsn/models/article.dart';
import 'package:sem_dsn/services/selection_service.dart';
import 'package:sem_dsn/widget/article_detail_args.dart';
import 'package:sem_dsn/widget/image_from_path.dart';

/// Section "Featured" (À La Une) : liste horizontale de cartes d'articles en vedette.
/// Si [articles] est fourni (API), affiche ces articles ; sinon données statiques.
class FeaturedSection extends StatefulWidget {
  const FeaturedSection({
    super.key,
    this.articles,
    this.sectionTitle,
    this.selectionService,
    this.onArticleTap,
  });

  final List<Article>? articles;
  /// Si fourni (ex. nom de la sous-catégorie API), remplace le titre par défaut.
  final String? sectionTitle;
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

  static const List<({String image, String title, String date})> _items = [
    (
      image: AppAssets.alaune1,
      title: AppStrings.featuredTitle1,
      date: AppStrings.featuredDate1,
    ),
    (
      image: AppAssets.alaune2,
      title: AppStrings.featuredTitle2,
      date: AppStrings.featuredDate2,
    ),
    (
      image: AppAssets.alaune1,
      title: AppStrings.featuredTitle3,
      date: AppStrings.featuredDate3,
    ),
    (
      image: AppAssets.alaune2,
      title: AppStrings.featuredTitle2,
      date: AppStrings.featuredDate2,
    ),
    (
      image: AppAssets.alaune1,
      title: AppStrings.featuredTitle1,
      date: AppStrings.featuredDate1,
    ),
    (
      image: AppAssets.alaune2,
      title: AppStrings.featuredTitle2,
      date: AppStrings.featuredDate2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final apiArticles = widget.articles ?? [];
    final useApi = apiArticles.isNotEmpty;
    final count = useApi ? apiArticles.length : _items.length;

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
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: count,
            itemBuilder: (context, index) {
              if (useApi) {
                final article = apiArticles[index];
                final imagePath = article.firstImageUrl ?? AppAssets.news1;
                final date = Article.formatDisplayDate(article.articleDate);
                final tag = article.categories.isNotEmpty
                    ? article.categories.first.name
                    : AppStrings.news;
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
              }
              final item = _items[index];
              final article = SelectedArticle(
                title: item.title,
                date: item.date,
                imagePath: item.image,
              );
              final heroTag = ArticleDetailArgs.heroTagFor(
                imagePath: item.image,
                title: item.title,
                date: item.date,
                sourceId: 'featured',
                index: index,
              );
              return _FeaturedCard(
                imagePath: item.image,
                title: item.title,
                date: item.date,
                heroTag: heroTag,
                isStarSelected:
                    widget.selectionService?.contains(article) ?? false,
                onStarTap: widget.selectionService != null
                    ? () => widget.selectionService!.toggle(article)
                    : null,
                onTap: widget.onArticleTap != null
                    ? () => widget.onArticleTap!(
                        ArticleDetailArgs(
                          title: item.title,
                          date: item.date,
                          tag: AppStrings.news,
                          body: AppStrings.articleBodySample,
                          imagePath: item.image,
                          isVideo: false,
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

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.imagePath,
    required this.title,
    required this.date,
    required this.heroTag,
    this.isStarSelected = false,
    this.onStarTap,
    this.onTap,
  });

  final String imagePath;
  final String title;
  final String date;
  final Object heroTag;
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
                        size: 18,
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
