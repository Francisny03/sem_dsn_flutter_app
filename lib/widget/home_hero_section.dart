import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sem_dsn/core/constants/app_assets.dart';
import 'package:sem_dsn/core/constants/app_border_radius.dart';
import 'package:sem_dsn/core/constants/app_padding.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/core/animation/selection_star_animation.dart';
import 'package:sem_dsn/models/article.dart';
import 'package:sem_dsn/services/selection_service.dart';
import 'package:sem_dsn/widget/article_detail_args.dart';
import 'package:sem_dsn/widget/congolese_flag_painter.dart';
import 'package:sem_dsn/widget/image_from_path.dart';

/// Données d'une slide du hero (titre, date, image, tag catégorie optionnel).
class _HeroSlide {
  const _HeroSlide({
    required this.title,
    required this.date,
    required this.imagePath,
    this.tag,
  });

  final String title;
  final String date;
  final String imagePath;
  /// Nom de la catégorie à afficher sur le badge (ex. « Actualités ») ; si null, défaut AppStrings.news.
  final String? tag;
}

const List<_HeroSlide> _heroSlides = [
  _HeroSlide(
    title: AppStrings.heroTitle1,
    date: AppStrings.heroDate1,
    imagePath: AppAssets.hero1,
  ),
  _HeroSlide(
    title: AppStrings.heroTitle2,
    date: AppStrings.heroDate2,
    imagePath: AppAssets.hero2,
  ),
  _HeroSlide(
    title: AppStrings.heroTitle3,
    date: AppStrings.heroDate3,
    imagePath: AppAssets.alaune1,
  ),
  _HeroSlide(
    title: AppStrings.heroTitle4,
    date: AppStrings.heroDate4,
    imagePath: AppAssets.news1,
  ),
  _HeroSlide(
    title: AppStrings.heroTitle5,
    date: AppStrings.heroDate5,
    imagePath: AppAssets.news2,
  ),
];

const Duration _kAutoScrollDuration = Duration(seconds: 5);

const Duration _kSlideContentAnimationDuration = Duration(milliseconds: 450);
const Curve _kSlideContentAnimationCurve = Curves.easeOutCubic;

/// Contenu animé d'une slide (fade + slide up à l'apparition).
class _AnimatedHeroSlideContent extends StatefulWidget {
  const _AnimatedHeroSlideContent({required this.slide});

  final _HeroSlide slide;

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
                color: AppColors.heroTag,
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
                fontSize: 25,
                fontWeight: FontWeight.w900,
                height: 1.2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
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
/// Si [articles] est fourni (API), affiche ces articles ; sinon données statiques.
/// Défilement automatique toutes les 5 s + défilement manuel par scroll.
class HomeHeroSection extends StatefulWidget {
  const HomeHeroSection({
    super.key,
    this.articles,
    this.selectionService,
    this.onCardTap,
  });

  final List<Article>? articles;
  final SelectionService? selectionService;
  final void Function(ArticleDetailArgs args)? onCardTap;

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

  int get _slideCount {
    final list = widget.articles;
    if (list != null && list.isNotEmpty) return list.length;
    return _heroSlides.length;
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
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: _slideCount,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final useApi =
                      widget.articles != null && widget.articles!.isNotEmpty;
                  final _HeroSlide slide;
                  Article? apiArticle;
                  if (useApi) {
                    apiArticle = widget.articles![index];
                    final tag = apiArticle.categories.isNotEmpty
                        ? apiArticle.categories.first.name
                        : AppStrings.news;
                    slide = _HeroSlide(
                      title: apiArticle.title,
                      date: Article.formatDisplayDate(apiArticle.articleDate),
                      imagePath: apiArticle.firstImageUrl ?? AppAssets.defaultImageArticle,
                      tag: tag,
                    );
                  } else {
                    slide = _heroSlides[index];
                  }
                  final heroTag = ArticleDetailArgs.heroTagFor(
                    imagePath: slide.imagePath,
                    title: slide.title,
                    date: slide.date,
                    sourceId: 'hero',
                    index: index,
                  );
                  return GestureDetector(
                    onTap: () {
                      if (apiArticle != null && widget.onCardTap != null) {
                        final tag = apiArticle.categories.isNotEmpty
                            ? apiArticle.categories.first.name
                            : AppStrings.news;
                        widget.onCardTap!(
                          ArticleDetailArgs.fromArticle(
                            apiArticle,
                            tag,
                            isHeroOrFeatured: true,
                            heroTagOverride: heroTag,
                          ),
                        );
                      } else if (widget.onCardTap != null) {
                        widget.onCardTap!(
                          ArticleDetailArgs(
                            title: slide.title,
                            date: slide.date,
                            tag: AppStrings.news,
                            body: AppStrings.articleBodySample,
                            imagePath: slide.imagePath,
                            isVideo: false,
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
                          child: _AnimatedHeroSlideContent(slide: slide),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Positioned(
                top: 0,
                right: 16,
                child: Builder(
                  builder: (context) {
                    final n = _slideCount;
                    final safeIndex = n > 0 ? _currentIndex.clamp(0, n - 1) : 0;
                    final useApi =
                        widget.articles != null && widget.articles!.isNotEmpty;
                    final slide = useApi
                        ? _HeroSlide(
                            title: widget.articles![safeIndex].title,
                            date: Article.formatDisplayDate(
                              widget.articles![safeIndex].articleDate,
                            ),
                            imagePath:
                                widget.articles![safeIndex].firstImageUrl ??
                                AppAssets.defaultImageArticle,
                          )
                        : _heroSlides[safeIndex];
                    final article = SelectedArticle(
                      title: slide.title,
                      date: slide.date,
                      imagePath: slide.imagePath,
                    );
                    return Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: AnimatedSelectionStar(
                        isSelected:
                            widget.selectionService?.contains(article) ?? false,
                        onTap: () => widget.selectionService?.toggle(article),
                        selectedColor: AppColors.yellowLight,
                        unselectedColor: AppColors.whiteTextColor,
                        size: 24,
                      ),
                    );
                  },
                ),
              ),
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
