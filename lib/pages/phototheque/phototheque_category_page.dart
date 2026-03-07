import 'package:flutter/material.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/core/constants/app_border_radius.dart';
import 'package:sem_dsn/pages/phototheque/phototheque_fullscreen_page.dart';

/// Page détail d'une catégorie Photothèque : titre dans l'AppBar + grille d'images.
class PhotothequeCategoryPage extends StatelessWidget {
  const PhotothequeCategoryPage({
    super.key,
    required this.title,
    required this.imagePaths,
    this.imageCaptions,
  });

  final String title;
  final List<String> imagePaths;

  /// Légendes pour chaque image (même ordre que [imagePaths]).
  final List<String>? imageCaptions;

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.onSurfaceLight,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(4),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 1,
          ),
          itemCount: imagePaths.length,
          itemBuilder: (context, index) {
            return _PhotoGridTile(
              imagePath: imagePaths[index],
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PhotothequeFullscreenPage(
                      imagePaths: imagePaths,
                      initialIndex: index,
                      imageCaptions: imageCaptions,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _PhotoGridTile extends StatelessWidget {
  const _PhotoGridTile({required this.imagePath, required this.onTap});

  final String imagePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: AppBorderRadius.r4,
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.filterUnselected,
              child: const Icon(Icons.image_not_supported),
            ),
          ),
        ),
      ),
    );
  }
}
