import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:sem_dsn/core/constants/app_assets.dart';

/// Affiche une image depuis un chemin asset ou une URL (avec cache pour le réseau).
/// Si [path] est vide, affiche le placeholder [AppAssets.defaultImageArticle].
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

  String get _effectivePath =>
      path.trim().isEmpty ? AppAssets.defaultImageArticle : path;

  bool get _isNetwork {
    final p = _effectivePath;
    return p.startsWith('http://') || p.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final p = _effectivePath;
    if (_isNetwork) {
      return CachedNetworkImage(
        imageUrl: p,
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
    return Image.asset(p, fit: fit, width: width, height: height);
  }
}
