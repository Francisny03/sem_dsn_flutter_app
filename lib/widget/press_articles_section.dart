import 'package:flutter/material.dart';
import 'package:sem_dsn/core/constants/app_assets.dart';
import 'package:sem_dsn/core/constants/app_border_radius.dart';
import 'package:sem_dsn/core/constants/app_font_sizes.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/core/animation/selection_star_animation.dart';

/// Section "Press Articles" : liste verticale d'articles (image + titre + date + favori).
class PressArticlesSection extends StatelessWidget {
  const PressArticlesSection({super.key, this.onArticleTap});

  final void Function(String title, String date, String imagePath)?
  onArticleTap;

  static const List<({String image, String title, String date})> _articles = [
    (
      image: AppAssets.news1,
      title:
          'Le président Denis Sassou-Nguesso a été reçu jeudi à Beijing en Chine',
      date: '04 Septembre 2025',
    ),
    (
      image: AppAssets.news2,
      title: 'Chine : Denis Sassou-Nguesso reçu par Vladimir Poutine à Pékin',
      date: '04 Septembre 2025',
    ),
    (
      image: AppAssets.news3,
      title:
          'France - Congo : Macron reçoit Denis Sassou N\'Guesso à l\'Élysée',
      date: '04 Septembre 2025',
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
            AppStrings.sectionTitlePressArticles,
            style: TextStyle(
              color: AppColors.sectionTitle,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _articles.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final article = _articles[index];
            return _PressArticleTile(
              imagePath: article.image,
              title: article.title,
              date: article.date,
              onTap: onArticleTap != null
                  ? () => onArticleTap!(
                      article.title,
                      article.date,
                      article.image,
                    )
                  : null,
            );
          },
        ),
      ],
    );
  }
}

class _PressArticleTile extends StatefulWidget {
  const _PressArticleTile({
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
  State<_PressArticleTile> createState() => _PressArticleTileState();
}

class _PressArticleTileState extends State<_PressArticleTile> {
  bool _isStarSelected = false;

  void _onStarTap() {
    setState(() => _isStarSelected = !_isStarSelected);
    if (_isStarSelected) {
      // TODO: ajouter l'article à la sélection
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: AppBorderRadius.r10,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: AppBorderRadius.r10,
                child: Image.asset(
                  widget.imagePath,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 90,
                    height: 90,
                    color: AppColors.filterUnselected,
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: AppColors.newsTitle,
                        fontSize: AppFontSizes.pressArticleTitle,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.date,
                          style: const TextStyle(
                            color: AppColors.newsDate,
                            fontSize: AppFontSizes.pressArticleDate,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: AnimatedSelectionStar(
                            isSelected: _isStarSelected,
                            onTap: _onStarTap,
                            selectedColor: AppColors.heroSelectionTag,
                            unselectedColor: AppColors.grayTextColor,
                            size: 24,
                          ),
                        ),
                      ],
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
