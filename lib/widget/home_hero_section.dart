import 'package:flutter/material.dart';
import 'package:sem_dsn/core/constants/app_assets.dart';
import 'package:sem_dsn/core/constants/app_border_radius.dart';
import 'package:sem_dsn/core/constants/app_padding.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/core/animation/selection_star_animation.dart';
import 'package:sem_dsn/widget/congolese_flag_painter.dart';

/// Section héros : grande carte avec image, dégradé, badge, titre, date et indicateurs.
class HomeHeroSection extends StatefulWidget {
  const HomeHeroSection({super.key, this.onCardTap});

  final VoidCallback? onCardTap;

  @override
  State<HomeHeroSection> createState() => _HomeHeroSectionState();
}

class _HomeHeroSectionState extends State<HomeHeroSection> {
  bool _isStarSelected = false;

  void _onStarTap() {
    setState(() => _isStarSelected = !_isStarSelected);
    if (_isStarSelected) {
      // TODO: ajouter le contenu hero à la sélection
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPadding.horizontalPadding20,
      child: ClipRRect(
        borderRadius: AppBorderRadius.r16,
        child: Stack(
          children: [
            GestureDetector(
              onTap: widget.onCardTap,
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                height: 360,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(AppAssets.hero1, fit: BoxFit.cover),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: AppColors.gradientHero,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 0,
              right: 16,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.heroSelectionTag,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                alignment: Alignment.center,
                child: AnimatedSelectionStar(
                  isSelected: _isStarSelected,
                  onTap: _onStarTap,
                  selectedColor: AppColors.blackIcon,
                  unselectedColor: AppColors.blackIcon,
                  size: 24,
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 50,
              bottom: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.heroTag,
                      borderRadius: AppBorderRadius.rtotal,
                    ),
                    child: const Text(
                      AppStrings.news,
                      style: TextStyle(
                        color: AppColors.whiteTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.heroTitle1,
                    maxLines: 3,
                    style: TextStyle(
                      color: AppColors.whiteTextColor,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.heroDate1,
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
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _dot(active: true),
                  const SizedBox(width: 6),
                  _dot(active: false),
                  const SizedBox(width: 6),
                  _dot(active: false),
                  const SizedBox(width: 6),
                  _dot(active: false),
                  const SizedBox(width: 6),
                  _dot(active: false),
                ],
              ),
            ),
          ],
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
