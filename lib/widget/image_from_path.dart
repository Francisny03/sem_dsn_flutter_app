import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:sem_dsn/core/constants/app_assets.dart';

/// Affiche une image depuis un chemin asset ou une URL (avec cache pour le réseau).
/// Si [path] est vide, affiche le placeholder [AppAssets.defaultImageArticle].
/// [cacheKey] : clé stable pour le cache (recommandé en photothèque pour réouverture d'album).
/// [memCacheWidth] / [memCacheHeight] : taille en cache mémoire (ex. 400 pour miniatures = plus d'images gardées en mémoire).
class ImageFromPath extends StatelessWidget {
  const ImageFromPath({
    super.key,
    required this.path,
    this.cacheKey,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  final String path;
  final String? cacheKey;
  final BoxFit fit;
  final double? width;
  final double? height;
  final int? memCacheWidth;
  final int? memCacheHeight;

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
        cacheKey: cacheKey ?? p,
        fit: fit,
        width: width,
        height: 10,
        memCacheWidth: memCacheWidth,
        memCacheHeight: memCacheHeight,
        fadeInDuration: Duration.zero,
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
