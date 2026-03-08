import 'package:flutter/material.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';

/// Placeholder style Netflix (fond sombre + gradient + indicateur) pour filtres, sections, etc.
class NetflixLoadingPlaceholder extends StatelessWidget {
  const NetflixLoadingPlaceholder({
    super.key,
    required this.height,
    this.width,
    this.borderRadius,
  });

  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1F1F1F),
            Color(0xFF2D2D2D),
            Color(0xFF0D0D0D),
          ],
        ),
      ),
      child: const Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.heroSelectionTag),
          ),
        ),
      ),
    );
  }
}
