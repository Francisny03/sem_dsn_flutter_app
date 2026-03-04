import 'package:flutter/material.dart';
import 'package:sem_dsn/core/constants/app_assets.dart';
import 'package:sem_dsn/core/constants/app_border_radius.dart';
import 'package:sem_dsn/core/constants/app_font_sizes.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/core/animation/selection_star_animation.dart';
import 'package:sem_dsn/pages/article_detail/article_detail_page.dart';
import 'package:sem_dsn/services/selection_service.dart';

/// Index des filtres : Actualités, Campagne, Réalisations, Discours, Projets, Interviews, Archives.
const int kFilterActualites = 0;
const int kFilterCampagne = 1;
const int kFilterRealisations = 2;
const int kFilterDiscours = 3;
const int kFilterProjets = 4;
const int kFilterInterviews = 5;
const int kFilterArchives = 6;

/// Contenu affiché selon le filtre sélectionné (liste Campagne / Réalisations / Projets etc.).
class HomeFilterContent extends StatelessWidget {
  const HomeFilterContent({
    super.key,
    required this.filterIndex,
    this.selectionService,
    this.onArticleTap,
  });

  final int filterIndex;
  final SelectionService? selectionService;
  final void Function(ArticleDetailArgs args)? onArticleTap;

  static String _tagForFilter(int index) {
    switch (index) {
      case kFilterCampagne:
        return AppStrings.campaign;
      case kFilterRealisations:
        return AppStrings.achievements;
      case kFilterDiscours:
        return AppStrings.speeches;
      case kFilterProjets:
        return AppStrings.projects;
      case kFilterInterviews:
        return AppStrings.interviews;
      case kFilterArchives:
        return AppStrings.archives;
      default:
        return AppStrings.news;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (filterIndex == kFilterActualites) {
      return const SizedBox.shrink();
    }
    if (filterIndex == kFilterCampagne ||
        filterIndex == kFilterInterviews ||
        filterIndex == kFilterArchives ||
        filterIndex == kFilterDiscours) {
      return _OverlayCardList(
        items: _overlayItems,
        tag: _tagForFilter(filterIndex),
        selectionService: selectionService,
        onArticleTap: onArticleTap,
      );
    }
    if (filterIndex == kFilterRealisations) {
      return _ImageBelowCardList(
        items: _achievementItems,
        tag: _tagForFilter(filterIndex),
        selectionService: selectionService,
        onArticleTap: onArticleTap,
      );
    }
    if (filterIndex == kFilterProjets) {
      return _ImageBelowCardList(
        items: _projectItems,
        showDate: false,
        tag: _tagForFilter(filterIndex),
        selectionService: selectionService,
        onArticleTap: onArticleTap,
      );
    }
    return const SizedBox.shrink();
  }
}

// ——— Données cartes overlay (image + gradient + texte + date + play si vidéo) ———

final List<({String image, String title, String date, bool isVideo})>
_overlayItems = [
  (
    image: AppAssets.news1,
    title: AppStrings.campaignCard1Title,
    date: AppStrings.campaignCard1Date,
    isVideo: false,
  ),
  (
    image: AppAssets.news2,
    title: AppStrings.campaignCard2Title,
    date: AppStrings.campaignCard2Date,
    isVideo: true,
  ),
  (
    image: AppAssets.news3,
    title: AppStrings.campaignCard3Title,
    date: AppStrings.campaignCard3Date,
    isVideo: true,
  ),
];

// ——— Données Réalisations (image + titre + date en dessous) ———

final List<({String image, String title, String date})> _achievementItems = [
  (
    image: AppAssets.alaune1,
    title: AppStrings.achievement1Title,
    date: AppStrings.achievement1Date,
  ),
  (
    image: AppAssets.alaune2,
    title: AppStrings.achievement2Title,
    date: AppStrings.achievement2Date,
  ),
  (
    image: AppAssets.alaune1,
    title: AppStrings.achievement3Title,
    date: AppStrings.achievement3Date,
  ),
];

// ——— Données Projets futurs (image + titre, sans date) ———

final List<({String image, String title, String date})> _projectItems = [
  (image: AppAssets.alaune1, title: AppStrings.project1Title, date: ''),
  (image: AppAssets.alaune2, title: AppStrings.project2Title, date: ''),
  (image: AppAssets.alaune1, title: AppStrings.project3Title, date: ''),
];

// ——— Liste de cartes avec overlay (gradient + texte + date + play si vidéo) ———

class _OverlayCardList extends StatelessWidget {
  const _OverlayCardList({
    required this.items,
    required this.tag,
    this.selectionService,
    this.onArticleTap,
  });

