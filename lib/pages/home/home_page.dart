import 'package:flutter/material.dart';
import 'package:sem_dsn/core/constants/app_assets.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/pages/article_detail/article_detail_page.dart';
import 'package:sem_dsn/widget/app_bottom_nav_bar.dart';
import 'package:sem_dsn/widget/app_header.dart';
import 'package:sem_dsn/widget/featured_section.dart';
import 'package:sem_dsn/widget/home_filter_content.dart';
import 'package:sem_dsn/widget/home_filter_section.dart';
import 'package:sem_dsn/widget/home_hero_section.dart';
import 'package:sem_dsn/widget/press_articles_section.dart';
import 'package:sem_dsn/pages/selection/selection_page_content.dart';
import 'package:sem_dsn/services/selection_service.dart';
import 'package:sem_dsn/pages/phototheque/phototheque_page.dart';
import 'package:sem_dsn/pages/phototheque/phototheque_search_page.dart';
import 'package:sem_dsn/pages/bibliographie/bibliographie_page.dart';

/// Page d'accueil : header, filtres, contenu selon filtre (Actualités = À la une + Articles de presse, sinon listes Campagne/Réalisations/Projets/etc.), bottom nav.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedFilterIndex = 0;
  int _selectedNavIndex = 0;
  final SelectionService _selectionService = SelectionService.instance;

  @override
  void initState() {
    super.initState();
    _selectionService.addListener(_onSelectionChanged);
  }

  @override
  void dispose() {
    _selectionService.removeListener(_onSelectionChanged);
    super.dispose();
  }

  void _onSelectionChanged() => setState(() {});

  void _openArticle(ArticleDetailArgs args) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ArticleDetailPage(args: args)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isActualites = _selectedFilterIndex == kFilterActualites;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppHeader(
        onSearchPressed: _selectedNavIndex == 1
            ? () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PhotothequeSearchPage(),
                  ),
                );
              }
            : null,
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedNavIndex,
          children: [
            CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 4)),
                SliverToBoxAdapter(
                  child: HomeHeroSection(
                    onCardTap: () => _openArticle(
                      ArticleDetailArgs(
                        title: AppStrings.heroTitle1,
                        date: AppStrings.heroDate1,
                        tag: AppStrings.news,
                        body: AppStrings.articleBodySample,
                        imagePath: AppAssets.hero1,
                        isVideo: false,
                        isHeroOrFeatured: true,
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyFilterDelegate(
                    child: HomeFilterSection(
                      selectedIndex: _selectedFilterIndex,
                      onSelected: (index) =>
                          setState(() => _selectedFilterIndex = index),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: isActualites
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FeaturedSection(
                                onArticleTap: (title, date, imagePath) =>
                                    _openArticle(
                                      ArticleDetailArgs(
                                        title: title,
                                        date: date,
                                        tag: AppStrings.news,
                                        body: AppStrings.articleBodySample,
                                        imagePath: imagePath,
                                        isVideo: false,
                                        isHeroOrFeatured: true,
                                      ),
                                    ),
                              ),
                              const SizedBox(height: 24),
                              PressArticlesSection(
                                selectionService: _selectionService,
                                onArticleTap: (title, date, imagePath) =>
                                    _openArticle(
                                      ArticleDetailArgs(
                                        title: title,
                                        date: date,
                                        tag: AppStrings.news,
                                        body: AppStrings.articleBodySample,
                                        imagePath: imagePath,
                                        isVideo: false,
                                        isHeroOrFeatured: false,
                                      ),
                                    ),
                              ),
                            ],
                          )
                        : HomeFilterContent(
                            filterIndex: _selectedFilterIndex,
                            onArticleTap: _openArticle,
                          ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
            const PhotothequePage(),
            const BibliographiePage(),
            const SelectionPageContent(),
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
