import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sem_dsn/core/constants/category_display_layout.dart';
import 'package:sem_dsn/providers/live_provider.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/pages/article_detail/article_detail_page.dart';
import 'package:sem_dsn/models/article.dart';
import 'package:sem_dsn/models/category.dart';
import 'package:sem_dsn/providers/articles_provider.dart';
import 'package:sem_dsn/providers/categories_provider.dart';
import 'package:sem_dsn/providers/home_articles_provider.dart';
import 'package:sem_dsn/providers/books_provider.dart';
import 'package:sem_dsn/providers/galleries_provider.dart';
import 'package:sem_dsn/providers/press_articles_cache_provider.dart';
import 'package:sem_dsn/pages/live/live_replay_player_page.dart';
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
import 'package:sem_dsn/widget/no_connection_view.dart';
import 'package:sem_dsn/widget/press_articles_section.dart';

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

/// Liste d’articles à passer à HomeFilterContent : priorité aux articles chargés par catégorie (API), sinon liste globale.
List<Article> _articlesForFilter(
  ArticlesProvider articlesProvider,
  List<Category> parentCategories,
  int selectedIndex,
  List<Article> fallbackArticles,
) {
  if (parentCategories.isEmpty ||
      selectedIndex < 0 ||
      selectedIndex >= parentCategories.length) {
    return fallbackArticles;
  }
  final cat = parentCategories[selectedIndex];
  final byCategory = articlesProvider.getArticlesForCategory(cat.id);
  return byCategory.isNotEmpty ? byCategory : fallbackArticles;
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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CategoriesProvider>().loadIfNeeded();
      context.read<ArticlesProvider>().loadIfNeeded();
      context.read<HomeArticlesProvider>().loadIfNeeded();
      context.read<LiveProvider>().loadIfNeeded();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (!position.hasPixels || !position.hasContentDimensions) return;
    final threshold = 200.0;
    if (position.pixels < position.maxScrollExtent - threshold) return;
    if (!mounted) return;
    final ap = context.read<ArticlesProvider>();
    final categoryId = _currentListCategoryId();
    if (categoryId == null) return;
    if (!ap.hasMoreForCategory(categoryId) ||
        ap.loadingMoreForCategory(categoryId)) {
      return;
    }
    ap.loadMoreArticlesForCategory(categoryId);
  }

  /// CategoryId utilisé pour la liste d'articles affichée (load more). Null si pas une liste paginée.
  int? _currentListCategoryId() {
    final categories = context.read<CategoriesProvider>().parentCategories;
    final selectedIndex = _selectedFilterIndex;
    if (categories.isEmpty ||
        selectedIndex < 0 ||
        selectedIndex >= categories.length) {
      return null;
    }
    final cat = categories[selectedIndex];
    if (cat.id == 9000) return null;
    if (cat.slug == 'discours') {
      return null; // on affiche la grille, pas la liste
    }
    if (cat.hasChildren && cat.children.length == 1) {
      return cat.children.first.id;
    }
    if (!cat.hasChildren) return cat.id;
    return null;
  }

  void _openArticle(ArticleDetailArgs args) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ArticleDetailPage(args: args)),
    );
  }

  void _onLivePressed() {
    final liveProvider = context.read<LiveProvider>();
    final isLive = liveProvider.isLiveInProgress;
    final liveUrl = liveProvider.youtubeLiveUrl;
    final recapUrl = liveProvider.recapVideoUrl;

    if (isLive && liveUrl.isNotEmpty) {
      final isHls =
          liveProvider.isHlsLive ||
          liveUrl.trim().toLowerCase().endsWith('.m3u8');
      if (isHls) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                LiveReplayPlayerPage(isLive: true, streamUrl: liveUrl),
          ),
        );
      } else {
        final videoId = getYoutubeVideoId(liveUrl);
        if (videoId != null) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  LiveReplayPlayerPage(isLive: true, videoId: videoId),
            ),
          );
        }
      }
    } else if (recapUrl.isNotEmpty) {
      final isHlsRecap = recapUrl.trim().toLowerCase().endsWith('.m3u8');
      if (isHlsRecap) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                LiveReplayPlayerPage(isLive: false, streamUrl: recapUrl),
          ),
        );
      } else {
        final videoId = getYoutubeVideoId(recapUrl);
        if (videoId != null) {
          final startAt = getYoutubeStartSeconds(recapUrl) ?? 0;
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => LiveReplayPlayerPage(
                isLive: false,
                videoId: videoId,
                startAtSeconds: startAt,
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectionService = context.watch<SelectionService>();
    final categoriesProvider = context.watch<CategoriesProvider>();
    final articlesProvider = context.watch<ArticlesProvider>();
    final homeArticlesProvider = context.watch<HomeArticlesProvider>();
    final liveProvider = context.watch<LiveProvider>();
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
    final last5 = _lastNArticlesByDate(articles, 5);
    final last4 = _lastNArticlesByDate(articles, 4);
    final isLive = liveProvider.isLiveInProgress;
    final isReplay = liveProvider.isReplay;
    final isEnded = liveProvider.isEnded;
    // Live → 1 slide live + 4 articles. Replay → replay toujours dans le hero (5 contenus max : 4 articles les plus récents + replay en dernière position).
    final hasLiveContent = isLive && !isEnded;
    final hasReplayContent = isReplay && !isEnded;
    final heroArticles = hasLiveContent
        ? last4
        : (hasReplayContent ? last4 : last5);

    // Charger les articles par catégorie pour l’onglet sélectionné (Réalisations, ou overlay 1 enfant ex. Discours).
    if (parentCategories.isNotEmpty &&
        selectedIndex < parentCategories.length) {
      final cat = parentCategories[selectedIndex];
      if (cat.id != 9000) {
        final categoryId = cat.hasChildren && cat.children.length == 1
            ? cat.children.first.id
            : cat.id;
        final alreadyLoaded = articlesProvider
            .getArticlesForCategory(categoryId)
            .isNotEmpty;
        if (!alreadyLoaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final ap = context.read<ArticlesProvider>();
            if (cat.hasChildren && cat.children.length == 1) {
              ap.loadArticlesForCategory(cat.children.first.id);
            } else if (!cat.hasChildren) {
              ap.loadArticlesForCategory(cat.id);
            }
          });
        }
      }
    }

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
        if (cat.slug == 'actualites') {
          featuredSectionTitle = 'À la une';
          pressSectionTitle = 'Autres infos';
          featuredArticles = homeArticlesProvider.aLaUne;
          pressArticles = homeArticlesProvider.contenuGeneral;
        } else {
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
        }
      } else if (contentLayout == CategoryDisplayLayout.overlay &&
          cat.children.length == 1) {
        overlayChildArticles = articlesProvider.getArticlesForCategory(
          cat.children.first.id,
        );
      }
    }

    // Mettre en cache les articles de presse pour "Autres Actualités" (page détail).
    final useWithChildren =
        hasChildren && contentLayout == CategoryDisplayLayout.withChildren;
    final isActualitesTab =
        hasChildren &&
        selectedIndex < parentCategories.length &&
        parentCategories[selectedIndex].slug == 'actualites';
    final homeSectionsLoading = isActualitesTab && homeArticlesProvider.loading;

    // Liste paginée en slivers (overlay ou image below) pour scroll fluide + load more.
    final filterArticles = _articlesForFilter(
      articlesProvider,
      parentCategories,
      selectedIndex,
      articles,
    );
    final filterCategory =
        parentCategories.isNotEmpty &&
            selectedIndex >= 0 &&
            selectedIndex < parentCategories.length
        ? parentCategories[selectedIndex]
        : null;
    final useSliverListOverlay =
        (hasChildren &&
            contentLayout == CategoryDisplayLayout.overlay &&
            overlayChildArticles.isNotEmpty) ||
        (filterCategory != null &&
            !hasChildren &&
            filterArticles.isNotEmpty &&
            filterCategory.slug != 'discours' &&
            filterCategory.slug != 'r-alisations' &&
            filterCategory.slug != 'realisations' &&
            filterCategory.slug != 'economie');
    final useSliverListImageBelow =
        filterCategory != null &&
        !hasChildren &&
        filterArticles.isNotEmpty &&
        (filterCategory.slug == 'r-alisations' ||
            filterCategory.slug == 'realisations' ||
            filterCategory.slug == 'economie');
    final listCategoryId = useSliverListOverlay
        ? (hasChildren ? filterCategory!.children.first.id : filterCategory!.id)
        : (useSliverListImageBelow ? filterCategory.id : null);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PressArticlesCacheProvider>().setPressArticles(
        useWithChildren ? pressArticles : [],
      );
    });

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppHeader(
        hasLiveContent: liveProvider.hasLiveContent,
        isLiveInProgress: liveProvider.isLiveInProgress,
        isEnded: liveProvider.isEnded,
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
                final homeArt = context.read<HomeArticlesProvider>();
                final liveProv = context.read<LiveProvider>();
                await Future.wait([
                  cat.load(),
                  art.load(),
                  homeArt.load(),
                  liveProv.load(),
                ]);
                if (mounted) {
                  final categoryId = _currentListCategoryId();
                  if (categoryId != null) {
                    await art.loadArticlesForCategory(categoryId);
                  }
                  setState(() {});
                }
              },
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 4)),
                  SliverToBoxAdapter(
                    child: HomeHeroSection(
                      articles: heroArticles.isNotEmpty ? heroArticles : null,
                      loading: articlesProvider.loading,
                      selectionService: selectionService,
                      onCardTap: (args) => _openArticle(args),
                      hasLiveContent: hasLiveContent,
                      hasReplayContent: hasReplayContent,
                      liveImageUrl: liveProvider.currentLive?.image,
                      liveTitle: liveProvider.currentLive?.title,
                      replayImageUrl: liveProvider.currentLive?.image,
                      replayTitle: liveProvider.currentLive?.title,
                      onLiveTap:
                          (hasLiveContent || hasReplayContent) && !isEnded
                          ? _onLivePressed
                          : null,
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
                  if (useSliverListOverlay || useSliverListImageBelow) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 280),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: SizedBox.shrink(
                            key: ValueKey<int>(selectedIndex),
                          ),
                        ),
                      ),
                    ),
                    if (useSliverListOverlay)
                      SliverOverlayCardListFromArticles(
                        articles: hasChildren
                            ? overlayChildArticles
                            : filterArticles,
                        tag: filterCategory!.name,
                        hasMore: listCategoryId != null
                            ? articlesProvider.hasMoreForCategory(
                                listCategoryId,
                              )
                            : false,
                        loadingMore: listCategoryId != null
                            ? articlesProvider.loadingMoreForCategory(
                                listCategoryId,
                              )
                            : false,
                        selectionService: selectionService,
                        onArticleTap: _openArticle,
                      )
                    else
                      SliverImageBelowCardListFromArticles(
                        articles: filterArticles,
                        tag: filterCategory!.name,
                        showDate: filterCategory.slug != 'economie',
                        hasMore: listCategoryId != null
                            ? articlesProvider.hasMoreForCategory(
                                listCategoryId,
                              )
                            : false,
                        loadingMore: listCategoryId != null
                            ? articlesProvider.loadingMoreForCategory(
                                listCategoryId,
                              )
                            : false,
                        selectionService: selectionService,
                        onArticleTap: _openArticle,
                      ),
                  ] else ...[
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
                                          if (isActualitesTab &&
                                              featuredArticles.isEmpty &&
                                              pressArticles.isEmpty &&
                                              !homeSectionsLoading &&
                                              homeArticlesProvider.loadFailed)
                                            NoConnectionView(
                                              onRetry: () =>
                                                  homeArticlesProvider.load(),
                                            )
                                          else ...[
                                            FeaturedSection(
                                              articles:
                                                  featuredArticles.isNotEmpty
                                                  ? featuredArticles
                                                  : null,
                                              loading: homeSectionsLoading,
                                              sectionTitle:
                                                  featuredSectionTitle,
                                              displayTag: isActualitesTab
                                                  ? null
                                                  : parentCategories[selectedIndex]
                                                        .name,
                                              selectionService:
                                                  selectionService,
                                              onArticleTap: (args) =>
                                                  _openArticle(args),
                                            ),
                                            const SizedBox(height: 24),
                                            PressArticlesSection(
                                              articles: pressArticles.isNotEmpty
                                                  ? pressArticles
                                                  : null,
                                              loading: homeSectionsLoading,
                                              sectionTitle: pressSectionTitle,
                                              displayTag: isActualitesTab
                                                  ? null
                                                  : parentCategories[selectedIndex]
                                                        .name,
                                              selectionService:
                                                  selectionService,
                                              onArticleTap: (args) =>
                                                  _openArticle(args),
                                            ),
                                          ],
                                        ],
                                      )
                                    : overlayChildArticles.isEmpty
                                    ? const SizedBox.shrink()
                                    : OverlayCardListFromArticles(
                                        key: const ValueKey<String>('overlay'),
                                        articles: overlayChildArticles,
                                        tag: parentCategories[selectedIndex]
                                            .name,
                                        selectionService: selectionService,
                                        onArticleTap: _openArticle,
                                      )
                              : HomeFilterContent(
                                  key: ValueKey<int>(selectedIndex),
                                  parentCategories: parentCategories,
                                  articles: filterArticles,
                                  selectedIndex: selectedIndex,
                                  selectionService: selectionService,
                                  onArticleTap: _openArticle,
                                ),
                        ),
                      ),
                    ),
                  ],
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
            RefreshIndicator(
              onRefresh: () =>
                  context.read<GalleriesProvider>().loadGalleries(),
              child: const PhotothequePage(),
            ),
            RefreshIndicator(
              onRefresh: () => context.read<BooksProvider>().load(),
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
