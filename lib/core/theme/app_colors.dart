import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primaryColor = Color(0xFF0C692A);
  static const Color bg = Color(0xFFFFFFFF);
  static const Color sectionTitle = Color(0xFF464646);
  static const Color whiteTextColor = Color(0xFFFFFFFF);
  static const Color grayTextColor = Color(0xFF545454);
  static const Color newsTitle = Color(0xFF2C2C2C);
  static const Color newsDate = Color(0xFF6B6B6B);
  static const Color filterUnselected = Color(0xFFF7F7F9);
  static const Color filterUnselectedTextColor = Color(0xFF545454);
  static const Color filterSelectedTextColor = Color(0xFFFFFFFF);
  static const Color heroSelectionTag = Color(0xFFFFCA00);
  static const Color activeDotSlider = Color(0xFFFFCA00);
  static const Color heroTag = Color(0xFFD2A700);
  static const Color flagColor1 = Color(0xFF00A936);
  static const Color flagColor2 = Color(0xFFFFCA00);
  static const Color flagColor3 = Color(0xFFBF1215);

  static const LinearGradient gradientHero = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x000C692A), Color(0xFF0C692A)],
  );

  static const LinearGradient gradientFeatured = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00000000), Color(0xFF000000)],
  );

  static const Color navBottomUnselect = Color(0xFF545454);
  static const Color navBottomSelectItem = Color(0xFFBF1215);
  static const Color blackIcon = Color(0xFF121212);

  // StadiumButton types (light theme)
  static const Color textPrimaryButtonLight = Color(0xFFFFFFFF);
  static const Color textPrimaryButtonDark = Color(0xFFFFFFFF);
  static const Color onSurfaceLight = Color(0xFF121212);
  static const Color onSurfaceDark = Color(0xFFFFFFFF);
  static const Color outlineLight = Color(0xFF545454);
  static const Color outlineDark = Color(0xFF545454);
  static const Color secondaryLight = Color(0xFFF7F7F9);
  static const Color secondaryDark = Color(0xFF464646);
  static const Color onSecondaryLight = Color(0xFF121212);
  static const Color onSecondaryDark = Color(0xFFFFFFFF);
  static const Color dangerLight = Color(0xFFBF1215);
  static const Color dangerDark = Color(0xFFBF1215);
  static const Color onDangerLight = Color(0xFFFFFFFF);
  static const Color onDangerDark = Color(0xFFFFFFFF);
  static const Color yellowLight = Color(0xFFFFCA00);
  static const Color yellowDark = Color(0xFFFFCA00);
  static const Color onYellowLight = Color(0xFF121212);
  static const Color onYellowDark = Color(0xFF121212);
  // Bouton blanc (ex: Continuer sur welcome)
  static const Color whiteButtonBg = Color(0xFFFFFFFF);
  static const Color onWhiteButton = Color(0xFF121212);

  /// Bordure des couvertures livre / revue dans la Bibliographie (#2B271B).
  static const Color bibliographyBorderColor = Color(0xFF2B271B);
}
