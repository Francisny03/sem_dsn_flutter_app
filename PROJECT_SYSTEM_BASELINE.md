# PROJECT SYSTEM BASELINE - DSN Flutter

Ce document définit les règles de base à respecter pour lancer un nouveau projet a partir de cette app, sans divergence UI/UX.

## 1) Stack et structure de base

- Framework: Flutter (Material)
- Langue UI par défaut: Français
- Organisation minimale:
  - `lib/core/constants/` pour constantes globales (strings, assets, tailles, padding, radius, config)
  - `lib/core/theme/` pour palette et tokens visuels
  - `lib/widget/` pour composants réutilisables (ex: boutons)

## 2) Single source of truth UI tokens

### Couleurs

Toutes les couleurs viennent de `AppColors` (`lib/core/theme/app_colors.dart`).
Interdiction de hardcoder une couleur dans les widgets métier (sauf exception documentée).

Couleurs clés:
- `primaryColor`: `#0C692A`
- `navBottomSelectItem`: `#BF1215`
- `heroSelectionTag` / `activeDotSlider`: `#FFCA00`
- `bg`: `#FFFFFF`
- `blackIcon`: `#121212`
- `grayTextColor`: `#545454`

### Typographie (tailles)

Toutes les tailles de police viennent de `AppFontSizes` (`lib/core/constants/app_font_sizes.dart`).

Exemples:
- `welcomeHeroText`: 40
- `heroTitle`: 25
- `sectionTitle`: 16
- `menuTitle`: 35

### Espacements

Utiliser `AppPadding` (`lib/core/constants/app_padding.dart`) au lieu de valeurs magiques.

Exemples:
- `horizontalPadding16`
- `horizontalPadding20`
- `horizontalPadding28`

### Radius

Utiliser `AppBorderRadius` (`lib/core/constants/app_border_radius.dart`).

Exemples:
- `r8`, `r12`, `r16`, `rtotal`

## 3) Assets

Les assets sont centralisés dans `AppAssets` (`lib/core/constants/app_assets.dart`).
- Ne jamais utiliser des chemins `assets/...` en direct dans les pages.
- Ajouter toute nouvelle ressource dans `AppAssets` + `pubspec.yaml`.
- Utiliser `AppAssets.imageOrDefault(path)` pour fallback image quand backend vide/null.

## 4) Strings / Langue

Toutes les chaines UI passent par `AppStrings` (`lib/core/constants/app_strings.dart`).
- Pas de texte en dur dans les widgets.
- Langue actuelle: Français.
- Si multilingue futur: migrer `AppStrings` vers solution i18n (`arb`/`flutter_localizations`) sans casser les clés existantes.

## 5) Composant bouton standard (obligatoire)

Le bouton principal du design system est `StadiumButton` (`lib/widget/custom_button.dart`).

### API standard

- `value` (label)
- `onPressed`
- `isLoading`
- `isEnabled`
- `type` via `BtnType`:
  - `primary`, `outline`, `secondary`, `danger`, `yellow`, `white`
- surcharge possible: `backgroundColor`, `foregroundColor`

### Règles d'usage

- Toujours préférer `StadiumButton` aux `ElevatedButton/OutlinedButton` custom locaux.
- États a respecter: normal, disabled, loading.
- Coins: `AppBorderRadius.rtotal`.
- Durées animations: ~200ms (cohérent avec composant existant).

## 6) Thème et cohérence visuelle

- Respecter les contrastes existants de `AppColors`.
- Ne pas introduire une nouvelle couleur/radius/font-size sans passer par les fichiers token.
- Toute nouvelle variation UI doit etre ajoutée dans:
  1. `AppColors` / `AppFontSizes` / `AppPadding` / `AppBorderRadius`
  2. puis consommée par les widgets

## 7) Conventions de code

- Constantes partagées => `lib/core/constants/`
- Tokens visuels => `lib/core/theme/`
- Widgets réutilisables => `lib/widget/`
- Nommage:
  - Classes: `PascalCase`
  - fichiers: `snake_case.dart`
- Favoriser `const` partout ou possible.
- Éviter la duplication: extraire composant réutilisable rapidement.

## 8) Checklist avant merge

- [ ] Aucune couleur hardcodée inutile
- [ ] Aucune string UI hardcodée
- [ ] Assets référencés via `AppAssets`
- [ ] Espacements/radius via `AppPadding`/`AppBorderRadius`
- [ ] Boutons importants via `StadiumButton`
- [ ] Lints OK
- [ ] UI cohérente light/dark (si concerné)

## 9) Fichiers de référence (actuels)

- `lib/core/theme/app_colors.dart`
- `lib/core/constants/app_font_sizes.dart`
- `lib/core/constants/app_padding.dart`
- `lib/core/constants/app_border_radius.dart`
- `lib/core/constants/app_assets.dart`
- `lib/core/constants/app_strings.dart`
- `lib/widget/custom_button.dart`
