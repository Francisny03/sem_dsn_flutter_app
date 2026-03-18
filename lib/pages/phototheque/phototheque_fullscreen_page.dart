import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:sem_dsn/core/constants/app_assets.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/models/gallery.dart';
import 'package:sem_dsn/providers/galleries_provider.dart';

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
  final List<String>? imageCaptions;
  final String? albumTitle;
  final int? galleryId;

  @override
  State<PhotothequeFullscreenPage> createState() =>
      _PhotothequeFullscreenPageState();
}

class _PhotothequeFullscreenPageState extends State<PhotothequeFullscreenPage>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;

  late AnimationController _animationController;
  Animation<double>? _scaleAnimation;

  bool _isZooming = false;

  late final List<PhotoViewController> _photoViewControllers;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;

    _animationController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 300), // Durée du "smooth"
        )..addListener(() {
          if (_scaleAnimation != null) {
            _photoViewControllers[_currentIndex].scale = _scaleAnimation!.value;
          }
        });

    _photoViewControllers = List.generate(
      widget.imagePaths.length,
      (_) => PhotoViewController(),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in _photoViewControllers) {
      c.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    final controller = _photoViewControllers[_currentIndex];
    final double begin = controller.scale!;

    // Définir la cible : si dézoomé -> zoom (x2), sinon -> retour au min
    final double end = (begin <= PhotoViewComputedScale.contained.multiplier)
        ? PhotoViewComputedScale.covered.multiplier * 2.0
        : PhotoViewComputedScale.contained.multiplier;

    _scaleAnimation = Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward(from: 0.0);
  }

  void _resetZoomFor(int index) {
    if (index < 0 || index >= _photoViewControllers.length) return;
    _photoViewControllers[index].reset();
  }

  ImageProvider _imageProviderForPath(String path) {
    final effectivePath = path.trim().isEmpty
        ? AppAssets.defaultImageArticle
        : path;

    final isNetwork =
        effectivePath.startsWith('http://') ||
        effectivePath.startsWith('https://');

    if (isNetwork) {
      return CachedNetworkImageProvider(effectivePath);
    }
    return AssetImage(effectivePath);
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final caption =
              widget.imageCaptions != null &&
                  _currentIndex < widget.imageCaptions!.length &&
                  widget.imageCaptions![_currentIndex].isNotEmpty
              ? widget.imageCaptions![_currentIndex]
              : null;

          final captionHeight = constraints.maxHeight * 0.25;

          return Column(
            children: [
              Expanded(
                child: PhotoViewGallery.builder(
                  pageController: _pageController,
                  itemCount: total,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                      _isZooming = false;
                    });
                    _resetZoomFor(index);
                  },
                  backgroundDecoration: const BoxDecoration(
                    color: AppColors.bg,
                  ),
                  scrollPhysics: const BouncingScrollPhysics(),
                  enableRotation: false,

                  /// 🔥 DETECTION ZOOM
                  scaleStateChangedCallback: (scaleState) {
                    final zooming = scaleState == PhotoViewScaleState.zoomedIn;

                    if (zooming != _isZooming) {
                      setState(() => _isZooming = zooming);

                      if (!zooming) {
                        _resetZoomFor(_currentIndex);
                      }
                    }
                  },

                  builder: (context, index) {
                    return PhotoViewGalleryPageOptions.customChild(
                      controller: _photoViewControllers[index],
                      initialScale: PhotoViewComputedScale.contained,
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 2.5,
                      child: GestureDetector(
                        onDoubleTap:
                            _handleDoubleTap, // 🔥 Appelle la fonction fluide
                        child: CachedNetworkImage(
                          imageUrl: widget.imagePaths[index],
                          fit: BoxFit.contain,
                          // ... rest of your code ...
                        ),
                      ),
                    );
                  },
                ),
              ),

              /// 🔥 TEXTE QUI DISPARAIT AU ZOOM
              if (caption != null && caption.isNotEmpty)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: _isZooming ? 0 : 1,
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    child: SizedBox(
                      height: _isZooming ? 0 : captionHeight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Text(
                            caption,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.blackIcon,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