  final List<({String image, String title, String date, bool isVideo})> items;
  final String tag;
  final SelectionService? selectionService;
  final void Function(ArticleDetailArgs args)? onArticleTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        final article = SelectedArticle(
          title: item.title,
          date: item.date,
          imagePath: item.image,
        );
        final heroTag = ArticleDetailArgs.heroTagFor(
          imagePath: item.image,
          title: item.title,
          date: item.date,
          sourceId: tag,
          index: index,
        );
        return _OverlayCard(
          imagePath: item.image,
          title: item.title,
          date: item.date,
          showPlayButton: item.isVideo,
          heroTag: heroTag,
          isStarSelected: selectionService?.contains(article) ?? false,
          onStarTap: selectionService != null
              ? () => selectionService!.toggle(article)
              : null,
          onTap: onArticleTap != null
              ? () => onArticleTap!(
                  ArticleDetailArgs(
                    title: item.title,
                    date: item.date,
                    tag: tag,
                    body: AppStrings.articleBodySample,
                    imagePath: item.image,
                    isVideo: item.isVideo,
                    videoPath: item.isVideo ? AppAssets.videotest : null,
                    isHeroOrFeatured: false,
                    heroTagOverride: heroTag,
                  ),
                )
              : null,
        );
      },
    );
  }
}

class _OverlayCard extends StatelessWidget {
  const _OverlayCard({
    required this.imagePath,
    required this.title,
    required this.date,
    required this.showPlayButton,
    required this.heroTag,
    this.isStarSelected = false,
    this.onStarTap,
    this.onTap,
  });

  final String imagePath;
  final String title;
  final String date;
  final bool showPlayButton;
  final Object heroTag;
  final bool isStarSelected;
  final VoidCallback? onStarTap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: AppBorderRadius.r10,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 220,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: heroTag,
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.gradientFeatured,
                    ),
                  ),
                ],
              ),
            ),
            if (showPlayButton)
              Hero(
                tag: ArticleDetailArgs.heroTagForVideoPlay(heroTag),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: AppColors.whiteTextColor,
                    size: 40,
                  ),
                ),
              ),
            if (onStarTap != null)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onStarTap,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: AnimatedSelectionStar(
                      isSelected: isStarSelected,
                      onTap: onStarTap!,
                      selectedColor: AppColors.heroSelectionTag,
                      unselectedColor: AppColors.whiteTextColor,
                      size: 22,
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 12,
              right: 80,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.whiteTextColor,
                      fontSize: AppFontSizes.campaignTitle,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 0),
                  Text(
                    date,
                    style: TextStyle(
                      color: AppColors.whiteTextColor.withValues(alpha: 0.9),
                      fontSize: AppFontSizes.campaignDate,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ——— Liste image + texte (et date optionnelle) en dessous ———

class _ImageBelowCardList extends StatelessWidget {
  const _ImageBelowCardList({
    required this.items,
    this.showDate = true,
    required this.tag,
    this.selectionService,
    this.onArticleTap,
  });

  final List<({String image, String title, String date})> items;
  final bool showDate;
  final String tag;
  final SelectionService? selectionService;
  final void Function(ArticleDetailArgs args)? onArticleTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        final article = SelectedArticle(
          title: item.title,
          date: item.date,
          imagePath: item.image,
        );
        final heroTag = ArticleDetailArgs.heroTagFor(
          imagePath: item.image,
          title: item.title,
          date: item.date,
          sourceId: tag,
          index: index,
        );
        return _ImageBelowCard(
          imagePath: item.image,
          title: item.title,
          date: showDate ? item.date : null,
          heroTag: heroTag,
          isStarSelected: selectionService?.contains(article) ?? false,
          onStarTap: selectionService != null
              ? () => selectionService!.toggle(article)
              : null,
          onTap: onArticleTap != null
              ? () => onArticleTap!(
                  ArticleDetailArgs(
                    title: item.title,
                    date: item.date,
                    tag: tag,
                    body: AppStrings.articleBodySample,
                    imagePath: item.image,
                    isVideo: false,
                    isHeroOrFeatured: false,
                    heroTagOverride: heroTag,
                  ),
                )
              : null,
        );
      },
    );
  }
}

class _ImageBelowCard extends StatelessWidget {
  const _ImageBelowCard({
    required this.imagePath,
    required this.title,
    required this.heroTag,
    this.date,
    this.isStarSelected = false,
    this.onStarTap,
    this.onTap,
  });

  final String imagePath;
  final String title;
  final Object heroTag;
  final String? date;
  final bool isStarSelected;
  final VoidCallback? onStarTap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Hero(
                tag: heroTag,
                child: ClipRRect(
                  borderRadius: AppBorderRadius.r12,
                  child: SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              ),
              if (onStarTap != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onStarTap,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: AnimatedSelectionStar(
                        isSelected: isStarSelected,
                        onTap: onStarTap!,
                        selectedColor: AppColors.heroSelectionTag,
                        unselectedColor: AppColors.grayTextColor,
                        size: 22,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.newsTitle,
                    fontSize: AppFontSizes.projectTitle,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (date != null && date!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    date!,
                    style: const TextStyle(
                      color: AppColors.newsDate,
                      fontSize: AppFontSizes.projectDate,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
