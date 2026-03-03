import 'package:flutter/material.dart';
import 'package:sem_dsn/core/constants/app_border_radius.dart';
import 'package:sem_dsn/core/constants/app_font_sizes.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/services/selection_service.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/core/animation/selection_star_animation.dart';
import 'package:sem_dsn/pages/article_detail/article_detail_page.dart';

/// Contenu de l’onglet Sélection : titre, sous-titre "Articles de presse", liste des articles
/// avec étoile remplie à droite de la date ; clic sur l’étoile retire de la sélection.
class SelectionPageContent extends StatefulWidget {
  const SelectionPageContent({super.key});

  @override
  State<SelectionPageContent> createState() => _SelectionPageContentState();
}

class _SelectionPageContentState extends State<SelectionPageContent> {
  final SelectionService _selection = SelectionService.instance;

  @override
  void initState() {
    super.initState();
    _selection.addListener(_onSelectionChanged);
  }

  @override
  void dispose() {
    _selection.removeListener(_onSelectionChanged);
    super.dispose();
  }

  void _onSelectionChanged() => setState(() {});

  void _openArticle(SelectedArticle article) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ArticleDetailPage(
          args: ArticleDetailArgs(
            title: article.title,
            date: article.date,
            tag: AppStrings.news,
            body: AppStrings.articleBodySample,
            imagePath: article.imagePath,
            isVideo: false,
            isHeroOrFeatured: false,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _selection.items;
    return CustomScrollView(
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
                style: TextStyle(color: AppColors.grayTextColor, fontSize: 15),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final article = items[index];
              return _SelectionArticleTile(
                article: article,
                onTap: () => _openArticle(article),
                onRemoveFromSelection: () => _selection.remove(article),
              );
            }, childCount: items.length),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _SelectionArticleTile extends StatelessWidget {
  const _SelectionArticleTile({
    required this.article,
    required this.onTap,
    required this.onRemoveFromSelection,
  });

  final SelectedArticle article;
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
                ClipRRect(
                  borderRadius: AppBorderRadius.r10,
                  child: Image.asset(
                    article.imagePath,
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
