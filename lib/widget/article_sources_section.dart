import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sem_dsn/core/constants/app_font_sizes.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/models/article_source.dart';
import 'package:url_launcher/url_launcher.dart';

/// Section affichée en fin d’article : liste des sources (nom + URL en colonne).
class ArticleSourcesSection extends StatelessWidget {
  const ArticleSourcesSection({super.key, required this.sources});

  final List<ArticleSource> sources;

  @override
  Widget build(BuildContext context) {
    if (sources.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sources',
            style: TextStyle(
              color: AppColors.sectionTitle,
              fontSize: AppFontSizes.sectionTitle,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...sources.map(
            (source) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (source.name.isNotEmpty)
                    Text(
                      source.name,
                      style: const TextStyle(
                        color: AppColors.newsTitle,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (source.name.isNotEmpty && source.url.isNotEmpty)
                    const SizedBox(height: 4),
                  if (source.url.isNotEmpty)
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                        text: source.url,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _openUrl(source.url),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
