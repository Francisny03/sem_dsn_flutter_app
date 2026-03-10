import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sem_dsn/core/constants/app_border_radius.dart';
import 'package:sem_dsn/core/constants/app_font_sizes.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/services/selection_service.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/core/animation/selection_star_animation.dart';
import 'package:sem_dsn/pages/article_detail/article_detail_page.dart';
import 'package:sem_dsn/core/constants/app_assets.dart';
import 'package:sem_dsn/widget/image_from_path.dart';

/// Contenu de l’onglet Sélection : titre, sous-titre "Articles de presse", liste des articles
/// avec étoile remplie à droite de la date ; clic sur l’étoile retire de la sélection.
class SelectionPageContent extends StatefulWidget {
  const SelectionPageContent({super.key});

  @override
  State<SelectionPageContent> createState() => _SelectionPageContentState();
}

class _SelectionPageContentState extends State<SelectionPageContent> {
  void _openArticle(SelectedArticle article, Object heroTag) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ArticleDetailPage(
          args: ArticleDetailArgs(
            title: article.title,
            date: article.date,
            tag: AppStrings.news,
            body: AppStrings.articleBodySample,
            imagePath: AppAssets.imageOrDefault(article.imagePath),
            isVideo: false,
            isHeroOrFeatured: false,
            heroTagOverride: heroTag,
          ),
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final selection = context.watch<SelectionService>();
    final items = selection.items;
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 4)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.navSelection,
                    style: const TextStyle(
                      color: AppColors.navBottomSelectItem,
                      fontSize: AppFontSizes.menuTitle,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  // const SizedBox(height: 4),
                  // Text(
                  //   AppStrings.sectionTitlePressArticles,
                  //   style: const TextStyle(
                  //     color: AppColors.sectionTitle,
                  //     fontSize: 16,
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          if (items.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  AppStrings.selectionEmpty,
                  style: TextStyle(
                    color: AppColors.grayTextColor,
                    fontSize: 15,
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final article = items[index];
                final imagePath = AppAssets.imageOrDefault(article.imagePath);
                final heroTag = ArticleDetailArgs.heroTagFor(
                  imagePath: imagePath,
                  title: article.title,
                  date: article.date,
                  sourceId: 'selection',
                  index: index,
                );
                return _SelectionArticleTile(
                  article: article,
                  imagePath: imagePath,
                  heroTag: heroTag,
                  onTap: () => _openArticle(article, heroTag),
                  onRemoveFromSelection: () => selection.remove(article),
                );
              }, childCount: items.length),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _SelectionArticleTile extends StatelessWidget {
  const _SelectionArticleTile({
    required this.article,
    required this.imagePath,
    required this.heroTag,
    required this.onTap,
    required this.onRemoveFromSelection,
  });

  final SelectedArticle article;
  final String imagePath;
  final Object heroTag;
  final VoidCallback onTap;
  final VoidCallback onRemoveFromSelection;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppBorderRadius.r10,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                  tag: heroTag,
                  child: ClipRRect(
                    borderRadius: AppBorderRadius.r10,
                    child: ImageFromPath(
                      path: imagePath,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        style: const TextStyle(
                          color: AppColors.newsTitle,
                          fontSize: AppFontSizes.pressArticleTitle,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            article.date,
                            style: const TextStyle(
                              color: AppColors.newsDate,
                              fontSize: AppFontSizes.pressArticleDate,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: AnimatedSelectionStar(
                              isSelected: true,
                              onTap: onRemoveFromSelection,
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
      ),
    );
  }
}
