import 'package:flutter/material.dart';
import 'package:sem_dsn/core/constants/app_border_radius.dart';
import 'package:sem_dsn/core/constants/app_font_sizes.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/core/animation/selection_star_animation.dart';
import 'package:sem_dsn/services/selection_service.dart';
import 'package:sem_dsn/widget/article_detail_args.dart';
import 'package:sem_dsn/widget/press_articles_section.dart';

/// Nombre max d’articles affichés dans "Autres Actualités" (les N derniers de la liste presse).
const int kOtherNewsMaxCount = 10;

/// Derniers articles de la section articles de presse, pour "Autres Actualités".
List<({String image, String title, String date})> get otherNewsItems {
  final list = PressArticlesSection.pressArticles;
  if (list.length <= kOtherNewsMaxCount) return list;
  return list.sublist(list.length - kOtherNewsMaxCount);
}

/// Section "Autres Actualités" en bas de la page détail (slivers à insérer dans un CustomScrollView).
/// Même contenu que les articles de presse, limité aux 10 derniers. Titre "Autres Actualités".
/// Chaque tuile a la sélection (étoile) comme en section presse.
List<Widget> buildOtherNewsSlivers({
  SelectionService? selectionService,
  void Function(ArticleDetailArgs args)? onArticleTap,
}) {
  final items = otherNewsItems;
  return [
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
          items.asMap().entries.map((entry) {
            final index = entry.key;
            final e = entry.value;
            final heroTag = ArticleDetailArgs.heroTagFor(
              imagePath: e.image,
              title: e.title,
              date: e.date,
              sourceId: 'other_news',
              index: index,
            );
            return OtherNewsTile(
              imagePath: e.image,
              title: e.title,
              date: e.date,
              heroTag: heroTag,
              selectionService: selectionService,
              onTap: onArticleTap != null
                  ? () => onArticleTap(ArticleDetailArgs(
                        title: e.title,
                        date: e.date,
                        tag: AppStrings.news,
                        body: AppStrings.articleBodySample,
                        imagePath: e.image,
                        isVideo: false,
                        isHeroOrFeatured: false,
                        heroTagOverride: heroTag,
                      ))
                  : null,
            );
          }).toList(),
        ),
      ),
    ),
    const SliverToBoxAdapter(child: SizedBox(height: 100)),
  ];
}

/// Tuile d’un article dans la liste "Autres Actualités" (même style que presse + sélection étoile).
class OtherNewsTile extends StatefulWidget {
  const OtherNewsTile({
    super.key,
    required this.imagePath,
    required this.title,
    required this.date,
    required this.heroTag,
    this.selectionService,
    this.onTap,
  });

  final String imagePath;
  final String title;
  final String date;
  final Object heroTag;
  final SelectionService? selectionService;
  final VoidCallback? onTap;

  @override
  State<OtherNewsTile> createState() => _OtherNewsTileState();
}

class _OtherNewsTileState extends State<OtherNewsTile> {
  @override
  void initState() {
    super.initState();
    widget.selectionService?.addListener(_onSelectionChanged);
  }

  @override
  void didUpdateWidget(covariant OtherNewsTile oldWidget) {
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
    final article = SelectedArticle(
      title: widget.title,
      date: widget.date,
      imagePath: widget.imagePath,
    );
    final isStarSelected = widget.selectionService?.contains(article) ?? false;
    final onStarTap = widget.selectionService != null
        ? () => widget.selectionService!.toggle(article)
        : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: AppBorderRadius.r10,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Hero(
                tag: widget.heroTag,
                child: ClipRRect(
                  borderRadius: AppBorderRadius.r10,
                  child: Image.asset(
                    widget.imagePath,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
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
                          widget.date,
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
                              onTap: onStarTap,
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
