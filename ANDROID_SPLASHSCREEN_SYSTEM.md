# Android Native Splashscreen System (DSN)

Ce fichier décrit la méthode officielle pour changer le splashscreen Android natif dans ce projet.
But: garantir le meme comportement visuel pour tous les devs.

## Portée

- Android natif avant affichage Flutter (cold start)
- API 31+ (Android 12+) via `windowSplashScreen*`
- API <31 via thème de lancement classique

## Fichiers source a maintenir

- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/res/values/styles.xml`
- `android/app/src/main/res/values-v31/styles.xml`
- `android/app/src/main/res/values-night/styles.xml`
- `android/app/src/main/res/values-night-v31/styles.xml`
- `android/app/src/main/res/drawable/launch_background.xml`
- `android/app/src/main/res/drawable-v21/launch_background.xml`
- `android/app/src/main/res/values/colors.xml` (si absent, le créer)
- `android/app/src/main/res/drawable/ic_splash_transparent.xml` (API 31+)

## Règles obligatoires

1. `MainActivity` doit garder `android:theme="@style/LaunchTheme"` dans `AndroidManifest.xml`.
2. `LaunchTheme` existe dans `values/styles.xml` et `values-v31/styles.xml`.
3. Couleur de fond unique dans `@color/splash_background`.
4. Pour Android 12+, utiliser `android:windowSplashScreenAnimatedIcon` avec un drawable transparent/bien centré.
5. Ne pas mettre de logique Flutter pour "imiter" le splash natif Android.

## Configuration recommandée

### 1) Manifest

Dans `android/app/src/main/AndroidManifest.xml`, conserver:

```xml
<activity
    android:name=".MainActivity"
    android:theme="@style/LaunchTheme"
    ...>
```

### 2) Theme API <31

Dans `android/app/src/main/res/values/styles.xml`:

```xml
<style name="LaunchTheme" parent="Theme.SplashScreen.IconBackground">
    <item name="windowSplashScreenBackground">@color/splash_background</item>
    <item name="windowSplashScreenIconBackgroundColor">@color/splash_background</item>
</style>
```

### 3) Theme API 31+

Dans `android/app/src/main/res/values-v31/styles.xml`:

```xml
<style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">
    <item name="android:windowSplashScreenBackground">@color/splash_background</item>
    <item name="android:windowSplashScreenAnimatedIcon">@drawable/ic_splash_transparent</item>
    <item name="android:windowSplashScreenIconBackgroundColor">@color/splash_background</item>
</style>
```

### 4) Couleur

Dans `android/app/src/main/res/values/colors.xml`:

```xml
<resources>
    <color name="splash_background">#0C692A</color>
</resources>
```

Adapter la valeur selon la DA, mais garder une seule source `splash_background`.

### 5) Drawable de fallback (<31)

Dans `android/app/src/main/res/drawable/launch_background.xml` et `drawable-v21/launch_background.xml`:

```xml
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@color/splash_background" />
</layer-list>
```

Si un logo centré est requis pour <31, ajouter un second `<item>` bitmap/vector centré.

### 6) Icone Android 12+

Créer/maintenir `android/app/src/main/res/drawable/ic_splash_transparent.xml`
avec un drawable qui évite un rendu carré agressif (padding/transparent), compatible `windowSplashScreenAnimatedIcon`.

## Procédure de changement du splash

1. Remplacer la couleur dans `@color/splash_background`.
2. Mettre a jour `ic_splash_transparent.xml` (si changement logo).
3. Vérifier `styles.xml` + `values-v31/styles.xml`.
4. Vérifier les variantes `values-night*` pour cohérence dark mode.
5. Lancer:
   - `flutter clean`
   - `flutter pub get`
   - `flutter run`
6. Tester sur:
   - un device Android 12+ (API 31+)
   - un device Android 10/11 (<31)

## Checklist QA rapide

- [ ] Pas de flash blanc avant Flutter
- [ ] Fond splash cohérent avec la marque
- [ ] Logo bien centré, non tronqué
- [ ] Rendu identique en portrait/paysage
- [ ] Comportement correct en dark mode (si configuré)

## Notes projet DSN

- Le projet utilise déjà `LaunchTheme` dans `AndroidManifest.xml`.
- Le projet a déjà des dossiers `values`, `values-v31`, `values-night`, `values-night-v31`.
- La méthode de référence reste cette base pour éviter toute divergence entre devs.
