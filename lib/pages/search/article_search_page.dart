import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sem_dsn/core/constants/app_assets.dart';
import 'package:sem_dsn/core/constants/app_border_radius.dart';
import 'package:sem_dsn/core/constants/app_font_sizes.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/core/animation/selection_star_animation.dart';
import 'package:sem_dsn/models/article.dart';
import 'package:sem_dsn/pages/article_detail/article_detail_page.dart';
import 'package:sem_dsn/providers/articles_provider.dart';
import 'package:sem_dsn/services/selection_service.dart';
import 'package:sem_dsn/widget/image_from_path.dart';

/// Page de recherche d’articles : input en haut ; résultats et "Articles récents" issus de l’API.
/// Filtrage par titre, sous-titre, description (sans HTML), date.
class ArticleSearchPage extends StatefulWidget {
  const ArticleSearchPage({super.key});

  @override
  State<ArticleSearchPage> createState() => _ArticleSearchPageState();
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

String _stripHtml(String html) {
  return html
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String _articleSearchableText(Article a) {
  final date = _formatArticleDate(a.articleDate);
  final desc = _stripHtml(a.description);
  return '${a.title} ${a.subtitle ?? ''} $desc $date'.toLowerCase();
}

class _ArticleSearchPageState extends State<ArticleSearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ArticlesProvider>().loadIfNeeded();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openArticle(Article article) {
    final tag = article.categories.isNotEmpty
        ? article.categories.first.name
        : 'Recherche';
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ArticleDetailPage(
          args: ArticleDetailArgs.fromArticle(article, tag),
        ),
      ),
    );
  }

  Widget _buildTile(
    Article article,
    int index,
    String sourceId,
    SelectionService selectionService,
  ) {
    final imagePath = article.firstImageUrl ?? AppAssets.news1;
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
      sourceId: sourceId,
      index: index,
    );
    return _ArticleSearchTile(
      imagePath: imagePath,
      title: article.title,
      date: date,
      heroTag: heroTag,
      isStarSelected: selectionService.contains(selectedArticle),
      onStarTap: () => selectionService.toggle(selectedArticle),
      onTap: () => _openArticle(article),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectionService = context.watch<SelectionService>();
    final articles = context.watch<ArticlesProvider>().articles;
    final query = _searchController.text.trim().toLowerCase();
    final hasQuery = query.isNotEmpty;
    final results = hasQuery
        ? articles
              .where((a) => _articleSearchableText(a).contains(query))
              .toList()
        : <Article>[];

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
          color: AppColors.blackIcon,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppStrings.articleSearchTitle,
          style: const TextStyle(
            color: AppColors.onSurfaceLight,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: AppStrings.articleSearchHint,
                hintStyle: const TextStyle(
                  color: AppColors.grayTextColor,
                  fontSize: 15,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.grayTextColor,
                  size: 22,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        color: AppColors.grayTextColor,
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.filterUnselected,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                if (hasQuery) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      AppStrings.articleSearchResults,
                      style: const TextStyle(
                        color: AppColors.sectionTitle,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      results.isEmpty
                          ? AppStrings.articleSearchNoResults
                          : '${results.length} ${AppStrings.articleSearchResultsCount}',
                      style: const TextStyle(
                        color: AppColors.grayTextColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...results.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: _buildTile(
                        e.value,
                        e.key,
                        'search_results',
                        selectionService,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    AppStrings.articleSearchRecents,
                    style: const TextStyle(
                      color: AppColors.sectionTitle,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...articles.asMap().entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _buildTile(
                      e.value,
                      e.key,
                      'search_recents',
                      selectionService,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleSearchTile extends StatelessWidget {
  const _ArticleSearchTile({
    required this.imagePath,
    required this.title,
    required this.date,
    required this.heroTag,
    required this.isStarSelected,
    required this.onStarTap,
    required this.onTap,
  });

  final String imagePath;
  final String title;
  final String date;
  final Object heroTag;
  final bool isStarSelected;
  final VoidCallback onStarTap;
  final VoidCallback onTap;

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
                      title,
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
                          date,
                          style: const TextStyle(
                            color: AppColors.newsDate,
                            fontSize: AppFontSizes.pressArticleDate,
                          ),
                        ),
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
