import 'package:sem_dsn/core/constants/app_assets.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';

/// Article searchable par titre, description, date.
class SearchableArticle {
  const SearchableArticle({
    required this.title,
    required this.date,
    required this.description,
    required this.imagePath,
    required this.tag,
    this.isVideo = false,
    this.isHeroOrFeatured = false,
  });

  final String title;
  final String date;
  final String description;
  final String imagePath;
  final String tag;
  final bool isVideo;
  final bool isHeroOrFeatured;

  /// Texte dans lequel chercher (titre + description + date).
  String get searchableText => '$title $description $date'.toLowerCase();
}

/// Liste d’articles pour la recherche (agrégat hero, à la une, presse, campagne, réalisations, etc.).
final List<SearchableArticle> searchableArticles = [
  SearchableArticle(
    title: AppStrings.heroTitle1,
    date: AppStrings.heroDate1,
    description: AppStrings.articleBodySample,
    imagePath: AppAssets.hero1,
    tag: AppStrings.news,
    isHeroOrFeatured: true,
  ),
  SearchableArticle(
    title: AppStrings.heroTitle2,
    date: AppStrings.heroDate2,
    description: AppStrings.articleBodySample,
    imagePath: AppAssets.hero2,
    tag: AppStrings.news,
    isHeroOrFeatured: true,
  ),
  SearchableArticle(
    title: AppStrings.heroTitle3,
    date: AppStrings.heroDate3,
    description: AppStrings.articleBodySample,
    imagePath: AppAssets.alaune1,
    tag: AppStrings.news,
    isHeroOrFeatured: true,
  ),
  SearchableArticle(
    title: AppStrings.heroTitle4,
    date: AppStrings.heroDate4,
    description: AppStrings.articleBodySample,
    imagePath: AppAssets.news1,
    tag: AppStrings.news,
    isHeroOrFeatured: true,
  ),
  SearchableArticle(
    title: AppStrings.heroTitle5,
    date: AppStrings.heroDate5,
    description: AppStrings.articleBodySample,
    imagePath: AppAssets.news2,
    tag: AppStrings.news,
    isHeroOrFeatured: true,
  ),
  SearchableArticle(
    title: AppStrings.featuredTitle1,
    date: AppStrings.featuredDate1,
    description: AppStrings.articleBodySample,
    imagePath: AppAssets.alaune1,
    tag: AppStrings.news,
    isHeroOrFeatured: true,
  ),
  SearchableArticle(
    title: AppStrings.featuredTitle2,
    date: AppStrings.featuredDate2,
    description: AppStrings.articleBodySample,
    imagePath: AppAssets.alaune2,
    tag: AppStrings.news,
    isHeroOrFeatured: true,
  ),
  SearchableArticle(
    title:
        'Le président Denis Sassou-Nguesso a été reçu jeudi à Beijing en Chine',
    date: '04 Septembre 2025',
    description: AppStrings.articleBodySample,
    imagePath: AppAssets.news1,
    tag: AppStrings.news,
  ),
  SearchableArticle(
    title: 'Chine : Denis Sassou-Nguesso reçu par Vladimir Poutine à Pékin',
    date: '04 Septembre 2025',
    description: AppStrings.articleBodySample,
    imagePath: AppAssets.news2,
    tag: AppStrings.news,
  ),
  SearchableArticle(
    title: "France - Congo : Macron reçoit Denis Sassou N'Guesso à l'Élysée",
    date: '04 Septembre 2025',
    description: AppStrings.articleBodySample,
    imagePath: AppAssets.news3,
    tag: AppStrings.news,
  ),
  SearchableArticle(
    title: AppStrings.campaignCard1Title,
    date: AppStrings.campaignCard1Date,
    description: AppStrings.articleBodySample,
    imagePath: AppAssets.news1,
    tag: AppStrings.campaign,
    isVideo: false,
  ),
  SearchableArticle(
    title: AppStrings.campaignCard2Title,
    date: AppStrings.campaignCard2Date,
    description: AppStrings.articleBodySample,
    imagePath: AppAssets.news2,
    tag: AppStrings.campaign,
    isVideo: true,
  ),
  SearchableArticle(
    title: AppStrings.campaignCard3Title,
    date: AppStrings.campaignCard3Date,
    description: AppStrings.articleBodySample,
    imagePath: AppAssets.news3,
    tag: AppStrings.campaign,
    isVideo: true,
  ),
  SearchableArticle(
    title: AppStrings.achievement1Title,
    date: AppStrings.achievement1Date,
    description: AppStrings.articleBodySample,
    imagePath: AppAssets.alaune1,
    tag: AppStrings.achievements,
  ),
  SearchableArticle(
    title: AppStrings.achievement2Title,
    date: AppStrings.achievement2Date,
    description: AppStrings.articleBodySample,
    imagePath: AppAssets.alaune2,
    tag: AppStrings.achievements,
  ),
  SearchableArticle(
    title: AppStrings.achievement3Title,
    date: AppStrings.achievement3Date,
    description: AppStrings.articleBodySample,
    imagePath: AppAssets.alaune1,
    tag: AppStrings.achievements,
  ),
  SearchableArticle(
    title: AppStrings.project1Title,
    date: '',
    description: AppStrings.articleBodySample,
    imagePath: AppAssets.alaune1,
    tag: AppStrings.projects,
  ),
  SearchableArticle(
    title: AppStrings.project2Title,
    date: '',
    description: AppStrings.articleBodySample,
    imagePath: AppAssets.alaune2,
    tag: AppStrings.projects,
  ),
  SearchableArticle(
    title: AppStrings.project3Title,
    date: '',
    description: AppStrings.articleBodySample,
    imagePath: AppAssets.alaune1,
    tag: AppStrings.projects,
  ),
];
