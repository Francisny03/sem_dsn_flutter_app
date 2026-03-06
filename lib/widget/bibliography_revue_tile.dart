import 'package:flutter/material.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/core/constants/app_border_radius.dart';

/// Tuile pour une revue de presse dans la section Bibliographie : miniature, titre, résumé, date, bouton "Lire plus".
/// Si [onTap] est fourni, tout le container est cliquable (même action que le bouton).
class BibliographyRevueTile extends StatelessWidget {
  const BibliographyRevueTile({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.date,
    this.onTap,
    this.onLirePlus,
  });

  final String imagePath;
  final String title;
  final String description;
  final String date;

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
          width: 100,
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
              width: 100,
              height: 140,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 100,
                height: 140,
                color: AppColors.filterUnselected,
                child: const Icon(Icons.newspaper),
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
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Text(
                  //   date,
                  //   style: const TextStyle(
                  //     color: AppColors.newsDate,
                  //     fontSize: 12,
                  //   ),
                  // ),
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
            ],
          ),
        ),
      ],
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
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
