import 'package:flutter/foundation.dart';

import 'package:sem_dsn/models/gallery.dart';
import 'package:sem_dsn/models/gallery_image.dart';
import 'package:sem_dsn/services/galleries_api.dart';

/// Provider des galeries (photothèque) et des images par galerie.
class GalleriesProvider extends ChangeNotifier {
  List<Gallery> _galleries = [];
  bool _loading = false;
  bool _loadFailed = false;
  final Map<int, List<GalleryImage>> _imagesByGalleryId = {};
  final Map<int, bool> _loadingImages = {};
  final Map<int, bool> _loadFailedImages = {};
  final Map<int, int> _totalByGalleryId = {};

  List<Gallery> get galleries => _galleries;
  bool get loading => _loading;
  bool get loadFailed => _loadFailed;

  List<GalleryImage> imagesForGallery(int galleryId) =>
      _imagesByGalleryId[galleryId] ?? [];
  bool isLoadingImages(int galleryId) => _loadingImages[galleryId] ?? false;
  bool isLoadFailedImages(int galleryId) =>
      _loadFailedImages[galleryId] ?? false;
  int totalImagesForGallery(int galleryId) => _totalByGalleryId[galleryId] ?? 0;

  Future<void> loadIfNeeded() async {
    if (_loading || _galleries.isNotEmpty) return;
    await loadGalleries();
  }

  Future<void> loadGalleries() async {
    _loading = true;
    _loadFailed = false;
    notifyListeners();
    try {
      final res = await fetchGalleries();
      _galleries = res.results;
      _loading = false;
      notifyListeners();
      // Précharger le nombre d'images de chaque galerie en arrière-plan pour afficher les counts sur la liste sans ouvrir chaque galerie.
      for (final g in _galleries) {
        loadGalleryImages(g.id);
      }
    } catch (_) {
      _galleries = [];
      _loadFailed = true;
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadGalleryImages(int galleryId) async {
    if (_loadingImages[galleryId] == true) return;
    _loadingImages[galleryId] = true;
    _loadFailedImages[galleryId] = false;
    notifyListeners();
    try {
      final res = await fetchGalleryImages(galleryId);
      final list = res.results;
      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      _imagesByGalleryId[galleryId] = list;
      _totalByGalleryId[galleryId] = res.total;
    } catch (_) {
      // Ne pas vider le cache : si l'utilisateur était déjà chargé,
      // on conserve l'affichage et on affiche un message de non-connexion.
      _loadFailedImages[galleryId] = true;
    } finally {
      _loadingImages[galleryId] = false;
      notifyListeners();
    }
  }
}
