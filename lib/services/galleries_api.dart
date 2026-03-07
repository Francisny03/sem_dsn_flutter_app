import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:sem_dsn/core/constants/api_config.dart';
import 'package:sem_dsn/models/gallery.dart';
import 'package:sem_dsn/models/gallery_image.dart';

class GalleriesResponse {
  const GalleriesResponse({required this.results, required this.total});
  final List<Gallery> results;
  final int total;
}

class GalleryImagesResponse {
  const GalleryImagesResponse({required this.results, required this.total});
  final List<GalleryImage> results;
  final int total;
}

Future<GalleriesResponse> fetchGalleries() async {
  final uri = Uri.parse(ApiConfig.galleries());
  final response = await http.get(uri, headers: {'accept': '*/*'});
  if (response.statusCode != 200) {
    throw Exception('galleries: ${response.statusCode}');
  }
  final map = json.decode(response.body) as Map<String, dynamic>;
  final list = map['results'] as List<dynamic>? ?? [];
  final total = map['total'] as int? ?? 0;
  return GalleriesResponse(
    results: list.map((e) => Gallery.fromJson(e as Map<String, dynamic>)).toList(),
    total: total,
  );
}

Future<GalleryImagesResponse> fetchGalleryImages(int galleryId) async {
  final uri = Uri.parse(ApiConfig.galleryImages(galleryId));
  final response = await http.get(uri, headers: {'accept': '*/*'});
  if (response.statusCode != 200) {
    throw Exception('galleries/$galleryId/images: ${response.statusCode}');
  }
  final map = json.decode(response.body) as Map<String, dynamic>;
  final list = map['results'] as List<dynamic>? ?? [];
  final total = map['total'] as int? ?? 0;
  return GalleryImagesResponse(
    results: list.map((e) => GalleryImage.fromJson(e as Map<String, dynamic>)).toList(),
    total: total,
  );
}
