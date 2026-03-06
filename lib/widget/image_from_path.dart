import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Affiche une image depuis un chemin asset ou une URL (avec cache pour le réseau).
class ImageFromPath extends StatelessWidget {
  const ImageFromPath({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final String path;
  final BoxFit fit;
  final double? width;
  final double? height;

  bool get _isNetwork =>
      path.startsWith('http://') || path.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    if (_isNetwork) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: fit,
        width: width,
        height: height,
        placeholder: (_, __) => SizedBox(
          width: width,
          height: height,
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (_, __, ___) => SizedBox(
          width: width,
          height: height,
          child: const Icon(Icons.broken_image_outlined),
        ),
      );
    }
    return Image.asset(path, fit: fit, width: width, height: height);
  }
}
