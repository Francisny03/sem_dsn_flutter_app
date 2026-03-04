import 'package:flutter/material.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/core/constants/app_border_radius.dart';

/// Tuile pour un livre dans la section Bibliographie : couverture, titre, résumé, année, bouton "Lire plus".
class BibliographyLivreTile extends StatelessWidget {
  const BibliographyLivreTile({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.year,
    this.onLirePlus,
  });

  final String imagePath;
  final String title;
  final String description;
  final String year;
  final VoidCallback? onLirePlus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: AppBorderRadius.r8,
              border: Border.all(
                width: 1,
                color: AppColors.bibliographyBorderColor,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: ClipRRect(
              borderRadius: AppBorderRadius.r8,
              child: Image.asset(
                imagePath,
                width: 120,
                height: 140,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 100,
                  height: 140,
                  color: AppColors.filterUnselected,
                  child: const Icon(Icons.menu_book),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.newsTitle,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.grayTextColor,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      year,
                      style: const TextStyle(
                        color: AppColors.newsDate,
                        fontSize: 12,
                      ),
                    ),
                    if (onLirePlus != null)
                      TextButton(
                        onPressed: onLirePlus,
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: AppColors.whiteTextColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppBorderRadius.rtotal,
                          ),
                        ),
                        child: Text(
                          AppStrings.bibButtonLirePlus,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
