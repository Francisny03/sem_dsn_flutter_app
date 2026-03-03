import 'package:flutter/material.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/core/constants/app_border_radius.dart';

enum BtnType { primary, outline, secondary, danger, yellow, white }

/// Bouton type Stadium (coins très arrondis) avec types de couleurs, chargement et ombre.
/// Couleurs basées sur [AppColors]. Tu peux aussi passer [backgroundColor] / [foregroundColor] pour personnaliser.
class StadiumButton extends StatelessWidget {
  const StadiumButton({
    super.key,
    required this.value,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.type = BtnType.primary,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String value;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final BtnType type;

  /// Couleur de fond personnalisée (optionnel, sinon selon [type])
  final Color? backgroundColor;

  /// Couleur du texte personnalisée (optionnel, sinon selon [type])
  final Color? foregroundColor;

  bool get _effectiveEnabled => isEnabled && !isLoading && onPressed != null;

  (Color bg, Color fg, Color shadow) _colors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (type) {
      case BtnType.primary:
        return (
          AppColors.primaryColor,
          isDark
              ? AppColors.textPrimaryButtonDark
              : AppColors.textPrimaryButtonLight,
          AppColors.primaryColor,
        );
      case BtnType.outline:
        return (
          Colors.transparent,
          isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
          isDark ? AppColors.outlineDark : AppColors.outlineLight,
        );
      case BtnType.secondary:
        return (
          isDark ? AppColors.secondaryDark : AppColors.secondaryLight,
          isDark ? AppColors.onSecondaryDark : AppColors.onSecondaryLight,
          isDark ? AppColors.secondaryDark : AppColors.secondaryLight,
        );
      case BtnType.danger:
        return (
          isDark ? AppColors.dangerDark : AppColors.dangerLight,
          isDark ? AppColors.onDangerDark : AppColors.onDangerLight,
          isDark ? AppColors.dangerDark : AppColors.dangerLight,
        );
      case BtnType.yellow:
        return (
          isDark ? AppColors.yellowDark : AppColors.yellowLight,
          isDark ? AppColors.onYellowDark : AppColors.onYellowLight,
          isDark ? AppColors.yellowDark : AppColors.yellowLight,
        );
      case BtnType.white:
        return (
          AppColors.whiteButtonBg,
          AppColors.onWhiteButton,
          AppColors.grayTextColor,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final (defaultBg, defaultFg, shadowColor) = _colors(context);
    final isOutline = type == BtnType.outline;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final disabledBg = isDark ? AppColors.outlineDark : AppColors.outlineLight;

    final effectiveBg =
        backgroundColor ??
        (_effectiveEnabled ? defaultBg : (isOutline ? defaultBg : disabledBg));
    final effectiveFg = foregroundColor ?? defaultFg;

    return Container(
      decoration: BoxDecoration(
        boxShadow: _effectiveEnabled
            ? [
                BoxShadow(
                  color: shadowColor.withValues(alpha: 0.45),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _effectiveEnabled ? onPressed : null,
          borderRadius: AppBorderRadius.rtotal,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: isOutline ? null : effectiveBg,
              border: isOutline
                  ? Border.all(
                      color: isDark
                          ? AppColors.outlineDark
                          : AppColors.outlineLight,
                      width: 2,
                    )
                  : null,
              borderRadius: AppBorderRadius.rtotal,
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isLoading
                    ? SizedBox(
                        key: const ValueKey('loading'),
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            effectiveFg,
                          ),
                        ),
                      )
                    : Text(
                        key: const ValueKey('text'),
                        value,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: effectiveFg,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
