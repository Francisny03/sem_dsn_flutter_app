import 'package:flutter/material.dart';
import 'package:sem_dsn/core/constants/app_assets.dart';
import 'package:sem_dsn/core/constants/app_border_radius.dart';
import 'package:sem_dsn/core/constants/app_font_sizes.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';

/// Section "Featured" (À La Une) : liste horizontale de cartes d'articles en vedette.
class FeaturedSection extends StatelessWidget {
  const FeaturedSection({super.key, this.onArticleTap});

  final void Function(String title, String date, String imagePath)?
  onArticleTap;

  static const List<({String image, String title, String date})> _items = [
    (
      image: AppAssets.alaune1,
      title: AppStrings.featuredTitle1,
      date: AppStrings.featuredDate1,
    ),
    (
      image: AppAssets.alaune2,
      title: AppStrings.featuredTitle2,
      date: AppStrings.featuredDate2,
    ),
    (
      image: AppAssets.alaune1,
      title: AppStrings.featuredTitle3,
      date: AppStrings.featuredDate3,
    ),
    (
      image: AppAssets.alaune2,
      title: AppStrings.featuredTitle2,
      date: AppStrings.featuredDate2,
    ),
    (
      image: AppAssets.alaune1,
      title: AppStrings.featuredTitle1,
      date: AppStrings.featuredDate1,
    ),
    (
      image: AppAssets.alaune2,
      title: AppStrings.featuredTitle2,
      date: AppStrings.featuredDate2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppStrings.sectionTitleFeatured,
            style: TextStyle(
              color: AppColors.sectionTitle,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return _FeaturedCard(
                imagePath: item.image,
                title: item.title,
                date: item.date,
                onTap: onArticleTap != null
                    ? () => onArticleTap!(item.title, item.date, item.image)
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.imagePath,
    required this.title,
    required this.date,
    this.onTap,
  });

  final String imagePath;
  final String title;
  final String date;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 220,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(borderRadius: AppBorderRadius.r12),
        child: ClipRRect(
          borderRadius: AppBorderRadius.r12,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(imagePath, fit: BoxFit.cover),
              Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.gradientFeatured,
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.whiteTextColor,
                        fontSize: AppFontSizes.featuredTitle,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: TextStyle(
                        color: AppColors.whiteTextColor.withValues(alpha: 0.9),
                        fontSize: AppFontSizes.featuredDate,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
