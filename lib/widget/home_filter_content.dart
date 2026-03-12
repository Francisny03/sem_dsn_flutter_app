import 'package:flutter/material.dart';
import 'package:sem_dsn/core/constants/app_assets.dart';
import 'package:sem_dsn/core/constants/discours_data.dart';
import 'package:sem_dsn/models/article.dart';
import 'package:sem_dsn/models/category.dart';
import 'package:sem_dsn/pages/article_detail/article_detail_page.dart';
import 'package:sem_dsn/pages/discours/discours_subcategory_page.dart';
import 'package:sem_dsn/widget/article_detail_args.dart';
import 'package:sem_dsn/widget/card_discours_subcategory.dart';
import 'package:sem_dsn/widget/card_image_below.dart';
import 'package:sem_dsn/widget/card_overlay.dart';
import 'package:sem_dsn/services/selection_service.dart';

/// Retourne true si l’article appartient à la catégorie (ou à un de ses enfants).
bool _articleBelongsToCategory(Article article, Category category) {
  final categoryIds = {category.id, ...category.children.map((c) => c.id)};
  return article.categories.any((c) => categoryIds.contains(c.id));
}

/// Contenu affiché selon la catégorie sélectionnée (parent sans enfants : overlay, image below, ou grille Discours). Tag = [Category.name].
/// Si [articles] est fourni, les listes utilisent les articles API filtrés par catégorie ; sinon données statiques ou vide.
class HomeFilterContent extends StatelessWidget {
  const HomeFilterContent({
    super.key,
    required this.parentCategories,
    this.articles = const [],
    required this.selectedIndex,
    this.selectionService,
    this.onArticleTap,
  });

  final List<Category> parentCategories;
  final List<Article> articles;
  final int selectedIndex;
  final SelectionService? selectionService;
  final void Function(ArticleDetailArgs args)? onArticleTap;

  @override
  Widget build(BuildContext context) {
    if (parentCategories.isEmpty ||
        selectedIndex < 0 ||
        selectedIndex >= parentCategories.length) {
      return const SizedBox.shrink();
    }
    final category = parentCategories[selectedIndex];
    final tag = category.name;
    final filteredArticles = articles
        .where((a) => _articleBelongsToCategory(a, category))
        .toList();

    if (category.slug == 'discours') {
      return _DiscoursGridContent(
        category: category,
        onArticleTap: onArticleTap,
      );
    }
    if (category.slug == 'r-alisations' || category.slug == 'realisations') {
      if (filteredArticles.isEmpty) {
        return const _EmptyCategoryMessage();
      }
      return _ImageBelowCardListFromArticles(
        articles: filteredArticles,
        tag: tag,
        showDate: true,
        selectionService: selectionService,
        onArticleTap: onArticleTap,
      );
    }
    if (category.slug == 'economie') {
      if (filteredArticles.isEmpty) {
        return const _EmptyCategoryMessage();
      }
      return _ImageBelowCardListFromArticles(
        articles: filteredArticles,
        tag: tag,
        showDate: false,
        selectionService: selectionService,
        onArticleTap: onArticleTap,
      );
    }
    if (filteredArticles.isEmpty) {
      return const _EmptyCategoryMessage();
    }
    return OverlayCardListFromArticles(
      articles: filteredArticles,
      tag: tag,
      selectionService: selectionService,
      onArticleTap: onArticleTap,
    );
  }
}

/// Message affiché quand la catégorie n’a pas encore de contenu.
class _EmptyCategoryMessage extends StatelessWidget {
  const _EmptyCategoryMessage();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

// ——— Grille Discours (sous-catégories type Photothèque) ———

class _DiscoursGridContent extends StatelessWidget {
  const _DiscoursGridContent({required this.category, this.onArticleTap});

  final Category category;
  final void Function(ArticleDetailArgs args)? onArticleTap;

