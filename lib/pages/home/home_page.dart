import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sem_dsn/core/constants/app_font_sizes.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/constants/category_display_layout.dart';
import 'package:sem_dsn/core/constants/live_config.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/pages/article_detail/article_detail_page.dart';
import 'package:sem_dsn/models/article.dart';
import 'package:sem_dsn/providers/articles_provider.dart';
import 'package:sem_dsn/providers/categories_provider.dart';
import 'package:sem_dsn/providers/press_articles_cache_provider.dart';
import 'package:sem_dsn/pages/live/live_fullscreen_page.dart';
import 'package:sem_dsn/pages/selection/selection_page_content.dart';
import 'package:sem_dsn/pages/phototheque/phototheque_page.dart';
import 'package:sem_dsn/pages/phototheque/phototheque_search_page.dart';
import 'package:sem_dsn/pages/bibliographie/bibliographie_page.dart';
import 'package:sem_dsn/pages/bibliographie/bibliographie_search_page.dart';
import 'package:sem_dsn/pages/notifications/notifications_page.dart';
import 'package:sem_dsn/pages/search/article_search_page.dart';
import 'package:sem_dsn/services/selection_service.dart';
import 'package:sem_dsn/widget/app_bottom_nav_bar.dart';
import 'package:sem_dsn/widget/app_header.dart';
import 'package:sem_dsn/widget/article_video_player.dart';
import 'package:sem_dsn/widget/featured_section.dart';
import 'package:sem_dsn/widget/home_filter_content.dart';
import 'package:sem_dsn/widget/home_filter_section.dart';
import 'package:sem_dsn/widget/home_hero_section.dart';
import 'package:sem_dsn/widget/press_articles_section.dart';
import 'package:sem_dsn/widget/youtube_fullscreen_page.dart';

/// Retourne les [n] derniers articles par date (article_date décroissant).
List<Article> _lastNArticlesByDate(List<Article> articles, int n) {
  if (articles.isEmpty || n <= 0) return [];
  final sorted = List<Article>.from(articles)
    ..sort((a, b) {
      try {
        final da = DateTime.parse(a.articleDate);
        final db = DateTime.parse(b.articleDate);
        return db.compareTo(da);
      } catch (_) {
        return b.articleDate.compareTo(a.articleDate);
      }
    });
  return sorted.take(n).toList();
}

