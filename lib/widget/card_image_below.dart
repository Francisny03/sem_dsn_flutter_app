import 'package:flutter/material.dart';
import 'package:sem_dsn/core/constants/app_border_radius.dart';
import 'package:sem_dsn/core/constants/app_font_sizes.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/core/animation/selection_star_animation.dart';
import 'package:sem_dsn/widget/image_from_path.dart';

/// Carte image + titre (et date optionnelle) en dessous (Réalisations, Projets).
class CardImageBelow extends StatelessWidget {
  const CardImageBelow({
    super.key,
    required this.imagePath,
    required this.title,
    required this.heroTag,
    this.date,
    this.showPlayButton = false,
    this.isStarSelected = false,
    this.onStarTap,
    this.onTap,
  });

  final String imagePath;
  final String title;
  final Object heroTag;
  final String? date;
  final bool showPlayButton;
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
                    child: ImageFromPath(
                      path: imagePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      memCacheWidth: 400,
                      // pas de memCacheHeight pour garder le ratio et éviter l'effet étiré
                    ),
                  ),
                ),
              ),
              if (showPlayButton)
                Positioned.fill(
                  child: Center(
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
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (onStarTap != null)
                  GestureDetector(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
