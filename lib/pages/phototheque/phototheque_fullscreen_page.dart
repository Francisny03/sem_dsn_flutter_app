import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/models/gallery.dart';
import 'package:sem_dsn/providers/galleries_provider.dart';
import 'package:sem_dsn/widget/image_from_path.dart';

/// Page plein écran pour afficher une image de la photothèque.
/// Défilement horizontal entre les images ; barre du haut : bouton fermer, titre album au centre, compteur vu/total à droite.
class PhotothequeFullscreenPage extends StatefulWidget {
  const PhotothequeFullscreenPage({
    super.key,
    required this.imagePaths,
    this.initialIndex = 0,
    this.imageCaptions,
    this.albumTitle,
    this.galleryId,
  });

  final List<String> imagePaths;
  final int initialIndex;

  /// Légende par image (même ordre que [imagePaths]). Affichée sous l'image si non vide.
  final List<String>? imageCaptions;

  /// Titre de l'album / catégorie affiché au centre de la barre du haut.
  final String? albumTitle;

  /// ID de la galerie : si [albumTitle] est vide, le nom est récupéré depuis le provider.
  final int? galleryId;

  @override
  State<PhotothequeFullscreenPage> createState() =>
      _PhotothequeFullscreenPageState();
}

class _PhotothequeFullscreenPageState extends State<PhotothequeFullscreenPage> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _effectiveTitle(BuildContext context) {
    final fromWidget = widget.albumTitle?.trim() ?? '';
    if (fromWidget.isNotEmpty) return fromWidget;
    final galleryId = widget.galleryId;
    if (galleryId == null) return '';
    final list = context
        .read<GalleriesProvider>()
        .galleries
        .where((Gallery g) => g.id == galleryId)
        .toList();
    return list.isNotEmpty ? list.first.name : '';
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.imagePaths.length;
    final title = _effectiveTitle(context);
    if (total == 0) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: AppColors.bg,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.blackIcon),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: title.isNotEmpty
              ? Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.onSurfaceLight,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : null,
          centerTitle: true,
        ),
        body: const Center(child: Text('Aucune image')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.blackIcon),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.onSurfaceLight,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentIndex + 1}/$total',
                style: const TextStyle(
                  color: AppColors.onSurfaceLight,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: total,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) {
          final caption =
              widget.imageCaptions != null &&
                  index < widget.imageCaptions!.length &&
                  widget.imageCaptions![index].isNotEmpty
              ? widget.imageCaptions![index]
              : null;
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4,
                  child: Center(
                    child: ImageFromPath(
                      path: widget.imagePaths[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                if (caption != null) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      caption,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.newsTitle.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
