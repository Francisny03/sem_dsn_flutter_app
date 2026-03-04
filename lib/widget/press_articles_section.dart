import 'package:flutter/material.dart';
import 'package:sem_dsn/core/constants/app_assets.dart';
import 'package:sem_dsn/core/constants/app_border_radius.dart';
import 'package:sem_dsn/core/constants/app_font_sizes.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/core/animation/selection_star_animation.dart';
import 'package:sem_dsn/services/selection_service.dart';
import 'package:sem_dsn/widget/article_detail_args.dart';

/// Section "Press Articles" : liste verticale d'articles (image + titre + date + favori).
class PressArticlesSection extends StatelessWidget {
  const PressArticlesSection({
    super.key,
    this.selectionService,
    this.onArticleTap,
  });

  final SelectionService? selectionService;
  final void Function(ArticleDetailArgs args)? onArticleTap;

  /// Liste des articles de presse (partagée avec "Autres Actualités").
  static const List<({String image, String title, String date})>
  pressArticles = [
    (
      image: AppAssets.news1,
      title:
          'Le président Denis Sassou-Nguesso a été reçu jeudi à Beijing en Chine',
      date: '04 Septembre 2025',
    ),
    (
      image: AppAssets.news2,
      title: 'Chine : Denis Sassou-Nguesso reçu par Vladimir Poutine à Pékin',
      date: '04 Septembre 2025',
    ),
    (
      image: AppAssets.news3,
      title:
          'France - Congo : Macron reçoit Denis Sassou N\'Guesso à l\'Élysée',
      date: '04 Septembre 2025',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppStrings.sectionTitlePressArticles,
            style: TextStyle(
              color: AppColors.sectionTitle,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: pressArticles.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final article = pressArticles[index];
            final selectedArticle = SelectedArticle(
              title: article.title,
              date: article.date,
              imagePath: article.image,
            );
            final heroTag = ArticleDetailArgs.heroTagFor(
              imagePath: article.image,
              title: article.title,
              date: article.date,
              sourceId: 'press',
              index: index,
            );
            return _PressArticleTile(
              imagePath: article.image,
              title: article.title,
              date: article.date,
              heroTag: heroTag,
              isStarSelected:
                  selectionService?.contains(selectedArticle) ?? false,
              onStarTap: selectionService != null
                  ? () => selectionService!.toggle(selectedArticle)
                  : null,
              onTap: onArticleTap != null
                  ? () => onArticleTap!(
                        ArticleDetailArgs(
                          title: article.title,
                          date: article.date,
                          tag: AppStrings.news,
                          body: AppStrings.articleBodySample,
                          imagePath: article.image,
                          isVideo: false,
                          isHeroOrFeatured: false,
                          heroTagOverride: heroTag,
                        ),
                      )
                  : null,
            );
          },
        ),
      ],
    );
  }
}

class _PressArticleTile extends StatelessWidget {
  const _PressArticleTile({
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorderRadius.r10,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: heroTag,
                child: ClipRRect(
                  borderRadius: AppBorderRadius.r10,
                  child: Image.asset(
                    imagePath,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 90,
                      height: 90,
                      color: AppColors.filterUnselected,
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.newsTitle,
                        fontSize: AppFontSizes.pressArticleTitle,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          date,
                          style: const TextStyle(
                            color: AppColors.newsDate,
                            fontSize: AppFontSizes.pressArticleDate,
                          ),
                        ),
                        if (onStarTap != null)
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: AnimatedSelectionStar(
                              isSelected: isStarSelected,
                              onTap: onStarTap!,
                              selectedColor: AppColors.heroSelectionTag,
                              unselectedColor: AppColors.grayTextColor,
                              size: 24,
                            ),
                          ),
                      ],
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
