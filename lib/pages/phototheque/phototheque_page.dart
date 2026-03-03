import 'package:flutter/material.dart';
import 'package:sem_dsn/core/constants/app_font_sizes.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/core/constants/app_border_radius.dart';
import 'package:sem_dsn/core/constants/phototheque_data.dart';
import 'package:sem_dsn/pages/phototheque/phototheque_category_page.dart';

class PhotothequePage extends StatelessWidget {
  const PhotothequePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(
              AppStrings.navPhototheque,
              style: const TextStyle(
                color: AppColors.navBottomSelectItem,
                fontSize: AppFontSizes.menuTitle,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final cat = photothequeCategories[index];
              return _PhotothequeCategoryCard(
                imagePath: cat.image,
                title: cat.title,

                imageCount: cat.count,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PhotothequeCategoryPage(
                        title: cat.title,
                        imagePaths: photothequeCategoryImagePaths,
                      ),
                    ),
                  );
                },
              );
            }, childCount: photothequeCategories.length),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _PhotothequeCategoryCard extends StatelessWidget {
  const _PhotothequeCategoryCard({
    required this.imagePath,
    required this.title,
    required this.imageCount,
    required this.onTap,
  });

  final String imagePath;
  final String title;
  final int imageCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorderRadius.r12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: AppBorderRadius.r12,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.filterUnselected,
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.newsTitle,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 0),
            Text(
              '$imageCount ${AppStrings.photothequeImagesCount}',
              style: const TextStyle(color: AppColors.newsDate, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
