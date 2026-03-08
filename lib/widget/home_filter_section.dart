import 'package:flutter/material.dart';
import 'package:sem_dsn/core/constants/app_border_radius.dart';
import 'package:sem_dsn/core/constants/app_font_sizes.dart';
import 'package:sem_dsn/core/constants/app_padding.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/models/category.dart';
import 'package:sem_dsn/widget/netflix_loading_placeholder.dart';
import 'package:sem_dsn/widget/netflix_shimmer.dart';

class HomeFilterSection extends StatelessWidget {
  const HomeFilterSection({
    super.key,
    required this.parentCategories,
    this.loading = false,
    required this.selectedIndex,
    required this.onSelected,
    this.onRetry,
  });

  /// Catégories parentes (racines) — affichées comme onglets, libellé = [Category.name].
  final List<Category> parentCategories;
  final bool loading;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (loading && parentCategories.isEmpty) {
      return NetflixShimmer(
        child: NetflixLoadingPlaceholder(
          height: 40,
          borderRadius: AppBorderRadius.rtotal,
        ),
      );
    }
    if (parentCategories.isEmpty) {
      return SizedBox(
        height: 40,
        child: Center(
          child: Padding(
            padding: AppPadding.horizontalPadding10,
            child: TextButton(
              onPressed: onRetry,
              child: const Text('Réessayer'),
            ),
          ),
        ),
      );
    }
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: AppPadding.horizontalPadding10,
        itemCount: parentCategories.length,
        itemBuilder: (context, index) {
          final cat = parentCategories[index];
          final isSelected = index == selectedIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelected(index),
                borderRadius: AppBorderRadius.rtotal,
                child: Container(
                  padding: AppPadding.horizontalPadding20,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryColor
                        : AppColors.filterUnselected,
                    borderRadius: AppBorderRadius.rtotal,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    cat.name,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.filterSelectedTextColor
                          : AppColors.filterUnselectedTextColor,
                      fontWeight: FontWeight.w600,
                      fontSize: AppFontSizes.filterTitle,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