  @override
  Widget build(BuildContext context) {
    if (category.children.isEmpty) {
      return const _EmptyCategoryMessage();
    }
    final children = category.children;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) {
          final sub = children[index];
          return CardDiscoursSubcategory(
            imagePath: AppAssets.news1,
            title: sub.name,
            count: 0,
            onTap: () {
              if (onArticleTap == null) return;
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => DiscoursSubcategoryPage(
                    subcategoryTitle: sub.name,
                    items: const <DiscoursOverlayItem>[],
                    onArticleTap: onArticleTap!,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

String _formatArticleDate(String iso) {
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

// ——— Liste de cartes overlay à partir d’articles API ———

/// Liste de cartes overlay (réutilisable depuis HomePage pour 1 enfant = overlay).
class OverlayCardListFromArticles extends StatelessWidget {
  const OverlayCardListFromArticles({
    super.key,
    required this.articles,
    required this.tag,
    this.selectionService,
    this.onArticleTap,
  });

  final List<Article> articles;
  final String tag;
  final SelectionService? selectionService;
  final void Function(ArticleDetailArgs args)? onArticleTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: articles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final article = articles[index];
        final imagePath = AppAssets.imageOrDefault(article.firstImageUrl);
        final date = _formatArticleDate(article.articleDate);
        final selectedArticle = SelectedArticle(
          title: article.title,
          date: date,
          imagePath: imagePath,
        );
        final heroTag = ArticleDetailArgs.heroTagFor(
          imagePath: imagePath,
          title: article.title,
          date: date,
          sourceId: tag,
          index: index,
        );
        return CardOverlay(
          imagePath: imagePath,
          title: article.title,
          date: date,
          showPlayButton: article.hasVideo,
          heroTag: heroTag,
          isStarSelected: selectionService?.contains(selectedArticle) ?? false,
          onStarTap: selectionService != null
              ? () => selectionService!.toggle(selectedArticle)
              : null,
          onTap: onArticleTap != null
              ? () => onArticleTap!(
                  ArticleDetailArgs.fromArticle(
                    article,
                    tag,
                    heroTagOverride: heroTag,
                  ),
                )
              : null,
        );
      },
    );
  }
}

/// Sliver : liste de cartes overlay + loader en bas si [hasMore] ou [loadingMore].
class SliverOverlayCardListFromArticles extends StatelessWidget {
  const SliverOverlayCardListFromArticles({
    super.key,
    required this.articles,
    required this.tag,
    this.hasMore = false,
    this.loadingMore = false,
    this.selectionService,
    this.onArticleTap,
  });

  final List<Article> articles;
  final String tag;
  final bool hasMore;
  final bool loadingMore;
  final SelectionService? selectionService;
  final void Function(ArticleDetailArgs args)? onArticleTap;

  @override
  Widget build(BuildContext context) {
    final showLoader = hasMore || loadingMore;
    final itemCount = articles.length + (showLoader ? 1 : 0);
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index >= articles.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final article = articles[index];
          final imagePath = AppAssets.imageOrDefault(article.firstImageUrl);
          final date = _formatArticleDate(article.articleDate);
          final selectedArticle = SelectedArticle(
            title: article.title,
            date: date,
            imagePath: imagePath,
          );
          final heroTag = ArticleDetailArgs.heroTagFor(
            imagePath: imagePath,
            title: article.title,
            date: date,
            sourceId: tag,
            index: index,
          );
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CardOverlay(
              imagePath: imagePath,
              title: article.title,
              date: date,
              showPlayButton: article.hasVideo,
              heroTag: heroTag,
              isStarSelected:
                  selectionService?.contains(selectedArticle) ?? false,
              onStarTap: selectionService != null
                  ? () => selectionService!.toggle(selectedArticle)
                  : null,
              onTap: onArticleTap != null
                  ? () => onArticleTap!(
                      ArticleDetailArgs.fromArticle(
                        article,
                        tag,
                        heroTagOverride: heroTag,
                      ),
                    )
                  : null,
            ),
          );
        }, childCount: itemCount),
      ),
    );
  }
}

// ——— Liste image + texte à partir d’articles API ———

class _ImageBelowCardListFromArticles extends StatelessWidget {
  const _ImageBelowCardListFromArticles({
    required this.articles,
    required this.tag,
    this.showDate = true,
    this.selectionService,
    this.onArticleTap,
  });

  final List<Article> articles;
  final String tag;
  final bool showDate;
  final SelectionService? selectionService;
  final void Function(ArticleDetailArgs args)? onArticleTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: articles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final article = articles[index];
        final imagePath = AppAssets.imageOrDefault(article.firstImageUrl);
        final date = _formatArticleDate(article.articleDate);
        final selectedArticle = SelectedArticle(
          title: article.title,
          date: date,
          imagePath: imagePath,
        );
        final heroTag = ArticleDetailArgs.heroTagFor(
          imagePath: imagePath,
          title: article.title,
          date: date,
          sourceId: tag,
          index: index,
        );
        return CardImageBelow(
          imagePath: imagePath,
          title: article.title,
          date: showDate ? date : null,
          showPlayButton: article.hasVideo,
          heroTag: heroTag,
          isStarSelected: selectionService?.contains(selectedArticle) ?? false,
          onStarTap: selectionService != null
              ? () => selectionService!.toggle(selectedArticle)
              : null,
          onTap: onArticleTap != null
              ? () => onArticleTap!(
                  ArticleDetailArgs.fromArticle(
                    article,
                    tag,
                    heroTagOverride: heroTag,
                  ),
                )
              : null,
        );
      },
    );
  }
}

/// Sliver : liste image below + loader en bas si [hasMore] ou [loadingMore].
class SliverImageBelowCardListFromArticles extends StatelessWidget {
  const SliverImageBelowCardListFromArticles({
    super.key,
    required this.articles,
    required this.tag,
    this.showDate = true,
    this.hasMore = false,
    this.loadingMore = false,
    this.selectionService,
    this.onArticleTap,
  });

  final List<Article> articles;
  final String tag;
  final bool showDate;
  final bool hasMore;
  final bool loadingMore;
  final SelectionService? selectionService;
  final void Function(ArticleDetailArgs args)? onArticleTap;

  @override
  Widget build(BuildContext context) {
    final showLoader = hasMore || loadingMore;
    final itemCount = articles.length + (showLoader ? 1 : 0);
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index >= articles.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final article = articles[index];
          final imagePath = AppAssets.imageOrDefault(article.firstImageUrl);
          final date = _formatArticleDate(article.articleDate);
          final selectedArticle = SelectedArticle(
            title: article.title,
            date: date,
            imagePath: imagePath,
          );
          final heroTag = ArticleDetailArgs.heroTagFor(
            imagePath: imagePath,
            title: article.title,
            date: date,
            sourceId: tag,
            index: index,
          );
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CardImageBelow(
              imagePath: imagePath,
              title: article.title,
              date: showDate ? date : null,
              showPlayButton: article.hasVideo,
              heroTag: heroTag,
              isStarSelected:
                  selectionService?.contains(selectedArticle) ?? false,
              onStarTap: selectionService != null
                  ? () => selectionService!.toggle(selectedArticle)
                  : null,
              onTap: onArticleTap != null
                  ? () => onArticleTap!(
                      ArticleDetailArgs.fromArticle(
                        article,
                        tag,
                        heroTagOverride: heroTag,
                      ),
                    )
                  : null,
            ),
          );
        }, childCount: itemCount),
      ),
    );
  }
}
