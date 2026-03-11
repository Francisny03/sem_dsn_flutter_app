import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sem_dsn/core/constants/app_assets.dart';
import 'package:sem_dsn/core/constants/app_border_radius.dart';
import 'package:sem_dsn/core/constants/app_padding.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/core/animation/selection_star_animation.dart';
import 'package:sem_dsn/models/article.dart';
import 'package:sem_dsn/providers/categories_provider.dart';
import 'package:sem_dsn/services/selection_service.dart';
import 'package:sem_dsn/widget/article_detail_args.dart';
import 'package:sem_dsn/widget/congolese_flag_painter.dart';
import 'package:sem_dsn/widget/image_from_path.dart';
import 'package:sem_dsn/widget/netflix_shimmer.dart';

/// Données d'une slide du hero (titre, date, image, tag catégorie optionnel).
class _HeroSlide {
  const _HeroSlide({
    required this.title,
    required this.date,
    required this.imagePath,
    this.tag,
    this.isLiveTag = false,
  });

  final String title;
  final String date;
  final String imagePath;

  /// Nom de la catégorie à afficher sur le badge (ex. « Actualités ») ; si null, défaut AppStrings.news.
  final String? tag;

  /// true = badge tag en rouge (carte live).
  final bool isLiveTag;
}

const Duration _kAutoScrollDuration = Duration(seconds: 5);

const Duration _kSlideContentAnimationDuration = Duration(milliseconds: 450);

/// Couleur des éléments skeleton dans les placeholders (gris sur fond sombre).
const Color _kSkeletonColor = Color(0xFF3D3D3D);

