import 'package:flutter/material.dart';
import 'package:sem_dsn/core/constants/app_border_radius.dart';
import 'package:sem_dsn/core/constants/app_font_sizes.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/core/animation/selection_star_animation.dart';
import 'package:sem_dsn/widget/article_detail_args.dart';
import 'package:sem_dsn/widget/image_from_path.dart';

/// Carte overlay (Campagne, etc.) : image en fond, gradient, titre + date dessus, play si vidéo, icône sélection.
class CardOverlay extends StatelessWidget {
  const CardOverlay({
    super.key,
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
                    child: ImageFromPath(
                      path: imagePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      memCacheWidth: 400,
                      // pas de memCacheHeight pour garder le ratio de l'image et éviter l'effet étiré
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
                bottom: 12,
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
