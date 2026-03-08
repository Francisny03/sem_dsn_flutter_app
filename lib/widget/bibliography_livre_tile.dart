import 'package:flutter/material.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/core/constants/app_border_radius.dart';
import 'package:sem_dsn/widget/image_from_path.dart';

/// Tuile pour un livre dans la section Bibliographie : couverture, titre, résumé (optionnel), année, bouton "Lire plus".
/// Si [onTap] est fourni, tout le container est cliquable (même action que le bouton).
class BibliographyLivreTile extends StatelessWidget {
  const BibliographyLivreTile({
    super.key,
    required this.imagePath,
    required this.title,
    this.description = '',
    this.year = '',
    this.onTap,
    this.onLirePlus,
  });

  final String imagePath;
  final String title;
  final String description;
  final String year;

  /// Tap sur tout le container (prioritaire ; le bouton "Lire plus" appelle aussi [onTap] si présent).
  final VoidCallback? onTap;
  final VoidCallback? onLirePlus;

  VoidCallback? get _effectiveOnLirePlus => onTap ?? onLirePlus;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 150,
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
            child: ImageFromPath(
              path: imagePath,
              width: 120,
              height: 150,
              fit: BoxFit.cover,
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.grayTextColor,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 6),
              Text(
                year,
                style: const TextStyle(color: AppColors.newsDate, fontSize: 12),
              ),
              const SizedBox(height: 16),
              if (_effectiveOnLirePlus != null)
                TextButton(
                  onPressed: _effectiveOnLirePlus,
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
        ),
      ],
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: onTap != null
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: AppBorderRadius.r8,
                child: content,
              ),
            )
          : content,
    );
  }
}