/// Page d'accueil : header, filtres, contenu selon filtre (layout overlay / with_children ou listes par slug), bottom nav.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedFilterIndex = 0;
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CategoriesProvider>().loadIfNeeded();
      context.read<ArticlesProvider>().loadIfNeeded();
    });
  }

  void _openArticle(ArticleDetailArgs args) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ArticleDetailPage(args: args)),
    );
  }

  void _onLivePressed() {
    if (LiveConfig.isLiveInProgress && LiveConfig.liveStreamUrl.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) =>
              LiveFullscreenPage(streamUrl: LiveConfig.liveStreamUrl),
        ),
      );
    } else if (LiveConfig.recapVideoUrl.isNotEmpty) {
      final videoId = getYoutubeVideoId(LiveConfig.recapVideoUrl);
      if (videoId != null) {
        final startAt = getYoutubeStartSeconds(LiveConfig.recapVideoUrl) ?? 0;
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            fullscreenDialog: true,
            builder: (_) => YoutubeFullscreenPage(
              videoId: videoId,
              startAtSeconds: startAt,
              isRecap: true,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectionService = context.watch<SelectionService>();
    final categoriesProvider = context.watch<CategoriesProvider>();
    final articlesProvider = context.watch<ArticlesProvider>();
    final parentCategories = categoriesProvider.parentCategories;
    final selectedIndex = parentCategories.isEmpty
        ? 0
        : _selectedFilterIndex.clamp(0, parentCategories.length - 1);
    if (selectedIndex != _selectedFilterIndex && parentCategories.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedFilterIndex = selectedIndex);
      });
    }
    final articles = articlesProvider.articles;
    // Hero = toujours les 5 derniers articles toutes catégories (tri par date décroissante).
    final heroArticles = _lastNArticlesByDate(articles, 5);

    final hasChildren =
        parentCategories.isNotEmpty &&
        selectedIndex < parentCategories.length &&
        parentCategories[selectedIndex].hasChildren;

    // Layout dérivé : 1 enfant → overlay, 2+ → with_children (plus tard piloté par l’API).
    CategoryDisplayLayout? contentLayout;
    List<Article> featuredArticles = [];
    List<Article> pressArticles = [];
    List<Article> overlayChildArticles = [];
    String? featuredSectionTitle;
    String? pressSectionTitle;
    if (hasChildren) {
      final cat = parentCategories[selectedIndex];
      contentLayout = getDisplayLayoutForCategory(cat);
      if (contentLayout == CategoryDisplayLayout.withChildren) {
        final firstId = cat.children.first.id;
        final restIds = cat.children.length > 1
            ? cat.children.sublist(1).map((c) => c.id).toSet()
            : <int>{};
        featuredSectionTitle = cat.children.first.name;
        pressSectionTitle = cat.children.length > 1
            ? cat.children[1].name
            : null;
        featuredArticles = articles
            .where((a) => a.categories.any((c) => c.id == firstId))
            .toList();
        pressArticles = articles
            .where((a) => a.categories.any((c) => restIds.contains(c.id)))
            .toList();
      } else if (contentLayout == CategoryDisplayLayout.overlay &&
          cat.children.length == 1) {
        final childId = cat.children.first.id;
        overlayChildArticles = articles
            .where((a) => a.categories.any((c) => c.id == childId))
            .toList();
      }
    }

    // Mettre en cache les articles de presse pour "Autres Actualités" (page détail).
    final useWithChildren =
        hasChildren && contentLayout == CategoryDisplayLayout.withChildren;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PressArticlesCacheProvider>().setPressArticles(
        useWithChildren ? pressArticles : [],
      );
    });

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppHeader(
        onLivePressed: _onLivePressed,
        onNotificationsPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const NotificationsPage()),
          );
        },
        onSearchPressed: () {
          if (_selectedNavIndex == 1) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PhotothequeSearchPage(),
              ),
            );
          } else if (_selectedNavIndex == 2) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const BibliographieSearchPage(),
              ),
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ArticleSearchPage(),
              ),
            );
          }
        },
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedNavIndex,
          children: [
            RefreshIndicator(
              onRefresh: () async {
                final cat = context.read<CategoriesProvider>();
                final art = context.read<ArticlesProvider>();
                await Future.wait([cat.load(), art.load()]);
                if (mounted) setState(() {});
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 4)),
                  SliverToBoxAdapter(
                    child: HomeHeroSection(
                      articles: heroArticles.isNotEmpty ? heroArticles : null,
                      selectionService: selectionService,
                      onCardTap: (args) => _openArticle(args),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StickyFilterDelegate(
                      child: HomeFilterSection(
                        parentCategories: parentCategories,
                        loading: categoriesProvider.loading,
                        selectedIndex: selectedIndex,
                        onSelected: (index) =>
                            setState(() => _selectedFilterIndex = index),
                        onRetry: () => categoriesProvider.load(),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position:
                                      Tween<Offset>(
                                        begin: const Offset(0, 0.03),
                                        end: Offset.zero,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOut,
                                        ),
                                      ),
                                  child: child,
                                ),
                              );
                            },
                        child: hasChildren
                            ? contentLayout ==
                                      CategoryDisplayLayout.withChildren
                                  ? Column(
                                      key: const ValueKey<String>(
                                        'with_children',
                                      ),
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        FeaturedSection(
                                          articles: featuredArticles.isNotEmpty
                                              ? featuredArticles
                                              : null,
                                          sectionTitle: featuredSectionTitle,
                                          selectionService: selectionService,
                                          onArticleTap: (args) =>
                                              _openArticle(args),
                                        ),
                                        const SizedBox(height: 24),
                                        PressArticlesSection(
                                          articles: pressArticles.isNotEmpty
                                              ? pressArticles
                                              : null,
                                          sectionTitle: pressSectionTitle,
                                          selectionService: selectionService,
                                          onArticleTap: (args) =>
                                              _openArticle(args),
                                        ),
                                      ],
                                    )
                                  : overlayChildArticles.isEmpty
                                  ? Padding(
                                      key: const ValueKey<String>(
                                        'overlay_empty',
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 32,
                                      ),
                                      child: Center(
                                        child: Text(
                                          AppStrings.noArticlesYet,
                                          style: TextStyle(
                                            fontSize: AppFontSizes.sectionTitle,
                                            color: AppColors.primaryColor,
                                          ),
                                        ),
                                      ),
                                    )
                                  : OverlayCardListFromArticles(
                                      key: const ValueKey<String>('overlay'),
                                      articles: overlayChildArticles,
                                      tag: parentCategories[selectedIndex]
                                          .children
                                          .first
                                          .name,
                                      selectionService: selectionService,
                                      onArticleTap: _openArticle,
                                    )
                            : HomeFilterContent(
                                key: ValueKey<int>(selectedIndex),
                                parentCategories: parentCategories,
                                articles: articlesProvider.articles,
                                selectedIndex: selectedIndex,
                                selectionService: selectionService,
                                onArticleTap: _openArticle,
                              ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
            RefreshIndicator(
              onRefresh: () async => setState(() {}),
              child: const PhotothequePage(),
            ),
            RefreshIndicator(
              onRefresh: () async => setState(() {}),
              child: const BibliographiePage(),
            ),
            SelectionPageContent(
              key: ValueKey('selection_${selectionService.items.length}'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _selectedNavIndex,
        onTap: (index) => setState(() => _selectedNavIndex = index),
      ),
    );
  }
}

/// Délégué pour que la barre de filtres reste sticky quand le hero a défilé.
class _StickyFilterDelegate extends SliverPersistentHeaderDelegate {
  _StickyFilterDelegate({required this.child});

  final Widget child;

  static const double _filterHeight = 40;
  static const double _bottomGap = 10;
  static const double _height = _filterHeight + _bottomGap;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      height: _height,
      color: AppColors.bg,
      padding: const EdgeInsets.only(bottom: _bottomGap),
      child: child,
    );
  }

  @override
  double get maxExtent => _height;

  @override
  double get minExtent => _height;

  @override
  bool shouldRebuild(covariant _StickyFilterDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}
