import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sem_dsn/core/constants/app_assets.dart';
import 'package:sem_dsn/core/constants/app_border_radius.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/providers/galleries_provider.dart';
import 'package:sem_dsn/pages/phototheque/phototheque_fullscreen_page.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/widget/image_from_path.dart';

/// Page détail d'une galerie Photothèque : titre + nombre d'images dans l'AppBar, grille d'images depuis l'API.
class PhotothequeCategoryPage extends StatefulWidget {
  const PhotothequeCategoryPage({
    super.key,
    required this.galleryId,
    required this.title,
  });

  final int galleryId;
  final String title;

  @override
  State<PhotothequeCategoryPage> createState() =>
      _PhotothequeCategoryPageState();
}

class _PhotothequeCategoryPageState extends State<PhotothequeCategoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GalleriesProvider>().loadGalleryImages(widget.galleryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GalleriesProvider>(
      builder: (context, galleriesProvider, _) {
        final images = galleriesProvider.imagesForGallery(widget.galleryId);
        final loading = galleriesProvider.isLoadingImages(widget.galleryId);
        final total = galleriesProvider.totalImagesForGallery(widget.galleryId);

        return Scaffold(
          backgroundColor: AppColors.bg,
          appBar: AppBar(
            backgroundColor: AppColors.bg,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 22),
              color: AppColors.blackIcon,
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: AppColors.onSurfaceLight,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (total > 0)
                  Text(
                    '$total ${AppStrings.photothequeImagesCount}',
                    style: const TextStyle(
                      color: AppColors.newsDate,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: loading && images.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : images.isEmpty
                    ? const Center(child: Text('Aucune image'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(4),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                          childAspectRatio: 1,
                        ),
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          final img = images[index];
                          final imageUrl = AppAssets.imageOrDefault(img.url);
                          return _PhotoGridTile(
                            imageUrl: imageUrl,
                            cacheKey: 'pt_${img.galleryId}_${img.id}',
                            memCacheSize: 400,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => PhotothequeFullscreenPage(
                                    imagePaths: images
                                        .map((e) => AppAssets.imageOrDefault(e.url))
                                        .toList(),
                                    initialIndex: index,
                                    imageCaptions: images.map((e) => e.name).toList(),
                                    albumTitle: widget.title,
                                    galleryId: widget.galleryId,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        );
      },
    );
  }
}

class _PhotoGridTile extends StatelessWidget {
  const _PhotoGridTile({
    required this.imageUrl,
    this.cacheKey,
    this.memCacheSize,
    required this.onTap,
  });

  final String imageUrl;
  final String? cacheKey;
  final int? memCacheSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: AppBorderRadius.r4,
          child: ImageFromPath(
            path: imageUrl,
            cacheKey: cacheKey,
            memCacheWidth: memCacheSize,
            memCacheHeight: memCacheSize,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}