/// Placeholder style Netflix : même structure que le hero + shimmer (vague lumineuse).
class _HeroLoadingPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NetflixShimmer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1F1F1F),
                  Color(0xFF2D2D2D),
                  Color(0xFF0D0D0D),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 50,
            bottom: 40,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _kSkeletonColor,
                    borderRadius: AppBorderRadius.rtotal,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 22,
                  decoration: BoxDecoration(
                    color: _kSkeletonColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 140,
                  height: 22,
                  decoration: BoxDecoration(
                    color: _kSkeletonColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 100,
                  height: 14,
                  decoration: BoxDecoration(
                    color: _kSkeletonColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 120,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _kSkeletonColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 8,
            bottom: 40,
            child: SvgPicture.asset(
              AppAssets.selection2,
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(_kSkeletonColor, BlendMode.srcIn),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.heroSelectionTag.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const Center(
            child: SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.heroSelectionTag,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const Curve _kSlideContentAnimationCurve = Curves.easeOutCubic;

/// Contenu animé d'une slide (fade + slide up à l'apparition).
class _AnimatedHeroSlideContent extends StatefulWidget {
  const _AnimatedHeroSlideContent({required this.slide, this.selectionService});

  final _HeroSlide slide;
  final SelectionService? selectionService;

  @override
  State<_AnimatedHeroSlideContent> createState() =>
      _AnimatedHeroSlideContentState();
}

class _AnimatedHeroSlideContentState extends State<_AnimatedHeroSlideContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slideOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: _kSlideContentAnimationDuration,
      vsync: this,
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: _kSlideContentAnimationCurve),
    );
    _slideOffset = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: _kSlideContentAnimationCurve,
          ),
        );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slideOffset,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.slide.isLiveTag
                    ? AppColors.dangerLight
                    : AppColors.heroTag,
                borderRadius: AppBorderRadius.rtotal,
              ),
              child: Text(
                widget.slide.tag ?? AppStrings.news,
                style: const TextStyle(
                  color: AppColors.whiteTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.slide.title,
              maxLines: 3,
              style: const TextStyle(
                color: AppColors.whiteTextColor,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                height: 1.2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            if (widget.slide.date.isNotEmpty)
              Text(
                widget.slide.date,
                style: TextStyle(
                  color: AppColors.whiteTextColor.withValues(alpha: 0.9),
                  fontSize: 14,
                ),
              ),
            const SizedBox(height: 10),
            ClipRRect(
              child: SizedBox(
                width: 120,
                height: 5,
                child: CustomPaint(painter: CongoleseFlagPainter()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section héros : carousel d'actualités avec image, dégradé, badge, titre, date.
/// Si un live est actif ([hasLiveContent]), la première slide est la carte live (image, titre, tag Live en rouge).
/// Si [loading] est true, affiche un placeholder style Netflix.
class HomeHeroSection extends StatefulWidget {
  const HomeHeroSection({
    super.key,
    this.articles,
    this.loading = false,
    this.selectionService,
    this.onCardTap,
    this.hasLiveContent = false,
    this.liveImageUrl,
    this.liveTitle,
    this.onLiveTap,
  });

  final List<Article>? articles;

  /// true = afficher le placeholder de chargement (style Netflix) au lieu du carousel.
  final bool loading;
  final SelectionService? selectionService;
  final void Function(ArticleDetailArgs args)? onCardTap;

  /// true = première slide = carte live (image, titre, tag Live rouge), puis les articles.
  final bool hasLiveContent;
  final String? liveImageUrl;
  final String? liveTitle;
  final VoidCallback? onLiveTap;

  @override
  State<HomeHeroSection> createState() => _HomeHeroSectionState();
}

class _HomeHeroSectionState extends State<HomeHeroSection> {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    widget.selectionService?.addListener(_onSelectionChanged);
    _startAutoScroll();
  }

  @override
  void didUpdateWidget(covariant HomeHeroSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectionService != widget.selectionService) {
      oldWidget.selectionService?.removeListener(_onSelectionChanged);
      widget.selectionService?.addListener(_onSelectionChanged);
    }
    final n = _slideCount;
    if (n > 0 && _currentIndex >= n) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _currentIndex = n - 1);
      });
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    widget.selectionService?.removeListener(_onSelectionChanged);
    super.dispose();
  }

  void _onSelectionChanged() => setState(() {});

  /// Avec live : 1 slide live + articles. Sans live : articles uniquement.
  int get _slideCount {
    final list = widget.articles;
    final articleCount = list != null ? list.length : 0;
    if (widget.hasLiveContent) return 1 + articleCount;
    return articleCount;
  }

  bool get _hasContent => _slideCount > 0;

  /// Index dans widget.articles pour la slide à l’index [slideIndex] (retourne null si slide = live).
  int? _articleIndexForSlide(int slideIndex) {
    if (!widget.hasLiveContent) return slideIndex;
    if (slideIndex == 0) return null;
    return slideIndex - 1;
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    final n = _slideCount;
    if (n == 0) return;
    _autoScrollTimer = Timer.periodic(_kAutoScrollDuration, (_) {
      if (!mounted) return;
      final next = (_currentIndex + 1) % n;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    _startAutoScroll(); // reset timer after manual scroll
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPadding.horizontalPadding20,
      child: ClipRRect(
        borderRadius: AppBorderRadius.r16,
        child: SizedBox(
          height: 360,
          width: double.infinity,
          child: (widget.loading || !_hasContent)
              ? _HeroLoadingPlaceholder()
              : Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: _slideCount,
                      onPageChanged: _onPageChanged,
                      itemBuilder: (context, index) {
                        final isLiveSlide = widget.hasLiveContent && index == 0;
                        if (isLiveSlide) {
                          final slide = _HeroSlide(
                            title: widget.liveTitle?.trim().isNotEmpty == true
                                ? widget.liveTitle!
                                : AppStrings.liveHeroDefaultTitle,
                            date: '',
                            imagePath: AppAssets.imageOrDefault(
                              widget.liveImageUrl,
                            ),
                            tag: AppStrings.liveTitle,
                            isLiveTag: true,
                          );
                          return GestureDetector(
                            onTap: widget.onLiveTap,
                            behavior: HitTestBehavior.opaque,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ImageFromPath(
                                  path: slide.imagePath,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                    gradient: AppColors.gradientHero,
                                  ),
                                ),
                                Positioned(
                                  left: 16,
                                  right: 50,
                                  bottom: 40,
                                  child: _AnimatedHeroSlideContent(
                                    slide: slide,
                                    selectionService: null,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        final articleIndex = _articleIndexForSlide(index)!;
                        final apiArticle = widget.articles![articleIndex];
                        final cat = apiArticle.categories.isNotEmpty
                            ? apiArticle.categories.first
                            : null;
                        final tag =
                            context
                                .read<CategoriesProvider>()
                                .getDisplayNameForCategory(cat) ??
                            cat?.name ??
                            AppStrings.news;
                        final slide = _HeroSlide(
                          title: apiArticle.title,
                          date: Article.formatDisplayDate(
                            apiArticle.articleDate,
                          ),
                          imagePath: AppAssets.imageOrDefault(
                            apiArticle.firstImageUrl,
                          ),
                          tag: tag,
                        );
                        final heroTag = ArticleDetailArgs.heroTagFor(
                          imagePath: slide.imagePath,
                          title: slide.title,
                          date: slide.date,
                          sourceId: 'hero',
                          index: index,
                        );
                        return GestureDetector(
                          onTap: () {
                            if (widget.onCardTap != null) {
                              final cat = apiArticle.categories.isNotEmpty
                                  ? apiArticle.categories.first
                                  : null;
                              final tagName =
                                  context
                                      .read<CategoriesProvider>()
                                      .getDisplayNameForCategory(cat) ??
                                  cat?.name ??
                                  AppStrings.news;
                              widget.onCardTap!(
                                ArticleDetailArgs.fromArticle(
                                  apiArticle,
                                  tagName,
                                  isHeroOrFeatured: true,
                                  heroTagOverride: heroTag,
                                ),
                              );
                            }
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Hero(
                                tag: heroTag,
                                child: ImageFromPath(
                                  path: slide.imagePath,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              Container(
                                decoration: const BoxDecoration(
                                  gradient: AppColors.gradientHero,
                                ),
                              ),
                              Positioned(
                                left: 16,
                                right: 50,
                                bottom: 40,
                                child: _AnimatedHeroSlideContent(
                                  slide: slide,
                                  selectionService: widget.selectionService,
                                ),
                              ),
                              Positioned(
                                right: 15,
                                top: -8,
                                child: Builder(
                                  builder: (context) {
                                    final article = SelectedArticle(
                                      title: slide.title,
                                      date: slide.date,
                                      imagePath: slide.imagePath,
                                    );
                                    return Container(
                                      width: 38,
                                      height: 38,
                                      alignment: Alignment.center,
                                      child: AnimatedSelectionStar(
                                        isSelected:
                                            widget.selectionService?.contains(
                                              article,
                                            ) ??
                                            false,
                                        onTap: () => widget.selectionService
                                            ?.toggle(article),
                                        selectedColor: AppColors.yellowLight,
                                        unselectedColor:
                                            AppColors.whiteTextColor,
                                        size: 25,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    // Positioned(
                    //   bottom: 60,
                    //   right: 16,
                    //   child: Builder(
                    //     builder: (context) {
                    //       final n = _slideCount;
                    //       final safeIndex = n > 0 ? _currentIndex.clamp(0, n - 1) : 0;
                    //       final useApi =
                    //           widget.articles != null && widget.articles!.isNotEmpty;
                    //       final slide = useApi
                    //           ? _HeroSlide(
                    //               title: widget.articles![safeIndex].title,
                    //               date: Article.formatDisplayDate(
                    //                 widget.articles![safeIndex].articleDate,
                    //               ),
                    //               imagePath: AppAssets.imageOrDefault(
                    //                 widget.articles![safeIndex].firstImageUrl,
                    //               ),
                    //             )
                    //           : _heroSlides[safeIndex];
                    //       final article = SelectedArticle(
                    //         title: slide.title,
                    //         date: slide.date,
                    //         imagePath: slide.imagePath,
                    //       );
                    //       return Container(
                    //         width: 38,
                    //         height: 38,
                    //         decoration: const BoxDecoration(
                    //           color: Colors.transparent,
                    //           borderRadius: BorderRadius.only(
                    //             bottomLeft: Radius.circular(10),
                    //             bottomRight: Radius.circular(10),
                    //           ),
                    //         ),
                    //         alignment: Alignment.center,
                    //         child: AnimatedSelectionStar(
                    //           isSelected:
                    //               widget.selectionService?.contains(article) ?? false,
                    //           onTap: () => widget.selectionService?.toggle(article),
                    //           selectedColor: AppColors.yellowLight,
                    //           unselectedColor: AppColors.whiteTextColor,
                    //           size: 24,
                    //         ),
                    //       );
                    //     },
                    //   ),
                    // ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _slideCount,
                          (i) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: _dot(active: i == _currentIndex),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _dot({required bool active}) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? AppColors.activeDotSlider
            : AppColors.whiteTextColor.withValues(alpha: 0.6),
      ),
    );
  }
}
