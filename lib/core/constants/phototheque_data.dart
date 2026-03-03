import 'package:sem_dsn/core/constants/app_assets.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';

const List<({String image, String title, int count})> photothequeCategories = [
  (
    image: AppAssets.hero1,
    title: AppStrings.photothequeCategoryElections,
    count: 41,
  ),
  (
    image: AppAssets.news1,
    title: AppStrings.photothequeCategoryArmee,
    count: 20,
  ),
  (image: AppAssets.news2, title: AppStrings.photothequeCategoryPct, count: 41),
  (
    image: AppAssets.alaune1,
    title: AppStrings.photothequeCategoryFamille,
    count: 20,
  ),
  (
    image: AppAssets.news3,
    title: AppStrings.photothequeCategoryInternational,
    count: 41,
  ),
  (
    image: AppAssets.hero2,
    title: AppStrings.photothequeCategoryMrMmeDsn,
    count: 20,
  ),
];

/// Liste d'images pour la grille d'une catégorie (placeholder : mêmes assets pour toutes les catégories).
const List<String> photothequeCategoryImagePaths = [
  AppAssets.hero1,
  AppAssets.hero2,
  AppAssets.news1,
  AppAssets.news2,
  AppAssets.news3,
  AppAssets.alaune1,
  AppAssets.alaune2,
  AppAssets.hero1,
  AppAssets.news1,
  AppAssets.hero2,
  AppAssets.news2,
  AppAssets.news3,
];
