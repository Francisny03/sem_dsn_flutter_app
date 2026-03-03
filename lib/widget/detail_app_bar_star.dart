import 'package:flutter/material.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/core/animation/selection_star_animation.dart';

/// Étoile de sélection dans l'AppBar de la page détail (favoris).
class DetailAppBarStar extends StatelessWidget {
  const DetailAppBarStar({
    super.key,
    required this.isSelected,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedSelectionStar(
      isSelected: isSelected,
      onTap: onTap,
      selectedColor: AppColors.heroSelectionTag,
      unselectedColor: iconColor,
      size: 22,
    );
  }
}
