import 'package:flutter/material.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';

/// Page plein écran pour afficher une image de la photothèque.
/// Défilement horizontal entre les images, indicateur "1/10", "2/10" en haut, légende sous l'image.
class PhotothequeFullscreenPage extends StatefulWidget {
  const PhotothequeFullscreenPage({
    super.key,
    required this.imagePaths,
    this.initialIndex = 0,
    this.imageCaptions,
  });

  final List<String> imagePaths;
  final int initialIndex;

  /// Légende par image (même ordre que [imagePaths]). Affichée sous l'image si non vide.
  final List<String>? imageCaptions;

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

  @override
  Widget build(BuildContext context) {
    final total = widget.imagePaths.length;
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
      body: Stack(
        children: [
          PageView.builder(
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
                        child: Image.asset(
                          widget.imagePaths[index],
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.image_not_supported, size: 48),
                          ),
                        ),
                      ),
                    ),
                    if (caption != null) ...[
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.blackIcon),
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentIndex + 1}/$total',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
