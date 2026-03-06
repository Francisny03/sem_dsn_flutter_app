import 'package:flutter/material.dart';
import 'package:sem_dsn/core/constants/app_border_radius.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';

/// Carte sous-catégorie Discours (grille type Photothèque) : image, titre, nombre d'items.
class CardDiscoursSubcategory extends StatelessWidget {
  const CardDiscoursSubcategory({
    super.key,
    required this.imagePath,
    required this.title,
    required this.count,
    required this.onTap,
  });

  final String imagePath;
  final String title;
  final int count;
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
                  errorBuilder: (context, error, stackTrace) => Container(
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 0),
            Text(
              '$count ${AppStrings.discoursCountLabel}',
              style: const TextStyle(color: AppColors.newsDate, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
