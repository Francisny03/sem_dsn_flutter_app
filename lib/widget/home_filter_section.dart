import 'package:flutter/material.dart';
import 'package:sem_dsn/core/constants/app_border_radius.dart';
import 'package:sem_dsn/core/constants/app_font_sizes.dart';
import 'package:sem_dsn/core/constants/app_padding.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';

class HomeFilterSection extends StatelessWidget {
  const HomeFilterSection({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const List<String> _filters = [
    AppStrings.news,
    AppStrings.campaign,
    AppStrings.achievements,
    AppStrings.speeches,
    AppStrings.projects,
    AppStrings.interviews,
    AppStrings.archives,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: AppPadding.horizontalPadding10,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
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
                    _filters[index],
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
