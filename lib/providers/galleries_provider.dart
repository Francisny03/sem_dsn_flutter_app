import 'package:flutter/foundation.dart';

import 'package:sem_dsn/models/gallery.dart';
import 'package:sem_dsn/models/gallery_image.dart';
import 'package:sem_dsn/services/galleries_api.dart';

/// Provider des galeries (photothèque) et des images par galerie.
class GalleriesProvider extends ChangeNotifier {
  List<Gallery> _galleries = [];
  bool _loading = false;
  final Map<int, List<GalleryImage>> _imagesByGalleryId = {};
  final Map<int, bool> _loadingImages = {};
  final Map<int, int> _totalByGalleryId = {};

  List<Gallery> get galleries => _galleries;
  bool get loading => _loading;

  List<GalleryImage> imagesForGallery(int galleryId) =>
      _imagesByGalleryId[galleryId] ?? [];
  bool isLoadingImages(int galleryId) => _loadingImages[galleryId] ?? false;
  int totalImagesForGallery(int galleryId) => _totalByGalleryId[galleryId] ?? 0;

  Future<void> loadIfNeeded() async {
    if (_loading || _galleries.isNotEmpty) return;
    await loadGalleries();
  }

  Future<void> loadGalleries() async {
    _loading = true;
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
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadGalleryImages(int galleryId) async {
    if (_loadingImages[galleryId] == true) return;
    _loadingImages[galleryId] = true;
    notifyListeners();
    try {
      final res = await fetchGalleryImages(galleryId);
      _imagesByGalleryId[galleryId] = res.results;
      _totalByGalleryId[galleryId] = res.total;
    } catch (_) {
      _imagesByGalleryId[galleryId] = [];
      _totalByGalleryId[galleryId] = 0;
    } finally {
      _loadingImages[galleryId] = false;
      notifyListeners();
    }
  }
}
