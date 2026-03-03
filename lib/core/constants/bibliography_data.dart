import 'package:sem_dsn/core/constants/app_assets.dart';

/// Entrée livre (image, titre, résumé, année).
typedef BibliographyBook = ({
  String image,
  String title,
  String description,
  String year,
});

/// Entrée revue de presse (image, titre, résumé, date).
typedef BibliographyReview = ({
  String image,
  String title,
  String description,
  String date,
});

const List<BibliographyBook> bibliographyBooks = [
  (
    image: AppAssets.biblio1,
    title: "Le manguier, le fleuve et la souris",
    description:
        "Ouvrage de réflexion et de témoignage sur les réalités africaines et les enjeux du développement.",
    year: "1997",
  ),
  (
    image: AppAssets.biblio2,
    title: "Parler vrai pour l'Afrique",
    description:
        "Discours et prises de position sur la politique africaine et les relations internationales.",
    year: "2009",
  ),
  (
    image: AppAssets.biblio3,
    title: "Gondwana : Le potager de Grand-mère Campagne",
    description: "Récit et réflexions autour de l'histoire et des traditions.",
    year: "2010",
  ),
  (
    image: AppAssets.biblio4,
    title: "Stratégie politique et repères essentiels",
    description:
        "Analyse des orientations politiques et des fondamentaux du projet de société.",
    year: "2013",
  ),
  (
    image: AppAssets.biblio5,
    title: "Africa: A global stake",
    description: "Vision et plaidoyer pour l'Afrique dans les enjeux mondiaux.",
    year: "2013",
  ),
];

const List<BibliographyReview> bibliographyReviews = [
  (
    image: AppAssets.revue1,
    title: "Nouvelle candidature",
    description:
        "Couverture médiatique et réactions à l'annonce de la candidature.",
    date: "2006",
  ),
  (
    image: AppAssets.revue2,
    title: "Rencontre Internationale",
    description:
        "Compte-rendu de la rencontre et des échanges avec les partenaires.",
    date: "Avril 2023",
  ),
  (
    image: AppAssets.revue3,
    title: "Visite officielle",
    description:
        "Revue de presse de la visite et des déclarations officielles.",
    date: "2023",
  ),
];
