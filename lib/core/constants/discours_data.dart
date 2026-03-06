import 'package:sem_dsn/core/constants/app_assets.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';

/// Un item discours (même format que les cartes Campagne : image, gradient, titre, date, option vidéo).
typedef DiscoursOverlayItem = ({
  String image,
  String title,
  String date,
  bool isVideo,
});

/// Sous-catégorie Discours : titre, nombre d'items, liste d'items.
typedef DiscoursSubcategory = ({
  String id,
  String title,
  int count,
  List<DiscoursOverlayItem> items,
});

/// Données en dur pour l'onglet Discours. À remplacer par l'API backend.
const List<DiscoursSubcategory> discoursSubcategories = [
  (
    id: 'politiques',
    title: AppStrings.discoursSubcategoryPolitiques,
    count: 5,
    items: [
      (
        image: AppAssets.news1,
        title:
            "Discours à l'occasion de l'ouverture de la session parlementaire",
        date: '15 Mars 2026',
        isVideo: false,
      ),
      (
        image: AppAssets.news2,
        title: 'Allocution - Cérémonie d\'investiture',
        date: '10 Janvier 2026',
        isVideo: true,
      ),
      (
        image: AppAssets.news3,
        title: 'Discours sur l\'état de la Nation',
        date: '5 Décembre 2025',
        isVideo: false,
      ),
      (
        image: AppAssets.hero1,
        title: 'Message à la jeunesse congolaise',
        date: '12 Novembre 2025',
        isVideo: true,
      ),
      (
        image: AppAssets.alaune1,
        title: 'Intervention au forum économique',
        date: '20 Octobre 2025',
        isVideo: false,
      ),
    ],
  ),
  (
    id: 'international',
    title: AppStrings.discoursSubcategoryInternational,
    count: 3,
    items: [
      (
        image: AppAssets.hero2,
        title: 'Discours à l\'Assemblée générale des Nations unies',
        date: '24 Septembre 2025',
        isVideo: true,
      ),
      (
        image: AppAssets.news1,
        title: 'Sommet UA - Déclaration sur la paix et la sécurité',
        date: '18 Juillet 2025',
        isVideo: false,
      ),
      (
        image: AppAssets.news2,
        title: 'Visite d\'État - Discours commun avec le partenaire',
        date: '3 Juin 2025',
        isVideo: true,
      ),
    ],
  ),
  (
    id: 'autres',
    title: AppStrings.discoursSubcategoryAutres,
    count: 4,
    items: [
      (
        image: AppAssets.news3,
        title: 'Hommage aux anciens combattants',
        date: '11 Novembre 2025',
        isVideo: false,
      ),
      (
        image: AppAssets.alaune1,
        title: 'Inauguration du complexe scolaire',
        date: '8 Octobre 2025',
        isVideo: true,
      ),
      (
        image: AppAssets.hero1,
        title: 'Cérémonie de remise de décorations',
        date: '15 Août 2025',
        isVideo: false,
      ),
      (
        image: AppAssets.alaune2,
        title: 'Discours de clôture du congrès du PCT',
        date: '27 Décembre 2025',
        isVideo: false,
      ),
    ],
  ),
];
