import 'package:flutter/material.dart';
import 'package:sem_dsn/core/constants/live_config.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/pages/article_detail/article_detail_page.dart';
import 'package:sem_dsn/pages/live/live_fullscreen_page.dart';
import 'package:sem_dsn/pages/selection/selection_page_content.dart';
import 'package:sem_dsn/pages/phototheque/phototheque_page.dart';
import 'package:sem_dsn/pages/phototheque/phototheque_search_page.dart';
import 'package:sem_dsn/pages/bibliographie/bibliographie_page.dart';
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
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActualites = _selectedFilterIndex == kFilterActualites;

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
              onRefresh: () async => setState(() {}),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 4)),
                  SliverToBoxAdapter(
                    child: HomeHeroSection(
                      selectionService: _selectionService,
                      onCardTap: (args) => _openArticle(args),
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
                        child: isActualites
                            ? Column(
                                key: const ValueKey<bool>(true),
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FeaturedSection(
                                    selectionService: _selectionService,
                                    onArticleTap: (args) => _openArticle(args),
                                  ),
                                  const SizedBox(height: 24),
                                  PressArticlesSection(
                                    selectionService: _selectionService,
                                    onArticleTap: (args) => _openArticle(args),
                                  ),
                                ],
                              )
                            : HomeFilterContent(
                                key: ValueKey<int>(_selectedFilterIndex),
                                filterIndex: _selectedFilterIndex,
                                selectionService: _selectionService,
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
              key: ValueKey('selection_${_selectionService.items.length}'),
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
