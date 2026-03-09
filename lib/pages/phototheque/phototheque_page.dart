import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sem_dsn/core/constants/app_font_sizes.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/core/constants/app_border_radius.dart';
import 'package:sem_dsn/models/gallery.dart';
import 'package:sem_dsn/providers/galleries_provider.dart';
import 'package:sem_dsn/pages/phototheque/phototheque_category_page.dart';
import 'package:sem_dsn/widget/image_from_path.dart';

class PhotothequePage extends StatelessWidget {
  const PhotothequePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GalleriesProvider>(
      builder: (context, galleriesProvider, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          galleriesProvider.loadIfNeeded();
        });
        final galleries = galleriesProvider.galleries;
        final loading = galleriesProvider.loading;

        if (loading && galleries.isEmpty) {
          return const CustomScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Text(
                    AppStrings.navPhototheque,
                    style: TextStyle(
                      color: AppColors.navBottomSelectItem,
                      fontSize: AppFontSizes.menuTitle,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
              SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          );
        }

        if (galleries.isEmpty) {
          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
              const SliverFillRemaining(
                child: Center(child: Text('Aucune galerie pour le moment')),
              ),
            ],
          );
        }

        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                  final gallery = galleries[index];
                  return _PhotothequeCategoryCard(
                    gallery: gallery,
                    imageCount: galleriesProvider.totalImagesForGallery(
                      gallery.id,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => PhotothequeCategoryPage(
                            galleryId: gallery.id,
                            title: gallery.name,
                          ),
                        ),
                      );
                    },
                  );
                }, childCount: galleries.length),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }
}

class _PhotothequeCategoryCard extends StatelessWidget {
  const _PhotothequeCategoryCard({
    required this.gallery,
    required this.imageCount,
    required this.onTap,
  });

  final Gallery gallery;
  final int imageCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final coverUrl = gallery.coverUrl;
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
                child: coverUrl != null && coverUrl.isNotEmpty
                    ? ImageFromPath(
                        path: coverUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    : Container(
                        color: AppColors.filterUnselected,
                        child: const Icon(
                          Icons.photo_library_outlined,
                          size: 48,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              gallery.name,
              style: const TextStyle(
                color: AppColors.newsTitle,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              imageCount > 0
                  ? '$imageCount ${AppStrings.photothequeImagesCount}'
                  : AppStrings.photothequeImagesCount,
              style: const TextStyle(color: AppColors.newsDate, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
